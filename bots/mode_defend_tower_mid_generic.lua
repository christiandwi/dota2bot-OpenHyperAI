local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local Defend = require( GetScriptDirectory()..'/FunLib/aba_defend')

local bot = GetBot()
local botName = bot:GetUnitName()

if bot:IsInvulnerable() or not bot:IsHero() or not string.find(botName, "hero") or bot:IsIllusion() then
	return
end

function GetDesire()
	local res = Defend.GetDefendDesire(bot, LANE_MID)
	if res > 0.6 then J.ModeAnnounce(bot, 'say_defend_mid', 30) end
	return res
end

-- DefendThink disabled: aba_defend.lua has critical bugs (shared module-level
-- state races between bots, Action_AttackMove side-effect in GetDefendDesireHelper,
-- off-by-one in creep loop, stale action replay). Needs TS source fix before enabling.
-- function Think() Defend.DefendThink(bot, LANE_MID) end
