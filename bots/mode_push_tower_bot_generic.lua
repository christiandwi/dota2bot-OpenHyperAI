local Push = require( GetScriptDirectory()..'/FunLib/aba_push')
local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local bot = GetBot()
local botName = bot:GetUnitName()
if bot == nil or bot:IsInvulnerable() or not bot:IsHero() or not bot:IsAlive() or not string.find(botName, "hero") or bot:IsIllusion() then return end
if bot.PushLaneDesire == nil then bot.PushLaneDesire = {0, 0, 0} end

function GetDesire()
    bot.PushLaneDesire[LANE_BOT] = Push.GetPushDesire(bot, LANE_BOT)
    if bot.PushLaneDesire[LANE_BOT] > 0.6 then J.ModeAnnounce(bot, 'say_push_bot', 30) end
    return bot.PushLaneDesire[LANE_BOT]
end
function Think() Push.PushThink(bot, LANE_BOT) end
