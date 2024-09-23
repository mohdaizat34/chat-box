--// Clientside mugger handling

surface.CreateFont( "mugger_26", {
	font = "Arial",
	size = 26,
	weight = 500,
	antialias = true,
} )

surface.CreateFont( "mugger_20", {
	font = "Arial",
	size = 20,
	weight = 500,
	antialias = true,
} )

surface.CreateFont( "mugger_16", {
	font = "Arial",
	size = 16,
	weight = 500,
	antialias = true,
} )

--// Makes the player look through the view of their ragdoll when they have just been mugged
hook.Add("CalcView", "mugged_view", function( ply, pos, ang )
	if LocalPlayer():GetNWBool( "mug_ragdoll", false ) then
		local view = {}
		
		local rag = LocalPlayer():GetRagdollEntity()
		
		if IsValid( rag ) then
			local attachID = rag:LookupAttachment( "eyes" )
			if not attachID then return end
			
			local attachData = rag:GetAttachment( attachID )
			if not attachData then return end
			
			view.origin = attachData.Pos
			view.angles = attachData.Ang
			
			return view
		end
	end
end)

--// Draws the mugger's information as target id
hook.Add("HUDPaint", "mugger_id", function()
	local tr = util.TraceLine({
		start = EyePos(),
		endpos = EyePos() + EyeAngles():Forward() * mugger.config.targetIDRange,
		filter = function( ent ) if ( ent:GetClass() == "mugger" ) then return true end end
	})
	
	if IsValid(tr.Entity) then
		if tr.Entity:GetClass() == "mugger" then
			local suffix = ""
			if mugger.config.targetIDSuffix == true then
				suffix = " the Mugger"
			end
		
			local name = tr.Entity:GetNWString("mugger_name", "Garry")
			draw.DrawText( name..suffix, "TargetID", ScrW() / 2 , ScrH() / 1.9, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
			
			if mugger.config.targetIDHealth then
				draw.DrawText( tr.Entity:Health(), "TargetID", ScrW() / 2 , ScrH() / 1.83, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
			end
			
			if mugger.config.debug then
				draw.DrawText( tr.Entity:GetNWString("mugger_status", "N/A"), "TargetID", ScrW() / 2 , ScrH() / 1.77, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
			end
		end
	end
end)

--// Opens the mugger hire panel
function mugger.openPanel( ent )
	if IsValid(mugger.frame) then return end
		
	mugger.frame = vgui.Create("DFrame")
	mugger.frame:SetSize( 400, 600 )
	mugger.frame:Center()
	mugger.frame:SetTitle( "" )
	mugger.frame:MakePopup()
	mugger.frame:SetDraggable( false )
	mugger.frame:ShowCloseButton( false )
	mugger.frame.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 30, 30, 30, 255 ) )
		draw.RoundedBox( 0, 0, 0, w, 28, Color(150, 40, 30) )
	end
	mugger.frame.Think = function( self )
		if not LocalPlayer():Alive() and LocalPlayer():isArrested() then
			net.Start("mug_panel")
			net.SendToServer()
			
			if IsValid(mugger.frame) then
				mugger.frame:Close()
			else
				local pnl = self:GetParent()
				pnl:Close()
			end
		end
	end
	
	local btnClose = vgui.Create("DButton", mugger.frame)
	btnClose:SetSize( 40, 18 )
	btnClose:SetPos( mugger.frame:GetWide() - btnClose:GetWide() - 5, 5 )
	btnClose:SetText( "X" )
	btnClose:SetTextColor( color_white )
	btnClose.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color(192, 57, 43) )
	end
	btnClose.DoClick = function( self )
		net.Start("mug_panel")
		net.SendToServer()
		
		if IsValid(mugger.frame) then
			mugger.frame:Close()
		else
			local pnl = self:GetParent()
			pnl:Close()
		end
	end
	
	local lblTitle = vgui.Create("DLabel", mugger.frame)
	lblTitle:SetText( "Mugger for hire" )
	lblTitle:SetFont( "mugger_16" )
	lblTitle:SizeToContents()
	lblTitle:SetPos( 5, 5 )
	
	local icnModel = vgui.Create( "SpawnIcon", mugger.frame )
	icnModel:SetModel( ent:GetModel() )
	icnModel:SetPos( 5, 35 )
	icnModel:SetSize( 100, 100 )
	icnModel:SetDisabled(true)
	icnModel.PaintOver = function( self ) self:SetTooltip() end
	icnModel:SetTooltip()
	
	local x, y = icnModel:GetPos()

	local lblMugger = vgui.Create("DLabel", mugger.frame)
	lblMugger:SetText( "Mugger" )
	lblMugger:SetFont( "mugger_26" )
	lblMugger:SizeToContents()
	lblMugger:SetPos( x + icnModel:GetWide() + 10, y )
	
	local lblName = vgui.Create("DLabel", mugger.frame)
	lblName:SetText( ent:GetNWString("mugger_name", "Garry") )
	lblName:SetFont( "mugger_20" )
	lblName:SizeToContents()
	lblName:SetPos( x + icnModel:GetWide() + 10, y + lblMugger:GetTall())
	
	local lblPrice = vgui.Create("DLabel", mugger.frame)
	lblPrice:SetText( "Price: $"..mugger.config.hireCost )
	lblPrice:SetFont( "mugger_26" )
	lblPrice:SizeToContents()
	lblPrice:SetPos( x + icnModel:GetWide() + 10, y + icnModel:GetTall() - lblPrice:GetTall() )
	lblPrice.Think = function( self )
		if LocalPlayer():getDarkRPVar("money") > mugger.config.hireCost then
			self:SetTextColor( Color(30, 200, 30 ) )
		else
			self:SetTextColor( Color(200, 30, 30 ) )
		end
	end
	
	scrPanel = vgui.Create("DScrollPanel", mugger.frame )
	scrPanel:SetSize( mugger.frame:GetWide() - 10, mugger.frame:GetTall() - 240 )
	scrPanel:SetPos( 5, 150 )
	scrPanel.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 20, 20, 20, 200 ) )
	end
	
	-- Draw a nicer scrollbar
	local bar = scrPanel:GetVBar()
	bar.Paint = function() end
	
	bar.btnUp.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color(150, 40, 30) )
		draw.RoundedBox( 0, 3, 3, w - 6, h- 6, Color(231, 76, 60) )
	end
	
	bar.btnDown.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color(150, 40, 30) )
		draw.RoundedBox( 0, 3, 3, w - 6, h- 6, Color(231, 76, 60) )
	end
	
	bar.btnGrip.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color(150, 40, 30) )
		draw.RoundedBox( 0, 3, 3, w - 6, h- 6, Color(231, 76, 60) )
	end
	
	lytPlayers = vgui.Create( "DIconLayout", scrPanel)
	lytPlayers:SetSize( scrPanel:GetWide() - 10, scrPanel:GetTall() - 10 )
	lytPlayers:SetPos( 5, 5 )
	lytPlayers:SetSpaceY( 0 )
	
	local target = nil
	
	-- Add player panels
	for _, ply in pairs( player.GetAll() ) do
		if ply == LocalPlayer() then continue end
		
		local col = GAMEMODE:GetTeamColor( ply )
		
		local btnPlayer = lytPlayers:Add("DButton")
		btnPlayer:SetSize( lytPlayers:GetWide(), 32 )
		btnPlayer:SetText( "" )
		btnPlayer.Paint = function( self, w, h )
			local mX, mY = self:ScreenToLocal( gui.MousePos() )
			if mX > 0 and mX < w and mY > 0 and mY < h then
				draw.RoundedBox( 0, 0, 0, w, h, Color( col.r + 60, col.g + 60, col.b + 60, 200 ) )
			else
				draw.RoundedBox( 0, 0, 0, w, h, Color( col.r, col.g, col.b, 100 ) )
			end	
			
			if target == ply then
				draw.RoundedBox( 0, 0, 0, w, h, Color( col.r + 80, col.g + 80, col.b + 80, 200 ) )
			end
		end
		btnPlayer.DoClick = function( self )
			-- A few checks
			if ply:Alive() and not ply:isArrested() and ply != LocalPlayer() then
				surface.PlaySound( "buttons/button9.wav" )

				target = ply
			else
				surface.PlaySound( "buttons/button10.wav" )
				
				notification.AddLegacy( "You cannot mug this player!", NOTIFY_GENERIC, 3 )
			end
		end
		
		local avaImage = vgui.Create( "AvatarImage", btnPlayer )
		avaImage:SetSize( 32, 32 )
		avaImage:SetPos( 0, 0 )
		avaImage:SetPlayer( ply, 32 )
		
		local lblName = vgui.Create("DLabel", btnPlayer)
		lblName:SetText( ply:Nick() )
		lblName:SetFont( "mugger_20" )
		lblName:SetTextColor( color_white )
		lblName:SizeToContents()
		local w, h = lblName:GetSize()
		lblName:SetSize( btnPlayer:GetWide()/2 - 30, h )
		lblName:SetPos( avaImage:GetWide() + 5, lblName:GetTall()/2 - 2)

		local lblJob = vgui.Create("DLabel", btnPlayer)
		lblJob:SetText( team.GetName(ply:Team()) )
		lblJob:SetFont( "mugger_20" )
		lblJob:SetTextColor( color_white )
		lblJob:SizeToContents()
		local w, h = lblJob:GetSize()
		lblJob:SetSize( btnPlayer:GetWide()/2 - 30, h )
		lblJob:SetPos( btnPlayer:GetWide() - lblJob:GetWide(), lblJob:GetTall()/2 - 2)
	end

	local btnPay = vgui.Create( "DButton", mugger.frame )
	btnPay:SetSize( mugger.frame:GetWide()/2 - 25, 60 )
	btnPay:SetPos( 15, mugger.frame:GetTall() - btnPay:GetTall() - 15 )
	btnPay:SetText( "Pay" )
	btnPay:SetTextColor( color_white )
	btnPay:SetFont( "mugger_20" )
	btnPay.Paint = function( self, w, h )
		local col = Color( 39, 174, 96 )
		
		local mX, mY = self:ScreenToLocal( gui.MousePos() )
		if mX > 0 and mX < w and mY > 0 and mY < h then
			draw.RoundedBox( 0, 0, 0, w, h, Color( col.r + 20, col.g + 20, col.b + 20, 200 ) )
		else
			draw.RoundedBox( 0, 0, 0, w, h, Color( col.r, col.g, col.b, 100 ) )
		end	
	end
	btnPay.DoClick = function( self )
		if not target then return end
		
		-- Clientside money check
		if LocalPlayer():getDarkRPVar("money") < mugger.config.hireCost then
			surface.PlaySound( "buttons/button10.wav" )
			notification.AddLegacy( "You do not have enough money to hire the mugger!", NOTIFY_GENERIC, 3 )
			mugger.frame:Close()
			return
		end
		
		if target:InVehicle() and mugger.config.canTargetVehicles == false then
			surface.PlaySound( "buttons/button10.wav" )
			notification.AddLegacy( "That player is in a vehicle!", NOTIFY_GENERIC, 3 )
			return
		end
		
		-- Check distance
		if ent:GetPos():Distance( target:GetPos() ) > mugger.config.maxRange then
			surface.PlaySound( "buttons/button10.wav" )
			
			notification.AddLegacy( "That player is out of range!", NOTIFY_GENERIC, 3 )
			
			local p1 = ent:GetPos()
			local p2 = target:GetPos()
			print( "Target out of range", p1.x - p2.x, p1.y - p2.y, p1.z - p2.z )
			
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
				surface.PlaySound( "buttons/button10.wav" )
				notification.AddLegacy( "You cannot mug this player's job!", NOTIFY_GENERIC, 3 )
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
				surface.PlaySound( "buttons/button10.wav" )
				notification.AddLegacy( "You cannot mug this player's usergroup!", NOTIFY_GENERIC, 3 )
				return
			end
		end
		
		-- Make sure they are a valid player
		if IsValid( target ) then
			surface.PlaySound( "buttons/button9.wav" )
			
			net.Start("mug_send")
				net.WriteString( target:SteamID() )
			net.SendToServer()
			
			notification.AddLegacy( "Sent mugger to go mug "..target:Nick().."!", NOTIFY_GENERIC, 3 )
			
			mugger.frame:Close()
		else
			surface.PlaySound( "buttons/button10.wav" )
			notification.AddLegacy( "You need to select a player to be mugged!", NOTIFY_GENERIC, 3 )
		end
	end
	
	local btnCancel = vgui.Create( "DButton", mugger.frame )
	btnCancel:SetSize( mugger.frame:GetWide()/2 - 25, 60 )
	btnCancel:SetPos( mugger.frame:GetWide() - btnCancel:GetWide() - 15, mugger.frame:GetTall() - btnCancel:GetTall() - 15 )
	btnCancel:SetText( "Cancel" )
	btnCancel:SetTextColor( color_white )
	btnCancel:SetFont( "mugger_20" )
	btnCancel.Paint = function( self, w, h )
		local col = Color(200, 40, 30)
		
		local mX, mY = self:ScreenToLocal( gui.MousePos() )
		if mX > 0 and mX < w and mY > 0 and mY < h then
			draw.RoundedBox( 0, 0, 0, w, h, Color( col.r + 20, col.g + 20, col.b + 20, 200 ) )
		else
			draw.RoundedBox( 0, 0, 0, w, h, Color( col.r, col.g, col.b, 100 ) )
		end	
	end
	btnCancel.DoClick = function( self )
		surface.PlaySound( "buttons/button9.wav" )
		
		net.Start("mug_panel")
		net.SendToServer()
		
		mugger.frame:Close()
	end
