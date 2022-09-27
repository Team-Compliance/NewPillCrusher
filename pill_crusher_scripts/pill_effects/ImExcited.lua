local lastExcitedStacks = 0
local lastBrokenWatchState = 0

local function OnUpdate()
    local drowsyCrushed = PillCrusher:GetCrushedPillNum(PillEffect.PILLEFFECT_IM_DROWSY)
    local excitedCrushed = PillCrusher:GetCrushedPillNum(PillEffect.PILLEFFECT_IM_EXCITED)

    local excitedStacks = math.max(0, excitedCrushed - drowsyCrushed)

    if excitedStacks < lastExcitedStacks then
        local room = Game():GetRoom()

        lastBrokenWatchState = room:GetBrokenWatchState()
        room:SetBrokenWatchState(1)
    elseif excitedStacks > lastExcitedStacks then
        local room = Game():GetRoom()

        room:SetBrokenWatchState(lastBrokenWatchState)
    end

    lastExcitedStacks = excitedStacks
end
PillCrusher:AddCallback(ModCallbacks.MC_POST_UPDATE, OnUpdate)


PillCrusher:AddPillCrusherEffect(PillEffect.PILLEFFECT_IM_EXCITED, "I'm Excited!!!")