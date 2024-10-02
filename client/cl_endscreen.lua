-- Custom options 
local keyBind = KEY_9 -- Default is key M, you can change according to the list below
local countdownTime = 60  --  You can change the countdown timer here 
local imagePath = "" -- here you can paste your desired image path make sure the path is in garrysmod/materials folder
local alphaValue = 255

-- I don't think you should mess with this -----------
local isOpen = false  


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


-- simple pop up 
local function SimplePopupFrame(text)
    -- Create the frame
    local PopUpFrame = vgui.Create("DFrame")
    PopUpFrame:SetTitle("Simple Popup")
    PopUpFrame:SetSize(300, 100)
    PopUpFrame:Center() -- Center the frame on the screen
    PopUpFrame:MakePopup() -- Make it interactive
    PopUpFrame:ShowCloseButton(false)
    PopUpFrame.Paint = function( self, w, h ) -- 'function Frame:Paint( w, h )' works too
        draw.RoundedBox( 0, 0, 0, w, h, Color( 0,0,0,138) ) -- Draw a black box instead of the frame
    end
    
    function PopUpFrame:Init() 
        self.startTime = SysTime() 
    end    
    function PopUpFrame:Paint() 
        Derma_DrawBackgroundBlur( self, self.startTime ) 
    end

    -- Create a label to display text
    local label = vgui.Create("DLabel", PopUpFrame)
    label:SetText(text)
    label:Dock(TOP) -- Dock the label to the top of the frame
    label:SetTextColor(Color(12,249,0))
    label:DockMargin(10, 10, 10, 10) -- Add some margin around the label
    label:SetContentAlignment(5) -- Center the text

    timer.Simple(2,function() 
        PopUpFrame:Close() 
    end)
end


-- Function to show the end screen and chat UI
function ShowEndScreen()
    local screenW, screenH = ScrW(), ScrH()

    -- Create the main frame
    local frame = vgui.Create("DFrame")
    frame:SetTitle("Server Restart")
    frame:SetSize(screenW , screenH)  -- Adjust size as needed
    frame:Center()
    frame:MakePopup()
    frame:SetDraggable(false)
    frame:ShowCloseButton(false)
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

    frame.Paint = function(self, w, h)
        if imagePath == "" then 
            draw.RoundedBox( 0, 0, 0, w, h, Color( 0,0,0,100) ) -- Draw a black box instead of the frame
        else 
            draw.RoundedBox( 0, 0, 0, w, h, Color( 0,0,0,100) ) -- Draw a black box instead of the frame
            surface.SetDrawColor(255, 255, 255, alphaValue)
            surface.SetMaterial(Material(imagePath)) -- Use the selected image
            surface.DrawTexturedRect(0, 0, w, h) -- Draw it across the frame
        end 
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
            --RunConsoleCommand("retry")  -- Auto reconnect
            net.Start("restartServer")
            net.SendToServer()
            
        --   timer.Simple(5,function()
        --         LocalPlayer():ConCommand("connect 45.61.170.70:27322")
        --     end)
        end
    end)


    local LeftPanel = vgui.Create( "DPanel", frame )   
	LeftPanel:Dock(LEFT)
	LeftPanel:DockPadding(0,0,0,0)
	LeftPanel:SetSize(400,200) 
	LeftPanel.Paint = function( self, w, h )  
	draw.RoundedBox( 0, 0, 0, w, h, Color( 255,0,0,0) ) -- Draw a black box instead of the frame
	end

