local lastDrowsyStacks = 0

local function OnUpdate()
    local drowsyCrushed = PillCrusher:GetCrushedPillNum(PillEffect.PILLEFFECT_IM_DROWSY)
    local excitedCrushed = PillCrusher:GetCrushedPillNum(PillEffect.PILLEFFECT_IM_EXCITED)

    local drowsyStacks = math.max(0, drowsyCrushed - excitedCrushed)

    if drowsyStacks > lastDrowsyStacks then
        for i = 0, Game():GetNumPlayers()-1, 1 do
            local player = Game():GetPlayer(i)
            player:AddSlowing(EntityRef(player), 1, 0.8 / drowsyStacks,Color(1,1,1,1))
        end
    elseif drowsyStacks < lastDrowsyStacks then
        for i = 0, Game():GetNumPlayers()-1, 1 do
            local player = Game():GetPlayer(i)
            player:ClearEntityFlags(EntityFlag.FLAG_SLOW)
            player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
		    player:EvaluateItems()
        end
    end

    lastDrowsyStacks = drowsyStacks
end
PillCrusher:AddCallback(ModCallbacks.MC_POST_UPDATE, OnUpdate)


local function OnCache(_, player)
    local drowsyCrushed = PillCrusher:GetCrushedPillNum(PillEffect.PILLEFFECT_IM_DROWSY)
    local excitedCrushed = PillCrusher:GetCrushedPillNum(PillEffect.PILLEFFECT_IM_EXCITED)

    local drowsyStacks = math.max(0, drowsyCrushed - excitedCrushed)
	player.MaxFireDelay = player.MaxFireDelay * (1 + 0.25 * drowsyStacks)
end
PillCrusher:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, OnCache, CacheFlag.CACHE_FIREDELAY)


PillCrusher:AddPillCrusherEffect(PillEffect.PILLEFFECT_IM_DROWSY, "I'm drowsy...",
function ()
    for i = 0, Game():GetNumPlayers()-1, 1 do
        local player = Game():GetPlayer(i)
        player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
		player:EvaluateItems()
    end
end)