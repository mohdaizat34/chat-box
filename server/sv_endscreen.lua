print("sv_endscreen!!") 
util.AddNetworkString("sendMessage")
util.AddNetworkString("receiveMessage") 

util.AddNetworkString("sendOpenChat")
util.AddNetworkString("receiveOpenChat")

util.AddNetworkString("restartServer")

--self explanatory, restart the server using ULX commands 
net.Receive ("restartServer" , function(bits , ply )
    -- Set the countdown time in seconds
    local countdownTime = 1
    
    -- Notify players about the server restart
    for _, ply in ipairs(player.GetAll()) do
        
       ply:PrintMessage( HUD_PRINTTALK, "Server Is Restarting." )
        -- Client-side countdown before disconnecting
        ply:SendLua([[
            local disconnectTime = ]] .. countdownTime - 1 .. [[

            -- Set the auto-reconnect timer after disconnecting
            timer.Simple(]] .. countdownTime + 1 .. [[, function() 
                LocalPlayer():ConCommand('retry') 
            end)
        ]])
    end
    
    -- Server-side: Restart the server after the countdown
    timer.Simple(countdownTime, function()
        game.ConsoleCommand("changelevel " .. game.GetMap() .. "\n") -- Restart server with the current map
    end)
end) 

net.Receive ("sendMessage" , function(bits , ply ) 
    local sendMessage = net.ReadString() 

    net.Start("receiveMessage")
    net.WriteString(sendMessage)
    net.Broadcast() 
end) 

net.Receive ("sendOpenChat" , function(bits , ply ) 
    


    local countDownTime = net.ReadInt(32)
    local imagePath = net.ReadString() 
    local alphaValue = net.ReadInt(32)

    net.Start("receiveOpenChat")
    net.WriteInt(countDownTime,32)
    net.WriteString(imagePath)
    net.WriteInt(alphaValue,32)
    net.Broadcast() 
end)


--Show the end screen when the shutdown begins
hook.Add("ShutDown", "ServerShuttingDown", function()
   
end)