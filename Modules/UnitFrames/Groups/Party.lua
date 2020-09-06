local T, C, L = Tukui:unpack()

local UnitFrames = T.UnitFrames

local ufFont = T.GetFont(C["Raid"].Font)
local BorderSize = C["General"].BorderSize
local FrameSpacing = C["General"].FrameSpacing

local powerHeight = 2
local NumDebuffs = 3
local GridDebuffSize = 33

-- These are coincidentally identical to the largest List-style raid frames
UnitFrames.PartyListWidth = 160
UnitFrames.PartyListHeight = 36


local FilterDebuffs = nil
local DebuffBlacklist = C["Party"].DebuffBlacklist
if next(DebuffBlacklist) ~= nil then
    FilterDebuffs = function(self, unit, button, ...)
        local Name, Id = select(1, ...), select(10, ...)
        ListEntry = DebuffBlacklist[Id] or DebuffBlacklist[Name]
        if (ListEntry) then
            if (ListEntry.OtherPlayerOnly and unit ~= "player") then
                return true
            end
            return false
        end
        return true
    end
end


-- Protected stuff (basically the debuffs) needs to be handled separately.
local function SetProtectedStyleUpdates(self)
    self:SetFrameRef("frame", self)
    self:SetFrameRef("debuffs", self.Debuffs)
    self:SetAttribute("_childupdate-framestyle",  string.format([[
        local frame = self:GetFrameRef("frame")
        local debuffs = self:GetFrameRef("debuffs")
        local spacing = %d
        local numDebuffs = %d
        local size

        if (message == "GRID") then
            size = %d
            debuffs:ClearAllPoints()
            debuffs:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 0, -spacing)
        else
            size = %d
            debuffs:ClearAllPoints()
            debuffs:SetPoint("TOPLEFT", frame, "TOPRIGHT", spacing, 0)
        end
        debuffs:SetWidth(numDebuffs * (size + spacing))
        debuffs:SetHeight(size)

        local frames = newtable(debuffs:GetChildren())
        for _,frame in ipairs(frames) do
            frame:SetWidth(size)
            frame:SetHeight(size)
        end
    ]], T.Scale(FrameSpacing), NumDebuffs, T.Scale(GridDebuffSize), T.Scale(UnitFrames.PartyListHeight)))
end


local function InitProtectedStyle(self, frameStyle)
    local Debuffs = self.Debuffs
    local Size

    Debuffs:ClearAllPoints()
    if (frameStyle == "GRID") then
        Size = GridDebuffSize
        Debuffs:Point("TOPLEFT", self, "BOTTOMLEFT", 0, -FrameSpacing)
    else
        Size = UnitFrames.PartyListHeight
        Debuffs:Point("TOPLEFT", self, "TOPRIGHT", FrameSpacing, 0)
    end

    Debuffs:Width(NumDebuffs * (Size + FrameSpacing))
    Debuffs:Height(Size)

    local frames = {Debuffs:GetChildren()}
    for i,frame in ipairs(frames) do
        frame:Width(Size)
        frame:Height(Size)
    end
end


local function OnRoleUpdate(self)
    local role = UnitGroupRolesAssigned(self.unit)
    if (role == self.CurrentRole) then return end

    if (role == "HEALER" and self.FrameStyle ~= "GRID") then
        self.Power:Show()
    else
        self.Power:Hide()
    end
    self.CurrentRole = role
end


local function OnPreUpdate(self)
    OnRoleUpdate(self)

    local parent = self:GetParent()
    local frameStyle = parent:GetAttribute("framestyle") or "LIST"
    self:UpdateStyle(frameStyle)
end


local function UpdateFrameWidth(self, w)
    local innerWidth = w - 2*T.Scale(BorderSize)
    local HealthPrediction = self.HealthPrediction
    HealthPrediction.absorbBar:SetWidth(innerWidth)
    HealthPrediction.myBar:SetWidth(innerWidth)
    HealthPrediction.otherBar:SetWidth(innerWidth)
end


local function UpdateFrameStyle(self, style)
    local Name = self.Name
    local RaidIcon = self.RaidTargetIndicator
    local ReadyCheck = self.ReadyCheckIndicator

    if (self.FrameStyle ~= style) then
        if (style == "GRID") then
            self.Name:ClearAllPoints()
            self.Name:Point("BOTTOM", self, "CENTER", 0, 2)

            self.Debuffs.size = T.Scale(33)
            self.Health.Value:Show()
            self.Power:Hide()

            ReadyCheck:ClearAllPoints()
            ReadyCheck:Point("CENTER")

            RaidIcon:ClearAllPoints()
            RaidIcon:Point("CENTER", self, "TOP")
        else
            self.Name:ClearAllPoints()
            self.Name:Point("CENTER", self, "CENTER")

            self.Debuffs.size = T.Scale(36)
            self.Health.Value:Hide()
            if (self.CurrentRole == "HEALER") then
                self.Power:Show()
            end

            ReadyCheck:ClearAllPoints()
            ReadyCheck:Point("RIGHT", self, "RIGHT", -4, 0)

            RaidIcon:ClearAllPoints()
            RaidIcon:Point("LEFT", self, "LEFT", 4, 0)
        end
        self.FrameStyle = style
    end
