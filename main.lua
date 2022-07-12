PillCrusher = RegisterMod("Pill Crusher", 1);
local mod = PillCrusher

CollectibleType.COLLECTIBLE_PILL_CRUSHER = Isaac.GetItemIdByName("Pill Crusher");

local rangedown = 0
local luckdown = 0
local tearsdown = 0
local DrowsyExited = 0

local PCDesc = "Gives a random {{Pill}} pill when picked up#Increase pill drop rate when held#Consumes currently held pill and applies an effect to the entire room depending on the type of pill"
local PCDescSpa = "Otorga una {{Pill}} pildora aleatoria al tomarlo#Las pildoras aparecen con mas frecuencia#Consume la pildora que posees y aplica un efecto a la sala, basado en la pildora"
local PCDescRu = "Дает случайную {{Pill}} пилюлю#Увеличивает шанс появления пилюль#Использует текущую пилюлю и накладывает зависимый от её типа эффект на всю комнату"
local PCDescPt_Br = "Gere uma pílula {{Pill}} aleatória quando pego#Almente a taxa de queda de pílulas# Consome a pílula segurada e aplique um efeito na sala inteira dependendo no tipo de pílula"

if EID then
	EID:addCollectible(CollectibleType.COLLECTIBLE_PILL_CRUSHER, PCDesc, "Pill Crusher", "en_us")
	EID:addCollectible(CollectibleType.COLLECTIBLE_PILL_CRUSHER, PCDescSpa, "Triturador de Pildoras", "spa")
	EID:addCollectible(CollectibleType.COLLECTIBLE_PILL_CRUSHER, PCDescRu, "Дробилка пилюль", "ru")
	EID:addCollectible(CollectibleType.COLLECTIBLE_PILL_CRUSHER, PCDesc, "Triturador de Pílula", "pt_br")
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

function mod:AddPill(player)
    local data = GetData(player)
    data.pilldrop = data.pilldrop or player:GetCollectibleNum(CollectibleType.COLLECTIBLE_PILL_CRUSHER)

    if data.pilldrop < player:GetCollectibleNum(CollectibleType.COLLECTIBLE_PILL_CRUSHER) then
        Isaac.Spawn(5, 70, 0, player.Position, Vector(0,0), player):ToPickup()
        data.pilldrop = player:GetCollectibleNum(CollectibleType.COLLECTIBLE_PILL_CRUSHER)
    end   
end
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, mod.AddPill)

local function BombsAreKey(p, pillcolor, itempool)
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
end

local function BadGas(p,pillcolor,itempool,enemies)
	if itempool:GetPillEffect(pillcolor, p) == PillEffect.PILLEFFECT_BAD_GAS or pillcolor == PillColor.PILL_GOLD or pillcolor == 2062 then
		Game():GetHUD():ShowItemText("Bad Gas")
		for _,enemy in ipairs(enemies) do
			local cloud = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SMOKE_CLOUD, 0, enemy.Position, Vector.Zero, enemy):ToEffect()
			local multi = pillcolor > 2047 and 2 or 1
			cloud.LifeSpan = 180 / multi
			enemy:AddPoison(EntityRef(p), 60 * multi, 3 + p.Damage / 2 * (multi - 1))
		end
	end
end

local function BadTrip(p,pillcolor,itempool,enemies)
	if itempool:GetPillEffect(pillcolor, p) == PillEffect.PILLEFFECT_BAD_TRIP or pillcolor == PillColor.PILL_GOLD or pillcolor == 2062 then
		Game():GetHUD():ShowItemText("Bad Trip")
		for _,enemy in ipairs(enemies) do
			local mult = pillcolor > 2047 and 2 or 1
			enemy:TakeDamage(enemy.HitPoints / (10 / mult), DamageFlag.DAMAGE_LASER, EntityRef(p),0)
		end
	end
end

