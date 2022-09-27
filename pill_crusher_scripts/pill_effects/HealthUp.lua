local Helpers = require("pill_crusher_scripts.Helpers")

PillCrusher:AddPillCrusherEffect(PillEffect.PILLEFFECT_HEALTH_UP, "Health Up",
function (_, _, _, isHorse)
    for _,enemy in ipairs(Helpers.GetEnemies(false)) do
        local mult = isHorse and 2 or 1
        enemy.MaxHitPoints = enemy.MaxHitPoints + 15 * mult
        enemy.HitPoints = enemy.HitPoints + 15 * mult
    end
end)