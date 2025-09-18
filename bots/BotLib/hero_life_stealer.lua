local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sRole = J.Item.GetRoleItemsBuyList( bot )

local tTalentTreeList = {
						['t25'] = {0, 10},
						['t20'] = {10, 0},
						['t15'] = {10, 0},
						['t10'] = {10, 0},
}

local tAllAbilityBuildList = {
						{2,3,1,3,3,6,3,2,2,2,1,6,1,1,6},--pos1
						-- {2,3,3,3,6,3,2,2,2,6,6},--pos1
}

local nAbilityBuildList = J.Skill.GetRandomBuild( tAllAbilityBuildList )

local nTalentBuildList = J.Skill.GetTalentBuild( tTalentTreeList )

local sRandom = RandomInt(1, 2) == 1 and "item_radiance" or "item_desolator"

local sRoleItemsBuyList = {}

sRoleItemsBuyList['pos_1'] = {
    "item_tango",
    "item_branches",
    "item_faerie_fire",
    "item_quelling_blade",
    "item_double_gauntlets",

    "item_orb_of_corrosion",
	"item_magic_wand",
    "item_phase_boots",
    "item_armlet",
    sRandom,--
    "item_aghanims_shard",
    "item_assault",--
    "item_basher",
    "item_nullifier",--
    "item_monkey_king_bar",--
    "item_travel_boots",
    "item_abyssal_blade",--
    "item_moon_shard",
    "item_travel_boots_2",--
    "item_ultimate_scepter_2",
}

sRoleItemsBuyList['pos_2'] = sRoleItemsBuyList['pos_1']

sRoleItemsBuyList['pos_3'] = sRoleItemsBuyList['pos_1']

sRoleItemsBuyList['pos_4'] = {
	'item_priest_outfit',
	"item_hand_of_midas",
	"item_mekansm",
	"item_glimmer_cape",--
	"item_guardian_greaves",--
    "item_basher",
    "item_monkey_king_bar",--
	"item_assault",--
	"item_heavens_halberd",--
	"item_aghanims_shard",
    "item_abyssal_blade",--
	"item_ultimate_scepter",
	"item_moon_shard",
	"item_ultimate_scepter_2",
}

sRoleItemsBuyList['pos_5'] = {
	'item_priest_outfit',
	"item_hand_of_midas",
	"item_mekansm",
	"item_glimmer_cape",--
	"item_pipe",--
    "item_basher",
    "item_monkey_king_bar",--
	"item_assault",--
	"item_heavens_halberd",--
	"item_aghanims_shard",
    "item_abyssal_blade",--
	"item_ultimate_scepter",
	"item_moon_shard",
	"item_ultimate_scepter_2",
}

X['sBuyList'] = sRoleItemsBuyList[sRole]

X['sSellList'] = {

	"item_black_king_bar",
	"item_quelling_blade",
}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_mid' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

local botTarget, infestTarget, infestTargetType
local nAllyHeroes, nEnemyHeroes

