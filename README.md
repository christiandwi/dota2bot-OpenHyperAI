### We love bot games!
Thanks and kudos to all that contributed to make bot games fun and exciting.
The goal of this script is to share the most up to date functionalities that we've implemented or fixed to keep the bot games challenging.

This script is based on Valve's default bot script and many other people's work and their scripts. That being said, this is a partial override not completely take over bot script. It takes the advantages of some other existing bot scripts and aims to be a better off script than the existing ones. We hope the bot's decision making and team strategies are more effective and brings more joy to you.

### Why it's enjoyable
1. Support 115+ heroes. (I personally don't take much of credit for this because it's many peoples work to make this possible, what I did was improving existing ones). Kudos to Tinkering ABout (by ryndrb) for making a lot of improvements on recent hero supporting, as well as bots taking Tormentor.
2. All supported heroes and play any position roles. Heroes will go to any lane they are assigned. The laning or pos of the hero is irrelevant to the pick order.
3. Improved code structure general logic for decision making for ability and item usages as well as roaming and farming.
4. Fixed tons of bugs that can cause bots to stay idle or cancel it's own channeling spells or stuck on weird state.

### How to install this script?
There is currently a bug where subscribing to recent bot scripts will NOT work when selecting them in the custom game lobby. They will revert back to default bots when you close out of the settings menu. In order to fix this, you must manually install this script:
1. Subscribe to the bot.
2. Navigate to \Steam\steamapps\workshop\content\570\3246316298
3. Copy the contents of this folder.
4. Navigate to \Steam\steamapps\common\dota 2 beta\game\dota\scripts\vscripts
5. Create a folder called "bots" if you do not already have one (back this folder up if you already have another bot in here!).
6. Paste all the contents you've copied into this folder.
7. Create a lobby in Dota2, select "Local Dev Script" when you are choosing the bot script for teams. 
8. Select "Local Host" as your server location or else this script will not load.
(Note the above steps were shared by the author of PhalanxBot)

### What's next
1. This is a script mainly based on the code from Tinkering ABout (by ryndrb). But the code has diverged significantly due to some roles and item selection support, as well as the local support with Frebot. So the future maintenance will keep diverging.
2. More heroes support.
3. Better decision making on pushing and ganking.
4. Better spell casting for certain heroes like Invoker, Rubick, etc.
5. More code bug fixes.
6. Better laning logic to avoid bots feeding too much in the early game.

