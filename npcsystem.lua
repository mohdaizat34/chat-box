-- conversation_example.lua
print("Npc system!")
-- Define the conversation data

function Conversation() 
    conversationDataChiaki = {
        -- The actual dialogue lines
        dialogue = {
            { speaker = "Chiaki Nanami:", text = "(Sitting and playing a handheld gaming console) Oh, hey there! Wanna join me in this game? It's super fun!", sprite = "sprite/chiakihello.png"}, //1
            { speaker = "", text = "[Select your dialogue choice]", sprite = "sprite/chiakihello.png"},

            --[[Accept the invitation: "Sure, I'd love to play with you, Chiaki!"
                Decline politely: "I appreciate the offer, but I'm not much of a gamer."]]


           --[[ { speaker = "You", text = "Konichiwa!" , sprite = "sprite/chiakihello.png"},//2
            { speaker = "You", text = "Ore no namae wa... Genshitto Impacto deshu..." , sprite = "sprite/chiakihello.png"},//3
            { speaker = "You", text = "Yoroshiku nee!" , sprite = "sprite/chiakihello.png"},//4
            { speaker = "GMan", text = "Tomodachi ni yarou ! :)" , sprite = "sprite/chiakismile.png"},//5
            { speaker = "GMan", text = "Sike! Fuck you" , sprite = "sprite/chiakidrool.png"},//6
            { speaker = "You", text = "Hold on.. Why would you say that?" , sprite = "sprite/chiakihello.png"},//7
            { speaker = "You", text = "You wanna fight lil bozo?" , sprite = "sprite/chiakihello.png"},//8
            { speaker = "GMan", text = "It's fine G. *bro handshake*. Here man a crowbar for ya. Keep yourself safe." , sprite = "sprite/chiakismile.png"},//9
            -- Add more lines here... --]] 
        },

        dialogue_route1_positive = {
             { speaker = "Chiaki Nanami:", text = "(Smiling) Awesome! Let's see how good you are at this.", sprite = "sprite/chiakihello.png"}, //1
             { speaker = "", text = "(The player and Chiaki engage in friendly competition, laughing and having a great time together.)", sprite = "sprite/chiakihello.png"}, //2
             { speaker = "Chiaki Nanami:", text = "(Pleased) You're really good at this! I like playing with you.", sprite = "sprite/chiakihello.png"}, //3
             { speaker = "", text = "[Select your dialogue choice]", sprite = "sprite/chiakihello.png"}, //4
        },

        dialogue_route1_negative = {

        },
        -- The index of the current line being displayed
        currentIndex = 1
    }
end 

