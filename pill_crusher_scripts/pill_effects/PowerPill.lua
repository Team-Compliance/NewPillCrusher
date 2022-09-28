local Helpers = require("pill_crusher_scripts.Helpers")


local function DoublePlayerDamage(_, player, damage, flags, source, cd)
    local data = Helpers.GetData(player)
    if not data then return end

    if data.IsDoubleDamage then return end
    if not data.DoubleDamageFrames then return end

    data.IsDoubleDamage = true
    player:TakeDamage(damage * 2, flags, source, cd)
    data.IsDoubleDamage = false

    return false
end
PillCrusher:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, DoublePlayerDamage, EntityType.ENTITY_PLAYER)


local function PlayerUpdate(_, player)
    local data = Helpers.GetData(player)
    if not data then return end

    if not data.DoubleDamageFrames then return end

    data.DoubleDamageFrames = data.DoubleDamageFrames - 1
    if data.DoubleDamageFrames <= 0 then data.DoubleDamageFrames = nil end
end
PillCrusher:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, PlayerUpdate)


PillCrusher:AddPillCrusherEffect(PillEffect.PILLEFFECT_POWER, "Power Pill!",
function (player, _, _, isHorse)
    local mult = isHorse and 2 or 1

    player:AddFear(EntityRef(player), 90 * mult)
    Helpers.GetData(player).DoubleDamageFrames = 90 * mult
end)