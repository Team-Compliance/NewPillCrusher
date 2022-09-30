PillCrusher = RegisterMod("Pill Crusher", 1);
local mod = PillCrusher
local json = require("json")
local Helpers = require("pill_crusher_scripts.Helpers")

CollectibleType.COLLECTIBLE_PILL_CRUSHER = Isaac.GetItemIdByName("Pill Crusher");

local BloomAmount = 0
local blurspeed = 0.07
local ActivateBloom = false

local PCDesc = "Gives a random {{Pill}} pill when picked up#Increase pill drop rate when held#Consumes currently held pill and applies an effect to the entire room depending on the type of pill"
local PCDescSpa = "Otorga una {{Pill}} pildora aleatoria al tomarlo#Las pildoras aparecen con mas frecuencia#Consume la pildora que posees y aplica un efecto a la sala, basado en la pildora"
local PCDescRu = "Дает случайную {{Pill}} пилюлю#Увеличивает шанс появления пилюль#Использует текущую пилюлю и накладывает зависимый от её типа эффект на всю комнату"
local PCDescPt_Br = "Gere uma pílula {{Pill}} aleatória quando pego#Almente a taxa de queda de pílulas# Consome a pílula segurada e aplique um efeito na sala inteira dependendo no tipo de pílula"

if MiniMapiItemsAPI then
	local frame = 1
	local pillcrusherIcon = Sprite()
	pillcrusherIcon:Load("gfx/ui/minimapitems/pillcrusher_icon.anm2", true)	
    	MiniMapiItemsAPI:AddCollectible(CollectibleType.COLLECTIBLE_PILL_CRUSHER, pillcrusherIcon, "CustomIconPillCrusher", frame)
end

if EID then
	EID:addCollectible(CollectibleType.COLLECTIBLE_PILL_CRUSHER, PCDesc, "Pill Crusher", "en_us")
	EID:addCollectible(CollectibleType.COLLECTIBLE_PILL_CRUSHER, PCDescSpa, "Triturador de Pildoras", "spa")
	EID:addCollectible(CollectibleType.COLLECTIBLE_PILL_CRUSHER, PCDescRu, "Дробилка пилюль", "ru")
	EID:addCollectible(CollectibleType.COLLECTIBLE_PILL_CRUSHER, PCDescPt_Br, "Triturador de Pílula", "pt_br")
end

--FF Helpers
mod.FFPillColours = {
    --Normal
    101,102,103,104,105,106,107,108,109,110,
    111,112,113,114,115,116,117,118,119,120,
    --Horse
    2149,2150,2151,2152,2153,2154,2155,2156,2157,2158,
    2159,2160,2161,2162,2163,2164,2165,2166,2167,2168
}
--Just lets you pass isFFPill[101] or somethin to test it
local isFFPill = {}
do
    for i = 1, #mod.FFPillColours do
        isFFPill[mod.FFPillColours[i]] = true
    end
end


--API
PillCrusher.CrushedPillEffects = {}
PillCrusher.CrushedPillsRoom = {}
PillCrusher.LastPillUsed = -1
PillCrusher.MonsterTeleTable = {}
PillCrusher.teleRooms = {}
PillCrusher.levelSize = 0
PillCrusher.HPUpDownEnemies = {}

---@param pillEffect PillEffect
---@param name string
---@param func fun(player: EntityPlayer, rng: RNG, isGolden: boolean, isHorse: boolean, pillColor: PillColor) | nil
function PillCrusher:AddPillCrusherEffect(pillEffect, name, func)
	if not func then
		func = function () end
	end
	PillCrusher.CrushedPillEffects[pillEffect] = {name = name, func = func}
end


---@param pillEffect PillEffect
---@return boolean
function PillCrusher:HasCrushedPill(pillEffect)
	return PillCrusher.CrushedPillsRoom[pillEffect] ~= nil
end


---@param pillEffect PillEffect
---@return integer
function PillCrusher:GetCrushedPillNum(pillEffect)
	local num = PillCrusher.CrushedPillsRoom[pillEffect]
	if not num then num = 0 end
	return num
end


function PillCrusher:ResetCrushedPillPerRoom()
	PillCrusher.CrushedPillsRoom = {}
end
PillCrusher:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, PillCrusher.ResetCrushedPillPerRoom)


