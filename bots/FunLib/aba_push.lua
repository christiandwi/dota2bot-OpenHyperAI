local Push = {}
local J = require( GetScriptDirectory()..'/FunLib/jmz_func')

local ShouldNotPushLane = false
local LanePushCooldown = 0
local LanePush = LANE_MID

local GlyphDuration = 7
local ShoulNotPushTower = false
local TowerPushCooldown = 0
local StartToPushTime = 16 * 60 -- after x mins, start considering to push.
local PushDuration = 4.5 * 60 -- keep pushing for x mins.
local PushGapMinutes = 6 -- only push once in x mins.
local lastPushTime = 0
local teamAveLvl = 0
local nEffctiveEnemyHeroesNearPushLoc = 0

local pingTimeDelta = 5
local targetBuilding = nil

function Push.GetPushDesire(bot, lane)
    local botName = bot:GetUnitName()
	if bot:IsInvulnerable() or not bot:IsHero() or not bot:IsAlive() or not string.find(botName, "hero") or bot:IsIllusion() then return BOT_MODE_DESIRE_NONE end

    if bot.laneToPush == nil then bot.laneToPush = lane end

    targetBuilding = nil
    local maxDesire = 0.95
	local nSearchRange = 2000
    local nModeDesire = bot:GetActiveModeDesire()
    local nInRangeEnemy = bot:GetNearbyHeroes(900, true, BOT_MODE_NONE)
    local laneFront = GetLaneFrontLocation(GetTeam(), lane, 0)
    local distanceToLaneFront = GetUnitToLocationDistance(bot, laneFront)
    local lEnemyHeroesAroundLoc = J.GetLastSeenEnemiesNearLoc(laneFront, nSearchRange)
    nEffctiveEnemyHeroesNearPushLoc = #lEnemyHeroesAroundLoc + #J.Utils.GetAllyIdsInTpToLocation(laneFront, nSearchRange)

	teamAveLvl = J.GetAverageLevel( false )

	if nInRangeEnemy ~= nil and #nInRangeEnemy > 0
    or (bot:GetAssignedLane() ~= lane and J.GetPosition(bot) == 1 and bot:GetLevel() < 12)
    or (J.IsDoingRoshan(bot) and #J.GetAlliesNearLoc(J.GetCurrentRoshanLocation(), 2800) >= 3)
	then
		return BOT_MODE_DESIRE_NONE
	end

    -- do not push too early.
    local currentTime = DotaTime()
    local nH, _ = J.Utils.NumHumanBotPlayersInTeam(GetOpposingTeam())
    if nH > 0 then
        if GetGameMode() == 23 then
            currentTime = currentTime * 1.6
        end
        if currentTime <= StartToPushTime
        then
            return BOT_MODE_DESIRE_NONE
        end
    end
    if teamAveLvl < 8 then return BOT_MODE_DESIRE_NONE end

	if J.IsDefending(bot) and nModeDesire > 0.8
    then
        maxDesire = 0.80
    end

    local human, humanPing = J.GetHumanPing()
	if human ~= nil and DotaTime() > pingTimeDelta
	then
		local isPinged, pingedLane = J.IsPingCloseToValidTower(GetOpposingTeam(), humanPing)
		if isPinged and lane == pingedLane
		and DotaTime() < humanPing.time + pingTimeDelta
		then
			return BOT_ACTION_DESIRE_ABSOLUTE * 0.95
		end
	end

    if ShoulNotPushTower
    then
        if DotaTime() < TowerPushCooldown + GlyphDuration
        then
            return BOT_ACTION_DESIRE_NONE
        else
            ShoulNotPushTower = false
            TowerPushCooldown = 0
        end
    end

    if ShouldNotPushLane
    then
        if DotaTime() < LanePushCooldown + 10
        then
            if LanePush == lane then
                return BOT_MODE_DESIRE_NONE
            end
        else
            ShouldNotPushLane = false
            LanePushCooldown = 0
        end
    end

    local aAliveCount = J.GetNumOfAliveHeroes(false)
    local eAliveCount = J.GetNumOfAliveHeroes(true)
    local allyKills = J.GetNumOfTeamTotalKills(false) + 1
    local enemyKills = J.GetNumOfTeamTotalKills(true) + 1
    local aAliveCoreCount = J.GetAliveCoreCount(false)
    local eAliveCoreCount = J.GetAliveCoreCount(true)
    local nPushDesire = GetPushLaneDesire(lane)
    local nEnemyAncient = GetAncient(GetOpposingTeam())
    local teamHasAegis = J.DoesTeamHaveAegis()
    local nMissingEnemyHeroes = J.Utils.CountMissingEnemyHeroes()

    local botTarget = bot:GetAttackTarget()
    if J.IsValidBuilding(botTarget)
    then
        if botTarget:HasModifier('modifier_fountain_glyph')
        and not (aAliveCount >= eAliveCount + 2)
        then
            ShoulNotPushTower = true
            TowerPushCooldown = DotaTime()
            return BOT_ACTION_DESIRE_NONE
        end

        if botTarget:HasModifier('modifier_backdoor_protection')
        or botTarget:HasModifier('modifier_backdoor_protection_in_base')
        or botTarget:HasModifier('modifier_backdoor_protection_active')
        then
            return BOT_ACTION_DESIRE_NONE
        end
    end

    if GetUnitToUnitDistance(bot, nEnemyAncient) < nSearchRange * 0.8
    and J.CanBeAttacked(nEnemyAncient)
    and not bot:WasRecentlyDamagedByAnyHero(1)
    and J.GetHP(bot) > 0.5 then
        bot:SetTarget(nEnemyAncient)
        bot:Action_AttackUnit(nEnemyAncient, true)
        return BOT_ACTION_DESIRE_ABSOLUTE * 0.98
    end

    if bot:WasRecentlyDamagedByTower(3)
    or J.GetHP(bot) < 0.45
    then
        return BOT_ACTION_DESIRE_NONE
    end

    local enemyCountInLane = J.GetEnemyCountInLane(lane)
    if enemyCountInLane > 0
    then
        local nInRangeAlly = J.GetAlliesNearLoc(GetLaneFrontLocation(GetTeam(), lane, 0), nSearchRange * 0.8)

        if enemyCountInLane > #nInRangeAlly
        then
            ShouldNotPushLane = true
            LanePushCooldown = DotaTime()
            LanePush = lane
            return BOT_MODE_DESIRE_NONE
        end
    end

    local vEnemyLaneFrontLocation = GetLaneFrontLocation(GetOpposingTeam(), lane, 0)

    local nInRangeAlly__ = J.GetAlliesNearLoc(vEnemyLaneFrontLocation, nSearchRange * 0.8)
    local nInRangeEnemy__ = J.Utils.GetLastSeenEnemyIdsNearLocation(vEnemyLaneFrontLocation, nSearchRange * 0.8)
    if (#nInRangeAlly__ < #nInRangeEnemy__)
    or ( teamAveLvl < 10
        and J.Utils.IsNearEnemySecondTierTower(bot, nSearchRange * 0.9)
        and #nInRangeAlly__ < eAliveCount )
    or ( teamAveLvl < 13
        and J.Utils.IsNearEnemyHighGroundTower(bot, nSearchRange * 0.9)
        and #nInRangeAlly__ < eAliveCount )
    then
        ShouldNotPushLane = true
        LanePushCooldown = DotaTime()
        LanePush = lane
        return BOT_MODE_DESIRE_NONE
    end

    -- 应该攻击建筑物而不是英雄
    if J.Utils.IsNearEnemyHighGroundTower(bot, 1000) then
        if J.IsValidHero(botTarget)
        and (J.GetHP(bot) < J.GetHP(botTarget) or not J.CanKillTarget(botTarget, bot:GetAttackDamage() * 2.5, DAMAGE_TYPE_PHYSICAL))
        and not J.IsInRange(bot, botTarget, bot:GetAttackRange() - 30) then
                targetBuilding = J.Utils.GetClosestTowerOrBarrackToAttack(bot)
                if targetBuilding then
                    bot:SetTarget(targetBuilding)
                    return BOT_MODE_DESIRE_VERYHIGH
                end
        end
    end

    -- 前中期推进
    if teamAveLvl < 12 then
        local nAllies = J.GetAlliesNearLoc(bot:GetLocation(), nSearchRange * 0.8)
        if #nAllies >= nEffctiveEnemyHeroesNearPushLoc + nMissingEnemyHeroes - 2 then
            if distanceToLaneFront < 2000 then
                local nDistance, cTower = J.Utils.GetDistanceToCloestTower(bot)
                if cTower and nDistance < 3000 then
                    return RemapValClamped(J.GetHP(bot), 0, 0.8, BOT_MODE_DESIRE_NONE, BOT_MODE_DESIRE_HIGH)
                end
            end
        else
            return BOT_MODE_DESIRE_NONE
        end
        return BOT_MODE_DESIRE_LOW
    elseif teamAveLvl < 18 then
        local nAllies = J.GetAlliesNearLoc(bot:GetLocation(), nSearchRange * 0.8)
        if #nAllies > nEffctiveEnemyHeroesNearPushLoc + nMissingEnemyHeroes - 2 then
            if distanceToLaneFront < 2000 then
                local nDistance, cTower = J.Utils.GetDistanceToCloestTower(bot)
                if cTower and nDistance < 3000 then
                    return RemapValClamped(J.GetHP(bot), 0, 0.8, BOT_MODE_DESIRE_NONE, BOT_MODE_DESIRE_HIGH)
                end
            end
        else
            return BOT_MODE_DESIRE_NONE
        end
        return BOT_MODE_DESIRE_LOW
    end

    -- General Push
    if Push.WhichLaneToPush(bot) == lane then
        if eAliveCount == 0
        or aAliveCoreCount >= eAliveCoreCount
        or (aAliveCoreCount >= 1 and aAliveCount >= eAliveCount + 2)
        then
            if teamHasAegis
            then
                local aegis = 1.3
                nPushDesire = nPushDesire * aegis
            end

            if aAliveCount >= eAliveCount
            and J.GetAverageLevel( false ) >= 12
            then
                -- nPushDesire = nPushDesire * RemapValClamped(allyKills / enemyKills, 1, 2, 1, 2)
                nPushDesire = nPushDesire + RemapValClamped(allyKills / enemyKills, 1, 2, 0.0, 1)
            end

            bot.laneToPush = lane

            nPushDesire = Clamp(nPushDesire, 0, maxDesire)
            return nPushDesire
        end
    end

    return BOT_MODE_DESIRE_NONE
end

function IsGroupPushingTime()
    local minute = math.floor(DotaTime() / 60)
    return math.fmod(minute, PushGapMinutes) == 0
        or DotaTime() - lastPushTime < PushDuration
        or J.IsAnyAllyHeroSurroundedByManyAllies()
        or J.GetCoresAverageNetworth() > 22000
        or minute >= 50
        or teamAveLvl > 20
        or teamHasAegis
        or J.GetNumOfTeamTotalKills( false ) <= J.GetNumOfTeamTotalKills(true) - 20
        -- or J.Utils.IsTeamPushingSecondTierOrHighGround(bot)
end

function Push.WhichLaneToPush(bot)

    local distanceToTop = 0
    local distanceToMid = 0
    local distanceToBot = 0

    for i = 1, #GetTeamPlayers( GetTeam() ) do
        local member = GetTeamMember(i)
        if member ~= nil and member:IsAlive() then
            local teamLoc = member:GetLocation()
            if J.GetPosition(member) <= 3 then
                distanceToTop = math.max(distanceToTop, J.GetDistance(GetLaneFrontLocation(GetTeam(),LANE_TOP, 0), teamLoc))
                distanceToMid = math.max(distanceToMid, J.GetDistance(GetLaneFrontLocation(GetTeam(),LANE_MID, 0), teamLoc))
                distanceToBot = math.max(distanceToBot, J.GetDistance(GetLaneFrontLocation(GetTeam(),LANE_BOT, 0), teamLoc))
            end
        end
    end

    local topLaneScore = CalculateLaneScore(distanceToTop, LANE_TOP)
    local midLaneScore = CalculateLaneScore(distanceToMid, LANE_MID)
    local botLaneScore = CalculateLaneScore(distanceToBot, LANE_BOT)

    if midLaneScore <= topLaneScore and midLaneScore <= botLaneScore then return LANE_MID end
    if topLaneScore <= midLaneScore and topLaneScore <= botLaneScore then return LANE_TOP end
    if botLaneScore <= topLaneScore and botLaneScore <= midLaneScore then return LANE_BOT end

    return nil
end

-- the smaller the better
function CalculateLaneScore(distance, lane)
    local hasBarracks = J.Utils.IsAnyBarracksOnLaneAlive(true, lane)
    local delta = 2500
    if hasBarracks then
        delta = 0
    end
    return distance + delta
end

function Push.TeamPushLane()

    local team = TEAM_RADIANT

    if GetTeam() == TEAM_RADIANT then
        team = TEAM_DIRE
    end

    if GetTower(team, TOWER_MID_1) ~= nil then
        return LANE_MID;
    end
    if GetTower(team, TOWER_BOT_1) ~= nil then
        return LANE_BOT;
    end
    if GetTower(team, TOWER_TOP_1) ~= nil then
        return LANE_TOP;
    end

    if GetTower(team, TOWER_MID_2) ~= nil then
        return LANE_MID;
    end
    if GetTower(team, TOWER_BOT_2) ~= nil then
        return LANE_BOT;
    end
    if GetTower(team, TOWER_TOP_2) ~= nil then
        return LANE_TOP;
    end

    if GetTower(team, TOWER_MID_3) ~= nil
    or GetBarracks(team, BARRACKS_MID_MELEE) ~= nil
    or GetBarracks(team, BARRACKS_MID_RANGED) ~= nil then
        return LANE_MID;
    end

    if GetTower(team, TOWER_BOT_3) ~= nil 
    or GetBarracks(team, BARRACKS_BOT_MELEE) ~= nil
    or GetBarracks(team, BARRACKS_BOT_RANGED) ~= nil then
        return LANE_BOT;
    end

    if GetTower(team, TOWER_TOP_3) ~= nil
    or GetBarracks(team, BARRACKS_TOP_MELEE) ~= nil
    or GetBarracks(team, BARRACKS_TOP_RANGED) ~= nil then
        return LANE_TOP;
    end

    return LANE_MID
end

function Push.PushThink(bot, lane)
    if J.CanNotUseAction(bot) then return end

    if J.IsValidBuilding(targetBuilding) then
        bot:Action_AttackUnit(targetBuilding, true)
        return
    end

    local botAttackRange = bot:GetAttackRange()
    local fDeltaFromFront = (Min(J.GetHP(bot), 0.7) * 1000 - 700) + RemapValClamped(botAttackRange, 300, 700, 0, -600)
    local nEnemyTowers = bot:GetNearbyTowers(1600, true)
    local targetLoc = GetLaneFrontLocation(GetTeam(), lane, fDeltaFromFront)
    targetLoc = J.Utils.GetOffsetLocationTowardsTargetLocation(targetLoc, J.GetTeamFountain(), 200 + RandomVector(300))

    local nEnemyAncient = GetAncient(GetOpposingTeam())
    if  GetUnitToUnitDistance(bot, nEnemyAncient) < 1600
    and J.CanBeAttacked(nEnemyAncient)
    then
        bot:Action_AttackUnit(nEnemyAncient, true)
        return
    end

    local nCreeps = bot:GetNearbyLaneCreeps(math.min(700 + botAttackRange, 1600), true)
    if  nCreeps ~= nil and #nCreeps > 0
    and J.CanBeAttacked(nCreeps[1])
    then
        bot:Action_AttackUnit(nCreeps[1], true)
        return
    end

    local nBarracks = bot:GetNearbyBarracks(math.min(700 + botAttackRange, 1600), true)
    if  nBarracks ~= nil and #nBarracks > 0
    and Push.CanBeAttacked(nBarracks[1])
    then
        bot:Action_AttackUnit(nBarracks[1], true)
        return
    end

    if  nEnemyTowers ~= nil and #nEnemyTowers > 0
    and Push.CanBeAttacked(nEnemyTowers[1])
    then
        bot:Action_AttackUnit(nEnemyTowers[1], true)
        return
    end

    local sEnemyTowers = bot:GetNearbyFillers(math.min(700 + botAttackRange, 1600), true)
    if  sEnemyTowers ~= nil and #sEnemyTowers > 0
    and Push.CanBeAttacked(sEnemyTowers[1])
    then
        bot:Action_AttackUnit(sEnemyTowers[1], true)
        return
    end

    bot:Action_MoveToLocation(targetLoc)
end

function Push.CanBeAttacked(building)
    if  building ~= nil
    and building:CanBeSeen()
    and not building:IsInvulnerable()
    then
        return true
    end

    return false
end

return Push