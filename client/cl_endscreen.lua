print("Hello cl_endscreen.lua")

local countdownTime = 180  -- 180 seconds countdown
local reconnectTimer = "ServerReconnectTimer"

-- Create a custom font
surface.CreateFont("ChatFont", {
    font = "Trebuchet24",  -- Change to your desired font
    size = 20,             -- Font size
    weight = 500,          -- Font weight
    antialias = true,      -- Anti-aliasing
    shadow = true,         -- Shadow for better readability
})

-- Function to show the end screen and chat UI
function ShowEndScreen()
    local screenW, screenH = ScrW(), ScrH()

    -- Create the main frame
    local frame = vgui.Create("DFrame")
    frame:SetTitle("Server Restart")
    frame:SetSize(screenW * 0.4, screenH * 0.8)  -- Adjust size as needed
    frame:Center()
    frame:MakePopup()
    frame:SetDraggable(false)
    frame:ShowCloseButton(true)
    frame.Paint = function( self, w, h ) -- 'function Frame:Paint( w, h )' works too
        draw.RoundedBox( 0, 0, 0, w, h, Color( 255,255,255,0) ) -- Draw a black box instead of the frame
    end
    
    function frame:Init() 
        self.startTime = SysTime() 
    end    
    function frame:Paint() 
        Derma_DrawBackgroundBlur( self, self.startTime ) 
    end


    -- Countdown label
    local countdownLabel = vgui.Create("DLabel", frame)
    countdownLabel:SetText("Reconnecting in " .. countdownTime .. " seconds")
    countdownLabel:SetFont("DermaLarge")
    countdownLabel:SetTextColor(Color(255, 255, 255))  -- Black text
    countdownLabel:SetContentAlignment(5)  -- Center alignment
    countdownLabel:Dock(TOP)
    countdownLabel:SetTall(50)
    countdownLabel:DockMargin(0, 20, 0, 10)

    -- Timer to update countdown
    timer.Create(reconnectTimer, 1, countdownTime, function()
        countdownTime = countdownTime - 1
        countdownLabel:SetText("Reconnecting in " .. countdownTime .. " seconds")

        if countdownTime <= 0 then
            RunConsoleCommand("retry")  -- Auto reconnect
        end
    end)

    -- Chat display panel
    local chatPanel = vgui.Create("DScrollPanel", frame)
    chatPanel:Dock(FILL)
    chatPanel:DockPadding(50,0,50,0)
    chatPanel:DockMargin(10, 10, 10, 50)  -- Margin to avoid overlap with chat box
    chatPanel.Paint = function( self, w, h ) -- 'function Frame:Paint( w, h )' works too
        draw.RoundedBox( 0, 0, 0, w, h, Color( 58,58,58,179) ) -- Draw a black box instead of the frame
    end

    -- Chat display panel
    local DisconnectPanel = vgui.Create("DPanel", frame)
    DisconnectPanel:Dock(BOTTOM)
    DisconnectPanel:SetSize(0,50)
    DisconnectPanel:DockMargin(0, 20, 0, 0)  -- Margin to avoid overlap with chat box
    DisconnectPanel.Paint = function( self, w, h ) -- 'function Frame:Paint( w, h )' works too
        draw.RoundedBox( 0, 0, 0, w, h, Color( 0,0,0,0) ) -- Draw a black box instead of the frame
    end

    -- Create a list of chat labels
    local chatLines = {}

    -- Function to add a new chat line
    local function AddChatLine(text)
        local chatLine = vgui.Create("DLabel", chatPanel)
        chatLine:SetText(text)
        chatLine:SetFont("Trebuchet24")
        chatLine:SetTextColor(Color(255, 255, 255))  -- White text
        chatLine:Dock(TOP)
        chatLine:SetTall(30)
        chatLine:DockMargin(5, 5, 5, 0)
        table.insert(chatLines, chatLine)
        chatPanel:InvalidateLayout(true)  -- Force re-layout to adjust size
        chatPanel:PerformLayout()
    end

    -- Chat box
    local chatBox = vgui.Create("DTextEntry", frame)
    chatBox:Dock(BOTTOM)
    chatBox:SetTall(40)
    chatBox:SetPlaceholderText( "Type here to chat..." )
    chatBox:SetTextColor(Color(0, 0, 0))  -- Black text
    chatBox:SetHighlightColor(Color(0, 0, 0, 76))  -- Light gray highlight
    chatBox.OnGetFocus = function(self)
        self:SetValue("")
    end
    -- Handle chat input
    chatBox.OnEnter = function(self)
        local text = LocalPlayer():Nick()..": "..self:GetValue()
        if text ~= "" then
            net.Start("sendMessage")
            net.WriteString(text)
            net.SendToServer()
        end
    end

    net.Receive ("receiveMessage" , function(bits , ply )
        local receiveMessage = net.ReadString() 
        print(receiveMessage)
        AddChatLine(receiveMessage)  -- Add message to chat
    end) 

    -- Disconnect button
    local disconnectButton = vgui.Create("DButton", DisconnectPanel)
    disconnectButton:SetText("Cancel Reconnect")
    disconnectButton:Dock(BOTTOM)
    disconnectButton:SetTextColor(Color(245, 245, 245))  -- White text
    disconnectButton:SetFont("DermaDefaultBold")
    disconnectButton.Paint = function( self, w, h ) -- 'function Frame:Paint( w, h )' works too
        draw.RoundedBox( 0, 0, 0, w, h, Color( 255,0,0,103) ) -- Draw a black box instead of the frame
    end

    disconnectButton.DoClick = function()
        timer.Remove(reconnectTimer)
        frame:Close()
        RunConsoleCommand("disconnect")  -- Manual disconnect
    end
end

hook.Add("PlayerButtonDown", "test", function(ply, button)
    if button == KEY_M then 
        ShowEndScreen()
    end 
end)

--Show the end screen when the shutdown begins
hook.Add("ShutDown", "ServerShuttingDown", function()
    ShowEndScreen()
    Entity( 1 ):PrintMessage( HUD_PRINTTALK, "Server Is Restarting." )
end)
