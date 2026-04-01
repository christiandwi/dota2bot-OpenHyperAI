local Push = require( GetScriptDirectory()..'/FunLib/aba_push')
local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local bot = GetBot()
local botName = bot:GetUnitName()
if bot == nil or bot:IsInvulnerable() or not bot:IsHero() or not bot:IsAlive() or not string.find(botName, "hero") or bot:IsIllusion() then return end
if bot.PushLaneDesire == nil then bot.PushLaneDesire = {0, 0, 0} end

function GetDesire()
    bot.PushLaneDesire[LANE_TOP] = Push.GetPushDesire(bot, LANE_TOP)
    if bot.PushLaneDesire[LANE_TOP] > 0.6 then J.ModeAnnounce(bot, 'say_push_top', 30) end
    return bot.PushLaneDesire[LANE_TOP]
end
function Think() Push.PushThink(bot, LANE_TOP) end
