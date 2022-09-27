local Helpers = require("pill_crusher_scripts.Helpers")


PillCrusher:AddPillCrusherEffect(PillEffect.PILLEFFECT_QUESTIONMARK, "???",
function (player, _, _, isHorse)
    for _,enemy in ipairs(Helpers.GetEnemies(false)) do
        if not enemy:IsBoss() and not enemy:IsChampion() then
            local mult = isHorse and 2 or 1
			enemy:AddConfusion(EntityRef(player), 90 * mult, false)
        end
    end
end)