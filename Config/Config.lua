local T, C, L = Tukui:unpack()

C["General"]["BackdropColor"] = {0.15, 0.15, 0.15}
C["General"]["BorderColor"] = {0, 0, 0}
C["General"]["BorderSize"] = 1                      -- Added
C["General"]["FrameSpacing"] = 1                    -- Added

C["ActionBars"]["NormalButtonSize"] = 30
C["ActionBars"]["PetButtonSize"] = 27
C["ActionBars"]["CenterButtonSize"] = 40            -- Added
C["ActionBars"]["PlayerButtonSize"] = 29
C["ActionBars"]["ShapeShift"] = false
C["ActionBars"]["HotKey"] = true
C["ActionBars"]["HideBackdrop"] = true
C["ActionBars"]["ButtonSpacing"] = 1
C["ActionBars"]["HideGrid"] = true

C["Auras"]["Fonts"] = "Roboto 11"

-- General options for the added AuraTimers module
C["AuraTimers"] = {}
C["AuraTimers"]["Enable"] = true
C["AuraTimers"]["BorderSize"] = 2

C["Bags"]["ButtonSize"] = 32
C["Bags"]["Spacing"] = 3
C["Bags"]["ItemsPerRow"] = 11


C["Chat"]["ChatFont"] = "Roboto 13"
C["Chat"]["TabFont"] = "Roboto 12"

C["Cooldowns"]["Font"] = "Roboto 11"

C["DataTexts"]["Font"] = "Roboto 12"
C["DataTexts"]["Time24HrFormat"] = true

C["Maps"] = {}
C["Maps"]["MinimapSize"] = 180

C["Misc"]["AutoInviteEnable"] = true

C["NamePlates"]["Font"] = "Roboto 13"
C["NamePlates"]["Texture"] = "Blank"

C["Party"]["Enable"] = true
C["Party"]["Portrait"] = false
C["Party"]["Font"] = "Roboto 12"
C["Party"]["HealthFont"] = "Roboto 12"
C["Party"]["HealthTexture"] = "Blank"
C["Party"]["PowerTexture"] = "Blank"
C["Party"]["ShowSolo"] = false                  -- Added (good for testing)

C["Raid"]["Enable"] = true
C["Raid"]["ShowPets"] = false
C["Raid"]["Font"] = "Roboto 12"
C["Raid"]["HealthFont"] = "Roboto 12"
C["Raid"]["HealthTexture"] = "Blank"
C["Raid"]["PowerTexture"] = "Blank"
C["Raid"]["MaxUnitPerColumn"] = 5               -- Bad things will happen if this is changed
C["Raid"]["ShowSolo"] = false                   -- Added (good for testing)

C["Tooltips"]["HealthFont"] = "Roboto 12"
C["Tooltips"]["HealthTexture"] = "Blank"

C["UnitFrames"]["DarkTheme"] = false
C["UnitFrames"]["UnlinkCastBar"] = true
C["UnitFrames"]["UnlinkPower"] = true           -- Added
C["UnitFrames"]["Font"] = "Roboto 14"
C["UnitFrames"]["SmallFont"] = "Roboto 12"     -- Added
C["UnitFrames"]["HealthTexture"] = "Blank"
C["UnitFrames"]["PowerTexture"] = "Blank"
C["UnitFrames"]["CastTexture"] = "Blank"
C["UnitFrames"]["WeakBar"] = false