end

--// Adds a screen notification from the server
net.Receive( "mug_notify", function( len, ply )
	local text = net.ReadString()
	notification.AddLegacy( text, NOTIFY_GENERIC, 3 )
end)

net.Receive("mug_chat", function( len, ply )
	local text = net.ReadString()
	chat.AddText(Color(150, 40, 30), "[Mugger]: ", color_white, text)
end)

--// Opens the clientside mugger panel
net.Receive( "mug_panel", function( len, ply )
	--local name = net.ReadString()
	local pos = net.ReadVector()
	
	local ent
	local possible = ents.FindInSphere( pos, 50 )
	
	for k, v in pairs( possible ) do
		if v:GetClass() == "mugger" then
			ent = v
		end
	end
	
	-- Couldn't find that mugger... Tell the server we failed to get him
	if not ent then
		net.Start("mug_panel")
		net.SendToServer()
	end
	
	if IsValid( ent ) then
		mugger.openPanel( ent )
	else
		notification.AddLegacy( "Invalid mugger to interact with!", NOTIFY_GENERIC, 3 )
	end
end)

net.Receive("mug_getlog", function( len, ply )
	local data = net.ReadTable()
	
	local frame = vgui.Create("DFrame")
	frame:SetSize( 500, 300 )
	frame:Center()
	frame:MakePopup()
	frame:SetTitle("Mugger - Log")
	
	local rich = vgui.Create("RichText", frame )
	rich:SetSize( frame:GetWide() - 10, frame:GetTall() - 35 )
	rich:SetPos( 5, 30 )
	rich.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, color_white ) 
	end
	
	for _, line in pairs( data ) do
		rich:InsertColorChange( 60, 60, 60, 255 )
		rich:AppendText( line.."\n" )
	end
