local T, C, L = Tukui:unpack()
local barPlugin = nil


local BorderSize = C.General.BorderSize
local FrameSpacing = C.General.FrameSpacing


local function RemoveStyle(bar)
    bar.candyBarBackdrop:Hide()

    local tex = bar:Get("bigwigs:restoreicon")
    if tex then
        local icon = bar.candyBarIconFrame
        icon:ClearAllPoints()
        icon:SetPoint("TOPLEFT")
        icon:SetPoint("BOTTOMLEFT")
        bar:SetIcon(tex)

        bar.candyBarIconFrameBackdrop:Hide()
    end

    bar.candyBarDuration:ClearAllPoints()
    bar.candyBarDuration:SetPoint("TOPLEFT", bar.candyBarBar, "TOPLEFT", 2, -1)
    bar.candyBarDuration:SetPoint("BOTTOMRIGHT", bar.candyBarBar, "BOTTOMRIGHT", -2, -1)

    bar.candyBarLabel:ClearAllPoints()
    bar.candyBarLabel:SetPoint("TOPLEFT", bar.candyBarBar, "TOPLEFT", 2, 0)
    bar.candyBarLabel:SetPoint("BOTTOMRIGHT", bar.candyBarBar, "BOTTOMRIGHT", -2, 0)
end

local function StyleBar(bar)

    if bar:IsForbidden() then
        return
    end

    local Backdrop = bar.candyBarBackdrop
    local Icon = bar.candyBarIconFrame

    Backdrop:SetOutside(bar)
    -- Backdrop:SetTemplate()
    Backdrop:Show()

    local Tex = Icon.icon
    bar:SetIcon(nil)
    Icon:SetTexture(Tex)
    Icon:Show()
    Icon:ClearAllPoints()
    Icon:SetPoint("RIGHT", bar, "LEFT", -(FrameSpacing + 2*BorderSize), 0)
    Icon:SetSize(bar:GetHeight(, bar:GetHeight(), bar:GetHeight())
    bar:Set("bigwigs:restoreicon", Tex)

    local IconBd = bar.candyBarIconFrameBackdrop
    -- IconBd:SetTemplate()
    IconBd:SetOutside(Icon)
    IconBd:Show()
end

local f = CreateFrame("Frame")
local function registerMyStyle()
    if not BigWigs then return end
    barPlugin = BigWigs:GetPlugin("Bars", true)
    if not barPlugin then return end
    f:UnregisterEvent("ADDON_LOADED")
    f:UnregisterEvent("PLAYER_LOGIN")
    barPlugin:RegisterBarStyle("identifier", {
        apiVersion = 1,
        version = 1,
        GetSpacing = function(bar) return FrameSpacing + 2*BorderSize end,
        ApplyStyle = StyleBar,
        BarStopped = RemoveStyle,
        GetStyleName = function() return "Tukui-glmckay" end,
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