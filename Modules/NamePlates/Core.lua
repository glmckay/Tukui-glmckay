local T, C, L = unpack(Tukui)

local Nameplates = T["NamePlates"]

local function EditPlate(self, options)
    local HealthBar = self.healthBar
    local Name = self.name

    HealthBar:CreateBackdrop()
    Name:SetShadowColor(0, 0, 0)
end

hooksecurefunc(Nameplates, "SetupPlate", EditPlate)
