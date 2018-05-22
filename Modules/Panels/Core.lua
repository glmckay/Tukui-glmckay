local T, C, L = unpack(Tukui)

local Panels = T["Panels"]
local UnitFrames = T.UnitFrames

local FrameSpacing = C["General"].FrameSpacing

Panels.CenterPanelWidth = (C["ActionBars"].CenterButtonSize + FrameSpacing) * 6 - FrameSpacing

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

    local UnitFrameAnchor = CreateFrame("Frame", "TukuiUnitFrameAnchor", self.PetBattleHider)
    UnitFrameAnchor:Point("TOP", UIParent, "CENTER", 0, -160)
    UnitFrameAnchor:Size(64 + Panels.CenterPanelWidth + 2*UnitFrames.PlayerTargetWidth, UnitFrames.FrameHeight)

    -- local CenterPanel = CreateFrame("Frame", "TukuiCenterPanel", self.PetBattleHider)
    -- CenterPanel:Point("TOP", UnitFrameAnchor, "TOP")
    -- CenterPanel:Size(Panels.CenterPanelWidth, (C["ActionBars"].CenterButtonSize + FrameSpacing) * 2 + UnitFrames.FrameHeight)

    self.UnitFrameAnchor = UnitFrameAnchor
    -- self.CenterPanel = CenterPanel
end

hooksecurefunc(T["Panels"], "Enable", EditPanels)