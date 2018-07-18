local T, C, L = Tukui:unpack()

local Panels = T.Panels
local UnitFrames = T.UnitFrames
local DummyFcn = function() end

-- localise some globals that will get used a lot
local floor = math.floor
local UnitIsPlayer = UnitIsPlayer
local UnitIsConnected = UnitIsConnected
local UnitPlayerControlled = UnitPlayerControlled
local UnitIsGhost = UnitIsGhost
local UnitIsDead = UnitIsDead
local UnitClass = UnitClass
local UnitPowerType = UnitPowerType

local BigNumberFont = T.GetFont(C["UnitFrames"].BigNumberFont)
local NumberFont = T.GetFont(C["UnitFrames"].NumberFont)
local NameFont = T.GetFont(C["UnitFrames"].Font)

local BorderSize = C.General.BorderSize
local FrameSpacing = C.General.FrameSpacing
local auraSize = C.ActionBars.PlayerButtonSize
local aurasPerRow = 8
local ufWidth = (FrameSpacing + auraSize)*aurasPerRow - FrameSpacing
local ufHeight = UnitFrames.FrameHeight
local healthHeight = ufHeight - 2*BorderSize
local powerHeight = 2

local CenterBarWidth = Panels.CenterPanelWidth - 2*BorderSize
local MeleePowerHeight = 9
local RangedPowerHeight = 7
local MeleeCastBarHeight = 14
local RangedCastBarHeight = ufHeight - RangedPowerHeight - 4*BorderSize - FrameSpacing

UnitFrames.PlayerTargetWidth = ufWidth


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
        self.Value:SetText(UnitFrames.ShortValue(min))
        self.Percent:SetFormattedText("%s%%", floor(min / max * 100))
    end
end


local function PlayerPostUpdatePower(self, unit, min, max)
    local pType, pToken = UnitPowerType(unit)

    if (UnitIsDead(unit) or UnitIsGhost(unit)) then
        self.Value:SetText()
        if (self.ExtraValue) then self.ExtraValue:SetText() end
    else
        if (pType == 0) then -- mana
            local value = UnitFrames.ShortValue(min)
            self.Value:SetText(value)
            if (self.ExtraValue) then self.ExtraValue:SetText() end
        else
            if ((pType == 3 and min == max) or (min == 0)) then -- pType 3 is energy
                self.Value:SetText()
            else
                self.Value:SetText(min)
            end
            if (self.ExtraValue) then self.ExtraValue:SetText(min) end
        end
    end
end


local function TargetPostUpdatePower(self, unit, min, max)
    local pType, pToken = UnitPowerType(unit)
    local isPlayer = UnitIsPlayer(unit)
    local class = UnitClass(unit)
    if ((pType == 0 and isPlayer and not (class == "Warlock" or class == "Mage")) or
        (pType ~= 0 and not isPlayer and min > 0)) then
        if (self.LastAlpha ~= 1) then
            local Parent = self:GetParent()
            Parent.Health:Height(ufHeight - powerHeight - 3*BorderSize)
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
            local Parent = self:GetParent()
            Parent.Health:Height(ufHeight - 2*BorderSize)
            self:SetAlpha(0)
            self.LastAlpha = 0
            self.Value:SetText()
        end
    end
end


local function EditPlayerTargetCommon(self)
    local Health = self.Health
    local Power = self.Power
    local CastBar = self.Castbar

    self.Panel:Kill()
    self:SetTemplate()
    self:SetBackdropColor(0, 0, 0) -- so the space between health and power is black

    -- Frame to overlay text above heal prediction
    local OverlayFrame = CreateFrame("Frame", nil, self)
    OverlayFrame:SetAllPoints()
    OverlayFrame:SetFrameLevel(Health:GetFrameLevel() + 3)

    -- Health
    Health:ClearAllPoints()
    Health:Point("TOPLEFT", self, BorderSize, -BorderSize)
    Health:Point("TOPRIGHT", self, -BorderSize, -BorderSize)

    Health.Value:SetParent(OverlayFrame)
    Health.Value:SetFontObject(NumberFont)

    Health.Percent = OverlayFrame:CreateFontString(nil, "OVERLAY")
    Health.Percent:SetFontObject(BigNumberFont)

    Health.PostUpdate = PostUpdateHealth

    Power.Value:SetParent(OverlayFrame)
    Power.Value:SetFontObject(NumberFont)

    -- Cast bar
    CastBar:Width(CenterBarWidth)
    CastBar:SetBackdrop({})
    CastBar:CreateBackdrop()

    CastBar.Time:SetFontObject(NumberFont)
    CastBar.Time:ClearAllPoints()
    CastBar.Time:Point("RIGHT", CastBar, "RIGHT", -2, 0)

    CastBar.Text:SetFontObject(NumberFont)

    if C.UnitFrames.DarkTheme then
        Health:SetStatusBarColor(.25, .25, .25)
    end

    if (C.UnitFrames.HealBar) then
        local HealPrediction = self.HealPrediction

        for name,bar in pairs(HealPrediction) do
            if (name ~= 'maxOverflow') then
                bar:Width(ufWidth - 2*BorderSize)
            end
        end
    end

    self.OverlayFrame = OverlayFrame
