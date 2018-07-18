local T, C, L = Tukui:unpack()

local TukuiColors = T["Colors"]

local function CopyBlizzColor(tukuiColor, blizzColor)
    tukuiColor[1] = blizzColor.r
    tukuiColor[2] = blizzColor.g
    tukuiColor[3] = blizzColor.b
end


for Class,Color in pairs(TukuiColors["class"]) do
    CopyBlizzColor(Color, RAID_CLASS_COLORS[Class])
end

CopyBlizzColor(TukuiColors["power"]["ENERGY"], PowerBarColor["ENERGY"])

-- Stagger
TukuiColors["power"]["STAGGER"] = { {0,0,0}, {0,0,0}, {0,0,0} }
for i = 1,3 do
    CopyBlizzColor(TukuiColors["power"]["STAGGER"][i], PowerBarColor["STAGGER"][i])
end

-- DK runes
TukuiColors["runes"]["CD"] = TukuiColors["runes"]["READY"]
TukuiColors["runes"]["READY"] = TukuiColors["power"]["RUNIC_POWER"]