-- monokuma_judging.lua
--[[

if SERVER then 
    -- Define the attributes form
    local attributeForm = {}
     util.AddNetworkString("send_individual_stats")

    util.AddNetworkString("SubmitAttributes")
    net.Receive("SubmitAttributes", function(_, ply)
        local social = net.ReadInt(32)
        local intellectual = net.ReadInt(32)
        local investigation = net.ReadInt(32)
        local classTrial = net.ReadInt(32)
        local reputation = net.ReadInt(32)
        local playerEnt = net.ReadEntity()
        
        local totalScore = social + intellectual + investigation + classTrial + reputation
        
        -- Store attributes and total score for ranking later
        ply.attributes = { social = social, intellectual = intellectual, investigation = investigation, classTrial = classTrial, reputation = reputation, }
        ply.totalScore = totalScore

        net.Start("send_individual_stats")
        net.WriteInt(social,  32)
        net.WriteInt(intellectual,  32)
        net.WriteInt(investigation,  32)
        net.WriteInt(classTrial,  32)
        net.WriteInt(reputation,  32)
        net.Send(playerEnt)
    end)

    -- Calculate judgment score based on attributes
    local function CalculateJudgmentScore(attributes)
        return attributes.social + attributes.intellectual + attributes.investigation + attributes.classTrial + attributes.reputation
    end

    -- Get a table of all players and their judgment scores
    local function GetRankedPlayers()
        local rankedPlayers = {}

        for _, ply in pairs(player.GetAll()) do
            if ply.attributes then
                local score = CalculateJudgmentScore(ply.attributes)
                table.insert(rankedPlayers, { player = ply, score = score })
            end
        end

        table.sort(rankedPlayers, function(a, b)
            return a.score > b.score
        end)

        return rankedPlayers
    end

    util.AddNetworkString("insertRankAll")
    util.AddNetworkString("printRankedAll")
    -- Register a console command to print ranked players
    concommand.Add("print_ranked_players", function()
        local rankedPlayers = GetRankedPlayers()

        net.Start("printRankedAll")
        net.Broadcast() 

        for _, data in ipairs(rankedPlayers) do
            print(data.player:Nick(), "Score:", data.score)

            net.Start("insertRankAll")
            net.WriteString(data.player:Nick())
            net.WriteString(data.score)
            net.Broadcast() 
        end
    end)

    -- Initialize the attribute form
    hook.Add("PlayerInitialSpawn", "InitializeAttributeForm", function(ply)
        timer.Simple(1, function()
            if IsValid(ply) then
                ply:ChatPrint("Welcome to the Monokuma Judging System. Type '!attributes' to fill in your attributes.")
            end
        end)
    end)
end 


if CLIENT then 

    -- individual stats 
    net.Receive("send_individual_stats", function()
        local social = net.ReadInt(32)
        local intellectual = net.ReadInt(32)
        local investigation = net.ReadInt(32)
        local classTrial = net.ReadInt(32)
        local reputation = net.ReadInt(32)
        local playerEnt = net.ReadEntity()

        local scoreFrame = vgui.Create("DFrame")
        scoreFrame:SetSize(300, 400)
        scoreFrame:SetTitle("Your Score")
        scoreFrame:Center()
        scoreFrame:MakePopup()
        function scoreFrame:Paint(w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(18, 10, 41,300)) 
        end

        local skill1 = vgui.Create("DLabel", scoreFrame)
        skill1:SetText("Social: "..social.."\n\nIntellectual: "..intellectual.."\n\nInvestigation: "..investigation.."\n\nClass Trial: "..classTrial.."\n\nReputation: "..reputation)
        skill1:Dock(TOP)
        skill1:DockMargin(0, 50, 0, 0)
        skill1:SetWrap(true)
        skill1:SetFont("CreditsText")
        skill1:SetSize(350, 200)

         local info = vgui.Create("DLabel", scoreFrame)
        info:SetText("Please wait while monokuma is ranking players..")
        info:Dock(TOP)
        info:SetWrap(true)
        info:SetFont("DefaultBold")
        info:SetSize(150, 30)
    end) 

    net.Receive("printRankedAll", function()
        print("print Rank All? ")
        local rankFrame = vgui.Create("DFrame")
        rankFrame:SetSize(300, 400)
        rankFrame:SetTitle("Score Guide")
        rankFrame:Center()
        rankFrame:MakePopup()
        function rankFrame:Paint(w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(18, 10, 41,300)) 
        end

        rankFrameRight = vgui.Create( "DScrollPanel", rankFrame )  
        rankFrameRight:Dock(RIGHT)
        rankFrameRight:SetSize(150,0)
        rankFrameRight.Paint = function( self, w, h )  
        draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0,0) ) -- Draw a black box instead of the frame
        end

        local labelScore = vgui.Create("DLabel", rankFrameRight)
        labelScore:SetText("SCORE")
        labelScore:Dock(TOP)
        labelScore:SetWrap(true)
        labelScore:SetFont("Trebuchet24")
        labelScore:SetSize(40, 80)

        rankFrameFill = vgui.Create( "DScrollPanel", rankFrame )  
        rankFrameFill:Dock(FILL)
        rankFrameFill.Paint = function( self, w, h )  
        draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0,0) ) -- Draw a black box instead of the frame
        end

        local labelName = vgui.Create("DLabel", rankFrameFill)
        labelName:SetText("NAME")
        labelName:Dock(TOP)
        labelName:SetWrap(true)
        labelName:SetFont("Trebuchet24")
        labelName:SetSize(200, 80)
    end) 

    local rankingNo = 0 
    net.Receive("insertRankAll", function()
        local playerName = net.ReadString() 
        local playerScore = net.ReadString() 

        rankingNo = rankingNo + 1 
        local name = vgui.Create("DLabel", rankFrameFill)
        name:SetText(rankingNo..".".. playerName)
        name:Dock(TOP)
        name:SetWrap(true)
        name:SetFont("CreditsText")
        name:SetSize(200, 80)

        local score = vgui.Create("DLabel", rankFrameRight)
        score:SetText(playerScore)
        score:Dock(TOP)
        score:SetWrap(true)
        score:SetFont("CreditsText")
        score:SetSize(200, 80)
    end) 


    function ScoreGuideFrame() 
        local scoreFrame = vgui.Create("DFrame")
        scoreFrame:SetSize(300, 400)
        scoreFrame:SetTitle("Score Guide")
        scoreFrame:Center()
        scoreFrame:MakePopup()
        function scoreFrame:Paint(w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(18, 10, 41,300)) 
        end

        local FillPanel = vgui.Create( "DScrollPanel", scoreFrame )  
        FillPanel:Dock(FILL)
        FillPanel.Paint = function( self, w, h )  
        draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0,0) ) -- Draw a black box instead of the frame
        end

        local info = vgui.Create("DLabel", FillPanel)
        info:SetText("You can drag this frame to side while doing scoring")
        info:Dock(TOP)
        info:SetWrap(true)
        info:SetFont("DefaultBold")
        info:SetSize(150, 30)


        local skill1 = vgui.Create("DLabel", FillPanel)
        skill1:SetText("Social Skills: Charisma, Ability to Build Alliances, Leadership")
        skill1:Dock(TOP)
        skill1:SetWrap(true)
        skill1:SetFont("CreditsText")
        skill1:SetSize(200, 80)

        local skill2 = vgui.Create("DLabel", FillPanel)
        skill2:SetText("Intellectual Skills: Problem Solving, Memory, Critical Thinking")
        skill2:Dock(TOP)
        skill2:SetWrap(true)
        skill2:SetFont("CreditsText")
        skill2:SetSize(200, 80)

        local skill3 = vgui.Create("DLabel", FillPanel)
        skill3:SetText("Investigation Skills: Observation, Attention to Detail, Getting information from others")
        skill3:Dock(TOP)
        skill3:SetWrap(true)
        skill3:SetFont("CreditsText")
        skill3:SetSize(200, 80)

        local skill4 = vgui.Create("DLabel", FillPanel)
        skill4:SetText("Class Trial Skills: Solving Mysteries and Puzzles, Presenting Evidence, Identifying Culprits, Ability to manipulate info, Ability to pressure culprit")
        skill4:Dock(TOP)
        skill4:SetWrap(true)
        skill4:SetFont("CreditsText")
        skill4:SetSize(200, 150)

        local skill4 = vgui.Create("DLabel", FillPanel)
        skill4:SetText("Reputation: Performance of the game, How Well-Liked the Player Is by Others and by Monokuma/Admins")
        skill4:Dock(TOP)
        skill4:SetWrap(true)
        skill4:SetFont("CreditsText")
        skill4:SetSize(200, 80)
    end 



    playertableindex = 1 
    playerNameList = {}
    playerscount = 0 

    function JudgeFrame(ply)  
        
        local frame = vgui.Create("DFrame")
        frame:SetSize(300, 400)
        frame:SetTitle("Scoring Attributes")
        frame:Center()
        frame:MakePopup()
        function frame:Paint(w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(18, 10, 41,300)) 
        end

        local scoreInfoButton = vgui.Create("DButton", frame)
        scoreInfoButton:SetText("Score Guide")
        scoreInfoButton:SetPos(5, 30)
        function scoreInfoButton:DoClick()
            ScoreGuideFrame() 
        end 

        --name on who we judging 
        local playerName = vgui.Create("DButton", frame)
        playerName:SetText("Name: "..ply:Nick())
        playerName:SetSize(150,30)
        playerName:SetPos(5, 70)
        playerName:SetTextColor(Color(255,0,0))
        playerName:SetFont("ScoreboardDefault")
        function playerName:Paint(w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0,0)) 
        end

        local commLabel = vgui.Create("DLabel", frame)
        commLabel:SetText("Social Skills:")
        commLabel:SetPos(10, 110)
        commLabel:SetFont("GModNotify")
        commLabel:SetSize(150, 30)

        local commSlider = vgui.Create("DNumSlider", frame)
        commSlider:SetPos(100, 110)
        commSlider:SetSize(200, 30)
        commSlider:SetMin(0)
        commSlider:SetMax(10)
        commSlider:SetDecimals(0)

        
        local intellectLabel = vgui.Create("DLabel", frame)
        intellectLabel:SetText("Intellectual:")
        intellectLabel:SetPos(10, 150)
        intellectLabel:SetFont("GModNotify")
        intellectLabel:SetSize(150, 30)
        
        local intellectSlider = vgui.Create("DNumSlider", frame)
        intellectSlider:SetPos(100, 150)
        intellectSlider:SetSize(200, 30)
        intellectSlider:SetMin(0)
        intellectSlider:SetMax(10)
        intellectSlider:SetDecimals(0)
        
        local investigationLabel = vgui.Create("DLabel", frame)
        investigationLabel:SetText("Investigation:")
        investigationLabel:SetPos(10, 190)
        investigationLabel:SetFont("GModNotify")
        investigationLabel:SetSize(150, 30)
        
        local investigationSlider = vgui.Create("DNumSlider", frame)
        investigationSlider:SetPos(100, 190)
        investigationSlider:SetSize(200, 30)
        investigationSlider:SetMin(0)
        investigationSlider:SetMax(10)
        investigationSlider:SetDecimals(0)

        local trialLabel = vgui.Create("DLabel", frame)
        trialLabel:SetText("Class Trial:")
        trialLabel:SetPos(10, 230)
        trialLabel:SetFont("GModNotify")
        trialLabel:SetSize(150, 30)
        
        local trialSlider = vgui.Create("DNumSlider", frame)
        trialSlider:SetPos(100, 230)
        trialSlider:SetSize(200, 30)
        trialSlider:SetMin(0)
        trialSlider:SetMax(10)
        trialSlider:SetDecimals(0)

        local repLabel = vgui.Create("DLabel", frame)
        repLabel:SetText("Reputation:")
        repLabel:SetPos(10, 270)
        repLabel:SetFont("GModNotify")
        repLabel:SetSize(150, 30)
        
        local repSlider = vgui.Create("DNumSlider", frame)
        repSlider:SetPos(100, 270)
        repSlider:SetSize(200, 30)
        repSlider:SetMin(0)
        repSlider:SetMax(10)
        repSlider:SetDecimals(0)
        
        local submitButton = vgui.Create("DButton", frame)
        submitButton:SetText("Next")
        submitButton:SetPos(100, 340)
        submitButton:SetTextColor(Color(255,255,255))
        submitButton:SetSize(100, 30)
        submitButton.DoClick = function()
            local social = commSlider:GetValue()
            local intellectual = intellectSlider:GetValue()
            local investigation = investigationSlider:GetValue()
            local classTrial = trialSlider:GetValue()
            local reputation = repSlider:GetValue()
            
            net.Start("SubmitAttributes")
            net.WriteInt(social, 32)
            net.WriteInt(intellectual, 32)
            net.WriteInt(investigation, 32)
            net.WriteInt(classTrial, 32)
            net.WriteInt(reputation, 32)
            net.WriteEntity(ply)
            net.SendToServer()
            
            frame:Close()
            

            playertableindex = playertableindex + 1
            print("index:"..playertableindex)
            print("all player count:"..playerscount)
            
            

            if playertableindex > playerscount then

            else 
                JudgeFrame(playerNameList[playertableindex])
            end 

            //end 
            
        end
        function submitButton:Paint(w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(214, 100, 0,200)) 
        end
    end 


    concommand.Add( "openjudgesystem", function( ply, cmd, args )

        playerNameList = player.GetAll()
        playertableindex = 1  // reset index 
        rankingNo = 0 //reset rank when use command print_ranked_all
        playerscount = #playerNameList 

        JudgeFrame(playerNameList[1])

    
    end)
end    
]]