-- 	local RightPanel = vgui.Create( "DPanel", frame )   
-- 	RightPanel:Dock(RIGHT)
-- 	RightPanel:DockPadding(0,0,0,0)
-- 	RightPanel:SetSize(400,200) 
-- 	RightPanel.Paint = function( self, w, h )  
-- 	draw.RoundedBox( 0, 0, 0, w, h, Color( 255,0,0,0) ) -- Draw a black box instead of the frame
-- 	end

    -- Chat display panel
    local chatPanel = vgui.Create("DScrollPanel", frame)
    chatPanel:Dock(FILL)
    chatPanel:DockPadding(100,0,100,0)
    chatPanel:DockMargin(10, 10, 10, 50)  -- Margin to avoid overlap with chat box
    chatPanel.Paint = function( self, w, h ) -- 'function Frame:Paint( w, h )' works too
        draw.RoundedBox( 0, 0, 0, w, h, Color( 58,58,58,210) ) -- Draw a black box instead of the frame
    end
    
   -- Create the Player List panel (right side)
    local playerListPanel = vgui.Create("DPanel", frame)
    playerListPanel:Dock(RIGHT)
    playerListPanel:SetSize(400, 0)
    playerListPanel:DockPadding(50,0,200,0)
    playerListPanel:DockMargin(0, 0, 0, 0) -- Margin to avoid overlap with chat box
    playerListPanel.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 0)) -- Transparent background
    end
    
    -- Function to update player list
    local function UpdatePlayerList(playerListPanel)
        playerListPanel:Clear() -- Clear the panel before updating
    
        -- Title label for the player list
        local title = vgui.Create("DLabel", playerListPanel)
        title:Dock(TOP)
        title:SetText("Remaining Players")
        title:SetFont("DermaDefaultBold")
        title:SetTextColor(Color(255, 188, 87)) -- Custom color for the title
        title:SetTall(40)
        title:DockMargin(5, 5, 5, 0)
    
        -- Loop through all players and display their info
        for _, ply in ipairs(player.GetAll()) do
            -- Create a panel for each player
            local plyPanel = vgui.Create("DPanel", playerListPanel)
            plyPanel:Dock(TOP)
            plyPanel:SetTall(40)
            plyPanel:DockMargin(5, 5, 5, 0)
            plyPanel.Paint = function(self, w, h)
                draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 200)) -- Dark background for each player
            end
    
            -- Player name label
            local plyNameLabel = vgui.Create("DLabel", plyPanel)
            plyNameLabel:SetText(ply:Nick()) -- Display player name
            plyNameLabel:SetFont("DermaDefaultBold")
            plyNameLabel:SetTextColor(Color(255, 255, 255)) -- White text
            plyNameLabel:Dock(TOP)
            plyNameLabel:SetWide(200)
    
            -- Player ping label
            local plyPingLabel = vgui.Create("DLabel", plyPanel)
            plyPingLabel:SetText(ply:Ping() .. "ms") -- Display player ping
            plyPingLabel:SetFont("DermaDefault")
            plyPingLabel:SetTextColor(Color(107, 255, 142)) -- Light gray text for ping
            plyPingLabel:Dock(TOP)
            plyPingLabel:SetWide(100)
        end
    end
    
    -- Timer to update the player list every 2 seconds
    timer.Create("UpdatePlayerList", 2, 0, function()
        if IsValid(playerListPanel) then
            UpdatePlayerList(playerListPanel)
        end
    end)
    
    -- Initial call to populate the player list
    UpdatePlayerList(playerListPanel)

    -- PlayerListPanel.Paint = function( self, w, h ) -- 'function Frame:Paint( w, h )' works too
    --     draw.RoundedBox( 0, 0, 0, w, h, Color( 0,0,0,0) ) -- Draw a black box instead of the frame
    -- end
    
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
        chatLine:DockMargin(5, 10, 5, 0)
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
    chatBox:SetHighlightColor(Color(0, 0, 0, 169))  -- Light gray highlight
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
        draw.RoundedBox( 0, 0, 0, w, h, Color( 255,0,0) ) -- Draw a black box instead of the frame
    end

    disconnectButton.DoClick = function()
        timer.Remove(reconnectTimer)
        frame:Close()
        RunConsoleCommand("disconnect")  -- Manual disconnect
    end
end


---------------------------------------------------------------------------------------
--set bg 
-- Create a custom file picker for materials (JPG, PNG, VTF)
local function OpenBackgroundChanger()
    -- Create the frame
    local framePicker = vgui.Create("DFrame")
    framePicker:SetSize(400, 300)
    framePicker:Center()
    framePicker:SetTitle("Background Changer")
    framePicker:MakePopup()

    -- List panel to hold file options
    local fileList = vgui.Create("DListView", framePicker)
    fileList:Dock(FILL)
    fileList:AddColumn("Available Images") 

    -- Search for image files in the "chatbox" folder within materials
    local jpgFiles, _ = file.Find("materials/chatbox/*.jpg", "GAME")
    local pngFiles, _ = file.Find("materials/chatbox/*.png", "GAME")
    local vtfFiles, _ = file.Find("materials/chatbox/*.vtf", "GAME")

    -- Add the found files to the list
    for _, fileName in ipairs(jpgFiles) do
        fileList:AddLine("materials/chatbox/" .. fileName)
    end
    for _, fileName in ipairs(pngFiles) do
        fileList:AddLine("materials/chatbox/" .. fileName)
    end
    for _, fileName in ipairs(vtfFiles) do
        fileList:AddLine("materials/chatbox/" .. fileName)
    end

    -- Capture file selection from the list
    fileList.OnRowSelected = function(_, _, row)
        imagePath = row:GetColumnText(1)
        print(imagePath)
    end


    local alphaSlider = vgui.Create("DNumSlider", framePicker)
    alphaSlider:Dock(BOTTOM)
    alphaSlider:SetText("Background Transparency")
    alphaSlider:SetMin(0) 
    alphaSlider:SetMax(255) 
    alphaSlider:SetValue(255) 
    alphaSlider:SetDecimals(0)
    
    alphaSlider.OnValueChanged = function(self, value)
        alphaValue = math.floor(value) 
    end
    
    local setButton = vgui.Create("DButton", framePicker)
    setButton:SetText("Set Background")
    setButton:Dock(BOTTOM)

    setButton.DoClick = function()
        if imagePath == "" then return end 
        framePicker:Close() 
        SimplePopupFrame("Successfully changed background!")
        timer.Simple(2,function() OptionFrame() end)
        
    end
