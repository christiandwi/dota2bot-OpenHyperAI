----------------------------------------------------------------------------------------------------
--- The Creation Come From: BOT EXPERIMENT Credit:FURIOUSPUPPY
--- BOT EXPERIMENT Author: Arizona Fauzie 2018.11.21
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=837040016
--- Refactor: 决明子 Email: dota2jmz@163.com 微博@Dota2_决明子
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1573671599
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1627071163
----------------------------------------------------------------------------------------------------
local X = {}
local bDebugMode = ( 1 == 10 )
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sRole = J.Item.GetRoleItemsBuyList( bot )

local tTalentTreeList = {
						['t25'] = {0, 10},
						['t20'] = {0, 10},
						['t15'] = {0, 10},
						['t10'] = {10, 0},
}


local tAllAbilityBuildList = {
						{1,3,3,1,3,6,3,1,1,2,6,2,2,2,6},
}

local nAbilityBuildList = J.Skill.GetRandomBuild( tAllAbilityBuildList )

local nTalentBuildList = J.Skill.GetTalentBuild( tTalentTreeList )

local sRoleItemsBuyList = {}

sRoleItemsBuyList['pos_4'] = {
	"item_tango",
	"item_tango",
	"item_double_branches",
	"item_blood_grenade",

	"item_magic_wand",
	"item_arcane_boots",
	"item_glimmer_cape",--
	"item_guardian_greaves",--
	"item_aghanims_shard",
	"item_force_staff",--
	"item_ultimate_scepter",
	"item_shivas_guard",--
	"item_refresher",--
	"item_octarine_core",--
	"item_ultimate_scepter_2",
	"item_moon_shard",
}

sRoleItemsBuyList['pos_5'] = {
	"item_tango",
	"item_tango",
	"item_double_branches",
	"item_blood_grenade",

	"item_magic_wand",
	"item_tranquil_boots",
	"item_glimmer_cape",--
	"item_pipe",
	"item_aghanims_shard",
	"item_force_staff",--
	"item_ultimate_scepter",
	"item_shivas_guard",--
	"item_boots_of_bearing",--
	"item_refresher",--
	"item_octarine_core",--
	"item_ultimate_scepter_2",
	"item_moon_shard",
}

sRoleItemsBuyList['pos_1'] = {
	"item_tango",
	"item_tango",
	"item_double_branches",

	"item_arcane_boots",
	"item_magic_wand",
	"item_glimmer_cape",--
	"item_force_staff",--
	"item_aghanims_shard",
	"item_ultimate_scepter",
	"item_shivas_guard",--
    "item_maelstrom",
	"item_gungir",--
	"item_refresher",--
	"item_octarine_core",--
	"item_ultimate_scepter_2",
	"item_moon_shard",
}

sRoleItemsBuyList['pos_2'] = {
	"item_mage_outfit",
	"item_shadow_amulet",
	"item_kaya",
	"item_veil_of_discord",
	"item_glimmer_cape",--
	"item_kaya_and_sange",--
    "item_maelstrom",
	"item_shivas_guard",--
	"item_aghanims_shard",
    "item_gungir",
	"item_sheepstick",--
	"item_refresher",--
	"item_heart",--
	-- "item_wind_waker",--
	"item_moon_shard",
	"item_ultimate_scepter_2",
	"item_travel_boots_2",--
}


sRoleItemsBuyList['pos_3'] = sRoleItemsBuyList['pos_2']

X['sBuyList'] = sRoleItemsBuyList[sRole]

X['sSellList'] = {

	"item_black_king_bar",
	"item_quelling_blade",

	"item_heart",
	"item_glimmer_cape",
}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_priest' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = true


local abilityQ = bot:GetAbilityByName( sAbilityList[1] )
local abilityW = bot:GetAbilityByName( sAbilityList[2] )
local abilityE = bot:GetAbilityByName( sAbilityList[3] )
local abilityR = bot:GetAbilityByName( sAbilityList[6] )
local talent2 = bot:GetAbilityByName( sTalentList[2] )
local talent6 = bot:GetAbilityByName( sTalentList[6] )


local castQDesire, castQTarget
local castWDesire, castWTarget
local castEDesire, castELocation
local castRDesire, castRLocation
local castRFRDesire, castRFRLocation

local nKeepMana, nMP, nHP, nLV, hEnemyHeroList
local aetherRange = 0

local abilityRef = nil


