local T, C, L = unpack(Tukui)

local Loading = T.Loading

-- Loading.OldOnEvent = Loading.OnEvent

-- Load extra modules
local function OnEvent(event, addon)
    self:OldOnEvent(event, addon)
    if (event == "PLAYER_LOGIN") then

        if (C.AuraTimers.Enable) then
            T["AuraTimers"]:Enable()
        end

    end
end

hooksecurefunc(Loading, "OnEvent", OnEvent)

-- Loading:SetScript("OnEvent", Loading.OnEvent)


