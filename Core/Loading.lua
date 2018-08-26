local T, C, L = unpack(Tukui)

-- Load extra modules
local function OnEvent(self, event, addon)
    if (event == "PLAYER_LOGIN") then
        if (C.AuraTimers.Enable) then
            T["AuraTimers"]:Enable()
        end
    end
end

T["Loading"]:HookScript("OnEvent", OnEvent)