end


local function EditListRaidFrame(self)
    local Health = self.Health
    local Power = self.Power
    local Name = self.Name
    local RaidIcon = self.RaidTargetIndicator
    local ReadyCheck = self.ReadyCheckIndicator

    self:SetTemplate()
    self:SetBackdropColor(0, 0, 0)

    -- Frame to overlay text above heal prediction
    local OverlayFrame = CreateFrame("Frame", nil, self)
    OverlayFrame:SetAllPoints()
    OverlayFrame:SetFrameLevel(Health:GetFrameLevel() + 3)

    Health:ClearAllPoints()
    Health:SetInside()
    Health:SetFrameLevel(3)

    Health.Value:SetParent(OverlayFrame)
    Health.Value:ClearAllPoints()
    Health.Value:Point("TOP", self, "CENTER", 0, -2)

    Power:SetFrameLevel(5)
    Power:ClearAllPoints()
    Power:Point("BOTTOMLEFT", self, BorderSize, BorderSize)
    Power:Point("BOTTOMRIGHT", self, -BorderSize, BorderSize)
    Power:Height(powerHeight)
    Power:CreateBackdrop()
    Power:Hide()

    Name:SetParent(OverlayFrame)
    if (C.UnitFrames.DarkTheme) then
        Health:SetStatusBarColor(.25, .25, .25)
        self:Tag(Name, "[Tukui:GetNameColor][Tukui:NameMedium][Tukui:Role]")
    else
        self:Tag(Name, "[Tukui:NameMedium]")
    end

    -- I don't care about the portrait
    if (self.Portrait) then
        self.Portrait:Kill()
        self.Portrait = nil
    end

    local Highlight = self.Highlight
    if (C.Party.Highlight) then
        Highlight:SetAllPoints(self)
        Highlight:SetBackdrop({ edgeFile = C.Medias.Blank, edgeSize = 2 })
        Highlight:SetFrameLevel(self:GetFrameLevel() + 1)
    else
        self:UnregisterEvent("PLAYER_TARGET_CHANGED", UnitFrames.Highlight)
        self:UnregisterEvent("RAID_ROSTER_UPDATE", UnitFrames.Highlight)
        self:UnregisterEvent("PLAYER_FOCUS_CHANGED", UnitFrames.Highlight)
        Highlight:Kill()
        self.Highlight = nil
    end

    self.Buffs:Kill()
    self.Buffs = nil

    local Debuffs = self.Debuffs
    self.Debuffs.num = NumDebuffs
    self.Debuffs.spacing = FrameSpacing
    self.Debuffs.CustomFilter = FilterDebuffs

    UnitFrames:CreateAuraWatch(self)

    RaidIcon:SetParent(OverlayFrame)
    RaidIcon:ClearAllPoints()
    RaidIcon:Point("TOP", self, "TOP", 0, 2)

    ReadyCheck:SetParent(OverlayFrame)
    ReadyCheck:ClearAllPoints()
    ReadyCheck:Point("CENTER", Health)

    self.LeaderIndicator:ClearAllPoints()
    self.LeaderIndicator:Point("TOPLEFT", self, "TOPLEFT", 2, -2)

    self.MasterLooterIndicator:Kill()
    self.MasterLooterIndicator = nil

    self.OverlayFrame = OverlayFrame
    self.Name = Name

    self.UpdateWidth = UpdateFrameWidth
    self.UpdateStyle = UpdateFrameStyle

    SetProtectedStyleUpdates(self)

    self:RegisterEvent("GROUP_ROSTER_UPDATE", OnRoleUpdate)
    self.PreUpdate = OnPreUpdate
    -- self:UpdateStyle(frameStyle)
    -- OnPreUpdate(self)

    local parent = self:GetParent()
    local frameStyle = parent:GetAttribute("framestyle") or "LIST"
    InitProtectedStyle(self, frameStyle)
    self:UpdateWidth(parent:GetAttribute("initial-width"))
end

hooksecurefunc(UnitFrames, "Party", EditListRaidFrame)