local Helpers = require("pill_crusher_scripts.Helpers")


PillCrusher:AddPillCrusherEffect(PillEffect.PILLEFFECT_SOMETHINGS_WRONG, "Something's wrong...",
function (_, _, _, isHorse)
    for _,enemy in ipairs(Helpers.GetEnemies(false)) do
        local mul = isHorse and 2 or 1

        local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CREEP_BLACK, 0, enemy.Position, Vector.Zero, nil)
        local playercreep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_BLACK, 0, enemy.Position, Vector.Zero, nil)
        creep = creep:ToEffect()
        playercreep = playercreep:ToEffect()

        creep.SpriteScale = creep.SpriteScale * 2.5
        playercreep.SpriteScale = playercreep.SpriteScale * 2.5
        playercreep.Visible = false

        creep.Timeout = creep.Timeout * mul
        playercreep.Timeout = playercreep.Timeout * mul
    end
end)