function X.MinionThink(hMinionUnit)

	if Minion.IsValidUnit( hMinionUnit )
		and ( not J.IsKeyWordUnit( 'npc_dota_warlock_minor_imp', hMinionUnit ) )
	then
		Minion.IllusionThink( hMinionUnit )
	end

	-- if Minion.IsValidUnit( hMinionUnit )
	-- then
	-- 	if string.find(hMinionUnit:GetUnitName(), "warlock_golem") then
	-- 		local target = J.GetProperTarget( bot )
	-- 		local hMinionUnitTarget = hMinionUnit:GetTarget()
		
	-- 		if target ~= nil then
	-- 			hMinionUnit:Action_AttackUnit(target, false)
	-- 			return
	-- 		end
	-- 		if hMinionUnitTarget ~= nil then
	-- 			hMinionUnit:Action_AttackUnit(hMinionUnitTarget, false)
	-- 			return
	-- 		end

	-- 		if hEnemyHeroList == nil then
	-- 			hEnemyHeroList = J.GetNearbyHeroes(bot, 1600, true, BOT_MODE_NONE )
	-- 		end
			
	-- 		if bot:IsAlive() and #hEnemyHeroList <= 0 then
	-- 			if GetUnitToUnitDistance(hMinionUnit, bot) > 500 then
	-- 				hMinionUnit:Action_MoveToLocation(bot:GetLocation())
	-- 			else
	-- 				hMinionUnit:Action_MoveToLocation(bot:GetLocation() + RandomVector(200))
	-- 			end
	-- 			return
	-- 		end
	-- 	end

	-- 	Minion.MinionThink(hMinionUnit)
	-- end

end


--[[

npc_dota_hero_warlock

"Ability1"		"warlock_fatal_bonds"
"Ability2"		"warlock_shadow_word"
"Ability3"		"warlock_upheaval"
"Ability4"		"generic_hidden"
"Ability5"		"generic_hidden"
"Ability6"		"warlock_rain_of_chaos"
"Ability10"		"special_bonus_unique_warlock_5"
"Ability11"		"special_bonus_cast_range_150"
"Ability12"		"special_bonus_exp_boost_60"
"Ability13"		"special_bonus_unique_warlock_3"
"Ability14"		"special_bonus_unique_warlock_4"
"Ability15"		"special_bonus_unique_warlock_6"
"Ability16"		"special_bonus_unique_warlock_2"
"Ability17"		"special_bonus_unique_warlock_1"

modifier_warlock_fatal_bonds
modifier_warlock_shadow_word
modifier_warlock_upheaval
modifier_warlock_rain_of_chaos_death_trigger
modifier_warlock_rain_of_chaos_thinker
modifier_special_bonus_unique_warlock_1
modifier_special_bonus_unique_warlock_2
modifier_warlock_golem_flaming_fists
modifier_warlock_golem_permanent_immolation
modifier_warlock_golem_permanent_immolation_debuff

--]]


function X.SkillsComplement()
	X.WarlockShouldMove()
	if J.CanNotUseAbility( bot ) or bot:IsInvisible() then return end

	nKeepMana = 400
	aetherRange = 0
	nLV = bot:GetLevel()
	nMP = bot:GetMana()/bot:GetMaxMana()
	nHP = bot:GetHealth()/bot:GetMaxHealth()
	hEnemyHeroList = J.GetNearbyHeroes(bot, 1600, true, BOT_MODE_NONE )
	abilityRef = J.IsItemAvailable( "item_refresher" )

	local aether = J.IsItemAvailable( "item_aether_lens" )
	if aether ~= nil then aetherRange = 250 end


	castRFRDesire, castRFRLocation = X.ConsiderRFR()
	if ( castRFRDesire > 0 )
	then

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbilityOnLocation( abilityR, castRFRLocation + RandomVector( 50 ) )
		bot:ActionQueue_UseAbility( abilityRef )
		bot:ActionQueue_UseAbilityOnLocation( abilityR, castRFRLocation + RandomVector( 50 ) )
		return

	end


	castRDesire, castRLocation = X.ConsiderR()
	if ( castRDesire > 0 )
	then

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbilityOnLocation( abilityR, castRLocation )
		return

	end


	castQDesire, castQTarget = X.ConsiderQ()
	if ( castQDesire > 0 )
	then

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbilityOnEntity( abilityQ, castQTarget )
		return
	end


	castWDesire, castWTarget = X.ConsiderW()
	if ( castWDesire > 0 )
	then

		J.SetQueuePtToINT( bot, true )
		
		bot:ActionQueue_UseAbilityOnEntity( abilityW, castWTarget )

		return
	end

	castEDesire, castELocation = X.ConsiderE()
	if ( castEDesire > 0 )
	then

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbilityOnLocation( abilityE, castELocation )
		return
	end


end

function X.WarlockShouldMove()
	if bot:IsAlive()
	and bot:IsChanneling()
	and not bot:HasModifier( "modifier_teleporting" )
	and bot:GetActiveMode() ~= BOT_MODE_SIDE_SHOP
	and #J.GetNearbyHeroes(bot, 1000, true, BOT_MODE_NONE ) >= 1
	and bot:WasRecentlyDamagedByAnyHero(3)
	and J.GetHP(bot) < 0.5
	then
		bot:Action_ClearActions( true )
		bot:Action_MoveToLocation(J.GetTeamFountain())
		return
	end
