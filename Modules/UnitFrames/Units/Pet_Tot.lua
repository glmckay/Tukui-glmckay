local T, C, L = Tukui:unpack()

local UnitFrames = T.UnitFrames
local DummyFcn = function() end

local ufFont = T.GetFont(C["UnitFrames"].Font)

UnitFrames.PetTotWidth = 80


local function EditPetTotCommon(self)
    local Health = self.Health

    self.Panel:Kill()
    self.Shadow:Kill()
    self:SetBackdrop(UnitFrames.SkinnedBackdrop)
    self:SetBackdropColor(0, 0, 0)

    -- Health
    Health:ClearAllPoints()
    Health:Point("TOPLEFT", self)
    Health:Point("BOTTOMRIGHT", self)

    -- Create new Name since we killed the panel
    local Name = Health:CreateFontString(nil, "OVERLAY")
    Name:Point("CENTER", Health, "TOP", 0, 2)
    Name:SetJustifyH("LEFT")
    Name:SetFontObject(ufFont)

    UnitFrames.UpdateNamePosition = DummyFcn

    if (C.UnitFrames.DarkTheme) then
        self:Tag(Name, "[Tukui:GetNameColor][Tukui:NameShort]")
    else
        self:Tag(Name, "[Tukui:NameShort]")
    end
    self.Name = Name

    if C.UnitFrames.DarkTheme then
        Health:SetStatusBarColor(.25, .25, .25)
    end
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