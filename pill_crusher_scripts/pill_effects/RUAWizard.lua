local Helpers = require("pill_crusher_scripts.Helpers")


PillCrusher:AddPillCrusherEffect(PillEffect.PILLEFFECT_WIZARD, "R U a Wizard?",
function (_, rng, _, isHorse)
    local fakeTargets = {}
    local mult = isHorse and 2 or 1
    for _ = 1, 5, 1 do
        local fakeTarget = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.WOMB_TELEPORT, 0, Isaac.GetRandomPosition(), Vector(8, 0):Rotated(rng:RandomInt(360)), nil)
        fakeTarget = fakeTarget:ToEffect()
        fakeTarget.Visible = false
        fakeTarget.Timeout = 90 * mult
        fakeTargets[#fakeTargets+1] = fakeTarget
    end

    for _,enemy in ipairs(Helpers.GetEnemies(false, true)) do
        local chosenTarget = fakeTargets[rng:RandomInt(#fakeTargets)+1]
        enemy.Target = chosenTarget
    end
end)