local function HPUP(p,pillcolor,itempool,enemies)
	if itempool:GetPillEffect(pillcolor, p) == PillEffect.PILLEFFECT_HEALTH_UP or pillcolor == PillColor.PILL_GOLD or pillcolor == 2062 then
		Game():GetHUD():ShowItemText("Health Up")
		for _,enemy in ipairs(enemies) do
			local mult = pillcolor > 2047 and 2 or 1
			enemy.MaxHitPoints = enemy.MaxHitPoints + 15 * mult
			enemy.HitPoints = enemy.HitPoints + 15 * mult
		end
	end
end

local function HPDOWN(p,pillcolor,itempool,enemies)
	if itempool:GetPillEffect(pillcolor, p) == PillEffect.PILLEFFECT_HEALTH_DOWN or pillcolor == PillColor.PILL_GOLD or pillcolor == 2062 then
		Game():GetHUD():ShowItemText("Health Down")
		for _,enemy in ipairs(enemies) do
			local mult = pillcolor > 2047 and 2 or 1
			enemy.MaxHitPoints = enemy.MaxHitPoints - math.min(15 * mult,enemy.MaxHitPoints / (2 - 0.5 * (-1 + mult)))
			enemy.HitPoints = enemy.HitPoints - math.min(15 * mult,enemy.HitPoints / (2 - 0.5 * (-1 + mult)))
		end
	end
end

local function FTTE(p,pillcolor,itempool,enemies)
	if itempool:GetPillEffect(pillcolor, p) == PillEffect.PILLEFFECT_FRIENDS_TILL_THE_END or pillcolor == PillColor.PILL_GOLD or pillcolor == 2062 then
		Game():GetHUD():ShowItemText("Friends till the end!")
		local rng = p:GetCollectibleRNG(CollectibleType.COLLECTIBLE_PILL_CRUSHER)
		for _,enemy in ipairs(enemies) do
			local data = GetData(enemy)
			data.SpawnFliesOnDeath = { Fly = pillcolor > 2047 and mod:GetRandomNumber(1, 3, rng) or 1, Parent = p}
		end
	end
end

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


local function FullHealth(p,pillcolor,itempool,enemies)
	if itempool:GetPillEffect(pillcolor, p) == PillEffect.PILLEFFECT_FULL_HEALTH or pillcolor == PillColor.PILL_GOLD or pillcolor == 2062 then
		Game():GetHUD():ShowItemText("Full health")
		for _,enemy in ipairs(enemies) do
			enemy.HitPoints = enemy.MaxHitPoints
		end
	end
end

local function ImExited(p,pillcolor,itempool)
	if itempool:GetPillEffect(pillcolor, p) == PillEffect.PILLEFFECT_IM_EXCITED or pillcolor == PillColor.PILL_GOLD or pillcolor == 2062 then
		Game():GetHUD():ShowItemText("I'm excited!!!")
		DrowsyExited = 1
	end
end

local function ImDrowsy(p,pillcolor,itempool)
	if itempool:GetPillEffect(pillcolor, p) == PillEffect.PILLEFFECT_IM_DROWSY or pillcolor == PillColor.PILL_GOLD or pillcolor == 2062 then
		Game():GetHUD():ShowItemText("I'm drowsy...")
		DrowsyExited = pillcolor > 2047 and 4 or 2
		for _,p in ipairs(Isaac.FindByType(EntityType.ENTITY_PLAYER)) do
			p = p:ToPlayer()
			p:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
			p:EvaluateItems()
		end
	end
end

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

local function BallsOfSteel(p,pillcolor,itempool,enemies)
	if itempool:GetPillEffect(pillcolor, p) == PillEffect.PILLEFFECT_BALLS_OF_STEEL or pillcolor == PillColor.PILL_GOLD or pillcolor == 2062 then
		Game():GetHUD():ShowItemText("Balls of Steel")
		for _,enemy in ipairs(enemies) do
			local mult = pillcolor > 2047 and 1.5 or 3
			local data = GetData(enemy)
			data.Armor = enemy.MaxHitPoints / mult
		end
	end
end

