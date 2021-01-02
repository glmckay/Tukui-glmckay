local T, C, L = Tukui:unpack()

C["General"]["BackdropColor"] = {0.11, 0.11, 0.11, 0.8}
C["General"]["BorderColor"] = {0, 0, 0}

C["General"]["BorderSize"] = 1                      -- Added
C["General"]["FrameSpacing"] = 1                    -- Added
C["General"]["HideShadows"] = true


C["ActionBars"]["RightBar"] = true
C["ActionBars"]["LeftBar"] = true
C["ActionBars"]["ShowBackdrop"] = false
C["ActionBars"]["NormalButtonSize"] = 30
C["ActionBars"]["PetButtonSize"] = 27
C["ActionBars"]["CenterButtonSize"] = 34            -- Added
C["ActionBars"]["CenterRowLength"] = 7
C["ActionBars"]["ShapeShift"] = false
C["ActionBars"]["HotKey"] = true
C["ActionBars"]["HideBackdrop"] = true
C["ActionBars"]["ButtonSpacing"] = 1
C["ActionBars"]["NumPlayerFrameButtons"] = 5
C["ActionBars"]["HideGrid"] = false
C["ActionBars"]["Macro"] = false


C["Auras"]["Fonts"] = "Small Bold"
C["Auras"]["Size"] = 40
C["Auras"]["Spacing"] = 3


-- General options for the added AuraTimers module
C["AuraTimers"] = {}
C["AuraTimers"]["Enable"] = false
C["AuraTimers"]["BorderSize"] = 2


C["Bags"]["ButtonSize"] = 32
C["Bags"]["Spacing"] = 3
C["Bags"]["ItemsPerRow"] = 11


C["Chat"]["LeftWidth"] = 450
C["Chat"]["RightWidth"] = 450
C["Chat"]["LeftHeight"] = 280
C["Chat"]["LeftHeight"] = 280
C["Chat"]["ChatFont"] = "Chat"
C["Chat"]["TabFont"] = "Chat"


C["Cooldowns"]["Font"] = "Cooldown" -- font size is set in Tukui :/


C["DataTexts"]["Font"] = "DataText"
C["DataTexts"]["Hour24"] = true


C["Maps"] = {}
C["Maps"]["MinimapSize"] = 200                  -- Added (a couple things use this)


C["Misc"]["AutoInviteEnable"] = true
C["Misc"]["NumExpBars"] = 1                     -- Added (should be 0 to 2)


C["NamePlates"]["Font"] = "Small UnitFrame"
C["NamePlates"]["Width"] = 174
C["NamePlates"]["Height"] = 14
C["NamePlates"]["CastHeight"] = 16
C["NamePlates"]["PlayerDebuffBlacklist"] = {}
C["NamePlates"]["DebuffWhitelist"] = {}         -- Added
C["NamePlates"]["BuffWhitelist"] = {}
C["NamePlates"]["ColorThreat"] = false
C["NamePlates"]["HighlightSize"] = 14


C["Party"]["Enable"] = true
C["Party"]["Highlight"] = false                 -- Added
C["Party"]["Font"] = "UnitFrame"
C["Party"]["HealthFont"] = "Small Bold"
C["Party"]["ShowPlayer"] = true
C["Party"]["ShowSolo"] = true                  -- Added (good for testing)
C["Party"]["DebuffBlacklist"] = {}              -- Added
C["Party"]["HealthTag"]["Value"] = "|cffFF0000[-$>Tukui:ShortMissingHp]|r"
C["Party"]["AuraTrack"] = true


C["Raid"]["Enable"] = true
C["Raid"]["ShowPets"] = false
C["Raid"]["Highlight"] = false                  -- Added
C["Raid"]["Font"] = "UnitFrame"
C["Raid"]["HealthFont"] = "Small Thin"
C["Raid"]["MaxUnitPerColumn"] = 5               -- Bad things will happen if this is changed
C["Raid"]["ShowSolo"] = false                   -- Added (good for testing)
C["Raid"]["HealthTag"]["Value"] = "|cffFF0000[-$>Tukui:ShortMissingHp]|r"


C["Tooltips"]["HealthFont"] = "Small Bold"

C["UnitFrames"]["PlayerBuffs"] = false
C["UnitFrames"]["PlayerDebuffs"] = false
C["UnitFrames"]["TOTAuras"] = false
C["UnitFrames"]["PetAuras"] = false
C["UnitFrames"]["DarkTheme"] = false
C["UnitFrames"]["UnlinkCastBar"] = true
C["UnitFrames"]["BigNumberFont"] = "Large Bold"-- Added
C["UnitFrames"]["NumberFont"] = "Bold"       -- Added
C["UnitFrames"]["Font"] = "UnitFrame"
C["UnitFrames"]["WeakBar"] = false
C["UnitFrames"]["FocusTargetAuras"] = false
C["UnitFrames"]["OOCNameLevel"] = false
C["UnitFrames"]["PlayerHealthTag"]["Value"] = "[Tukui:CurrentHP][  |  $>Tukui:PercHpNotAtMax<$%]"
C["UnitFrames"]["TargetHealthTag"]["Value"] = "[$>Tukui:PercHpNotAtMax<$%  |  ][Tukui:CurrentHP]"
C["UnitFrames"]["FocusHealthTag"]["Value"] = "[Tukui:CurrentHP][  |  $>Tukui:PercHpNotAtMax<$%]"
C["UnitFrames"]["FocusTargetHealthTag"]["Value"] = "[Tukui:CurrentHP][  |  $>Tukui:PercHpNotAtMax<$%]"
C["UnitFrames"]["BossHealthTag"]["Value"] = "[Tukui:CurrentHP][  |  $>Tukui:PercHpNotAtMax<$%]"
C["UnitFrames"]["PlayerPowerTag"] = {
    ["Value"] = "[Tukui:CurrentPowerNonMana]"
}


