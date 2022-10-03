local Helpers = require("pill_crusher_scripts.Helpers")


---@param entity Entity
local function BatteriesOnDeath(_, entity)
    local data = Helpers.GetData(entity)
    if not data then return end
    if not data.HourEnergy then return end

    local subtype
    if entity:IsBoss() then
        --Boss or miniboss
        if data.WasHorseHourEnergy then
            subtype = BatterySubType.BATTERY_GOLDEN
        else
            subtype = BatterySubType.BATTERY_MEGA
        end
    elseif entity.HitPoints > 20 then
        --Bigger entity
        if data.WasHorseHourEnergy then
            subtype = BatterySubType.BATTERY_MEGA
        else
            subtype = BatterySubType.BATTERY_NORMAL
        end
    else
        --Smol entity
        if data.WasHorseHourEnergy then
            subtype = BatterySubType.BATTERY_NORMAL
        else
            subtype = BatterySubType.BATTERY_MICRO
        end
    end

    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_LIL_BATTERY, subtype, entity.Position, Vector.Zero, nil)
end
PillCrusher:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, BatteriesOnDeath)


PillCrusher:AddPillCrusherEffect(PillEffect.PILLEFFECT_48HOUR_ENERGY, "48 Hour Energy",
function (_, _, _, isHorse)
    for _,enemy in ipairs(Helpers.GetEnemies(false)) do
        local data = Helpers.GetData(enemy)
		data.HourEnergy = true
        data.WasHorseHourEnergy = isHorse
    end
end)