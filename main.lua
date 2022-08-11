PillCrusher = RegisterMod("Pill Crusher", 1);
local mod = PillCrusher

CollectibleType.COLLECTIBLE_PILL_CRUSHER = Isaac.GetItemIdByName("Pill Crusher");

local BloomAmount = 0
local ActivateBloom = false
local MonsterTeleTable = {}

local rangedown = 0
local luckdown = 0
local tearsdown = 0
local DrowsyExited = 0

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

local function GetData(entity)
	if entity and entity.GetData then
		local data = entity:GetData()
		if not data.PillCrusher then
			data.PillCrusher = {}
		end
		return data
	end
	return nil
end

local function GetEnemies(allEnemies, noBosses)
	local enemies = {}
	for _,enemy in ipairs(Isaac.GetRoomEntities()) do
		enemy = enemy:ToNPC()
		if enemy and (enemy:IsVulnerableEnemy() or allEnemies) and enemy:IsActiveEnemy() and enemy:IsEnemy() then
			if not enemy:IsBoss() or (enemy:IsBoss() and not noBosses) then
				table.insert(enemies,enemy)
			end
		end
	end
	return enemies
end

function mod:AddPill(player)
    local data = GetData(player)
    data.pilldrop = data.pilldrop or player:GetCollectibleNum(CollectibleType.COLLECTIBLE_PILL_CRUSHER)

    if data.pilldrop < player:GetCollectibleNum(CollectibleType.COLLECTIBLE_PILL_CRUSHER) then
        Isaac.Spawn(5, 70, 0, player.Position, Vector(0,0), player):ToPickup()
        data.pilldrop = player:GetCollectibleNum(CollectibleType.COLLECTIBLE_PILL_CRUSHER)
    end   
end
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, mod.AddPill)

local PillCrusherEffects = {
[PillEffect.PILLEFFECT_BOMBS_ARE_KEYS] = function(p,pillcolor,itempool)
	if itempool:GetPillEffect(pillcolor, p) == PillEffect.PILLEFFECT_BOMBS_ARE_KEYS or pillcolor == PillColor.PILL_GOLD or pillcolor == 2062 then
		Game():GetHUD():ShowItemText("Bombs are key")
		local bombspickup = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BOMB)
		local keyspickup = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_KEY)
		local keytears = Isaac.FindByType(EntityType.ENTITY_TEAR)
		local bombs = Isaac.FindByType(EntityType.ENTITY_BOMB)
		
		for _,bomb in ipairs(bombspickup) do
			bomb = bomb:ToPickup()
			local subtype = KeySubType.KEY_NORMAL
			if bomb.SubType == BombSubType.BOMB_DOUBLEPACK or pillcolor > 2047 then
				subtype = KeySubType.KEY_DOUBLEPACK
			end
			if bomb.SubType == BombSubType.BOMB_GOLDEN or bomb.SubType == BombSubType.BOMB_GOLDENTROLL then
				subtype = KeySubType.KEY_GOLDEN
			end
			bomb:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_KEY, subtype, true, true)
		end
		
		for _,key in ipairs(keyspickup) do
			key = key:ToPickup()
			local subtype = BombSubType.BOMB_NORMAL
			if key.SubType == KeySubType.KEY_DOUBLEPACK or pillcolor > 2047 then
				subtype = BombSubType.BOMB_DOUBLEPACK
			end
			if key.SubType == KeySubType.KEY_GOLDEN then
				subtype = BombSubType.BOMB_GOLDEN
			end
			key:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BOMB, subtype, true, true)
		end

		for _,key in ipairs(keytears) do
			key = key:ToTear()
			if key.Variant == TearVariant.KEY or key.Variant == TearVariant.KEY_BLOOD then
				local bomb = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BOMB, BombSubType.BOMB_NORMAL, key.Position, key.Velocity, nil)
				bomb:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
				key:Remove()
			end
		end

		for _,bomb in ipairs(bombs) do
			bomb = bomb:ToBomb()
			if bomb.Variant ~= BombVariant.BOMB_THROWABLE then
				local subtype = KeySubType.KEY_NORMAL
				if bomb.Variant == BombVariant.BOMB_GIGA or bomb.Variant == BombVariant.BOMB_ROCKET_GIGA then
					subtype = KeySubType.KEY_CHARGED
				end
				if bomb.Variant == BombVariant.BOMB_GOLDENTROLL then
					subtype = KeySubType.KEY_GOLDEN
				end
				local key = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_KEY, subtype, bomb.Position, bomb.Velocity, nil)
				key:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
				bomb:Remove()
			end
		end
	end
