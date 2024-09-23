--// Serverside mugger handling

mugger.eventLog = {}

DOOR_STATE_CLOSED = 0
DOOR_STATE_OPENING = 1
DOOR_STATE_OPEN = 2
DOOR_STATE_CLOSING = 3
DOOR_STATE_AJAR = 4

local meta = FindMetaTable("Entity")

-- Door metatable functions
function meta:getDoorState()
	return self:GetSaveTable().m_eDoorState --or self:GetSaveTable().m_toggle_state
end

function meta:isDoorClosed()
	return self:getDoorState() == DOOR_STATE_CLOSED
end

function meta:isDoorClosing()
	return self:getDoorState() == DOOR_STATE_CLOSING
end

function meta:isDoorOpening()
	return self:getDoorState() == DOOR_STATE_OPENING
end

function meta:isDoorOpen()
	return self:getDoorState() == DOOR_STATE_OPEN
end

function mugger.isDoor( ent )
	local class = ent:GetClass()
	if class == "prop_door_rotating" or class == "func_door" or class == "func_door_rotating" then
		return true, class == "func_door"
	end
	return false
end

--// Prevents players from picking up the mugger's knife
hook.Add("PlayerCanPickupWeapon", "mugger_knife", function( ply, wep )
	if wep:GetClass() == "weapon_mug_knife" then
		return false
	end
end)

--// Deletes the knife from any player who manages to pick it up
hook.Add("PlayerCanPickupWeapon", "mugger_knifedel", function( wep )
	timer.Simple(0, function()
		if IsValid(wep) and wep:GetClass() == "weapon_mug_knife" then
			wep:Remove()
		end
	end)
end)

--// Prevents non-admins and kids from spawning muggers
hook.Add("CanTool", "mugger_stool", function( ply, tr, tool )
	if tool == "tool_muggerplace" then
		if mugger.isAdmin( ply ) then
			return true
		else
			ply:ChatPrint("Only admins can use the mugger tool!")
			return false
		end
	end
end)

--// Prevents the mugger or mugged players from being physgunned
hook.Add("PhysgunPickup", "mugger_physgun", function( ply, ent )
	if ent:GetClass() == "mugger" or ent:GetNWBool( "mug_ragdoll", false ) then
		if mugger.isAdmin( ply ) then
			return true
		else
			return false
		end
	end
end)

--// Sends the mugger log data to the client
hook.Add( "PlayerSay", "mugger_logs", function( ply, text, public )
	text = string.lower( text )
	if string.sub( text, 1 ) == "!mugger" then
		mugger.sendLogs( ply )
	end
end )

--// Creates the mugger when the map starts
hook.Add("InitPostEntity", "mugger_spawn", function()
	timer.Simple(1, function() -- Wait a little bit otherwise he won't spawn
		if mugger.spawnpoints[game.GetMap()] == nil then
			mugger.chatBroadcast( "Unable to locate spawn point position in config table! The mugger won't be able to spawn" )
			error("Attempt to spawn mugger on nil vector! Make sure you included a proper table entry in the config file")
		end
	
		mugger.spawnForMap()
	end)
end)	

--// Spawn the muggers for this map
function mugger.spawnForMap()
	if mugger.spawnpoints[game.GetMap()].x then -- Its a vector
		local ent = mugger.spawnNew()
		
		if not ent then
			mugger.chatBroadcast( "An error occurred while creating the mugger(s)! Check the server console" )
		end
	else -- Its a table of vectors, so we spawn each mugger individually
		for _, pos in pairs( mugger.spawnpoints[game.GetMap()] ) do
			local ent = mugger.spawnNew( pos )
			
			if not ent then
				mugger.chatBroadcast( "An error occurred while creating the mugger(s)! Check the server console" )
			end
		end
	end
end