-- Create the conversation GUI
local function CreateConversationGUI()
    Conversation()


    --- UI Shits--------------------------
    local frame = vgui.Create("DFrame")
    frame:SetSize(1336,768)
    frame:Center()
    frame:SetTitle("Conversation")
    frame:SetVisible(true)
    frame:SetDraggable(true)
    frame:ShowCloseButton(true)
    frame:MakePopup()
    function frame:Paint(w, h)
    draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 50)) 
    end

    local sprite = vgui.Create( "DImage", frame )
    sprite:SetPos(250,0)
    sprite:SetSize( 768, 768 )
    sprite:SetImage("sprite/chiakihello.png")

    local MainPanel = vgui.Create( "DPanel",frame)
    MainPanel:Dock(FILL) -- Set the position of the panel
    MainPanel:SetSize( 200, 500) -- Set the size of the panel
    MainPanel:SetBackgroundColor(Color(0,0,0,0))

    local BottomPanel = vgui.Create( "DPanel",MainPanel)
    BottomPanel:Dock(BOTTOM) -- Set the position of the panel
    BottomPanel:SetSize( 200, 200) -- Set the size of the panel
    BottomPanel:SetBackgroundColor(Color(0,0,0,200))

    local dialogueLabel = vgui.Create("DLabel", BottomPanel)
    dialogueLabel:Dock(TOP)
    dialogueLabel:SetSize(380, 100)
    dialogueLabel:SetFont("Trebuchet24")
    dialogueLabel:SetWrap(true) 

    local nextButton = vgui.Create("DImageButton", BottomPanel) 
    //nextButton:Dock(TOP)
    nextButton:SetPos( 1200, 100 )
    nextButton:SetSize(60, 60)
    nextButton:SetImage( "ui/next.png" )

    local yesButton = vgui.Create("DButton", BottomPanel)
    yesButton:Dock(TOP)
    yesButton:SetPos(10, 150)
    yesButton:SetSize(380, 40)
    yesButton:SetText("Kill this nigga")
    yesButton:SetVisible(false) 

    local noButton = vgui.Create("DButton", BottomPanel)
    noButton:Dock(TOP)
    noButton:SetPos(10, 200)
    noButton:SetSize(380, 40)
    noButton:SetText("") 
    noButton:SetVisible(false) 
    ----------------------------------------------------------------



    -- Function to update the dialogue label text
    local function UpdateDialogue()
        local currentLine = conversationDataChiaki.dialogue[conversationDataChiaki.currentIndex]
        dialogueLabel:SetText(currentLine.speaker .. " " .. currentLine.text)

        if currentLine.speaker  == "Chiaki Nanami:" then 
            dialogueLabel:SetTextColor(Color(252, 194, 237))
        else 
            dialogueLabel:SetTextColor(Color(41, 180, 240))
        end 

        sprite:SetImage(currentLine.sprite)
       // sprite:SetSize(surface.GetTextureSize( surface.GetTextureID( currentLine.sprite ) ))

        //event decision chiaki 1 
        if conversationDataChiaki.currentIndex == 2 then 
            nextButton:SetVisible(false) 

            yesButton:SetText("Sure, I'd love to play with you, Chiaki!")
            yesButton:SetVisible(true)

            noButton:SetText("I appreciate the offer, but I'm not much of a gamer.") 
            noButton:SetVisible(true)

            //option 1
            function yesButton:DoClick() 
                local currentLine = conversationDataChiaki.dialogue_route1_positive[conversationDataChiaki.currentIndex]
                local state = "chiakiPositiveRoute1" 

                dialogueLabel:SetText(currentLine.speaker .." ".. currentLine.text)
                yesButton:SetVisible(false)
                noButton:SetVisible(false) 
                nextButton:SetVisible(true)
                nextScript() 

            end 

            //option 2
            function noButton:DoClick() 
                dialogueLabel:SetText(currentLine.speaker .. ": My Bad G.. I was just kidding. Nanka.. Gomen nee?")
                local state = "negativeRoute" 

                // basically we hide yes no button, and make next button appear again.. 
                yesButton:SetVisible(false)
                noButton:SetVisible(false) 
                nextButton:SetVisible(true)
                nextScript() 

            end

        // Give RPG event with GMan
        elseif conversationDataChiaki.currentIndex == 9 then
            net.Start("giveItem") 
            net.WriteString("give item gman")
            net.SendToServer()
        end 


    end


    -- chiaki route1 positive route 
    function nextScript() 
        -- Function to handle the "Next" button click
        nextButton.DoClick = function()

            if state == "chiakiPositiveRoute1" then 
                print("Current index:"..conversationDataChiaki.currentIndex)
               
                conversationDataChiaki.currentIndex = conversationDataChiaki.currentIndex + 1 
                if conversationDataChiaki.currentIndex > #conversationDataChiaki.dialogue_route1_positive then
                    frame:Close() -- End the conversation when there are no more lines

                else
                    UpdateDialogue()
                end
            else 
                print("Current index:"..conversationDataChiaki.currentIndex)
               
                conversationDataChiaki.currentIndex = conversationDataChiaki.currentIndex + 1
                if conversationDataChiaki.currentIndex > #conversationDataChiaki.dialogue then
                    frame:Close() -- End the conversation when there are no more lines
                    //currentIndex = 1 
                else
                    UpdateDialogue()
                end
            end 
        end
    end 

    nextScript() 
    UpdateDialogue() -- Display the first line of dialogue
end
--[[
if SERVER then 
    util.AddNetworkString("giveItem")

    hook.Add("PlayerButtonDown","createBot",function(ply,button)
        if button == KEY_G then 
            local npc = ents.Create("npc_gman") -- Replace "npc_zombie" with the desired NPC classname
            if not IsValid(npc) then return end
            npc:SetPos(Vector(314.276245, -73.277122, -12223.968750)) -- Set the position where the NPC should spawn (modify the Vector values)
            npc:Spawn()
            -- Optionally, set additional properties for the NPC, e.g., its health and behavior
            npc:SetHealth(100)
        end 
    end) 

    //give item Gman 
    net.Receive( "giveItem", function(bits,ply)
        local item = net.ReadString() 
        print(item)

        if item == "give item gman" then 
            ply:Give("weapon_crowbar")
            ply:ChatPrint("You received crowbar from GMan.")
        end 
    end) 
end 

if CLIENT then 
    local ply = LocalPlayer() 
    -- Start the conversation
    hook.Add("PlayerButtonDown","ActivateConversation",function(ply,button)

        //target specific NPC  
        if button == KEY_E then 
                entName = tostring(ply:GetEyeTrace().Entity) 
                print("String: "..entName)
            if (entName == "NPC [91][npc_gman]") then   
                CreateConversationGUI()
            end 
        end   
    end)
end ]]
