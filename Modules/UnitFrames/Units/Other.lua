local T, C, L = Tukui:unpack()

local TukuiUF = T.UnitFrames

local FrameSpacing = C.General.FrameSpacing
local BorderSize = C.General.BorderSize

local FrameHeight = TukuiUF.OtherHeight
local PowerHeight = TukuiUF.PowerHeight
local NumBuffs = 3
local NumDebuffs = 5


local function UpdateBars(self)
    local NumPowerBars = 0
    if (self.Power.BarShown) then NumPowerBars = 1 end
    if (self.AltPower.BarShown) then NumPowerBars = NumPowerBars + 1 end

    self.Health:SetHeight(FrameHeight - 2*BorderSize - NumPowerBars*(TukuiUF.PowerHeight + BorderSize))
end


local function BossPostUpdatePower(self, unit, min, max)
    if (min > 0) then
        if (self.LastAlpha ~= 1) then
            self:SetAlpha(1)
            self.LastAlpha = 1
            UpdateBars(self:GetParent())
        end
    else
        if (self.LastAlpha ~= 0) then
            self:SetAlpha(0)
            self.LastAlpha = 0
            UpdateBars(self:GetParent())
        end
    end
end


local function BossPostUpdateAltPower(self, min, cur, max)
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


local function EditOtherFramesCommon(self)
    local Health = self.Health
    local Power = self.Power
    local Name = self.Name

    self.Backdrop = nil
    self:CreateBackdrop()
    -- self:SetTemplate()
    -- self.Backdrop:SetBackdropColor(0, 0, 0)

    -- Health
    if not Health.Value then
        Health.Value = Health:CreateFontString(nil, "OVERLAY")
        Health.Value:SetFontObject(T.GetFont(C["UnitFrames"].Font))
    else
        Health.Value:ClearAllPoints()
    end
    Health.Value:SetPoint("RIGHT", Health, "RIGHT", -2, 0)

    if C.UnitFrames.DarkTheme then
        Health:SetStatusBarColor(.25, .25, .25)
    else
        Name:SetTextColor(.9, .9, .9)
    end

    -- Name
    Name:ClearAllPoints()
    Name:SetPoint("LEFT", Health, "LEFT", 2, 0)
    if (C.UnitFrames.DarkTheme) then
        self:Tag(Name, "[Tukui:GetNameColor][Tukui:NameShort]")
    else
        self:Tag(Name, "[Tukui:NameShort]")
    end
end


local function EditFocusFocusTargetCommon(self)
    EditOtherFramesCommon(self)

    self.Health:SetAllPoints()

    self.Power:Kill()
    self.Power = nil

    if (C.UnitFrames.FocusAuras) then
        local Buffs = self.Buffs
        local Debuffs = self.Debuffs
        local BuffSize = FrameHeight + 2*BorderSize

        if (Buffs) then
            Buffs:ClearAllPoints()
            Buffs:SetPoint("RIGHT", self, "LEFT", -(BorderSize + FrameSpacing), 0)
            Buffs:SetFrameLevel(self:GetFrameLevel())
            Buffs:SetHeight(BuffSize)
            Buffs:SetWidth(BuffSize*NumBuffs + FrameSpacing*(NumBuffs-1))
            Buffs.initialAnchor = "TOPRIGHT"
            Buffs["growth-x"] = "LEFT"
            Buffs.num = NumBuffs
            Buffs.size = BuffSize
            Buffs.spacing = FrameSpacing
        end

        if (Debuffs) then
            Debuffs:ClearAllPoints()
            Debuffs:SetPoint("LEFT", self, "RIGHT", BorderSize + FrameSpacing, 0)
            Debuffs:SetFrameLevel(self:GetFrameLevel())
            Debuffs:SetHeight(BuffSize)
            Debuffs:SetWidth(BuffSize*NumDebuffs + FrameSpacing*(NumDebuffs-1))
            Debuffs.initialAnchor = "TOPLEFT"
            Debuffs["growth-x"] = "RIGHT"
            Debuffs.num = NumDebuffs
            Debuffs.size = BuffSize
            Debuffs.spacing = FrameSpacing
        end
    end
end


local function EditFocus(self)
    EditFocusFocusTargetCommon(self)

    if (C.UnitFrames.CastBar) then
        local CastBar = self.Castbar

        CastBar.Backdrop:SetBackdrop({})
        CastBar:CreateBackdrop()
        CastBar:ClearAllPoints()
        CastBar:SetHeight(20)
        CastBar:SetPoint("TOPLEFT", self, "BOTTOMLEFT", BorderSize, -3)
        CastBar:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", -BorderSize, -3)

        -- CastBar.Time:ClearAllPoints()
        -- CastBar.Time:SetPoint("RIGHT", CastBar, "RIGHT", -2, 0)

        CastBar.Text:ClearAllPoints()
        CastBar.Text:SetWidth(150)
        CastBar.Text:SetPoint("LEFT", CastBar, "LEFT", 2, 0)

        CastBar.Button:Kill()
        CastBar.Icon:Kill()
    end
