local Helpers = require("pill_crusher_scripts.Helpers")


local SpecialHearts = {
    {type = 10, variant = 3, heart = HeartSubType.HEART_ROTTEN},
    {type = 252, variant = 0, heart = HeartSubType.HEART_BLACK},
    {type = 299, variant = 0, heart = HeartSubType.HEART_GOLDEN},
    {type = 850, variant = 0, heart = HeartSubType.HEART_ROTTEN},
    {type = 850, variant = 1, heart = HeartSubType.HEART_ROTTEN},
    {type = 850, variant = 2, heart = HeartSubType.HEART_ROTTEN},
    {type = 912, variant = 20, heart = HeartSubType.HEART_ROTTEN},
    {type = 917, variant = 1, heart = HeartSubType.HEART_SOUL},
    {type = 889, variant = 0, heart = HeartSubType.HEART_BONE},
    {type = 25, variant = 4, heart = HeartSubType.HEART_BONE},
    {type = 861, variant = 0, heart = HeartSubType.HEART_ROTTEN},
    {type = 38, variant = 1, heart = HeartSubType.HEART_SOUL},
    {type = 259, variant = 0, heart = HeartSubType.HEART_BLACK},
    {type = 883, variant = 0, heart = HeartSubType.HEART_BLACK},
    {type = 865, variant = 0, heart = HeartSubType.HEART_ROTTEN},
    {type = 862, variant = 0, heart = HeartSubType.HEART_ROTTEN},
    {type = 41, variant = 4, heart = HeartSubType.HEART_BLACK},
    {type = 53, variant = 1, heart = HeartSubType.HEART_BLACK},
    {type = 55, variant = 2, heart = HeartSubType.HEART_SOUL},
    {type = 57, variant = 2, heart = HeartSubType.HEART_ROTTEN},
    {type = 60, variant = 2, heart = HeartSubType.HEART_ETERNAL},
    {type = 818, variant = 1, heart = HeartSubType.HEART_SOUL},
    {type = 86, variant = 0, heart = HeartSubType.HEART_GOLDEN},
    {type = 90, variant = 0, heart = HeartSubType.HEART_GOLDEN},
    {type = 830, variant = 0, heart = HeartSubType.HEART_BONE},
    {type = 831, variant = 0, heart = HeartSubType.HEART_ROTTEN},
    {type = 831, variant = 10, heart = HeartSubType.HEART_ROTTEN},
    {type = 888, variant = 0, heart = HeartSubType.HEART_BLACK},
    {type = 287, variant = 0, heart = HeartSubType.HEART_BONE},
    {type = 225, variant = 0, heart = HeartSubType.HEART_BLACK},
    {type = 227, variant = 0, heart = HeartSubType.HEART_BONE},
    {type = 227, variant = 1, heart = HeartSubType.HEART_BONE},
    {type = 277, variant = 0, heart = HeartSubType.HEART_BONE},
    {type = 841, variant = 0, heart = HeartSubType.HEART_BONE},
    {type = 841, variant = 1, heart = HeartSubType.HEART_BONE},
    {type = 251, variant = 0, heart = HeartSubType.HEART_BLACK},
    {type = 805, variant = 0, heart = HeartSubType.HEART_SOUL},
    {type = 891, variant = 1, heart = HeartSubType.HEART_BLACK},
    {type = 873, variant = 0, heart = HeartSubType.HEART_ROTTEN},
    {type = 881, variant = 1, heart = HeartSubType.HEART_BONE},
    {type = 293, variant = 0, heart = HeartSubType.HEART_GOLDEN},
    {type = 293, variant = 1, heart = HeartSubType.HEART_GOLDEN},
    {type = 293, variant = 2, heart = HeartSubType.HEART_GOLDEN},
    {type = 293, variant = 3, heart = HeartSubType.HEART_GOLDEN},
}


PillCrusher:AddPillCrusherEffect(PillEffect.PILLEFFECT_HEMATEMESIS, "Hematemesis",
function (_, rng, _, isHorse)
    for _,enemy in ipairs(Helpers.GetEnemies(false)) do
        enemy:AddEntityFlags(EntityFlag.FLAG_BLEED_OUT)
        if rng:RandomInt(100) < 30 then
            local subtype = HeartSubType.HEART_FULL

            if rng:RandomInt(100) < 40 or isHorse then
                for _, specialHeartEntity in ipairs(SpecialHearts) do
                    if enemy.Type == specialHeartEntity.type and enemy.Variant == specialHeartEntity.variant then
                        subtype = specialHeartEntity.heart
                        break
                    end
                end
            end

            local num = rng:RandomInt(2) + 1
            if isHorse then num = rng:RandomInt(3) + 2 end

            for _ = 1, num do
                local spawningPos = Game():GetRoom():FindFreePickupSpawnPosition(enemy.Position)

                Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, subtype, spawningPos,Vector.Zero,nil)
            end
        end
    end
end)