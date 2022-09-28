local Helpers = require("pill_crusher_scripts.Helpers")


PillCrusher:AddPillCrusherEffect(PillEffect.PILLEFFECT_LEMON_PARTY, "Lemon Party",
function (_, _, _, isHorse)
    for _,enemy in ipairs(Helpers.GetEnemies(false)) do
        local mul = isHorse and 2 or 1

        local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CREEP_YELLOW, 0, enemy.Position, Vector.Zero, nil)
        local playercreep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_RED, 0, enemy.Position, Vector.Zero, nil)
        creep = creep:ToEffect()
        playercreep = playercreep:ToEffect()

        creep.SpriteScale = creep.SpriteScale * 2.5 * mul
        playercreep.SpriteScale = playercreep.SpriteScale * 2.5 * mul
        playercreep.Visible = false

        creep.Timeout = 120
        playercreep.Timeout = 120
    end
end)