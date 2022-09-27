local Helpers = require("pill_crusher_scripts.Helpers")


local function FliesOnDeath(_, entity)
	local data = Helpers.GetData(entity)
    if not data then return end
	if not data.SpawnFliesOnDeath then return end

    for _ = 1, data.SpawnFliesOnDeath.Fly do
        local fly = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_FLY, 0, entity.Position, Vector.Zero, data.SpawnFliesOnDeath.Parent)
        fly:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
    end
end
PillCrusher:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, FliesOnDeath)


PillCrusher:AddPillCrusherEffect(PillEffect.PILLEFFECT_FRIENDS_TILL_THE_END, "Friends Till The End!",
function (player, rng, _, isHorse)
    for _,enemy in ipairs(Helpers.GetEnemies(true)) do
        local data = Helpers.GetData(enemy)
        data.SpawnFliesOnDeath = { Fly = isHorse and rng:RandomInt(3)+1 or 1, Parent = player}
    end
end)