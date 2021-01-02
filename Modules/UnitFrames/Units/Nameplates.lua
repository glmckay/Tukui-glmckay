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

local FilterBuffs = nil
local BuffWhitelist = C["NamePlates"].BuffWhitelist

if next(BuffWhitelist) ~= nil then
    FilterBuffs = function(self, unit, button, ...)
        local Name, Caster, Id = select(1, ...), select(7, ...), select(10, ...)
        return BuffWhitelist[Id] or BuffWhitelist[Name]
    end
end

local function ScaleTarget(self)

    local baseScale = T.Toolkit.Settings.UIScale

    if UnitIsUnit("target", self.unit) then
        -- self:SetScale(1.5 * baseScale)
        self:SetSize(math.floor(1.2 * C.NamePlates.Width), ClickableHeight + math.floor(0.5 * C.NamePlates.Height))
    else
        -- self:SetScale(baseScale)
        self:SetSize(C.NamePlates.Width, ClickableHeight)
    end

    T.UnitFrames.Highlight(self)
end

local function EditNameplates(self)
    local r,g,b = unpack(C["General"]["BackdropColor"])
    self.Backdrop:SetBackdrop({})
    self:SetHeight(ClickableHeight)

    local Health = self.Health
    Health:ClearAllPoints()
    Health:SetPoint("TOPLEFT", self, BorderSize, -ClickPadding)
    Health:SetPoint("BOTTOMRIGHT", self, -BorderSize, ClickPadding)

    Health.UpdateColor = UpdateNamePlateColor
    Health.Background:Kill()
    Health:CreateBackdrop()
    Health.Backdrop:SetPoint("TOPLEFT", Health, "TOPLEFT", T.Toolkit.Functions.Scale(-1), T.Toolkit.Functions.Scale(1))
    Health.Backdrop:SetPoint("BOTTOMRIGHT", Health, "BOTTOMRIGHT", T.Toolkit.Functions.Scale(1), T.Toolkit.Functions.Scale(-1))

    local Name = self.Name
    Name:ClearAllPoints()
    Name:SetPoint("BOTTOMLEFT", Health, "TOPLEFT", -2, 0)
	-- Name:SetFont(select(1, Name:GetFont()), 11, select(3, Name:GetFont()))

    self.Power:Kill()
    self.Power = nil

    local Buffs = self.Buffs
    local BuffSize = Health:GetHeight()*4
    Buffs:SetHeight(BuffSize)
    Buffs:SetWidth(BuffSize*3 + 4)
    Buffs.size = BuffSize
    Buffs.CustomFilter = FilterBuffs

    local Debuffs = self.Debuffs
    Debuffs:ClearAllPoints()
    Debuffs:SetPoint("BOTTOMLEFT", Health, "TOPLEFT", -BorderSize, 10)
    Debuffs.CustomFilter = FilterDebuffs
    Debuffs.size = AuraWidth
    Debuffs.spacing = C.General.FrameSpacing
    Debuffs:SetHeight(AuraHeight)
    Debuffs.PostUpdateIcon = function(self, unit, button) button:SetHeight(AuraHeight) end

    local CastBar = self.Castbar
    CastBar:SetHeight(C.NamePlates.CastHeight)
    CastBar:ClearAllPoints()
    CastBar:SetPoint("TOPLEFT", Health, "BOTTOMLEFT", 0, -BorderSize)
    CastBar:SetPoint("TOPRIGHT", Health, "BOTTOMRIGHT", 0, -BorderSize)

    CastBar.Button:SetSize(CastIconSize, CastIconSize)
    CastBar.Button:ClearAllPoints()
    CastBar.Button:SetPoint("TOPLEFT", Health, "TOPRIGHT", BorderSize, BorderSize)

    CastBar.Background:Kill()
    CastBar:CreateBackdrop()
    CastBar.Backdrop:SetPoint("TOPLEFT", CastBar, "TOPLEFT", T.Toolkit.Functions.Scale(-1), T.Toolkit.Functions.Scale(1))
    CastBar.Backdrop:SetPoint("BOTTOMRIGHT", CastBar, "BOTTOMRIGHT", T.Toolkit.Functions.Scale(1), T.Toolkit.Functions.Scale(-1))

    local Text = CastBar:CreateFontString(nil, "OVERLAY")
    -- Text:SetPoint("TOPLEFT", CastBar, "BOTTOMLEFT", -2, -2)
    Text:SetPoint("LEFT", CastBar, "LEFT", 2, 0)
    Text:SetJustifyH("LEFT")
    Text:SetFontObject(Font)
    Text:SetFont(C["Medias"].ThinFont, 12, "OUTLINE")
    Text:SetTextColor(.9,.9,.9)
    CastBar.Text = Text

    local Highlight = self.Highlight
    local HighlightOffset = BorderSize + C.NamePlates.HighlightSize
    Highlight:ClearAllPoints()
    Highlight:SetPoint("TOPLEFT", Health, -HighlightOffset, HighlightOffset)
    CastBar:SetScript("OnShow", function()
        Highlight:SetPoint("BOTTOMRIGHT", CastBar.Button, HighlightOffset, -HighlightOffset)
    end)
    CastBar:SetScript("OnHide", function()
        Highlight:SetPoint("BOTTOMRIGHT", Health, HighlightOffset, -HighlightOffset)
    end)

    -- self.Highlight:Kill()

	self:RegisterEvent("PLAYER_TARGET_CHANGED", ScaleTarget, true)
	self:RegisterEvent("NAME_PLATE_UNIT_ADDED", ScaleTarget, true)
	self:RegisterEvent("NAME_PLATE_UNIT_REMOVED", ScaleTarget, true)
end

hooksecurefunc(T["UnitFrames"], "Nameplates", EditNameplates)
