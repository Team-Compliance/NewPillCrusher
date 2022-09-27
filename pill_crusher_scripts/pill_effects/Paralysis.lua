local Helpers = require("pill_crusher_scripts.Helpers")


PillCrusher:AddPillCrusherEffect(PillEffect.PILLEFFECT_PARALYSIS, "Paralysis",
function (player, rng, _, isHorse)
    for _,enemy in ipairs(Helpers.GetEnemies(false)) do
        local mult = isHorse and 2 or 1
        enemy:AddFreeze(EntityRef(player), rng:RandomInt(30) + 60 * mult)
    end
end)