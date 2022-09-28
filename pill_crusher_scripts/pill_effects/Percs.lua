local Helpers = require("pill_crusher_scripts.Helpers")


local function HalfDamage(_, entity, damage, flags, source, cd)
	if entity:ToPlayer() then return nil end
	local data = Helpers.GetData(entity)
    if not data then return end

    local addictedCrushed = PillCrusher:GetCrushedPillNum(PillEffect.PILLEFFECT_ADDICTED)
    local perksCrushed = PillCrusher:GetCrushedPillNum(PillEffect.PILLEFFECT_PERCS)

    if perksCrushed < addictedCrushed then return end

    if not data.HalfDamage then return end

    if not data.TookHD then
        data.TookHD = true
        entity:TakeDamage(damage/data.HalfDamage, flags, source, cd)
        return false
    else
        data.TookHD = nil
    end
end
PillCrusher:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, HalfDamage)


PillCrusher:AddPillCrusherEffect(PillEffect.PILLEFFECT_PERCS, "Percs!",
function (_, _, _, isHorse)
    for _,enemy in ipairs(Helpers.GetEnemies(false)) do
        local data = Helpers.GetData(enemy)
		data.HalfDamage = isHorse and 2 or 1.3
    end
end)