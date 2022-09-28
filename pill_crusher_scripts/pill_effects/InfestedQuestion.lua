local Helpers = require("pill_crusher_scripts.Helpers")


---@param entity Entity
local function SpidersOnDeath(_, entity)
	local data = Helpers.GetData(entity)
    if not data then return end
	if not data.SpawnSpidersIfSlowed then return end

    if entity:HasEntityFlags(EntityFlag.FLAG_SLOW) then
        ---@type EntityPlayer
        local player = data.SpawnSpidersIfSlowed.player
        local numSpiders = data.SpawnSpidersIfSlowed.num
        for _ = 1, numSpiders, 1 do
            player:AddBlueSpider(entity.Position)
        end
    end
end
PillCrusher:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, SpidersOnDeath)


PillCrusher:AddPillCrusherEffect(PillEffect.PILLEFFECT_INFESTED_QUESTION, "Infested?",
function (player, rng, _, isHorse)
    for _,enemy in ipairs(Helpers.GetEnemies(true)) do
        enemy:AddSlowing(EntityRef(player), 120, 1, Color(1, 1, 1, 1, 0.2, 0.2, 0.2))
        local data = Helpers.GetData(enemy)
        data.SpawnSpidersIfSlowed = {player = player, num = rng:RandomInt(3) + (isHorse and 3 or 1)}
    end
end)