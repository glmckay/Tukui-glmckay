local T, C, L = Tukui:unpack()

local UnitFrames = T["UnitFrames"]
local Panels = T["Panels"]

local BorderSize = C.General.BorderSize
local FrameSpacing = C.General.FrameSpacing

local UFHeight = UnitFrames.FrameHeight
local UFWidth = UnitFrames.PlayerTargetWidth
-- local BarHeight = math.floor((UFHeight - (2*BorderSize + FrameSpacing)) / 2)
local BarHeight = 9 -- for now


if (T.MyClass ~= "MONK") then
    return
end


UnitFrames.EditClassFeatures["MONK"] = function(self)
    -- Windwalker chi indicator
    local Power = self.Power
    local Harmony = self.HarmonyBar
    local TotalWidth = Panels.CenterPanelWidth - 2*BorderSize

    Harmony:SetBackdrop({})

    Harmony:SetParent(Power)
    Harmony:SetFrameLevel(0)
    Harmony:ClearAllPoints()
    Harmony:Size(TotalWidth, BarHeight)
    Harmony:Point("TOP", Panels.UnitFrameAnchor, 0, -BorderSize)

    -- The Chi colour is hardcoded, so we have to resort to the old "I changed it and threw away the function"
    local c = T["Colors"]["power"]["CHI"]
    for _,bar in ipairs(Harmony) do
        bar:Height(BarHeight)
        bar:SetStatusBarColor(unpack(c))
        bar.SetStatusBarColor = function() end
    end

    local LastHarmony = nil
    for i,Bar in ipairs(Harmony) do
        local EffectiveWidth = TotalWidth - 5*(2*BorderSize + FrameSpacing)

        if (i == 1) then
            Bar:Width(EffectiveWidth - 5*math.floor(EffectiveWidth / 6))
        else
            Bar:Width(math.floor(EffectiveWidth / 6))
        end

        EffectiveWidth = TotalWidth - 4*(2*BorderSize + FrameSpacing)

        if (i == 3) then
            Bar.NoTalent = EffectiveWidth - 4*math.floor(EffectiveWidth / 5)
        else
            Bar.NoTalent = math.floor(EffectiveWidth / 5)
        end

        Bar:CreateBackdrop()
        if (LastHarmony) then
            Bar:Point("LEFT", LastHarmony, "RIGHT", 2*BorderSize + FrameSpacing, 0)
        end
        LastHarmony = Bar
    end

    -- Add Brewmaster stagger bar
    local Stagger = CreateFrame('StatusBar', self:GetName().."StaggerBar", Power)
    Stagger:SetFrameLevel(0)
    Stagger:CreateBackdrop()
    Stagger:SetStatusBarTexture(C["Medias"]["Blank"])
    Stagger:Height(BarHeight)
    Stagger:Point("BOTTOMLEFT", Power, "TOPLEFT", 0, FrameSpacing + 2*BorderSize)
    Stagger:Point("BOTTOMRIGHT", Power, "TOPRIGHT", 0, FrameSpacing + 2*BorderSize)

    self.Stagger = Stagger
end