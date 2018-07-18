local T, C, L = Tukui:unpack()

local TukuiMedia = T["Media"]

C["Medias"].Font = C["Medias"].GNBold

C["Medias"].BoldFont = C["Medias"].GNBlack
C["Medias"].RegFont = C["Medias"].GNBold
C["Medias"].ThinFont = C["Medias"].GNMedium

-- Fonts
local SmallThinFont = CreateFont("SmallThin")
SmallThinFont:SetFont(C["Medias"].ThinFont, 14, "OUTLINE")

local SmallBoldFont = CreateFont("SmallBold")
SmallBoldFont:SetFont(C["Medias"].BoldFont, 12, "OUTLINE")

local NoOutlineRegularFont = CreateFont("NoOutlineRegular")
NoOutlineRegularFont:SetFont(C["Medias"].RegFont, 14)

local RegularFont = CreateFont("Regular")
RegularFont:SetFont(C["Medias"].RegFont, 16, "OUTLINE")

local ThinFont = CreateFont("Thin")
ThinFont:SetFont(C["Medias"].ThinFont, 16, "OUTLINE")

local BoldFont = CreateFont("Bold")
BoldFont:SetFont(C["Medias"].BoldFont, 16, "OUTLINE")

local LargeBoldFont = CreateFont("LargeBold")
LargeBoldFont:SetFont(C["Medias"].BoldFont, 20, "OUTLINE")

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
        media:Register("font", "Gotham Narrow Medium", C["Medias"]["GNMedium"])
        media:Register("font", "Gotham Narrow Bold", C["Medias"]["GNBold"])
        media:Register("font", "Gotham Narrow Black", C["Medias"]["GNBlack"])
        media:Register("font", "Gotham Narrow Ultra", C["Medias"]["GNUltra"])

        media:Register("statusbar", "Blank", C["Medias"]["Blank"])
        media:Register("statusbar", "Tukui", C["Medias"]["Normal"])

        MediaLoader:UnregisterAllEvents()
    end
end

MediaLoader:SetScript("OnEvent", RegisterSharedMedia)
MediaLoader:RegisterEvent("ADDON_LOADED")
RegisterSharedMedia()