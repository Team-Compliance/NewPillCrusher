local Helpers = require("pill_crusher_scripts.Helpers")

PillCrusher:AddPillCrusherEffect(PillEffect.PILLEFFECT_FULL_HEALTH, "Full Health",
function ()
    for _,enemy in ipairs(Helpers.GetEnemies(false)) do
        enemy.HitPoints = enemy.MaxHitPoints
    end
end)