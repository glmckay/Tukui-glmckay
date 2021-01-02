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

local BorderSize = C.General.BorderSize
local FrameSpacing = C.General.FrameSpacing

local FrameWidth = TukuiUF.PlayerTargetWidth
local FrameHeight = TukuiUF.FrameHeight
local CenterBarWidth = T.Panels.CenterPanelWidth - 2*BorderSize
local CastBarHeight = 25
local NumAuras = 24


local function EnemyDebuffFilter(element, unit, button, ...)
    local Caster, CasterIsPlayer = select(7, ...), select(13, ...)
    return Caster == 'player' or not CasterIsPlayer
end


local function UpdateBars(self)
    local NumPowerBars = 0
    if (self.Power.BarShown) then NumPowerBars = 1 end
    -- if (self.AlternativePower.BarShown) then NumPowerBars = NumPowerBars + 1 end

    self.Health:SetHeight(FrameHeight - 2*BorderSize - NumPowerBars*(TukuiUF.PowerHeight + BorderSize))
end


local function PostUpdatePower(self, unit, cur, min, max)
    local pType, pToken = UnitPowerType(unit)
    local IsPlayer = UnitIsPlayer(unit)
    local Class = UnitClass(unit)
    -- if ((pType == 0 and IsPlayer and not (Class == "Warlock" or Class == "Mage")) or
    if ((pType == 0) or (not IsPlayer and cur > 0)) then
        if (self.BarShown ~= true) then
            self:SetAlpha(1)
            self.BarShown = true
            UpdateBars(self:GetParent())
        end

        if ((pType == 0 or cur == 0) or
            not UnitIsConnected(unit) or
            UnitIsDead(unit) or
            UnitIsGhost(unit)) then
            self.Value:SetText()
        else
            self.Value:SetText(cur)
        end
    else
        if (self.BarShown ~= false) then
            -- self:GetParent().Health:SetHeight(FrameHeight - 2*BorderSize)
            self:SetAlpha(0)
            self.BarShown = false
            self.Value:SetText()
            UpdateBars(self:GetParent())
        end
    end
end


local function PostUpdateAltPower(self, unit, cur, min, max)
    if (not cur) or (not max) then return end

    if (min ~= cur) then
        if (self.BarShown == false) then
            self:SetAlpha(1)
            self.BarShown = true
            UpdateBars(self:GetParent())
        end
    else
        if (self.BarShown == true) then
            self:SetAlpha(0)
            self.BarShown = false
            UpdateBars(self:GetParent())
        end
    end
end


local function EditTarget(self)

    local Health = self.Health
    local Power = self.Power
    local AltPower = self.AlternativePower
    local CastBar = self.Castbar
    local OverlayFrame = self.OverlayFrame

    -- Frame to overlay text above heal prediction
    local OverlayFrame = CreateFrame("Frame", nil, self)
    OverlayFrame:SetAllPoints()
    OverlayFrame:SetFrameLevel(Health:GetFrameLevel() + 3)
    self.OverlayFrame = OverlayFrame

    -- Health
    Health:ClearAllPoints()
    Health:SetPoint("TOPLEFT", self, BorderSize, -BorderSize)
    Health:SetPoint("TOPRIGHT", self, -BorderSize, -BorderSize)
    Health:SetHeight(FrameHeight - 2*BorderSize)

    Health.Background:Kill()
    Health.bg = nil

    Health.Value:SetParent(OverlayFrame)
    Health.Value:SetFontObject(NumberFont)
    Health.Value:ClearAllPoints()
    Health.Value:SetPoint("LEFT", Health, "LEFT", 2, 0)

    Health.Percent = OverlayFrame:CreateFontString(nil, "OVERLAY")
    Health.Percent:SetFontObject(BigNumberFont)
    Health.Percent:SetPoint("RIGHT", Health, "TOPRIGHT", -2, 0)

    Health.PostUpdate = TukuiUF.PlayerTargetPostUpdateHealth

    -- Power
    Power:ClearAllPoints()
    Power:SetHeight(TukuiUF.PowerHeight)
    Power:SetPoint("BOTTOMLEFT", self, BorderSize, BorderSize)
    Power:SetPoint("BOTTOMRIGHT", self, -BorderSize, BorderSize)
    Power:SetFrameLevel(Health:GetFrameLevel() + 2)

    Power.Value = OverlayFrame:CreateFontString(nil, "OVERLAY")
    Power.Value:SetFontObject(NumberFont)
    Power.Value:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -2, 1)
    Power.PostUpdate = PostUpdatePower

    -- Alt Power Bar
    -- AltPower:ClearAllPoints()
    -- AltPower:SetHeight(TukuiUF.PowerHeight)
    -- AltPower:SetPoint("TOPLEFT", Health, "BOTTOMLEFT", 0, -BorderSize)
    -- AltPower:SetPoint("TOPRIGHT", Health, "BOTTOMRIGHT", 0, -BorderSize)

    -- AltPower.PostUpdate = PostUpdateAltPower

    -- Castbar
    CastBar:SetParent(UIParent)
    CastBar:CreateBackdrop()
    CastBar.Backdrop:SetOutside()
    CastBar.Background:Kill()
    CastBar.bg = nil

    CastBar:SetSize(CenterBarWidth + (CenterBarWidth % 2), CastBarHeight)
    CastBar:ClearAllPoints()
    if (C.UnitFrames.UnlinkCastBar) then
        CastBar:SetPoint("BOTTOM", UIParent, "CENTER", 0, 340)
    else
        CastBar:SetPoint("TOP", self, "BOTTOM", 0, -FrameSpacing)
    end

    CastBar.Time:SetFontObject(NumberFont)
    CastBar.Time:ClearAllPoints()
    CastBar.Time:SetPoint("RIGHT", CastBar, "RIGHT", -2, 0)

    CastBar.Text:SetFontObject(NumberFont)
    CastBar.Text:ClearAllPoints()
    CastBar.Text:SetWidth(FrameWidth - 80)
    CastBar.Text:SetHeight(CastBar:GetHeight())
    CastBar.Text:SetPoint("LEFT", CastBar, "LEFT", 2, 0)

    if C.UnitFrames.CastBarIcon then
        CastBar.Icon:ClearAllPoints()
        CastBar.Icon:SetSize(36, 36)
        CastBar.Icon:SetPoint("BOTTOM", CastBar, "TOP", 0, 10)
    end

    if (C.UnitFrames.HealBar) then
        local HealthPrediction = self.HealthPrediction

        for name,bar in pairs(HealthPrediction) do
            if (name ~= 'maxOverflow') then
                bar:SetWidth(FrameWidth - 2*BorderSize)
            end
        end
    end

    -- Create new Name since we killed the panel
    local Name = OverlayFrame:CreateFontString(nil, "OVERLAY")
    Name:SetPoint("BOTTOMRIGHT", Health, "TOPRIGHT", -2, 0)
    Name:SetJustifyH("RIGHT")
    Name:SetFontObject(NameFont)

    if (C.UnitFrames.DarkTheme) then
        self:Tag(Name, "[Tukui:GetNameColor][Tukui:NameLong]")
    else
        self:Tag(Name, "[Tukui:NameLong]")
    end
    self.Name = Name

    -- Auras
    if (C.UnitFrames.TargetBuffs) then
        local Buffs = self.Buffs
        local Debuffs = self.Debuffs

        Buffs:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 15)
        Buffs:SetFrameLevel(self:GetFrameLevel())
        Buffs:SetHeight(TukuiUF.TargetAuraSize)
        Buffs:SetWidth(FrameWidth)
        Buffs.size = TukuiUF.TargetAuraSize
        Buffs.num = NumAuras
        Buffs.numRow = TukuiUF.TargetAurasPerRow
        Buffs.spacing = FrameSpacing
    end

    if (C.UnitFrames.TargetDebuffs) then
        local Debuffs = self.Debuffs

        Debuffs:SetPoint("BOTTOMLEFT", buffs, "TOPLEFT", 0, 1) -- until  UpdateDebuffsHeaderPosition changes it
        Debuffs:SetFrameLevel(self:GetFrameLevel())
        Debuffs:SetHeight(TukuiUF.TargetAuraSize)
        Debuffs:SetWidth(FrameWidth)
        Debuffs.size = TukuiUF.TargetAuraSize
        Debuffs.num = NumAuras
        Debuffs.numRow = TukuiUF.TargetAurasPerRow
        Debuffs.Spacing = FrameSpacing

        -- Toggle debuff filtering based on unit
        self.PreUpdate = function(self)
            if (UnitIsPlayer('target') or not UnitIsEnemy("player", "target")) then
                Debuffs.CustomFilter = nil
            else
                Debuffs.CustomFilter = EnemyDebuffFilter
            end
        end
    end
end

hooksecurefunc(TukuiUF, "Target", EditTarget)
