local T, C, L = unpack(Tukui)

local TukuiActionBars = T["ActionBars"]
local TukuiPanels = T["Panels"]


function TukuiActionBars:EnableShiftPaging(self)
    local Bar1 = TukuiPanels.ActionBar1
    local BarStateHandler = CreateFrame("Frame", "TukuiBarStateHandler", UIParent, "SecureHandlerStateTemplate")

    BarStateHandler:Execute("Bar1Buttons = newtable()")
    for i = 1,NUM_ACTIONBAR_BUTTONS do
        local btnName = "Bar1Button"..i
        BarStateHandler:SetFrameRef(btnName, Bar1["Button"..i])
        BarStateHandler:Execute(string.format('Bar1Buttons[%d] = self:GetFrameRef("%s")', i, btnName))
    end

    RegisterStateDriver(BarStateHandler, "shift-state", "[mod:Shift] shift; noShift")
    BarStateHandler:SetAttribute("_onstate-shift-state", [[
        -- Note: Arguments are self, stateid, newstate
        if newstate == "shift" then
            pageNum = 2
        else
            pageNum = 1
        end
        for _,btn in ipairs(Bar1Buttons) do
            btn:SetAttribute("actionpage", pageNum)
        end
    ]])
end


local function EnableEdits(self)
    self:EnableShiftPaging()
end

hooksecurefunc(TukuiActionBars, "Enable", EnableEdits)