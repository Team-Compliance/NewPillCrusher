local Helpers = require("pill_crusher_scripts.Helpers")

PillCrusher:AddPillCrusherEffect(PillEffect.PILLEFFECT_HEALTH_DOWN, "Health Down",
function (_, _, _, isHorse)
    for _,enemy in ipairs(Helpers.GetEnemies(false)) do
        local mult = isHorse and 2 or 1
        enemy.MaxHitPoints = enemy.MaxHitPoints - math.min(15 * mult,enemy.MaxHitPoints / (2 - 0.5 * (-1 + mult)))
		enemy.HitPoints = enemy.HitPoints - math.min(15 * mult,enemy.HitPoints / (2 - 0.5 * (-1 + mult)))
    end
end)