local T, C, L = Tukui:unpack()

local TukuiUF = T.UnitFrames
local Noop = function() end

local NameFont = T.GetFont(C["UnitFrames"].Font)


local function EditPetTotCommon(self)
    local Health = self.Health

    -- Health
    Health:ClearAllPoints()
    Health:SetInside(self)

    Health.Background:Kill()
    Health.bg = nil

    -- Power
    if (self.Power) then
        self.Power:Kill()
        self.Power = nil
    end

    -- Create new Name since we killed the panel
    local Name = Health:CreateFontString(nil, "OVERLAY")
    Name:SetPoint("CENTER", Health, "CENTER", 0, 0)
    Name:SetJustifyH("CENTER")
    Name:SetFontObject(NameFont)

    if (C.UnitFrames.DarkTheme) then
        Health:SetStatusBarColor(.25, .25, .25)
        self:Tag(Name, "[Tukui:GetNameColor][Tukui:NameShort]")
    else
        self:Tag(Name, "[Tukui:NameShort]")
    end
    self.Name = Name

    local RaidIcon = self.RaidTargetIndicator
    RaidIcon:ClearAllPoints()
    RaidIcon:SetPoint("CENTER", self, "TOP", 0, 0)
end

hooksecurefunc(TukuiUF, "TargetOfTarget", EditPetTotCommon)
hooksecurefunc(TukuiUF, "Pet", EditPetTotCommon)
