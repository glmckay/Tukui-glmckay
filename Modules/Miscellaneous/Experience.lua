local T, C, L = unpack(Tukui)

local Experience = T["Miscellaneous"].Experience
local BorderSize = C["General"].BorderSize

local function EnableEdit(self)
    for i = 1,self.NumBars do
        local bar = self["XPBar"..i]
        local anchorFrame = ((i == 1 and Minimap) or self["XPBar"..i-1])
        bar:SetOrientation("Horizontal")
        bar:ClearAllPoints()
        bar:Point("TOPLEFT", anchorFrame, "BOTTOMLEFT", 0, -BorderSize)
        bar:Point("TOPRIGHT", anchorFrame, "BOTTOMRIGHT", 0, -BorderSize)
        bar:Height(6)
    end
end

-- We use SetPoint instead of SetOwner as the latter will clear the tooltip contents and hide it
local function MoveTooltip(self)
    GameTooltip:ClearAllPoints()
    GameTooltip:SetPoint("TOPRIGHT", Minimap, "BOTTOMRIGHT", 0, -36)
end

hooksecurefunc(Experience, "Enable", EnableEdit)
hooksecurefunc(Experience, "SetTooltip", MoveTooltip)
