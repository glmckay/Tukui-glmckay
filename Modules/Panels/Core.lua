local T, C, L = unpack(Tukui)

local Panels = T["Panels"]
local UnitFrames = T.UnitFrames

local BorderSize = C["General"].BorderSize
local FrameSpacing = C["General"].FrameSpacing
local LeftRightPanelWidth = 410

Panels.CenterPanelWidth = (C["ActionBars"].CenterButtonSize + FrameSpacing) * 6 - FrameSpacing


-- Give a backdrop to Details!
local function CreateDetailsPanels()
    local i = 1
    repeat
        local Frame = _G["DetailsBaseFrame"..i]
        if not Frame then break end
        Frame:CreateBackdrop()
        i = i + 1
    until true

    DetailsBaseFrame1:ClearAllPoints()
    DetailsBaseFrame1:Point("BOTTOMRIGHT", Panels.DataTextRight, "TOPRIGHT", -BorderSize, BorderSize + FrameSpacing)
end


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
    DataTextLeft:Width(LeftRightPanelWidth)
    DataTextRight:SetBackdrop({})
    DataTextRight:Width(LeftRightPanelWidth)

    local UnitFrameAnchor = CreateFrame("Frame", "TukuiUnitFrameAnchor", self.PetBattleHider)
    UnitFrameAnchor:Point("TOP", UIParent, "CENTER", 0, -160)
    UnitFrameAnchor:Size(64 + Panels.CenterPanelWidth + 2*UnitFrames.PlayerTargetWidth, UnitFrames.FrameHeight)

    local DataTextCenter =  CreateFrame("Frame", "TukuiCenterDataTextBox", UIParent)
    DataTextCenter:Size(600, 23)
    DataTextCenter:SetPoint("CENTER", UIParent, "BOTTOM", 0, 15)
    DataTextCenter:SetFrameStrata("BACKGROUND")
    DataTextCenter:SetFrameLevel(1)

    self.UnitFrameAnchor = UnitFrameAnchor
    self.DataTextCenter = DataTextCenter

    CreateDetailsPanels()
end



hooksecurefunc(T["Panels"], "Enable", EditPanels)