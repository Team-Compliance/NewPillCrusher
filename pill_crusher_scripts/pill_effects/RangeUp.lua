---@param projectile EntityProjectile
local function OnProjectileUpdate(_, projectile)
    if projectile.FrameCount ~= 1 then return end

    local rangeUpCrushed = PillCrusher:GetCrushedPillNum(PillEffect.PILLEFFECT_RANGE_UP)
    local rangeDownCrushed = PillCrusher:GetCrushedPillNum(PillEffect.PILLEFFECT_RANGE_DOWN)

    local rangeUpStacks = math.max(0, rangeUpCrushed - rangeDownCrushed)

    projectile.Height = projectile.Height - rangeUpStacks * 5
end
PillCrusher:AddCallback(ModCallbacks.MC_POST_PROJECTILE_UPDATE, OnProjectileUpdate)


PillCrusher:AddPillCrusherEffect(PillEffect.PILLEFFECT_RANGE_UP, "Range Up")