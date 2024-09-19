
print("sv_endscreen!!") 
util.AddNetworkString("sendMessage")
util.AddNetworkString("receiveMessage") 

net.Receive ("sendMessage" , function(bits , ply ) 
    local sendMessage = net.ReadString() 

    net.Start("receiveMessage")
    net.WriteString(sendMessage)
    net.Broadcast() 
end) 


--Show the end screen when the shutdown begins
hook.Add("ShutDown", "ServerShuttingDown", function()
    PrintMessage(HUD_PRINTTALK, "I'm new here.")
end)