-- hook.Add("KeyPress", "PlayCustomAnimationOnKeyPress", function(ply, key)
--     if key == IN_ATTACK2 and IsFirstTimePredicted() then
--         -- Find the sequence ID for the "taunt_laugh" animation
--         local sequenceId = ply:LookupSequence("taunt_laugh")

--         if sequenceId ~= -1 then
--             -- Print sequence ID for debugging
--             print("Sequence ID for 'taunt_laugh': " .. sequenceId)

--             -- Play the animation
--             ply:SetCycle(0)
--             ply:SetSequence(sequenceId)
--             ply:SetPlaybackRate(1)
--         else
--             print("Custom animation sequence 'taunt_laugh' not found!")
--         end
--     end
-- end)
