---@param projectile EntityProjectile
local function OnProjectileUpdate(_, projectile)
    if projectile.FrameCount ~= 1 then return end

    local shotSpeedUpCrushed = PillCrusher:GetCrushedPillNum(PillEffect.PILLEFFECT_SHOT_SPEED_UP)
    local shotSpeedDownCrushed = PillCrusher:GetCrushedPillNum(PillEffect.PILLEFFECT_SHOT_SPEED_DOWN)

    local shotSpeedUpStacks = math.max(0, shotSpeedUpCrushed - shotSpeedDownCrushed)

    projectile.Velocity = projectile.Velocity * (1 + shotSpeedUpStacks * 0.2)
end
PillCrusher:AddCallback(ModCallbacks.MC_POST_PROJECTILE_UPDATE, OnProjectileUpdate)


PillCrusher:AddPillCrusherEffect(PillEffect.PILLEFFECT_SHOT_SPEED_UP, "Shot Speed Up")