end

function X.ConsiderR()

	if not abilityR:IsFullyCastable() then return BOT_ACTION_DESIRE_NONE, nil	end

	if abilityQ:IsFullyCastable()
		and bot:GetMana() >= ( abilityQ:GetManaCost() + abilityR:GetManaCost() )
		and nHP > 0.5
	then
		return BOT_ACTION_DESIRE_NONE, nil
	end

	local nCastRange = abilityR:GetCastRange() + aetherRange
	local nCastPoint = abilityR:GetCastPoint()
	local manaCost = abilityR:GetManaCost()
	local nRadius = abilityR:GetSpecialValueInt( "aoe" )
	local hTrueHeroList = J.GetEnemyList( bot, 1400 )


	local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius, 0, 0 )
	if ( locationAoE.count >= 2 and #hTrueHeroList >= 2 )
		or locationAoE.count >= 3
	then
		return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc
	end
	if locationAoE.count >= 1 and J.GetHP( bot ) < 0.38 and #hTrueHeroList >= 1
	then
		return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc
	end


	--进攻时
	if J.IsGoingOnSomeone( bot )
	then
		local npcTarget = J.GetProperTarget( bot )
		if J.IsValidHero( npcTarget )
			and J.CanCastOnMagicImmune( npcTarget )
			and J.IsInRange( npcTarget, bot, nCastRange + 200 )
		then
			if #hTrueHeroList >= 2 then
				return BOT_ACTION_DESIRE_HIGH, npcTarget:GetExtrapolatedLocation( nCastPoint )
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderRFR()

	if not abilityR:IsFullyCastable()
		or abilityRef == nil
		or not abilityRef:IsFullyCastable()
	then return BOT_ACTION_DESIRE_NONE, nil end

	if abilityQ:IsFullyCastable()
		and bot:GetMana() >= ( abilityQ:GetManaCost() + abilityR:GetManaCost() )
		and nHP > 0.5
	then
		return BOT_ACTION_DESIRE_NONE, nil
	end

	if bot:GetMana() < abilityR:GetManaCost() * 2 + abilityRef:GetManaCost()
	then
		return BOT_ACTION_DESIRE_NONE, nil
	end

	local nCastRange = abilityR:GetCastRange() + aetherRange
	local nCastPoint = abilityR:GetCastPoint()
	local manaCost = abilityR:GetManaCost()
	local nRadius = abilityR:GetSpecialValueInt( "aoe" )
	local hTrueHeroList = J.GetEnemyList( bot, 1600 )

	--进攻时
	if J.IsGoingOnSomeone( bot )
	then
		local npcTarget = J.GetProperTarget( bot )
		if J.IsValidHero( npcTarget )
			and J.CanCastOnMagicImmune( npcTarget )
			and J.IsInRange( npcTarget, bot, nCastRange + 200 )
		then
			if #hTrueHeroList >= 3 then
				return BOT_ACTION_DESIRE_HIGH, npcTarget:GetExtrapolatedLocation( nCastPoint )
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderE()

	if not abilityE:IsFullyCastable() then return BOT_ACTION_DESIRE_NONE, nil end

	if abilityR:IsFullyCastable()
		or abilityQ:IsFullyCastable()
		or abilityW:IsFullyCastable()
	then
		return BOT_ACTION_DESIRE_NONE, nil
	end

	local nCastRange = abilityE:GetCastRange() + 30 + aetherRange
	local nCastPoint = abilityE:GetCastPoint()
	local manaCost = abilityE:GetManaCost()
	local nRadius = abilityE:GetSpecialValueInt( "aoe" )

	if J.IsInTeamFight( bot, 1200 )
	then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius/2, 0, 0 )
		if ( locationAoE.count >= 2 )
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc
		end
	end

	if J.IsGoingOnSomeone( bot )
	then
		local npcTarget = J.GetProperTarget( bot )
		if J.IsValidHero( npcTarget )
			and J.CanCastOnNonMagicImmune( npcTarget )
			and J.IsInRange( npcTarget, bot, nCastRange + 200 )
		then
			local enemies = J.GetNearbyHeroes(npcTarget, nRadius, false, BOT_MODE_NONE )
			if #enemies >= 2 then
				return BOT_ACTION_DESIRE_HIGH, npcTarget:GetExtrapolatedLocation( nCastPoint )
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE, nil
end