end

-- set timer
local function OpenSetTimer()

    local frameTimer = vgui.Create("DFrame")
    frameTimer:SetSize(300, 100)
    frameTimer:Center()
    frameTimer:SetTitle("Enter a Number")
    frameTimer:MakePopup()
    frameTimer:ShowCloseButton(true)
    frameTimer.Paint = function( self, w, h ) 
        draw.RoundedBox( 0, 0, 0, w, h, Color( 255,255,255,0) ) 
    end
    
    function frameTimer:Init() 
        self.startTime = SysTime() 
    end    
    function frameTimer:Paint() 
        Derma_DrawBackgroundBlur( self, self.startTime ) 
    end

    function frameTimer:OnClose() 
        timer.Stop(reconnectTimer)
    end 
    
    local numberEntry = vgui.Create("DTextEntry", frameTimer)
    numberEntry:SetSize(200, 30)
    numberEntry:SetPos(50, 40)
    numberEntry:SetNumeric(true)  -- Only allow numbers
    numberEntry:SetText(countdownTime)

    numberEntry.AllowInput = function(self, char)
        if not tonumber(char) then
            return true 
        end
    end

    numberEntry.OnLoseFocus = function(self)
        countdownTime = tonumber(self:GetValue()) or 0 
    end

    local confirmButton = vgui.Create("DButton", frameTimer)
    confirmButton:SetSize(80, 30)
    confirmButton:SetPos(110, 75)
    confirmButton:SetText("Confirm")

    confirmButton.DoClick = function()
        frameTimer:ShowCloseButton(false)
        
        countdownTime = tonumber(numberEntry:GetValue()) or 0
        numberEntry:SetText("Number has been set!")
        numberEntry:SetTextColor(Color(5,138,0))
        confirmButton:SetVisible(false)
        timer.Simple(2,function() frameTimer:Close() OptionFrame() end)
    end
end




--Confirmation Pop up 
function ShowConfirmationPopup()
    -- Create the frame
    local frame = vgui.Create("DFrame")
    frame:SetTitle("Confirmation")
    frame:SetSize(300, 150)
    frame:Center()  -- Center the frame on the screen
    frame:MakePopup()  -- Make it interactive

    -- Create the label
    local label = vgui.Create("DLabel", frame)
    label:SetText("ARE YOU SURE?\n\n this will restart the server")
    label:SizeToContents()
    label:CenterHorizontal()  -- Center label horizontally
    label:SetPos(label:GetPos(), 40)  -- Set label position

    -- Create the Yes button
    local yesButton = vgui.Create("DButton", frame)
    yesButton:SetText("Yes")
    yesButton:SetSize(100, 30)
    yesButton:SetPos(30, 100)
    yesButton:SetTextColor(Color(255,255,255))
    yesButton.Paint = function( self, w, h )
        draw.RoundedBox( 0, 0, 0, w, h, Color( 45, 179, 0) ) 
    end
    yesButton.DoClick = function()
        frame:Close()  -- Close the popup
        
        net.Start("sendOpenChat")
        net.WriteInt(countdownTime,32)
        net.WriteString(imagePath)
        net.WriteInt(alphaValue,32)
        net.SendToServer()
        
    end

    -- Create the No button
    local noButton = vgui.Create("DButton", frame)
    noButton:SetText("No")
    noButton:SetSize(100, 30)
    noButton:SetPos(170, 100)
    noButton:SetTextColor(Color(255,255,255))
    noButton.Paint = function( self, w, h )
    draw.RoundedBox( 0, 0, 0, w, h, Color( 255,0,0) ) 
    end

    noButton.DoClick = function()
        frame:Close()  -- Close the popup
    end
end


