if SERVER then
    -- Wait for players to connect
    timer.Simple(1, function()
        -- Get the first player
        local player1 = Entity(1)

        -- Get the second player
        local player2 = Entity(2)

        -- Create the ball
        local ball = ents.FindByClass( "prop_physics*" ) -- Get reference to the volleyball entity
        for k, v in pairs( ball ) do 
  
            -- Lag compensation
            local lag_compensation = 0.2 -- Adjust this value based on your server's lag

            -- Update the ball's position
            function ball:Think()
                if not self:IsMoveable() then return end

                local cur_time = CurTime()
                local time_since_last_update = cur_time - self.last_update

                -- Update the ball's position based on its velocity
                self:SetPos(self:GetPos() + self:GetVelocity() * time_since_last_update)

                -- Store the current time for the next update
                self.last_update = cur_time
            end

            -- Serverside: Send the ball's position to all clients
            function ball:OnMove(data)
                if not self:IsMoveable() then return end

                local pos = self:GetPos()
                local velocity = self:GetVelocity()

                -- Use the built-in LagCompensate method to compensate for network latency
                local lag_compensated_pos, lag_compensated_velocity = util.LagCompensate(self, pos, velocity, lag_compensation)

                net.Start("SendBallPosition")
                net.WriteEntity(self)
                net.WriteVector(lag_compensated_pos)
                net.WriteVector(lag_compensated_velocity)
                net.Broadcast()
            end

            function HandleInput(ply, bind, pressed)
                if not pressed then return end
            
                if bind == "ActivateVelocity" then -- This is the console command you've bound to the left mouse button
                    --local ball = Entity(1) -- Assuming the ball is the first entity in the entity list
                    local velocity = Vector(0, 0, 100) -- The desired velocity you want to add to the ball
            
                    -- Check if the player has clicked the left mouse button
                    if input.IsMouseDown(MOUSE_LEFT) then
                        -- Add the velocity to the ball
                        print("Pressing left")
                        ball:SetVelocity(ball:GetVelocity() + velocity)
                    end
                end
            end
        end 

        -- Bind the input to the function
        concommand.Add("ActivateVelocity", HandleInput)
    end)
end

if CLIENT then
    -- Clientside: Receive the ball's position and velocity from the server
    net.Receive("SendBallPosition", function()
        local ball = net.ReadEntity()
        local pos = net.ReadVector()
        local velocity = net.ReadVector()

        -- Set the ball's position and velocity on the client
        ball:SetPos(pos)
        ball:SetVelocity(velocity)
    end)
end