local T, C, L = Tukui:unpack()

local TukuiUF = T["UnitFrames"]
local Noop = function() end

-- Localised globals
local UnitPowerType = UnitPowerType
local UnitIsPlayer = UnitIsPlayer
local UnitClass = UnitClass
local UnitIsConnected = UnitIsConnected
local UnitIsDead = UnitIsDead
local UnitIsGhost = UnitIsGhost

local BigNumberFont = T.GetFont(C["UnitFrames"].BigNumberFont)
local NumberFont = T.GetFont(C["UnitFrames"].NumberFont)
local NameFont = T.GetFont(C["UnitFrames"].Font)
local FontOffset = C["Medias"].FontOffset

local BorderSize = C.General.BorderSize
local FrameSpacing = C.General.FrameSpacing

local FrameWidth = TukuiUF.PlayerTargetWidth
local FrameHeight = TukuiUF.FrameHeight
local CenterBarWidth = T.Panels.CenterPanelWidth - 2*BorderSize
local CastBarHeight = 25
local NumAuras = 24


local function TargetPostUpdatePower(self, unit, min, max)
    local pType, pToken = UnitPowerType(unit)
    local IsPlayer = UnitIsPlayer(unit)
    local Class = UnitClass(unit)
    if ((pType == 0 and IsPlayer and not (Class == "Warlock" or Class == "Mage")) or
        (pType ~= 0 and not IsPlayer and min > 0)) then
        if (self.LastAlpha ~= 1) then
            self:GetParent().Health:Height(FrameHeight - TukuiUF.PowerHeight - 3*BorderSize)
            self:SetAlpha(1)
            self.LastAlpha = 1
        end

        if ((pType == 0 or min == 0) or not UnitIsConnected(unit) or UnitIsDead(unit) or UnitIsGhost(unit)) then
            self.Value:SetText()
        else
            self.Value:SetText(min)
        end
    else
        if (self.LastAlpha ~= 0) then
            self:GetParent().Health:Height(FrameHeight - 2*BorderSize)
            self:SetAlpha(0)
            self.LastAlpha = 0
            self.Value:SetText()
        end
    end
end



local function EditTarget(self)
    self.Panel:Kill()
    self:SetTemplate()

    local Health = self.Health
    local Power = self.Power
    local CastBar = self.Castbar
    local OverlayFrame = self.OverlayFrame

    -- Frame to overlay text above heal prediction
    local OverlayFrame = CreateFrame("Frame", nil, self)
    OverlayFrame:SetAllPoints()
    OverlayFrame:SetFrameLevel(Health:GetFrameLevel() + 3)
    self.OverlayFrame = OverlayFrame

    -- Health
    Health:ClearAllPoints()
    Health:Point("TOPLEFT", self, BorderSize, -BorderSize)
    Health:Point("TOPRIGHT", self, -BorderSize, -BorderSize)
    Health:Height(FrameHeight - 2*BorderSize)

    Health.Background:Kill()

    Health.Value:SetParent(OverlayFrame)
    Health.Value:SetFontObject(NumberFont)
    Health.Value:ClearAllPoints()
    Health.Value:Point("LEFT", Health, "LEFT", 2, FontOffset)

    Health.Percent = OverlayFrame:CreateFontString(nil, "OVERLAY")
    Health.Percent:SetFontObject(BigNumberFont)
    Health.Percent:Point("RIGHT", Health, "TOPRIGHT", -2, FontOffset)

    Health.PostUpdate = TukuiUF.PlayerTargetPostUpdateHealth

    -- Power
    Power:ClearAllPoints()
    Power:Height(TukuiUF.PowerHeight)
    Power:Point("BOTTOMLEFT", self, BorderSize, BorderSize)
    Power:Point("BOTTOMRIGHT", self, -BorderSize, BorderSize)

    Power.Background:Kill()

    Power.Value:SetParent(OverlayFrame)
    Power.Value:SetFontObject(NumberFont)
    Power.Value:ClearAllPoints()
    Power.Value:Point("BOTTOMRIGHT", self, "BOTTOMRIGHT", -2, FontOffset)

    Power.PostUpdate = TargetPostUpdatePower

    -- Castbar
    CastBar:SetBackdrop({})
    CastBar:CreateBackdrop()
    CastBar.Background:Kill()

    CastBar:Size(CenterBarWidth, CastBarHeight)
    CastBar:ClearAllPoints()
    if (C.UnitFrames.UnlinkCastBar) then
        CastBar:Point("BOTTOM", UIParent, "CENTER", 0, 340)
    else
        CastBar:Point("TOP", self, "BOTTOM", 0, -FrameSpacing)
    end

    CastBar.Time:SetFontObject(NumberFont)
    CastBar.Time:ClearAllPoints()
    CastBar.Time:Point("RIGHT", CastBar, "RIGHT", -2, FontOffset)

    CastBar.Text:SetFontObject(NumberFont)
    CastBar.Text:ClearAllPoints()
    CastBar.Text:SetWidth(T.Scale(FrameWidth - 80))
    CastBar.Text:SetHeight(CastBar:GetHeight())
    CastBar.Text:Point("LEFT", CastBar, "LEFT", 2, FontOffset)

    if C.UnitFrames.CastBarIcon then
        CastBar.Icon:ClearAllPoints()
        CastBar.Icon:Size(36)
        CastBar.Icon:Point("BOTTOM", CastBar, "TOP", 0, 10)
    end

    if (C.UnitFrames.HealBar) then
        local HealthPrediction = self.HealthPrediction

        for name,bar in pairs(HealthPrediction) do
            if (name ~= 'maxOverflow') then
                bar:Width(FrameWidth - 2*BorderSize)
            end
        end
    end

    -- Create new Name since we killed the panel
    local Name = OverlayFrame:CreateFontString(nil, "OVERLAY")
    Name:Point("BOTTOMLEFT", Health, "TOPLEFT", -2, FontOffset - 1)
    Name:SetJustifyH("LEFT")
    Name:SetFontObject(NameFont)

    if (C.UnitFrames.DarkTheme) then
        self:Tag(Name, "[Tukui:GetNameColor][Tukui:NameLong]")
    else
        self:Tag(Name, "[Tukui:NameLong]")
    end
    self.Name = Name

    -- Auras
    if (C.UnitFrames.TargetAuras) then
        local Buffs = self.Buffs
        local Debuffs = self.Debuffs

        Buffs:Point("BOTTOMLEFT", self, "TOPLEFT", 0, 15)
        Buffs:SetFrameLevel(self:GetFrameLevel())
        Buffs:Height(TukuiUF.TargetAuraSize)
        Buffs:Width(FrameWidth)
        Buffs.size = T.Scale(TukuiUF.TargetAuraSize)
        Buffs.num = NumAuras
        Buffs.numRow = TukuiUF.TargetAurasPerRow
        Buffs.spacing = T.Scale(FrameSpacing)


        Debuffs:Point("BOTTOMLEFT", buffs, "TOPLEFT", 0, 1) -- until  UpdateDebuffsHeaderPosition changes it
        Debuffs:SetFrameLevel(self:GetFrameLevel())
        Debuffs:Height(TukuiUF.TargetAuraSize)
        Debuffs:Width(FrameWidth)
        Debuffs.size = T.Scale(TukuiUF.TargetAuraSize)
        Debuffs.num = NumAuras
        Debuffs.numRow = TukuiUF.TargetAurasPerRow
        Debuffs.Spacing = T.Scale(FrameSpacing)
    end
end

hooksecurefunc(TukuiUF, "Target", EditTarget)
