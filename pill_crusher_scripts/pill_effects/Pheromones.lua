local Helpers = require("pill_crusher_scripts.Helpers")


PillCrusher:AddPillCrusherEffect(PillEffect.PILLEFFECT_PHEROMONES, "Pheromones",
function (player, _, _, isHorse)
    for _, enemy in ipairs(Helpers.GetEnemies(false, true)) do
        if isHorse then
            enemy:AddEntityFlags(EntityFlag.FLAG_PERSISTENT | EntityFlag.FLAG_FRIENDLY)
        else
            enemy:AddCharmed(EntityRef(player), 180)
        end
    end
end)