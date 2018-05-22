local T, C, L = Tukui:unpack()

local UnitFrames = T.UnitFrames

local ufFont = T.GetFont(C["Raid"].Font)

local borderSize = C["General"].BorderSize

UnitFrames.GridTotalHeight = T.Scale(234)
UnitFrames.GridMaxHeight = T.Scale(60)
UnitFrames.GridWidth = T.Scale(100)


local function UpdateFrameForSize(self, w, h)
    local innerWidth = w - 2*T.Scale(borderSize)

    local HealPrediction = self.HealPrediction
    if (HealPrediction) then
        HealPrediction.myBar:SetWidth(innerWidth)
        HealPrediction.otherBar:SetWidth(innerWidth)
        HealPrediction.absorbBar:SetWidth(innerWidth)
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

    self.Power:Kill()
    self.Power = nil

    local Name = OverlayFrame:CreateFontString(nil, "OVERLAY")
    Name:Point("CENTER", Health, "TOP", 0, 2)
    Name:SetFontObject(ufFont)
    if (C.UnitFrames.DarkTheme) then
        Health:SetStatusBarColor(.25, .25, .25)
        self:Tag(Name, "[Tukui:GetNameColor][Tukui:NameMedium]")
    else
        Name:SetTextColor(.9, .9, .9)
        self:Tag(Name, "[Tukui:NameMedium]")
    end

    local RaidDebuffs = self.RaidDebuffs

    local Highlight = self.Highlight
    Highlight:SetAllPoints(self)
    Highlight:SetBackdrop({ edgeFile = C.Medias.Blank, edgeSize = 2 })
    Highlight:SetFrameLevel(self:GetFrameLevel() + 1)

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

    self.LFDRole:Kill()
    self.LFDRole = nil

    self.OverlayFrame = OverlayFrame
    self.Name = Name

    self.UpdateForSize = UpdateFrameForSize

    local parent = self:GetParent()
    self:UpdateForSize(parent:GetAttribute("initial-width"), parent:GetAttribute("initial-height"))
end

-- Testing RaidDebuffs (shows Heroism debuff)
-- UnitFrames.RaidDebuffsTracking[GetSpellInfo(57723)] = 6

hooksecurefunc(UnitFrames, "Raid", EditGridRaidFrame)