local function GetRandomPillCrusherEffect(rng)
	local pillEffects = {}

	for pillEffect, _ in pairs(PillCrusher.CrushedPillEffects) do
		table.insert(pillEffects, pillEffect)
	end

	local chosenPill = pillEffects[rng:RandomInt(#pillEffects) + 1]

	return {PillCrusher.CrushedPillEffects[chosenPill], chosenPill}
end

--Vanilla pill effects
require("pill_crusher_scripts.pill_effects.48HourEnergy")
require("pill_crusher_scripts.pill_effects.Addicted")
require("pill_crusher_scripts.pill_effects.Amnesia")
require("pill_crusher_scripts.pill_effects.BadGas")
require("pill_crusher_scripts.pill_effects.BadTrip")
require("pill_crusher_scripts.pill_effects.BallsOfSteel")
require("pill_crusher_scripts.pill_effects.BombsAreKeys")
require("pill_crusher_scripts.pill_effects.ExplosiveDiarrhea")
require("pill_crusher_scripts.pill_effects.FriendsTillTheEnd")
require("pill_crusher_scripts.pill_effects.FullHealth")
require("pill_crusher_scripts.pill_effects.Gulp")
require("pill_crusher_scripts.pill_effects.HealthDown")
require("pill_crusher_scripts.pill_effects.HealthUp")
require("pill_crusher_scripts.pill_effects.Hematemesis")
require("pill_crusher_scripts.pill_effects.Horf")
require("pill_crusher_scripts.pill_effects.IFoundPills")
require("pill_crusher_scripts.pill_effects.ImDrowsy")
require("pill_crusher_scripts.pill_effects.ImExcited")
require("pill_crusher_scripts.pill_effects.InfestedExclamation")
require("pill_crusher_scripts.pill_effects.InfestedQuestion")
require("pill_crusher_scripts.pill_effects.Larger")
require("pill_crusher_scripts.pill_effects.LemonParty")
require("pill_crusher_scripts.pill_effects.LuckDown")
require("pill_crusher_scripts.pill_effects.LuckUp")
require("pill_crusher_scripts.pill_effects.Paralysis")
require("pill_crusher_scripts.pill_effects.Percs")
require("pill_crusher_scripts.pill_effects.Pheromones")
require("pill_crusher_scripts.pill_effects.PowerPill")
require("pill_crusher_scripts.pill_effects.PrettyFly")
require("pill_crusher_scripts.pill_effects.Puberty")
require("pill_crusher_scripts.pill_effects.QuestionMark")
require("pill_crusher_scripts.pill_effects.RangeDown")
require("pill_crusher_scripts.pill_effects.RangeUp")
require("pill_crusher_scripts.pill_effects.Relax")
require("pill_crusher_scripts.pill_effects.RetroVision")
require("pill_crusher_scripts.pill_effects.RUAWizard")
require("pill_crusher_scripts.pill_effects.SeeForever")
require("pill_crusher_scripts.pill_effects.ShotSpeedDown")
require("pill_crusher_scripts.pill_effects.ShotSpeedUp")
require("pill_crusher_scripts.pill_effects.Smaller")
require("pill_crusher_scripts.pill_effects.SomethingsWrong")
require("pill_crusher_scripts.pill_effects.SpeedDown")
require("pill_crusher_scripts.pill_effects.SpeedUp")
require("pill_crusher_scripts.pill_effects.Sunshine")
require("pill_crusher_scripts.pill_effects.TearsDown")
require("pill_crusher_scripts.pill_effects.TearsUp")
require("pill_crusher_scripts.pill_effects.Telepills")
require("pill_crusher_scripts.pill_effects.Vurp")
require("pill_crusher_scripts.pill_effects.XLax")

--Main mod
local function Lerp(a, b, t)
	return a + (b-a) * 0.2 * t
end


function mod:BloomShader(shader)
	if shader == "PillCrusherBloom" then
		local params = {
			BloomAmount = BloomAmount,
			Ratio = {BloomAmount /3, BloomAmount / 2}
		}
		if ActivateBloom == true then
			if BloomAmount >= 2.1 then
				ActivateBloom = false
				blurspeed = 0.01
			else
				BloomAmount = BloomAmount + blurspeed
				blurspeed = Lerp(blurspeed, 0.01, 0.06)
			end
		elseif BloomAmount > 0.1 then
			BloomAmount = BloomAmount - blurspeed
			blurspeed = Lerp(blurspeed, 0.2, 0.08)
		elseif BloomAmount < 0.1 then
			BloomAmount = 0
			blurspeed = 0.07
		end
		return params
	end
end
mod:AddCallback(ModCallbacks.MC_GET_SHADER_PARAMS, mod.BloomShader)


---@param rng RNG
---@param player EntityPlayer
function mod:UsePillCrusher(_, rng, player)
	local pillColor = player:GetPill(0)
	if pillColor == 0 then return end

	local itemPool = Game():GetItemPool()
	local pillEffect = itemPool:GetPillEffect(pillColor, player)

	--Fiend folio compatibility bs (ffs why wouldn't they just make it an api)
	if FiendFolio then
		if isFFPill[pillColor] then
			pillColor = FiendFolio.savedata.run.PillCopies[tostring(pillColor)]
			pillEffect = itemPool:GetPillEffect(pillColor, player)
			FiendFolio.savedata.run.IdentifiedRunPills[tostring(pillColor)] = true
		end
	end

	itemPool:IdentifyPill(pillColor)

	if pillEffect == PillEffect.PILLEFFECT_VURP and PillCrusher.LastPillUsed >= 0 then
		pillEffect = PillCrusher.LastPillUsed
		PillCrusher.LastPillUsed = PillEffect.PILLEFFECT_VURP
	else
		PillCrusher.LastPillUsed = pillEffect
	end

	local crushedPillEffect = PillCrusher.CrushedPillEffects[pillEffect]

	local isGolden = pillColor == PillColor.PILL_GOLD or pillColor == (PillColor.PILL_GOLD | PillColor.PILL_GIANT_FLAG)
	local isHorse = pillColor & PillColor.PILL_GIANT_FLAG == PillColor.PILL_GIANT_FLAG

	if pillEffect == PillEffect.PILLEFFECT_EXPERIMENTAL then
		crushedPillEffect, pillEffect = table.unpack(GetRandomPillCrusherEffect(rng))
	end

	if isGolden then
		crushedPillEffect, pillEffect = table.unpack(GetRandomPillCrusherEffect(rng))
	end

	local name
	if not crushedPillEffect then
		name = Isaac.GetItemConfig():GetPillEffect(pillEffect).Name
	else
		if pillEffect == PillEffect.PILLEFFECT_EXPERIMENTAL then
			name = "Experimental Treatment"
		else
			name = crushedPillEffect.name
		end

		crushedPillEffect.func(player, rng, isGolden, isHorse, pillColor)
	end

	local mult = isHorse and 2 or 1
	if PillCrusher.CrushedPillsRoom[pillEffect] then
		PillCrusher.CrushedPillsRoom[pillEffect] = PillCrusher.CrushedPillsRoom[pillEffect] + 1 * mult
	else
		PillCrusher.CrushedPillsRoom[pillEffect] = 1 * mult
	end

	SFXManager():Play(SoundEffect.SOUND_BONE_SNAP)
	Game():GetHUD():ShowItemText(name, "")
	local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, player.Position, Vector.Zero, nil)
	poof.Color = Color(1, 1, 1, 1, 0.7, 0.7, 0.7)
	ActivateBloom = true

	if not isGolden or rng:RandomInt(100) < 10 then
		player:SetPill(0, 0)

		if player:HasTrinket(TrinketType.TRINKET_ENDLESS_NAMELESS) and rng:RandomInt(100) < 25 then
			local spawningPos = Game():GetRoom():FindFreePickupSpawnPosition(player.Position, 1, true)
			Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_PILL, pillColor, spawningPos, Vector.Zero, nil)
		end
	end

	return true
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.UsePillCrusher, CollectibleType.COLLECTIBLE_PILL_CRUSHER)


