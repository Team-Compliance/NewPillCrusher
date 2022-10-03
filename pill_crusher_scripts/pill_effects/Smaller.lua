local Helpers = require("pill_crusher_scripts.Helpers")


---@param npc EntityNPC
local function OnNPCUpdate(_, npc)
    local data = Helpers.GetData(npc)
    if not data then return end
    if not data.ShrinkDuration then return end

    data.ShrinkDuration = data.ShrinkDuration - 1
    if data.ShrinkDuration % 2 == 1 then
        npc:AddShrink(EntityRef(data.ShrinkPlayer), 2)
    end

    if data.ShrinkDuration ~= 0 then return end

    data.ShrinkDuration = nil
    npc:ClearEntityFlags(EntityFlag.FLAG_SHRINK)
end
PillCrusher:AddCallback(ModCallbacks.MC_NPC_UPDATE, OnNPCUpdate)


PillCrusher:AddPillCrusherEffect(PillEffect.PILLEFFECT_SMALLER, "One makes you small",
function (player, _, _, isHorse)
    for _, enemy in ipairs(Helpers.GetEnemies(false)) do
        local mult = isHorse and 2 or 1
        local data = Helpers.GetData(enemy)
        data.ShrinkDuration = 150 * mult
        data.ShrinkPlayer = player
        enemy:AddShrink(EntityRef(player), 2)
    end
end)