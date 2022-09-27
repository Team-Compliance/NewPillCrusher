local Helpers = require("pill_crusher_scripts.Helpers")

PillCrusher:AddPillCrusherEffect(PillEffect.PILLEFFECT_PRETTY_FLY, "Pretty Fly",
function (_, _, _, isHorse)
    for _,enemy in ipairs(Helpers.GetEnemies(false)) do
        local mul = isHorse and 2 or 1

        for _ = 1, mul, 1 do
            local fly = Isaac.Spawn(EntityType.ENTITY_ETERNALFLY,0,0,enemy.Position,Vector.Zero,enemy):ToNPC()
            fly.Parent = enemy
        end
    end
end)