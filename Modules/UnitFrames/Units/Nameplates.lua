local T, C, L = Tukui:unpack()

local BorderSize = C["General"].BorderSize

local Font = T.GetFont(C["NamePlates"].Font)
local FontOffset = C["Medias"].FontOffset
local CastIconSize = C.NamePlates.Height + C.NamePlates.CastHeight + BorderSize


local function EditNameplates(self)
    local r,g,b = unpack(C["General"]["BackdropColor"])
    self:SetTemplate()
    self:SetBackdropColor(r, g, b)

    local Health = self.Health
    Health:ClearAllPoints()
    Health:SetInside()

    Health.UpdateColor = UpdateNamePlateColor
    Health.Background:Kill()

    local Name = self.Name
    Name:ClearAllPoints()
    Name:Point("BOTTOMLEFT", Health, "TOPLEFT", -2, 0)

    self.Power:Kill()
    self.Power = nil

    local Debuffs = self.Debuffs
    Debuffs:ClearAllPoints()
    Debuffs:Point("BOTTOMLEFT", self, "TOPLEFT", 0, 15)

    local CastBar = self.Castbar
    CastBar:ClearAllPoints()
    CastBar:Point("TOPLEFT", self, "BOTTOMLEFT", BorderSize, 0)
    CastBar:Point("TOPRIGHT", self, "BOTTOMRIGHT", -BorderSize, 0)

    CastBar.Button:Size(CastIconSize)
    CastBar.Button:ClearAllPoints()
    CastBar.Button:Point("TOPLEFT", self, "TOPRIGHT", 0, 0)

    CastBar.Background:Kill()
    CastBar:CreateBackdrop()

    local Text = CastBar:CreateFontString(nil, "OVERLAY")
    Text:Point("TOPLEFT", CastBar, "BOTTOMLEFT", -2, -2)
    Text:SetJustifyH("LEFT")
    Text:SetFontObject(Font)
    Text:SetFont(C["Medias"].VeryThinFont, 12, "OUTLINE")
    Text:SetTextColor(.9,.9,.9)
    CastBar.Text = Text

    local Shadow = self.Shadow
    CastBar:SetScript("OnShow", function()
        Shadow:Point("BOTTOMRIGHT", CastBar.Button, 4, -4)
    end)
    CastBar:SetScript("OnHide", function()
        Shadow:Point("BOTTOMRIGHT", self, 4, -4)
    end)
end

hooksecurefunc(T["UnitFrames"], "Nameplates", EditNameplates)
