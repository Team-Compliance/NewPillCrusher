local Helpers = require("pill_crusher_scripts.Helpers")

PillCrusher:AddPillCrusherEffect(PillEffect.PILLEFFECT_SMALLER, "One makes you small",
function (_, _, _, isHorse)
    for _,enemy in ipairs(Helpers.GetEnemies(false)) do
        local mult = isHorse and 1.5 or 1
		enemy.Scale = enemy.Scale / (1.3 * mult)
    end
end)