function mod:BallsOfSteelArmor(e, damage, flags, source, cd)
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
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, mod.BallsOfSteelArmor)

function mod:BallsOfSteelArmorIndicator(npc)
	local data = GetData(npc)
	if data.Armor then
		local color = Color(1,1,1,1)
		color:SetColorize(0,0,0.6,0.35)
		npc:GetSprite().Color = color
	end
end
mod:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, mod.BallsOfSteelArmorIndicator)

function mod:use_pillcrusher(boi, rng, p, slot, data)
	local pillcolor = p:GetPill(0)
	if pillcolor == 0 then return false end
	local itempool = Game():GetItemPool()
	local enemies = {}
	for _,enemy in ipairs(Isaac.GetRoomEntities()) do
		enemy = enemy:ToNPC()
		if enemy and enemy:IsVulnerableEnemy() and enemy:IsActiveEnemy() and enemy:IsEnemy() then
			table.insert(enemies,enemy)
		end
	end
	BadGas(p, pillcolor, itempool,enemies)
	BadTrip(p, pillcolor, itempool,enemies)
	HPDOWN(p, pillcolor, itempool,enemies)
	HPUP(p, pillcolor, itempool,enemies)
	FTTE(p, pillcolor, itempool,enemies)
	FullHealth(p, pillcolor, itempool,enemies)
	BallsOfSteel(p, pillcolor, itempool,enemies)
	BombsAreKey(p, pillcolor, itempool)
	ImExited(p, pillcolor, itempool)
	ImDrowsy(p, pillcolor, itempool)
	
	
	if pillcolor ~= 0 then
		itempool:IdentifyPill(pillcolor)
		p:SetPill(0,0)
	end
	SFXManager():Play(462, 1, 2, false, 1, 0)
	return true
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.use_pillcrusher, CollectibleType.COLLECTIBLE_PILL_CRUSHER)

function mod:player_effect( p )
	for i, e in pairs(Isaac.FindByType(EntityType.ENTITY_PLAYER, 0, -1, false, false)) do
		local p = e:ToPlayer()
		for _, entity in pairs(Isaac.GetRoomEntities()) do
			if entity.Type == 9 then
				if rangedown > 0 then
					local proj = entity:ToProjectile()
					proj.Height = proj.Height + 7
				end
				if tearsdown > 0 then
					local proj = entity:ToProjectile()
					proj:Remove()
				end
				if luckdown > 0 then
					local proj = entity:ToProjectile()
					proj.ProjectileFlags = 0
				end
			end
		end
		rangedown = rangedown - 1
		luckdown = luckdown - 1
		tearsdown = tearsdown - 1
	end
end
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.player_effect, EntityType.ENTITY_PLAYER)

function mod:spawnPill(rng, pos)
	local spawnposition = Game():GetRoom():FindFreePickupSpawnPosition(pos)
	for i=0, Game():GetNumPlayers()-1 do
		local player = Isaac.GetPlayer(i)
		if player:HasCollectible(CollectibleType.COLLECTIBLE_PILL_CRUSHER) == true and mod:GetRandomNumber(1,3,rng) == 1 then
			print("should spawn")
			Isaac.Spawn(5, 70, 0, spawnposition, Vector.Zero, player)
		end
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, mod.spawnPill)

--spawns 3 pills on greed mode
function mod:item_effect()
	local room = Game():GetRoom()
	for i=0, Game():GetNumPlayers()-1 do
		local player = Isaac.GetPlayer(i)
		if player:HasCollectible(CollectibleType.COLLECTIBLE_PILL_CRUSHER) == true and Game():IsGreedMode() == true then
			Isaac.Spawn(5, 70, 0, player.Position, Vector.FromAngle(math.random(0,360)):Resized(3), player)
			Isaac.Spawn(5, 70, 0, player.Position, Vector.FromAngle(math.random(0,360)):Resized(3), player)
			Isaac.Spawn(5, 70, 0, player.Position, Vector.FromAngle(math.random(0,360)):Resized(3), player)
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
