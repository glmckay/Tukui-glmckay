local T, C, L = unpack(Tukui)

local ActionBars = T["ActionBars"]
local Panels = T["Panels"]

local FrameSpacing = C["General"].FrameSpacing
local BorderSize = C["General"].BorderSize


local function EnableShiftPaging()
    local ActionBar1 = ActionBars.Bars.Bar1
    local OldGetBar = ActionBar1.GetBar
    ActionBar1.GetBar = function()
        return string.gsub(OldGetBar(ActionBar1), "bar:2", "mod:Shift][bar:2")
    end
    RegisterStateDriver(ActionBar1, "page", ActionBar1.GetBar())
end


local function SetupCenterBar()
    local ButtonsPerRow = C["ActionBars"].CenterRowLength
    local CenterButtonSize = C["ActionBars"].CenterButtonSize

    local CenterActionBar1 = ActionBars.Bars.Bar4
    CenterActionBar1:Show()
    CenterActionBar1:ClearAllPoints()
    CenterActionBar1:SetSize(ButtonsPerRow*CenterButtonSize + (ButtonsPerRow-1)*FrameSpacing, CenterButtonSize)
    CenterActionBar1:SetPoint("TOP", Panels.UnitFrameAnchor, "BOTTOM", 0, -FrameSpacing)

    local CenterActionBar2 = CreateFrame("Frame", "TukuiActionBar4Row2", CenterActionBar1, "SecureHandlerStateTemplate")
    CenterActionBar2:SetSize(ButtonsPerRow*CenterButtonSize + (ButtonsPerRow-1)*FrameSpacing, CenterButtonSize)
    CenterActionBar2:SetPoint("TOP", CenterActionBar1, "BOTTOM", 0, -FrameSpacing)
    CenterActionBar2:SetFrameStrata(CenterActionBar1:GetFrameStrata())
    CenterActionBar2:SetFrameLevel(CenterActionBar1:GetFrameLevel())

    for i = 1, (2 * ButtonsPerRow) do
        local Button
        if i <= NUM_ACTIONBAR_BUTTONS then
            Button = ActionBars.Bars.Bar4["Button"..i]
        else
            Button = ActionBars.Bars.Bar5["Button"..(2*NUM_ACTIONBAR_BUTTONS + 1 - i)]
        end

        if (i <= ButtonsPerRow) then
            Button:SetParent(CenterActionBar1)
            Button:SetAttribute("flyoutDirection", "UP")
        else
            CenterActionBar1["Button"..i] = nil
            CenterActionBar2["Button"..(i-ButtonsPerRow)] = Button
            Button:SetParent(CenterActionBar2)
            Button:SetAttribute("flyoutDirection", "DOWN")
        end

        if (i <= NUM_ACTIONBAR_BUTTONS) then
            Button:SetAttribute("actionpage", 3)
        else
            Button:SetAttribute("actionpage", 4)
        end

        Button:SetSize(CenterButtonSize, CenterButtonSize)
        Button:ClearAllPoints()

        if (i == 1) then
            Button:SetPoint("LEFT", CenterActionBar1)
        elseif (i == ButtonsPerRow + 1) then
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
    local Bar = ActionBars.Bars.Bar5
    local Bar = Panels.ActionBar5
    local Size = 34
    local Spacing = C.ActionBars.ButtonSpacing
    local OffsetX = T.UnitFrames.PlayerTargetWidth / 2
    local NumButtons = C.ActionBars.NumPlayerFrameButtons

    local totalWidth = Size*NumButtons + Spacing * (NumButtons - 1)
    if (totalWidth % 2 == 0) then OffsetX = OffsetX + 0.5 end -- for pixel-perfectness

    Bar:SetSize(totalWidth, Size)
    Bar:ClearAllPoints()
    Bar:SetPoint("TOP", Panels.UnitFrameAnchor, "BOTTOMLEFT", OffsetX, -FrameSpacing)

    local PrevButton
    for i = 1,NumButtons do
        local Button = Bar["Button"..i]
        Button:SetSize(Size, Size)
        Button:ClearAllPoints()
        if (not PrevButton) then
            Button:SetPoint("TOPLEFT", Bar, "TOPLEFT")
        else
            Button:SetPoint("LEFT", PrevButton, "RIGHT", Spacing, 0)
        end
        PrevButton = Button
    end

    local LastButtonToKill = math.min(NUM_ACTIONBAR_BUTTONS, 2*(NUM_ACTIONBAR_BUTTONS - C["ActionBars"].CenterRowLength))
    for i = (NumButtons+1),LastButtonToKill do
        Bar["Button"..i]:Kill()
    end

    -- Tukui moves the pet bar when this bar is shown/hidden.
    Bar:SetScript("OnShow", nil)
    Bar:SetScript("OnHide", nil)

    RegisterStateDriver(Bar, "visibility", "[vehicleui][petbattle][overridebar][nocombat,nomod:shift]hide; show")
