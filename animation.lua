-- if SERVER then
--     util.AddNetworkString("PlayCustomAnimation")



-- end

-- if CLIENT then
--     print("Sequences for " .. LocalPlayer():GetModel() .. ":")
--     for _, sequence in ipairs(LocalPlayer():GetSequenceList()) do
--         print(sequence)
--     end

--     net.Receive("PlayCustomAnimation", function()
--         local ply = net.ReadEntity()
--         local sequenceId = net.ReadInt(32)
        

--         if IsValid(ply) and sequenceId ~= -1 then
--             ply:AddVCDSequenceToGestureSlot(GESTURE_SLOT_ATTACK_AND_RELOAD, sequenceId, 0, true)
--         end
--     end)
-- end

-- hook.Add("KeyPress", "PlayCustomAnimationOnKeyPress", function(ply, key)
--     if key == IN_ATTACK2 then
--         local sequenceId = ply:LookupSequence("gojo_hollow_purple")

--         if sequenceId ~= -1 then
--             print("Sequence ID for '': " .. sequenceId)

--             if SERVER then
--                 net.Start("PlayCustomAnimation")
--                 net.WriteEntity(ply)
--                 net.WriteInt(sequenceId, 32)
--                 net.Broadcast()
--             end
--         else
--             print("Custom animation sequence '' not found!")
--         end
--     end
-- end)
 
if CLIENT then 
    ply = LocalPlayer() 

    -- ply:AnimRestartGesture(GESTURE_SLOT_CUSTOM, raisearmtest, true)
    -- ply:AnimSetGestureWeight(GESTURE_SLOT_CUSTOM, 1)
end 

print("Test!")

-- Define the animation data
local animData = {
    FrameData = {
		{
			BoneInfo = {
				['ValveBiped.Bip01_L_UpperArm'] = {
                    RU = 0, -- Add an initial rotation (e.g., 0 degrees)
                    RR = 0,
                    RF = 0
                },
                ['ValveBiped.Bip01_R_UpperArm'] = {
                    RU = 0,
                    RR = 0,
                    RF = 0
                }
			},
			FrameRate = 100
		},
		{
			BoneInfo = {
				['ValveBiped.Bip01_L_UpperArm'] = {
					RU = -46,
					RR = -16,
					RF = -1
				},
				['ValveBiped.Bip01_R_UpperArm'] = {
				}
			},
			FrameRate = 6.0
		},
		{
			BoneInfo = {
				['ValveBiped.Bip01_L_UpperArm'] = {
					RU = -92,
					RR = -31,
					RF = -1
				},
				['ValveBiped.Bip01_R_UpperArm'] = {
					RU = -72,
					RR = -3,
					RF = 37
				}
			},
			FrameRate = 6.0
		},
	},
	Type = TYPE_GESTURE
}

-- Function to play the custom animation
local function PlayCustomAnimation(ply)
    if not IsValid(ply) then return end

    -- Replace with your logic to apply the animation to the player
    -- For example:
    -- ply:AnimRestartGesture(GESTURE_SLOT_CUSTOM, ACT_GMOD_GESTURE_TAUNT_ZOMBIE, true)
    -- ply:AnimSetGestureWeight(GESTURE_SLOT_CUSTOM, 1)

    -- You can also set bone positions using animData
    -- For example:
    for _, frame in ipairs(animData) do
        for bone, info in pairs(frame.BoneInfo) do
            local boneIndex = ply:LookupBone(bone)
            if boneIndex then
                ply:ManipulateBoneAngles(boneIndex, Angle(info.RU, info.RR, info.RF))
            end
        end
    end
end

-- Replace 'ply' with the actual player entity
local playerEntity = Entity(1) -- Example: Get the first player entity
if IsValid(playerEntity) then
    PlayCustomAnimation(playerEntity)
else
    print("Invalid player entity!")
end

RegisterLuaAnimation('raisearmtest', {
	FrameData = {
		{
			BoneInfo = {
				['ValveBiped.Bip01_L_UpperArm'] = {
				},
				['ValveBiped.Bip01_R_UpperArm'] = {
				}
			},
			FrameRate = 100
		},
		{
			BoneInfo = {
				['ValveBiped.Bip01_L_UpperArm'] = {
					RU = -46,
					RR = -16,
					RF = -1
				},
				['ValveBiped.Bip01_R_UpperArm'] = {
				}
			},
			FrameRate = 6.0
		},
		{
			BoneInfo = {
				['ValveBiped.Bip01_L_UpperArm'] = {
					RU = -92,
					RR = -31,
					RF = -1
				},
				['ValveBiped.Bip01_R_UpperArm'] = {
					RU = -72,
					RR = -3,
					RF = 37
				}
			},
			FrameRate = 6.0
		},
	},
	Type = TYPE_GESTURE
})