function X.MinionThink(hMinionUnit)
    local botHp = J.GetHP(bot)
    local Control = hMinionUnit:GetAbilityByName('life_stealer_control')
    if Control and not Control:IsHidden() and Control:IsFullyCastable()
    then
        bot:Action_UseAbility(Control)
        return
    end

    local Consume = hMinionUnit:GetAbilityByName('life_stealer_consume')
    if Consume and Consume:IsFullyCastable() then
        if GetUnitToLocationDistance(hMinionUnit, J.GetTeamFountain()) < 1500 and J.GetHP(hMinionUnit) > 0.7 then
            hMinionUnit:Action_UseAbility(Consume)
            return
        end
        if J.IsInTeamFight(bot, 900) and botHp > 0.75 then
            hMinionUnit:Action_UseAbility(Consume)
            return
        end
        if infestTargetType == 'creep' then
            if (J.IsInTeamFight(bot, 1600) and botHp > 0.5) or botHp > 0.75 then
                local nTeamFightLocation = J.GetTeamFightLocation(bot)
                if nTeamFightLocation ~= nil then
                    hMinionUnit:Action_MoveToLocation(nTeamFightLocation)
                    return
                end
            else
                hMinionUnit:Action_MoveToLocation(J.GetTeamFountain())
                return
            end
        elseif infestTargetType == 'hero' and IsTeamPlayer(infestTarget:GetPlayerID()) then
            if botHp > 0.5
            and nEnemyHeroes and #nEnemyHeroes > 0
            and (J.IsPushing(infestTarget) or J.IsAttacking(infestTarget)) then
                hMinionUnit:Action_UseAbility(Consume)
                return
            end
            if botHp > 0.75
            and not (nEnemyHeroes and #nEnemyHeroes > 0) then
                hMinionUnit:Action_UseAbility(Consume)
                return
            end
        end
    end

    Minion.MinionThink(hMinionUnit)
end

local Rage          = bot:GetAbilityByName('life_stealer_rage')
-- local Feast         = bot:GetAbilityByName('life_stealer_feast')
-- local GhoulFrenzy   = bot:GetAbilityByName('life_stealer_ghoul_frenzy')
local OpenWounds    = bot:GetAbilityByName('life_stealer_open_wounds')
local Infest        = bot:GetAbilityByName('life_stealer_infest')
local Consume       = bot:GetAbilityByName('life_stealer_consume')
local Control       = bot:GetAbilityByName('life_stealer_control')


local RageDesire
local OpenWoundsDesire, OpenWoundsTarget
local InfestDesire, InfestTarget
local ConsumeDesire

local bAttacking = false
local botHP, botMaxMana, botManaRegen

function X.SkillsComplement()
    bAttacking = J.IsAttacking(bot)
    botHP = J.GetHP(bot)
	botMaxMana = bot:GetMaxMana()
    botManaRegen = bot:GetManaRegen()
    botTarget = J.GetProperTarget(bot)
    nAllyHeroes = bot:GetNearbyHeroes(1600, false, BOT_MODE_NONE)
    nEnemyHeroes = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)

    ConsumeDesire = X.ConsiderConsume()
    if ConsumeDesire > 0 then
        bot:Action_UseAbility(Consume)
        return
    end

    if not bot:HasModifier('modifier_life_stealer_infest') then
        if J.CanNotUseAbility(bot) then return end
    end

    InfestDesire, InfestTarget = X.ConsiderInfest()
    if InfestDesire > 0 then
        bot:Action_UseAbilityOnEntity(Infest, InfestTarget)
        return
    end

    RageDesire = X.ConsiderRage()
    if RageDesire > 0 then
        J.SetQueuePtToINT(bot, false)
        bot:ActionQueue_UseAbility(Rage)
        return
    end

    OpenWoundsDesire, OpenWoundsTarget = X.ConsiderOpenWounds()
    if OpenWoundsDesire > 0 then
        J.SetQueuePtToINT(bot, false)
        bot:ActionQueue_UseAbilityOnEntity(OpenWounds, OpenWoundsTarget)
        return
    end
end

