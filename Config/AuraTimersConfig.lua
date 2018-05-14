local T, C, L = unpack(Tukui)

local AuraTimers = CreateFrame("Frame")

-- Inventory Ids
--  0: ammo
--  1: head
--  2: neck
--  3: shoulder
--  4: shirt
--  5: chest
--  6: waist
--  7: legs
--  8: feet
--  9: wrists
-- 10: hands
-- 11: finger1
-- 12: finger2
-- 13: trinket1
-- 14: trinket2
-- 15: backmain hand
-- 16: main hand
-- 17: off hand
-- 18: ranged
-- 19: tabard


-- Mandatory:
--   Name
--   Direction
--   Width/Height (or Size)
--   Spacing
--   AnchorPoint
--   Mode:
--     Bar:
--       BarTexture
--       Font (if ExtraOptions requires it)
--     Icon:
--       Font

-- Optional:
--   ParentFrame
--   ExtraOptions:
--     HideOutOfCombat
--     SortReverse
--     AllowedSpecs
--     Bar:
--       ShowName
--       ShowTime
--       ShowIcon


function AuraTimers:LoadSettings()
    local Player = T.UnitFrames.Units.Player
    local Target = T.UnitFrames.Units.Target

    C["AuraTimers"]["SHAMAN"] = {
        {
            Name = "ElementalSpecialBuffs",
            Direction = "UP",
            Size = 36,
            Spacing = 7,
            AnchorPoint = { "BOTTOMRIGHT", Player, "TOPRIGHT", -20, 20 },
            Mode = "ICON",
            Font = "Roboto 20",
            ExtraOptions = {
                AllowedSpecs = {
                    Elemental = true,
                    Enhancement = true,
                },
                HideOutOfCombat = true,
            },

            -- Lightning rod
            { SpellId = 210689, UnitId = "target", Caster = "player", Filter = "DEBUFF" , Color = { 0.5, 0.7, 0.9 } },
            -- Ascendance
            { SpellId = 114050, UnitId = "player", Caster = "player", Filter = "BUFF", },
            -- Stormkeeper
            { SpellId = 205495, UnitId = "player", Caster = "player", Filter = "BUFF", },
            -- Icefury
            { SpellId = 210714, UnitId = "player", Caster = "player", Filter = "BUFF", },
        },
        -- {
        --     Name = "ElementalTargetTimers",
        --     Direction = "DOWN",
        --     Width = Target:GetWidth(),
        --     Height = 18,
        --     Spacing = 1,
        --     AnchorPoint = { "TOP", Target, "BOTTOM", 0, -5 },
        --     Mode = "BAR",
        --     Font = "Express 11",
        --     BarTexture = "Blank",
        --     ParentFrame = Target,
        --     ExtraOptions = {
        --         AllowedSpecs = {
        --             Elemental = true,
        --         },
        --         HideOutOfCombat = true,
        --         SortReverse = true,
        --         ShowIcon = true,
        --         ShowName = true,
        --         ShowTime = true,
        --     },

        --     -- Lightning rod
        --     { SpellId = 210689, UnitId = "target", Caster = "player", Filter = "DEBUFF" , Color = { 0.5, 0.7, 0.9 } },
        -- },
        {
            Name = "RestoDamageTimers",
            Direction = "DOWN",
            Width = Target:GetWidth(),
            Height = 18,
            Spacing = 1,
            AnchorPoint = { "TOP", Target, "BOTTOM", 0, -5 },
            Mode = "BAR",
            Font = "Roboto 11",
            BarTexture = "Blank",
            ParentFrame = Target,
            ExtraOptions = {
                AllowedSpecs = {
                    Restoration = true,
                },
                HideOutOfCombat = true,
                SortReverse = true,
                ShowIcon = true,
                ShowName = true,
                ShowTime = true,
            },

            -- Flame Shock
            { SpellId = 188389, UnitId = "target", Caster = "player", Filter = "DEBUFF", Color = { 0.9, 0.5, 0.1 } },
            -- Lava Burst
            { SpellId = 51505, Filter = "COOLDOWN", Color = { 0.9, 0.35, 0.1 } },
        },
        -- {
        --     Name = "ElementalSpellTimers",
        --     Direction = "DOWN",
        --     Width = Player.Power:GetWidth(),
        --     Height = 18,
        --     Spacing = 1,
        --     AnchorPoint = { "TOP", Player.Power, "BOTTOM", 0, -5 },
        --     Font = "Express 11",
        --     Mode = "BAR",
        --     BarTexture = "Blank",
        --     ExtraOptions = {
        --         AllowedSpecs = {
        --             Elemental = true,
        --         },
        --         HideOutOfCombat = true,
        --         ShowIcon = true,
        --         ShowName = true,
        --         ShowTime = true,
        --         SortReverse = true,
        --     },

        --     -- Flame Shock
        --     { SpellId = 188389, UnitId = "target", Caster = "player", Filter = "DEBUFF", Color = { 0.9, 0.5, 0.1 } },
        --     -- Elemental Blast
        --     { SpellId = 117014, Filter = "COOLDOWN", Color = { 0.7, 0.25, 0.7 } },
        --     -- Lava Burst
        --     { SpellId = 51505, Filter = "CHARGE_COOLDOWN", MultiBar = true, ColorList = { { 1, 0.1, 0.1 }, { 0.9, 0.35, 0.1 } } },
        --     -- Stormkeeper
        --     { SpellId = 205495, Filter = "COOLDOWN" , Color = { 0, 0.7, 0.6 } },
        --     -- Icefury
        --     { SpellId = 210714, Filter = "COOLDOWN", Color = { 0.5, 0.4, 0.9 }}
        -- },
        -- {
        --     Name = "ElementalSpellTimersIcons",
        --     Direction = "RIGHT",
        --     Size = 30,
        --     Spacing = 1,
        --     AnchorPoint = { "TOPLEFT", Player.Power, "BOTTOMLEFT", 0, -5 },
        --     Font = "Express 12",
        --     Mode = "ICON",
        --     ExtraOptions = {
        --         AllowedSpecs = {
        --             Elemental = true,
        --         },
        --         HideOutOfCombat = true,
        --         AlwaysShow = true,
        --     },

        --     -- Flame Shock
        --     { SpellId = 188389, UnitId = "target", Caster = "player", Filter = "DEBUFF", Color = { 0.9, 0.5, 0.1 } },
        --     -- Elemental Blast
        --     { SpellId = 117014, Filter = "COOLDOWN", Color = { 0.7, 0.25, 0.7 } },
        --     -- Lava Burst
        --     { SpellId = 51505, Filter = "CHARGE_COOLDOWN", MultiBar = true, ColorList = { { 1, 0.1, 0.1 }, { 0.9, 0.35, 0.1 } } },
        --     -- Stormkeeper
        --     { SpellId = 205495, Filter = "COOLDOWN" , Color = { 0, 0.7, 0.6 } },
        --     -- Icefury
        --     { SpellId = 210714, Filter = "COOLDOWN", Color = { 0.5, 0.4, 0.9 }}
        -- },
        -- {
        --     Name = "RestoSpellTimers",
        --     Direction = "DOWN",
        --     Width = Player:GetWidth(),
        --     Height = 18,
        --     Spacing = 1,
        --     AnchorPoint = { "TOP", Player.Power, "BOTTOM", 0, -5 },
        --     Font = "Express 11",
        --     Mode = "BAR",
        --     BarTexture = "Blank",
        --     ExtraOptions = {
        --         AllowedSpecs = {
        --             Restoration = true,
        --         },
        --         HideOutOfCombat = true,
        --         ShowIcon = true,
        --         ShowName = true,
        --         ShowTime = true,
        --         SortReverse = true,
        --     },

        --     -- Tidal Waves
        --     -- { SpellId = 51564, UnitId = "player", Caster = "player", Filter = "BUFF" , Color = { 0, 0.4, 0.8 } },
        --     -- Cloudburst Totem
        --     { SpellId = 157153, Filter = "COOLDOWN", Color = { 0.35, 0.65, 0.8 } },
        --     -- Riptide
        --     { SpellId = 61295, Filter = "COOLDOWN", Color = { 0.15, 0.35, 0.35 } },
        --     -- Healing Stream Totem
        --     { SpellId = 5394, Filter = "COOLDOWN", Color = { 0.2, 0.55, 0.8 } },
        --     -- Healing Rain
        --     { SpellId = 73920, Filter = "COOLDOWN", Color = { 0, 0.3, 0.9 } },
        --     -- Gift of the Queen
        --     { SpellId = 207778, Filter = "COOLDOWN", Color = { 0.5, 0.7, 0.2 } },
        -- },
    }
end

T["AuraTimers"] = AuraTimers