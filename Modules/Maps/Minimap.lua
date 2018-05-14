local T, C, L = Tukui:unpack()

local Maps = T["Maps"]

-- Get rid of minimap datatext frames and set the minimap as the anchor for
--  a datatext at its bottom
function Minimap:AddMinimapDataTexts()
    T["Panels"].MinimapDataTextOne = self
end

local function EditZoneAndCoords(self)
    local Zone = Minimap.MinimapZone
    local Coords = Minimap.MinimapCoords

    Zone:SetBackdrop({})
    Zone.Text:SetFont(C["Medias"].RobotoCondBold, 13, "THINOUTLINE")
    -- Zone.Text:SetParent(Minimap) -- If I want the zone to always be shown
    Zone.Text:ClearAllPoints()
    Zone.Text:Point("CENTER", Minimap, "TOP", 0, 1)

    Coords:SetBackdrop({})
    Coords.Text:SetFont(C["Medias"].RobotoCondBold, 12, "THINOUTLINE")
end

function Minimap:EnableEdits()
    self:Size(C["Maps"]["MinimapSize"])
end

hooksecurefunc(Minimap, "AddZoneAndCoords", EditZoneAndCoords)
