local Helpers = require("pill_crusher_scripts.Helpers")

local TeleportAnimFrames = {
	{Scale = Vector(0.9, 1.1), Offset = Vector(0, 9)},
	{Scale = Vector(0.9, 1.1), Offset = Vector(0, 9)},
	{Scale = Vector(1.4, 0.6), Offset = Vector(0, -23)},
	{Scale = Vector(1.4, 0.6), Offset = Vector(0, -23)},
	{Scale = Vector(1.8, 0.5), Offset = Vector(0, -23)},
	{Scale = Vector(0.5, 2.2), Offset = Vector(0, 27)},
	{Scale = Vector(0.3, 3), Offset = Vector(0, 27)},
	{Scale = Vector(0.1, 8), Offset = Vector(0, 31)},
}


local function NewTeleLevel()
	PillCrusher.MonsterTeleTable = {}
end
PillCrusher:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, NewTeleLevel)


local function NewTeleRoom()
	if #PillCrusher.MonsterTeleTable <= 0 then return end

	local roomIDX = Game():GetLevel():GetCurrentRoomDesc().ListIndex
	local room = Game():GetRoom()

	for index, teleMonster in ipairs(PillCrusher.MonsterTeleTable) do
		if teleMonster.RoomIDX == roomIDX then
			local spawnpos = room:FindFreeTilePosition(room:GetRandomPosition(20), 10)

			if teleMonster.SpawnPos == nil then
				PillCrusher.MonsterTeleTable[index].SpawnPos = spawnpos
			else
				spawnpos = teleMonster.SpawnPos
			end

			local enemy = Game():Spawn(teleMonster.Type, teleMonster.Variant, spawnpos, Vector.Zero, nil, teleMonster.SubType, teleMonster.Seed):ToNPC()

			if teleMonster.ChampionIDX ~= -1 then
				enemy:MakeChampion(teleMonster.Seed, teleMonster.ChampionIDX,true)
			end

			enemy.HitPoints = teleMonster.HitPoints

			local data = Helpers.GetData(enemy)
			data.PrevTeleportEntityColl = enemy.EntityCollisionClass
			data.PrevTeleportGridColl = enemy.GridCollisionClass
			data.TeleFrames = #TeleportAnimFrames + 20
			data.IsTeleportingBack = true

			enemy:AddEntityFlags(EntityFlag.FLAG_FREEZE)
			enemy.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			enemy.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
			local sprite = enemy:GetSprite()
			data.OriginalScale = Vector(sprite.Scale.X, sprite.Scale.Y)
			data.OriginalOffset = Vector(sprite.Offset.X, sprite.Offset.Y)

			enemy.Visible = false

			room:SetClear(false)
		end
	end
end
PillCrusher:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, NewTeleRoom)


local function CleanRoom()
    local level = Game():GetLevel()
	local currentRoomIndex = level:GetCurrentRoomDesc().ListIndex
	local newMonsterTeleTable = {}

	for _, teleMonster in ipairs(PillCrusher.MonsterTeleTable) do
		if teleMonster.RoomIDX ~= currentRoomIndex then
			newMonsterTeleTable[#newMonsterTeleTable+1] = teleMonster
		end
	end

	PillCrusher.MonsterTeleTable = newMonsterTeleTable
end


local wasClear = true
local function OnUpdate()
	local room = Game():GetRoom()
	local isClear = room:IsClear()

	if not wasClear and isClear then
		CleanRoom()
	end

	wasClear = isClear
end
PillCrusher:AddCallback(ModCallbacks.MC_POST_UPDATE, OnUpdate)


---@param npc EntityNPC
local function TeleportMonsterAnim(_, npc)
	local data = Helpers.GetData(npc)
    if not data or not data.TeleFrames then return end
	local sprite = npc:GetSprite()
	local originScale = Vector(data.OriginalScale.X, data.OriginalScale.Y)
	local originOffset = Vector(data.OriginalOffset.X, data.OriginalOffset.Y)


	if data.TeleFrames == #TeleportAnimFrames*2 then
		SFXManager():Play(SoundEffect.SOUND_HELL_PORTAL2,1,0)
		npc.Visible = true
	end

	if data.TeleFrames % 2 == 0 then
		if data.TeleFrames % 4 == 0 then
			sprite.Color = Color(0,0,0,1)
		else
			sprite.Color = Color(1,1,1,1,1,1,1)
		end
	end

	local currentFrame = TeleportAnimFrames[math.floor(data.TeleFrames/2)]

	if currentFrame then
		---@diagnostic disable-next-line: assign-type-mismatch
		npc.SpriteScale = originScale * currentFrame.Scale
		---@diagnostic disable-next-line: assign-type-mismatch
		sprite.Offset = originOffset + currentFrame.Offset
	end

	if data.IsTeleportingBack then
		data.TeleFrames = data.TeleFrames - 1
	else
    	data.TeleFrames = data.TeleFrames + 1
	end

	if data.TeleFrames > #TeleportAnimFrames*2 then
		if data.IsTeleportingBack then
			npc.Visible = false
		else
			if not data.WasHorseTelePilled then
				local rng = Isaac.GetPlayer():GetCollectibleRNG(CollectibleType.COLLECTIBLE_PILL_CRUSHER)

				local level = Game():GetLevel()
				local currentRoomIndex = level:GetCurrentRoomDesc().SafeGridIndex
				local possibleTeleRooms = {}

				--Get all current rooms in current dimension
				for i = 0, 168, 1 do
					local roomDesc = level:GetRoomByIdx(i)

					if i ~= currentRoomIndex and i ~= 84 and roomDesc.Data and roomDesc.SafeGridIndex == i then
						possibleTeleRooms[#possibleTeleRooms+1] = roomDesc.ListIndex
					end
				end

				local chosenTeleroom = possibleTeleRooms[rng:RandomInt(#possibleTeleRooms) + 1]

				table.insert(PillCrusher.MonsterTeleTable, {
					RoomIDX = chosenTeleroom,
					Type = npc.Type,
					Variant = npc.Variant,
					SubType = npc.SubType,
					ChampionIDX = npc:GetChampionColorIdx(),
					Seed = npc.InitSeed,
					HitPoints = npc.HitPoints
				})
			end

			npc:Remove()
		end
	end

	if data.TeleFrames <= 0 then
		npc.EntityCollisionClass = data.PrevTeleportEntityColl
		npc.GridCollisionClass = data.PrevTeleportGridColl
		npc:ClearEntityFlags(EntityFlag.FLAG_FREEZE)
		npc.Color = Color(1, 1, 1)
		data.TeleFrames = nil
		data.IsTeleportingBack = nil
		sprite.Offset = Vector(data.OriginalOffset.X, data.OriginalOffset.Y)
		sprite.Scale = Vector(data.OriginalScale.X, data.OriginalScale.Y)
	end

    if not Game():IsPaused() then
        sprite:Update()
    end
end
PillCrusher:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, TeleportMonsterAnim)


PillCrusher:AddPillCrusherEffect(PillEffect.PILLEFFECT_TELEPILLS, "Telepills",
function (_, _, _, isHorse)
    for _,enemy in ipairs(Helpers.GetEnemies(true,true)) do
        enemy:AddEntityFlags(EntityFlag.FLAG_FREEZE)
        enemy.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        enemy.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
        local data = Helpers.GetData(enemy)
		data.TeleFrames = 1
		data.WasHorseTelePilled = isHorse
		data.OriginalScale = enemy:GetSprite().Scale
		data.OriginalOffset = enemy:GetSprite().Offset
    end

    SFXManager():Play(SoundEffect.SOUND_HELL_PORTAL1,1,0)
end)