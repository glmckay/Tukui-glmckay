local T, C, L = Tukui:unpack()

local MirrorTimers = T["Miscellaneous"].MirrorTimers

local function EditTimers(self)
    for i = 1, MIRRORTIMER_NUMTIMERS, 1 do
        local Bar = _G["MirrorTimer"..i]
        if not Bar.IsEdited then
            local Text = _G[Bar:GetName().."Text"]
            local Status = _G[Bar:GetName().."StatusBar"]

            Status:SetStatusBarTexture(T.GetTexture(C["Textures"].General))

            Text:SetFont(C["Medias"].RegFont, 16, "OUTLINE")
            Text:SetPoint("CENTER", Bar, "CENTER", 0, 0)

            Bar.IsEdited = true
        end
    end
end

hooksecurefunc(MirrorTimers, "Update", EditTimers)