end,

[PillEffect.PILLEFFECT_BAD_GAS] = function(p,pillcolor,itempool)
	if itempool:GetPillEffect(pillcolor, p) == PillEffect.PILLEFFECT_BAD_GAS or pillcolor == PillColor.PILL_GOLD or pillcolor == 2062 then
		Game():GetHUD():ShowItemText("Bad Gas")
		for _,enemy in ipairs(GetEnemies(false)) do
			local cloud = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SMOKE_CLOUD, 0, enemy.Position, Vector.Zero, enemy):ToEffect()
			local multi = pillcolor > 2047 and 2 or 1
			cloud.LifeSpan = 180 / multi
			enemy:AddPoison(EntityRef(p), 60 * multi, 3 + p.Damage / 2 * (multi - 1))
		end
	end
end,

[PillEffect.PILLEFFECT_BAD_TRIP] = function(p,pillcolor,itempool)
	if itempool:GetPillEffect(pillcolor, p) == PillEffect.PILLEFFECT_BAD_TRIP or pillcolor == PillColor.PILL_GOLD or pillcolor == 2062 then
		Game():GetHUD():ShowItemText("Bad Trip")
		for _,enemy in ipairs(GetEnemies(false)) do
			local mult = pillcolor > 2047 and 2 or 1
			enemy:TakeDamage(enemy.HitPoints / (10 / mult), DamageFlag.DAMAGE_LASER, EntityRef(p),0)
		end
	end
end,

[PillEffect.PILLEFFECT_HEALTH_UP] = function(p,pillcolor,itempool)
	if itempool:GetPillEffect(pillcolor, p) == PillEffect.PILLEFFECT_HEALTH_UP or pillcolor == PillColor.PILL_GOLD or pillcolor == 2062 then
		Game():GetHUD():ShowItemText("Health Up")
		for _,enemy in ipairs(GetEnemies(false)) do
			local mult = pillcolor > 2047 and 2 or 1
			enemy.MaxHitPoints = enemy.MaxHitPoints + 15 * mult
			enemy.HitPoints = enemy.HitPoints + 15 * mult
		end
	end
end,

[PillEffect.PILLEFFECT_HEALTH_DOWN] = function(p,pillcolor,itempool)
	if itempool:GetPillEffect(pillcolor, p) == PillEffect.PILLEFFECT_HEALTH_DOWN or pillcolor == PillColor.PILL_GOLD or pillcolor == 2062 then
		Game():GetHUD():ShowItemText("Health Down")
		for _,enemy in ipairs(GetEnemies(false)) do
			local mult = pillcolor > 2047 and 2 or 1
			enemy.MaxHitPoints = enemy.MaxHitPoints - math.min(15 * mult,enemy.MaxHitPoints / (2 - 0.5 * (-1 + mult)))
			enemy.HitPoints = enemy.HitPoints - math.min(15 * mult,enemy.HitPoints / (2 - 0.5 * (-1 + mult)))
		end
	end
end,

[PillEffect.PILLEFFECT_FRIENDS_TILL_THE_END] = function(p,pillcolor,itempool)
	if itempool:GetPillEffect(pillcolor, p) == PillEffect.PILLEFFECT_FRIENDS_TILL_THE_END or pillcolor == PillColor.PILL_GOLD or pillcolor == 2062 then
		Game():GetHUD():ShowItemText("Friends till the end!")
		local rng = p:GetCollectibleRNG(CollectibleType.COLLECTIBLE_PILL_CRUSHER)
		for _,enemy in ipairs(GetEnemies(true)) do
			local data = GetData(enemy)
			data.SpawnFliesOnDeath = { Fly = pillcolor > 2047 and mod:GetRandomNumber(1, 3, rng) or 1, Parent = p}
		end
	end
