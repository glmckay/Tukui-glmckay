local T, C, L = Tukui:unpack()

C["General"]["BackdropColor"] = {0.15, 0.15, 0.15, 0.6}
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

C["NamePlates"]["Font"] = "Small Bold"
C["NamePlates"]["Texture"] = "Tukui"

C["Party"]["Enable"] = true
C["Party"]["Portrait"] = false
C["Party"]["Font"] = "Small Bold"
C["Party"]["HealthFont"] = "Small Bold"
C["Party"]["HealthTexture"] = "Blank"
C["Party"]["PowerTexture"] = "Blank"
C["Party"]["ShowSolo"] = false                  -- Added (good for testing)

C["Raid"]["Enable"] = true
C["Raid"]["ShowPets"] = false
C["Raid"]["Font"] = "Small Bold"
C["Raid"]["HealthFont"] = "Small Bold"
C["Raid"]["HealthTexture"] = "Blank"
C["Raid"]["PowerTexture"] = "Blank"
C["Raid"]["MaxUnitPerColumn"] = 5               -- Bad things will happen if this is changed
C["Raid"]["ShowSolo"] = false                   -- Added (good for testing)

C["Tooltips"]["HealthFont"] = "Small Bold"
C["Tooltips"]["HealthTexture"] = "Blank"

C["UnitFrames"]["DarkTheme"] = false
C["UnitFrames"]["UnlinkCastBar"] = true
C["UnitFrames"]["BigNumberFont"] = "Large Bold"-- Added
C["UnitFrames"]["NumberFont"] = "Bold"       -- Added
C["UnitFrames"]["Font"] = "Thin"
C["UnitFrames"]["HealthTexture"] = "Tukui"
C["UnitFrames"]["PowerTexture"] = "Tukui"
C["UnitFrames"]["CastTexture"] = "Tukui"
C["UnitFrames"]["WeakBar"] = false
