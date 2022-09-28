local Helpers = require("pill_crusher_scripts.Helpers")


function NoDamage(_, entity)
	if entity:ToPlayer() then return nil end
	local data = Helpers.GetData(entity)
    if not data then return end

    if not data.InvincivilityTimer then return end

    return false
end
PillCrusher:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, NoDamage)


---@param npc EntityNPC
function NPCUpdate(_, npc)
    local data = Helpers.GetData(npc)
    if not data then return end
    if not data.InvincivilityTimer then return end

    data.InvincivilityTimer = data.InvincivilityTimer - 1
    local color = data.InvincivilityColor

    if (color.R > 0 and color.B == 0) then
        color.R = color.R - 5
        color.G = color.G + 5
    end

    if (color.G > 0 and color.R == 0) then
        color.G = color.G - 5
        color.B = color.B + 5
    end

    if (color.B > 0 and color.G == 0) then
        color.R = color.R + 5
        color.B = color.B - 5
    end

    npc:SetColor(Color(1, 1, 1, 1, color.R/255 * 0.7, color.G/255 * 0.7, color.B/255 * 0.7), 2, -10, false, true)

    if data.InvincivilityTimer == 0 then data.InvincivilityTimer = nil end
end
PillCrusher:AddCallback(ModCallbacks.MC_NPC_UPDATE, NPCUpdate)


PillCrusher:AddPillCrusherEffect(PillEffect.PILLEFFECT_SUNSHINE, "Feels like I'm walking on sunshine!",
function (_, _, _, isHorse)
    for _, enemy in ipairs(Helpers.GetEnemies(false)) do
        local mul = isHorse and 2 or 1
        local data = Helpers.GetData(enemy)
        data.InvincivilityTimer = 90 * mul
        if enemy.InitSeed % 3 == 0 then
            data.InvincivilityColor = {R = 200, G = 0, B = 0}
        elseif enemy.InitSeed % 3 == 0 then
            data.InvincivilityColor = {R = 0, G = 200, B = 0}
        else
            data.InvincivilityColor = {R = 0, G = 0, B = 200}
        end
    end
end)