--// Spawns a new mugger at the specified position
function mugger.spawnNew( pos )
	print("Creating new mugger at Vector: "..tostring(pos))
	local spawnpoints = mugger.spawnpoints[game.GetMap()]
	
	if not spawnpoints then
		error("Attempt to spawn mugger on nil vector! Make sure you included a proper table entry in the config file. #2")
	end
	
	if not file.Exists("maps/"..game.GetMap()..".nav", "GAME" )  then
		mugger.chatBroadcast( "Unable to locate .nav file for current map! Run the serverside command 'nav_generate' to fix this." )
		error("Failed to locate navmesh! Generate one with the concommand 'nav_generate'")
	end
	
	if not pos then
		if spawnpoints.x then
			print("Spawning mugger at spawnpoint vector")
			pos = spawnpoints
		else
			print("Spawning mugger at random spawnpoint vector")
			pos = table.Random(spawnpoints)
		end
	end
	
	if not pos then
		error("Attempt to spawn mugger on nil vector! Make sure you included a proper table entry in the config file. #3")
	end
	
	for _, k in pairs( ents.GetAll() ) do
		if k:GetClass() == "mugger" then
			if k:GetPos():Distance( pos ) < 50 then -- Shouldn't place multiple muggers on top of each other
				mugger.log("Attempt to spawn mugger on top of existing")
				return 
			end
		end
	end
	
	local ent = ents.Create("mugger")
	ent:SetPos( pos )
	ent:Spawn()
	
	-- Set their 'home'
	ent.startPos = pos
	
	mugger.log( "Successfully created new mugger! "..ent:EntIndex() )
	
	return ent
end

--// Prints a message to the player's chat
function mugger.chatMsg( ply, text )
	net.Start("mug_chat")
		net.WriteString( text )
	net.Send( ply )
end

--// Broadcasts a chat message
function mugger.chatBroadcast( text )
	net.Start("mug_chat")
		net.WriteString( text )
	net.Broadcast()
end

--// Logs an event the mugger table
function mugger.log( ... )
	local text = table.concat( {...}, " " )
	
	print("[Mugger]: "..text)
	
	table.insert( mugger.eventLog, string.format( "[%s]: %s", os.date("%X"), text ) )
end

function mugger.sendLogs( ply )
	local canUse
	if #mugger.config.canViewLogUsergroups > 0 then
		canUse = mugger.isAdmin( ply )
	else
		canUse = mugger.canViewLogs( ply )
	end
	
	if not canUse then
		mugger.log(ply:Nick().." attempted to access mugger logs but was denied")
		return
	end
	
	mugger.log(ply:Nick().." has requested access to the mugger logs")
	
	net.Start("mug_getlog")
		net.WriteTable( mugger.eventLog ) -- Oh god, WriteTable
	net.Send( ply )
end

--// Is the player considered an admin
function mugger.isAdmin( ply )
	local canUse = false
	if #mugger.config.adminUsergroups > 0 then
		for _, job in pairs( mugger.config.adminUsergroups ) do
			if job:lower() == ply:GetUserGroup():lower() then
				canUse = true
				break
			end
		end
	end
	
	return canUse
end

--// Can the player view the mugger logs
function mugger.canViewLogs( ply )
	local canUse = false
	if #mugger.config.canViewLogUsergroups > 0 then
		for _, job in pairs( mugger.config.canViewLogUsergroups ) do
			if job:lower() == ply:GetUserGroup():lower() then
				canUse = true
				break
			end
		end
	else
		return mugger.isAdmin( ply ) -- Default to admin usergroups
	end
	
	return canUse
end

--// Returns all the alive muggers
function mugger.getAll()
	local mugs = {}
	
	for k, v in pairs( ents.GetAll() ) do
		if v:GetClass() == "mugger" then
			table.insert( mugs, v )
		end
	end
	
	return mugs
end

--// Concommand to create a mugger or delete one
net.Receive( "mug_spawn", function( len, ply )
	if mugger.isAdmin( ply ) then
		local name = net.ReadString()
		
		if name == "" then
			local ent = mugger.spawnNew( )
			
			-- This entity failed to be created
			if not ent then
				mugger.chatMsg( ply, "An error occurred while creating your mugger! Check the server console" )
			end

			undo.Create("mugger")
				undo.AddEntity( ent )
				undo.SetPlayer( ply )
			undo.Finish()
		else
			for k_, ent in pairs( ents.GetAll() ) do
				if ent:GetClass() == "mugger" then
					if ent:GetNWString("mugger_name", ""):lower() == name:lower() then
						mugger.log(ply:Nick().." has removed mugger: "..name)
						ent:Remove()
					end
				end
			end
		end
	end
end)

--// Mugger's use panel has been closed
net.Receive( "mug_panel", function( len, ply )
	if IsValid(ply.usingMugger) then
		local ent = ply.usingMugger
		
		mugger.log( ply:Nick().." is no longer interacting with mugger: "..ent:GetNWString("mugger_name","") )
		
		ent.usingPlayer = nil
		ent.funder = nil
		ent.inUse = false
		ply.usingMugger = nil
	end
end)

