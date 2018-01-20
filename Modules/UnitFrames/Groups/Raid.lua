local T, C, L = Tukui:unpack()

local UnitFrames = T.UnitFrames

local ufFont = T.GetFont(C["Raid"].Font)

local ufWidth = 75
local ufHeight = 32

UnitFrames.RaidWidth = ufWidth
UnitFrames.RaidHeight = ufHeight

local function EditRaid(self)

    local Health = self.Health

    self.Panel:Kill()
    self.Shadow:Kill()
    self:SetBackdrop(UnitFrames.SkinnedBackdrop)
    self:SetBackdropColor(0, 0, 0)

    -- Frame to overlay text above heal prediction
    local OverlayFrame = CreateFrame("Frame", nil, self)
    OverlayFrame:SetAllPoints()
    OverlayFrame:SetFrameLevel(Health:GetFrameLevel() + 3)

    Health:SetAllPoints()
    Health:SetFrameLevel(3)

    self.Power:Kill()
    self.Power = nil

    local Name = OverlayFrame:CreateFontString(nil, "OVERLAY")
    Name:Point("CENTER", Health, "TOP", 0, 2)
    Name:SetFontObject(ufFont)
    if (C.UnitFrames.DarkTheme) then
        self:Tag(Name, "[Tukui:GetNameColor][Tukui:NameShort]")
    else
        self:Tag(Name, "[Tukui:NameShort]")
    end

    self.ReadyCheck:SetParent(OverlayFrame)
    self.ReadyCheck:ClearAllPoints()
    self.ReadyCheck:Point("CENTER")

    if (C.Raid.HealBar) then
        local HealPrediction = self.HealPrediction

        for name,bar in pairs(HealPrediction) do
            if (name ~= 'maxOverflow') then
                bar:Height(ufHeight)
                bar:Width(ufWidth)
            end
        end
    end

    if (C.UnitFrames.DarkTheme) then
        Health:SetStatusBarColor(.25, .25, .25)
    end

    self.OverlayFrame = OverlayFrame
    self.Name = Name
    self.ReadyCheck = ReadyCheck
end

-- Testing AuraWatch
-- UnitFrames.RaidDebuffsTracking[GetSpellInfo(57723)] = 6

hooksecurefunc(UnitFrames, "Raid", EditRaid)