local T, C, L = Tukui:unpack()

local TukuiMedia = T["Media"]

local Express11 = CreateFont("Express11")
Express11:SetFont(C["Medias"].Express, 11, "THINOUTLINE")

local Express12 = CreateFont("Express12")
Express12:SetFont(C["Medias"].Express, 12, "THINOUTLINE")

local Express13 = CreateFont("Express13")
Express13:SetFont(C["Medias"].Express, 13, "THINOUTLINE")

TukuiMedia:RegisterFont("Express 11", "Express11")
TukuiMedia:RegisterFont("Express 12", "Express12")
TukuiMedia:RegisterFont("Express 13", "Express13")


-- Register some stuff with sharedmedia if it gets loads
local MediaLoader = CreateFrame("Frame", nil, UIParent)
local function RegisterSharedMedia()
    if (not LibStub) then return end
    local media = LibStub("LibSharedMedia-3.0")
    if (media) then
        media:Register("font", "Expressway", C["Medias"]["Express"])
        media:Register("statusbar", "Blank", C["Medias"]["Blank"])
        MediaLoader:UnregisterAllEvents()
    end
end

MediaLoader:RegisterEvent("ADDON_LOADED")
MediaLoader:SetScript("OnEvent", RegisterSharedMedia)
RegisterSharedMedia()