end)

--// Returns the player's position as a Lua table entry
concommand.Add("mypos", function()
	local pos = LocalPlayer():GetPos()
	
	print(string.format('["%s"] = Vector( %s, %s, %s ),',
	game.GetMap(),
	pos.x,
	pos.y,
	pos.z
	))
end)

local function isAdmin()
	local canUse = false
	if #mugger.config.adminUsergroups > 0 then
		for _, job in pairs( mugger.config.adminUsergroups ) do
			if job:lower() == LocalPlayer():GetUserGroup():lower() then
				canUse = true
				break
			end
		end
	end
	
	return canUse
end

local function canViewLogs()
	local canUse = false
	if #mugger.config.canViewLogUsergroups > 0 then
		for _, job in pairs( mugger.config.canViewLogUsergroups ) do
			if job:lower() == LocalPlayer():GetUserGroup():lower() then
				canUse = true
				break
			end
		end
	else
		return isAdmin() -- Default to admin usergroups
	end
	
	return canUse
end

--// Forces a mugger to spawn
concommand.Add("mug_spawn", function()
	if isAdmin() then
		net.Start("mug_spawn")
		net.SendToServer()
	else
		print("You do not have permission to do this!")
	end
end)

--// Removes a mugger by their name
concommand.Add("mug_remove", function( ply, cmd, args )
	if isAdmin() then
		local name = args[1] 
		
		if not name then
			local tr = ply:GetEyeTrace()
		
			local ent = tr.Entity
			if IsValid( ent ) then
				name = ent:GetNWString("mugger_name", "nil")
			else
				print("Not looking at a valid mugger")
			end
		end
	
		net.Start("mug_spawn")
			net.WriteString( name )
		net.SendToServer()
	else
		print("You do not have permission to do this!")
	end
end)

--// Removes a mugger by their name
concommand.Add("mug_getlogs", function( ply, cmd, args )
	if canViewLogs() then
		net.Start("mug_getlog") 
		net.SendToServer()
	else
		print("You do not have permission to do this!")
	end
end)

--// Clears the values that might cause a mugger to be busy
concommand.Add("mug_free", function( ply, cmd, args )
	if isAdmin() then
		local name = args[1] 
		
		if not name then
			local tr = ply:GetEyeTrace()
		
			local ent = tr.Entity
			if IsValid( ent ) then
				name = ent:GetNWString("mugger_name", "nil")
			else
				print("Not looking at a valid mugger")
			end
		end
		
		if name then
			net.Start("mug_free") 
				net.WriteString( name )
			net.SendToServer()
		end
	else
		print("You do not have permission to do this!")
	end
end)

concommand.Add("mug_version", function()
	-- 110426709
	print("This server is running Exho's GTA Mugger version: "..mugger.version)
end)