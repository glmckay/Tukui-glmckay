local T, C, L = Tukui:unpack()

local Panels = T["Panels"]
local TukuiUF = T["UnitFrames"]

-- Localised globals
local UnitPowerType = UnitPowerType
local UnitIsGhost = UnitIsGhost
local UnitIsDead = UnitIsDead
local ShortValue = TukuiUF.ShortValue

TukuiUF.EditClassProfile = {}

local BigNumberFont = T.GetFont(C["UnitFrames"].BigNumberFont)
local NumberFont = T.GetFont(C["UnitFrames"].NumberFont)

local BorderSize = C.General.BorderSize
local FrameSpacing = C.General.FrameSpacing

local FrameWidth = TukuiUF.PlayerTargetWidth
local FrameHeight = TukuiUF.FrameHeight
local CenterBarWidth = Panels.CenterPanelWidth - 2*BorderSize
local HealthHeight = FrameHeight - 2*BorderSize
local MeleePowerHeight = 9
local RangedPowerHeight = 7
local AdditionalPowerHeight = TukuiUF.PowerHeight
local MeleeCastBarHeight = 14
local RangedCastBarHeight = FrameHeight - RangedPowerHeight - 4*BorderSize - FrameSpacing


local function PlayerPostUpdatePower(self, unit, min, max)
    local pType, pToken = UnitPowerType(unit)

    if (UnitIsDead(unit) or UnitIsGhost(unit)) then
        self.Value:SetText()
        if (self.ExtraValue) then self.ExtraValue:SetText() end
    else
        if (pType == 0) then -- mana
            local value = ShortValue(min)
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


local function EditPlayer(self)
    self.Panel:Kill()
    self:SetTemplate()

    local Health = self.Health
    local Power = self.Power
    local AdditionalPower = self.AdditionalPower
    local CastBar = self.Castbar
    local Combat = self.CombatIndicator

    -- Frame to overlay text above heal prediction
    local OverlayFrame = CreateFrame("Frame", nil, self)
    OverlayFrame:SetAllPoints()
    OverlayFrame:SetFrameStrata(self:GetFrameStrata())
    OverlayFrame:SetFrameLevel(Health:GetFrameLevel() + 3)
    self.OverlayFrame = OverlayFrame

    -- Health
    Health:ClearAllPoints()
    Health:Point("TOPLEFT", self, BorderSize, -BorderSize)
    Health:Point("TOPRIGHT", self, -BorderSize, -BorderSize)
    Health:Height(HealthHeight - AdditionalPowerHeight - BorderSize)

    Health.Background:Kill()

    Health.Value:SetParent(OverlayFrame)
    Health.Value:SetFontObject(NumberFont)
    Health.Value:ClearAllPoints()
    Health.Value:Point("RIGHT", Health, "RIGHT", -2, 0)

    Health.Percent = OverlayFrame:CreateFontString(nil, "OVERLAY")
    Health.Percent:SetFontObject(BigNumberFont)
    Health.Percent:Point("LEFT", Health, "TOPLEFT", 2, 0)

    Health.PostUpdate = TukuiUF.PlayerTargetPostUpdateHealth

    -- Power
    Power:Width(CenterBarWidth)
    Power:CreateBackdrop()
    Power.Background:Kill()

    Power.Value:SetParent(OverlayFrame)
    Power.Value:SetFontObject(NumberFont)
    Power.Value:ClearAllPoints()
    Power.Value:Point("BOTTOMLEFT", self, "BOTTOMLEFT", 2, 1)
    Power.PostUpdate = PlayerPostUpdatePower

    Power.Prediction:Width(FrameWidth - 2*BorderSize)

    -- Create a new string for the detached power bar (the usual string will stay on the frame when out of combat)
    Power.ExtraValue = Power:CreateFontString(nil, "OVERLAY")
    Power.ExtraValue:SetFontObject(BigNumberFont)
    Power.ExtraValue:Point("CENTER", Power, "TOP", 0, 0)

    Power.Value:SetParent(OverlayFrame)

    RegisterStateDriver(Power, "visibility", "[combat][mod:shift]show;hide")
    Power:SetScript("OnShow", function() Power.Value:Hide() end)
    Power:SetScript("OnHide", function() Power.Value:Show() end)

    -- AdditionalPower
    AdditionalPower:SetBackdrop({})
    AdditionalPower:ClearAllPoints()
    AdditionalPower:Height(AdditionalPowerHeight)
    AdditionalPower:Point("BOTTOMLEFT", self, BorderSize, BorderSize)
    AdditionalPower:Point("BOTTOMRIGHT", self, -BorderSize, BorderSize)

    -- Repurpose the background as a border between the health and additional power bars
    AdditionalPower.Background:ClearAllPoints()
    AdditionalPower.Background:Size(FrameWidth, BorderSize)
    AdditionalPower.Background:Point("BOTTOM", AdditionalPower, "TOP")
    AdditionalPower.Background:SetColorTexture(unpack(C.General.BorderColor))

    -- Fix health height when shown/hidden
    AdditionalPower:SetScript("OnShow", function()
        Health:Height(HealthHeight - AdditionalPowerHeight - BorderSize)
    end)
    AdditionalPower:SetScript("OnHide", function()
        Health:Height(HealthHeight)
    end)

    -- CastBar
    CastBar:Width(CenterBarWidth)
    CastBar:SetBackdrop({})
    CastBar:CreateBackdrop()
    CastBar.Background:Kill()

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

    CastBar.Time:SetFontObject(NumberFont)
    CastBar.Time:ClearAllPoints()
    CastBar.Time:Point("RIGHT", CastBar, "RIGHT", -2, 0)

    CastBar.Text:SetFontObject(NumberFont)


    if (C.UnitFrames.HealBar) then
        local HealthPrediction = self.HealthPrediction

        for name,bar in pairs(HealthPrediction) do
            if (name ~= 'maxOverflow') then
                bar:SetFrameLevel(Health:GetFrameLevel())
                bar:Width(FrameWidth - 2*BorderSize)
            end
        end
    end

    Combat:ClearAllPoints()
    Combat:Point("CENTER", Health, "CENTER")
    Combat:Size(24)
    Combat:SetVertexColor(1, 1, 1)

    self.LeaderIndicator:Kill()
    self.LeaderIndicator = nil

    self.MasterLooterIndicator:Kill()
    self.MasterLooterIndicator = nil

    if (TukuiUF.EditClassFeatures[T.MyClass]) then
        TukuiUF.EditClassFeatures[T.MyClass](self)
    end
end



-- Some spec specific settings for the Player frame
function TukuiUF:SetPlayerProfile(role, isRanged)
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
        CastBar.Text:SetHeight(CastBar:GetHeight())
        CastBar.Text:Point("LEFT", CastBar, "LEFT", 2, 0)
        CastBar.Text:SetWidth(CenterBarWidth - 80)
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
        CastBar.Text:Point("TOP", CastBar, "CENTER", 0, 0)
        CastBar.Text:SetJustifyH("CENTER")

        CastBar.Time:Hide()
    end

    if (TukuiUF.EditClassProfile[T.MyClass]) then
        TukuiUF.EditClassProfile[T.MyClass](Player, isRanged)
    end
end

hooksecurefunc(TukuiUF, "Player", EditPlayer)