--// Dispatch the mugger 
net.Receive( "mug_send", function( len, ply )
	local id = net.ReadString()
	
	-- Make sure this player is actually interacting with an npc
	if IsValid(ply.usingMugger) then
		local ent = ply.usingMugger
		
		if ent.usingPlayer != ply then
			mugger.log("NPC's interacting player differs from requesting player: "..ply:Nick())
			return
		end
		
		ent.usingPlayer = nil
		ent.inUse = false
		ply.usingMugger = nil
		
		ent.funder = ply
		
		local target
		
		-- Find the player
		for _, v in pairs( player.GetAll() ) do
			if v:SteamID() == id then
				target = v
				break
			end
			
			-- Bot support sorta
			if v:SteamID() == "BOT" and id == "NULL" then 
				target = v
			end
		end
		
		if target:InVehicle() and mugger.config.canTargetVehicles == false then
			mugger.log("Attempt to target player in vehicle from "..ply:Nick())
			ent.funder = nil
			return
		end
		
		-- Check to make sure that they can target that player's job
		local canUse = true
		if #mugger.config.unTargetableJobs > 0 then
			for _, job in pairs( mugger.config.unTargetableJobs ) do
				if job:lower() == team.GetName( target:Team() ):lower() then
					canUse = false
					break
				end
			end
			
			if not canUse then
				mugger.log("Invalid job for the mugger to target from "..ply:Nick())
				ent.funder = nil
				return
			end
		end
		
		-- Check to make sure that they can target that player's usergroup
		canUse = true
		if #mugger.config.unTargetableUsergroups > 0 then
			for _, group in pairs( mugger.config.unTargetableUsergroups ) do
				if group:lower() == target:GetUserGroup():lower() then
					canUse = false
					break
				end
			end
			
			if not canUse then
				mugger.log("Invalid usergroup for the mugger to target from "..ply:Nick())
				ent.funder = nil
				return
			end
		end
		
		-- Double check what we verified on the client for security
		local dist = ent:GetRangeTo( target:GetPos() )
		if dist > mugger.config.maxRange or not target:Alive() or target:isArrested() or target == ply or ply:getDarkRPVar("money") < mugger.config.hireCost then
			mugger.log("Incorrect mugger client-server checks from "..ply:Nick(), dist > mugger.config.maxRange, not target:Alive(), target:isArrested(), target == ply)
			ent.funder = nil
			return
		end
		
		-- Send him on his merry way
		if target then
			mugger.log(string.format("%s hired mugger (%s) to kill (%s) \n", ply:Nick(), ent:GetNWString("mugger_name", ""), target:Nick()))
			ply:addMoney(-mugger.config.hireCost)
			ent:setTarget( target )
		end
	end
end)

net.Receive("mug_free", function( len, ply )
	if mugger.isAdmin( ply ) then
		local name = net.ReadString()
		
		if name == "nil" then return end
		
		for _, ent in pairs( mugger.getAll() ) do
			if ent:GetNWString("mugger_name", ""):lower() == name:lower() then
				ent.inUse = false
				ent:setTarget( nil )
				ent.funder = nil
				ent.cooldown = false
				ent.usingPlayer = false
			end
		end
	end
end)

net.Receive("mug_getlog", function( len, ply )
	mugger.sendLogs( ply )
end)

--// Makes sure the mugger is up to date
function mugger.checkUpdate()
	http.Fetch( "http://exho1.github.io/mugger/index.html", 
	function ( body, len, headers, code )
		-- Gotta find the json 
		local startPos = string.find( body, "{")
		local endPos = string.find( body, "}")
		
		if startPos and endPos then
			-- Json -> Table
			local json = string.sub( body, startPos, endPos )
			local tbl = util.JSONToTable( json )
			
			local webVersion = tbl[1]
			local localVersion = string.gsub( mugger.version, "/", "" )
			webVersion = string.gsub( webVersion, "/", "" )
			
			localVersion = tonumber(localVersion)
			webVersion = tonumber(webVersion)
			
			-- Check to make sure they are running the latest version for its benefits :D
			if localVersion and webVersion then
				if webVersion > localVersion then
					mugger.chatBroadcast("Your DarkRP mugger is out of date! Download the latest version from ScriptFodder")
					mugger.log("Mugger is out of date. Local: "..mugger.version..". Web: "..webVersion)
				end
			end
		end
	end,
	function (error)
		mugger.log("Could not connect to update url")
	end)
end