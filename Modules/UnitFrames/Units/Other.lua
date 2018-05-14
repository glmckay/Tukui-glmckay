local T, C, L = Tukui:unpack()

local UnitFrames = T.UnitFrames
local DummyFcn = function() end


local ufFont = T.GetFont(C["UnitFrames"].Font)

local ufSpacing = C.General.FrameSpacing
local borderSize = C.General.BorderSize
local ufHeight = UnitFrames.FrameHeight
local powerHeight = 3

UnitFrames.OtherWidth = 200


local function OtherPostUpdateHealth(self, unit, min, max)
    if (not UnitIsConnected(unit) or UnitIsDead(unit) or UnitIsGhost(unit)) then
        if (not UnitIsConnected(unit)) then
            self.Value:SetText("|cffD7BEA5"..FRIENDS_LIST_OFFLINE.."|r")
        elseif (UnitIsDead(unit)) then
            self.Value:SetText("|cffD7BEA5"..DEAD.."|r")
        elseif (UnitIsGhost(unit)) then
            self.Value:SetText("|cffD7BEA5"..L.UnitFrames.Ghost.."|r")
        end
    elseif (unit) then
        local r, g, b

        if (strfind(unit, "boss%d") and min ~= max) then
            r, g, b = T.ColorGradient(min, max, 0.69, 0.31, 0.31, 0.65, 0.63, 0.35, 0.33, 0.59, 0.33)
            self.Value:SetFormattedText("|cff%02x%02x%02x%d%%|r", r * 255, g * 255, b * 255, floor(min / max * 100))
        else
            self.Value:SetText("|cff559655"..UnitFrames.ShortValue(max).."|r")
        end
    else
        self.Value:SetText(" ")
    end
end


local function EditOtherFramesCommon(self)
    local Health = self.Health
    local Power = self.Power
    local Name = self.Name

    self.Shadow:Kill()
    self:SetTemplate()
    self:SetBackdropColor(0, 0, 0)

    -- Health
    Health:ClearAllPoints()
    Health:Point("TOPLEFT", self, borderSize, -borderSize)
    Health:Point("TOPRIGHT", self, -borderSize, -borderSize)
    Health:Height(ufHeight - powerHeight - 3*borderSize)

    Health.Value:ClearAllPoints()
    Health.Value:Point("RIGHT", Health, "TOPRIGHT", -2, 2)

    Health.PostUpdate = OtherPostUpdateHealth

    if C.UnitFrames.DarkTheme then
        Health:SetStatusBarColor(.25, .25, .25)
    else
        Name:SetTextColor(.9, .9, .9)
    end

    -- Power
    Power:ClearAllPoints()
    Power:Height(powerHeight)
    Power:Point("BOTTOMLEFT", self, borderSize, borderSize)
    Power:Point("BOTTOMRIGHT", self, -borderSize, borderSize)

    Power.Value:Kill()
    Power.Value = nil
    Power.PostUpdate = nil

    -- Name
    Name:ClearAllPoints()
    Name:Point("LEFT", Health, "TOPLEFT", 2, 2)
    if (C.UnitFrames.DarkTheme) then
        self:Tag(Name, "[Tukui:GetNameColor][Tukui:NameMedium]")
    else
        self:Tag(Name, "[Tukui:NameMedium]")
    end
end


local function EditFocusFocusTargetCommon(self)
    EditOtherFramesCommon(self)

    if (C.UnitFrames.FocusAuras) then
        local Buffs = self.Buffs
        local Debuffs = self.Debuffs

        Buffs:ClearAllPoints()
        Buffs:Point("RIGHT", self, "LEFT", -ufSpacing, 0)
        Buffs:SetFrameLevel(self:GetFrameLevel())
        Buffs:Height(ufHeight)
        Buffs:Width(3*ufHeight + 2*ufSpacing)
        Buffs.size = T.Scale(ufHeight)
        Buffs.spacing = T.Scale(ufSpacing)

        Debuffs:ClearAllPoints()
        Debuffs:Point("LEFT", self, "RIGHT", ufSpacing, 0)
        Debuffs:SetFrameLevel(self:GetFrameLevel())
        Debuffs:Height(ufHeight)
        Debuffs:Width(5*ufHeight + 4*ufSpacing)
        Debuffs.size = T.Scale(ufHeight)
        Debuffs.spacing = T.Scale(ufSpacing)
    end
end


