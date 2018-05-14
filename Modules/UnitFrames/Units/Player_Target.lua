local T, C, L = Tukui:unpack()

local Panels = T.Panels
local UnitFrames = T.UnitFrames
local DummyFcn = function() end

-- local some globals that will get used a lot
local UnitIsPlayer = UnitIsPlayer
local UnitIsConnected = UnitIsConnected
local UnitPlayerControlled = UnitPlayerControlled
local UnitIsGhost = UnitIsGhost
local UnitIsDead = UnitIsDead
local UnitPowerType = UnitPowerType

local ufFont = T.GetFont(C["UnitFrames"].Font)

local BorderSize = C.General.BorderSize
local ufSpacing = C.General.FrameSpacing
local CenterBarSize = (C.ActionBars.CenterButtonSize + ufSpacing) * 6 - ufSpacing
local auraSize = C.ActionBars.PlayerButtonSize
local aurasPerRow = 8
local ufWidth = (ufSpacing + auraSize)*aurasPerRow - ufSpacing
local ufHeight = UnitFrames.FrameHeight
local healthHeight = ufHeight - 2*BorderSize
local powerHeight = 3

UnitFrames.PlayerTargetWidth = ufWidth


local function PlayerPostUpdateHealth(self, unit, min, max)
    if (UnitIsDead(unit) or UnitIsGhost(unit)) then
        if (UnitIsDead(unit)) then
            self.Value:SetText("|cffD7BEA5"..DEAD.."|r")
        elseif (UnitIsGhost(unit)) then
            self.Value:SetText("|cffD7BEA5"..L.UnitFrames.Ghost.."|r")
        end
    else
        local r, g, b

        if (min ~= max) then
            r, g, b = T.ColorGradient(min, max, 0.69, 0.31, 0.31, 0.65, 0.63, 0.35, 0.33, 0.59, 0.33)
            if (self:GetAttribute("normalUnit") ~= "pet") then
                self.Value:SetFormattedText("|cffAF5050%s|r |cffD7BEA5-|r |cff%02x%02x%02x%d%%|r", UnitFrames.ShortValue(min), r * 255, g * 255, b * 255, floor(min / max * 100))
            else
                self.Value:SetText("|cffff2222-"..UnitFrames.ShortValue(max-min).."|r")
            end
        else
            if (self:GetAttribute("normalUnit") ~= "pet") then
                self.Value:SetText("|cff559655"..UnitFrames.ShortValue(max).."|r")
            else
                self.Value:SetText(" ")
            end
        end
    end
end


local function PlayerPostUpdatePower(self, unit, min, max)
    local Parent = self:GetParent()
    local pType, pToken = UnitPowerType(unit)
    local Colors = T["Colors"]
    local Color = Colors.power[pToken]

    if Color then
        self.Value:SetTextColor(Color[1], Color[2], Color[3])
        if (self.ExtraValue) then self.ExtraValue:SetTextColor(Color[1], Color[2], Color[3]) end
    end

    if (not UnitIsPlayer(unit) and not UnitPlayerControlled(unit) or not UnitIsConnected(unit) or UnitIsDead(unit) or UnitIsGhost(unit)) then
        self.Value:SetText()
        if (self.ExtraValue) then self.ExtraValue:SetText() end
    else
        if (min ~= max) then
            if (pType == 0) then
                if (unit == "player" and Parent:GetAttribute("normalUnit") == "pet" or unit == "pet") then
                    self.Value:SetFormattedText("%d%%", floor(min / max * 100))
                    if (self.ExtraValue) then self.ExtraValue:SetFormattedText("%d%%", floor(min / max * 100)) end
                end
                if (self.ExtraValue) then
                    self.Value:SetText(UnitFrames.ShortValue(max - (max - min)))
                    self.ExtraValue:SetFormattedText("|cff325582%d%%|r |cffD7BEA5-|r %s", floor(min / max * 100), UnitFrames.ShortValue(max - (max - min)))
                else
                    self.Value:SetFormattedText("%d%% |cffD7BEA5-|r %s", floor(min / max * 100), UnitFrames.ShortValue(max - (max - min)))
                end
            else
                self.Value:SetText(UnitFrames.ShortValue(max - (max - min)))
                if (self.ExtraValue) then self.ExtraValue:SetText(max - (max - min)) end
            end
        else
            if (pType == 0) then
                self.Value:SetText(UnitFrames.ShortValue(min))
                if (self.ExtraValue) then self.ExtraValue:SetText(UnitFrames.ShortValue(min)) end
            else
                self.Value:SetText(min)
                if (self.ExtraValue) then self.ExtraValue:SetText(min) end
            end
        end
    end
end


