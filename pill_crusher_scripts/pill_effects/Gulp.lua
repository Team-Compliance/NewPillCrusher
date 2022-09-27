PillCrusher:AddPillCrusherEffect(PillEffect.PILLEFFECT_GULP, "Gulp!",
function (player, rng, _, isHorse)
    local trinket1 = player:GetTrinket(0)
    local trinket2 = player:GetTrinket(1)
    if trinket1 ~= 0 then player:TryRemoveTrinket(trinket1) end
    if trinket2 ~= 0 then player:TryRemoveTrinket(trinket2) end

    for _, trinket in ipairs(Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET)) do
        local goldFlag = 0
        if (isHorse and rng:RandomInt(2) == 1) then
            goldFlag = TrinketType.TRINKET_GOLDEN_FLAG
        end

        ---@diagnostic disable-next-line: param-type-mismatch
        player:AddTrinket(trinket.SubType | goldFlag)
        player:UseActiveItem(CollectibleType.COLLECTIBLE_SMELTER,false,false,true,false)

        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, trinket.Position,Vector.Zero,nil)
        trinket:Remove()
    end

    if trinket1 ~= 0 then player:AddTrinket(trinket1) end
    if trinket2 ~= 0 then player:AddTrinket(trinket2) end
end)