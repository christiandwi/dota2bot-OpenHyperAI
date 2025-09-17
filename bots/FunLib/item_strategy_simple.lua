--[[
Simple Item Strategy System
Single file that provides dynamic item builds based on position, hero type, and enemy composition
]]

local ItemStrategy = {}

-- Hero classifications
local HERO_TYPES = {
    MELEE = {
        "npc_dota_hero_abaddon", "npc_dota_hero_alchemist", "npc_dota_hero_axe", "npc_dota_hero_bloodseeker",
        "npc_dota_hero_bounty_hunter", "npc_dota_hero_brewmaster", "npc_dota_hero_centaur", "npc_dota_hero_chaos_knight",
        "npc_dota_hero_clockwerk", "npc_dota_hero_dark_seer", "npc_dota_hero_dawnbreaker", "npc_dota_hero_doom",
        "npc_dota_hero_dragon_knight", "npc_dota_hero_earth_spirit", "npc_dota_hero_earthshaker", "npc_dota_hero_elder_titan",
        "npc_dota_hero_ember_spirit", "npc_dota_hero_enigma", "npc_dota_hero_faceless_void", "npc_dota_hero_huskar",
        "npc_dota_hero_juggernaut", "npc_dota_hero_kunkka", "npc_dota_hero_legion_commander", "npc_dota_hero_life_stealer",
        "npc_dota_hero_lycan", "npc_dota_hero_magnataur", "npc_dota_hero_mars", "npc_dota_hero_meepo",
        "npc_dota_hero_morphling", "npc_dota_hero_naga_siren", "npc_dota_hero_necrolyte", "npc_dota_hero_night_stalker",
        "npc_dota_hero_nyx_assassin", "npc_dota_hero_ogre_magi", "npc_dota_hero_omniknight", "npc_dota_hero_pangolier",
        "npc_dota_hero_phantom_assassin", "npc_dota_hero_phantom_lancer", "npc_dota_hero_pudge", "npc_dota_hero_razor",
        "npc_dota_hero_riki", "npc_dota_hero_sand_king", "npc_dota_hero_shredder", "npc_dota_hero_skeleton_king",
        "npc_dota_hero_slardar", "npc_dota_hero_slark", "npc_dota_hero_snapfire", "npc_dota_hero_spectre",
        "npc_dota_hero_spirit_breaker", "npc_dota_hero_storm_spirit", "npc_dota_hero_sven", "npc_dota_hero_templar_assassin",
        "npc_dota_hero_terrorblade", "npc_dota_hero_tidehunter", "npc_dota_hero_tiny", "npc_dota_hero_treant",
        "npc_dota_hero_troll_warlord", "npc_dota_hero_tusk", "npc_dota_hero_undying", "npc_dota_hero_ursa",
        "npc_dota_hero_vengefulspirit", "npc_dota_hero_viper", "npc_dota_hero_weaver", "npc_dota_hero_windrunner"
    },
    
    PHYSICAL_DAMAGE = {
        "npc_dota_hero_abaddon", "npc_dota_hero_alchemist", "npc_dota_hero_antimage", "npc_dota_hero_axe",
        "npc_dota_hero_bloodseeker", "npc_dota_hero_bounty_hunter", "npc_dota_hero_chaos_knight", "npc_dota_hero_clinkz",
        "npc_dota_hero_drow_ranger", "npc_dota_hero_ember_spirit", "npc_dota_hero_faceless_void", "npc_dota_hero_huskar",
        "npc_dota_hero_juggernaut", "npc_dota_hero_legion_commander", "npc_dota_hero_life_stealer", "npc_dota_hero_luna",
        "npc_dota_hero_lycan", "npc_dota_hero_medusa", "npc_dota_hero_mirana", "npc_dota_hero_morphling",
        "npc_dota_hero_naga_siren", "npc_dota_hero_phantom_assassin", "npc_dota_hero_phantom_lancer", "npc_dota_hero_razor",
        "npc_dota_hero_riki", "npc_dota_hero_shredder", "npc_dota_hero_skeleton_king", "npc_dota_hero_slardar",
        "npc_dota_hero_slark", "npc_dota_hero_sniper", "npc_dota_hero_spectre", "npc_dota_hero_sven",
        "npc_dota_hero_templar_assassin", "npc_dota_hero_terrorblade", "npc_dota_hero_troll_warlord", "npc_dota_hero_ursa",
        "npc_dota_hero_vengefulspirit", "npc_dota_hero_viper", "npc_dota_hero_weaver", "npc_dota_hero_windrunner"
    }
}

