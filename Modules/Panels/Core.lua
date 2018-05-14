local T, C, L = unpack(Tukui)

local UnitFrames = T.UnitFrames


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

    local UnitFrameAnchor = CreateFrame("Frame", "TukuiUnitFrameAnchor", UIParent)
    UnitFrameAnchor:SetParent(self.PetBattleHider)
    UnitFrameAnchor:Point("TOP", UIParent, "CENTER", 0, -160)
    UnitFrameAnchor:Size(340 + 2*UnitFrames.PlayerTargetWidth, UnitFrames.FrameHeight)

    self.UnitFrameAnchor = UnitFrameAnchor
end

hooksecurefunc(T["Panels"], "Enable", EditPanels)