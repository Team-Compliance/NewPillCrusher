local Helpers = require("pill_crusher_scripts.Helpers")


---@param creep EntityEffect
local function OnLiquidPoopCreepUpdate(_, creep)
    local data = Helpers.GetData(creep)

    if not data then return end

    ---@type EntityEffect
    local slipperyCreep = data.SlipperyCreep

    if not slipperyCreep then return end

    if not slipperyCreep:Exists() then
        creep:Remove()
        return
    end

    creep.SpriteScale = slipperyCreep.SpriteScale
end
PillCrusher:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, OnLiquidPoopCreepUpdate, EffectVariant.CREEP_LIQUID_POOP)


PillCrusher:AddPillCrusherEffect(PillEffect.PILLEFFECT_X_LAX, "X-Lax",
function (_, _, _, isHorse)
    for _, enemy in ipairs(Helpers.GetEnemies(false)) do
        local mult = isHorse and 2 or 1

        local slipperyCreep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CREEP_SLIPPERY_BROWN, 0, enemy.Position, Vector.Zero, nil)
        slipperyCreep = slipperyCreep:ToEffect()

        local blueBabyCreep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CREEP_LIQUID_POOP, 0, enemy.Position, Vector.Zero, nil)
        blueBabyCreep = blueBabyCreep:ToEffect()

        slipperyCreep.SpriteScale = slipperyCreep.SpriteScale * 2.5
        blueBabyCreep.SpriteScale = slipperyCreep.SpriteScale

        slipperyCreep.Timeout = slipperyCreep.Timeout * mult
        blueBabyCreep.Timeout = slipperyCreep.Timeout

        slipperyCreep.Visible = false

        Helpers.GetData(blueBabyCreep).SlipperyCreep = slipperyCreep
    end
end)