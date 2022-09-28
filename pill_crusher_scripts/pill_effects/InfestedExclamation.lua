local GridPoopVariant = {
    NORMAL = 0,
    RED = 1,
    CORN = 2,
    GOLDEN = 3,
    RAINBOW = 4,
    BLACK = 5,
    WHITE = 6,
    GIGA = 7
}


local SpiderPerGridPoop = {
    [GridPoopVariant.NORMAL] = {
        Normal = {Type = EntityType.ENTITY_SPIDER, Variant = 0, SubType = 0},
        Horse = {Type = EntityType.ENTITY_BIGSPIDER, Variant = 0, SubType = 0}
    },
    [GridPoopVariant.RED] = {
        Normal = {Type = EntityType.ENTITY_SPIDER, Variant = 0, SubType = 0},
        Horse = {Type = EntityType.ENTITY_SPIDER_L2, Variant = 0, SubType = 0}
    },
    [GridPoopVariant.CORN] = {
        Normal = {Type = EntityType.ENTITY_SWARM_SPIDER, Variant = 0, SubType = 3},
        Horse = {Type = EntityType.ENTITY_SWARM_SPIDER, Variant = 0, SubType = 5}
    },
    [GridPoopVariant.BLACK] = {
        Normal = {Type = EntityType.ENTITY_SPIDER, Variant = 0, SubType = 0},
        Horse = {Type = EntityType.ENTITY_TICKING_SPIDER, Variant = 0, SubType = 0}
    },
    [GridPoopVariant.GIGA] = {
        Normal = {Type = EntityType.ENTITY_BIGSPIDER, Variant = 0, SubType = 0},
        Horse = {Type = EntityType.ENTITY_HOPPER, Variant = 1, SubType = 0}
    },
}


local function IsBadCornerOfGigaPoop(variant)
    return variant == 8 or variant == 9 or variant == 10
end


local EntityPoopVariant = {
    NORMAL = 0,
    GOLDEN = 1,
    STONE = 11,
    CORN = 12,
    BURNING = 13,
    STINKY = 14,
    BLACK = 15,
    HOLY = 16
}

local SpiderPerEntityPoop = {
    [EntityPoopVariant.NORMAL] = {
        Normal = {Type = EntityType.ENTITY_SPIDER, Variant = 0, SubType = 0},
        Horse = {Type = EntityType.ENTITY_BIGSPIDER, Variant = 0, SubType = 0}
    },
    [EntityPoopVariant.STONE] = {
        Normal = {Type = EntityType.ENTITY_ROCK_SPIDER, Variant = 0, SubType = 0},
        Horse = {Type = EntityType.ENTITY_ROCK_SPIDER, Variant = 0, SubType = 0}
    },
    [EntityPoopVariant.CORN] = {
        Normal = {Type = EntityType.ENTITY_SWARM_SPIDER, Variant = 0, SubType = 3},
        Horse = {Type = EntityType.ENTITY_SWARM_SPIDER, Variant = 0, SubType = 5}
    },
    [EntityPoopVariant.BLACK] = {
        Normal = {Type = EntityType.ENTITY_SPIDER, Variant = 0, SubType = 0},
        Horse = {Type = EntityType.ENTITY_TICKING_SPIDER, Variant = 0, SubType = 0}
    },
}


PillCrusher:AddPillCrusherEffect(PillEffect.PILLEFFECT_INFESTED_EXCLAMATION, "Infested!",
function (_, _, _, isHorse)
    local room = Game():GetRoom()

    local roomSize = room:GetGridSize()

    for i = 1, roomSize, 1 do
        local gridEntity = room:GetGridEntity(i)

        if gridEntity then
            if gridEntity:GetType() == GridEntityType.GRID_POOP and
            not IsBadCornerOfGigaPoop(gridEntity:GetVariant()) and
            gridEntity.State ~= 1000 then
                while gridEntity.State ~= 1000 do
                    gridEntity:Destroy(false)
                end

                local spiderPerPoop = SpiderPerGridPoop[gridEntity:GetVariant()]
                if not spiderPerPoop then spiderPerPoop = SpiderPerGridPoop[GridPoopVariant.NORMAL] end

                local spiderToSpawn = spiderPerPoop.Normal
                if isHorse then spiderToSpawn = spiderPerPoop.Horse end

                Isaac.Spawn(spiderToSpawn.Type, spiderToSpawn.Variant, spiderToSpawn.SubType, gridEntity.Position, Vector.Zero, nil)
            end
        end
    end

    for _, poop in ipairs(Isaac.FindByType(EntityType.ENTITY_POOP)) do
        if poop.HitPoints ~= 1 then
            poop.HitPoints = 1.2
            poop:Kill()

            local spiderPerPoop = SpiderPerEntityPoop[poop.Variant]
            if not spiderPerPoop then spiderPerPoop = SpiderPerEntityPoop[EntityPoopVariant.NORMAL] end

            local spiderToSpawn = spiderPerPoop.Normal
            if isHorse then spiderToSpawn = spiderPerPoop.Horse end

            Isaac.Spawn(spiderToSpawn.Type, spiderToSpawn.Variant, spiderToSpawn.SubType, poop.Position, Vector.Zero, nil)
        end
    end
end)