end



local function EditPlayer(self)
    EditPlayerTargetCommon(self)

    local Health = self.Health
    local Power = self.Power
    local AdditionalPower = self.AdditionalPower
    local CastBar = self.Castbar
    local OverlayFrame = self.OverlayFrame

    -- Health
    Health:Height(healthHeight - powerHeight - BorderSize)

    Health.Value:ClearAllPoints()
    Health.Value:Point("RIGHT", Health, "RIGHT", -2, 0)

    Health.Percent:Point("LEFT", Health, "TOPLEFT", 2, 0)

    -- Power
    Power:Width(CenterBarWidth)
    Power:CreateBackdrop()


    Power.Value:ClearAllPoints()
    Power.Value:Point("BOTTOMLEFT", self, "BOTTOMLEFT", 2, 2)
    Power.PostUpdate = PlayerPostUpdatePower

    Power.Prediction:Width(ufWidth - 2*BorderSize)

    -- Create a new string for the detached power bar (the usual string will stay on the frame when out of combat)
    Power.ExtraValue = Power:CreateFontString(nil, "OVERLAY")
    Power.ExtraValue:SetFontObject(BigNumberFont)
    Power.ExtraValue:Point("CENTER", Power, "TOP", 0, 0)

    Power.Value:SetParent(OverlayFrame)

    RegisterStateDriver(Power, "visibility", "[combat][mod:shift]show;hide")
    Power:SetScript("OnShow", function() Power.Value:Hide() end)
    Power:SetScript("OnHide", function() Power.Value:Show() end)

    -- AdditionalPower
    AdditionalPower:ClearAllPoints()
    AdditionalPower:Height(powerHeight)
    AdditionalPower:Point("BOTTOMLEFT", Power, "TOPLEFT", 0, BorderSize)
    AdditionalPower:Point("BOTTOMRIGHT", Power, "TOPRIGHT", 0, BorderSize)

    -- Fix health height when shown/hidden
    AdditionalPower:Point("BOTTOMLEFT", self, BorderSize, BorderSize)
    AdditionalPower:Point("BOTTOMRIGHT", self, -BorderSize, BorderSize)

    AdditionalPower:SetScript("OnShow", function()
        Health:Height(healthHeight - powerHeight - BorderSize)
    end)
    AdditionalPower:SetScript("OnHide", function()
        Health:Height(healthHeight)
    end)

    -- CastBar
    CastBar:ClearAllPoints()
    if (C.UnitFrames.UnlinkCastBar) then
        CastBar:Point("TOP", Panels.UnitFrameAnchor, "TOP", 0, -BorderSize)
        CastBar:Size(CenterBarWidth, CastBarHeight)
        CastBar:SetFrameLevel(Power:GetFrameLevel())
    else
        CastBar:Point("TOP", self, "BOTTOM", 0, -FrameSpacing)
    end
    if (C.UnitFrames.CastBarIcon) then
        CastBar.Icon:Kill()
        CastBar.Button:Kill()
    end

    local Combat = self.Combat
    Combat:ClearAllPoints()
    Combat:Point("CENTER", Health, "CENTER")
    Combat:Size(24)
    Combat:SetVertexColor(1, 1, 1)

    self.Leader:Kill()
    self.Leader = nil

    self.MasterLooter:Kill()
    self.MasterLooter = nil

    if (UnitFrames.EditClassFeatures[T.MyClass]) then
        UnitFrames.EditClassFeatures[T.MyClass](self)
    end
end


