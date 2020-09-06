local T, C, L = Tukui:unpack()

local BorderSize = C["General"].BorderSize

local AuraWidth = 30
local AuraHeight = 18

local Font = T.GetFont(C["NamePlates"].Font)
local CastIconSize = C.NamePlates.Height + C.NamePlates.CastHeight + BorderSize
local ClickableHeight = C.NamePlates.Height + 2*(C.NamePlates.CastHeight + BorderSize)
local ClickPadding = C.NamePlates.CastHeight + 2*BorderSize

local FilterDebuffs = nil
local DebuffWhitelist = C["NamePlates"].DebuffWhitelist
local PlayerDebuffBlacklist = C["NamePlates"].PlayerDebuffBlacklist

if next(DebuffWhitelist) ~= nil or next(PlayerDebuffBlacklist) ~= nil then
    FilterDebuffs = function(self, unit, button, ...)
        local Name, Caster, Id = select(1, ...), select(7, ...), select(10, ...)
        if (Caster == 'player') then
            return not (PlayerDebuffBlacklist[Id] or PlayerDebuffBlacklist[Name])
        else
            return DebuffWhitelist[Id] or DebuffWhitelist[Name]
        end
    end
end


local function EditNameplates(self)
    local r,g,b = unpack(C["General"]["BackdropColor"])
    self:SetBackdrop({})
    self:Height(ClickableHeight)

    local Health = self.Health
    Health:ClearAllPoints()
    Health:Point("TOPLEFT", self, BorderSize, -ClickPadding)
    Health:Point("BOTTOMRIGHT", self, -BorderSize, ClickPadding)

    Health.UpdateColor = UpdateNamePlateColor
    Health.Background:Kill()
    Health:CreateBackdrop()

    local Name = self.Name
    Name:ClearAllPoints()
    Name:Point("BOTTOMLEFT", Health, "TOPLEFT", -2, 0)

    self.Power:Kill()
    self.Power = nil

    local Debuffs = self.Debuffs
    Debuffs:ClearAllPoints()
    Debuffs:Point("BOTTOMLEFT", Health, "TOPLEFT", -BorderSize, 10)
    Debuffs.CustomFilter = FilterDebuffs
    Debuffs.size = T.Scale(AuraWidth)
    Debuffs.spacing = T.Scale(C.General.FrameSpacing)
    Debuffs:Height(AuraHeight)
    Debuffs.PostUpdateIcon = function(self, unit, button) button:SetHeight(AuraHeight) end

    local CastBar = self.Castbar
    CastBar:ClearAllPoints()
    CastBar:Point("TOPLEFT", Health, "BOTTOMLEFT", 0, -BorderSize)
    CastBar:Point("TOPRIGHT", Health, "BOTTOMRIGHT", 0, -BorderSize)

    CastBar.Button:Size(CastIconSize)
    CastBar.Button:ClearAllPoints()
    CastBar.Button:Point("TOPLEFT", Health, "TOPRIGHT", BorderSize, BorderSize)

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
    local ShadowOffset = BorderSize + 4
    Shadow:ClearAllPoints()
    Shadow:Point("TOPLEFT", Health, -ShadowOffset, ShadowOffset)
    CastBar:SetScript("OnShow", function()
        Shadow:Point("BOTTOMRIGHT", CastBar.Button, ShadowOffset, -ShadowOffset)
    end)
    CastBar:SetScript("OnHide", function()
        Shadow:Point("BOTTOMRIGHT", Health, ShadowOffset, -ShadowOffset)
    end)
end

hooksecurefunc(T["UnitFrames"], "Nameplates", EditNameplates)
