local T, C, L = Tukui:unpack()

local TukuiMedia = T["Media"]

-- Textures
TukuiMedia:RegisterTexture("CaithTex", C["Medias"]["CaithTex"])

-- Fonts
local ExpressSmall = CreateFont("ExpressSmall")
ExpressSmall:SetFont(C["Medias"].ExpressBold, 12, "OUTLINE")

local TextFont = CreateFont("TextFont")
TextFont:SetFont(C["Medias"].ExpressBold, 16, "OUTLINE")

local ThinFont = CreateFont("ThinFont")
ThinFont:SetFont(C["Medias"].ExpressRegular, 16, "OUTLINE")

local NumberFont = CreateFont("NumberFont")
NumberFont:SetFont(C["Medias"].ExpressExtraBold, 16, "OUTLINE")

local BigNumberFont = CreateFont("BigNumberFont")
BigNumberFont:SetFont(C["Medias"].ExpressExtraBold, 22, "OUTLINE")

TukuiMedia:RegisterFont("Express Small", "ExpressSmall")
TukuiMedia:RegisterFont("Text Font", "TextFont")
TukuiMedia:RegisterFont("Thin Font", "ThinFont")
TukuiMedia:RegisterFont("Big Number", "BigNumberFont")
TukuiMedia:RegisterFont("Number", "NumberFont")


local Roboto11 = CreateFont("Roboto11")
Roboto11:SetFont(C["Medias"].RobotoCondBold, 11, "THINOUTLINE")

local Roboto12 = CreateFont("Roboto12")
Roboto12:SetFont(C["Medias"].RobotoCondBold, 12, "THINOUTLINE")

local Roboto13 = CreateFont("Roboto13")
Roboto13:SetFont(C["Medias"].RobotoCondBold, 13, "THINOUTLINE")

local Roboto14 = CreateFont("Roboto14")
Roboto14:SetFont(C["Medias"].RobotoCondBold, 14, "THINOUTLINE")

local Roboto20 = CreateFont("Roboto20")
Roboto20:SetFont(C["Medias"].RobotoCondBold, 20, "THINOUTLINE")


TukuiMedia:RegisterFont("Roboto 11", "Roboto11")
TukuiMedia:RegisterFont("Roboto 12", "Roboto12")
TukuiMedia:RegisterFont("Roboto 13", "Roboto13")
TukuiMedia:RegisterFont("Roboto 14", "Roboto14")
TukuiMedia:RegisterFont("Roboto 20", "Roboto20")


-- Register some stuff with sharedmedia if it gets loaded
local MediaLoader = CreateFrame("Frame", nil, UIParent)
local function RegisterSharedMedia()
    if (not LibStub) then return end
    local media = LibStub("LibSharedMedia-3.0", "silent")
    if (media) then
        media:Register("font", "Roboto Cond", C["Medias"]["RobotoCond"])
        media:Register("font", "Roboto Cond Bold", C["Medias"]["RobotoCondBold"])

        media:Register("statusbar", "Blank", C["Medias"]["Blank"])

        MediaLoader:UnregisterAllEvents()
    end
end

MediaLoader:SetScript("OnEvent", RegisterSharedMedia)
MediaLoader:RegisterEvent("ADDON_LOADED")
RegisterSharedMedia()