end,

[PillEffect.PILLEFFECT_FULL_HEALTH] = function(p,pillcolor,itempool)
	if itempool:GetPillEffect(pillcolor, p) == PillEffect.PILLEFFECT_FULL_HEALTH or pillcolor == PillColor.PILL_GOLD or pillcolor == 2062 then
		Game():GetHUD():ShowItemText("Full health")
		for _,enemy in ipairs(GetEnemies(true)) do
			enemy.HitPoints = enemy.MaxHitPoints
		end
	end
end,

[PillEffect.PILLEFFECT_IM_EXCITED] = function(p,pillcolor,itempool)
	if itempool:GetPillEffect(pillcolor, p) == PillEffect.PILLEFFECT_IM_EXCITED or pillcolor == PillColor.PILL_GOLD or pillcolor == 2062 then
		Game():GetHUD():ShowItemText("I'm excited!!!")
		DrowsyExited = 1
	end
end,

[PillEffect.PILLEFFECT_IM_DROWSY] = function(p,pillcolor,itempool)
	if itempool:GetPillEffect(pillcolor, p) == PillEffect.PILLEFFECT_IM_DROWSY or pillcolor == PillColor.PILL_GOLD or pillcolor == 2062 then
		Game():GetHUD():ShowItemText("I'm drowsy...")
		DrowsyExited = pillcolor > 2047 and 4 or 2
		for _,p in ipairs(Isaac.FindByType(EntityType.ENTITY_PLAYER)) do
			p = p:ToPlayer()
			p:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
			p:EvaluateItems()
		end
	end
end,

[PillEffect.PILLEFFECT_BALLS_OF_STEEL] = function(p,pillcolor,itempool)
	if itempool:GetPillEffect(pillcolor, p) == PillEffect.PILLEFFECT_BALLS_OF_STEEL or pillcolor == PillColor.PILL_GOLD or pillcolor == 2062 then
		Game():GetHUD():ShowItemText("Balls of Steel")
		for _,enemy in ipairs(GetEnemies(false)) do
			local mult = pillcolor > 2047 and 1.5 or 3
			local data = GetData(enemy)
			data.Armor = enemy.MaxHitPoints / mult
		end
	end
end,


[PillEffect.PILLEFFECT_PARALYSIS] = function(p,pillcolor,itempool)
	if itempool:GetPillEffect(pillcolor, p) == PillEffect.PILLEFFECT_PARALYSIS or pillcolor == PillColor.PILL_GOLD or pillcolor == 2062 then
		Game():GetHUD():ShowItemText("Paralysis")
		local rng = p:GetCollectibleRNG(CollectibleType.COLLECTIBLE_PILL_CRUSHER)
		for _,enemy in ipairs(GetEnemies(false)) do
			local mult = pillcolor > 2047 and 2 or 1
			enemy:AddFreeze(EntityRef(p),mod:GetRandomNumber(60,90,rng) * mult)
		end
	end
end,

[PillEffect.PILLEFFECT_ADDICTED] = function(p,pillcolor,itempool)
	if itempool:GetPillEffect(pillcolor, p) == PillEffect.PILLEFFECT_ADDICTED or pillcolor == PillColor.PILL_GOLD or pillcolor == 2062 then
		Game():GetHUD():ShowItemText("Addicted!")
		for _,enemy in ipairs(GetEnemies(false)) do
			local data = GetData(enemy)
			data.DoubleDamage = pillcolor > 2047 and 2 or 1.3
		end
	end
end,

