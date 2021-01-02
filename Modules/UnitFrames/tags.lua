local T, C, L = Tukui:unpack()

local Tags = T.UnitFrames.Tags
local TukuiShortValue = T.UnitFrames.ShortValue

Tags.Events["Tukui:PercHpNotAtMax"] = "UNIT_HEALTH"
Tags.Methods["Tukui:PercHpNotAtMax"] = function(unit)
    local hp = UnitHealth(unit)
    local max = UnitHealthMax(unit)
    if (hp ~= max) then
        if(max == 0) then
            return 0
        else
            return math.floor(hp / max * 100 + .5)
        end
    end
end
Tags.Events["Tukui:ShortMissingHp"] = "UNIT_HEALTH UNIT_MAXHEALTH"
Tags.Methods["Tukui:ShortMissingHp"] = function(unit)
    local missing = UnitHealthMax(unit) - UnitHealth(unit)
    if (missing > 0) then
        return TukuiShortValue(missing)
    end
end

Tags.Events["Tukui:CurrentPowerNonMana"] = "UNIT_POWER_FREQUENT UNIT_DISPLAYPOWER"
Tags.Methods["Tukui:CurrentPowerNonMana"] = function(unit)
    local pType = UnitPowerType(unit)
    if (pType ~= 0) then
        return UnitPower(unit)
    end
end