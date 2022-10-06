PillCrusher:AddPillCrusherEffect(PillEffect.PILLEFFECT_SPEED_DOWN, "Speed Down",
function (player)
    ---@diagnostic disable-next-line: param-type-mismatch
    player:UsePill(PillEffect.PILLEFFECT_IM_DROWSY, PillColor.PILL_NULL, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
end)