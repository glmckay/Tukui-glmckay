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


local function SetupConsumableBar()
    local Bar = Panels.ActionBar5
    local Size = 36
    local Spacing = C.ActionBars.ButtonSpacing
    local OffsetX = T.UnitFrames.PlayerTargetWidth / 2
    local NumButtons = 2

    Bar:Size(Size*NumButtons + Spacing * (NumButtons - 1), Size)
    Bar:ClearAllPoints()
    Bar:Point("TOP", Panels.UnitFrameAnchor, "BOTTOMLEFT", OffsetX, -FrameSpacing)

    local PrevButton
    for i = 1,NUM_ACTIONBAR_BUTTONS do
        local Button = Bar["Button"..i]
        if (i <= NumButtons) then
            Button:Size(Size)
            Button:ClearAllPoints()
            if (not PrevButton) then
                Button:Point("TOPLEFT", Bar, "TOPLEFT")
            else
                Button:Point("LEFT", PrevButton, "RIGHT", Spacing, 0)
            end
            PrevButton = Button
        else
            Button:Kill()
        end
    end

    -- Tukui moves the pet bar when this bar is shown/hidden.
    Bar:SetScript("OnShow", nil)
    Bar:SetScript("OnHide", nil)

    RegisterStateDriver(Bar, "visibility", "[vehicleui][petbattle][overridebar][nocombat,nomod:shift]hide; show")
end

ActionBars.MovePetBar = function() end

local function MovePetBar()
    local Bar = T.Panels.PetActionBar
    local PetSize = C.ActionBars.PetButtonSize
    local Spacing = C.ActionBars.ButtonSpacing

    Bar:Size(PetSize * 12 + Spacing * 11, PetSize)
    Bar:ClearAllPoints()
    Bar:Point("BOTTOM", UIParent, "BOTTOM", 0, 30)

    local PrevButton = nil
    for i = 1,NUM_PET_ACTION_SLOTS do
        local Button = Bar["Button"..i]

        Button:ClearAllPoints()
        if (PrevButton == nil) then
            Button:Point("TOPLEFT", Bar)
        else
            Button:Point("LEFT", PrevButton, "RIGHT", Spacing, 0)
        end

        PrevButton = Button
    end
end


-- Get rid of Tukui controls
ActionBars.CreateToggleButtons = function() end
ActionBars.LoadVariables = function() end

local function EditVehicleButtons()
    local VehicleLeft = T.Panels.VehicleButtonLeft

    VehicleLeft:Kill()
    -- local VehicleRight = T.Panels.VehicleButtonRight

    -- VehicleLeft:ClearAllPoints()
    -- VehicleLeft:Width(120)
    -- VehicleLeft:Point("TOPLEFT", T.Panels.DataTextLeft, "TOPRIGHT", FrameSpacing, 0)
    -- VehicleLeft:Point("TOPLEFT", T.Panels.DataTextLeft, "TOPRIGHT", FrameSpacing, 0)

    -- VehicleRight:ClearAllPoints()
    -- VehicleRight:Width(120)
    -- VehicleRight:Point("TOPRIGHT", T.Panels.DataTextRight, "TOPLEFT", -FrameSpacing, 0)
    -- VehicleRight:Point("TOPRIGHT", T.Panels.DataTextRight, "TOPLEFT", -FrameSpacing, 0)
end


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
-- function ActionBars:ShowGrid()
--     for i = 1, NUM_ACTIONBAR_BUTTONS do
--         local Button

--         Button = _G[format("ActionButton%d", i)]
--         Button:SetAttribute("showgrid", 1)
--         ActionButton_ShowGrid(Button)
--     end
-- end


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

        MovePetBar()
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

    SetupConsumableBar()
end

hooksecurefunc(ActionBars, "Enable", EnableEdits)
hooksecurefunc(ActionBars, "SetUpExtraActionButton", SetExtraActionDefaultPosition)
hooksecurefunc(ActionBars, "CreateVehicleButtons", EditVehicleButtons)