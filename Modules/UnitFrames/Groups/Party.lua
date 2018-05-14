local T, C, L = Tukui:unpack()

-- I hijack these to make dps/tank raid frames

local UnitFrames = T.UnitFrames

local ufFont = T.GetFont(C["Raid"].Font)
local borderSize = C["General"].BorderSize
local ufSpacing = C["General"].FrameSpacing

local powerHeight = 3

UnitFrames.ListMinWidth = T.Scale(95)
UnitFrames.ListMinHeight = T.Scale(17)
UnitFrames.ListWidthIncr = T.Scale(6)
UnitFrames.ListHeightIncr = T.Scale(3)


local partyWidth = UnitFrames.ListMinWidth + 7*UnitFrames.ListWidthIncr
local partyHeight = UnitFrames.ListMinHeight + 7*UnitFrames.ListHeightIncr


local function RaidDebuffsShow(self)
    local Parent = self:GetParent()
    local Name = Parent.Name
    Name:ClearAllPoints()
    Name:Point("LEFT", self, "RIGHT", 5, 0)
end

local function RaidDebuffsHide(self)
    local Parent = self:GetParent()
    local Name = Parent.Name
    Name:ClearAllPoints()
    Name:Point("LEFT", Parent, "RIGHT", 5, 0)
end


local function UpdateFrameForSize(self, w, h, isParty)
    local innerHeight = h - 2*T.Scale(borderSize)

    if (isParty) then
        self.Health:SetHeight(innerHeight - powerHeight - borderSize)
        self.Power:Show()

        if (self.Portrait) then self.Portrait:Show() end
    else
        self.Health:SetHeight(innerHeight)
        self.Power:Hide()

        if (self.Portrait) then self.Portrait:Hide() end
    end

    self.RaidDebuffs:SetWidth(h)
    self.RaidDebuffs:SetHeight(h)

    local HealPrediction = self.HealPrediction
    if (HealPrediction) then
        HealPrediction.myBar:SetWidth(w)
        HealPrediction.otherBar:SetWidth(w)
        HealPrediction.absorbBar:SetWidth(w)
    end
end

local function EditListRaidFrame(self)
    local Health = self.Health
    local Power = self.Power
    local Name = self.Name
    local RaidIcon = self.RaidIcon

    self.Shadow:Kill()
    self:SetTemplate()
    self:SetBackdropColor(0, 0, 0)

    -- Frame to overlay text above heal prediction
    local OverlayFrame = CreateFrame("Frame", nil, self)
    OverlayFrame:SetAllPoints()
    OverlayFrame:SetFrameLevel(Health:GetFrameLevel() + 3)

    Health:ClearAllPoints()
    Health:Point("TOPLEFT", self, borderSize, -borderSize)
    Health:Point("TOPRIGHT", self, -borderSize, -borderSize)
    Health:SetFrameLevel(3)

    Power:ClearAllPoints()
    Power:Point("BOTTOMLEFT", self, borderSize, borderSize)
    Power:Point("BOTTOMRIGHT", self, -borderSize, borderSize)
    Power:Height(powerHeight)

    Name:SetParent(OverlayFrame)
    Name:ClearAllPoints()
    Name:Point("LEFT", self, "RIGHT", 5, 0)
    Name:SetTextColor(.9,.9,.9)
    if (C.UnitFrames.DarkTheme) then
        Health:SetStatusBarColor(.25, .25, .25)
        self:Tag(Name, "[Tukui:GetNameColor][Tukui:NameMedium][Tukui:Role]")
    else
        Name:SetTextColor(.9, .9, .9)
        self:Tag(Name, "[Tukui:NameMedium][Tukui:Role]")
    end

    -- I have no idea what it will look like with the portrait, but at least this will be half-decent
    if (self.Portrait) then
        local Portrait = self.Portrait
        Portrait:ClearAllPoints()
        Portrait:SetWidth(partyWidth)
        Portrait:SetHeight(partyHeight)
        Portrait:Point("RIGHT", self, "LEFT", -1, 0)
        Portrait.Backdrop:SetOutside(Portrait)
        Portrait.Backdrop.Shadow:Kill()
    end

    self.Buffs = nil
    self.Debuffs = nil
    -- No debuffs (for now)
    -- If I revisit this in the future, I must be careful if I also want RaidDebuffs
    -- I can't call self:DisableElement("RaidDebuffs") before the frame is completely spawned

    -- local numDebuffs = 5
    -- Debuffs:Point("LEFT", self, "RIGHT", ufSpacing, 0)
    -- Debuffs:SetWidth(numDebuffs*(partyHeight + T.Scale(ufSpacing)))
    -- Debuffs:SetHeight(partyHeight)
    -- Debuffs.size = partyHeight
    -- Debuffs.num = numDebuffs
    -- Debuffs.spacing = ufSpacing



    local RaidDebuffs = CreateFrame("Frame", nil, self)
    RaidDebuffs:Point("LEFT", self, "RIGHT", ufSpacing, 0)
    RaidDebuffs:SetTemplate()

    RaidDebuffs.icon = RaidDebuffs:CreateTexture(nil, "ARTWORK")
    RaidDebuffs.icon:SetTexCoord(.1, .9, .1, .9)
    RaidDebuffs.icon:SetInside(RaidDebuffs)

    RaidDebuffs.cd = CreateFrame("Cooldown", nil, RaidDebuffs)
    RaidDebuffs.cd:SetAllPoints(RaidDebuffs)
    RaidDebuffs.cd:SetHideCountdownNumbers(true)

    RaidDebuffs.ShowDispelableDebuff = true
    RaidDebuffs.FilterDispelableDebuff = true
    RaidDebuffs.MatchBySpellName = true
    RaidDebuffs.ShowBossDebuff = true
    RaidDebuffs.BossDebuffPriority = 5

    RaidDebuffs.count = RaidDebuffs:CreateFontString(nil, "OVERLAY")
    RaidDebuffs.count:SetFont(C.Medias.Font, 12, "OUTLINE")
    RaidDebuffs.count:SetPoint("BOTTOMRIGHT", RaidDebuffs, "BOTTOMRIGHT", 2, 0)
    RaidDebuffs.count:SetTextColor(1, .9, 0)

    RaidDebuffs.SetDebuffTypeColor = RaidDebuffs.SetBackdropBorderColor
    RaidDebuffs.Debuffs = UnitFrames.RaidDebuffsTracking

    RaidDebuffs:SetScript("OnShow", RaidDebuffsShow)
    RaidDebuffs:SetScript("OnHide", RaidDebuffsHide)
    self.RaidDebuffs = RaidDebuffs

    RaidIcon:SetParent(OverlayFrame)
    RaidIcon:ClearAllPoints()
    RaidIcon:Point("CENTER", self, "BOTTOM", 0, 8)

    self.ReadyCheck:SetParent(OverlayFrame)
    self.ReadyCheck:ClearAllPoints()
    self.ReadyCheck:Point("CENTER", Health)

    self.Leader:Kill()
    self.Leader = nil

    self.OverlayFrame = OverlayFrame
    self.Name = Name

    self.UpdateForSize = UpdateFrameForSize

    local parent = self:GetParent()
    self:UpdateForSize(parent:GetAttribute("initial-width"), parent:GetAttribute("initial-height"), GetNumGroupMembers() <= 5)
end

hooksecurefunc(UnitFrames, "Party", EditListRaidFrame)