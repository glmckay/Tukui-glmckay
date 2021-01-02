local T, C, L = Tukui:unpack()

local TukuiMedia = T["Media"]

local Mult = T.Toolkit.Functions.Scale(1)

T["Media"]:RegisterTexture("GBlank", C["Medias"]["BlankGrey"])
T["Media"]:RegisterTexture("Gradient", C["Medias"]["Melli"])


C["Medias"].BoldFont = C["Medias"].BarlowExBold
C["Medias"].RegFont = C["Medias"].BarlowBold
C["Medias"].ThinFont = C["Medias"].BarlowSemiBold
C["Medias"].VeryThinFont = C["Medias"].BarlowMedium

C["Medias"].BoldFontCond = C["Medias"].BarlowCondExBold
C["Medias"].RegFontCond = C["Medias"].BarlowCondBold
C["Medias"].ThinFontCond = C["Medias"].BarlowCondSemiBold
C["Medias"].VeryThinFontCond = C["Medias"].BarlowCondMedium

C["Medias"].Font = C["Medias"].RegFontCond


-- Fonts
local SmallThinFont = CreateFont("SmallThin")
SmallThinFont:SetFont(C["Medias"].RegFont, 14, "OUTLINE")
SmallThinFont:SetShadowColor(0,0,0)
SmallThinFont:SetShadowOffset(1,-1)

local SmallBoldFont = CreateFont("SmallBold")
SmallBoldFont:SetFont(C["Medias"].RegFontCond, 12, "OUTLINE")
SmallBoldFont:SetShadowColor(0,0,0)
SmallBoldFont:SetShadowOffset(1,-1)


local RegularFont = CreateFont("Regular")
RegularFont:SetFont(C["Medias"].RegFont, 20, "OUTLINE")

local ThinFont = CreateFont("Thin")
ThinFont:SetFont(C["Medias"].ThinFont, 14, "OUTLINE")
ThinFont:SetShadowColor(0,0,0)
ThinFont:SetShadowOffset(1,-1)

local BoldFont = CreateFont("Bold")
BoldFont:SetFont(C["Medias"].RegFont, 15, "OUTLINE")
BoldFont:SetShadowColor(0,0,0)
BoldFont:SetShadowOffset(Mult,-Mult)

local LargeBoldFont = CreateFont("LargeBold")
LargeBoldFont:SetFont(C["Medias"].BoldFont, 20, "OUTLINE")
LargeBoldFont:SetShadowColor(0,0,0)
LargeBoldFont:SetShadowOffset(Mult,-Mult)

local DataTextFont = CreateFont("DataText")
DataTextFont:SetFont(C["Medias"].RegFontCond, 16)

local UFFont = CreateFont("UnitFrame")
UFFont:SetFont(C["Medias"].ThinFont, 15, "OUTLINE")
UFFont:SetShadowColor(0,0,0)
UFFont:SetShadowOffset(Mult,-Mult)

local SmallUFFont = CreateFont("SmallUnitFrame")
SmallUFFont:SetFont(C["Medias"].ThinFont, 13, "OUTLINE")
SmallUFFont:SetShadowColor(0,0,0)
SmallUFFont:SetShadowOffset(Mult,-Mult)

local CDFont = CreateFont("Cooldown")
CDFont:SetFont(C["Medias"].BoldFont, 16, "OUTLINE")
CDFont:SetShadowColor(0,0,0)
CDFont:SetShadowOffset(Mult,-Mult)

local ChatFont = CreateFont("Chat")
ChatFont:SetFont(C["Medias"].RegFont, 13, "OUTLINE")
ChatFont:SetShadowColor(0,0,0)
ChatFont:SetShadowOffset(Mult,-Mult)


TukuiMedia:RegisterFont("Small Thin", "SmallThin")
TukuiMedia:RegisterFont("Small Bold", "SmallBold")
TukuiMedia:RegisterFont("Regular", "Regular")
TukuiMedia:RegisterFont("Thin", "Thin")
TukuiMedia:RegisterFont("Large Bold", "LargeBold")
TukuiMedia:RegisterFont("Bold", "Bold")

TukuiMedia:RegisterFont("UnitFrame", "UnitFrame")
TukuiMedia:RegisterFont("Cooldown", "Cooldown")
TukuiMedia:RegisterFont("DataText", "DataText")
TukuiMedia:RegisterFont("Chat", "Chat")
TukuiMedia:RegisterFont("Small UnitFrame", "SmallUnitFrame")


-- Register some stuff with sharedmedia if it gets loaded
local MediaLoader = CreateFrame("Frame", nil, UIParent)
local function RegisterSharedMedia()
    if (not LibStub) then return end
    local media = LibStub("LibSharedMedia-3.0", "silent")
    if (media) then
        media:Register("font", "Tukui-glmckay Very Thin ", C["Medias"].VeryThinFont)
        media:Register("font", "Tukui-glmckay Thin", C["Medias"].ThinFont)
        media:Register("font", "Tukui-glmckay Regular", C["Medias"].RegFont)
        media:Register("font", "Tukui-glmckay Bold", C["Medias"].BoldFont)

        media:Register("font", "Tukui-glmckay Very Thin (Cond.)", C["Medias"].VeryThinFontCond)
        media:Register("font", "Tukui-glmckay Thin (Cond.)", C["Medias"].ThinFontCond)
        media:Register("font", "Tukui-glmckay Regular (Cond.)", C["Medias"].RegFontCond)
        media:Register("font", "Tukui-glmckay Bold (Cond.)", C["Medias"].BoldFontCond)

        media:Register("statusbar", "Tukui-glmckay", T.GetTexture(C["Textures"].General))

        MediaLoader:UnregisterAllEvents()
    end
end

MediaLoader:SetScript("OnEvent", RegisterSharedMedia)
MediaLoader:RegisterEvent("ADDON_LOADED")
RegisterSharedMedia()