function mod:AddPill(player)
    local data = Helpers.GetData(player)
	if not data then return end

    data.pilldrop = data.pilldrop or player:GetCollectibleNum(CollectibleType.COLLECTIBLE_PILL_CRUSHER)

    if data.pilldrop < player:GetCollectibleNum(CollectibleType.COLLECTIBLE_PILL_CRUSHER) then
		local room = Game():GetRoom()
		local spawningPos = room:FindFreePickupSpawnPosition(player.Position, 1, true)
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_PILL, 0, spawningPos, Vector.Zero, player):ToPickup()
        data.pilldrop = player:GetCollectibleNum(CollectibleType.COLLECTIBLE_PILL_CRUSHER)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, mod.AddPill)


function mod:spawnPill(rng, pos)
	local room = Game():GetRoom()
	local spawnposition = room:FindFreePickupSpawnPosition(pos)
	local spawned = false
	for i=0, Game():GetNumPlayers()-1 do
		local player = Isaac.GetPlayer(i)
		if player:HasCollectible(CollectibleType.COLLECTIBLE_PILL_CRUSHER) and rng:RandomInt(3)+1 == 1 and not spawned then
			local pill = Isaac.Spawn(5, 70, 0, spawnposition, Vector.Zero, player)
			if player:HasCollectible(CollectibleType.COLLECTIBLE_CONTRACT_FROM_BELOW) then
				Isaac.Spawn(5, 70, pill.SubType, spawnposition, Vector.Zero, player)
			end
			spawned = true
		end
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, mod.spawnPill)


