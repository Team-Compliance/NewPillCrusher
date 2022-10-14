local Helpers = require("pill_crusher_scripts.Helpers")

local IsAmnesiaPillCrusherActivated = false
local IsAmnesiaPillCrusherHorsePilled = false
local AmnesiaSafeTimer = 0


local function OnUpdate()
    if not IsAmnesiaPillCrusherActivated then return end
    if AmnesiaSafeTimer <= 0 then return end
    AmnesiaSafeTimer = AmnesiaSafeTimer - 1
end
PillCrusher:AddCallback(ModCallbacks.MC_POST_UPDATE, OnUpdate)


local function OnNPCUpdate(_, npc)
    if not IsAmnesiaPillCrusherActivated then return end
    local data = Helpers.GetData(npc)
    if not data then return end
    if not data.IsAmnesiaCrushed then return end

    npc:AddEntityFlags(EntityFlag.FLAG_CONFUSION)
end
PillCrusher:AddCallback(ModCallbacks.MC_NPC_UPDATE, OnNPCUpdate)


---@param player EntityPlayer
local function IsPlayerPressingShootingInputs(player)
    local controllerIndex = player.ControllerIndex

    return Input.IsActionPressed(ButtonAction.ACTION_SHOOTLEFT, controllerIndex) or Input.IsActionPressed(ButtonAction.ACTION_SHOOTRIGHT, controllerIndex) or
    Input.IsActionPressed(ButtonAction.ACTION_SHOOTUP, controllerIndex) or Input.IsActionPressed(ButtonAction.ACTION_SHOOTDOWN, controllerIndex)
end


local function OnPlayerUpdate(_, player)
    if not IsAmnesiaPillCrusherActivated then return end
    if AmnesiaSafeTimer > 0 then return end
    if not IsPlayerPressingShootingInputs(player) then return end

    for _, enemy in ipairs(Helpers.GetEnemies(false, true)) do
        enemy:ClearEntityFlags(EntityFlag.FLAG_CONFUSION)
        Helpers.GetData(enemy).IsAmnesiaCrushed = nil
    end

    if IsAmnesiaPillCrusherHorsePilled then
        for _, enemy in ipairs(Isaac.FindInRadius(player.Position, 120, EntityPartition.ENEMY)) do
            if enemy:IsVulnerableEnemy() then
                enemy:TakeDamage(15, 0, EntityRef(player), -1)
            end
        end
    end

    IsAmnesiaPillCrusherActivated = false
    IsAmnesiaPillCrusherHorsePilled = false
end
PillCrusher:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, OnPlayerUpdate)


PillCrusher:AddPillCrusherEffect(PillEffect.PILLEFFECT_AMNESIA, "Amnesia",
function (player, _, _, isHorse)
    IsAmnesiaPillCrusherActivated = true
    IsAmnesiaPillCrusherHorsePilled = isHorse
    AmnesiaSafeTimer = 30

    for _, enemy in ipairs(Helpers.GetEnemies(false, true)) do
        enemy:AddConfusion(EntityRef(player), 10, false)
        Helpers.GetData(enemy).IsAmnesiaCrushed = true
    end
end)