local function EditPlayerTargetCommon(self)
    local Health = self.Health
    local Power = self.Power
    local CastBar = self.Castbar

    self.Panel:Kill()
    self.Shadow:Kill()
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
    Health.Value:ClearAllPoints()
    Health.Value:Point("RIGHT", Health, "TOPRIGHT", -2, 2)

    -- Power
    Power:ClearAllPoints()
    Power:Height(powerHeight)
    Power:Point("BOTTOMLEFT", self, BorderSize, BorderSize)
    Power:Point("BOTTOMRIGHT", self, -BorderSize, BorderSize)

    Power.Value:SetParent(OverlayFrame)

    -- Cast bar
    CastBar:ClearAllPoints()
    CastBar:Size(ufWidth - 2*BorderSize, ufHeight - 2*BorderSize)
    CastBar:SetBackdrop({})
    CastBar:CreateBackdrop()
    if (CastBar.Shadow) then
        CastBar.Shadow:Kill()
    end

    CastBar.Time:ClearAllPoints()
    CastBar.Time:Point("RIGHT", CastBar, "RIGHT", -2, 1)

    CastBar.Text:ClearAllPoints()
    CastBar.Text:SetWidth(ufWidth - 50)
    CastBar.Text:Point("LEFT", CastBar, "LEFT", 2, 1)

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
    Health.PostUpdate = PlayerPostUpdateHealth

    -- Power
    Power.Value:ClearAllPoints()
    Power.Value:Point("LEFT", Health, "TOPLEFT", 2, 2)
    Power.PostUpdate = PlayerPostUpdatePower

    Power.Prediction:Width(ufWidth - 2*BorderSize)

    -- If Power bar is unlinked from the frame
    if (C.UnitFrames.UnlinkPower) then
        Power:ClearAllPoints()
        Power:Size(CenterBarSize, ufHeight - 2*BorderSize)
        Power:Point("CENTER", Panels.UnitFrameAnchor)
        Power:CreateBackdrop()

        -- Create a new string for the detached power bar (the usual string will stay on the frame when out of combat)
        Power.ExtraValue = Power:CreateFontString(nil, "OVERLAY")
        Power.ExtraValue:SetFontObject(ufFont)
        Power.ExtraValue:Point("CENTER", Power, "CENTER", 0, 2)
        Power.ExtraValue:SetParent(Power)
        Power.ExtraValue:SetTextColor(.9, .9, .9)

        Power.Value:SetParent(OverlayFrame)
    end

    -- AdditionalPower
    AdditionalPower:ClearAllPoints()
    AdditionalPower:Height(powerHeight)
    AdditionalPower:Point("BOTTOMLEFT", Power, "TOPLEFT", 0, BorderSize)
    AdditionalPower:Point("BOTTOMRIGHT", Power, "TOPRIGHT", 0, BorderSize)

    -- Fix health height when shown/hidden
    if (C.UnitFrames.UnlinkPower) then
        AdditionalPower:Point("BOTTOMLEFT", self, BorderSize, BorderSize)
        AdditionalPower:Point("BOTTOMRIGHT", self, -BorderSize, BorderSize)

        AdditionalPower:SetScript("OnShow", function()
            Health:Height(healthHeight - powerHeight - BorderSize)
        end)
        AdditionalPower:SetScript("OnHide", function()
            Health:Height(healthHeight)
        end)
    else
        AdditionalPower:SetScript("OnShow", function()
            Health:Height(healthHeight - 2*(powerHeight + BorderSize))
        end)
        AdditionalPower:SetScript("OnHide", function()
            Health:Height(healthHeight - powerHeight - BorderSize)
        end)
    end

    -- CastBar
    CastBar:ClearAllPoints()
    if (C.UnitFrames.UnlinkCastBar) then
        CastBar:Size(CenterBarSize, ufHeight - 2*BorderSize)
        CastBar:Point("CENTER", Panels.UnitFrameAnchor)
        CastBar:SetFrameLevel(Power:GetFrameLevel() + 3)
    else
        CastBar:Point("TOP", self, "BOTTOM", 0, -ufSpacing)
    end
    if (C.UnitFrames.CastBarIcon) then
        CastBar.Icon:Kill()
        CastBar.Button:Kill()
    end

    -- Create new combat indicator
    local Combat = OverlayFrame:CreateFontString(nil, "OVERLAY")
    Combat:SetFontObject(ufFont)
    Combat:Point("LEFT", Health, "TOPLEFT", 2, 2)
    Combat:SetText("In Combat")
    Combat:SetTextColor(.9, .1, .1)

    Combat.PostUpdate = function(self, inCombat)
        if inCombat then
            Power:Show()
            Power.Value:Hide()
        else
            Power:Hide()
            Power.Value:Show()
        end
    end

    self.Combat:Kill()
    self.Combat = Combat

    self.Leader:Kill()
    self.Leader = nil

    self.MasterLooter:Kill()
    self.MasterLooter = nil

    if (UnitFrames.EditClassFeatures[T.MyClass]) then
        UnitFrames.EditClassFeatures[T.MyClass](self)
    end