-- Some spec specific settings for the Player frame
function UnitFrames:SetPlayerProfile(role, isRanged)
    local Player = self.Units.Player
    local Power = Player.Power
    local CastBar = Player.Castbar
    local CenterActionBars = Panels.CenterActionBars

    if (isRanged) then
        -- Position power bar so that some other resource bar can be comfortably placed above
        Power:ClearAllPoints()
        Power:Height(RangedPowerHeight)
        Power:Point("BOTTOM", Panels.UnitFrameAnchor, "BOTTOM", 0, BorderSize)

        CenterActionBars[1]:ClearAllPoints()
        CenterActionBars[1]:Point("TOP",Panels.UnitFrameAnchor, "BOTTOM", 0, -(BorderSize + FrameSpacing))

        CastBar:ClearAllPoints()
        CastBar:Height(RangedCastBarHeight)
        CastBar:Point("TOP", Panels.UnitFrameAnchor, "TOP", 0, -BorderSize)

        CastBar.Text:ClearAllPoints()
        CastBar.Text:Point("TOP", CastBar, "TOP")
        CastBar.Text:Point("BOTTOM", CastBar, "BOTTOM")
        CastBar.Text:Point("LEFT", CastBar, "LEFT", 2, 0)
        CastBar.Text:SetWidth(ufWidth - 80)
        CastBar.Text:SetJustifyH("LEFT")

        CastBar.Time:Show()
    else
        Power:ClearAllPoints()
        Power:Height(MeleePowerHeight)
        Power:Point("TOP", Panels.UnitFrameAnchor, 0, -(MeleePowerHeight + 3*BorderSize + FrameSpacing))

        CenterActionBars[1]:ClearAllPoints()
        CenterActionBars[1]:Point("TOP", Power, "BOTTOM", 0, -(BorderSize + FrameSpacing))

        CastBar:ClearAllPoints()
        CastBar:Height(MeleeCastBarHeight)
        CastBar:Point("TOP", CenterActionBars[2], "BOTTOM", 0, -(FrameSpacing + BorderSize))

        CastBar.Text:ClearAllPoints()
        CastBar.Text:Height(10)
        CastBar.Text:Point("RIGHT", CastBar, "RIGHT", -2, 0)
        CastBar.Text:Point("LEFT", CastBar, "LEFT", 2, 0)
        CastBar.Text:Point("TOP", CastBar, "CENTER")
        CastBar.Text:SetJustifyH("CENTER")

        CastBar.Time:Hide()
    end
end


local function EditTarget(self)
    EditPlayerTargetCommon(self)

    local Health = self.Health
    local Power = self.Power
    local CastBar = self.Castbar
    local OverlayFrame = self.OverlayFrame

    Health:Height(healthHeight)

    Health.Value:ClearAllPoints()
    Health.Value:Point("LEFT", Health, "LEFT", 2, 0)

    Health.Percent:Point("RIGHT", Health, "TOPRIGHT", -2, 0)

    -- Power
    Power:ClearAllPoints()
    Power:Height(powerHeight)
    Power:Point("BOTTOMLEFT", self, BorderSize, BorderSize)
    Power:Point("BOTTOMRIGHT", self, -BorderSize, BorderSize)

    Power.Value:ClearAllPoints()
    Power.Value:Point("BOTTOMRIGHT", self, "BOTTOMRIGHT", -2, 2)
    Power.PostUpdate = TargetPostUpdatePower

    -- Castbar
    CastBar:Height(healthHeight)
    CastBar:ClearAllPoints()
    if (C.UnitFrames.UnlinkCastBar) then
        CastBar:Point("BOTTOM", UIParent, "CENTER", 0, 340)
    else
        CastBar:Point("TOP", self, "BOTTOM", 0, -FrameSpacing)
    end

    CastBar.Text:ClearAllPoints()
    CastBar.Text:SetWidth(ufWidth - 80)
    CastBar.Text:Point("TOP", CastBar, "TOP")
    CastBar.Text:Point("BOTTOM", CastBar, "BOTTOM")
    CastBar.Text:Point("LEFT", CastBar, "LEFT", 2, 0)

    if C.UnitFrames.CastBarIcon then
        CastBar.Icon:ClearAllPoints()
        CastBar.Icon:Size(36)
        CastBar.Icon:Point("BOTTOM", CastBar, "TOP", 0, 10)
    end

    -- Create new Name since we killed the panel
    local Name = OverlayFrame:CreateFontString(nil, "OVERLAY")
    Name:Point("BOTTOMLEFT", Health, "TOPLEFT", 0, -1)
    Name:SetJustifyH("LEFT")
    Name:SetFontObject(NameFont)

    UnitFrames.UpdateNamePosition = DummyFcn

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
        local ComboPoints = self.ComboPointsBar

        Buffs:Point("BOTTOMLEFT", self, "TOPLEFT", 0, 15)
        Buffs:SetFrameLevel(self:GetFrameLevel())
        Buffs:Height(auraSize)
        Buffs:Width(ufWidth)
        Buffs.size = T.Scale(auraSize)
        Buffs.num = 24
        Buffs.numRow = aurasPerRow
        Buffs.spacing = T.Scale(FrameSpacing)


        Debuffs:Point("BOTTOMLEFT", buffs, "TOPLEFT", 0, 1) -- until  UpdateDebuffsHeaderPosition changes it
        Debuffs:SetFrameLevel(self:GetFrameLevel())
        Debuffs:Height(auraSize)
        Debuffs:Width(ufWidth)
        Debuffs.size = T.Scale(auraSize)
        Debuffs.num = 24
        Debuffs.numRow = aurasPerRow
        Debuffs.Spacing = T.Scale(FrameSpacing)

        -- Fix combo point scripts moving the buffs
        ComboPoints:SetScript("OnShow", function(self)
            UnitFrames.UpdateBuffsHeaderPosition(self, 25)
        end)
        ComboPoints:SetScript("OnHide", function(self)
            UnitFrames.UpdateBuffsHeaderPosition(self, 15)
        end)
    end
end

hooksecurefunc(UnitFrames, "Player", EditPlayer)
hooksecurefunc(UnitFrames, "Target", EditTarget)