local function EditFocus(self)
    EditFocusFocusTargetCommon(self)

    if (C.UnitFrames.CastBar) then
        local CastBar = self.Castbar

        CastBar.Shadow:Kill()
        CastBar:SetBackdrop({})
        CastBar:CreateBackdrop()
        CastBar:ClearAllPoints()
        CastBar:Height(20)
        CastBar:Point("TOPLEFT", self, "BOTTOMLEFT", borderSize, -3)
        CastBar:Point("TOPRIGHT", self, "BOTTOMRIGHT", -borderSize, -3)

        CastBar.Time:SetFontObject(smallFont)
        CastBar.Time:ClearAllPoints()
        CastBar.Time:Point("RIGHT", CastBar, "RIGHT", -2, 0)

        CastBar.Text:SetFontObject(smallFont)
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

    local OverlayFrame = CreateFrame("Frame", nil, self)
    OverlayFrame:SetAllPoints()
    OverlayFrame:SetFrameLevel(Health:GetFrameLevel() + 3)

    self.Name:SetParent(OverlayFrame)
    Health.Value:SetParent(OverlayFrame)

    if (C.UnitFrames.CastBar) then
        local CastBar = self.Castbar

        CastBar:SetFrameLevel(Health:GetFrameLevel() + 2)
        CastBar:SetInside(self)
        CastBar:SetBackdrop({ bgFile = C.Medias.Blank })
        CastBar:SetBackdropColor(.2,.2,.2,1)

        CastBar.Time:SetFontObject(smallFont)
        CastBar.Time:ClearAllPoints()
        CastBar.Time:Point("RIGHT", CastBar, "RIGHT", -2, -2)

        CastBar.Text:SetFontObject(smallFont)
        CastBar.Text:ClearAllPoints()
        CastBar.Text:SetWidth(UnitFrames.OtherWidth - 50)
        CastBar.Text:Point("LEFT", CastBar, "LEFT", 2, -2)

        CastBar.Button:Kill()
        CastBar.Icon:Kill()
        CastBar.Shadow:Kill()
    end
end


local function EditArena(self)
    EditArenaBossCommon(self)

    local SpecIcon = self.PVPSpecIcon
    local Trinket = self.Trinket

    if (C.UnitFrames.ArenaAuras) then
        local Debuffs = self.Debuffs

        Debuffs:ClearAllPoints()
        Debuffs:Point("LEFT", self, "RIGHT", ufSpacing, 0)
        Debuffs:SetFrameLevel(self:GetFrameLevel())
        Debuffs:Height(ufHeight)
        Debuffs:Width(5*ufHeight + 4*borderSize)
        Debuffs.size = T.Scale(ufHeight)
        Debuffs.spacing = T.Scale(ufSpacing)
    end

    SpecIcon:ClearAllPoints()
    SpecIcon:Size(ufHeight - 2*borderSize)
    SpecIcon:Point("RIGHT", self, "LEFT", -(1 + borderSize), 0)
    SpecIcon.Backdrop.Shadow:Kill()

    Trinket:ClearAllPoints()
    Trinket:Size(ufHeight - 2*borderSize)
    Trinket:Point("RIGHT", self, "LEFT", -(ufHeight + 1), 0)
    Trinket.Backdrop.Shadow:Kill()
end


local function EditBoss(self)
    EditArenaBossCommon(self)

    if (C.UnitFrames.BossAuras) then
        local Buffs = self.Buffs
        local Debuffs = self.Debuffs

        Buffs:ClearAllPoints()
        Buffs:Point("RIGHT", self, "LEFT", -ufSpacing, 0)
        Buffs:SetFrameLevel(self:GetFrameLevel())
        Buffs:Height(ufHeight)
        Buffs:Width(3*ufHeight + 2*borderSize)
        Buffs.size = T.Scale(ufHeight)
        Buffs.spacing = T.Scale(ufSpacing)

        Debuffs:ClearAllPoints()
        Debuffs:Point("LEFT", self, "RIGHT", ufSpacing, 0)
        Debuffs:SetFrameLevel(self:GetFrameLevel())
        Debuffs:Height(ufHeight)
        Debuffs:Width(5*ufHeight + 4*borderSize)
        Debuffs.size = T.Scale(ufHeight)
        Debuffs.spacing = T.Scale(ufSpacing)
    end
end


hooksecurefunc(UnitFrames, "Focus", EditFocus)
hooksecurefunc(UnitFrames, "FocusTarget", EditFocusTarget)
hooksecurefunc(UnitFrames, "Arena", EditArena)
hooksecurefunc(UnitFrames, "Boss", EditBoss)