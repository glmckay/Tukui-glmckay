local T, C, L = Tukui:unpack()

local MirrorTimers = T["Miscellaneous"].MirrorTimers

local function EditTimers(self)
    for i = 1, MIRRORTIMER_NUMTIMERS, 1 do
        local Bar = _G["MirrorTimer"..i]
        if not Bar.isTextEdited then
            local Text = _G[Bar:GetName().."Text"]

            Text:SetFont(C["Medias"].RegFont, 14, "OUTLINE")

            Bar.isTextEdited = true
        end
    end
end

hooksecurefunc(MirrorTimer, "Update", EditTimers)