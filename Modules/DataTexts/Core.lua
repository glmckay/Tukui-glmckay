local T, C, L = Tukui:unpack()

local TukuiDT = T["DataTexts"]


local function AddMinimapAnchor(self)
    local Anchors = self.Anchors
    local numAnchs = self.NumAnchors + 1
    self.NumAnchors = numAnchs

    local Frame = CreateFrame("Button", nil, UIParent)
    Frame:Size(Minimap:GetWidth() / 2, 19)
    Frame:Point("CENTER", Minimap, "BOTTOM", 0, 1)
    Frame:SetFrameLevel(Minimap:GetFrameLevel() + 1)
    Frame:SetFrameStrata("HIGH")
    Frame:EnableMouse(false)
    Frame.SetData = Anchors[1].SetData
    Frame.RemoveData = Anchors[1].RemoveData
    Frame.Num = numAnchs

    Frame.Tex = Frame:CreateTexture()
    Frame.Tex:SetAllPoints()
    Frame.Tex:SetColorTexture(0.2, 1, 0.2, 0)

    Anchors[numAnchs] = Frame
end

hooksecurefunc(TukuiDT, "CreateAnchors", AddMinimapAnchor)


-- Change default datatext positions
function TukuiDT:AddDefaults()
    TukuiData[GetRealmName()][UnitName("player")].Texts = {}

    TukuiData[GetRealmName()][UnitName("player")].Texts[L.DataText.Guild] = {true, 1}
    TukuiData[GetRealmName()][UnitName("player")].Texts[L.DataText.Friends] = {true, 2}
    TukuiData[GetRealmName()][UnitName("player")].Texts[L.DataText.FPSAndMS] = {true, 3}
    TukuiData[GetRealmName()][UnitName("player")].Texts[L.DataText.Memory] = {true, 4}
    TukuiData[GetRealmName()][UnitName("player")].Texts[L.DataText.Durability] = {true, 5}
    TukuiData[GetRealmName()][UnitName("player")].Texts[L.DataText.Gold] = {true, 6}
    TukuiData[GetRealmName()][UnitName("player")].Texts[L.DataText.Time] = {true, 7}
end