local Helpers = require("pill_crusher_scripts.Helpers")


local function Relax(_, npc)
	local data = Helpers.GetData(npc)
    if not data or not data.RelaxTimer then return end

    if data.RelaxTimer % 10 == 0 then
        local poop = Isaac.Spawn(EntityType.ENTITY_POOP, 0, 0, npc.Position, Vector.Zero, npc)
        poop:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        poop:GetData().IgnoreCollisionWithParent = true
    end

    data.RelaxTimer = data.RelaxTimer - 1
    if data.RelaxTimer <= 0 then
        data.RelaxTimer = nil
    end
end
PillCrusher:AddCallback(ModCallbacks.MC_NPC_UPDATE, Relax)


local function BombCollision(_, poop, collider)
    if poop.FrameCount > 5 then return end
    if not poop:GetData().IgnoreCollisionWithParent then return end

    if GetPtrHash(poop.SpawnerEntity) == GetPtrHash(collider) then
        return true
    end
end
PillCrusher:AddCallback(ModCallbacks.MC_PRE_NPC_COLLISION, BombCollision, EntityType.ENTITY_POOP)


PillCrusher:AddPillCrusherEffect(PillEffect.PILLEFFECT_RELAX, "Re-Lax",
function (_, rng, _, isHorse)
    for _,enemy in ipairs(Helpers.GetEnemies(false)) do
        local mul = isHorse and 3 or 1
        local data = Helpers.GetData(enemy)
        data.RelaxTimer = 90 * mul + rng:RandomInt(10)
    end
end)