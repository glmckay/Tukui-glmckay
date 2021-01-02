local T, C, L = Tukui:unpack()

local UnitFrames = T.UnitFrames

local ufFont = T.GetFont(C["Raid"].Font)
local BorderSize = C["General"].BorderSize
local FrameSpacing = C["General"].FrameSpacing

local powerHeight = 2
local NumDebuffs = 4
local GridDebuffSize = 33

UnitFrames.PartyListWidth = 170
UnitFrames.PartyListHeight = 32


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

        if (message == "GRID" and false) then
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
    ]], FrameSpacing, NumDebuffs, GridDebuffSize, UnitFrames.PartyListHeight))
end


local function InitProtectedStyle(self, frameStyle)
    local Debuffs = self.Debuffs
    local Size

    Debuffs:ClearAllPoints()
    if (frameStyle == "GRID" and false) then
        Size = GridDebuffSize
        Debuffs:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -FrameSpacing)
    else
        Size = UnitFrames.PartyListHeight
        Debuffs:SetPoint("TOPLEFT", self, "TOPRIGHT", FrameSpacing, 0)
    end

    Debuffs:SetWidth(NumDebuffs * (Size + FrameSpacing))
    Debuffs:SetHeight(Size)

    local frames = {Debuffs:GetChildren()}
    for i,frame in ipairs(frames) do
        frame:SetWidth(Size)
        frame:SetHeight(Size)
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
    local innerWidth = w - 2*BorderSize
    local HealthPrediction = self.HealthPrediction
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
            self.Name:SetPoint("BOTTOM", self, "CENTER", 0, 2)

            self.Debuffs.size = GridDebuffSize
            self.Health.Value:Show()
            self.Power:Hide()

            ReadyCheck:ClearAllPoints()
            ReadyCheck:SetPoint("CENTER")

            RaidIcon:ClearAllPoints()
            RaidIcon:SetPoint("CENTER", self, "TOP")
        else
            self.Name:ClearAllPoints()
            self.Name:SetPoint("CENTER", self, "CENTER")

            self.Debuffs.size = UnitFrames.PartyListHeight
            self.Health.Value:Hide()
            if (self.CurrentRole == "HEALER") then
                self.Power:Show()
            end

            ReadyCheck:ClearAllPoints()
            ReadyCheck:SetPoint("RIGHT", self, "RIGHT", -20, 0)

            RaidIcon:ClearAllPoints()
            RaidIcon:SetPoint("RIGHT", self, "RIGHT", -4, 0)
        end
        self.FrameStyle = style
    end
end

local function PostUpdatePower(self, unit, cur, min, max)
    local pType, pToken = UnitPowerType(unit)
    local isMana = pType == 0
    if (isMana ~= self.BarShown) then
        self:SetAlpha(isMana and 1 or 0)
        self.BarShown = isMana
    end
end


local function EditListRaidFrame(self)
    local Health = self.Health
    local Power = self.Power
    local Name = self.Name
    local RaidIcon = self.RaidTargetIndicator
    local ReadyCheck = self.ReadyCheckIndicator

    -- Frame to overlay text above heal prediction
    local OverlayFrame = CreateFrame("Frame", nil, self)
    OverlayFrame:SetAllPoints()
    OverlayFrame:SetFrameLevel(Health:GetFrameLevel() + 3)

    local GroupIconFrame = CreateFrame("Frame", nil, OverlayFrame)
    GroupIconFrame:SetAllPoints()
    RegisterStateDriver(GroupIconFrame, "visibility", "[mod:alt]show;hide")

    Health:ClearAllPoints()
    Health:SetInside()
    Health:SetFrameLevel(3)

    Health.Value:SetParent(OverlayFrame)
    Health.Value:ClearAllPoints()
    Health.Value:SetPoint("TOP", self, "CENTER", 0, -2)

    Power:SetFrameLevel(5)
    Power:ClearAllPoints()
    Power:SetPoint("BOTTOMLEFT", self, BorderSize, BorderSize)
    Power:SetPoint("BOTTOMRIGHT", self, -BorderSize, BorderSize)
    Power:SetHeight(powerHeight)
    Power:CreateBackdrop()
    Power.PostUpdate = PostUpdatePower

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

    RaidIcon:SetParent(OverlayFrame)
    RaidIcon:ClearAllPoints()
    RaidIcon:SetPoint("TOP", self, "TOP", 0, 2)

    ReadyCheck:SetParent(OverlayFrame)
    ReadyCheck:ClearAllPoints()
    ReadyCheck:SetPoint("CENTER", Health)

    self.LeaderIndicator:ClearAllPoints()
    self.LeaderIndicator:SetPoint("TOPLEFT", self, "TOPLEFT", 3, 0)
    self.LeaderIndicator:SetParent(GroupIconFrame)

    self.MasterLooterIndicator:Kill()
    self.MasterLooterIndicator = nil

    local GroupRoleIndicator = GroupIconFrame:CreateTexture(nil, 'OVERLAY')
    GroupRoleIndicator:SetSize(16, 16)
    GroupRoleIndicator:SetPoint("BOTTOMLEFT", 2, 2)
    GroupRoleIndicator:SetParent(GroupIconFrame)
    GroupRoleIndicator.Override = UnitFrames.GroupRoleIndicatorUpdate
    self.GroupRoleIndicator = GroupRoleIndicator

    if C.Party.AuraTrack then
		local AuraTrack = CreateFrame("Frame", nil, Health)
		AuraTrack:SetAllPoints()
		AuraTrack.Texture = C.Medias.Normal
		AuraTrack.Icons = C.Raid.AuraTrackIcons
		AuraTrack.Thickness = C.Raid.AuraTrackThickness
		AuraTrack.IconSize = C.Raid.AuraTrackIconSize
		AuraTrack.Spacing = C.Raid.AuraTrackSpacing

        self.AuraTrack = AuraTrack
    end

    self.OverlayFrame = OverlayFrame
    self.Name = Name

    self.UpdateWidth = UpdateFrameWidth
    self.UpdateStyle = UpdateFrameStyle

    SetProtectedStyleUpdates(self)

    -- self:RegisterEvent("GROUP_ROSTER_UPDATE", OnRoleUpdate)
    -- self.PreUpdate = OnPreUpdate
    -- self:UpdateStyle(frameStyle)
    OnPreUpdate(self)

    local parent = self:GetParent()
    local frameStyle = parent:GetAttribute("framestyle") or "LIST"
    InitProtectedStyle(self, frameStyle)
    self:UpdateWidth(parent:GetAttribute("initial-width"))

end

hooksecurefunc(UnitFrames, "Party", EditListRaidFrame)