-- Early game builds (0-15 minutes) - cheap, essential items for laning
local EARLY_GAME_BUILDS = {
    pos_1 = {
        -- Starting items for carry laning
        "item_tango", "item_double_branches", "item_quelling_blade", "item_circlet",
        -- Early laning items for last hitting and sustain
        "item_wraith_band", "item_magic_wand", "item_power_treads", "item_hand_of_midas",
        -- Early damage items
        "item_echo_sabre", "item_lesser_crit"
    },
    pos_2 = {
        -- Starting items for mid laning
        "item_tango", "item_double_branches", "item_faerie_fire", "item_circlet",
        -- Mid lane essentials
        "item_bottle", "item_magic_wand", "item_power_treads", "item_hand_of_midas",
        -- Early damage and mobility
        "item_echo_sabre", "item_blink"
    },
    pos_3 = {
        -- Starting items for offlane
        "item_tango", "item_double_branches", "item_quelling_blade",
        -- Offlane survival and farming
        "item_gloves", "item_magic_wand", "item_orb_of_corrosion", "item_phase_boots",
        -- Early team items
        "item_crimson_guard", "item_blink"
    },
    pos_4 = {
        -- Support starting items
        "item_tank_outfit", "item_ward_observer", "item_ward_sentry", "item_dust",
        -- Early support items
        "item_echo_sabre", "item_aghanims_shard", "item_glimmer_cape", "item_force_staff"
    },
    pos_5 = {
        -- Hard support starting items
        "item_mage_outfit", "item_ward_observer", "item_ward_sentry", "item_dust",
        -- Early support items
        "item_ancient_janggo", "item_glimmer_cape", "item_force_staff", "item_medallion_of_courage"
    }
}

-- Late game builds (15+ minutes) - expensive, powerful 6-slot items
local LATE_GAME_BUILDS = {
    pos_1 = {
        -- Core carry 6-slot items
        "item_manta", "item_black_king_bar", "item_skadi", "item_bloodthorn",
        "item_travel_boots_2", "item_moon_shard", "item_ultimate_scepter_2", "item_butterfly"
    },
    pos_2 = {
        -- Mid lane 6-slot items
        "item_manta", "item_black_king_bar", "item_harpoon", "item_basher",
        "item_heart", "item_ultimate_scepter", "item_travel_boots_2", "item_greater_crit"
    },
    pos_3 = {
        -- Offlane 6-slot items
        "item_radiance", "item_crimson_guard", "item_assault", "item_ultimate_scepter",
        "item_heart", "item_travel_boots_2", "item_aghanims_shard", "item_moon_shard"
    },
    pos_4 = {
        -- Support 6-slot items
        "item_crimson_guard", "item_ultimate_scepter", "item_heavens_halberd",
        "item_assault", "item_travel_boots", "item_moon_shard", "item_sheepstick",
        "item_ultimate_scepter_2", "item_octarine_core", "item_travel_boots_2"
    },
    pos_5 = {
        -- Hard support 6-slot items
        "item_boots_of_bearing", "item_pipe", "item_aghanims_shard", "item_cyclone",
        "item_shivas_guard", "item_sheepstick", "item_heart", "item_octarine_core",
        "item_moon_shard", "item_ultimate_scepter_2"
    }
}

-- Counter items for specific threats
local COUNTER_ITEMS = {
    -- Against Phantom Assassin
    ["npc_dota_hero_phantom_assassin"] = {"item_monkey_king_bar", "item_bloodthorn"},
    -- Against magic-heavy teams
    magic_heavy = {"item_black_king_bar", "item_pipe_of_insight", "item_lotus_orb"},
    -- Against illusion heroes
    illusion_heavy = {"item_maelstrom", "item_mjollnir", "item_radiance", "item_battlefury"},
    -- Against evasion
    evasion = {"item_monkey_king_bar", "item_bloodthorn"}
}

-- Magic damage heroes
local MAGIC_HEROES = {
    "npc_dota_hero_zeus", "npc_dota_hero_lina", "npc_dota_hero_lion", "npc_dota_hero_lich",
    "npc_dota_hero_crystal_maiden", "npc_dota_hero_skywrath_mage", "npc_dota_hero_pugna",
    "npc_dota_hero_leshrac", "npc_dota_hero_invoker", "npc_dota_hero_tinker",
    "npc_dota_hero_queen_of_pain", "npc_dota_hero_storm_spirit", "npc_dota_hero_rubick"
}

-- Illusion heroes
local ILLUSION_HEROES = {
    "npc_dota_hero_phantom_lancer", "npc_dota_hero_chaos_knight", "npc_dota_hero_morphling", "npc_dota_hero_terrorblade"
}

-- Evasion heroes
local EVASION_HEROES = {
    "npc_dota_hero_phantom_assassin", "npc_dota_hero_windrunner", "npc_dota_hero_riki", "npc_dota_hero_brewmaster"
}

-- Helper functions
local function hasItem(build, itemName)
    for _, item in pairs(build) do
        if item == itemName then return true end
    end
    return false
end

local function isMelee(heroName)
    for _, hero in pairs(HERO_TYPES.MELEE) do
        if hero == heroName then return true end
    end
    return false
end

local function isPhysicalDamage(heroName)
    for _, hero in pairs(HERO_TYPES.PHYSICAL_DAMAGE) do
        if hero == heroName then return true end
    end
    return false
end

