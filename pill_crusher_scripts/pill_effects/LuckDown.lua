local checkForPrize = true


local function OnUpdate()
    local luckUpCrushed = PillCrusher:GetCrushedPillNum(PillEffect.PILLEFFECT_LUCK_UP)
    local luckDownCrushed = PillCrusher:GetCrushedPillNum(PillEffect.PILLEFFECT_LUCK_DOWN)

    local luckDownStacks = math.max(0, luckDownCrushed - luckUpCrushed)

    if luckDownStacks == 0 then return end

    if checkForPrize then
        local pickups = Isaac.FindByType(EntityType.ENTITY_PICKUP)

        for _, pickup in ipairs(pickups) do
            if pickup.FrameCount == 0 then
                local rng = RNG()
                rng:SetSeed(pickup.InitSeed, 35)

                if rng:RandomInt(100) < 10 * luckDownStacks then
                    pickup:Remove()
                end
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


PillCrusher:AddPillCrusherEffect(PillEffect.PILLEFFECT_LUCK_DOWN, "Luck Down")