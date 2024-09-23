if SERVER then
    hook.Add("DoPlayerDeath", "SilenceNPCsDeathSound", function(ply)
        if IsValid(ply) and ply:IsNPC() then
            ply:EmitSound("common/null.wav") -- Replace "null.wav" with an appropriate silent sound if needed
            return true
        end
    end)
end