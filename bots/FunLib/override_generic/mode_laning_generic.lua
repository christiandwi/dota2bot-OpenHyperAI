local J = require( GetScriptDirectory()..'/FunLib/jmz_func')

BotsInit = require( "game/botsinit" )
local X = BotsInit.CreateGeneric()

local bot = GetBot()
local LowHealthThreshold = 0.4
local safeAmountFromFront = 300

function X.OnStart() end
function X.OnEnd() end

local nEnemyTowers, nEnemyCreeps, assignedLane, tangoDesire, tangoTarget, tangoSlot
local fNextMovementTime = 0

function X.GetDesire()

	tangoDesire, tangoTarget = ConsiderTango()
	if tangoDesire > 0 then
		return BOT_MODE_DESIRE_ABSOLUTE
	end

	if not assignedLane then assignedLane = GetBotTargetLane() end

	if GetGameMode() == GAMEMODE_1V1MID or GetGameMode() == GAMEMODE_MO then return 1 end

	local currentTime = DotaTime()
	local botLV = bot:GetLevel()

	if GetGameMode() == 23 then currentTime = currentTime * 1.65 end
	if currentTime <= 10 then return 0.268 end
	if currentTime <= 9 * 60 and botLV <= 7 then return 0.446 end
	if currentTime <= 12 * 60 and botLV <= 11 then return 0.369 end
	if botLV <= 15 and J.GetCoresAverageNetworth() < 12000 then return 0.228 end

	return BOT_MODE_DESIRE_VERYLOW

end

function GetHarassTarget(hEnemyList)
	for _, enemyHero in pairs(hEnemyList) do
		if J.IsValidHero(enemyHero)
		and J.CanBeAttacked(enemyHero)
		and not J.IsSuspiciousIllusion(enemyHero)
		then
			return enemyHero
		end
	end

	return nil
end

function GetBotTargetLane()
	if assignedLane then return assignedLane end

	if GetTeam() == TEAM_RADIANT then
		if J.GetPosition(bot) == 2 then
			assignedLane = LANE_MID
		end
		if J.GetPosition(bot) == 1 or J.GetPosition(bot) == 5 then
			assignedLane = LANE_BOT
		end
		if J.GetPosition(bot) == 3 or J.GetPosition(bot) == 4 then
			assignedLane = LANE_TOP
		end
	else
		if J.GetPosition(bot) == 2 then
			assignedLane = LANE_MID
		end
		if J.GetPosition(bot) == 1 or J.GetPosition(bot) == 5 then
			assignedLane = LANE_TOP
		end
		if J.GetPosition(bot) == 3 or J.GetPosition(bot) == 4 then
			assignedLane = LANE_BOT
		end
	end
	return assignedLane
end

-- Get the best last-hittable creep from a list
local function GetBestCreepToLastHit(creepList)
	if not creepList or #creepList == 0 then return nil end
	local attackDamage = bot:GetAttackDamage()
	for _, creep in pairs(creepList) do
		if J.IsValid(creep) and J.CanBeAttacked(creep) then
			local nDelay = bot:GetAttackPoint() + GetUnitToUnitDistance(bot, creep) / bot:GetAttackProjectileSpeed()
			if creep:GetHealth() <= creep:GetActualIncomingDamage(attackDamage, DAMAGE_TYPE_PHYSICAL) then
				return creep
			end
		end
	end
	return nil
end

-- Get the best deniable allied creep
local function GetBestCreepToDeny(creepList)
	if not creepList or #creepList == 0 then return nil end
	local attackDamage = bot:GetAttackDamage()
	for _, creep in pairs(creepList) do
		if J.IsValid(creep) and creep:GetHealth() > 0
		and creep:GetHealth() / creep:GetMaxHealth() < 0.5 then
			if creep:GetHealth() <= creep:GetActualIncomingDamage(attackDamage, DAMAGE_TYPE_PHYSICAL) then
				return creep
			end
		end
	end
	return nil
end

-- Drop tower aggro by right-clicking a nearby enemy creep
local function TryDropTowerAggro()
	local nEnemyTowers = bot:GetNearbyTowers(900, true)
	if J.IsValidBuilding(nEnemyTowers[1]) and bot:WasRecentlyDamagedByTower(1.5) then
		local nEnemyCreeps = bot:GetNearbyLaneCreeps(700, true)
		if J.IsValid(nEnemyCreeps[1]) then
			bot:Action_AttackUnit(nEnemyCreeps[1], true)
			return true
		end
	end
	return false
end