[PillEffect.PILLEFFECT_I_FOUND_PILLS] = function(p,pillcolor,itempool)
	if itempool:GetPillEffect(pillcolor, p) == PillEffect.PILLEFFECT_I_FOUND_PILLS or pillcolor == PillColor.PILL_GOLD or pillcolor == 2062 then
		--Game():GetHUD():ShowItemText("Addicted!")
		p:UsePill(PillEffect.PILLEFFECT_I_FOUND_PILLS,pillcolor,UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
	end
end,

[PillEffect.PILLEFFECT_PUBERTY] = function(p,pillcolor,itempool)
	if itempool:GetPillEffect(pillcolor, p) == PillEffect.PILLEFFECT_PUBERTY or pillcolor == PillColor.PILL_GOLD or pillcolor == 2062 then
		Game():GetHUD():ShowItemText("Puberty!")
		for _, enemy in ipairs(GetEnemies(true)) do
			if not enemy:IsBoss() and not enemy:IsChampion() then
				local hpMul = enemy.HitPoints / enemy.MaxHitPoints
				enemy:MakeChampion(enemy.InitSeed)
				enemy.HitPoints = enemy.MaxHitPoints * hpMul
			end
		end
	end
end,

[PillEffect.PILLEFFECT_PERCS] = function(p,pillcolor,itempool)
	if itempool:GetPillEffect(pillcolor, p) == PillEffect.PILLEFFECT_PERCS or pillcolor == PillColor.PILL_GOLD or pillcolor == 2062 then
		Game():GetHUD():ShowItemText("Percs!")
		for _,enemy in ipairs(GetEnemies(false)) do
			local data = GetData(enemy)
			data.HalfDamage = pillcolor > 2047 and 2 or 1.3
		end
	end
end,

[PillEffect.PILLEFFECT_QUESTIONMARK] = function(p,pillcolor,itempool)
	if itempool:GetPillEffect(pillcolor, p) == PillEffect.PILLEFFECT_QUESTIONMARK or pillcolor == PillColor.PILL_GOLD or pillcolor == 2062 then
		Game():GetHUD():ShowItemText("???")
		for _,enemy in ipairs(GetEnemies(false)) do
			local mult = pillcolor > 2047 and 2 or 1
			enemy:AddConfusion(EntityRef(p), 90 * mult, false)
		end
	end
end,

[PillEffect.PILLEFFECT_LARGER] = function(p,pillcolor,itempool)
	if itempool:GetPillEffect(pillcolor, p) == PillEffect.PILLEFFECT_LARGER or pillcolor == PillColor.PILL_GOLD or pillcolor == 2062 then
		Game():GetHUD():ShowItemText("One Makes You Larger")
		for _,enemy in ipairs(GetEnemies(false)) do
			local mult = pillcolor > 2047 and 1.5 or 1
			enemy.Scale = enemy.Scale * 1.3 * mult
		end
	end
end,

[PillEffect.PILLEFFECT_SMALLER] = function(p,pillcolor,itempool)
	if itempool:GetPillEffect(pillcolor, p) == PillEffect.PILLEFFECT_SMALLER or pillcolor == PillColor.PILL_GOLD or pillcolor == 2062 then
		Game():GetHUD():ShowItemText("One Makes You Small")
		for _,enemy in ipairs(GetEnemies(false)) do
			local mult = pillcolor > 2047 and 1.5 or 1
			enemy.Scale = enemy.Scale / (1.3 * mult)
		end
	end
end,

[PillEffect.PILLEFFECT_GULP] = function(p,pillcolor,itempool)
	if itempool:GetPillEffect(pillcolor, p) == PillEffect.PILLEFFECT_GULP or pillcolor == PillColor.PILL_GOLD or pillcolor == 2062 then
		Game():GetHUD():ShowItemText("Gulp!")
		local trinket1 = p:GetTrinket(0)
		local trinket2 = p:GetTrinket(1)
		if trinket1 ~= 0 then p:TryRemoveTrinket(trinket1) end
		if trinket2 ~= 0 then p:TryRemoveTrinket(trinket2) end
		local rng = p:GetCollectibleRNG(CollectibleType.COLLECTIBLE_PILL_CRUSHER)
		for _,trinket in ipairs(Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET)) do
			local gold = (pillcolor > 2047 and rng:RandomInt(2) == 1 and trinket.SubType < TrinketType.TRINKET_GOLDEN_FLAG) and TrinketType.TRINKET_GOLDEN_FLAG or 0
			p:AddTrinket(trinket.SubType + gold)
			p:UseActiveItem(CollectibleType.COLLECTIBLE_SMELTER,false,false,true,false)
			Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, trinket.Position,Vector.Zero,nil)
			trinket:Remove()
		end
		if trinket1 ~= 0 then p:AddTrinket(trinket1) end
		if trinket2 ~= 0 then p:AddTrinket(trinket2) end
	end
