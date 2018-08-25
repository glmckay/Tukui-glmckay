local T, C, L = unpack(Tukui)

local Experience = T["Miscellaneous"].Experience
local BorderSize = C["General"].BorderSize
local FrameSpacing = C["General"].FrameSpacing
local NumBars = C["Misc"]["NumExpBars"] or 2

Experience.BarHeight = 4


local function EditBars(self)
    for i = 1, self.NumBars do
        local XPBar = self["XPBar"..i]
        local RestedBar = self["RestedBar"..i]

        if (i <= 2 - NumBars) then
            XPBar:Kill()
            RestedBar:Kill()
        else
            XPBar:SetStatusBarTexture(T.GetTexture(C["Textures"].General))
            RestedBar:SetStatusBarTexture(T.GetTexture(C["Textures"].General))

            XPBar:SetOrientation("Horizontal")
            XPBar:SetReverseFill(false)
            RestedBar:SetOrientation("Horizontal")
            RestedBar:SetReverseFill(false)

            local anchorFrame = (((i == 3 - NumBars) and Minimap) or self["XPBar"..i-1])
            XPBar:ClearAllPoints()
            XPBar:Point("TOPLEFT", anchorFrame, "BOTTOMLEFT", 0, -(BorderSize*2 + FrameSpacing))
            XPBar:Point("TOPRIGHT", anchorFrame, "BOTTOMRIGHT", 0, -(BorderSize*2 + FrameSpacing))
            XPBar:Height(self.BarHeight)
        end
    end
end

-- We use SetPoint instead of SetOwner as the latter will clear the tooltip contents and hide it
local function MoveTooltip(self)
    GameTooltip:ClearAllPoints()
    GameTooltip:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, -36)
end

hooksecurefunc(Experience, "Create", EditBars)
hooksecurefunc(Experience, "SetTooltip", MoveTooltip)
