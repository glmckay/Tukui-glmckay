local T, C, L = Tukui:unpack()

C["General"]["BackdropColor"] = {0.11, 0.11, 0.11, 0.8}
C["General"]["BorderColor"] = {0, 0, 0}

C["General"]["BorderSize"] = 1                      -- Added
C["General"]["FrameSpacing"] = 1                    -- Added
C["General"]["HideShadows"] = true


C["ActionBars"]["NormalButtonSize"] = 30
C["ActionBars"]["PetButtonSize"] = 27
C["ActionBars"]["CenterButtonSize"] = 40            -- Added
C["ActionBars"]["ShapeShift"] = false
C["ActionBars"]["HotKey"] = true
C["ActionBars"]["HideBackdrop"] = true
C["ActionBars"]["ButtonSpacing"] = 1
C["ActionBars"]["NumPlayerFrameButtons"] = 4
C["ActionBars"]["HideGrid"] = false


C["Auras"]["Fonts"] = "Small Bold"
C["Auras"]["Size"] = 34
C["Auras"]["Spacing"] = 3


-- General options for the added AuraTimers module
C["AuraTimers"] = {}
C["AuraTimers"]["Enable"] = false
C["AuraTimers"]["BorderSize"] = 2


C["Bags"]["ButtonSize"] = 32
C["Bags"]["Spacing"] = 3
C["Bags"]["ItemsPerRow"] = 11


C["Chat"]["ChatFont"] = "Regular"
C["Chat"]["TabFont"] = "Small Bold"


C["Cooldowns"]["Font"] = "Small Bold"


C["DataTexts"]["Font"] = "NoOutline Regular"
C["DataTexts"]["Time24HrFormat"] = true


C["Maps"] = {}
C["Maps"]["MinimapSize"] = 180                  -- Added (a couple things use this)


C["Misc"]["AutoInviteEnable"] = true
C["Misc"]["NumExpBars"] = 1                     -- Added (should be 0 to 2)


C["NamePlates"]["Font"] = "Small Bold"
C["NamePlates"]["Width"] = 154
C["NamePlates"]["Height"] = 16
C["NamePlates"]["CastHeight"] = 7
C["NamePlates"]["PlayerDebuffBlacklist"] = {}
C["NamePlates"]["DebuffWhitelist"] = {}         -- Added

C["Party"]["Enable"] = true
C["Party"]["Highlight"] = false                 -- Added
C["Party"]["Font"] = "Small Thin"
C["Party"]["HealthFont"] = "Small Bold"
C["Party"]["ShowPlayer"] = true
C["Party"]["ShowSolo"] = false                  -- Added (good for testing)
C["Party"]["DebuffBlacklist"] = {}              -- Added


C["Raid"]["Enable"] = true
C["Raid"]["ShowPets"] = false
C["Raid"]["Highlight"] = false                  -- Added
C["Raid"]["Font"] = "Small Thin"
C["Raid"]["HealthFont"] = "Small Thin"
C["Raid"]["MaxUnitPerColumn"] = 5               -- Bad things will happen if this is changed
C["Raid"]["ShowSolo"] = false                   -- Added (good for testing)


C["Tooltips"]["HealthFont"] = "Small Bold"


C["UnitFrames"]["DarkTheme"] = false
C["UnitFrames"]["UnlinkCastBar"] = true
C["UnitFrames"]["BigNumberFont"] = "Large Bold"-- Added
C["UnitFrames"]["NumberFont"] = "Bold"       -- Added
C["UnitFrames"]["Font"] = "Thin"
C["UnitFrames"]["WeakBar"] = false
C["UnitFrames"]["FocusTargetAuras"] = false


-- Textures
local DefaultTex = "GBlank"
for key,_ in pairs(C["Textures"]) do
    C["Textures"][key] = DefaultTex
end
C["Textures"]["General"] = DefaultTex

-- Debuff Filters
local HardCCs = {
    6770,    -- Sap
    2094,    -- Blind
    115078,  -- Paralysis
    20066,   -- Repentance
    2637,    -- Hibernate
    187650,  -- Freezing Trap
    217832,  -- Imprison
    710,     -- Banish
    9484,    -- Shackle Undead
    "Hex",
    "Polymorph",
}

local LustDebuffs = {
    57723,  -- Exhaustion
    80354,  -- Temporal Displacement
    95809,  -- Insanity (Ancient Hysteria Debuff)
    160455, -- Fatigued (Netherwinds Debuff)
    264689, -- Fatigued (Primal Rage Debuff)
}

local DungeonDebuffBlacklist = {
    206151, -- Challenger's Burden
    256200, -- Heartstopper Venom (Last Boss of Tol Dagor)
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