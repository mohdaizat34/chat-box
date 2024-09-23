--// Mugger entity 

AddCSLuaFile()

ENT.Base 				= "base_nextbot"
ENT.AdminSpawnable		= true
ENT.Spawnable			= false

function ENT:Initialize()	
	-- Start position which will get overridden later
	self.startPos = Vector( 0, 0, 0 )

	-- Random model from the config table
	self:SetModel( mugger.config.models[math.random(#mugger.config.models)] )
	
	-- Give him a name
	self:SetNWString("mugger_name", table.Random( mugger.config.names ) )
	
	-- Gotta have a knife for looks
	self.weapon = self:createKnife()

	-- Values
	self.curSearchTime = 0
	self.stuckCount = 0
	self.cooldown = false
	self.targetHit = false
	self.inUse = false
	self.usingPlayer = nil
	self.funder = nil
	
	-- Spawn protection
	self:SetHealth(5000)
end

function ENT:createKnife()
	if CLIENT then return end
	
	-- Get right hand attachment
	local att = "anim_attachment_RH"
	local shootpos = self:GetAttachment( self:LookupAttachment(att) )
	
	-- Create the knife

	local wep = ents.Create("weapon_mug_knife")
	wep:SetOwner( self )
	wep:SetPos( shootpos.Pos )
	wep:SetHoldType( "knife" )
	wep:Spawn()
	
	-- No collisions
	wep:SetSolid( SOLID_NONE )	
	wep:SetParent( self )

	-- Attach it to the bot
	wep:Fire( "setparentattachment", "anim_attachment_RH" )
	wep:AddEffects( EF_BONEMERGE )
	wep:SetAngles( self:GetForward():Angle() )
	
	return wep
end

--// Helper function for debugging
function ENT:setStatus( text )
	if mugger.config.debug then
		print("[Mugger]: "..text)
		self:SetNWString( "mugger_status", text )
	end
end

--// Helper function for debugging
function ENT:getStatus()
	return self:GetNWString( "mugger_status", "nil" )
end

--// Set a new target for the mugger to attack
function ENT:setTarget( ent )
	self.targetHit = false
	self.target = ent
end

--// Returns the mugger's target
function ENT:getTarget()
	return self.target
end

--// Does this mugger have a target?
function ENT:hasTarget()
	if IsValid( self:getTarget() ) then
		if self.target:IsPlayer() then
			return self.target:Alive()
		end
	end
	return false
end

function ENT:fullReset()
	self.curSearchTime = 0
	self.stuckCount = 0
	self.cooldown = false
	self.targetHit = false
	self.inUse = false
	self.usingPlayer = nil
	self.funder = nil
end

function ENT:completedMugging()
	self.funder = nil
	self.targetHit = false
	self:setTarget( nil )
end

local lastNotif = 0
function ENT:Use( activator, ply, type, val )
	if CLIENT then return end
	
	-- Prevent the use function from being called more than once by the same player
	if self.usingPlayer == ply then return end
	
	-- Check that their job can hire the mugger
	local canUse = true
	if #mugger.config.useableJobs > 0 then
		canUse = false
		for _, job in pairs( mugger.config.useableJobs ) do
			if job:lower() == team.GetName( ply:Team() ):lower() then
				canUse = true
				break
			end
		end
	end
	
	if not canUse then
		if CurTime() > lastNotif then
			net.Start("mug_notify")
				net.WriteString("Your job cannot hire the mugger!")
			net.Send( ply )
			lastNotif = CurTime() + 1
		end
		return
	end
	
	-- Check that their usergroup can hire the mugger
	canUse = true
	if #mugger.config.useableUsergroups > 0 then
		canUse = false
		for _, job in pairs( mugger.config.useableUsergroups ) do
			if job:lower() == ply:GetUserGroup():lower() then
				canUse = true
				break
			end
		end
	end
	
	if not canUse then
		if CurTime() > lastNotif then
			net.Start("mug_notify")
				net.WriteString("Your usergroup cannot hire the mugger!")
			net.Send( ply )
			lastNotif = CurTime() + 1
		end
		return
	end
	
	-- Make sure the mugger is not in the middle of something important
	if not self.inUse and not self:hasTarget() and not IsValid( self.funder ) and not self.cooldown and not self.usingPlayer then
		mugger.log( ply:Nick().." is now interacting with mugger: "..self:GetNWString("mugger_name","") )

		net.Start("mug_panel")
			--net.WriteString( self:GetNWString("mugger_name",""), 8 )
			net.WriteVector( self:GetPos() )
		net.Send( ply )
		
		-- Rotate the mugger to face its user
		local ratio = 0
		timer.Create("mugger_turn", 0.1, 10, function()
			ratio = ratio + 0.1
			
			local ang = self:GetAngles()
			local dif = ( ply:GetPos() - self:GetPos() ):Angle()
			
			local y = Lerp( ratio, dif.y, ang.y )
			
			self:SetAngles( Angle( ang.p, y, ang.r ) )
		end)
		
		ply.usingMugger = self
		self.usingPlayer = ply
		self.inUse = true
	else
		if CurTime() > lastNotif then -- Prevent spam
			net.Start("mug_notify")
				net.WriteString("This mugger is busy at the moment")
			net.Send( ply )
			lastNotif = CurTime() + 1
			
			local debug = string.format( "Mugger is busy! InUse: %s. Target: %s. Valid: %s. Cooldown: %s. Using: %s", 
			self.inUse, self:hasTarget(), IsValid( self.funder ), self.cooldown, self.usingPlayer)
			
			-- Print the details into console so they can be checked
			ply:PrintMessage( HUD_PRINTCONSOLE, debug.."\tOther:"..tostring(self.funder).." "..tostring(self.usingPlayer))
			
			if mugger.config.debug then
				print(debug)
			end
		end
	end
end

function ENT:Think()
	if CLIENT then return end
	
	if not IsValid( self.weapon ) then
		self.weapon = self:createKnife()
	end
	
	-- Make sure our using player is valid
	if self.inUse then
		self:setStatus("In use by "..tostring(self.usingPlayer))
		
		-- If something happens to our user, disregard him
		if not IsValid(self.usingPlayer) or not self.usingPlayer:Alive() or self.usingPlayer:isArrested() then
			self.usingPlayer = nil
			self.funder = nil
			self.inUse = false
			
			if self.usingPlayer then
				self.usingPlayer.usingMugger = nil
			end
		end
	end
	
	self.nextDoorCheck = self.nextDoorCheck or 0  
	
	-- Check periodically for doors and other interactable objects when we are out running
	if CurTime() > self.nextDoorCheck and self:GetPos():Distance( self.startPos ) > 20 then
		-- Find all doors in front of the mugger
		local tr = util.TraceLine( {
			start = self:EyePos(),
			endpos = self:EyePos() + self:EyeAngles():Forward() * 200,
			filter = self
		} )
		
		local delay = 0.5
		
		local ent = tr.Entity

		if IsValid(ent) and self:GetPos():Distance( ent:GetPos()) < 100 then -- Make sure its valid and we are close to it
			local isDoor, isSliding = mugger.isDoor( ent )
			if isDoor and not ent:isDoorOpen() and not ent:isDoorOpening() then -- Open closed doors
				local val = ent:GetKeyValues()
				local oldDir = val["opendir"] -- Get the old open direction
				
				-- Override the open direction because doors are stupid and open in the muggers face
				local fwd = ent:GetForward()
				if fwd.p == 1 then
					ent:SetKeyValue( "opendir", "0" )
				elseif fwd.y == 1 then
					ent:SetKeyValue( "opendir", "1" )
				end
				
				-- Open it
				ent:Fire("open")
				self.openedDoor = true
				
				self:setStatus("Opened door")
				
				-- Restore open direction
				ent:SetKeyValue( "opendir", tostring(oldDir) )
			elseif string.find(ent:GetClass(), "func_breakable") then -- Shatter glass
				ent:Fire("break")
			end
		elseif self:GetPos():Distance( tr.HitPos ) > 200 then -- Nothing close
			delay = 1.5 -- So we don't need to trace as often
		end
		
		self.nextDoorCheck = CurTime() + delay
	end

	if self:getStatus():lower() == "returning" then
		if mugger.config.debug then
			print("Mugger is "..math.floor(self:GetPos():Distance( self.startPos )).." units away from their start position")
		end
	end
	
	if self:hasTarget() then	
		-- Remove spawn protection
		if self:Health() > mugger.config.health then
			self:SetHealth( Lerp( 0.1, self:Health(), mugger.config.health ) )
		end
		
		-- Increment the search time
		self.curSearchTime = self.curSearchTime + engine.TickInterval()
		
		-- Its been too long since we've seen the mugger
		if self.curSearchTime > mugger.config.maxSearchTime then
			self:setStatus("Exceeded max search time")
			if IsValid( self.funder ) then
				net.Start("mug_notify")
					net.WriteString("Your mugger has given up trying to find the your target.")
				net.Send( self.funder )
				
				if mugger.config.refunds then
					net.Start("mug_notify")
						net.WriteString("You were refunded $"..mugger.config.hireCost)
					net.Send( self.funder )
					
					self.funder:addMoney( mugger.config.hireCost )
				end
			end
			
			self.funder = nil
			
			self.targetHit = false
			self:setTarget( nil )
			self.curSearchTime = 0
			return
		end
		
		local pos = self:GetPos()
		local tPos = self:getTarget():GetPos()
		
		-- If we are close to the target and they are on a ledge, jump
		if math.abs(pos.x - tPos.x) < 100 and math.abs(pos.y - tPos.y) < 100 then
			if tPos.z > pos.z and tPos.z - pos.z > 20 and tPos.z - pos.z < 70 then
				self:setStatus("Jumping to reduce gap of "..tostring(tPos.z - pos.z) )
				self.loco:Jump()
			end
		end
		
		-- We are close enough to mug them
		if math.abs(pos.x - tPos.x) < 35 and math.abs(pos.y - tPos.y) < 50 and tPos.z - pos.z < 70 then
			self:setStatus("In range of target, mugging")
			
			local ply = self:getTarget()
			self:setTarget( nil )
			self.targetHit = true
			
			self.weapon:EmitSound( "Weapon_Knife.Hit" )
			self:EmitSound( "vo/coast/odessa/male01/nlo_cheer0"..math.random(1,4)..".wav" ) -- Victory screech!
			
			-- Steal a variable amount of money from our victim and make sure we don't steal more money than they have
			local steal
			if mugger.config.maxMoneyStolen > ply:getDarkRPVar("money") then
				steal = math.random( mugger.config.minMoneyStolen, ply:getDarkRPVar("money") )
			else
				steal = math.random( mugger.config.minMoneyStolen, mugger.config.maxMoneyStolen )
			end
			
			-- Transaction
			self.stolenMoney = steal
			ply:addMoney( -steal )
			
			net.Start("mug_notify")
				net.WriteString("You have been mugged for $"..steal.."! Don't let him get away!!")
			net.Send( ply )
			
			-- Take damage
			if mugger.config.takeDamage then
				ply:TakeDamage( math.random(mugger.config.minDamage, mugger.config.maxDamage), self, self.weapon )
			end
			
			-- Check to see if they survived the stab
			if ply:Alive() then
				-- Create our fake knocked down player
				ply:CreateRagdoll()
				local rag = ply:GetRagdollEntity()
				rag:SetNWBool( "mug_ragdoll", true )
				ply:SetNoDraw( true )
				ply:Freeze( true )
				ply:SetNWBool( "mug_ragdoll", true )
				
				-- Reset it all
				timer.Simple(mugger.config.downTime, function()
					ply:SetNWBool( "mug_ragdoll", false )
					ply:SetNoDraw( false )
					ply:Freeze( false )
					
					if IsValid( rag ) then
						rag:Remove()
					end
				end)
			end
			
			local chance = math.random(50)
			if chance == 1 then
				self:Ignite( 5 )
			end
		end
	else
		self.curSearchTime = 0
	end
end

function ENT:RunBehaviour()

	while true do
		if self:hasTarget() then
			self:setStatus("Chasing target")
			self.loco:FaceTowards(self:getTarget():GetPos())
			self:StartActivity( ACT_RUN )
			self.loco:SetDesiredSpeed( mugger.config.chaseSpeed )
			self.loco:SetAcceleration( mugger.config.chaseAcceleration )
			local result = self:chaseEnemy() 
			self.loco:SetAcceleration( 400 )
			self:StartActivity( ACT_IDLE )
			
			-- Could not reach the target so we give up and head back
			if result == "stuck" or result == "failed" then 
				self:setStatus("Failed to reach target, giving up")
				
				self.targetHit = false
				self:setTarget( nil )
			end
		else
			-- Mugger is making his way back home
			if self:GetPos():Distance( self.startPos ) > 40 then
				self:setStatus("Returning")
				self:StartActivity( ACT_RUN )
				self.loco:SetDesiredSpeed( mugger.config.fleeSpeed )
				self.loco:SetAcceleration( mugger.config.fleeAcceleration )
				local result = self:MoveToPos( self.startPos )
				
				-- Our home is blocked, lets wander a bit to try to get unstuck
				if result == "stuck" or result == "failed" then 
					self:setStatus("Attempting to get unstuck")
					local pos = self:GetPos()
					self:MoveToPos( Vector( pos.x + math.random(-100,100), pos.y + math.random(-100,100), pos.z ) )
				end
			else
				-- Mugger was hired
				if IsValid( self.funder ) then
					if self.targetHit then
						net.Start("mug_notify")
							net.WriteString("Your mugger successfully mugged the target and got you $"..self.stolenMoney.."!")
						net.Send( self.funder )
						
						self.funder:addMoney( self.stolenMoney )
					else
						net.Start("mug_notify")
							net.WriteString("Your mugger was unable to reach the target")
						net.Send( self.funder )
						
						-- Are we nice enough to refund the player?
						if mugger.config.refunds then
							net.Start("mug_notify")
								net.WriteString("You were refunded $"..mugger.config.hireCost)
							net.Send( self.funder )
							
							self.funder:addMoney( mugger.config.hireCost )
						end
					end
					
					self:completedMugging()
					self:setStatus("Cooldown")
					
					-- Cooldown after being hired
					self.cooldown = true
					timer.Simple( mugger.config.cooldownTime, function()
						self.cooldown = false
						self.funder = nil
					end)
				else
					-- We are resting, reset variables
					self.stolenMoney = 0
					self:RemoveAllDecals()
					self:SetHealth( 5000 )
				end
			end
		end
		
		-- Stop the mugger from wandering when somebody tries to use him
		if self.inUse then
			local result = self:MoveToPos( self:GetPos() )
			self:StartActivity( ACT_IDLE )
		end
		
		if self.cooldown == true then -- Chill out for a while
			self:setStatus("Cooling")
			self:StartActivity( ACT_BUSY_SIT_GROUND )
		elseif mugger.config.wanderWhenIdle and not self.inUse then -- Wander about because the mugger is idle
			self:setStatus("Wandering")
			self:StartActivity( ACT_WALK )
			self.loco:SetDesiredSpeed( 200 )
			self.loco:SetAcceleration( 400 )
			
			local pos = self:GetPos()
			local x = math.random( pos.x - 500, pos.x + 500 )
			local y = math.random( pos.y - 500, pos.y + 500 )
			self:MoveToPos( Vector( x, y, pos.z ) )
			self.startPos = self:GetPos()
			self:StartActivity( ACT_IDLE )
		elseif mugger.config.wanderAlongPath and not self.inUse then -- Follow our predetermined path because we have no jobs
			self:setStatus("Following path")
			
			-- Walk to each point in the path
			for i = 1, #mugger.path[game.GetMap()] do
				local pos = mugger.path[game.GetMap()][i]
				
				self:StartActivity( ACT_WALK )
				self.loco:SetDesiredSpeed( 200 )
				self.loco:SetAcceleration( 400 )
				
				self:MoveToPos( pos )
				self:StartActivity( ACT_IDLE )
				coroutine.wait( 1 ) -- Wait a little bit at each point to give people time to catch up
			end
		else -- Otherwise we just stand still
			self:setStatus("Idle")
			self:StartActivity( ACT_IDLE )
		end
		
		coroutine.wait( .5 )
	end
end	

--// Default MoveToPos function edited to fail when the mugger is in use
function ENT:MoveToPos( pos, options )

	local options = options or {}

	local path = Path( "Follow" )
	path:SetMinLookAheadDistance( options.lookahead or 300 )
	path:SetGoalTolerance( options.tolerance or 20 )
	path:Compute( self, pos )

	if ( !path:IsValid() ) then return "failed" end

	while ( path:IsValid() and not self.inUse ) do

		path:Update( self )

		if ( options.draw ) then
			path:Draw()
		end

		if ( self.loco:IsStuck() ) then
			self:HandleStuck();
			return "stuck"
		end

		if ( options.maxage ) then
			if ( path:GetAge() > options.maxage ) then return "timeout" end
		end
		
		if ( options.repath ) then
			if ( path:GetAge() > options.repath ) then path:Compute( self, pos ) end
		end
		coroutine.yield()
	end
	return "ok"
end

--// Garry's Mod wiki chase enemy function (modified) because there is no need to reinvent the wheel
function ENT:chaseEnemy( options )

	local options = options or {}

	local path = Path( "Chase" )
	path:SetMinLookAheadDistance( options.lookahead or 300 )
	path:SetGoalTolerance( options.tolerance or 20 )
	path:Chase( self, self:getTarget() )
	--path:Compute( self, self:getTarget():GetPos() )

	if ( !path:IsValid() ) then return "failed" end

	while ( path:IsValid() and self:hasTarget() ) do
	
		-- Fixes them from being stuck in a permanent jump position
		if self.loco:IsClimbingOrJumping() then
			self:setStatus("Fix jump")
			self:StartActivity( ACT_RUN )
		end
	
		if ( path:GetAge() > 0.1 ) then
			path:Compute(self, self:getTarget():GetPos())
		end
		path:Update( self )
		
		if ( options.draw ) then path:Draw() end
		
		if ( self.loco:IsStuck() or self.openedDoor ) then
			self:setStatus("Stuck")
			
			self:HandleStuck()
			
			local pos = self:GetPos()
			
			if self.openedDoor then
				 -- Opened a door, so we need to back up so it can open
				self:MoveToPos( pos - (self:GetForward()*100) ) 
			else
				-- Just generally stuck, move around a little
				local sign = math.random(-1,1)
				self:MoveToPos( pos - (self:GetForward()*100) + (self:GetRight() * 100 * sign) )
			end
			
			if not self.openedDoor then -- Don't count this as a stuck if it was manual
				self.stuckCount = self.stuckCount + 1
			end
			self.openedDoor = false
			
			-- Try try again until we finally give up
			if self.stuckCount > 3 and not self.openedDoor then
				self.stuckCount =  0
				return "stuck"
			end
		end
		coroutine.yield()
	end
	return "ok"
end

--// Fire, fire, fire!
function ENT:OnIgnite()
	self:setTarget( nil )
end

--// Damage handler
function ENT:OnInjured( dmginfo )
	if self:Health() <= mugger.config.health then -- Make sure we are actually on a job	
		local wep = dmginfo:GetAttacker().GetActiveWeapon and dmginfo:GetAttacker():GetActiveWeapon() or "[NULL ENTITY]"
		local dmg = dmginfo:GetDamage() or 0
		
		-- CW2.0 doesn't like Nextbots so we need to manually fetch and deal the damage ourselves
		if dmg == 0 then
			if type(wep) != "string" then
				dmg = wep.Damage or 15
			else
				mugger.log(string.format( "Mugger (%s) was damaged by a null entity"))
				return
			end
		end
		
		self:SetHealth( self:Health() - dmg )
	
		mugger.log(string.format( "Mugger (%s) was damaged for (%s) damage by a (%s)",
		self:GetNWString("mugger_name",""), dmg, wep))
	end
end

--// Death handler
function ENT:OnKilled( dmginfo )
	-- Cache this because it will be nil once we remove the mugger
	local spawnPos = self.startPos
	
	-- Standard death stuff
	hook.Call( "OnNPCKilled", GAMEMODE, self, dmginfo:GetAttacker(), dmginfo:GetInflictor() )
	
	-- Create our own ragdoll
	local rag = ents.Create("prop_ragdoll")
	rag:SetPos( self:GetPos() )
	rag:SetAngles( self:GetAngles() )
	rag:SetModel( self:GetModel() )
	rag:SetSkin( self:GetSkin() )
	rag:SetNWBool("mug_ragdoll", true)
	self:Remove()
	rag:Spawn()
	
	-- Alert other players
	net.Start("mug_notify")
		net.WriteString("The mugger has been killed! Another will take his place shortly")
	net.Broadcast()
	
	-- Alert the hirer
	if self.funder then
		net.Start("mug_notify")
			net.WriteString("Your mugger was killed while in action! Your money was lost") -- No refunds if the mugger died
		net.Send( self.funder )
		
		-- Drop a bag o' money
		local pos = self:GetPos()
		DarkRP.createMoneyBag( Vector( pos.x, pos.y, pos.z + 20 ), (self.stolenMoney or 0) + mugger.config.hireCost)
	end

	self.funder = nil
	self.targetHit = false
	self:setTarget( nil )

	-- Get rid of the knife
	if IsValid( self.weapon ) then
		self.weapon:Remove()
	end
	
	-- Simple body despawn
	timer.Simple(5, function()
		if IsValid( rag ) then
			rag:Remove()
		end
	end)
	
	if mugger.config.shouldRespawn then
		-- Respawn a new mugger
		timer.Simple(mugger.config.respawnDelay, function()
			mugger.spawnNew( spawnPos )
		end)
	end
end

list.Set( "NPC", "mugger", {
	Name = "Mugger", 
	Class = "mugger", 
	Category = "Nextbot"
})