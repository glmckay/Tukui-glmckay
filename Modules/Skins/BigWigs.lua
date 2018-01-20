local T, C, L = Tukui:unpack()

local borderSize = C.General.BorderSize

local BarBackdrop = {
    bgFile = C.Medias.Blank,
    insets = { top =    -T.Scale(borderSize),
               left =   -T.Scale(borderSize),
               bottom = -T.Scale(borderSize),
               right =  -T.Scale(borderSize) },
}

local function StyleBar(bar)
    bar:Height(18)

    local bd = bar.candyBarBackdrop

    bd:SetBackdrop(BarBackdrop)
    bd:SetBackdropColor(0, 0, 0)
    bd:SetAllPoints()
    bd:Show()

    if (bar.candyBarIconFrame) then
        local icon = bar.candyBarIconFrame
        local tex = icon.icon
        bar:SetIcon(nil)
        icon:SetTexture(tex)
        icon:ClearAllPoints()
        icon:SetPoint("RIGHT", bar, "LEFT", -5, 0)
        icon:SetSize(bar:GetHeight(), bar:GetHeight())
        bar:Set("bigwigs:restoreicon", tex)

        local iconBd = bar.candyBarIconFrameBackdrop
        iconBd:SetBackdrop(BarBackdrop)
        iconBd:SetBackdropColor(.1, .1, .1, 1)
        iconBd:SetBackdropBorderColor(0, 0, 0, 1)

        iconBd:SetAllPoints(icon)
        iconBd:Show()
    end
end

local f = CreateFrame("Frame")
local function registerMyStyle()
    if not BigWigs then return end
    local bars = BigWigs:GetPlugin("Bars", true)
    if not bars then return end
    f:UnregisterEvent("ADDON_LOADED")
    f:UnregisterEvent("PLAYER_LOGIN")
    bars:RegisterBarStyle("identifier", {
        apiVersion = 1,
        version = 1,
        GetSpacing = function(bar) return 5 end,
        ApplyStyle = StyleBar,
        BarStopped = function(bar) end,
        GetStyleName = function() return "My Style" end,
    })
end
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_LOGIN")

local reason = nil
f:SetScript("OnEvent", function(self, event, msg)
    if event == "ADDON_LOADED" then
        if not reason then reason = (select(6, GetAddOnInfo("BigWigs_Plugins"))) end
        if (reason == "MISSING" and msg == "BigWigs") or msg == "BigWigs_Plugins" then
            registerMyStyle()
        end
    elseif event == "PLAYER_LOGIN" then
        registerMyStyle()
    end
end)