end,

[PillEffect.PILLEFFECT_EXPLOSIVE_DIARRHEA] = function(p,pillcolor,itempool)
	if itempool:GetPillEffect(pillcolor, p) == PillEffect.PILLEFFECT_EXPLOSIVE_DIARRHEA or pillcolor == PillColor.PILL_GOLD or pillcolor == 2062 then
		Game():GetHUD():ShowItemText("Explosive Diarrhea")
		for _,enemy in ipairs(GetEnemies(true)) do
			local mul = pillcolor > 2047 and 3 or 1
			local data = GetData(enemy)
			data.DiarrheaTimer = 90 * mul
		end
	end
end,

[PillEffect.PILLEFFECT_PRETTY_FLY] = function(p,pillcolor,itempool)
	if itempool:GetPillEffect(pillcolor, p) == PillEffect.PILLEFFECT_PRETTY_FLY or pillcolor == PillColor.PILL_GOLD or pillcolor == 2062 then
		Game():GetHUD():ShowItemText("Pretty Fly")
		for _,enemy in ipairs(GetEnemies(false)) do
			local mul = pillcolor > 2047 and 2 or 1
			--enemy:Morph(enemy.Type,enemy.Variant,enemy.SubType,17)
			for i = 1, mul do
				local fly = Isaac.Spawn(EntityType.ENTITY_ETERNALFLY,0,0,enemy.Position,Vector.Zero,enemy):ToNPC()
				fly.Parent = enemy
			end
		end
	end
end,

[PillEffect.PILLEFFECT_TELEPILLS] = function(p,pillcolor,itempool)
	if itempool:GetPillEffect(pillcolor, p) == PillEffect.PILLEFFECT_TELEPILLS or pillcolor == PillColor.PILL_GOLD or pillcolor == 2062 then
		Game():GetHUD():ShowItemText("Telepills")
		for _,enemy in ipairs(GetEnemies(true,true)) do
			table.insert(MonsterTeleTable,{Type = enemy.Type, Variant = enemy.Variant, SubType = enemy.SubType, ChampionIDX = enemy:GetChampionColorIdx(), Seed = enemy.InitSeed, HP = enemy.HitPoints})
			enemy:AddEntityFlags(EntityFlag.FLAG_FREEZE)
			local sprite = enemy:GetSprite()
			sprite.Color = Color(1,1,1,1,1,1,1)
			enemy:Remove()
		end
	end
end,
[PillEffect.PILLEFFECT_HEMATEMESIS] = function(p,pillcolor,itempool)
	if itempool:GetPillEffect(pillcolor, p) == PillEffect.PILLEFFECT_HEMATEMESIS or pillcolor == PillColor.PILL_GOLD or pillcolor == 2062 then
		Game():GetHUD():ShowItemText("Hematemesis")
		for _,enemy in ipairs(GetEnemies()) do
			enemy:AddEntityFlags(EntityFlag.FLAG_BLEED_OUT)
			local rng = p:GetCollectibleRNG(CollectibleType.COLLECTIBLE_PILL_CRUSHER)
			if mod:GetRandomNumber(1,100,rng) < 30 then
				for i = 1, (rng:RandomInt(2) + 1) do
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_FULL, Game():GetRoom():FindFreePickupSpawnPosition(enemy.Position),Vector.Zero,nil)
				end
			end
		end
	end
