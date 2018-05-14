local T, C, L = unpack(Tukui)

local ActionBars = T["ActionBars"]
local Panels = T["Panels"]

local FrameSpacing = C.General.FrameSpacing
local BorderSize = C.General.BorderSize


function ActionBars:EnableShiftPaging()
--     local Bar1 = TukuiPanels.ActionBar1
--     local Bar1StateHandler = CreateFrame("Frame", "TukuiBarStateHandler", UIParent, "SecureHandlerStateTemplate")

--     Bar1StateHandler:Execute("Bar1Buttons = newtable()")
--     for i = 1,NUM_ACTIONBAR_BUTTONS do
--         local btnName = "Bar1Button"..i
--         Bar1StateHandler:SetFrameRef(btnName, Bar1["Button"..i])
--         Bar1StateHandler:Execute(string.format('Bar1Buttons[%d] = self:GetFrameRef("%s")', i, btnName))
--     end

--     RegisterStateDriver(Bar1StateHandler, "shift-state", "[vehicleui][petbattle][overridebar] ignore;[mod:Shift] shift; noshift")
--     Bar1StateHandler:SetAttribute("_onstate-shift-state", [[
--         -- Note: Arguments are self, stateid, newstate
--         pageNum = -1
--         if newstate == "shift" then
--             pageNum = 2
--         elseif newstate == "noshift" then
--             pageNum = 1
--         end
--         if (pageNum > 0) then
--             for _,btn in ipairs(Bar1Buttons) do
--                 btn:SetAttribute("actionpage", pageNum)
--             end
--         end
--     ]])
    local actionBar1 = Panels.ActionBar1
    local oldGetBar = actionBar1.GetBar
    actionBar1.GetBar = function()
        return string.gsub(oldGetBar(actionBar1), "bar:2", "mod:Shift][bar:2")
    end
    self:UpdateBar1()
end


function ActionBars:MiddleBar()
    local actionBar2 = Panels.ActionBar2
    local actionBar4 = Panels.ActionBar4

    local previousButton
    for i = 5,12 do
        local button = actionBar2["Button"..i]

        button:ClearAllPoints()
        button:Size(29)
        -- button:SetAttribute("flyoutDirection", "DOWN")

        if (i == 5) then
            button:Point("TOPLEFT", Panels.UnitFrameAnchor, "BOTTOMLEFT", 0, -FrameSpacing)
        else
            button:Point("LEFT", previousButton, "RIGHT", FrameSpacing, 0)
        end
        previousButton = button
        -- For now
        RegisterStateDriver(button, "visibility", "[vehicleui][petbattle][overridebar][nocombat,nomod:shift]hide; show")
    end

    actionBar4:SetBackdrop(nil)
    actionBar4:Show()
    for i = 1,12 do
        local button = actionBar4["Button"..i]

        button:Size(40)
        button:ClearAllPoints()
        button:SetAttribute("flyoutDirection", "UP")

        if (i == 1) then
            button:SetPoint("TOPLEFT", Panels.UnitFrameAnchor, "BOTTOM", -3*(40 + FrameSpacing), -FrameSpacing)
        elseif (i == 7) then
            button:SetPoint("TOPLEFT", actionBar4["Button"..1], "BOTTOMLEFT", 0, -FrameSpacing)
        else
            button:SetPoint("LEFT", previousButton, "RIGHT", FrameSpacing, 0)
        end
        previousButton = button
    end

    RegisterStateDriver(actionBar4, "visibility", "[vehicleui][petbattle][overridebar][nocombat,nomod:shift]hide; show")
end

if (C["ActionBars"].HideGrid == true) then
    ActionBars.ShowGrid = function() end
end

function ActionBars:EnableEdits()
    if (C["ActionBars"].HideGrid == true) then
        SetCVar("alwaysShowActionBars", 0)
    end

    self:EnableShiftPaging()
    self:MiddleBar()
end

-- hooksecurefunc(ActionBars, "Enable", EnableEdits)