### Credits to
- New beginner ai (by dota2jmz@163.com).
- Tinkering ABout (by ryndrb: https://github.com/ryndrb/dota2bot or https://steamcommunity.com/sharedfiles/filedetails/?id=3139791706)
- Ranked Matchmaking AI (by adamqqq)
- fretbots (by fretmute)
- BOT Experiment (by Furiospuppy)
- ExtremePush (https://github.com/insraq/dota2bots)
- All other bot script authors/contributors that had made bot scripts interesting.

### Useful resources:
- Posts shared by Ranked Matchmaking AI author: https://www.adamqqq.com/ai/dota2-ai-devlopment-tutorial.html
- Official Bot side script intro: https://developer.valvesoftware.com/wiki/Dota_Bot_Scripting
- Lua (Bots side) APIs: https://docs.moddota.com/lua_bots/
- Ability metadata: https://raw.githubusercontent.com/dotabuff/d2vpk/master/dota_pak01/scripts/npc/npc_abilities.txt
- Lua APIs, modes, and enum values: https://moddota.com/api/#!/vscripts/dotaunitorder_t
- Bot modifier names: https://developer.valvesoftware.com/wiki/Dota_2_Workshop_Tools/Scripting/Built-In_Modifier_Names
- Dota2 data mining (details of items, abilities, heroes): https://github.com/muk-as/DOTA2_WEB/blob/master/dota2_web/Items_cn.json


### Things to be updated (not ranked by priority):
- Bots should be less aggressive to chase people into towers, human will take advantage of that to continuely lowering bot's hp and get the kill.
- Bots should respect the TPs while chasing people.
- Bots should have regens in laning phase. Don't stay in lane if ph is too low. e.g. not calling in regen like omni would have 1400 hp and sit in lane on 200 till they tp back and take a free kill
- Better Tormentor strategy with human players
- Bot should rethink about dot damage on them. they run away from dot damage without considering why. e.g. dark seer ion shell you can chase a bot from their t1 to your t1 by simply walking behind them and they take the path most directly away from it. 
- Bots should take exp runes. [exp rune is not officially supported as of 5.5.2024]
- Bots are ignoreing some abilities or modifiers that have relatively long duration and can end up deal with high dmg, spells like dazzle’s first ability modifier.
- Calculate Enigma's ultimate damage. 1600 range, lasts 4 seconds, plus Decay. Engage if it can kill, even if alone.
- Use ultimate if it can hit all visible people and can take at least one with it.
- Don't just focus on attacking Brewmaster's ultimate summons.
- Random laning.
- Randomly selected warding locations from good warding locations.
- Enigma can use ultimate on just one. If it has been a long time since the last use, or if the target is one of the top two strongest visible enemies.
- Or if you are slowed, with more than two enemies nearby. Being attacked. Health below 75%.
- If already at half health and running away, continue to retreat rather than turning back.
- During laning phase, don't use Sun Strike. Now focusing on Cold Snap and Lightning in the early game. In mid and late game, Sun Strike only on controlled targets or to secure kills.
- Don't use Sun Strike when nearly at full health. Don't use Carl's Sun Strike just for channelling.
- Sun Strike release is very confusing. Check if the position or target is wrong.
- Sun Strike always fails to connect, consider removing cast point.
- Prioritize global Sun Strike conditions. If there's Enigma's ult or similar, prioritize using big Sun Strike, or with Batrider's pull.
- Don't ignore illusion damage.
- If retreating, calculate the total nearby illusions, decide whether to Wind Walk or go invisible. If possible, calculate total damage. In late game, can't judge escape skills based on health alone.
- First 3 minutes. If within 300 range there are small fish, Pudge, retreat to 500 before fighting them.
- If there is a Witch Doctor's Maledict nearby, and the state lasts more than half, being attacked and health less than half. Don't continue to tank damage, retreat. If you're going to die but TP might save you, then TP.
- Dodge Veno's skills. Similar to dodging Pudge's hooks.
- Carry Gem in the late game.
- Expand the search range for the weakest. Look for hiding mages, Witch Doctor, or Sniper.
- Why would you act alone in the late game?
- If dead late game, or resurrected and the enemy 5 are near the high ground, and your side has fewer people alive or less than the enemy, don't engage.
- If Jakiro's ultimate ignores magic immunity, then retreat even if under BKB.
- If your side has all 5 heroes, or more people, in good condition, have pushed high, and most of the enemy are dead, do not retreat or farm. Continue to hit towers or barracks. Unless the enemy is within 500 range, don't be distracted.
- If there are no allies nearby, don't go to open outposts alone.
- Carl sell Ashes.
- Skeleton King sell Armlet and Phase.
- If Refresher Orb was just used. If there are more than 3 allies and more than 2 enemies nearby, don't use Cyclone. Consider other combo skills directly.
- If you have the state of Wraith King's Aghanim's, it proves you died, don't retreat.
- Random role location.
- In the first 5 minutes, if stacked by Huskar's spears 3 layers or more, health less than half and the enemy won't be killed immediately, or the enemy has more health, retreat until the spears expire. Similarly for Monkey King, Slardar, etc. In late game, if stacked many layers, just TP.
- In the first 5 minutes, don't roam, especially as a mid-laner.
- If being attacked by a tower, and there's a small creep nearby, and all are within tower range, attack the enemy's small creep.
- If no enemy heroes nearby and your side's status is below 75, don't get attacked by the tower.

- Random ward locations.
- If Carl, don't use Ashes to heal, even if very low on health, unless there are many charges.
- Roshan cannot be seen. Check Roshan's status only when within attack range.
- If inside a Static Storm, activate BKB.
- After 25 minutes, if more than 2 enemies are nearby, prioritize using Meteor to push waves. After 30 minutes, regardless of the number of people, prioritize Meteor push wave QQQ, then use other skills.
- Lina and Quick Sprint use less after 30 minutes, unless out of other skills.
- Rubick, if it's a single point and not a target, then location. If it is a target, then unit.
- Invoker shouldn't always be farming.
- Carl, if there are people nearby and you have very low health, retreat unconditionally. Because Carl's full-screen abilities will cancel previous retreat commands.
- Bots won't immediately use items from their backpack. Better backpack managment needed to 1, swap items for e.g. healings and swap back when used.
- Don't go to outpost alone or use smoke.


### Things fixed
- Bots are now more flexible with different laning or roles. They were not able to purchase items if they were assigned with different role or laning.
- Added/Improved a bunch of hero support so bots can have better performance on more heroes with better strategy of the ability usage, item purcahse, etc, such as Invoker casting abilities and making combos.
- When Fretbot is enabled. A list of unfair settings get applied in addition to what was provided by Frebot originally:
  - The bots get bonus mana/hp regens and provide less exp on death.
  - When a player kills a bot, the player who made the kill receives a reduction in gold. This does not affect assisting players.
- Bots with refresher won't directly use refresher immidiately, this is to prevent e.g. Void, Enigma using ult immidiately twice. The logic is now also overridable in each bot files.
- [updated, need to test] Don't kill couriers if bot is targeting a dieing hero or is retreating.
- [updated, need to test] Don't focus on some minions over heroes.
- Bots won't stay on some ability effects for lone. e.g. jakiro_macropyre_burn, dark_seer_wall, sandking_sand_storm, warlock_upheaval, etc. Bots have the intension to run away from those effects.
- Carry large HP and mana potions. Swap slots.
- Swap slots to use moonshard
