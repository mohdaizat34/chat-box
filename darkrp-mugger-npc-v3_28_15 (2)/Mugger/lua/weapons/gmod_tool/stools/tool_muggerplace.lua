TOOL.Category = "Mugger NPC"
TOOL.Name = "Mugger Spawner"
TOOL.Command = nil
TOOL.ConfigName = ""
TOOL.ShootSound = Sound( "Airboat.FireGunRevDown" )
TOOL.muggers = {}

if CLIENT then
	language.Add( "tool.tool_muggerplace.name", "Mugger Spawner" )
	language.Add( "tool.tool_muggerplace.desc", "Places a mugger NPC " )
	language.Add( "tool.tool_muggerplace.0", "Left-click: Spawn mugger. Right-click: Edit mugger's spawn point." )
	language.Add( "tool.tool_muggerplace.1", "Click somewhere else to set the mugger's new spawn" )
	language.Add( "tool.undone_muggerplace", "Undone mugger." )
end

--// Creates a mugger
function TOOL:LeftClick( tr )
	if CLIENT then 
		local effect = EffectData()
		effect:SetOrigin(tr.HitPos)
		util.Effect("cball_explode", effect)
		return 
	end
	
	self.Weapon:EmitSound( self.ShootSound )
	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self:GetOwner():SetAnimation( PLAYER_ATTACK1 )

	if self:GetStage() == 0 then
		if tr.HitNonWorld or tr.HitSky then return end
		
		-- Create a new mugger
		local ent = mugger.spawnNew( tr.HitPos )
		
		if not IsValid(ent) then return end
		
		ent.startPos = tr.HitPos
		
		table.insert( self.muggers, ent )
		
		undo.Create("mugger")
			undo.AddEntity( ent )
			undo.SetPlayer( self:GetOwner() )
		undo.Finish()
	else
		-- Set the mugger's start position
		self.mugger.startPos = tr.HitPos
		self:SetStage( 0 )
	end
end
 
--// Moves the spawn position of a mugger
function TOOL:RightClick( tr )
	if CLIENT then 
		local effect = EffectData()
		effect:SetOrigin(tr.HitPos)
		util.Effect("cball_explode", effect)
		return 
	end
	

	self.Weapon:EmitSound( self.ShootSound )
	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self:GetOwner():SetAnimation( PLAYER_ATTACK1 )
	
	if self:GetStage() == 0 then
		if IsValid( tr.Entity ) and tr.Entity:GetClass() == "mugger" then
			-- Select the mugger that we are looking at
			self.mugger = tr.Entity
			self:SetStage( 1 )
		end
	else
		-- Set the mugger's start position
		self.mugger.startPos = tr.HitPos
		self:SetStage( 0 )
	end
end

--// Print all valid mugger positions to console as a spawn table
function TOOL:Reload()
	if CLIENT then return end
	
	local function print( text )
		self:GetOwner():PrintMessage( HUD_PRINTCONSOLE, text )
	end

	if #self.muggers > 1 then
		for i = 1, #self.muggers do
			local ent = self.muggers[i]
			if i == 1 then
				print(string.format('["%s"] = {', 
				game.GetMap()))
			end
			
			if IsValid( ent ) then
				local pos = ent.startPos != nil and ent.startPos or ent:GetPos()
				
				print(string.format('\tVector( %s, %s, %s ),',
				pos.x,
				pos.y,
				pos.z))
			end
		end
		print("},")
	elseif #self.muggers == 1 then
		local ent = self.muggers[1]
		local pos = ent.startPos != nil and ent.startPos or ent:GetPos()
		
		print(string.format('["%s"] = Vector( %s, %s, %s ),',
		game.GetMap(),
		pos.x,
		pos.y,
		pos.z
		))
	else
		print("You ain't got no muggers")
	end
end


 