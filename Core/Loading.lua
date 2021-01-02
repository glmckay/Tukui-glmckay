local T, C, L = unpack(Tukui)

local Loading = T["Loading"]

-- Load extra modules
local function OnEvent(self, event, addon)
    if (event == "PLAYER_LOGIN") then
        T["Panels"]:Enable()
    end

    Loading:OnEvent(event, addon)
end

Loading:SetScript("OnEvent", OnEvent)
