local Helpers = require("pill_crusher_scripts.Helpers")


local function Diarrhea(_, npc)
	local data = Helpers.GetData(npc)
    if not data or not data.DiarrheaTimer then return end

    if data.DiarrheaTimer % 15 == 0 then
        local bomb = Isaac.Spawn(EntityType.ENTITY_BOMB, BombVariant.BOMB_TROLL, 0, npc.Position, Vector.Zero, npc)
        bomb:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        bomb:GetData().IgnoreCollisionWithParent = true
    end

    data.DiarrheaTimer = data.DiarrheaTimer - 1
    if data.DiarrheaTimer <= 0 then
        data.DiarrheaTimer = nil
    end
end
PillCrusher:AddCallback(ModCallbacks.MC_NPC_UPDATE, Diarrhea)


local function BombCollision(_, bomb, collider)
    if bomb.FrameCount > 5 then return end
    if not bomb:GetData().IgnoreCollisionWithParent then return end

    if GetPtrHash(bomb.SpawnerEntity) == GetPtrHash(collider) then
        return true
    end
end
PillCrusher:AddCallback(ModCallbacks.MC_PRE_BOMB_COLLISION, BombCollision)


PillCrusher:AddPillCrusherEffect(PillEffect.PILLEFFECT_EXPLOSIVE_DIARRHEA, "Explosive Diarrhea",
function (_, rng, _, isHorse)
    if isHorse then
        local room = Game():GetRoom()
        local pos = room:GetCenterPos()
        room:MamaMegaExplosion(pos)
        return
    end

    for _,enemy in ipairs(Helpers.GetEnemies(true)) do
        local data = Helpers.GetData(enemy)
        data.DiarrheaTimer = 90 + rng:RandomInt(10)
    end
end)