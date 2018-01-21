local T, C, L = unpack(Tukui)


local function EditPanels(self)
    local BottomLine = self.BottomLine
    local LeftVerticalLine = self.LeftVerticalLine
    local RightVerticalLine = self.RightVerticalLine
    local DataTextLeft = self.DataTextLeft
    local DataTextRight = self.DataTextRight

    BottomLine:Kill()
    LeftVerticalLine:Kill()
    RightVerticalLine:Kill()

    DataTextLeft:SetBackdrop({})
    DataTextRight:SetBackdrop({})

end

hooksecurefunc(T["Panels"], "Enable", EditPanels)