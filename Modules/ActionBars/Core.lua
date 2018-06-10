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


local function MiddleBar()
    local ActionBar2 = Panels.ActionBar2

    -- I plan on removing this or giving it its own function in the future
    for i = 5,12 do
        local Button = ActionBar2["Button"..i]

        Button:ClearAllPoints()
        Button:Size(29)
        -- button:SetAttribute("flyoutDirection", "DOWN")

        if (i == 5) then
            Button:Point("TOPLEFT", Panels.UnitFrameAnchor, "BOTTOMLEFT", 0, -FrameSpacing)
        else
            Button:Point("LEFT", PreviousButton, "RIGHT", FrameSpacing, 0)
        end
        PreviousButton = Button
        -- For now
        RegisterStateDriver(Button, "visibility", "[vehicleui][petbattle][overridebar][nocombat,nomod:shift]hide; show")
    end



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

    -- CenterActionBar:SetBackdrop(nil)
    for i = 1,12 do
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


if (C["ActionBars"].HideGrid == true) then
    ActionBars.ShowGrid = function() end
end


ActionBars.CreateToggleButtons = function() end
ActionBars.LoadVariables = function() end


local function BottomRightBarStyle(Bar)
    local Size = C.ActionBars.NormalButtonSize
    local Spacing = C.ActionBars.ButtonSpacing

    Bar:Size(Size * 6 + Spacing * 5, Size * 2 + Spacing * 1)
    Bar.Button1:ClearAllPoints()
    Bar.Button1:Point("BOTTOMLEFT", Bar, "BOTTOMLEFT")

    Bar.Button7:ClearAllPoints()
    Bar.Button7:Point("TOPLEFT", Bar, "TOPLEFT")
end

-- The middle bar needs to be loaded after the panels are editted, (and we don't need to make changes while
--  Tukui is loading) so we will make changes after all modules load
local function EnableEdits(self)
    if (C["ActionBars"].HideGrid == true) then
        SetCVar("alwaysShowActionBars", 0)
    end

    EnableShiftPaging()

    local Bar1 = Panels.ActionBar1
    local Bar2 = Panels.ActionBar2
    local Bar3 = Panels.ActionBar3

    RegisterStateDriver(Bar1, "visibility", "[vehicleui][petbattle][overridebar][combat][mod:alt]show; hide")
    RegisterStateDriver(Bar2, "visibility", "[vehicleui][petbattle][overridebar][nocombat,nomod:alt]hide; show")
    RegisterStateDriver(Bar3, "visibility", "[vehicleui][petbattle][overridebar][nocombat,nomod:alt]hide; show")

    Panels.ActionBar1:HookScript("OnEvent", function(self, event)
        if not event == "PLAYER_ENTERING_WORLD" then return end
        BottomRightBarStyle(self)
        self:ClearAllPoints()
        self:Point("BOTTOMLEFT", Panels.DataTextRight, "TOPLEFT", 0, FrameSpacing)
    end)

    Bar2:ClearAllPoints()
    Bar2:Point("BOTTOMLEFT", Bar3, "TOPLEFT", 0, FrameSpacing)
    -- CHANGE THIS IN THE FUTURE PLEASE!!!!
    Bar2.Button1:ClearAllPoints()
    Bar2.Button1:Point("BOTTOMRIGHT", Bar3, "TOPRIGHT", 0, FrameSpacing)

    BottomRightBarStyle(Bar3)
    Bar3:ClearAllPoints()
    Bar3:Point("BOTTOMLEFT", Bar1, "TOPLEFT", 0, FrameSpacing)

    MiddleBar()
end

hooksecurefunc(ActionBars, "Enable", EnableEdits)