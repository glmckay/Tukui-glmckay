local T, C, L = Tukui:unpack()

local UnitFrames = T.UnitFrames

local ufFont = T.GetFont(C["Raid"].Font)

local BorderSize = C["General"].BorderSize
local FrameSpacing = C["General"].FrameSpacing

UnitFrames.GridTotalHeight = 234
UnitFrames.GridMaxHeight = 60
UnitFrames.GridWidth = 101


UnitFrames.ListMaxHeight = 36
UnitFrames.ListTotalHeight = 720
UnitFrames.ListLargeWidth = 160
UnitFrames.ListSmallWidth = 100

-- UnitFrames.ListMinWidth = T.Scale(97)
-- UnitFrames.ListMinHeight = T.Scale(17)
-- UnitFrames.ListWidthIncr = T.Scale(9)
-- UnitFrames.ListHeightIncr = T.Scale(3)


local function RaidDebuffsShow(self)
    local Parent = self:GetParent()
    local Name = Parent.Name
    Name:ClearAllPoints()
    Name:Point("LEFT", self, "RIGHT", 5, 0)
end

local function RaidDebuffsHide(self)
    local Parent = self:GetParent()
    local Name = Parent.Name
    Name:ClearAllPoints()
    Name:Point("LEFT", Parent, "RIGHT", 5, 0)
end

local function UpdateFrameWidth(self, w)
    local innerWidth = w - 2*T.Scale(BorderSize)
    local HealPrediction = self.HealPrediction
    HealPrediction.absorbBar:SetWidth(innerWidth)
    HealPrediction.myBar:SetWidth(innerWidth)
    HealPrediction.otherBar:SetWidth(innerWidth)
end

local function UpdateListNameAndDebuffs(self, h)
    local RaidDebuffs = self.RaidDebuffs
    local Name = self.Name

    if (h == T.Scale(UnitFrames.ListMaxHeight)) then
        Name:ClearAllPoints()
        Name:Point("CENTER", self, "CENTER")

        RaidDebuffs:SetScript("OnShow", nil)
        RaidDebuffs:SetScript("OnHide", nil)
    else
        Name:ClearAllPoints()
        Name:Point("LEFT", self, "RIGHT", 5, 0)

        RaidDebuffs:SetScript("OnShow", RaidDebuffsShow)
        RaidDebuffs:SetScript("OnHide", RaidDebuffsHide)
        if (RaidDebuffs:IsShown()) then
            RaidDebuffsShow(RaidDebuffs)
        else
            RaidDebuffsHide(RaidDebuffs)
        end
    end
end


local function UpdateFrameHeight(self, h)

    if (self.FrameStyle == "LIST") then
        UpdateListNameAndDebuffs(self, h)

        local innerHeight = h - 2*T.Scale(BorderSize)
        self.RaidDebuffs:SetWidth(h)
        self.RaidDebuffs:SetHeight(h)
    end
end


local function UpdateFrameStyle(self, style)
    local RaidDebuffs = self.RaidDebuffs
    local Name = self.Name

    if (self.FrameStyle ~= style) then
        if (style == "GRID") then
            RaidDebuffs:SetScript("OnShow", nil)
            RaidDebuffs:SetScript("OnHide", nil)

            RaidDebuffs:ClearAllPoints()
            RaidDebuffs:Point("CENTER", self, "CENTER", 0, 0)
            RaidDebuffs:SetWidth(24)
            RaidDebuffs:SetHeight(24)

            Name:ClearAllPoints()
            Name:Point("BOTTOM", self, "CENTER", 0, 2)
            self.Health.Value:Show()
        else
            RaidDebuffs:ClearAllPoints()
            RaidDebuffs:Point("LEFT", self, "RIGHT", FrameSpacing, 0)

            local size = self:GetHeight()
            RaidDebuffs:SetWidth(size)
            RaidDebuffs:SetHeight(size)
            self.Health.Value:Hide()


        end
        self.FrameStyle = style
    end
end

local function EditGridRaidFrame(self)
    local Health = self.Health

    self.Panel:Kill()
    self:SetTemplate()

    -- Frame to overlay text above heal prediction
    local OverlayFrame = CreateFrame("Frame", nil, self)
    OverlayFrame:SetAllPoints()
    OverlayFrame:SetFrameLevel(Health:GetFrameLevel() + 3)

    Health:SetInside(self)
    Health:SetFrameLevel(3)

    Health.Value:ClearAllPoints()
    Health.Value:Point("TOP", self, "CENTER", 0, -2)

    self.Power:Kill()
    self.Power = nil

    local Name = OverlayFrame:CreateFontString(nil, "OVERLAY")
    Name:SetFontObject(ufFont)
    if (C.UnitFrames.DarkTheme) then
        Health:SetStatusBarColor(.25, .25, .25)
        self:Tag(Name, "[Tukui:GetNameColor][Tukui:NameMedium]")
    else
        self:Tag(Name, "[Tukui:NameMedium]")
    end

    local Highlight = self.Highlight
    if (Highlight) then
        Highlight:SetAllPoints(self)
        Highlight:SetBackdrop({ edgeFile = C.Medias.Blank, edgeSize = 2 })
        Highlight:SetFrameLevel(self:GetFrameLevel() + 1)
    end

    local HealPrediction = self.HealPrediction
    for name, bar in pairs(HealPrediction) do
        if (name ~= "maxOverflow") then
            bar:ClearAllPoints()
            bar:SetPoint("TOP", Health)
            bar:SetPoint("BOTTOM", Health)
            bar:SetPoint("LEFT", Health:GetStatusBarTexture(), "RIGHT")
        end
    end

    local ReadyCheck = self.ReadyCheck
    ReadyCheck:SetParent(OverlayFrame)
    ReadyCheck:ClearAllPoints()
    ReadyCheck:Point("CENTER", OverlayFrame)

    self.RaidDebuffs:Hide()

    self.LFDRole:Kill()
    self.LFDRole = nil

    self.OverlayFrame = OverlayFrame
    self.Name = Name

    self.UpdateWidth = UpdateFrameWidth
    self.UpdateHeight = UpdateFrameHeight
    self.UpdateStyle = UpdateFrameStyle

    local parent = self:GetParent()
    if (parent:GetAttribute("framestyle")) then
        self:UpdateStyle(parent:GetAttribute("framestyle"))
    end
    self:UpdateWidth(parent:GetAttribute("initial-width"))
    self:UpdateHeight(parent:GetAttribute("initial-height"))
end

hooksecurefunc(UnitFrames, "Raid", EditGridRaidFrame)
-- Testing RaidDebuffs (shows Heroism debuff)
-- UnitFrames.DebuffsTracking["CCDebuffs"]["spells"][57723] = {["enable"] = true, ["priority"] = 0, ["stackThreshold"] = 0}
