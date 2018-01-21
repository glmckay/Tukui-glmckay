local T, C, L = Tukui:unpack()

-- Get rid of minimap datatext frames and set the minimap as the anchor for
--  a datatext at its bottom
function Minimap:AddMinimapDataTexts()
    T["Panels"].MinimapDataTextOne = self
end

local function EditZoneAndCoords(self)
    local Zone = Minimap.MinimapZone
    local Coords = Minimap.MinimapCoords

    Zone:SetBackdrop({})
    Zone.Text:SetFont(C["Medias"].Express, 12, "THINOUTLINE")
    -- Zone.Text:SetParent(Minimap) -- If I want the zone to always be shown
    Zone.Text:ClearAllPoints()
    Zone.Text:Point("CENTER", Minimap, "TOP", 0, 1)

    Coords:SetBackdrop({})
    Coords.Text:SetFont(C["Medias"].Express, 11, "THINOUTLINE")
end

hooksecurefunc(Minimap, "AddZoneAndCoords", EditZoneAndCoords)
