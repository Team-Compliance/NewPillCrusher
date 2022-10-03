local Helpers = require("pill_crusher_scripts.Helpers")

PillCrusher:AddPillCrusherEffect(PillEffect.PILLEFFECT_FULL_HEALTH, "Full Health",
function (_, _, _, isHorse)
    for _,enemy in ipairs(Helpers.GetEnemies(false)) do
        if isHorse then
            enemy.MaxHitPoints = enemy.MaxHitPoints + 15
        end
        enemy.HitPoints = enemy.MaxHitPoints
    end
end)