local function getEnemyHeroes()
    local enemyHeroes = {}
    local enemyTeam = GetTeam() == TEAM_RADIANT and TEAM_DIRE or TEAM_RADIANT
    
    for i = 1, 5 do
        local hero = GetTeamMember(i, enemyTeam)
        if hero and hero:IsAlive() then
            table.insert(enemyHeroes, hero:GetUnitName())
        end
    end
    
    return enemyHeroes
end

local function hasEnemyThreat(enemyHeroes, threatType)
    if threatType == "magic_heavy" then
        local magicCount = 0
        for _, enemy in pairs(enemyHeroes) do
            for _, magicHero in pairs(MAGIC_HEROES) do
                if enemy == magicHero then
                    magicCount = magicCount + 1
                    break
                end
            end
        end
        return magicCount >= 2
    elseif threatType == "illusion_heavy" then
        for _, enemy in pairs(enemyHeroes) do
            for _, illusionHero in pairs(ILLUSION_HEROES) do
                if enemy == illusionHero then return true end
            end
        end
    elseif threatType == "evasion" then
        for _, enemy in pairs(enemyHeroes) do
            for _, evasionHero in pairs(EVASION_HEROES) do
                if enemy == evasionHero then return true end
            end
        end
    end
    return false
end

-- Main function to get item build
function ItemStrategy.GetItemBuild(bot, position)
    local heroName = bot:GetUnitName()
    local enemyHeroes = getEnemyHeroes()
    local gameTime = DotaTime()
    
    -- Choose build based on game phase
    local build = {}
    if gameTime < 15 * 60 then -- Early game (0-15 minutes)
        if EARLY_GAME_BUILDS[position] then
            for _, item in pairs(EARLY_GAME_BUILDS[position]) do
                table.insert(build, item)
            end
        end
    else -- Late game (15+ minutes)
        if LATE_GAME_BUILDS[position] then
            for _, item in pairs(LATE_GAME_BUILDS[position]) do
                table.insert(build, item)
            end
        end
    end
    
    -- Adjust for melee vs ranged
    if isMelee(heroName) then
        if position == "pos_1" or position == "pos_2" then
            if not hasItem(build, "item_blink") then
                table.insert(build, "item_blink")
            end
        end
    else
        if position == "pos_1" or position == "pos_2" then
            if not hasItem(build, "item_dragon_lance") then
                table.insert(build, "item_dragon_lance")
            end
        end
    end
    
    -- Adjust for physical vs magical damage
    if isPhysicalDamage(heroName) then
        if position == "pos_1" or position == "pos_2" then
            if not hasItem(build, "item_butterfly") then
                table.insert(build, "item_butterfly")
            end
        end
    else
        if not hasItem(build, "item_kaya_and_sange") then
            table.insert(build, "item_kaya_and_sange")
        end
    end
    
    -- Add counter items for specific enemy heroes
    for _, enemy in pairs(enemyHeroes) do
        if COUNTER_ITEMS[enemy] then
            for _, counterItem in pairs(COUNTER_ITEMS[enemy]) do
                if not hasItem(build, counterItem) then
                    table.insert(build, counterItem)
                end
            end
        end
    end
    
    -- Add general counter items
    if hasEnemyThreat(enemyHeroes, "magic_heavy") then
        for _, counterItem in pairs(COUNTER_ITEMS.magic_heavy) do
            if not hasItem(build, counterItem) then
                table.insert(build, counterItem)
            end
        end
    end
    
    if hasEnemyThreat(enemyHeroes, "illusion_heavy") then
        for _, counterItem in pairs(COUNTER_ITEMS.illusion_heavy) do
            if not hasItem(build, counterItem) then
                table.insert(build, counterItem)
            end
        end
    end
    
    if hasEnemyThreat(enemyHeroes, "evasion") then
        for _, counterItem in pairs(COUNTER_ITEMS.evasion) do
            if not hasItem(build, counterItem) then
                table.insert(build, counterItem)
            end
        end
    end
    
    return build
end

-- Get current game phase
function ItemStrategy.GetGamePhase(gameTime)
    if gameTime < 15 * 60 then
        return "early"
    elseif gameTime < 30 * 60 then
        return "mid"
    else
        return "late"
    end
end

-- Get sell list based on game phase
function ItemStrategy.GetSellList(position, gameTime)
    local sellList = {}
    local phase = ItemStrategy.GetGamePhase(gameTime)
    
    -- Always sell these items
    table.insert(sellList, "item_ultimate_scepter")
    table.insert(sellList, "item_magic_wand")
    
    -- Early game items to sell in late game
    if phase == "late" then
        table.insert(sellList, "item_quelling_blade")
        table.insert(sellList, "item_bottle")
        table.insert(sellList, "item_hand_of_midas")
        table.insert(sellList, "item_ancient_janggo")
        table.insert(sellList, "item_orb_of_corrosion")
        table.insert(sellList, "item_wraith_band")
        table.insert(sellList, "item_bracer")
        table.insert(sellList, "item_null_talisman")
    end
    
    return sellList
end

return ItemStrategy
