local T, C, L = Tukui:unpack()

C["General"]["BackdropColor"] = {0.11, 0.11, 0.11, 0.6}
C["General"]["BorderColor"] = {0, 0, 0}

C["General"]["BorderSize"] = 1                      -- Added
C["General"]["FrameSpacing"] = 1                    -- Added
C["General"]["HideShadows"] = true


C["ActionBars"]["NormalButtonSize"] = 30
C["ActionBars"]["PetButtonSize"] = 27
C["ActionBars"]["CenterButtonSize"] = 40            -- Added
C["ActionBars"]["PlayerButtonSize"] = 29
C["ActionBars"]["ShapeShift"] = false
C["ActionBars"]["HotKey"] = true
C["ActionBars"]["HideBackdrop"] = true
C["ActionBars"]["ButtonSpacing"] = 1
C["ActionBars"]["HideGrid"] = true


C["Auras"]["Fonts"] = "Small Bold"
C["Auras"]["Size"] = 34
C["Auras"]["Spacing"] = 3


-- General options for the added AuraTimers module
C["AuraTimers"] = {}
C["AuraTimers"]["Enable"] = true
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
C["NamePlates"]["CastHeight"] = 7


C["Party"]["Enable"] = true
C["Party"]["Highlight"] = false                 -- Added
C["Party"]["Font"] = "Small Thin"
C["Party"]["HealthFont"] = "Small Bold"
C["Party"]["ShowPlayer"] = true
C["Party"]["ShowSolo"] = false                  -- Added (good for testing)


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