end

ActionBars.MovePetBar = function() end

local function MovePetBar()
    local Bar = ActionBars.Bars.Pet
    local PetSize = C.ActionBars.PetButtonSize
    local Spacing = C.ActionBars.ButtonSpacing

    Bar:SetSize(PetSize * 12 + Spacing * 11, PetSize)
    Bar:ClearAllPoints()
    Bar:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 30)

    local PrevButton = nil
    for i = 1,NUM_PET_ACTION_SLOTS do
        local Button = Bar["Button"..i]

        Button:ClearAllPoints()
        if (PrevButton == nil) then
            Button:SetPoint("TOPLEFT", Bar)
        else
            Button:SetPoint("LEFT", PrevButton, "RIGHT", Spacing, 0)
        end

        PrevButton = Button
    end
end


-- Get rid of Tukui controls
ActionBars.CreateToggleButtons = function() end
ActionBars.LoadVariables = function() end

-- For some reason the objective tracker gets bugged out if I kill this frame immediately,
--  so we wait until it receives an event (probably PLAYER_ENTERING_WORLD) to kill it
local function EditVehicleButtons()
    local VehicleLeft = T.Panels.VehicleButtonLeft

    VehicleLeft:SetScript("OnEvent", VehicleLeft.Kill)
end


local function BottomRightBarStyle(Bar)
    local Size = C.ActionBars.NormalButtonSize
    local Spacing = C.ActionBars.ButtonSpacing

    Bar:SetSize(Size * 6 + Spacing * 5, Size * 2 + Spacing * 1)

    for i = 1,NUM_ACTIONBAR_BUTTONS do
        local Button = Bar["Button"..i]
        local PrevButton = Bar["Button"..i-1]

        Button:ClearAllPoints()
        if (i == 1) then
            Button:SetPoint("BOTTOMLEFT", Bar, "BOTTOMLEFT")
        elseif (i == 7) then
            Button:SetPoint("TOPLEFT", Bar, "TOPLEFT")
        else
            Button:SetPoint("LEFT", PrevButton, "RIGHT", Spacing, 0)
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
    Holder:SetPoint("BOTTOM", 0, 150)

    Movers:RegisterFrame(Holder)
end


local function EnableEdits(self)
    local Bar1 = ActionBars.Bars.Bar1
    local Bar2 = ActionBars.Bars.Bar2
    local Bar3 = ActionBars.Bars.Bar3
    local Bar5 = ActionBars.Bars.Bar5

    SetCVar("alwaysShowActionBars", (C["ActionBars"].HideGrid and 0) or 1)

    EnableShiftPaging()
    SetupCenterBar()

    ActionBars.Bars.Bar1:HookScript("OnEvent", function(self, event)
        if (event ~= "PLAYER_ENTERING_WORLD") then return end
        BottomRightBarStyle(self)
        self:ClearAllPoints()
        self:SetPoint("BOTTOMLEFT", T.DataTexts.Panels.Right, "TOPLEFT", 0, FrameSpacing)

        MovePetBar()
    end)

    BottomRightBarStyle(Bar2)
    Bar2:ClearAllPoints()
    Bar2:SetPoint("BOTTOMLEFT", Bar1, "TOPLEFT", 0, FrameSpacing)

    BottomRightBarStyle(Bar3)
    Bar3:ClearAllPoints()
    Bar3:SetPoint("BOTTOMLEFT", Bar2, "TOPLEFT", 0, FrameSpacing)

    RegisterStateDriver(Bar1, "visibility", "[vehicleui][petbattle][overridebar][mod:alt]show; hide")
    RegisterStateDriver(Bar2, "visibility", "[vehicleui][petbattle][overridebar][nomod:alt]hide; show")
    RegisterStateDriver(Bar3, "visibility", "[vehicleui][petbattle][overridebar][nomod:alt]hide; show")

    SetupConsumableBar()
end

hooksecurefunc(ActionBars, "Enable", EnableEdits)
hooksecurefunc(ActionBars, "SetupExtraButton", SetExtraActionDefaultPosition)
-- hooksecurefunc(ActionBars, "CreateVehicleButtons", EditVehicleButtons)