end
}

function mod:Diarrhea(npc)
	local data = GetData(npc)
	if data.DiarrheaTimer then
		if data.DiarrheaTimer % 10 == 0 then
			local bomb = Isaac.Spawn(EntityType.ENTITY_BOMB, BombVariant.BOMB_NORMAL, 0, npc.Position, Vector.Zero, npc)
			bomb:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		end
		data.DiarrheaTimer = data.DiarrheaTimer - 1
		if data.DiarrheaTimer <= 0 then
			data.DiarrheaTimer = nil
		end
	end
end
mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, mod.Diarrhea)

local blurspeed = 0.07

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
			blurspeed = Lerp(blurspeed,0.2,0.08)
		elseif BloomAmount < 0.1 then
			BloomAmount = 0
			blurspeed = 0.07
		end
		return params
	end
end
mod:AddCallback(ModCallbacks.MC_GET_SHADER_PARAMS, mod.BloomShader)



function mod:SlowFastRoom()
	if DrowsyExited == 1 then
		Game():GetRoom():SetBrokenWatchState(DrowsyExited)
	elseif DrowsyExited == 2 or DrowsyExited == 4 then
		for _,p in ipairs(Isaac.FindByType(EntityType.ENTITY_PLAYER)) do
			p:AddSlowing(EntityRef(nil),1,0.8 / DrowsyExited,Color(1,1,1,1))
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.SlowFastRoom)

function mod:SlowFastRoomFireRate(p,cache)
	if DrowsyExited ~= 1 then
		p.MaxFireDelay = p.MaxFireDelay * (1 + 0.25 * DrowsyExited)
	end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.SlowFastRoomFireRate, CacheFlag.CACHE_FIREDELAY)

function mod:SlowFastRoomReset()
	if DrowsyExited > 0 then
		DrowsyExited = 0
		for _,p in ipairs(Isaac.FindByType(EntityType.ENTITY_PLAYER)) do
			p = p:ToPlayer()
			p:ClearEntityFlags(EntityFlag.FLAG_SLOW)
			p:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
			p:EvaluateItems()
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.SlowFastRoomReset)

function mod:BallsOfSteelArmorIndicator(npc)
	local data = GetData(npc)
	if data.Armor then
		local color = Color(1,1,1,1)
		color:SetColorize(0,0,0.6,0.35)
		npc:GetSprite().Color = color
	end
end
mod:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, mod.BallsOfSteelArmorIndicator)

function mod:NewTeleRoom()
	local room = Game():GetRoom()
	if #MonsterTeleTable > 0 and room:IsClear() then
		local spawn = {}
		local rng = Isaac.GetPlayer():GetCollectibleRNG(CollectibleType.COLLECTIBLE_PILL_CRUSHER)
		for k,v in ipairs(MonsterTeleTable) do
			if rng:RandomInt(4) == 1 then
				local spawnpos = room:FindFreeTilePosition(room:GetRandomPosition(20), 10)
				local enemy = Game():Spawn(v.Type,v.Variant,spawnpos,Vector.Zero,nil,v.SubType,v.Seed):ToNPC()
				if v.ChampionIDX ~= -1 then
					enemy:MakeChampion(v.Seed,v.ChampionIDX,true)
				end
				enemy.HitPoints = v.HP
				table.remove(MonsterTeleTable,k)
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.NewTeleRoom)

function mod:use_pillcrusher(boi, rng, p, slot, data)
	local pillcolor = p:GetPill(0)
	if pillcolor == 0 then return false end
	local itempool = Game():GetItemPool()
	ActivateBloom = itempool:GetPillEffect(pillcolor, p) ~= PillEffect.PILLEFFECT_I_FOUND_PILLS
	local func
	if pillcolor < PillColor.PILL_GOLD then
		func = PillCrusherEffects[itempool:GetPillEffect(pillcolor, p)]
		p:SetPill(0,0)
	else
		func = PillCrusherEffects[mod:GetRandomNumber(0,13,rng)]
		if rng:RandomInt(10) == 1 then
			p:SetPill(0,0)
		end
	end
	if func ~= nil then
		func(p,pillcolor,itempool)
	end
	itempool:IdentifyPill(pillcolor)
	SFXManager():Play(462, 1, 2, false, 1, 0)
	return true
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.use_pillcrusher, CollectibleType.COLLECTIBLE_PILL_CRUSHER)

