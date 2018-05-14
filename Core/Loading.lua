local T, C, L = unpack(Tukui)

local Loading = T.Loading

Loading.OldOnEvent = Loading.OnEvent

function Loading:OnEvent(event, addon)
    self:OldOnEvent(event, addon)
    if (event == "PLAYER_LOGIN") then
        if (C.ActionBars.Enable) then
            T["ActionBars"]:EnableEdits()
        end

        T["Maps"]["Minimap"]:EnableEdits()

        if (C.UnitFrames.Enable) then
            T["UnitFrames"]:EnableEdits()
        end

        if (C.AuraTimers.Enable) then
            T["AuraTimers"]:Enable()
        end
    end
end

Loading:SetScript("OnEvent", Loading.OnEvent)

