local Helpers = require("pill_crusher_scripts.Helpers")

PillCrusher:AddPillCrusherEffect(PillEffect.PILLEFFECT_X_LAX, "X-Lax",
function (_, _, _, isHorse)
    for _, enemy in ipairs(Helpers.GetEnemies(false)) do
        local mul = isHorse and 2 or 1

        local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CREEP_SLIPPERY_BROWN, 0, enemy.Position, Vector.Zero, nil)
        creep = creep:ToEffect()

        creep.SpriteScale = creep.SpriteScale * 2.5 * mul
    end
end)