-- Option Main Frames 
function OptionFrame()
    local frameOption = vgui.Create("DFrame")
    frameOption:SetTitle("Server Restart")
    frameOption:SetSize(500 , 500) 
    frameOption:Center()
    frameOption:MakePopup()
    frameOption:SetDraggable(true)
    frameOption:ShowCloseButton(true)
    frameOption.Paint = function( self, w, h )
        draw.RoundedBox( 0, 0, 0, w, h, Color( 255,255,255,0) ) 
    end
    
    function frameOption:Init() 
        self.startTime = SysTime() 
    end    
    function frameOption:Paint() 
        Derma_DrawBackgroundBlur( self, self.startTime ) 
    end
    
    function frameOption:OnClose() 
        isOpen = false 
    end

    local FillPanel = vgui.Create( "DPanel", frameOption )  
	FillPanel:Dock(FILL)
	FillPanel:DockPadding(0,0,0,0)
	FillPanel.Paint = function( self, w, h )  
	draw.RoundedBox( 0, 0, 0, w, h, Color( 0,0,0,0) )
	end

    local LeftPanel = vgui.Create( "DPanel", frameOption )   
	LeftPanel:Dock(LEFT)
	LeftPanel:DockPadding(0,0,0,0)
	LeftPanel:SetSize(100,200) 
	LeftPanel.Paint = function( self, w, h )  
	draw.RoundedBox( 0, 0, 0, w, h, Color( 255,0,0,0) ) 
	end

	local RightPanel = vgui.Create( "DPanel", frameOption )   
	RightPanel:Dock(RIGHT)
	RightPanel:DockPadding(0,0,0,0)
	RightPanel:SetSize(100,200) 
	RightPanel.Paint = function( self, w, h )  
	draw.RoundedBox( 0, 0, 0, w, h, Color( 255,0,0,0) ) 
	end

    local restartButton = vgui.Create("DButton", FillPanel)
    restartButton:SetText("Restart Server")
    restartButton:Dock(TOP)
    restartButton:SetSize(0,50)
    restartButton:DockMargin(0,100,0,0)
    restartButton:SetTextColor(Color(245, 245, 245)) 
    restartButton:SetFont("DermaLarge")
    restartButton.Paint = function( self, w, h ) 
        draw.RoundedBox( 0, 0, 0, w, h, Color( 255,123,0,187) ) 
    end

    restartButton.DoClick = function()
        frameOption:Close() 
        ShowConfirmationPopup()
        
        if LocalPlayer():IsSuperAdmin() then 
            if countdownTime == 0 then 
            
            end 
        end 
    end

     -- Disconnect button
     local settingButton = vgui.Create("DButton", FillPanel)
     settingButton:SetText("Set Image")
     settingButton:Dock(TOP)
     settingButton:SetSize(0,30)
     settingButton:DockMargin(0,30,0,0)
     settingButton:SetTextColor(Color(245, 245, 245))  -- White text
     settingButton:SetFont("HudDefault")
     settingButton.Paint = function( self, w, h ) -- 'function Frame:Paint( w, h )' works too
         draw.RoundedBox( 0, 0, 0, w, h, Color( 0,34,255,187) ) -- Draw a black box instead of the frame
     end

     settingButton.DoClick = function()
        frameOption:Close() 
        OpenBackgroundChanger()
    end

    -- Set timer
    local timerButton = vgui.Create("DButton", FillPanel)
    timerButton:SetText("Set Timer")
    timerButton:Dock(TOP)
    timerButton:SetSize(0,30)
    timerButton:DockMargin(0,30,0,0)
    timerButton:SetTextColor(Color(245, 245, 245))  -- White text
    timerButton:SetFont("HudDefault")
    timerButton.Paint = function( self, w, h ) -- 'function Frame:Paint( w, h )' works too
        draw.RoundedBox( 0, 0, 0, w, h, Color( 0,98,255,187) ) -- Draw a black box instead of the frame
    end

    timerButton.DoClick = function()
        frameOption:Close() 
        OpenSetTimer()
    end
end 

net.Receive ("receiveOpenChat" , function(bits , ply )
    local countDownTimeReceive = net.ReadInt(32)
    local imagePathReceive = net.ReadString() 
    local alphaValueReceive = net.ReadInt(32)
    print(countDownTime)
    print(imagePath)
    print(alphaValue)

    countdownTime = countDownTimeReceive
    imagePath = imagePathReceive
    alphaValue = alphaValueReceive 
    
    ShowEndScreen()
end) 


-- this function is to open and close keybinds
hook.Add("PlayerButtonDown", "test", function(ply, button)
    if LocalPlayer():IsSuperAdmin() then 
        if button == keyBind and isOpen == false then
            timer.Stop(reconnectTimer)
            OptionFrame()
            isOpen = true 
        end 
    end 
end)

-- hook.Add( "ShutDown", "ServerShuttingDown", function()

-- end )