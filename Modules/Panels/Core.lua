local T, C, L = unpack(Tukui)

T["Panels"] = CreateFrame("Frame")

local Panels = T["Panels"]
local UnitFrames = T["UnitFrames"]
local DataText = T["DataTexts"]

local BorderSize = C["General"].BorderSize
local FrameSpacing = C["General"].FrameSpacing
local CenterButtonsPerRow = C["ActionBars"].CenterRowLength
local LeftRightPanelWidth = 410  -- magic number?

Panels.CenterPanelWidth = (C["ActionBars"].CenterButtonSize + FrameSpacing) * CenterButtonsPerRow - FrameSpacing


-- Give a backdrop to Details!
local function SkinDetails()
    local i = 1
    repeat
        local Frame = _G["DetailsBaseFrame"..i]
        if not Frame then break end
        Frame:CreateBackdrop()
        Frame.Backdrop:SetOutside(Frame)
        i = i + 1
    until false
end


local function CreateDetailsButton(self)
    local Details = DetailsBaseFrame1
    local ActionButtonSize = C.ActionBars.NormalButtonSize
    local ActionButtonSpacing = C.ActionBars.ButtonSpacing

    -- Details:ClearAllPoints()
    -- Details:SetPoint("BOTTOMRIGHT", Panels.DataTextRight, "TOPRIGHT", -BorderSize, BorderSize + FrameSpacing)

    local Button = CreateFrame("Button", "TukuiDetailsToggle", UIParent)
    Button:SetWidth(LeftRightPanelWidth - CenterButtonsPerRow*ActionButtonSize - (CenterButtonsPerRow-1) * ActionButtonSpacing - FrameSpacing)
    -- Button:SetWidth(100)
    Button:SetPoint("TOPRIGHT", UIParent, "BOTTOMRIGHT", -34, 42)
    Button:SetPoint("BOTTOM", UIParent)
    Button:CreateBackdrop()
    Button:SetAlpha(0)
    Button:SetScript("OnEnter", function(self) self:SetAlpha(1) end)
    Button:SetScript("OnLeave", function(self) self:SetAlpha(0) end)
    Button:SetScript("OnClick", function(self)
        SlashCmdList.DETAILS("toggle 1")
        SkinDetails()
    end)
    SkinDetails()

    Button.Text = Button:CreateFontString(nil, "BORDER")
    Button.Text:SetFont(C["Medias"].RegFont, 14, "OUTLINE")
    Button.Text:SetText("Toggle Details!")
    Button.Text:SetPoint("BOTTOM", Button, "CENTER", 0, -2)
end

local BlankBackdrop = {}
local function EditLeftRightPanel(panel)
    panel:SetWidth(LeftRightPanelWidth)
    panel:SetBackdrop(BlankBackdrop)
end


function Panels:Enable()
    -- self.BottomLine:Kill()

    -- SetPoint because we don't want these numbers rounded
    -- DataTexts.Panels.Right:SetPoint("BOTTOMRIGHT", DataTexts.Panels.Right, -26, 30)
    -- DataTexts.Panels.Left:SetPoint("LEFT", DataTexts.Panels.Left, 4, -0.5)

    -- for _,side in ipairs({ "Left", "Right" }) do
    --     local VerticalLine = self[side.."VerticalLine"]
    --     local DataText = self["DataText"..side]
    --     local ChatBG = self[side.."ChatBG"]
    --     local ChatTabsBG = self["TabsBG"..side]

    --     VerticalLine:Kill()

    --     DataText:SetWidth(LeftRightPanelWidth)
    --     DataText:SetBackdrop({})

    --     ChatBG:SetWidth(LeftRightPanelWidth)
    --     ChatBG.Backdrop:Kill()

    --     -- 12 is taken from Tukui/Modules/Panels/Core.lua
    --     ChatTabsBG:SetWidth(LeftRightPanelWidth - 12)
    --     ChatTabsBG:SetBackdrop({})
    -- end

    local UnitFrameAnchor = CreateFrame("Frame", "TukuiUnitFrameAnchor", UIParent)
    UnitFrameAnchor:SetPoint("TOP", UIParent, "CENTER", 0, -190)
    UnitFrameAnchor:SetSize(64 + Panels.CenterPanelWidth + 2*UnitFrames.PlayerTargetWidth, UnitFrames.FrameHeight)

    local DataTextCenter =  CreateFrame("Frame", "TukuiCenterDataTextBox", UIParent)
    DataTextCenter:SetSize(600, 23)
    DataTextCenter:SetPoint("CENTER", UIParent, "BOTTOM", 0, 15)
    DataTextCenter:SetFrameStrata("BACKGROUND")
    DataTextCenter:SetFrameLevel(1)

    self.UnitFrameAnchor = UnitFrameAnchor
    self.DataTextCenter = DataTextCenter

    CreateDetailsButton(self)
end

-- hooksecurefunc(T["UnitFrames"], "Enable", EditPanels)
