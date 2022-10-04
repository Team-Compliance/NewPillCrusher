local ClearableProjectileFlags = {
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
    ProjectileFlags.SHIELDED,
    ProjectileFlags.CHANGE_FLAGS_AFTER_TIMEOUT,
    ProjectileFlags.FIRE_SPAWN,
    ProjectileFlags.GODHEAD
}


---@param projectile EntityProjectile
local function OnProjectileUpdate(_, projectile)
    if projectile.FrameCount ~= 1 then return end

    local tearsUpCrushed = PillCrusher:GetCrushedPillNum(PillEffect.PILLEFFECT_TEARS_UP)
    local tearsDownCrushed = PillCrusher:GetCrushedPillNum(PillEffect.PILLEFFECT_TEARS_DOWN)

    local tearsDownStacks = math.max(0, tearsDownCrushed - tearsUpCrushed)

    local rng = RNG()
    rng:SetSeed(projectile.InitSeed, 35)

    if rng:RandomInt(100) < tearsDownStacks * 10 then
        for _, projectileFlag in ipairs(ClearableProjectileFlags) do
            projectile:ClearProjectileFlags(projectileFlag)
        end
        projectile.Color = Color(1, 1, 1)
    end
end
PillCrusher:AddCallback(ModCallbacks.MC_POST_PROJECTILE_UPDATE, OnProjectileUpdate)


PillCrusher:AddPillCrusherEffect(PillEffect.PILLEFFECT_TEARS_DOWN, "Tears Down")