local PickupUpgrades = {
    {Variant = PickupVariant.PICKUP_COIN, NewSubtype = CoinSubType.COIN_GOLDEN},
    {Variant = PickupVariant.PICKUP_KEY, NewSubtype = KeySubType.KEY_GOLDEN},
    {Variant = PickupVariant.PICKUP_BOMB, NewSubtype = BombSubType.BOMB_GOLDEN},
    {Variant = PickupVariant.PICKUP_LIL_BATTERY, NewSubtype = BatterySubType.BATTERY_GOLDEN},
    {Variant = PickupVariant.PICKUP_PILL, NewSubtype = PillColor.PILL_GOLD},
}

local checkForPrize = false


---@param pickup EntityPickup
local function DuplicateOrUpgrade(pickup, stacks)
    local rng = RNG()
    rng:SetSeed(pickup.InitSeed, 35)

    local unableToMorph = false
    if rng:RandomInt(100) < math.min(5 + stacks, 10) then
        local newSubtype

        for _, pickupUpgrade in ipairs(PickupUpgrades) do
            if pickup.Variant == pickupUpgrade.Variant then
                newSubtype = pickupUpgrade.NewSubtype
            end
        end

        if pickup.Variant == PickupVariant.PICKUP_TRINKET then
            newSubtype = pickup.SubType | TrinketType.TRINKET_GOLDEN_FLAG
        end

        if not newSubtype then
            unableToMorph = true
        else
            pickup:Morph(pickup.Type, pickup.Variant, newSubtype, true)
            return
        end
    end

    if unableToMorph or rng:RandomInt(100) < stacks * 10 then
        local duplicated = Isaac.Spawn(pickup.Type, pickup.Variant, pickup.SubType, pickup.Position, pickup.Velocity, pickup.SpawnerEntity)

        local rotation = rng:RandomInt(120) - 60
        duplicated.Velocity = duplicated.Velocity:Rotated(rotation)
    end
end


local function OnUpdate()
    local luckUpCrushed = PillCrusher:GetCrushedPillNum(PillEffect.PILLEFFECT_LUCK_UP)
    local luckDownCrushed = PillCrusher:GetCrushedPillNum(PillEffect.PILLEFFECT_LUCK_DOWN)

    local luckUpStacks = math.max(0, luckUpCrushed - luckDownCrushed)

    if luckUpStacks == 0 then return end

    if checkForPrize then
        local pickups = Isaac.FindByType(EntityType.ENTITY_PICKUP)

        for _, pickup in ipairs(pickups) do
            if pickup.FrameCount == 0 then
                DuplicateOrUpgrade(pickup:ToPickup(), luckUpStacks)
            end
        end

        checkForPrize = false
    end

    local slots = Isaac.FindByType(EntityType.ENTITY_SLOT)

    for _, slot in ipairs(slots) do
        local slotSpr = slot:GetSprite()

        if slotSpr:IsEventTriggered("Prize") then
            checkForPrize = true
        end
    end
end
PillCrusher:AddCallback(ModCallbacks.MC_POST_UPDATE, OnUpdate)


PillCrusher:AddPillCrusherEffect(PillEffect.PILLEFFECT_LUCK_UP, "Luck Up")