end


local function EditFocusTarget(self)
    EditFocusFocusTargetCommon(self)
end


local function EditArenaBossCommon(self)
    EditOtherFramesCommon(self)

    local Health = self.Health
    local Power = self.Power

    Health:ClearAllPoints()
    Health:SetPoint("TOPLEFT", self, BorderSize, -BorderSize)
    Health:SetPoint("TOPRIGHT", self, -BorderSize, -BorderSize)
    Health:SetHeight(FrameHeight - PowerHeight - 3*BorderSize)

    -- Power
    Power:ClearAllPoints()
    Power:SetHeight(PowerHeight)
    Power:SetPoint("BOTTOMLEFT", self, BorderSize, BorderSize)
    Power:SetPoint("BOTTOMRIGHT", self, -BorderSize, BorderSize)
    Power:SetFrameLevel(Health:GetFrameLevel() + 2)

    local OverlayFrame = CreateFrame("Frame", nil, self)
    OverlayFrame:SetAllPoints()
    OverlayFrame:SetFrameLevel(Health:GetFrameLevel() + 3)

    self.Name:SetParent(OverlayFrame)
    Health.Value:SetParent(OverlayFrame)

    if (C.UnitFrames.CastBar) then
        local CastBar = self.Castbar

        CastBar:ClearAllPoints()
        CastBar:SetHeight(20)
        CastBar:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -(FrameSpacing + BorderSize))
        CastBar:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, -(FrameSpacing + BorderSize))
        CastBar.Backdrop = nil
        CastBar:CreateBackdrop()

        -- CastBar.Time:ClearAllPoints()
        -- CastBar.Time:SetPoint("RIGHT", CastBar, "RIGHT", -2, 0)

        CastBar.Text:ClearAllPoints()
        CastBar.Text:SetWidth(TukuiUF.OtherWidth - 50)
        CastBar.Text:SetPoint("LEFT", CastBar, "LEFT", 2, 0)

        CastBar.Button:Kill()
        CastBar.Icon:Kill()
    end
end


local function EditArena(self)
    EditArenaBossCommon(self)

    local SpecIcon = self.PVPSpecIcon
    local Trinket = self.Trinket

    if (C.UnitFrames.ArenaAuras) then
        local Debuffs = self.Debuffs

        Debuffs:ClearAllPoints()
        Debuffs:SetPoint("LEFT", self, "RIGHT", FrameSpacing, 0)
        Debuffs:SetFrameLevel(self:GetFrameLevel())
        Debuffs:SetHeight(FrameHeight)
        Debuffs:SetWidth(FrameHeight*NumDebuffs + FrameSpacing*(NumDebuffs-1))
        Debuffs.num = NumDebuffs
        Debuffs.size = FrameHeight
        Debuffs.spacing = FrameSpacing
    end

    -- SpecIcon:ClearAllPoints()
    -- SpecIcon:SetSize(FrameHeight - 2*BorderSize, FrameHeight - 2*BorderSize)
    -- SpecIcon:SetPoint("RIGHT", self, "LEFT", -(1 + BorderSize), 0)

    -- Trinket:ClearAllPoints()
    -- Trinket:SetSize(FrameHeight - 2*BorderSize, FrameHeight - 2*BorderSize)
    -- Trinket:SetPoint("RIGHT", self, "LEFT", -(FrameHeight + 1), 0)
end


local function EditBoss(self)
    EditArenaBossCommon(self)

    self.Power.PostUpdate = PostUpdatePower
    -- self.AlternativePower.PostUpdate = BossPostUpdateAltPower

    if (C.UnitFrames.BossAuras) then
        local Buffs = self.Buffs
        local Debuffs = self.Debuffs

        Buffs:ClearAllPoints()
        Buffs:SetPoint("RIGHT", self, "LEFT", -FrameSpacing, 0)
        Buffs:SetFrameLevel(self:GetFrameLevel())
        Buffs:SetHeight(FrameHeight)
        Buffs:SetWidth(FrameHeight*NumBuffs + FrameSpacing*(NumBuffs-1))
        Buffs.num = NumBuffs
        Buffs.size = FrameHeight
        Buffs.spacing = FrameSpacing

        Debuffs:ClearAllPoints()
        Debuffs:SetPoint("LEFT", self, "RIGHT", FrameSpacing, 0)
        Debuffs:SetFrameLevel(self:GetFrameLevel())
        Debuffs:SetHeight(FrameHeight)
        Debuffs:SetWidth(FrameHeight*NumDebuffs + FrameSpacing*(NumDebuffs-1))
        Debuffs.num = NumDebuffs
        Debuffs.size = FrameHeight
        Debuffs.spacing = FrameSpacing
    end
end


hooksecurefunc(TukuiUF, "Focus", EditFocus)
hooksecurefunc(TukuiUF, "FocusTarget", EditFocusTarget)
hooksecurefunc(TukuiUF, "Arena", EditArena)
hooksecurefunc(TukuiUF, "Boss", EditBoss)
