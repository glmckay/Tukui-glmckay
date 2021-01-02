local T, C, L = unpack(Tukui)

local Reputation = T["Miscellaneous"].Reputation
local Experience = T["Miscellaneous"].Experience
local BorderSize = C["General"].BorderSize
local FrameSpacing = C["General"].FrameSpacing
local NumBars = C["Misc"]["NumExpBars"] or 2
local Noop = function() end


local function EditBars(self)
    for i = 1, self.NumBars do
        local RepBar = self["RepBar"..i]

        if (i > 2 - NumBars) then
            RepBar:Kill()
        else
            RepBar:SetStatusBarTexture(T.GetTexture(C["Textures"].General))
            RepBar:SetOrientation("Horizontal")

            local anchorFrame = ((i == 1 and Minimap) or self["RepBar"..i-1])
            RepBar:ClearAllPoints()
            RepBar:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT", 0, -(BorderSize*2 + FrameSpacing))
            RepBar:SetPoint("TOPRIGHT", anchorFrame, "BOTTOMRIGHT", 0, -(BorderSize*2 + FrameSpacing))
            RepBar:SetHeight(Experience.BarHeight)
        end
    end
end

local function MoveTooltip(self)
    GameTooltip:ClearAllPoints()
    GameTooltip:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, -36)
end

-- Tukui expect at least two bars to show/hide
if (Reputation.NumBars < 2) then
    for i = Reputation.NumBars+1, 2 do
        Reputation["RepBar"..i] = { Show = Noop, Hide = Noop }
    end
end

hooksecurefunc(Reputation, "Create", EditBars)
hooksecurefunc(Reputation, "SetTooltip", MoveTooltip)
