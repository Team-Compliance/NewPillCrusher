PillCrusher:AddPillCrusherEffect(PillEffect.PILLEFFECT_SEE_FOREVER, "I can see forever!",
function (player)
    ---@diagnostic disable-next-line: param-type-mismatch
    player:UseCard(Card.CARD_SOUL_CAIN,UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
end)