PillCrusher:AddPillCrusherEffect(PillEffect.PILLEFFECT_SPEED_UP, "Speed Up",
function ()
    local room = Game():GetRoom()
    room:SetBrokenWatchState(2)
end)