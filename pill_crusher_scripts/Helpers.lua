local Helpers = {}

local turretList = {{831,10,-1}, {835,10,-1}, {887,-1,-1}, {951,-1,-1}, {815,-1,-1}, {306,-1,-1}, {837,-1,-1}, {42,-1,-1}, {201,-1,-1}, 
{202,-1,-1}, {203,-1,-1}, {235,-1,-1}, {236,-1,-1}, {804,-1,-1}, {809,-1,-1}, {68,-1,-1}, {864,-1,-1}, {44,-1,-1}, {218,-1,-1}, {877,-1,-1},
{893,-1,-1}, {915,-1,-1}, {291,-1,-1}, {295,-1,-1}, {404,-1,-1}, {409,-1,-1}, {903,-1,-1}, {293,-1,-1}, {964,-1,-1},}


function Helpers.HereticBattle(enemy)
	local room = Game():GetRoom()
	if room:GetType() == RoomType.ROOM_BOSS and room:GetBossID() == 81 and enemy.Type == EntityType.ENTITY_EXORCIST then
		return true
	end
	return false
end


function Helpers.IsTurret(enemy)
	for _,e in ipairs(turretList) do
		if e[1] == enemy.Type and (e[2] == -1 or e[2] == enemy.Variant) and (e[3] == -1 or e[3] == enemy.SubType) then
			return true
		end
	end
	return false
end


---@param allEnemies boolean
---@param noBosses boolean | nil
---@return EntityNPC[]
function Helpers.GetEnemies(allEnemies, noBosses)
	local enemies = {}
	for _,enemy in ipairs(Isaac.GetRoomEntities()) do
		enemy = enemy:ToNPC()
		if enemy and (enemy:IsVulnerableEnemy() or allEnemies) and enemy:IsActiveEnemy() and enemy:IsEnemy() 
		and not EntityRef(enemy).IsFriendly then
			if not enemy:IsBoss() or (enemy:IsBoss() and not noBosses) then
				if enemy.Type == EntityType.ENTITY_ETERNALFLY then
					enemy:Morph(EntityType.ENTITY_ATTACKFLY,0,0,-1)
				end
				if not Helpers.HereticBattle(enemy) and not Helpers.IsTurret(enemy) and enemy.Type ~= EntityType.ENTITY_BLOOD_PUPPY then
					table.insert(enemies,enemy)
				end
			end
		end
	end
	return enemies
end


function Helpers.GetData(entity)
	if entity and entity.GetData then
		local data = entity:GetData()
		if not data.PillCrusher then
			data.PillCrusher = {}
		end
		return data
	end
	return nil
end

return Helpers