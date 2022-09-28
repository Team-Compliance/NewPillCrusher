local Helpers = require("pill_crusher_scripts.Helpers")

PillCrusher:AddPillCrusherEffect(PillEffect.PILLEFFECT_BAD_TRIP, "Bad Trip",
function (player, _, _, isHorse)
    for _,enemy in ipairs(Helpers.GetEnemies(false)) do
        local mult = isHorse and 2 or 1
        enemy:TakeDamage(enemy.HitPoints * 0.1 * mult, DamageFlag.DAMAGE_LASER, EntityRef(player),0)
    end
end)