local Helpers = require("pill_crusher_scripts.Helpers")


local function ArmorDamage(_, entity, amount, flags, source, cd)
	if entity:ToPlayer() then return end

	local data = Helpers.GetData(entity)
	if not data or not data.Armor then return end

    if data.Armor >= amount then
        data.Armor = data.Armor - amount
    else
        local leftover = amount - data.Armor
        data.Armor = 0
        entity:TakeDamage(leftover, flags, source, cd)
    end

    if data.Armor == 0 then data.Armor = nil end

    return false
end
PillCrusher:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, ArmorDamage)


local function BallsOfSteelArmorIndicator(_, npc)
	local data = Helpers.GetData(npc)
	if not data or not data.Armor then return end

    local color = Color(1, 1, 1)
    color:SetColorize(0, 0, 0.6, 0.35)
    npc:GetSprite().Color = color
end
PillCrusher:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, BallsOfSteelArmorIndicator)


PillCrusher:AddPillCrusherEffect(PillEffect.PILLEFFECT_BALLS_OF_STEEL, "Balls Of Steel",
function (_, _, _, isHorse)
    for _,enemy in ipairs(Helpers.GetEnemies(false)) do
        local mult = isHorse and 1.5 or 3
        local data = Helpers.GetData(enemy)
        data.Armor = enemy.MaxHitPoints / mult
    end
end)