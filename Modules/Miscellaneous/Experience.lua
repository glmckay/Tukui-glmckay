local T, C, L = unpack(Tukui)

local Experience = T["Miscellaneous"].Experience
local BorderSize = C["General"].BorderSize

local function EditBars(self)
    for i = 1, self.NumBars do
        local XPBar = self["XPBar"..i]
        local RestedBar = self["RestedBar"..i]

        XPBar:SetStatusBarTexture(C["Medias"].Blank)
        XPBar:SetOrientation("Horizontal")

        RestedBar:SetStatusBarTexture(C["Medias"].Blank)
        RestedBar:SetOrientation("Horizontal")

        local anchorFrame = ((i == 1 and Minimap) or self["XPBar"..i-1])
        XPBar:ClearAllPoints()
        XPBar:Point("TOPLEFT", anchorFrame, "BOTTOMLEFT", 0, -BorderSize)
        XPBar:Point("TOPRIGHT", anchorFrame, "BOTTOMRIGHT", 0, -BorderSize)
        XPBar:Height(6)
    end
end

-- We use SetPoint instead of SetOwner as the latter will clear the tooltip contents and hide it
local function MoveTooltip(self)
    GameTooltip:ClearAllPoints()
    GameTooltip:SetPoint("TOPRIGHT", Minimap, "BOTTOMRIGHT", 0, -36)
end

hooksecurefunc(Experience, "Create", EditBars)
hooksecurefunc(Experience, "SetTooltip", MoveTooltip)