end


local function EditTarget(self)
    EditPlayerTargetCommon(self)

    local Health = self.Health
    local Power = self.Power
    local CastBar = self.Castbar
    local OverlayFrame = self.OverlayFrame

    Health:Height(healthHeight)

    Power:SetScript("OnShow", function() Health:Height(healthHeight - powerHeight - BorderSize) end)
    Power:SetScript("OnHide", function() Health:Height(healthHeight) end)

    if Power.Value then
        Power.Value:Kill()
    end
    Power.Value = nil
    Power.PostUpdate = nil

    -- Castbar
    if (C.UnitFrames.UnlinkCastBar) then
        CastBar:Point("BOTTOM", UIParent, "CENTER", 0, 340)
    else
        CastBar:Point("TOP", self, "BOTTOM", 0, -ufSpacing)
    end
    if C.UnitFrames.CastBarIcon then
        CastBar.Icon:ClearAllPoints()
        CastBar.Icon:Size(36)
        CastBar.Icon:Point("BOTTOM", CastBar, "TOP", 0, 10)
    end

    -- Create new Name since we killed the panel
    local Name = OverlayFrame:CreateFontString(nil, "OVERLAY")
    Name:Point("LEFT", Health, "TOPLEFT", 2, 2)
    Name:SetJustifyH("LEFT")
    Name:SetFontObject(ufFont)
    Name:SetTextColor(.9,.9,.9)

    UnitFrames.UpdateNamePosition = DummyFcn

    if (C.UnitFrames.DarkTheme) then
        self:Tag(Name, "[Tukui:GetNameColor][Tukui:NameMedium] [Tukui:DiffColor][level] [shortclassification]")
    else
        self:Tag(Name, "[Tukui:NameMedium] [Tukui:DiffColor][level] [shortclassification]")
    end
    self.Name = Name

    -- Auras
    if (C.UnitFrames.TargetAuras) then
        local Buffs = self.Buffs
        local Debuffs = self.Debuffs
        local ComboPoints = self.ComboPointsBar

        Buffs:Point("BOTTOMLEFT", self, "TOPLEFT", 0, 6)
        Buffs:SetFrameLevel(self:GetFrameLevel())
        Buffs:Height(auraSize)
        Buffs:Width(ufWidth)
        Buffs.size = T.Scale(auraSize)
        Buffs.num = 24
        Buffs.numRow = aurasPerRow
        Buffs.spacing = T.Scale(ufSpacing)


        Debuffs:Point("BOTTOMLEFT", buffs, "TOPLEFT", 0, 1) -- until  UpdateDebuffsHeaderPosition changes it
        Debuffs:SetFrameLevel(self:GetFrameLevel())
        Debuffs:Height(auraSize)
        Debuffs:Width(ufWidth)
        Debuffs.size = T.Scale(auraSize)
        Debuffs.num = 24
        Debuffs.numRow = aurasPerRow
        Debuffs.Spacing = T.Scale(ufSpacing)

        -- Fix combo point scripts moving the buffs
        ComboPoints:SetScript("OnShow", function(self)
            UnitFrames.UpdateBuffsHeaderPosition(self, 15)
        end)
        ComboPoints:SetScript("OnHide", function(self)
            UnitFrames.UpdateBuffsHeaderPosition(self, 5)
        end)
    end
end

hooksecurefunc(UnitFrames, "Player", EditPlayer)
hooksecurefunc(UnitFrames, "Target", EditTarget)

-- Show target power bar for players with mana
function UnitFrames:CreateTargetPowerToggle(targetFrame)
    local targetPowerCheck = CreateFrame("Frame", nil, UIParent)
    targetPowerCheck.TargetFrame = targetFrame

    targetPowerCheck:SetScript("OnEvent", function(self, event, arg)
        if ((event == "PLAYER_TARGET_CHANGED" or arg == "target") and UnitIsPlayer("target")) then
            local class = UnitClass("target")
            pType, pToken = UnitPowerType("target")
            if (pType == 0 and not (class == "Mage" or class == "Warlock")) then
                self.TargetFrame.Power:Show()
            else
                self.TargetFrame.Power:Hide()
            end
        else
            self.TargetFrame.Power:Hide()
        end
    end)
    targetPowerCheck:RegisterEvent("UNIT_DISPLAYPOWER", togglepower)
    targetPowerCheck:RegisterEvent("PLAYER_TARGET_CHANGED", togglepower)
    targetPowerCheck:RegisterEvent("UNIT_MAXPOWER", togglepower)

    self.TargetPowerCheck = targetPowerCheck
end