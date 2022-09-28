local Helpers = require("pill_crusher_scripts.Helpers")


local function DoubleDamage(_, entity, damage, flags, source, cd)
	if entity:ToPlayer() then return nil end
	local data = Helpers.GetData(entity)
    if not data then return end

    local addictedCrushed = PillCrusher:GetCrushedPillNum(PillEffect.PILLEFFECT_ADDICTED)
    local perksCrushed = PillCrusher:GetCrushedPillNum(PillEffect.PILLEFFECT_PERCS)

    if addictedCrushed < perksCrushed then return end

    if not data.DoubleDamage then return end

    if not data.TookDD then
        data.TookDD = true
        entity:TakeDamage(damage*data.DoubleDamage, flags, source, cd)
        return false
    else
        data.TookDD = nil
    end
end
PillCrusher:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, DoubleDamage)


PillCrusher:AddPillCrusherEffect(PillEffect.PILLEFFECT_ADDICTED, "Addicted!",
function (_, _, _, isHorse)
    for _,enemy in ipairs(Helpers.GetEnemies(false)) do
        local data = Helpers.GetData(enemy)
		data.DoubleDamage = isHorse and 2 or 1.3
    end
end)