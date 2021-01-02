local T, C, L = Tukui:unpack()

local UnitFrames = T["UnitFrames"]
local Panels = T["Panels"]

local BorderSize = C.General.BorderSize
local FrameSpacing = C.General.FrameSpacing

local UFHeight = UnitFrames.FrameHeight
local UFWidth = UnitFrames.PlayerTargetWidth
-- local BarHeight = math.floor((UFHeight - (2*BorderSize + FrameSpacing)) / 2)
local BarHeight = 9 -- for now


if (T.MyClass ~= "DEATHKNIGHT") then
    return
end


UnitFrames.EditClassFeatures["DEATHKNIGHT"] = function(self)
    local Power = self.Power
    local Runes = self.Runes
    local TotalWidth = Panels.CenterPanelWidth - 2*BorderSize

    Runes:SetParent(Power)
    Runes:SetFrameLevel(0)
    Runes:ClearAllPoints()
    Runes:SetSize(TotalWidth, BarHeight)
    Runes:SetPoint("TOP", Panels.UnitFrameAnchor, 0, -BorderSize)

    local EffectiveWidth = TotalWidth - 5*(2*BorderSize + FrameSpacing)
    local BarWidth = math.floor(EffectiveWidth / 6)
    local LastRune

    for i,Rune in ipairs(Runes) do
        Rune:CreateBackdrop()
        Rune:SetHeight(BarHeight)
        if (i == 1) then
            Rune:SetWidth(EffectiveWidth - 5*BarWidth)
        else
            Rune:SetWidth(BarWidth)
        end

        if (LastRune) then
            Rune:SetPoint("LEFT", LastRune, "RIGHT", 2*BorderSize + FrameSpacing, 0)
        end
        LastRune = Rune
    end

    Runes.sortOrder = "asc"
end

