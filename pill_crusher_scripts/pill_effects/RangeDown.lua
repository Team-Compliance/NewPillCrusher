---@param projectile EntityProjectile
local function OnProjectileUpdate(_, projectile)
    if projectile.FrameCount ~= 1 then return end

    local rangeUpCrushed = PillCrusher:GetCrushedPillNum(PillEffect.PILLEFFECT_RANGE_UP)
    local rangeDownCrushed = PillCrusher:GetCrushedPillNum(PillEffect.PILLEFFECT_RANGE_DOWN)

    local rangeDownStacks = math.max(0, rangeDownCrushed - rangeUpCrushed)

    projectile.Height = projectile.Height + rangeDownStacks * 4
end
PillCrusher:AddCallback(ModCallbacks.MC_POST_PROJECTILE_UPDATE, OnProjectileUpdate)


PillCrusher:AddPillCrusherEffect(PillEffect.PILLEFFECT_RANGE_DOWN, "Range Down")