local Helpers = require("pill_crusher_scripts.Helpers")


function IsCircleIntersectingWithRectangle(RectPos, RectSize, CirclePos, CircleSize)
    local circleDistanceX = math.abs(CirclePos.X - RectPos.X)
    local circleDistanceY = math.abs(CirclePos.Y - RectPos.Y)

    if circleDistanceX > RectSize.X/2 + CircleSize + 0.1 or
    circleDistanceY > RectSize.Y/2 + CircleSize + 0.1  then
        return false
    elseif circleDistanceX <= 20 or circleDistanceY <= 20 then
        return true
    else
        local cornerDistanceSq = (circleDistanceX - 20)^2 + (circleDistanceY - 20)^2
        return cornerDistanceSq <= (CircleSize + 0.1)^2
    end
end


---@param entity Entity
---@return GridEntity[]
function GetCloseGridEntities(entity)
    local room = Game():GetRoom()
    local gridEntities = {}

    for x = -1, 1, 1 do
        for y = -1, 1, 1 do
            if x~= 0 or y~=0 then
                local gridPosition = entity.Position + Vector(x*40, y*40)
                ---@diagnostic disable-next-line: param-type-mismatch
                local gridEntity = room:GetGridEntityFromPos(gridPosition)

                if gridEntity and IsCircleIntersectingWithRectangle(gridEntity.Position, Vector(40, 40), entity.Position, entity.Size) then
                    gridEntities[#gridEntities+1] = gridEntity
                end
            end
        end
    end

    return gridEntities
end


---@param npc EntityNPC
local function OnNPCUpdate(_, npc)
    local data = Helpers.GetData(npc)
    if not data then return end
    if not data.LargerTimer then return end

    data.LargerTimer = data.LargerTimer - 1

    for _, gridEntity in ipairs(GetCloseGridEntities(npc)) do
        gridEntity:Destroy(true)
    end

    if data.LargerTimer ~= 0 then return end

    data.LargerTimer = nil
    data.InitialScale = nil
    npc:ClearEntityFlags(EntityFlag.FLAG_SHRINK)
    npc.Scale = data.InitialScale
end
PillCrusher:AddCallback(ModCallbacks.MC_NPC_UPDATE, OnNPCUpdate)


PillCrusher:AddPillCrusherEffect(PillEffect.PILLEFFECT_LARGER, "One makes you larger",
function (_, _, _, isHorse)
    for _,enemy in ipairs(Helpers.GetEnemies(false)) do
        local data = Helpers.GetData(enemy)
        local mult = isHorse and 2 or 1

        ---@diagnostic disable-next-line: need-check-nil
        if not data.InitialScale then
            data.InitialScale = enemy.Scale
        end
        data.LargerTimer = 150 * mult
		enemy.Scale = enemy.Scale * 1.3
    end
end)