local T, C, L = Tukui:unpack()

local Miscellaneous = T["Miscellaneous"]
local Movers = T["Movers"]

-- A bunch of small changes to miscellaneous Tukui things

local AltPowerBar = Miscellaneous.AltPowerBar

local function EditBar(self)
    self.Status:SetStatusBarTexture(T.GetTexture(C["Textures"].General))
end

hooksecurefunc(AltPowerBar, "Create", EditBar)

