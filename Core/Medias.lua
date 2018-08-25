local T, C, L = Tukui:unpack()

local TukuiMedia = T["Media"]

T["Media"]:RegisterTexture("GBlank", C["Medias"]["BlankGrey"])

C["Medias"].Font = C["Medias"].TekoMedium
C["Medias"].BoldFont = C["Medias"].TekoBold
C["Medias"].RegFont = C["Medias"].TekoSemiBold
C["Medias"].ThinFont = C["Medias"].TekoMedium
C["Medias"].VeryThinFont = C["Medias"].TekoRegular

C["Medias"].FontOffset = -3

-- Fonts
local SmallThinFont = CreateFont("SmallThin")
SmallThinFont:SetFont(C["Medias"].ThinFont, 16, "OUTLINE")

local SmallBoldFont = CreateFont("SmallBold")
SmallBoldFont:SetFont(C["Medias"].BoldFont, 14, "OUTLINE")

local NoOutlineRegularFont = CreateFont("NoOutlineRegular")
NoOutlineRegularFont:SetFont(C["Medias"].RegFont, 16)

local RegularFont = CreateFont("Regular")
RegularFont:SetFont(C["Medias"].RegFont, 20, "OUTLINE")

local ThinFont = CreateFont("Thin")
ThinFont:SetFont(C["Medias"].ThinFont, 20, "OUTLINE")

local BoldFont = CreateFont("Bold")
BoldFont:SetFont(C["Medias"].BoldFont, 20, "OUTLINE")

local LargeBoldFont = CreateFont("LargeBold")
LargeBoldFont:SetFont(C["Medias"].BoldFont, 24, "OUTLINE")

TukuiMedia:RegisterFont("Small Thin", "SmallThin")
TukuiMedia:RegisterFont("Small Bold", "SmallBold")
TukuiMedia:RegisterFont("NoOutline Regular", "NoOutlineRegular")
TukuiMedia:RegisterFont("Regular", "Regular")
TukuiMedia:RegisterFont("Thin", "Thin")
TukuiMedia:RegisterFont("Large Bold", "LargeBold")
TukuiMedia:RegisterFont("Bold", "Bold")


-- Register some stuff with sharedmedia if it gets loaded
local MediaLoader = CreateFrame("Frame", nil, UIParent)
local function RegisterSharedMedia()
    if (not LibStub) then return end
    local media = LibStub("LibSharedMedia-3.0", "silent")
    if (media) then
        media:Register("font", "Tukui-glmckay Thin", C["Medias"].ThinFont)
        media:Register("font", "Tukui-glmckay Thin", C["Medias"].ThinFont)
        media:Register("font", "Tukui-glmckay Regular", C["Medias"].RegFont)
        media:Register("font", "Tukui-glmckay Bold", C["Medias"].BoldFont)
        -- media:Register("font", "Gotham Narrow Medium", C["Medias"]["GNMedium"])
        -- media:Register("font", "Gotham Narrow Bold", C["Medias"]["GNBold"])
        -- media:Register("font", "Gotham Narrow Black", C["Medias"]["GNBlack"])
        -- media:Register("font", "Gotham Narrow Ultra", C["Medias"]["GNUltra"])

        -- media:Register("statusbar", "Blank", C["Medias"]["Blank"])
        media:Register("statusbar", "Tukui-glmckay", T.GetTexture(C["Textures"].General))

        MediaLoader:UnregisterAllEvents()
    end
end

MediaLoader:SetScript("OnEvent", RegisterSharedMedia)
MediaLoader:RegisterEvent("ADDON_LOADED")
RegisterSharedMedia()