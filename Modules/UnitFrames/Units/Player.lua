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


local function EditPlayer(self)

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
    Health:SetPoint("TOPLEFT", self, BorderSize, -BorderSize)
    Health:SetPoint("TOPRIGHT", self, -BorderSize, -BorderSize)
    Health:SetHeight(HealthHeight - AdditionalPowerHeight - BorderSize)

    Health.Background:Kill()

    Health.Value:SetParent(OverlayFrame)
    Health.Value:SetFontObject(NumberFont)
    Health.Value:ClearAllPoints()
    Health.Value:SetPoint("RIGHT", Health, "RIGHT", -2, 0)

    -- Power
    Power:SetWidth(CenterBarWidth)
    Power:CreateBackdrop()
    Power.Backdrop:SetOutside(Power)
    Power.Background:Kill()

    -- Power.Value:SetParent(OverlayFrame)
    Power.Value:SetFontObject(BigNumberFont)
    Power.Value:ClearAllPoints()
    Power.Value:SetPoint("CENTER", Power, "TOP", 0, 0)
    Power.PostUpdate = nil

    Power:SetScript("OnShow", function()
        Power.Value:UpdateTag()
    end)

    Power.Prediction:SetWidth(FrameWidth - 2*BorderSize)


    RegisterStateDriver(Power, "visibility", "[combat][mod:shift]show;hide")

    -- AdditionalPower
    AdditionalPower:ClearAllPoints()
    AdditionalPower:SetHeight(AdditionalPowerHeight)
    AdditionalPower:SetPoint("BOTTOMLEFT", self, BorderSize, BorderSize)
    AdditionalPower:SetPoint("BOTTOMRIGHT", self, -BorderSize, BorderSize)

    -- Repurpose the background as a border between the health and additional power bars
    AdditionalPower.Background:ClearAllPoints()
    AdditionalPower.Background:SetSize(FrameWidth, BorderSize)
    AdditionalPower.Background:SetPoint("BOTTOM", AdditionalPower, "TOP")
    AdditionalPower.Background:SetColorTexture(unpack(C.General.BorderColor))

    -- Fix health height when shown/hidden
    AdditionalPower:SetScript("OnShow", function()
        Health:SetHeight(HealthHeight - AdditionalPowerHeight - BorderSize)
    end)
    AdditionalPower:SetScript("OnHide", function()
        Health:SetHeight(HealthHeight)
    end)

    self.AdditionalPower = AdditionalPower

    -- CastBar
    CastBar:SetWidth(CenterBarWidth)
    CastBar:CreateBackdrop()
    CastBar.Backdrop:SetOutside()
    CastBar.Background:Kill()

    CastBar:ClearAllPoints()
    if (C.UnitFrames.UnlinkCastBar) then
        CastBar:SetPoint("TOP", Panels.UnitFrameAnchor, "TOP", 0, -BorderSize)
        CastBar:SetSize(CenterBarWidth, MeleeCastBarHeight)
        CastBar:SetFrameLevel(Power:GetFrameLevel())
    else
        CastBar:SetPoint("TOP", self, "BOTTOM", 0, -FrameSpacing)
    end

    if (C.UnitFrames.CastBarIcon) then
        CastBar.Icon:Kill()
        CastBar.Button:Kill()
    end

    CastBar.Time:SetFontObject(NumberFont)
    CastBar.Time:ClearAllPoints()
    CastBar.Time:SetPoint("RIGHT", CastBar, "RIGHT", -2, 0)

    CastBar.Text:SetFontObject(NumberFont)


    if (C.UnitFrames.HealBar) then
        local HealthPrediction = self.HealthPrediction

        for name,bar in pairs(HealthPrediction) do
            if (name ~= 'maxOverflow') then
                bar:SetFrameLevel(Health:GetFrameLevel())
                bar:SetWidth(FrameWidth - 2*BorderSize)
            end
        end
    end

    Combat:ClearAllPoints()
    Combat:SetPoint("CENTER", Health, "CENTER")
    Combat:SetSize(24, 24)
    Combat:SetVertexColor(1, 1, 1)

    self.LeaderIndicator:Kill()
    self.LeaderIndicator = nil

    self.MasterLooterIndicator:Kill()
    self.MasterLooterIndicator = nil

    self:Tag(Power.Value, C.UnitFrames.PlayerPowerTag.Value)

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
        Power:SetHeight(RangedPowerHeight)
        Power:SetPoint("BOTTOM", Panels.UnitFrameAnchor, "BOTTOM", 0, BorderSize)

        CenterActionBars[1]:ClearAllPoints()
        CenterActionBars[1]:SetPoint("TOP",Panels.UnitFrameAnchor, "BOTTOM", 0, -(BorderSize + FrameSpacing))

        CastBar:ClearAllPoints()
        CastBar:SetHeight(RangedCastBarHeight)
        CastBar:SetPoint("TOP", Panels.UnitFrameAnchor, "TOP", 0, -BorderSize)

        CastBar.Text:ClearAllPoints()
        CastBar.Text:SetHeight(CastBar:GetHeight())
        CastBar.Text:SetPoint("LEFT", CastBar, "LEFT", 2, 0)
        CastBar.Text:SetWidth(CenterBarWidth - 80)
        CastBar.Text:SetJustifyH("LEFT")

        CastBar.Time:Show()
    else
        Power:ClearAllPoints()
        Power:SetHeight(MeleePowerHeight)
        Power:SetPoint("TOP", Panels.UnitFrameAnchor, 0, -(MeleePowerHeight + 3*BorderSize + FrameSpacing))

        CenterActionBars[1]:ClearAllPoints()
        CenterActionBars[1]:SetPoint("TOP", Power, "BOTTOM", 0, -(BorderSize + FrameSpacing))

        CastBar:ClearAllPoints()
        CastBar:SetHeight(MeleeCastBarHeight)
        CastBar:SetPoint("TOP", CenterActionBars[2], "BOTTOM", 0, -(FrameSpacing + BorderSize))

        CastBar.Text:ClearAllPoints()
        CastBar.Text:SetHeight(10)
        CastBar.Text:SetPoint("RIGHT", CastBar, "RIGHT", -2, 0)
        CastBar.Text:SetPoint("LEFT", CastBar, "LEFT", 2, 0)
        CastBar.Text:SetPoint("TOP", CastBar, "CENTER", 0, 0)
        CastBar.Text:SetJustifyH("CENTER")

        CastBar.Time:Hide()
    end

    if (TukuiUF.EditClassProfile[T.MyClass]) then
        TukuiUF.EditClassProfile[T.MyClass](Player, isRanged)
    end
end

hooksecurefunc(TukuiUF, "Player", EditPlayer)
