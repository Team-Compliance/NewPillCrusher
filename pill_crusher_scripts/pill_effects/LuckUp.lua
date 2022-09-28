local AddableProjectileFlags = {
    ProjectileFlags.SMART,
    ProjectileFlags.EXPLODE,
    ProjectileFlags.ACID_GREEN,
    ProjectileFlags.GOO,
    ProjectileFlags.GHOST,
    ProjectileFlags.WIGGLE,
    ProjectileFlags.BOOMERANG,
    ProjectileFlags.ACID_RED,
    ProjectileFlags.GREED,
    ProjectileFlags.RED_CREEP,
    ProjectileFlags.CREEP_BROWN,
    ProjectileFlags.BURST,
    ProjectileFlags.BURST3,
    ProjectileFlags.BURST8,
    ProjectileFlags.BURSTSPLIT,
    ProjectileFlags.SHIELDED,
    ProjectileFlags.FIRE_SPAWN,
    ProjectileFlags.GODHEAD
}


---@param projectile EntityProjectile
local function OnProjectileUpdate(_, projectile)
    if projectile.FrameCount ~= 1 then return end

    local luckUpCrushed = PillCrusher:GetCrushedPillNum(PillEffect.PILLEFFECT_LUCK_UP)
    local luckDownCrushed = PillCrusher:GetCrushedPillNum(PillEffect.PILLEFFECT_LUCK_DOWN)

    local luckUpStacks = math.max(0, luckUpCrushed - luckDownCrushed)

    local rng = RNG()
    rng:SetSeed(projectile.InitSeed, 35)

    if rng:RandomInt(100) < luckUpStacks * 10 then
        local chosenProjectileFlag = AddableProjectileFlags[rng:RandomInt(#AddableProjectileFlags) + 1]
        projectile:AddProjectileFlags(chosenProjectileFlag)
    end
end
PillCrusher:AddCallback(ModCallbacks.MC_POST_PROJECTILE_UPDATE, OnProjectileUpdate)


PillCrusher:AddPillCrusherEffect(PillEffect.PILLEFFECT_LUCK_UP, "Luck Up")