local lastCheck = -90
function X.ConsiderW()

	if not abilityW:IsFullyCastable() then	return BOT_ACTION_DESIRE_NONE, nil	end

	local nCastRange = abilityW:GetCastRange() + 50 + aetherRange
	local nCastPoint = abilityW:GetCastPoint()
	local manaCost = abilityW:GetManaCost()
	local nRadius = 0

	if talent6:IsTrained() then nRadius = 250 end

	if DotaTime() >= lastCheck + 0.5 then
		local weakest = nil
		local minHP = 100000
		local allies = J.GetNearbyHeroes(bot, nCastRange, false, BOT_MODE_NONE )
		if #allies > 0 then
			for i=1, #allies do
				if not allies[i]:HasModifier( "modifier_warlock_shadow_word" )
					and J.CanCastOnNonMagicImmune( allies[i] )
					and allies[i]:GetHealth() <= minHP
	 				and allies[i]:GetHealth() <= 0.65 * allies[i]:GetMaxHealth()
				then
					weakest = allies[i]
					minHP = allies[i]:GetHealth()
				end
			end
		end
		if weakest ~= nil 
		then
			return BOT_ACTION_DESIRE_HIGH, weakest
		end
		lastCheck = DotaTime()
	end

	if J.IsInTeamFight( bot, 1200 )
	then

		if talent6:IsTrained() and false
		then
			local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius, 0, 0 )
			if ( locationAoE.count >= 2 )
			then
				return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc
			end
		else

			local npcWeakestEnemy = nil
			local npcWeakestEnemyHealth = 10000
			local nEnemysHeroesInRange = J.GetNearbyHeroes(bot, nCastRange, true, BOT_MODE_NONE )
			for _, npcEnemy in pairs( nEnemysHeroesInRange )
			do
				if J.IsValid( npcEnemy )
					and J.CanCastOnNonMagicImmune( npcEnemy )
					and J.CanCastOnTargetAdvanced( npcEnemy )
					and not npcEnemy:HasModifier( "modifier_warlock_shadow_word" )
				then
					local npcEnemyHealth = npcEnemy:GetHealth()
					if ( npcEnemyHealth < npcWeakestEnemyHealth )
					then
						npcWeakestEnemyHealth = npcEnemyHealth
						npcWeakestEnemy = npcEnemy
					end
				end
			end

			if ( npcWeakestEnemy ~= nil )
			then
				return BOT_ACTION_DESIRE_HIGH, npcWeakestEnemy
			end

		end
	end

	if J.IsGoingOnSomeone( bot )
	then
		local target = J.GetProperTarget( bot )
		if J.IsValidHero( target )
			and J.CanCastOnNonMagicImmune( target )
			and J.CanCastOnTargetAdvanced( target )
			and J.IsInRange( target, bot, nCastRange )
			and not target:HasModifier( "modifier_warlock_shadow_word" )
		then
			return BOT_ACTION_DESIRE_HIGH, target
		end
	end

	return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderQ()

	if not abilityQ:IsFullyCastable() then return BOT_ACTION_DESIRE_NONE, nil end

	local nCastRange = abilityQ:GetCastRange() + 50 + aetherRange
	local nCastPoint = abilityQ:GetCastPoint()
	local manaCost = abilityQ:GetManaCost()
	local nRadius = abilityQ:GetSpecialValueInt( "search_aoe" )
	local nCount = abilityQ:GetSpecialValueInt( "count" )


	if J.IsInTeamFight( bot, 1000 )
	then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius, 0, 0 )
		if ( locationAoE.count >= 2 )
		then
			local nEnemyHeroes = J.GetNearbyHeroes(bot, nCastRange, true, BOT_MODE_NONE )
			if J.IsValidHero( nEnemyHeroes[1] )
				and J.CanCastOnNonMagicImmune( nEnemyHeroes[1] )
				and J.CanCastOnTargetAdvanced( nEnemyHeroes[1] )
			then
				return  BOT_ACTION_DESIRE_HIGH, nEnemyHeroes[1]
			end
		end
	end

	if J.IsRetreating( bot )
	then
		local target = J.GetVulnerableWeakestUnit( bot, true, true, nCastRange - 100 )
		if target ~= nil and J.GetUnitAllyCountAroundEnemyTarget( target, nRadius ) >= 3 then
			return BOT_ACTION_DESIRE_HIGH, target
		end
	end

	if J.IsGoingOnSomeone( bot )
	then
		local target = J.GetProperTarget( bot )
		if J.IsValidHero( target )
			and J.CanCastOnNonMagicImmune( target )
			and J.CanCastOnTargetAdvanced( target )
			and J.IsInRange( target, bot, nCastRange )
		then
			if J.GetAroundTargetEnemyUnitCount( target, nRadius ) >= 3 then
				return BOT_ACTION_DESIRE_HIGH, target
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE, nil
end

return X
-- dota2jmz@163.com QQ:2462331592..