function mod:FliesOnDeath(entity)
	local data = GetData(entity)
	if data.SpawnFliesOnDeath then
		for i = 1, data.SpawnFliesOnDeath.Fly do
			local fly = Isaac.Spawn(EntityType.ENTITY_FAMILIAR,FamiliarVariant.BLUE_FLY,0,entity.Position,Vector.Zero,data.SpawnFliesOnDeath.Parent)
			fly:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		end		
	end
end
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, mod.FliesOnDeath)

function mod:DamageEffects(e, damage, flags, source, cd)
	if e:ToPlayer() then return nil end
	local data = GetData(e)
	if data.Armor then
		if data.Armor > 0 then
			data.Armor = data.Armor - damage
		else
			local leftover = data.Armor
			data.Armor = nil
			e:TakeDamage(damage+leftover,flags,source,cd)
		end
		return false
	end
	if not (data.DoubleDamage and data.HalfDamage) then
		if not data.TookDD and data.DoubleDamage then
			data.TookDD = true
			e:TakeDamage(damage*data.DoubleDamage,flags,source,cd)
			return false
		else
			data.TookDD = nil
		end
		if not data.TookHD and data.HalfDamage then
			data.TookHD = true
			e:TakeDamage(damage/data.HalfDamage,flags,source,cd)
			return false
		else
			data.TookHD = nil
		end
	end
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, mod.DamageEffects)

function mod:player_effect()

	for _, entity in pairs(Isaac.GetRoomEntities()) do
		if entity.Type == 9 then
			local proj = entity:ToProjectile()
			if rangedown > 0 then
				proj.Height = proj.Height + 7
			end
			if tearsdown > 0 then
				proj:Remove()
			end
			if luckdown > 0 then
				proj.ProjectileFlags = 0
			end
		end
	end
	rangedown = rangedown > 0 and (rangedown - 1) or 0
	luckdown = luckdown > 0 and (luckdown - 1) or 0
	tearsdown = tearsdown > 0 and (tearsdown - 1) or 0
	
end
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.player_effect)

function mod:spawnPill(rng, pos)
	local spawnposition = Game():GetRoom():FindFreePickupSpawnPosition(pos)
	local spawned = false
	for i=0, Game():GetNumPlayers()-1 do
		local player = Isaac.GetPlayer(i)
		if player:HasCollectible(CollectibleType.COLLECTIBLE_PILL_CRUSHER) and mod:GetRandomNumber(1,3,rng) == 1 and not spawned then
			local pill = Isaac.Spawn(5, 70, 0, spawnposition, Vector.Zero, player)
			if player:HasCollectible(CollectibleType.COLLECTIBLE_CONTRACT_FROM_BELOW) then	
				Isaac.Spawn(5, 70, pill.SubType, spawnposition, Vector.Zero, player)
			end
			spawned = true
		end
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, mod.spawnPill)

--spawns 3 pills on greed mode
function mod:item_effect()
	local room = Game():GetRoom()
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
			wisp.SubType = 102
		end
	end
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, mod.DefaultWispInit, FamiliarVariant.WISP)

function mod:GetRandomNumber(numMin, numMax, rng)
	if not numMax then
		numMax = numMin
		numMin = nil
	end

	if type(rng) == "number" then
		local seed = rng
		rng = RNG()
		rng:SetSeed(seed, 1)
	end
	
	if numMin and numMax then
		return rng:Next() % (numMax - numMin + 1) + numMin
	elseif numMax then
		return rng:Next() % numMax
	end
	return rng:Next()
end