-- Textures
local DefaultTex = "Gradient"
for key,_ in pairs(C["Textures"]) do
    C["Textures"][key] = DefaultTex
end
C["Textures"]["General"] = DefaultTex

-- Debuff Filters
local HardCCs = {
    -- Death Knight
    -- Demon Hunter
    217832,  -- Imprison
    -- Druid
    33786,   -- Cyclone
    339,     -- Entangling Roots
    -- Hunter
    117526,  -- Binding Shot
    203340,  -- Diamond Ice (survival honor talent)
    3355,    -- Freezing Trap
    19577,   -- Intimidation
    213691,  -- Scatter Shot
    -- Mage
    "Polymorph", -- A lot of variants for different animals
    -- Monk
    115078,  -- Paralysis
    -- Paladin
    -- Priest
    9484,    -- Shackle Undead
    20066,   -- Repentance
    -- Rogue
    6770,    -- Sap
    2094,    -- Blind
    -- Shaman
    "Hex", -- A lot of variants
    -- Warlock
    710,     -- Banish
    -- Warrior
}

local LustDebuffs = {
    -- Death Knight
    -- Demon Hunter
    -- Druid
    -- Hunter
    95809,  -- Insanity (Ancient Hysteria Debuff)
    160455, -- Fatigued (Netherwinds Debuff)
    264689, -- Fatigued (Primal Rage Debuff)
    -- Mage
    80354,  -- Temporal Displacement
    -- Monk
    -- Paladin
    -- Roguee
    -- Shaman
    57723,  -- Exhaustion
    -- Warlock
    -- Warrior
}

local DungeonDebuffBlacklist = {
    206151, -- Challenger's Burden
    256200, -- Heartstopper Venom (Last Boss of Tol Dagor)
}

local EnemyBuffWhitelist = {
    -- Death Knight
    48707,  -- Anti-Magic Shell
    48265,  -- Death's Advance
    48792,  -- Icebound Fortitude
    -- Demon hunter
    212800, -- Blur
    187827, -- Metamorphosis
    196555, -- Netherwalk
    188501, -- Spectral Sight
    -- Druid
    22812,  -- Barkskin
    22842,  -- Frenzied Regeneration
    102560, -- Incarnation: Guardian of Elune
    102558, -- Incarnation: Guardian of Ursol
    102543, -- Incarnation: King of the Jungle
    33891,  -- Incarnation: Tree of Life
    102342, -- Ironbark
    61336,  -- Survival Instincts
    236696, 305497, -- Thorns
    -- Hunter
    186265, -- Aspect of the Turtle
    19574,  -- Bestial Wrath
    272682, -- Master's Call
    288613, -- Trueshot
    -- Mage
    108978, -- Alter Time
    190319, -- Combustion
    45438,  -- Ice Block
    -- Monk
    122783, -- Diffuse Magic
    115203, 201318, 243435, -- Fortifying Brew
    116849, -- Life Cocoon
    137639, -- Storm, Earth, and Fire
    125174, -- Touch of Karma
    -- Paladin
    31884,  -- Avenging Wrath
    1044,   -- Blessing of Freedom
    1022,   -- Blessing of Protection
    6940,   -- Blessing of Sacrifice
    642,    -- Divine Shield
    86659, 212641, -- Guardian of Ancient Kings (and glyphed version)
    228049, -- Guardian of the Forgotten Queen
    -- Priest
    197871, -- Dark Archangel
    322108, -- Dispersion
    213610, -- Holy Ward
    33206,  -- Pain Suppression
    10060,  -- Power Infusion
    81782, 271466,  -- Power Word: Barrier
    194249, -- Voidform
    -- Rogue
    31224,  -- Cloak of Shadows
    5277,  -- Evasion
    199754, -- Riposte
    131471, -- Shadow Blades
    185313, -- Shadow Dance
    79140,  -- Vendetta
    --Shaman
    114050, 114051, 114052, -- Ascendance (3 specs)
    108271, 210918, -- Astral Shift/ Ethereal Form
    2825, 32182, -- Bloodlust/Heroism
    204945, -- Doom Winds
    8178, 34079, 204336, 255016,  -- Grounding Totem Effect
    98008,  -- Spirit Link Totem
    260878, -- Spirit Wolves
    -- Warlock
    --  ???
    -- Warrior
    107574, -- Avatar
    18499,  -- Berserker Rage
    197690, -- Defensive Stance
    315948, -- Die by the Sword
    316825, -- Rallying Cry
    1719,   -- Recklessness
    871,    -- Shield Wall
    23920, 213915, 216890, -- Spell Reflection

    -- Mob Buffs
    343502, -- Inspiring (affix buff)
}

local DefaultEntry = {}
for _,cc in ipairs(HardCCs) do
    C["NamePlates"]["DebuffWhitelist"][cc] = DefaultEntry
end
for _,debuff in ipairs(LustDebuffs) do
    C["Party"]["DebuffBlacklist"][debuff] = DefaultEntry
end
for _,debuff in ipairs(DungeonDebuffBlacklist) do
    C["Party"]["DebuffBlacklist"][debuff] = DefaultEntry
end
for _,buff in ipairs(EnemyBuffWhitelist) do
    C["NamePlates"]["BuffWhitelist"][buff] = DefaultEntry
end