local T, C, L = Tukui:unpack()

local UnitFrames = T.UnitFrames
local DummyFcn = function() end

local NameFont = T.GetFont(C["UnitFrames"].Font)

UnitFrames.PetTotWidth = 90


local function EditPetTotCommon(self)
    local Health = self.Health

    self.Panel:Kill()
    self:SetTemplate()
    self:SetBackdropColor(0, 0, 0)

    -- Health
    Health:ClearAllPoints()
    Health:SetInside(self)

    -- Create new Name since we killed the panel
    local Name = Health:CreateFontString(nil, "OVERLAY")
    Name:Point("CENTER", Health, "CENTER", 0, 0)
    Name:SetJustifyH("CENTER")
    Name:SetFontObject(NameFont)

    UnitFrames.UpdateNamePosition = DummyFcn

    if (C.UnitFrames.DarkTheme) then
        Health:SetStatusBarColor(.25, .25, .25)
        self:Tag(Name, "[Tukui:GetNameColor][Tukui:NameShort]")
    else
        self:Tag(Name, "[Tukui:NameShort]")
    end
    self.Name = Name

    local RaidIcon = self.RaidIcon
    RaidIcon:ClearAllPoints()
    RaidIcon:Point("CENTER", self, "BOTTOM", 0, 12)

end


local function EditTargetOfTarget(self)
    EditPetTotCommon(self)
end


local function EditPet(self)
    EditPetTotCommon(self)

    local Power = self.Power
    -- Power
    if (Power) then
        self.Power = nil
        Power:Kill()
    end
end


hooksecurefunc(UnitFrames, "TargetOfTarget", EditTargetOfTarget)
hooksecurefunc(UnitFrames, "Pet", EditPet)