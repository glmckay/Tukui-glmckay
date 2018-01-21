local T, C, L = Tukui:unpack()

local UnitFrames = T["UnitFrames"]
local oUF = oUF or Tukui.oUF
local PriestColor = oUF.colors.class["PRIEST"]

if (T.MyClass ~= "PRIEST") then
    return
end

UnitFrames.EditClassFeatures["PRIEST"] = function(self)
    if (C.UnitFrames.UnlinkPower) then
        -- I don't like the priest color on the center power bar
        self.Power.colorClass = false
        self.Power.colorPower = true
        self.Power.ExtraValue:SetTextColor(PriestColor[1], PriestColor[2], PriestColor[3])
        self.Power.ExtraValue.SetTextColor = function() end
    end
end