function X.Think()
    if not bot:IsAlive() or J.CanNotUseAction(bot) or bot:IsUsingAbility() or bot:IsChanneling() or bot:IsDisarmed() then return end

	-- Tango usage
	if tangoDesire and tangoDesire > 0 and tangoTarget then
		local hItem = bot:GetItemInSlot( tangoSlot )
		bot:Action_UseAbilityOnTree( hItem, tangoTarget )
		return
	end

	-- Tower aggro management: drop aggro by attacking a creep
	if TryDropTowerAggro() then return end

	-- Safety: retreat if taking hero damage while outnumbered
	local nAllyHeroes = bot:GetNearbyHeroes(1200, false, BOT_MODE_NONE)
	local nEnemyHeroes = bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
	if bot:WasRecentlyDamagedByAnyHero(2.0) and #nEnemyHeroes > #nAllyHeroes and J.GetHP(bot) < 0.5 then
		local safeLoc = GetLaneFrontLocation(GetTeam(), assignedLane or bot:GetAssignedLane(), -1200)
		bot:Action_MoveToLocation(safeLoc)
		return
	end

	local tEnemyLaneCreeps = bot:GetNearbyLaneCreeps(900, true)
	local tAllyLaneCreeps = bot:GetNearbyLaneCreeps(900, false)
	local botAttackRange = bot:GetAttackRange()

	-- PRIORITY 1: Last-hit enemy creeps (ALWAYS highest priority)
	local lastHitCreep = GetBestCreepToLastHit(tEnemyLaneCreeps)
	if lastHitCreep then
		if GetUnitToUnitDistance(bot, lastHitCreep) > botAttackRange then
			bot:Action_MoveToUnit(lastHitCreep)
		else
			bot:Action_AttackUnit(lastHitCreep, true)
		end
		return
	end

	-- PRIORITY 2: Deny allied creeps
	local denyCreep = GetBestCreepToDeny(tAllyLaneCreeps)
	if denyCreep then
		bot:Action_AttackUnit(denyCreep, true)
		return
	end

	-- PRIORITY 3: Harass enemy heroes (ONLY for supports, ONLY when few enemy creeps)
	-- Cores should focus on last-hits and positioning, not harassing
	if not J.IsCore(bot) then
		local tCloseEnemyCreeps = bot:GetNearbyLaneCreeps(600, true)
		local tHarassEnemies = bot:GetNearbyHeroes(botAttackRange + 150, true, BOT_MODE_NONE)
		if #tCloseEnemyCreeps <= 1 then
			local harassTarget = GetHarassTarget(tHarassEnemies)
			if J.IsValidHero(harassTarget) then
				bot:Action_AttackUnit(harassTarget, true)
				return
			end
		end
	end

	-- PRIORITY 4: Positioning — stay near lane front at safe distance
	if DotaTime() > fNextMovementTime then
		fNextMovementTime = DotaTime() + RandomFloat(0.1, 0.25)
		local nLane = assignedLane or bot:GetAssignedLane()
		local nLongestRange = math.max(botAttackRange, 250)
		if J.IsValidHero(nEnemyHeroes[1]) then
			nLongestRange = math.max(nLongestRange, nEnemyHeroes[1]:GetAttackRange())
		end
		local targetLoc = GetLaneFrontLocation(GetTeam(), nLane, -nLongestRange)
		bot:Action_MoveToLocation(targetLoc + RandomVector(50))
	end
end

function ConsiderTango()
	if bot:HasModifier('modifier_tango_heal') then return BOT_ACTION_DESIRE_NONE, nil end

	tangoDesire = 0
	tangoSlot = J.FindItemSlotNotInNonbackpack(bot, "item_tango")
	if tangoSlot < 0 then
		tangoSlot = J.FindItemSlotNotInNonbackpack(bot, "item_tango_single")
	end
	if tangoSlot >= 0
	and bot:OriginalGetMaxHealth() - bot:OriginalGetHealth() > 250
	and J.GetHP(bot) > 0.15
	and not J.IsAttacking(bot)
	and not bot:WasRecentlyDamagedByAnyHero(2) then
		local trees = bot:GetNearbyTrees( 800 )
		local targetTree = trees[1]
		local nearEnemyList = J.GetNearbyHeroes(bot, 1000, true, BOT_MODE_NONE )
		local nearestEnemy = nearEnemyList[1]
		local nearTowerList = bot:GetNearbyTowers( 1400, true )
		local nearestTower = nearTowerList[1]
		if targetTree ~= nil
		then
			local targetTreeLoc = GetTreeLocation( targetTree )
			if IsLocationVisible( targetTreeLoc )
				and IsLocationPassable( targetTreeLoc )
				and ( #nearEnemyList == 0 or GetUnitToLocationDistance( bot, targetTreeLoc ) * 1.6 < GetUnitToUnitDistance( bot, nearestEnemy ) )
				and ( #nearTowerList == 0 or GetUnitToLocationDistance( nearestTower, targetTreeLoc ) > 920 )
			then
				return BOT_ACTION_DESIRE_HIGH, targetTree
			end
		end
	end
	return BOT_ACTION_DESIRE_NONE
end

return X
