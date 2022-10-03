local FriendlyDipSubtype = {
    NORMAL = 0,
    RED = 1,
    CORNY = 2,
    GOLD = 3,
    RAINBOW = 4,
    BLACK = 5,
    WHITE = 6,
    STONE = 12,
    FLAMING = 13,
    STINKY = 14,
    BROWNIE = 20
}


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

local FriendlyDipPerGridPoop = {
    [GridPoopVariant.NORMAL] = FriendlyDipSubtype.NORMAL,
    [GridPoopVariant.RED] = FriendlyDipSubtype.RED,
    [GridPoopVariant.CORN] = FriendlyDipSubtype.CORNY,
    [GridPoopVariant.GOLDEN] = FriendlyDipSubtype.GOLD,
    [GridPoopVariant.RAINBOW] = FriendlyDipSubtype.RAINBOW,
    [GridPoopVariant.BLACK] = FriendlyDipSubtype.BLACK,
    [GridPoopVariant.WHITE] = FriendlyDipSubtype.WHITE,
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

local FriendlyDipPerEntityPoop = {
    [EntityPoopVariant.NORMAL] = FriendlyDipSubtype.NORMAL,
    [EntityPoopVariant.GOLDEN] = FriendlyDipSubtype.GOLD,
    [EntityPoopVariant.STONE] = FriendlyDipSubtype.STONE,
    [EntityPoopVariant.CORN] = FriendlyDipSubtype.STONE,
    [EntityPoopVariant.BURNING] = FriendlyDipSubtype.FLAMING,
    [EntityPoopVariant.STINKY] = FriendlyDipSubtype.STINKY,
    [EntityPoopVariant.BLACK] = FriendlyDipSubtype.BLACK,
    [EntityPoopVariant.HOLY] = FriendlyDipSubtype.WHITE,
}


PillCrusher:AddPillCrusherEffect(PillEffect.PILLEFFECT_RELAX, "Re-Lax",
function (player, rng, _, isHorse)
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

                local dipSubtype = FriendlyDipPerGridPoop[gridEntity:GetVariant()]
                if not dipSubtype then dipSubtype = FriendlyDipSubtype.NORMAL end

                local num = rng:RandomInt(3) + 1
                if isHorse then num = num + 3 end

                for _ = 1, num, 1 do
                    player:AddFriendlyDip(dipSubtype, gridEntity.Position)
                end
            end
        end
    end

    for _, poop in ipairs(Isaac.FindByType(EntityType.ENTITY_POOP)) do
        if poop.HitPoints ~= 1 then
            poop.HitPoints = 1.2
            poop:Kill()

            local dipSubtype = FriendlyDipPerEntityPoop[poop.Variant]
            if not dipSubtype then dipSubtype = FriendlyDipSubtype.NORMAL end

            local num = rng:RandomInt(3) + 1
            if isHorse then num = num + 3 end

            for _ = 1, num, 1 do
                player:AddFriendlyDip(dipSubtype, poop.Position)
            end
        end
    end
end)