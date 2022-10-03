PillCrusher:AddPillCrusherEffect(PillEffect.PILLEFFECT_RETRO_VISION, "Retro Vision",
function (_, _, _, isHorse)
    local num = isHorse and 90 or 30
    Game():AddPixelation(num * 30)
end)