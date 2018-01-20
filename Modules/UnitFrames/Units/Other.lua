local T, C, L = Tukui:unpack()

local UnitFrames = T.UnitFrames
local DummyFcn = function() end


local ufFont = T.GetFont(C["UnitFrames"].Font)

local borderSize = C.General.BorderSize
local ufHeight = UnitFrames.ufHeight
local powerHeight = 3

UnitFrames.OtherWidth = 200


local function EditOtherFramesCommon(self)
    local Health = self.Health
    local Power = self.Power
    local Name = self.Name

    self.Shadow:Kill()
    self:SetBackdrop(UnitFrames.SkinnedBackdrop)
    self:SetBackdropColor(0, 0, 0)

    -- Health
    Health:ClearAllPoints()
    Health:Point("TOPLEFT", self)
    Health:Point("BOTTOMRIGHT", self, 0, powerHeight + borderSize)

    Health.Value:ClearAllPoints()
    Health.Value:Point("RIGHT", Health, "TOPRIGHT", -2, 2)

    if C.UnitFrames.DarkTheme then
        Health:SetStatusBarColor(.25, .25, .25)
    end

    -- Power
    Power:ClearAllPoints()
    Power:Height(powerHeight)
    Power:Point("BOTTOMLEFT", self)
    Power:Point("BOTTOMRIGHT", self)

    Power.Value:Kill()
    -- Power.Value = nil -- Can't set to nil, otherwise PostPowerUpdate errors

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
        Buffs:Point("RIGHT", self, "LEFT", -5, 0)
        Buffs:SetFrameLevel(self:GetFrameLevel())
        Buffs:Height(ufHeight)
        Buffs:Width(3*ufHeight + 10)
        Buffs.size = T.Scale(ufHeight)
        Buffs.spacing = 5

        Debuffs:ClearAllPoints()
        Debuffs:Point("LEFT", self, "RIGHT", 5, 0)
        Debuffs:SetFrameLevel(self:GetFrameLevel())
        Debuffs:Height(ufHeight)
        Debuffs:Width(5*ufHeight + 20)
        Debuffs.size = T.Scale(ufHeight)
        Debuffs.spacing = 5
    end
end


local function EditFocus(self)
    EditFocusFocusTargetCommon(self)

    if (C.UnitFrames.CastBar) then
        local CastBar = self.Castbar

        CastBar.Shadow:Kill()
        CastBar:SetBackdrop(UnitFrames.SkinnedBackdrop)
        CastBar:SetBackdropColor(0, 0, 0)
        CastBar:ClearAllPoints()
        CastBar:Height(18)
        CastBar:Point("BOTTOMLEFT", self, "TOPLEFT", 0, 10)
        CastBar:Point("BOTTOMRIGHT", self, "TOPRIGHT", 0, 10)

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

    if (C.UnitFrames.CastBar) then
        local CastBar = self.Castbar

        CastBar:ClearAllPoints()
        CastBar:Point("TOPLEFT", self, "BOTTOMLEFT", 0, -5)
        CastBar:Point("TOPRIGHT", self, "BOTTOMRIGHT", 0, -5)
        CastBar:Height(14)
        CastBar:SetBackdrop(UnitFrames.SkinnedBackdrop)
        CastBar:SetBackdropColor(0, 0, 0)

        CastBar.Time:SetFontObject(smallFont)
        CastBar.Time:ClearAllPoints()
        CastBar.Time:Point("RIGHT", CastBar, "RIGHT", -2, 1)

        CastBar.Text:SetFontObject(smallFont)
        CastBar.Text:ClearAllPoints()
        CastBar.Text:SetWidth(150)
        CastBar.Text:Point("LEFT", CastBar, "LEFT", 2, 1)

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
        Debuffs:Point("LEFT", self, "RIGHT", 5, 0)
        Debuffs:SetFrameLevel(self:GetFrameLevel())
        Debuffs:Height(ufHeight)
        Debuffs:Width(5*ufHeight + 20)
        Debuffs.size = T.Scale(ufHeight)
        Debuffs.spacing = 5
    end

    SpecIcon:ClearAllPoints()
    SpecIcon:Size(ufHeight)
    SpecIcon:Point("RIGHT", self, "LEFT", -5, 0)

    Trinket:ClearAllPoints()
    Trinket:Size(ufHeight)
    Trinket:Point("RIGHT", self, "LEFT", -(ufHeight + 10))
end


local function EditBoss(self)
    EditArenaBossCommon(self)

    if (C.UnitFrames.BossAuras) then
        local Buffs = self.Buffs
        local Debuffs = self.Debuffs

        Buffs:ClearAllPoints()
        Buffs:Point("RIGHT", self, "LEFT", -5, 0)
        Buffs:SetFrameLevel(self:GetFrameLevel())
        Buffs:Height(ufHeight)
        Buffs:Width(3*ufHeight + 10)
        Buffs.size = T.Scale(ufHeight)
        Buffs.spacing = 5

        Debuffs:ClearAllPoints()
        Debuffs:Point("LEFT", self, "RIGHT", 5, 0)
        Debuffs:SetFrameLevel(self:GetFrameLevel())
        Debuffs:Height(ufHeight)
        Debuffs:Width(5*ufHeight + 20)
        Debuffs.size = T.Scale(ufHeight)
        Debuffs.spacing = 5
    end
end


hooksecurefunc(UnitFrames, "Focus", EditFocus)
hooksecurefunc(UnitFrames, "FocusTarget", EditFocusTarget)
hooksecurefunc(UnitFrames, "Arena", EditArena)
hooksecurefunc(UnitFrames, "Boss", EditBoss)