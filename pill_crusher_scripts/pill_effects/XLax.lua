local Helpers = require("pill_crusher_scripts.Helpers")

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
    end
end)