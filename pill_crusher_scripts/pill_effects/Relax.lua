local Helpers = require("pill_crusher_scripts.Helpers")


local function Relax(_, npc)
	local data = Helpers.GetData(npc)
    if not data or not data.RelaxTimer then return end

    if data.RelaxTimer % 10 == 0 then
        local bomb = Isaac.Spawn(EntityType.ENTITY_POOP, 0, 0, npc.Position, Vector.Zero, npc)
        bomb:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
    end

    data.RelaxTimer = data.RelaxTimer - 1
    if data.RelaxTimer <= 0 then
        data.RelaxTimer = nil
    end
end
PillCrusher:AddCallback(ModCallbacks.MC_NPC_UPDATE, Relax)


PillCrusher:AddPillCrusherEffect(PillEffect.PILLEFFECT_RELAX, "Re-Lax",
function (_, rng, _, isHorse)
    for _,enemy in ipairs(Helpers.GetEnemies(true)) do
        local mul = isHorse and 3 or 1
        local data = Helpers.GetData(enemy)
        data.RelaxTimer = 90 * mul + rng:RandomInt(10)
    end
end)