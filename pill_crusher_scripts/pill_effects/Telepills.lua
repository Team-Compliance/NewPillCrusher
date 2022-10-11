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


local function AddRedRoom(i)
	local room = Game():GetRoom()
	table.insert(PillCrusher.teleRooms, {ListIDX = i, IsMirror = room:IsMirrorWorld()})
end


local function GetTeleRooms()
	local level = Game():GetLevel()
	local rooms = level:GetRooms()
	local startroom, endroom = 0, rooms.Size - 1
	PillCrusher.levelSize = rooms.Size
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


local function NewTeleLevel()
	PillCrusher.MonsterTeleTable = {}
	PillCrusher.teleRooms = GetTeleRooms()
end
PillCrusher:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, NewTeleLevel)


local function NewTeleRoom()
	local roomIDX = Game():GetLevel():GetCurrentRoomDesc().ListIndex
	local room = Game():GetRoom()
	if #PillCrusher.MonsterTeleTable > 0 then
		for k,v in ipairs(PillCrusher.MonsterTeleTable) do
			if v.RoomIDX == roomIDX then
				local spawnpos = room:FindFreeTilePosition(room:GetRandomPosition(20), 10)
				if v.SpawnPos == nil then
					PillCrusher.MonsterTeleTable[k].SpawnPos = spawnpos
				else
					spawnpos = v.SpawnPos
				end
				local enemy = Game():Spawn(v.Type,v.Variant,spawnpos,Vector.Zero,nil,v.SubType,v.Seed):ToNPC()
				if v.ChampionIDX ~= -1 then
					enemy:MakeChampion(v.Seed,v.ChampionIDX,true)
				end
				enemy.HitPoints = v.HP

				local data = Helpers.GetData(enemy)
				data.PrevTeleportEntityColl = enemy.EntityCollisionClass
				data.PrevTeleportGridColl = enemy.GridCollisionClass
				data.TeleFrames = #TeleportAnimFrames
				data.IsTeleportingBack = true

				enemy:AddEntityFlags(EntityFlag.FLAG_FREEZE)
				enemy.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
				enemy.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
				local sprite = enemy:GetSprite()
				data.OriginalScale = sprite.Scale
				data.OriginalOffset = sprite.Offset
				sprite.Scale = Vector(0, sprite.Offset.Y * 100)

				SFXManager():Play(SoundEffect.SOUND_HELL_PORTAL2,1,0)
			end
		end
	end
end
PillCrusher:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, NewTeleRoom)


local function CleanRoom()
    local level = Game():GetLevel()
	local i = 1
	while i <= #PillCrusher.MonsterTeleTable do
		if PillCrusher.MonsterTeleTable[i].RoomIDX == level:GetCurrentRoomDesc().ListIndex then
			table.remove(PillCrusher.MonsterTeleTable,i)
		else
			i = i + 1
		end
	end
end
PillCrusher:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, CleanRoom)


function RedRoomExpansion()
	local level = Game():GetLevel()
	local rooms = level:GetRooms()
	if PillCrusher.levelSize < rooms.Size then
		for i = PillCrusher.levelSize, rooms.Size - 1 do
			AddRedRoom(i)
		end
		PillCrusher.levelSize = rooms.Size
	end
end
PillCrusher:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, RedRoomExpansion)
PillCrusher:AddCallback(ModCallbacks.MC_USE_ITEM, RedRoomExpansion, CollectibleType.COLLECTIBLE_RED_KEY)
PillCrusher:AddCallback(ModCallbacks.MC_USE_CARD, RedRoomExpansion, Card.CARD_CRACKED_KEY)


---@param npc EntityNPC
local function TeleportMonsterAnim(_, npc)
	local data = Helpers.GetData(npc)
    if not data or not data.TeleFrames then return end
	local sprite = npc:GetSprite()
	local originScale = data.OriginalScale
	local originOffset = data.OriginalOffset
	local room = Game():GetRoom()

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
		npc.SpriteScale = currentFrame.Scale
		---@diagnostic disable-next-line: assign-type-mismatch
		sprite.Offset = originOffset + currentFrame.Offset
	end

	if data.IsTeleportingBack then
		data.TeleFrames = data.TeleFrames - 1
	else
    	data.TeleFrames = data.TeleFrames + 1
	end

	if data.TeleFrames > #TeleportAnimFrames*2 then
		if not data.WasHorseTelePilled then
			local rng = Isaac.GetPlayer():GetCollectibleRNG(CollectibleType.COLLECTIBLE_PILL_CRUSHER)

			local idx = nil
			while idx == nil do
				idx = PillCrusher.teleRooms[rng:RandomInt(#PillCrusher.teleRooms) + 1]
				if room:IsMirrorWorld() ~= idx.IsMirror or idx.ListIDX == Game():GetLevel():GetCurrentRoomDesc().ListIndex then
					idx = nil
				end
			end

			table.insert(PillCrusher.MonsterTeleTable,{Type = npc.Type, Variant = npc.Variant, SubType = npc.SubType, ChampionIDX = npc:GetChampionColorIdx(), Seed = npc.InitSeed, HP = npc.HitPoints, RoomIDX = idx.ListIDX})
		end

		npc:Remove()
	end

	if data.TeleFrames <= 0 then
		npc.EntityCollisionClass = data.PrevTeleportEntityColl
		npc.GridCollisionClass = data.PrevTeleportGridColl
		npc:ClearEntityFlags(EntityFlag.FLAG_FREEZE)
		npc.Color = Color(1, 1, 1)
		data.TeleFrames = nil
		data.IsTeleportingBack = nil
		sprite.Offset = originOffset
		--sprite.Scale = originScale
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