function X.ConsiderRage()
    if not J.CanCastAbility(Rage)
    or bot:HasModifier('modifier_life_stealer_infest')
    or bot:IsMagicImmune()
    or bot:IsInvulnerable()
    then
        return BOT_ACTION_DESIRE_NONE
    end

    local nInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), 1200)

    if #nInRangeEnemy > 0 then
        if J.IsNotAttackProjectileIncoming(bot, 350)
        or J.IsWillBeCastUnitTargetSpell(bot, 500)
        or J.IsWillBeCastPointSpell(bot, 500)
        then
            if not J.IsRealInvisible(bot) then
                return BOT_ACTION_DESIRE_HIGH
            end
        end

        if (J.IsGoingOnSomeone(bot) or (J.IsRetreating(bot) and not J.IsRealInvisible(bot))) then
            if bot:IsRooted() then
                return BOT_ACTION_DESIRE_HIGH
            end

            nInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), 600)
            if bot:IsSilenced()
            and #nInRangeEnemy >= 2
            and not bot:HasModifier('modifier_item_mask_of_madness_berserk')
            then
                return BOT_ACTION_DESIRE_HIGH
            end

            local nInRangeAlly = J.GetAlliesNearLoc(bot:GetLocation(), 1200)
            if #nInRangeEnemy >= #nInRangeAlly
            and botHP < 0.6
            and J.IsValidHero(nInRangeEnemy[1])
            and (J.IsChasingTarget(nInRangeEnemy[1], bot) or nInRangeEnemy[1]:GetAttackTarget() == bot)
            then
                return BOT_ACTION_DESIRE_HIGH
            end

            if #nInRangeEnemy >= 3 and J.IsInTeamFight(bot, 1200) and #J.GetHeroesTargetingUnit(nInRangeEnemy, bot) then
                return BOT_ACTION_DESIRE_HIGH
            end
        end
    end

    if bot:HasModifier('modifier_jakiro_macropyre_burn')
    or bot:HasModifier('modifier_lich_chainfrost_slow')
    or bot:HasModifier('modifier_crystal_maiden_freezing_field_slow')
    or bot:HasModifier('modifier_puck_coiled')
    or bot:HasModifier('modifier_skywrath_mystic_flare_aura_effect')
    or bot:HasModifier('modifier_snapfire_magma_burn_slow')
    or bot:HasModifier('modifier_sand_king_epicenter_slow')
    then
        return BOT_ACTION_DESIRE_HIGH
    end

    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderOpenWounds()
    if not J.CanCastAbility(OpenWounds)
    or bot:HasModifier('modifier_life_stealer_infest')
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

	local nCastRange = J.GetProperCastRange(false, bot, OpenWounds:GetCastRange())
    local nManaCost = OpenWounds:GetManaCost()
    local fManaAfter = J.GetManaAfter(nManaCost)
    local fManaThreshold1 = J.GetManaThreshold(bot, nManaCost, {Rage, Infest})

	if J.IsGoingOnSomeone(bot) then
        if  J.IsValidTarget(botTarget)
        and J.CanBeAttacked(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.CanCastOnTargetAdvanced(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and not J.IsDisabled(botTarget)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
        and not botTarget:HasModifier('modifier_templar_assassin_refraction_absorb')
		then
            if J.IsChasingTarget(bot, botTarget)
            or (#J.GetHeroesTargetingUnit(nAllyHeroes, botTarget) >= 2 and J.GetHP(botTarget) > 0.2)
            then
                if fManaAfter > fManaThreshold1 then
                    return BOT_ACTION_DESIRE_HIGH, botTarget
                end
            end
        end
	end

    if J.IsRetreating(bot) and not J.IsRealInvisible(bot) then
        for _, enemy in pairs(nEnemyHeroes) do
            if J.IsValidHero(enemy)
            and J.IsInRange(bot, enemy, nCastRange)
            and J.CanCastOnNonMagicImmune(enemy)
            and J.CanCastOnTargetAdvanced(enemy)
            and bot:WasRecentlyDamagedByHero(enemy, 3.0)
            and J.IsChasingTarget(enemy, bot)
            and not J.IsDisabled(enemy)
            and not enemy:IsDisarmed()
            then
                if J.IsChasingTarget(enemy, bot) or #nEnemyHeroes > #nAllyHeroes and botHP < 0.5 then
                    return BOT_ACTION_DESIRE_HIGH, enemy
                end
            end
        end
    end

	if (J.IsPushing(bot) or J.IsDefending(bot) or J.IsFarming(bot)) and botHP < 0.5 and (fManaAfter > fManaThreshold1 or botHP < 0.2) and bAttacking then
		if J.IsValid(botTarget)
        and J.CanBeAttacked(botTarget)
        and botTarget:IsCreep()
        and J.GetHP(botTarget) >= 0.75
        and not J.CanKillTarget(botTarget, bot:GetAttackDamage() * 4, DAMAGE_TYPE_PHYSICAL)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget
        end
	end

	if J.IsDoingRoshan(bot) then
        if  J.IsRoshan(botTarget)
        and J.CanBeAttacked(botTarget)
        and J.CanCastOnTargetAdvanced(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and J.GetHP(botTarget) > 0.2
        and bAttacking
        and botHP < 0.5
        and (fManaAfter > fManaThreshold1 or botHP < 0.2)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget
        end
	end

	if J.IsDoingTormentor(bot) then
        if J.IsTormentor(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and bAttacking
        and botHP < 0.5
        and (fManaAfter > fManaThreshold1 or botHP < 0.2)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget
        end
	end

    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderInfest()
    if not J.CanCastAbility(Infest)
    or bot:HasModifier('modifier_life_stealer_infest')
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

    local nCastRange = J.GetProperCastRange(false, bot, Infest:GetCastRange())

	if J.IsGoingOnSomeone(bot) then
        if  J.IsValidHero(botTarget)
        and J.CanBeAttacked(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, 1200)
        and not J.IsDisabled(botTarget)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_enigma_black_hole_pull')
        and not botTarget:HasModifier('modifier_faceless_void_chronosphere_freeze')
		then
            if bot:HasScepter() then
                if botHP < 0.5
                and J.CanCastOnTargetAdvanced(botTarget)
                and J.IsInRange(bot, botTarget, nCastRange + 300)
                and (J.IsCore(botTarget) or J.GetHP(botTarget) > 0.5)
                then
                    bot.infest_target = 'hero'
                    return BOT_ACTION_DESIRE_HIGH, botTarget
                end
            end

            local nInRangeEnemy = J.GetEnemiesNearLoc(botTarget:GetLocation(), 900)
            if #nInRangeEnemy >= 2 then
                local hTarget = nil
                for _, allyHero in pairs(nAllyHeroes) do
                    if bot ~= allyHero
                    and J.IsValidHero(allyHero)
                    and J.IsInRange(bot, allyHero, 900)
                    and J.IsGoingOnSomeone(allyHero)
                    and (allyHero:GetAttackTarget() == botTarget or J.IsChasingTarget(allyHero, botTarget))
                    and not allyHero:IsIllusion()
                    and not J.IsMeepoClone(allyHero)
                    and allyHero:GetAttackRange() <= 324
                    then
                        hTarget = allyHero
                    end
                end

                if hTarget ~= nil then
                    bot.infest_target = 'hero'
                    return BOT_ACTION_DESIRE_HIGH, hTarget
                end
            end
		end
	end

	if J.IsRetreating(bot) and not J.IsRealInvisible(bot) then
        for _, enemyHero in pairs(nEnemyHeroes) do
            if J.IsValidHero(enemyHero)
            and J.IsInRange(bot, enemyHero, 800)
            and not J.IsSuspiciousIllusion(enemyHero)
            and not enemyHero:IsDisarmed()
            then
                if J.IsChasingTarget(enemyHero, bot) or #nEnemyHeroes > #nAllyHeroes and botHP < 0.5 then
                    local enemyDamage = J.GetTotalEstimatedDamageToTarget(nEnemyHeroes, bot, 5.0)
                    if enemyDamage > (bot:GetHealth() + bot:GetHealthRegen() * 5.0) then
                        for _, allyHero in ipairs(nAllyHeroes) do
                            if bot ~= allyHero
                            and J.IsValidHero(allyHero)
                            and J.IsInRange(bot, allyHero, nCastRange + 500)
                            and J.IsRetreating(allyHero)
                            and not J.IsSuspiciousIllusion(allyHero)
                            and not J.IsMeepoClone(allyHero)
                            then
                                bot.infest_target = 'hero'
                                return BOT_ACTION_DESIRE_HIGH, allyHero
                            end
                        end

                        local nAllyLaneCreeps = bot:GetNearbyLaneCreeps(777, false)
                        for _, creep in ipairs(nAllyLaneCreeps) do
                            if J.IsValid(creep) then
                                bot.infest_target = 'creep'
                                return BOT_ACTION_DESIRE_HIGH, creep
                            end
                        end

                        local nEnemyCreeps = bot:GetNearbyCreeps(777, true)
                        for _, creep in ipairs(nEnemyCreeps) do
                            if J.IsValid(creep)
                            and not creep:IsAncientCreep()
                            and not creep:IsDominated()
                            and not creep:HasModifier('modifier_chen_holy_persuasion')
                            and not creep:HasModifier('modifier_dominated')
                            then
                                bot.infest_target = 'creep'
                                return BOT_ACTION_DESIRE_HIGH, creep
                            end
                        end
                    end
                end
            end
        end
	end

    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderConsume()
    if not J.CanCastAbility(Consume) then
        return BOT_ACTION_DESIRE_NONE
    end

    local nDamage = Infest:GetSpecialValueInt('damage')
	local nRadius = Infest:GetSpecialValueInt('radius')

    if not J.IsRetreating(bot) then
        for _, enemy in pairs(nEnemyHeroes) do
            if J.IsValidHero(enemy)
            and J.CanBeAttacked(enemy)
            and J.IsInRange(bot, enemy, nRadius - 100)
            and J.CanCastOnNonMagicImmune(enemy)
            and not enemy:HasModifier('modifier_abaddon_borrowed_time')
            and not enemy:HasModifier('modifier_dazzle_shallow_grave')
            and not enemy:HasModifier('modifier_necrolyte_reapers_scythe')
            then
                local nInRangeAlly = J.GetAlliesNearLoc(enemy:GetLocation(), 1200)
                local nInRangeEnemy = J.GetEnemiesNearLoc(enemy:GetLocation(), 1200)
                if #nInRangeAlly >= #nInRangeEnemy then
                    if J.CanKillTarget(enemy, nDamage, DAMAGE_TYPE_MAGICAL) then
                        return BOT_ACTION_DESIRE_HIGH
                    end
                end
            end
        end
    end

	if J.IsGoingOnSomeone(bot) then
		if  J.IsValidHero(botTarget)
        and J.CanBeAttacked(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nRadius)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
        and not botTarget:HasModifier('modifier_enigma_black_hole_pull')
        and not botTarget:HasModifier('modifier_faceless_void_chronosphere_freeze')
		then
            if botHP > 0.8 then
                return BOT_ACTION_DESIRE_HIGH
            end
		end
	end

	if J.IsRetreating(bot) then
        if #nEnemyHeroes == 0 and botHP > 0.9 then
            return BOT_ACTION_DESIRE_HIGH
        end
	end

    if botHP > 0.9 and #nAllyHeroes >= #nEnemyHeroes then
        return BOT_ACTION_DESIRE_HIGH
    end

    return BOT_ACTION_DESIRE_NONE
end

return X