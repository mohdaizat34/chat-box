-- Custom options 
local keyBind = KEY_M -- Default is key M, you can change according to the list below
local countdownTime = 60  --  You can change the countdown timer here 
local imagePath = "" -- here you can paste your desired image path make sure the path is in garrysmod/materials folder

--Here are the list of keybinds you can change 
-- KEY_FIRST	0	
-- KEY_NONE	0	
-- KEY_0	1	Normal number 0 key
-- KEY_1	2	Normal number 1 key
-- KEY_2	3	Normal number 2 key
-- KEY_3	4	Normal number 3 key
-- KEY_4	5	Normal number 4 key
-- KEY_5	6	Normal number 5 key
-- KEY_6	7	Normal number 6 key
-- KEY_7	8	Normal number 7 key
-- KEY_8	9	Normal number 8 key
-- KEY_9	10	Normal number 9 key
-- KEY_A	11	
-- KEY_B	12	
-- KEY_C	13	
-- KEY_D	14	
-- KEY_E	15	
-- KEY_F	16	
-- KEY_G	17	
-- KEY_H	18	
-- KEY_I	19	
-- KEY_J	20	
-- KEY_K	21	
-- KEY_L	22	
-- KEY_M	23	
-- KEY_N	24	
-- KEY_O	25	
-- KEY_P	26	
-- KEY_Q	27	
-- KEY_R	28	
-- KEY_S	29	
-- KEY_T	30	
-- KEY_U	31	
-- KEY_V	32	
-- KEY_W	33	
-- KEY_X	34	
-- KEY_Y	35	
-- KEY_Z	36	
-- KEY_PAD_0	37	Keypad number 0 key
-- KEY_PAD_1	38	Keypad number 1 key
-- KEY_PAD_2	39	Keypad number 2 key
-- KEY_PAD_3	40	Keypad number 3 key
-- KEY_PAD_4	41	Keypad number 4 key
-- KEY_PAD_5	42	Keypad number 5 key
-- KEY_PAD_6	43	Keypad number 6 key
-- KEY_PAD_7	44	Keypad number 7 key
-- KEY_PAD_8	45	Keypad number 8 key
-- KEY_PAD_9	46	Keypad number 9 key
-- KEY_PAD_DIVIDE	47	Keypad division/slash key (/)
-- KEY_PAD_MULTIPLY	48	Keypad asterisk key (*)
-- KEY_PAD_MINUS	49	Keypad minus key
-- KEY_PAD_PLUS	50	Keypad plus key
-- KEY_PAD_ENTER	51	Keypad enter key
-- KEY_PAD_DECIMAL	52	Keypad dot key (.)
-- KEY_LBRACKET	53	
-- KEY_RBRACKET	54	
-- KEY_SEMICOLON	55	
-- KEY_APOSTROPHE	56	
-- KEY_BACKQUOTE	57	
-- KEY_COMMA	58	
-- KEY_PERIOD	59	
-- KEY_SLASH	60	
-- KEY_BACKSLASH	61	
-- KEY_MINUS	62	
-- KEY_EQUAL	63	
-- KEY_ENTER	64	
-- KEY_SPACE	65	
-- KEY_BACKSPACE	66	
-- KEY_TAB	67	
-- KEY_CAPSLOCK	68	
-- KEY_NUMLOCK	69	
-- KEY_ESCAPE	70	
-- KEY_SCROLLLOCK	71	
-- KEY_INSERT	72	
-- KEY_DELETE	73	
-- KEY_HOME	74	
-- KEY_END	75	
-- KEY_PAGEUP	76	
-- KEY_PAGEDOWN	77	
-- KEY_BREAK	78	
-- KEY_LSHIFT	79	The left Shift key, has been seen to be triggered by Right Shift in PANEL:OnKeyCodePressed
-- KEY_RSHIFT	80	
-- KEY_LALT	81	
-- KEY_RALT	82	
-- KEY_LCONTROL	83	
-- KEY_RCONTROL	84	
-- KEY_LWIN	85	The left Windows key or the Command key on Mac OSX
-- KEY_RWIN	86	The right Windows key or the Command key on Mac OSX
-- KEY_APP	87	
-- KEY_UP	88	
-- KEY_LEFT	89	
-- KEY_DOWN	90	
-- KEY_RIGHT	91	
-- KEY_F1	92	
-- KEY_F2	93	
-- KEY_F3	94	
-- KEY_F4	95	
-- KEY_F5	96	
-- KEY_F6	97	
-- KEY_F7	98	
-- KEY_F8	99	
-- KEY_F9	100	
-- KEY_F10	101	
-- KEY_F11	102	
-- KEY_F12	103	
-- KEY_CAPSLOCKTOGGLE	104	
-- KEY_NUMLOCKTOGGLE
------------------------------------------------------------------------------------------------------------------------------------------
-- It is recommended to not change anything below ! ----------------------------------------------------------------------------------------




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
    frame:SetSize(screenW , screenH)  -- Adjust size as needed
    frame:Center()
    frame:MakePopup()
    frame:SetDraggable(true)
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

    function frame:OnClose() 
        timer.Stop(reconnectTimer)
    end 

    
    -- Countdown label
    local countdownLabel = vgui.Create("DLabel", frame)
    countdownLabel:SetText("Reconnecting in " .. countdownTime .. " seconds")
    countdownLabel:SetFont("DermaLarge")
    countdownLabel:SetTextColor(Color(255, 230, 0))  -- Black text
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


    local LeftPanel = vgui.Create( "DPanel", frame )   
	LeftPanel:Dock(LEFT)
	LeftPanel:DockPadding(0,0,0,0)
	LeftPanel:SetSize(400,200) 
	LeftPanel.Paint = function( self, w, h )  
	draw.RoundedBox( 0, 0, 0, w, h, Color( 255,0,0,0) ) -- Draw a black box instead of the frame
	end

	local RightPanel = vgui.Create( "DPanel", frame )   
	RightPanel:Dock(RIGHT)
	RightPanel:DockPadding(0,0,0,0)
	RightPanel:SetSize(400,200) 
	RightPanel.Paint = function( self, w, h )  
	draw.RoundedBox( 0, 0, 0, w, h, Color( 255,0,0,0) ) -- Draw a black box instead of the frame
	end

    -- Chat display panel
    local chatPanel = vgui.Create("DScrollPanel", frame)
    chatPanel:Dock(FILL)
    chatPanel:DockPadding(100,0,100,0)
    chatPanel:DockMargin(10, 10, 10, 50)  -- Margin to avoid overlap with chat box
    chatPanel.Paint = function( self, w, h ) -- 'function Frame:Paint( w, h )' works too
        draw.RoundedBox( 0, 0, 0, w, h, Color( 58,58,58,179) ) -- Draw a black box instead of the frame
    end

    -- Chat display panel
    local DisconnectPanel = vgui.Create("DPanel", frame)
    DisconnectPanel:Dock(BOTTOM)
    DisconnectPanel:SetSize(0,50)
    DisconnectPanel:DockMargin(0, 50, 0, 0)  -- Margin to avoid overlap with chat box
    DisconnectPanel.Paint = function( self, w, h ) -- 'function Frame:Paint( w, h )' works too
        draw.RoundedBox( 0, 0, 0, w, h, Color( 0,0,0,0) ) -- Draw a black box instead of the frame
    end

    -- Create a list of chat labels
    local chatLines = {}

    -- Function to add a new chat line
    local function AddChatLine(text)
        local chatLine = vgui.Create("DLabel", chatPanel)
        chatLine:SetText(text)
        chatLine:SetFont("DermaLarge")
        chatLine:SetTextColor(Color(255, 255, 255))  -- White text
        chatLine:Dock(TOP)
        chatLine:SetWrap(true)
        chatLine:SetAutoStretchVertical(true)
        chatLine:SetTall(40)
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
    chatBox:SetFont("DermaLarge")
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
    disconnectButton:SetText("Disconnect")
    disconnectButton:Dock(BOTTOM)
    disconnectButton:SetSize(0,50)
    disconnectButton:SetTextColor(Color(245, 245, 245))  -- White text
    disconnectButton:SetFont("HudDefault")
    disconnectButton.Paint = function( self, w, h ) -- 'function Frame:Paint( w, h )' works too
        draw.RoundedBox( 0, 0, 0, w, h, Color( 255,0,0,103) ) -- Draw a black box instead of the frame
    end

    disconnectButton.DoClick = function()
        timer.Remove(reconnectTimer)
        frame:Close()
        RunConsoleCommand("disconnect")  -- Manual disconnect
    end
