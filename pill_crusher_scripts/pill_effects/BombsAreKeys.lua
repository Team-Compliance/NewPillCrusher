PillCrusher:AddPillCrusherEffect(PillEffect.PILLEFFECT_BOMBS_ARE_KEYS, "Bombs Are Keys",
function (_, _, _, isHorse)
    local bombspickup = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BOMB)
    local keyspickup = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_KEY)
    local keytears = Isaac.FindByType(EntityType.ENTITY_TEAR)
    local bombs = Isaac.FindByType(EntityType.ENTITY_BOMB)

    for _,bomb in ipairs(bombspickup) do
        bomb = bomb:ToPickup()
        local subtype = KeySubType.KEY_NORMAL
        if bomb.SubType == BombSubType.BOMB_DOUBLEPACK or isHorse then
            subtype = KeySubType.KEY_DOUBLEPACK
        end
        if bomb.SubType == BombSubType.BOMB_GOLDEN or bomb.SubType == BombSubType.BOMB_GOLDENTROLL then
            subtype = KeySubType.KEY_GOLDEN
        end
        bomb:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_KEY, subtype, true, true)
    end

    for _,key in ipairs(keyspickup) do
        key = key:ToPickup()
        local subtype = BombSubType.BOMB_NORMAL
        if key.SubType == KeySubType.KEY_DOUBLEPACK or isHorse then
            subtype = BombSubType.BOMB_DOUBLEPACK
        end
        if key.SubType == KeySubType.KEY_GOLDEN then
            subtype = BombSubType.BOMB_GOLDEN
        end
        key:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BOMB, subtype, true, true)
    end

    for _,key in ipairs(keytears) do
        key = key:ToTear()
        if key.Variant == TearVariant.KEY or key.Variant == TearVariant.KEY_BLOOD then
            local subtype = BombSubType.BOMB_NORMAL
            if isHorse then
                subtype = BombSubType.BOMB_DOUBLEPACK
            end
            local bomb = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BOMB, subtype, key.Position, key.Velocity, nil)
            bomb:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
            key:Remove()
        end
    end

    for _,bomb in ipairs(bombs) do
        bomb = bomb:ToBomb()
        if bomb.Variant ~= BombVariant.BOMB_THROWABLE then
            local subtype = KeySubType.KEY_NORMAL
            if isHorse then
                subtype = KeySubType.KEY_DOUBLEPACK
            end
            if bomb.Variant == BombVariant.BOMB_GIGA or bomb.Variant == BombVariant.BOMB_ROCKET_GIGA then
                subtype = KeySubType.KEY_CHARGED
            end
            if bomb.Variant == BombVariant.BOMB_GOLDENTROLL then
                subtype = KeySubType.KEY_GOLDEN
            end
            local key = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_KEY, subtype, bomb.Position, bomb.Velocity, nil)
            key:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
            bomb:Remove()
        end
    end
end)