local T, C, L = Tukui:unpack()

-- Get rid of minimap datatext frames
function Minimap:AddMinimapDataTexts()
end

local function EditZoneAndCoords(self)
    local Zone = Minimap.MinimapZone
    local Coords = Minimap.MinimapCoords

    Zone:SetBackdrop({})
    Zone.Text:SetFont(C["Medias"].RegFont, 16, "OUTLINE")
    -- Zone.Text:SetParent(Minimap) -- If I want the zone to always be shown
    Zone.Text:ClearAllPoints()
    Zone.Text:Point("CENTER", Minimap, "TOP", 0, 1)

    Coords:SetBackdrop({})
    Coords.Text:SetFont(C["Medias"].RegFont, 14, "OUTLINE")
end

local TukuiAuras = T["Auras"]

local function EditMinimapSize()
    Minimap:Size(C["Maps"]["MinimapSize"])

    WorldMapFrame:HookScript("OnShow", function(self)
        self:ClearAllPoints()
        self:SetPoint("LEFT", UIParent, "LEFT", 30, 0)
    end)
end

hooksecurefunc(Minimap, "AddZoneAndCoords", EditZoneAndCoords)
hooksecurefunc(Minimap, "PositionMinimap", EditMinimapSize)
