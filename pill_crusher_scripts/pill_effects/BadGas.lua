local Helpers = require("pill_crusher_scripts.Helpers")

PillCrusher:AddPillCrusherEffect(PillEffect.PILLEFFECT_BAD_GAS, "Bad Gas",
function (player, _, _, isHorse)
    for _,enemy in ipairs(Helpers.GetEnemies(false)) do
        local cloud = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SMOKE_CLOUD, 0, enemy.Position, Vector.Zero, enemy):ToEffect()
        local multi = isHorse and 2 or 1
        cloud.LifeSpan = 180 / multi
        enemy:AddPoison(EntityRef(player), 60 * multi, 3 + player.Damage / 2 * (multi - 1))
    end    
end)