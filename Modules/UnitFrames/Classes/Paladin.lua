local T, C, L = Tukui:unpack()

local UnitFrames = T["UnitFrames"]
local Panels = T["Panels"]

local BorderSize = C.General.BorderSize
local FrameSpacing = C.General.FrameSpacing

local UFHeight = UnitFrames.FrameHeight
local UFWidth = UnitFrames.PlayerTargetWidth
-- local BarHeight = math.floor((UFHeight - (2*BorderSize + FrameSpacing)) / 2)
local BarHeight = 9 -- for now


if (T.MyClass ~= "PALADIN") then
    return
end


UnitFrames.EditClassFeatures["PALADIN"] = function(self)
    local Power = self.Power
    local HolyPower = self.HolyPower
    local TotalWidth = Panels.CenterPanelWidth - 2*BorderSize

    HolyPower:SetParent(Power)
    HolyPower:SetFrameLevel(0)
    HolyPower:ClearAllPoints()
    HolyPower:SetSize(TotalWidth, BarHeight)
    HolyPower:SetPoint("TOP", Panels.UnitFrameAnchor, 0, -BorderSize)

    local EffectiveWidth = TotalWidth - 4*(2*BorderSize + FrameSpacing)
    local BarWidth = math.floor(EffectiveWidth / 5)
    local LastBar

    for i,Bar in ipairs(HolyPower) do
        Bar:CreateBackdrop()
        Bar:SetHeight(BarHeight)
        if (i == 1) then
            Bar:SetWidth(EffectiveWidth - 4*BarWidth)
        else
            Bar:SetWidth(BarWidth)
        end

        if (LastBar) then
            Bar:SetPoint("LEFT", LastBar, "RIGHT", 2*BorderSize + FrameSpacing, 0)
        end
        LastBar = Bar
    end

    HolyPower.sortOrder = "asc"
end

