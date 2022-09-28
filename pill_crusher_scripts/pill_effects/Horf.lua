local Helpers = require("pill_crusher_scripts.Helpers")


PillCrusher:AddPillCrusherEffect(PillEffect.PILLEFFECT_HORF, "Horf",
function (_, rng)
    for _, enemy in ipairs(Helpers.GetEnemies(false)) do
        local randomX = rng:RandomFloat() * 2 - 1
        local randomY = rng:RandomFloat() * 2 - 1
        local dir = Vector(randomX, randomY)

        local params = ProjectileParams()

        params.BulletFlags = ProjectileFlags.EXPLODE
        params.FallingAccelModifier = 0.7
        params.FallingSpeedModifier = -10
        params.Scale = 1

        local projectileColor = Color(1, 1, 1)
        projectileColor:SetColorize(0, 1, 0, 1)

        params.Color = projectileColor

        enemy:FireProjectiles(enemy.Position, dir:Resized(4), 0, params)
    end
end)