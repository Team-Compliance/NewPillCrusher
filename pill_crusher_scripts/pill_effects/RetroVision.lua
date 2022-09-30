PillCrusher:AddPillCrusherEffect(PillEffect.PILLEFFECT_RETRO_VISION, "Retro Vision",
function (player, _, _, _, pillColor)
    ---@diagnostic disable-next-line: param-type-mismatch
    player:UsePill(PillEffect.PILLEFFECT_RETRO_VISION, pillColor, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
end)