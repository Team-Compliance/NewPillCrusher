local Helpers = require("pill_crusher_scripts.Helpers")


PillCrusher:AddPillCrusherEffect(PillEffect.PILLEFFECT_HEMATEMESIS, "Hematemesis",
function (_, rng)
    for _,enemy in ipairs(Helpers.GetEnemies(false)) do
        enemy:AddEntityFlags(EntityFlag.FLAG_BLEED_OUT)
        if rng:RandomInt(100) < 30 then
            for _ = 1, (rng:RandomInt(2) + 1) do
                local spawningPos = Game():GetRoom():FindFreePickupSpawnPosition(enemy.Position)
                Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_FULL, spawningPos,Vector.Zero,nil)
            end
        end
    end
end)