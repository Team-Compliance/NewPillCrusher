PillCrusher:AddPillCrusherEffect(PillEffect.PILLEFFECT_I_FOUND_PILLS, "I found pills",
function (player, _, _, _, pillColor)
    ---@diagnostic disable-next-line: param-type-mismatch
    player:UsePill(PillEffect.PILLEFFECT_I_FOUND_PILLS, pillColor, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
end)