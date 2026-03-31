local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local Defend = require( GetScriptDirectory()..'/FunLib/aba_defend')

local bot = GetBot()
local botName = bot:GetUnitName()

if bot:IsInvulnerable() or not bot:IsHero() or not string.find(botName, "hero") or bot:IsIllusion() then
	return
end

function GetDesire()
	local res = Defend.GetDefendDesire(bot, LANE_TOP)
	if res > 0.6 then J.ModeAnnounce(bot, 'say_defend_top', 30) end
	return res
end
