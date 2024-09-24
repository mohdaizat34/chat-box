
print("sv_endscreen!!") 
util.AddNetworkString("sendMessage")
util.AddNetworkString("receiveMessage") 

util.AddNetworkString("sendOpenChat")
util.AddNetworkString("receiveOpenChat")

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
    PrintMessage(HUD_PRINTTALK, "I'm new here.")
end)