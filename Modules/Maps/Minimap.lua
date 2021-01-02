local T, C, L = Tukui:unpack()

-- Invisible DataText frame
function Minimap:AddMinimapDataTexts()
    local Backdrop = self.Backdrop

	local MinimapDataText = CreateFrame("Frame", nil, self)
	MinimapDataText:SetSize(self.Backdrop:GetWidth(), 19)
	MinimapDataText:SetPoint("TOPLEFT", self.Backdrop, "BOTTOMLEFT", 0, 0)

	T.DataTexts.Panels.Minimap = MinimapDataText
end

local function EditZoneAndCoords(self)
    local Zone = Minimap.MinimapZone
    local Coords = Minimap.MinimapCoords

    T.Toolkit.Functions.HideBackdrop(Zone)
    Zone.Text:SetFont(C["Medias"].RegFont, 16, "OUTLINE")
    -- Zone.Text:SetParent(Minimap) -- If I want the zone to always be shown
    Zone.Text:ClearAllPoints()
    Zone.Text:SetPoint("CENTER", Minimap, "TOP", 0, 1)

    T.Toolkit.Functions.HideBackdrop(Coords)
    Coords.Text:SetFont(C["Medias"].RegFont, 13, "OUTLINE")
end

local function EditMinimapSize()
    Minimap:SetSize(C["Maps"]["MinimapSize"], C["Maps"]["MinimapSize"])

    WorldMapFrame:HookScript("OnShow", function(self)
        self:ClearAllPoints()
        self:SetPoint("LEFT", UIParent, "LEFT", 30, 0)
    end)
end

hooksecurefunc(Minimap, "AddZoneAndCoords", EditZoneAndCoords)
hooksecurefunc(Minimap, "PositionMinimap", EditMinimapSize)
