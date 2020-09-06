local T, C, L = Tukui:unpack()

local TukuiUF = T.UnitFrames

local FrameSpacing = C.General.FrameSpacing
local BorderSize = C.General.BorderSize

local FrameHeight = TukuiUF.OtherHeight
local PowerHeight = TukuiUF.PowerHeight
local NumBuffs = 3
local NumDebuffs = 5


local function PostUpdateHealth(self, unit, min, max)
    if (not UnitIsConnected(unit) or UnitIsDead(unit) or UnitIsGhost(unit)) then
        if (not UnitIsConnected(unit)) then
            self.Value:SetText("|cffD7BEA5"..FRIENDS_LIST_OFFLINE.."|r")
        elseif (UnitIsDead(unit)) then
            self.Value:SetText("|cffD7BEA5"..DEAD.."|r")
        elseif (UnitIsGhost(unit)) then
            self.Value:SetText("|cffD7BEA5"..L.UnitFrames.Ghost.."|r")
        end
    else
        if (min ~= max) then
            self.Value:SetFormattedText("%s - %s%%", TukuiUF.ShortValue(min), floor(min / max * 100))
        else
            self.Value:SetText(TukuiUF.ShortValue(min))
        end
    end
end


local function UpdateBars(self)
    local NumPowerBars = 0
    if (self.Power.BarShown) then NumPowerBars = 1 end
    if (self.AltPower.BarShown) then NumPowerBars = NumPowerBars + 1 end

    self.Health:Height(FrameHeight - 2*BorderSize - NumPowerBars*(TukuiUF.PowerHeight + BorderSize))
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

    self:SetTemplate()
    self:SetBackdropColor(0, 0, 0)

    -- Health
    Health.Value:ClearAllPoints()
    Health.Value:Point("RIGHT", Health, "RIGHT", -2, 0)

    Health.PostUpdate = PostUpdateHealth

    if C.UnitFrames.DarkTheme then
        Health:SetStatusBarColor(.25, .25, .25)
    else
        Name:SetTextColor(.9, .9, .9)
    end

    -- Name
    Name:ClearAllPoints()
    Name:Point("LEFT", Health, "LEFT", 2, 0)
    if (C.UnitFrames.DarkTheme) then
        self:Tag(Name, "[Tukui:GetNameColor][Tukui:NameShort]")
    else
        self:Tag(Name, "[Tukui:NameShort]")
    end
end


local function EditFocusFocusTargetCommon(self)
    EditOtherFramesCommon(self)

    local Health = self.Health
    Health:ClearAllPoints()
    Health:SetInside(self)

    self.Power:Kill()
    self.Power = nil

    if (C.UnitFrames.FocusAuras) then
        local Buffs = self.Buffs
        local Debuffs = self.Debuffs

        if (Buffs) then
            Buffs:ClearAllPoints()
            Buffs:Point("RIGHT", self, "LEFT", -FrameSpacing, 0)
            Buffs:SetFrameLevel(self:GetFrameLevel())
            Buffs:Height(FrameHeight)
            Buffs:Width(FrameHeight*NumBuffs + FrameSpacing*(NumBuffs-1))
            Buffs.num = NumBuffs
            Buffs.size = T.Scale(FrameHeight)
            Buffs.spacing = T.Scale(FrameSpacing)
        end

        if (Debuffs) then
            Debuffs:ClearAllPoints()
            Debuffs:Point("LEFT", self, "RIGHT", FrameSpacing, 0)
            Debuffs:SetFrameLevel(self:GetFrameLevel())
            Debuffs:Height(FrameHeight)
            Debuffs:Width(FrameHeight*NumDebuffs + FrameSpacing*(NumDebuffs-1))
            Debuffs.num = NumDebuffs
            Debuffs.size = T.Scale(FrameHeight)
            Debuffs.spacing = T.Scale(FrameSpacing)
        end
    end
end


local function EditFocus(self)
    EditFocusFocusTargetCommon(self)

    if (C.UnitFrames.CastBar) then
        local CastBar = self.Castbar

        CastBar:SetBackdrop({})
        CastBar:CreateBackdrop()
        CastBar:ClearAllPoints()
        CastBar:Height(20)
        CastBar:Point("TOPLEFT", self, "BOTTOMLEFT", BorderSize, -3)
        CastBar:Point("TOPRIGHT", self, "BOTTOMRIGHT", -BorderSize, -3)

        CastBar.Time:ClearAllPoints()
        CastBar.Time:Point("RIGHT", CastBar, "RIGHT", -2, 0)

        CastBar.Text:ClearAllPoints()
        CastBar.Text:SetWidth(150)
        CastBar.Text:Point("LEFT", CastBar, "LEFT", 2, 0)

        CastBar.Button:Kill()
        CastBar.Icon:Kill()
    end
