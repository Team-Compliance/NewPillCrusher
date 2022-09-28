local Helpers = require("pill_crusher_scripts.Helpers")

local json = require("json")
-- local PillCrusher.MonsterTeleTable = {}
-- local PillCrusher.teleRooms = {}
-- local PillCrusher.levelSize


local function AddRedRoom(i)
	local room = Game():GetRoom()
	table.insert(PillCrusher.teleRooms, {ListIDX = i, IsMirror = room:IsMirrorWorld()})
end


-- local function GetRoomsSize()
-- 	return PillCrusher.teleRooms
-- end


local function GetTeleRooms(cleared)
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


function SaveRun(_, save)
	if save then
		local toSave = {Monsters = PillCrusher.MonsterTeleTable, Rooms = PillCrusher.teleRooms, Size = PillCrusher.levelSize}
		PillCrusher:SaveData(json.encode(toSave))
	end
end
PillCrusher:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, SaveRun)


function LoadRun(_, continue)
	if continue and PillCrusher:HasData() then
		local load = json.decode(PillCrusher:LoadData())
		PillCrusher.MonsterTeleTable = load.Monsters
		PillCrusher.teleRooms = load.Rooms
		PillCrusher.levelSize = load.Size
	else
		PillCrusher.MonsterTeleTable = {}
		PillCrusher.teleRooms = GetTeleRooms()
	end
end
PillCrusher:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, LoadRun)


local function TeleportMonsterAnim(_, npc)
	local data = Helpers.GetData(npc)
    if not data or not data.TeleFrames then return end
	local sprite = npc:GetSprite()
	local originScale = sprite.Scale
	local originOffset = sprite.Offset
	local room = Game():GetRoom()

    if data.TeleFrames == 0 or data.TeleFrames == 1 then
        sprite.Offset = Vector(originOffset.X, originOffset.Y + 9)
        sprite.Scale = Vector(originScale.X * 0.9, originScale.Y * 1.1)
    end
    if data.TeleFrames == 2 or data.TeleFrames == 3 then
        sprite.Offset = Vector(originOffset.X, originOffset.Y - 23)
        sprite.Scale = Vector(originScale.X * 1.4, originScale.Y * 0.6)
    end
    if data.TeleFrames == 3 then
        sprite.Offset = Vector(originOffset.X, originOffset.Y - 23)
        sprite.Scale = Vector(originScale.X * 1.4, originScale.Y * 0.6)
    end
    if data.TeleFrames == 4 then
        sprite.Offset = Vector(originOffset.X, originOffset.Y - 23)
        sprite.Scale = Vector(originScale.X * 1.8, originScale.Y * 0.5)
    end
    if data.TeleFrames == 5 then
        sprite.Offset = Vector(originOffset.X, originOffset.Y + 27)
        sprite.Scale = Vector(originScale.X * 0.5, originScale.Y * 2.2)
    end
    if data.TeleFrames == 6 then
        sprite.Offset = Vector(originOffset.X, originOffset.Y + 27)
        sprite.Scale = Vector(originScale.X * 0.3, originScale.Y * 3.0)
    end
    if data.TeleFrames == 7 then
        sprite.Offset = Vector(originOffset.X, originOffset.Y + 31)
        sprite.Scale = Vector(originScale.X * 0.1, originScale.Y * 8)
    end
    if data.TeleFrames >= 8 then
        sprite.Scale = Vector(0, originScale.Y * 100)
        local rng = Isaac.GetPlayer():GetCollectibleRNG(CollectibleType.COLLECTIBLE_PILL_CRUSHER)

        local idx = nil
        while idx == nil do
            idx = PillCrusher.teleRooms[rng:RandomInt(#PillCrusher.teleRooms) + 1]
            if room:IsMirrorWorld() ~= idx.IsMirror or idx.ListIDX == Game():GetLevel():GetCurrentRoomDesc().ListIndex then
                idx = nil
            end
        end

        table.insert(PillCrusher.MonsterTeleTable,{Type = npc.Type, Variant = npc.Variant, SubType = npc.SubType, ChampionIDX = npc:GetChampionColorIdx(), Seed = npc.InitSeed, HP = npc.HitPoints, RoomIDX = idx.ListIDX})
        npc:Remove()
    end

    if data.TeleFrames % 2 == 0 then
        sprite.Color = Color(0,0,0,1)
    else
        sprite.Color = Color(1,1,1,1,1,1,1)
    end

    data.TeleFrames = data.TeleFrames + 1

    if not Game():IsPaused() then
        sprite:Update()
    end
end
PillCrusher:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, TeleportMonsterAnim)


PillCrusher:AddPillCrusherEffect(PillEffect.PILLEFFECT_TELEPILLS, "Telepills",
function ()
    for _,enemy in ipairs(Helpers.GetEnemies(true,true)) do
        enemy:AddEntityFlags(EntityFlag.FLAG_FREEZE)
        enemy.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        enemy.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
        Helpers.GetData(enemy).TeleFrames = 0
    end

    SFXManager():Play(SoundEffect.SOUND_TELEPILLS,1,0)
end)