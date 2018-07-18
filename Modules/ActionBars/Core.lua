local T, C, L = unpack(Tukui)

local ActionBars = T["ActionBars"]
local Panels = T["Panels"]

local FrameSpacing = C["General"].FrameSpacing
local BorderSize = C["General"].BorderSize


local function EnableShiftPaging()
    local ActionBar1 = Panels.ActionBar1
    local OldGetBar = ActionBar1.GetBar
    ActionBar1.GetBar = function()
        return string.gsub(OldGetBar(ActionBar1), "bar:2", "mod:Shift][bar:2")
    end
    ActionBars:UpdateBar1()
end


local function SetupCenterBar()
    local CenterButtonSize = C["ActionBars"].CenterButtonSize

    local CenterActionBar1 = Panels.ActionBar4
    CenterActionBar1:Show()
    CenterActionBar1:ClearAllPoints()
    CenterActionBar1:Size(6*CenterButtonSize + 5*FrameSpacing, CenterButtonSize)
    CenterActionBar1:Point("TOP", Panels.UnitFrameAnchor, "BOTTOM", 0, -FrameSpacing)

    local CenterActionBar2 = CreateFrame("Frame", "TukuiActionBar4Row2", CenterActionBar1, "SecureHandlerStateTemplate")
    CenterActionBar2:Size(6*CenterButtonSize + 5*FrameSpacing, CenterButtonSize)
    CenterActionBar2:Point("TOP", CenterActionBar1, "BOTTOM", 0, -FrameSpacing)
    CenterActionBar2:SetFrameStrata(CenterActionBar1:GetFrameStrata())
    CenterActionBar2:SetFrameLevel(CenterActionBar1:GetFrameLevel())

    for i = 1,NUM_ACTIONBAR_BUTTONS do
        local Button = CenterActionBar1["Button"..i]

        if (i <= 6) then
            Button:SetAttribute("flyoutDirection", "UP")
        else
            CenterActionBar1["Button"..i] = nil
            CenterActionBar2["Button"..i-6] = Button
            Button:SetParent(CenterActionBar2)
            Button:SetAttribute("actionpage", 3)
            Button:SetAttribute("flyoutDirection", "DOWN")
        end

        Button:Size(CenterButtonSize)
        Button:ClearAllPoints()

        if (i == 1) then
            Button:SetPoint("LEFT", CenterActionBar1)
        elseif (i == 7) then
            Button:SetPoint("LEFT", CenterActionBar2)
        else
            Button:SetPoint("LEFT", PreviousButton, "RIGHT", FrameSpacing, 0)
        end
        PreviousButton = Button
    end

    RegisterStateDriver(CenterActionBar1, "visibility", "[vehicleui][petbattle][overridebar][nocombat,nomod:shift]hide; show")

    Panels.CenterActionBars = { CenterActionBar1, CenterActionBar2 }
end


-- Get rid of Tukui controls
ActionBars.CreateToggleButtons = function() end
ActionBars.LoadVariables = function() end


local function BottomRightBarStyle(Bar)
    local Size = C.ActionBars.NormalButtonSize
    local Spacing = C.ActionBars.ButtonSpacing

    Bar:Size(Size * 6 + Spacing * 5, Size * 2 + Spacing * 1)

    for i = 1,NUM_ACTIONBAR_BUTTONS do
        local Button = Bar["Button"..i]
        local PrevButton = Bar["Button"..i-1]

        Button:ClearAllPoints()
        if (i == 1) then
            Button:Point("BOTTOMLEFT", Bar, "BOTTOMLEFT")
        elseif (i == 7) then
            Button:Point("TOPLEFT", Bar, "TOPLEFT")
        else
            Button:Point("LEFT", PrevButton, "RIGHT", Spacing, 0)
        end
    end
end


-- Always show ActionBar1 (otherwise grid doesn't show properly, maybe because of paging)
function ActionBars:ShowGrid()
    for i = 1, NUM_ACTIONBAR_BUTTONS do
        local Button

        Button = _G[format("ActionButton%d", i)]
        Button:SetAttribute("showgrid", 1)
        ActionButton_ShowGrid(Button)
    end
end


local function SetExtraActionDefaultPosition()
    local Holder = TukuiExtraActionButton
    local Movers = T["Movers"]

    Holder:ClearAllPoints()
    Holder:Point("BOTTOM", 0, 150)

    Movers:RegisterFrame(Holder)
end


local function EnableEdits(self)
    local Bar1 = Panels.ActionBar1
    local Bar2 = Panels.ActionBar2
    local Bar3 = Panels.ActionBar3
    local Bar5 = Panels.ActionBar5

    SetCVar("alwaysShowActionBars", (C["ActionBars"].HideGrid and 0) or 1)

    EnableShiftPaging()
    SetupCenterBar()

    Panels.ActionBar1:HookScript("OnEvent", function(self, event)
        if (event ~= "PLAYER_ENTERING_WORLD") then return end
        BottomRightBarStyle(self)
        self:ClearAllPoints()
        self:Point("BOTTOMLEFT", Panels.DataTextRight, "TOPLEFT", 0, FrameSpacing)
    end)

    BottomRightBarStyle(Bar2)
    Bar2:ClearAllPoints()
    Bar2:Point("BOTTOMLEFT", Bar1, "TOPLEFT", 0, FrameSpacing)

    BottomRightBarStyle(Bar3)
    Bar3:ClearAllPoints()
    Bar3:Point("BOTTOMLEFT", Bar2, "TOPLEFT", 0, FrameSpacing)

    RegisterStateDriver(Bar1, "visibility", "[vehicleui][petbattle][overridebar][mod:alt]show; hide")
    RegisterStateDriver(Bar2, "visibility", "[vehicleui][petbattle][overridebar][nomod:alt]hide; show")
    RegisterStateDriver(Bar3, "visibility", "[vehicleui][petbattle][overridebar][nomod:alt]hide; show")

    UnregisterStateDriver(Bar5, "visibility")
    Bar5:Kill()
end

hooksecurefunc(ActionBars, "Enable", EnableEdits)
hooksecurefunc(ActionBars, "SetUpExtraActionButton", SetExtraActionDefaultPosition)