function mod:item_effect()
	for i=0, Game():GetNumPlayers()-1 do
		local player = Isaac.GetPlayer(i)
		local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_PILL_CRUSHER)
		if player:HasCollectible(CollectibleType.COLLECTIBLE_PILL_CRUSHER) == true and Game():IsGreedMode() == true then
			Isaac.Spawn(5, 70, 0, player.Position, Vector.FromAngle(mod:GetRandomNumber(0, 360, rng)):Resized(3), player)
			Isaac.Spawn(5, 70, 0, player.Position, Vector.FromAngle(mod:GetRandomNumber(0, 360, rng)):Resized(3), player)
			Isaac.Spawn(5, 70, 0, player.Position, Vector.FromAngle(mod:GetRandomNumber(0, 360, rng)):Resized(3), player)
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, mod.item_effect)


function mod:DefaultWispInit(wisp)
	local player = wisp.Player
	if player:HasCollectible(CollectibleType.COLLECTIBLE_PILL_CRUSHER) then
		if wisp.SubType == CollectibleType.COLLECTIBLE_PILL_CRUSHER then
			--Wtf is this
			wisp.SubType = CollectibleType.COLLECTIBLE_MOMS_BOTTLE_PILLS
		end
	end
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, mod.DefaultWispInit, FamiliarVariant.WISP)


local function GetTeleRooms(cleared)
	local level = Game():GetLevel()
	local rooms = level:GetRooms()
	local startroom, endroom = 0, rooms.Size - 1
	levelSize = rooms.Size
	local roomsTable = {}
	if level:GetStageType() == StageType.STAGETYPE_REPENTANCE then
		if level:GetAbsoluteStage() == LevelStage.STAGE2_2 then
			endroom = endroom - 8
		end
	end
	for i = startroom, endroom do
		if rooms:Get(i).Data.Type ~= RoomType.ROOM_ANGEL and rooms:Get(i).Data.Type ~= RoomType.ROOM_DEVIL
		and rooms:Get(i).Data.Type ~= RoomType.ROOM_BOSS and rooms:Get(i).Data.Type ~= RoomType.ROOM_BOSSRUSH then
			local isMirror = level:GetAbsoluteStage() == LevelStage.STAGE1_2 and level:GetStageType() == StageType.STAGETYPE_REPENTANCE and (i > (endroom + 1) / 2)
			table.insert(roomsTable,{ListIDX = rooms:Get(i).ListIndex, IsMirror = isMirror})
		end
	end

	return roomsTable
end


function mod:SaveRun(save)
	if save then
		local toSave = {
			LastPillUsed = PillCrusher.LastPillUsed,
			Monsters = PillCrusher.MonsterTeleTable,
			Rooms = PillCrusher.teleRooms,
			Size = PillCrusher.levelSize,
			HPUpDownEnemies = PillCrusher.HPUpDownEnemies
		}
		PillCrusher:SaveData(json.encode(toSave))
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, mod.SaveRun)


function mod:LoadRun(continue)
	if continue and PillCrusher:HasData() then
		local load = json.decode(PillCrusher:LoadData())
		PillCrusher.LastPillUsed = load.LastPillUsed
		PillCrusher.MonsterTeleTable = load.Monsters
		PillCrusher.teleRooms = load.Rooms
		PillCrusher.levelSize = load.Size
		PillCrusher.HPUpDownEnemies = load.HPUpDownEnemies
	else
		PillCrusher.LastPillUsed = -1
		PillCrusher.MonsterTeleTable = {}
		PillCrusher.teleRooms = GetTeleRooms()
		PillCrusher.HPUpDownEnemies = {}
	end
end
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, mod.LoadRun)