end


local function EditFocusTarget(self)
    EditFocusFocusTargetCommon(self)

    local CastBar = self.Castbar

    CastBar:Kill()
    self.Castbar = nil
end


local function EditArenaBossCommon(self)
    EditOtherFramesCommon(self)

    local Health = self.Health
    local Power = self.Power

    Health:ClearAllPoints()
    Health:Point("TOPLEFT", self, BorderSize, -BorderSize)
    Health:Point("TOPRIGHT", self, -BorderSize, -BorderSize)
    Health:Height(FrameHeight - PowerHeight - 3*BorderSize)

    -- Power
    Power:ClearAllPoints()
    Power:Height(PowerHeight)
    Power:Point("BOTTOMLEFT", self, BorderSize, BorderSize)
    Power:Point("BOTTOMRIGHT", self, -BorderSize, BorderSize)
    Power:SetFrameLevel(Health:GetFrameLevel() + 2)

    Power.Value:Kill()
    Power.Value = nil
    Power.PostUpdate = nil

    local OverlayFrame = CreateFrame("Frame", nil, self)
    OverlayFrame:SetAllPoints()
    OverlayFrame:SetFrameLevel(Health:GetFrameLevel() + 3)

    self.Name:SetParent(OverlayFrame)
    Health.Value:SetParent(OverlayFrame)

    if (C.UnitFrames.CastBar) then
        local CastBar = self.Castbar

        CastBar:ClearAllPoints()
        CastBar:Height(20)
        CastBar:Point("TOPLEFT", self, "BOTTOMLEFT", 0, -(FrameSpacing + BorderSize))
        CastBar:Point("TOPRIGHT", self, "BOTTOMRIGHT", 0, -(FrameSpacing + BorderSize))
        CastBar:SetBackdrop({})
        CastBar:CreateBackdrop()

        CastBar.Time:ClearAllPoints()
        CastBar.Time:Point("RIGHT", CastBar, "RIGHT", -2, 0)

        CastBar.Text:ClearAllPoints()
        CastBar.Text:SetWidth(TukuiUF.OtherWidth - 50)
        CastBar.Text:Point("LEFT", CastBar, "LEFT", 2, 0)

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
        Debuffs:Point("LEFT", self, "RIGHT", FrameSpacing, 0)
        Debuffs:SetFrameLevel(self:GetFrameLevel())
        Debuffs:Height(FrameHeight)
        Debuffs:Width(FrameHeight*NumDebuffs + FrameSpacing*(NumDebuffs-1))
        Debuffs.num = NumDebuffs
        Debuffs.size = T.Scale(FrameHeight)
        Debuffs.spacing = T.Scale(FrameSpacing)
    end

    SpecIcon:ClearAllPoints()
    SpecIcon:Size(FrameHeight - 2*BorderSize)
    SpecIcon:Point("RIGHT", self, "LEFT", -(1 + BorderSize), 0)

    Trinket:ClearAllPoints()
    Trinket:Size(FrameHeight - 2*BorderSize)
    Trinket:Point("RIGHT", self, "LEFT", -(FrameHeight + 1), 0)
end


local function EditBoss(self)
    EditArenaBossCommon(self)

    self.Power.PostUpdate = PostUpdatePower
    self.AlternativePower.PostUpdate = BossPostUpdateAltPower

    if (C.UnitFrames.BossAuras) then
        local Buffs = self.Buffs
        local Debuffs = self.Debuffs

        Buffs:ClearAllPoints()
        Buffs:Point("RIGHT", self, "LEFT", -FrameSpacing, 0)
        Buffs:SetFrameLevel(self:GetFrameLevel())
        Buffs:Height(FrameHeight)
        Buffs:Width(FrameHeight*NumBuffs + FrameSpacing*(NumBuffs-1))
        Buffs.num = NumBuffs
        Buffs.size = T.Scale(FrameHeight)
        Buffs.spacing = T.Scale(FrameSpacing)

        Debuffs:ClearAllPoints()
        Debuffs:Point("LEFT", self, "RIGHT", FrameSpacing, 0)
        Debuffs:SetFrameLevel(self:GetFrameLevel())
        Debuffs:Height(FrameHeight)
        Debuffs:Width(FrameHeight*NumDebuffs + FrameSpacing*(NumDebuffs-1))
        Debuffs.num = NumDebuffs
        Debuffs.size = T.Scale(FrameHeight)
        Debuffs.spacing = T.Scale(FrameSpacing)
    end
end


hooksecurefunc(TukuiUF, "Focus", EditFocus)
hooksecurefunc(TukuiUF, "FocusTarget", EditFocusTarget)
hooksecurefunc(TukuiUF, "Arena", EditArena)
hooksecurefunc(TukuiUF, "Boss", EditBoss)