end




function OptionFrame()
    local frameOption = vgui.Create("DFrame")
    frameOption:SetTitle("Server Restart")
    frameOption:SetSize(500 , 500)  -- Adjust size as needed
    frameOption:Center()
    frameOption:MakePopup()
    frameOption:SetDraggable(true)
    frameOption:ShowCloseButton(true)
    frameOption.Paint = function( self, w, h ) -- 'function Frame:Paint( w, h )' works too
        draw.RoundedBox( 0, 0, 0, w, h, Color( 255,255,255,0) ) -- Draw a black box instead of the frame
    end
    
    function frameOption:Init() 
        self.startTime = SysTime() 
    end    
    function frameOption:Paint() 
        Derma_DrawBackgroundBlur( self, self.startTime ) 
    end

    local FillPanel = vgui.Create( "DPanel", frameOption )  
	FillPanel:Dock(FILL)
	FillPanel:DockPadding(0,200,0,200)
	FillPanel.Paint = function( self, w, h )  
	draw.RoundedBox( 0, 0, 0, w, h, Color( 0,0,0,0) ) -- Draw a black box instead of the frame
	end

    local LeftPanel = vgui.Create( "DPanel", frameOption )   
	LeftPanel:Dock(LEFT)
	LeftPanel:DockPadding(0,0,0,0)
	LeftPanel:SetSize(100,200) 
	LeftPanel.Paint = function( self, w, h )  
	draw.RoundedBox( 0, 0, 0, w, h, Color( 255,0,0,0) ) -- Draw a black box instead of the frame
	end

	local RightPanel = vgui.Create( "DPanel", frameOption )   
	RightPanel:Dock(RIGHT)
	RightPanel:DockPadding(0,0,0,0)
	RightPanel:SetSize(100,200) 
	RightPanel.Paint = function( self, w, h )  
	draw.RoundedBox( 0, 0, 0, w, h, Color( 255,0,0,0) ) -- Draw a black box instead of the frame
	end

    -- Disconnect button
    local restartButton = vgui.Create("DButton", FillPanel)
    restartButton:SetText("Restart Server")
    restartButton:Dock(FILL)
    restartButton:SetTextColor(Color(245, 245, 245))  -- White text
    restartButton:SetFont("DermaLarge")
    restartButton.Paint = function( self, w, h ) -- 'function Frame:Paint( w, h )' works too
        draw.RoundedBox( 0, 0, 0, w, h, Color( 255,123,0,187) ) -- Draw a black box instead of the frame
    end

    restartButton.DoClick = function()
        frameOption:Close() 
        net.Start("sendOpenChat")
        net.SendToServer()
        
        if LocalPlayer():IsSuperAdmin() then 
            if countdownTime == 0 then 
                LocalPlayer():ConCommand("_restart")
            end 
        end 
    end
end 

net.Receive ("receiveOpenChat" , function(bits , ply ) 
    ShowEndScreen()
end) 

hook.Add("PlayerButtonDown", "test", function(ply, button)
    if LocalPlayer():IsSuperAdmin() then 
        if button == keyBind then
            timer.Stop(reconnectTimer)
            OptionFrame()
        end 
    end 
end)
