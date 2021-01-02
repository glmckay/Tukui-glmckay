local T, C, L = Tukui:unpack()

if (T.MyClass ~= "MONK") then return end

local TukuiUF = T["UnitFrames"]
local Panels = T["Panels"]

local BorderSize = C.General.BorderSize
local FrameSpacing = C.General.FrameSpacing

local UFHeight = TukuiUF.FrameHeight
local UFWidth = TukuiUF.PlayerTargetWidth
local BMBarHeight = 6 -- for now
local NormalBarHeight

local MAX_POSSIBLE_BREWS = 4
local ISB_SPELL_ID = 115308
local ISB_AURA_ID = 215479
local BREWMASTER_SPEC_INDEX = 1
local WINDWALKER_SPEC_INDEX = 3
local LOW_R, LOW_G, LOW_B = 0.99, 0.31, 0.31


local function BrewBarOnUpdate(self)
    local CurrentTime = GetTime()
    self.StatusBar:SetValue(CurrentTime)
    if (CurrentTime > self.EndTime) then
        self:SetScript("OnUpdate", nil)
        local Parent = self:GetParent()
        Parent.Charges = Parent.Charges + 1
        if (Parent.Charges < Parent.MaxCharges) then
            local NextBar = Parent[Parent.Charges + 1]
            NextBar:SetScript("OnUpdate", BrewBarOnUpdate)
        end
    end
end

local function BrewAuraOnUpdate(self, elapsed)
    if (self.TimeLeft) then
        self.Elapsed = (self.Elapsed or 0) + elapsed

        if self.Elapsed >= 0.1 then
            if not self.First then
                self.TimeLeft = self.TimeLeft - self.Elapsed
            else
                self.TimeLeft = self.TimeLeft - GetTime()
                self.First = false
            end
            if self.TimeLeft > 0 then
                local Time = math.floor(self.TimeLeft)
                self.Remaining:SetText(Time)

                if self.TimeLeft <= 5 then
                    self.Remaining:SetTextColor(LOW_R, LOW_G, LOW_B)
                else
                    self.Remaining:SetTextColor(1, 1, 1)
                end
            else
                self:SetScript("OnUpdate", nil)
            end

            self.Elapsed = 0
        end
    end
end

local function CheckBrewAura(self)
    for i = 1,40 do
        local _, _, _, _, _, ExpTime, _, _, _, SpellId = UnitAura("player", i, "PLAYER|HELPFUL")
        if (not SpellId) then break end

        if (SpellId == ISB_AURA_ID and ExpTime ~= self.AuraExpTime) then
            if (ExpTime > GetTime()) then
                self:SetScript("OnUpdate", BrewAuraOnUpdate)
                self.TimeLeft = ExpTime
                self.First = true
            else
                self.TimeLeft = 0
                self.Remaining:SetText("0")
                self.Remaining:SetTextColor(LOW_R, LOW_G, LOW_B)
                self:SetScript("OnUpdate", nil)
            end
            return
        end
    end
    if (self.TimeLeft > 0) then
        self.TimeLeft = 0
        self.Remaining:SetText("0")
        self.Remaining:SetTextColor(LOW_R, LOW_G, LOW_B)
        self:SetScript("OnUpdate", nil)
    end
end

local function UpdateBrewCharges(self, charges, start, duration)
    local CurrentTime = GetTime()

    if (charges == self.MaxCharges) then
        for i = 1,self.MaxCharges do
            local Bar = self[i]
            Bar.StatusBar:SetMinMaxValues(0, 1)
            Bar.StatusBar:SetValue(1)
            Bar:SetScript("OnUpdate", nil)
        end
    else
        for i = 1,self.MaxCharges do
            local Bar = self[i]
            local BarEndTime = start + duration*(i - charges)
            Bar.EndTime = BarEndTime
            Bar.StatusBar:SetMinMaxValues(BarEndTime - duration, BarEndTime)
            Bar.StatusBar:SetValue(CurrentTime)
            Bar:SetScript("OnUpdate", (i == charges + 1 and BrewBarOnUpdate) or nil)
        end
    end

    self.Charges = charges
    self.Start = start
    self.Duration = duration
    self.NextChargeTime = start + duration
end

local function UpdateMaxBrewCharges(self, maxCharges)
    local TotalWidth = Panels.CenterPanelWidth - (maxCharges-1)*FrameSpacing
    local BarWidth = TotalWidth / maxCharges

    -- Set the width of the bars from the outside bars inwards
    -- The middle bars will adjust to fill the width
    local i = 1
    local j = maxCharges
    while (j > i + 1) do
        self[i]:SetWidth(BarWidth)
        self[j]:SetWidth(BarWidth)
        i = i + 1
        j = j - 1
    end

    if (i == j) then
        self[i]:SetWidth(TotalWidth - (maxCharges-1)*BarWidth)
    else -- j == i+1
        local MidBarWidth = (TotalWidth - (maxCharges - 2)*BarWidth) / 2
        self[i]:SetWidth(math.floor(MidBarWidth))
        self[j]:SetWidth(math.ceil(MidBarWidth))
    end

    for i = 1,MAX_POSSIBLE_BREWS do
        if (i <= maxCharges) then
            self[i]:Show()
        else
            self[i]:Hide()
        end
    end

    self.MaxCharges = maxCharges
end


local function CheckBrewCharges(self)
    local Charges, MaxCharges, Start, Duration = GetSpellCharges(ISB_SPELL_ID)
    if (MaxCharges ~= self.MaxCharges) then
        UpdateMaxBrewCharges(self, MaxCharges)
    end
    if (Charges ~= self.Charges or
        (Charges < MaxCharges and (Start ~= self.Start or Duration ~= self.Duration))) then
        UpdateBrewCharges(self, Charges, Start, Duration)
    end
end


local function EnableBrewFrame(self)
    if (not self.Enabled) then
        self:RegisterEvent("SPELL_UPDATE_COOLDOWN")
        self:RegisterEvent("UNIT_AURA")
        self:Show()
        CheckBrewCharges(self)
        CheckBrewAura(self)
        self.Enabled = true
    end
end

local function DisableBrewFrame(self)
    if (self.Enabled) then
        self:UnregisterEvent("SPELL_UPDATE_COOLDOWN")
        self:UnregisterEvent("UNIT_AURA")
        self:SetScript("OnUpdate", nil)
        if (self.Charges < self.MaxCharges) then
            self[self.Charges+1]:SetScript("OnUpdate", nil)
        end
        self:Hide()
        self.Enabled = false
    end
end

local function SpecUpdate(self)
    if (GetSpecialization() == BREWMASTER_SPEC_INDEX) then
        EnableBrewFrame(self)
    else
        DisableBrewFrame(self)
    end
end

local function CreateBrewDisplay(self)
    local BrewFrame = CreateFrame("Frame", self:GetName().."BrewFrame", self.Power)
    BrewFrame:SetSize(Panels.CenterPanelWidth, 8)
    BrewFrame:SetPoint("BOTTOM", self.Stagger, "TOP", 0, FrameSpacing + BorderSize)
    BrewFrame:SetFrameLevel(2)

    for i = 1,MAX_POSSIBLE_BREWS do
        local Bar = CreateFrame("Frame", self:GetName().."BrewFrameBar"..i, BrewFrame)
        Bar:SetFrameLevel(0)
        if (i == 1) then
            Bar:SetPoint("LEFT", BrewFrame, "LEFT")
        else
            Bar:SetPoint("LEFT", BrewFrame[i-1], "RIGHT", FrameSpacing, 0)
        end
        -- Bar:SetTemplate()
        Bar:SetHeight(8)

        Bar.StatusBar = CreateFrame("StatusBar", nil, Bar)
        Bar.StatusBar:SetFrameLevel(1)
        Bar.StatusBar:SetInside(Bar)
        Bar.StatusBar:SetStatusBarTexture(T.GetTexture(C["Textures"]["General"]))
        Bar.StatusBar:SetStatusBarColor(unpack(T["Colors"]["power"]["CHI"]))

        BrewFrame[i] = Bar
    end

    BrewFrame.Remaining = BrewFrame:CreateFontString(self:GetName().."BrewFrameTime", "BORDER")
    BrewFrame.Remaining:SetFontObject(T.GetFont(C["UnitFrames"].BigNumberFont))
    BrewFrame.Remaining:SetPoint("CENTER", BrewFrame, "CENTER")

    BrewFrame.TimeLeft = 100 -- To force an initial update
    BrewFrame.Remaining:SetText("100")

    BrewFrame:SetScript("OnEvent", function(self, event, arg)
        if (event == "UNIT_AURA" and arg == "player") then
            CheckBrewAura(self)
        elseif (event == "SPELL_UPDATE_COOLDOWN") then
            CheckBrewCharges(self)
        end
    end)

    BrewFrame:Hide()

    BrewFrame.Enable = EnableBrewFrame
    BrewFrame.Disable = DisableBrewFrame

    self.BrewDisplay = BrewFrame
end


local function EditChiDisplay(self)
    local Power = self.Power
    local Harmony = self.HarmonyBar
    local TotalWidth = Panels.CenterPanelWidth - 2*BorderSize

    Harmony.Backdrop:Kill()
    Harmony.Backdrop = nil

    Harmony:SetParent(Power)
    Harmony:SetFrameLevel(0)
    Harmony:ClearAllPoints()
    Harmony:SetSize(TotalWidth, NormalBarHeight)
    Harmony:SetPoint("TOP", Panels.UnitFrameAnchor, 0, -BorderSize)

    -- The Chi colour is hardcoded, so we have to resort to the old "I changed it and threw away the function"
    local c = T["Colors"]["power"]["CHI"]
    for _,bar in ipairs(Harmony) do
        bar:SetHeight(NormalBarHeight)
        bar:SetStatusBarColor(unpack(c))
        bar.SetStatusBarColor = function() end
    end

    local LastHarmony = nil
    for i,Bar in ipairs(Harmony) do
        -- Adjust size of last bar for even max chi (center for odd) to make it fit

        -- Ascension
        local EffectiveWidth = TotalWidth - 5*(2*BorderSize + FrameSpacing)
        if (i == 6) then
            Bar.Ascension = EffectiveWidth - 5*math.floor(EffectiveWidth / 6)
        else
            Bar.Ascension = math.floor(EffectiveWidth / 6)
        end

        -- Normal
        EffectiveWidth = TotalWidth - 4*(2*BorderSize + FrameSpacing)
        if (i == 3) then
            Bar.NoTalent = EffectiveWidth - 4*math.floor(EffectiveWidth / 5)
        else
            Bar.NoTalent = math.floor(EffectiveWidth / 5)
        end

        Bar:CreateBackdrop()
        Bar.Backdrop:SetOutside()
        if (LastHarmony) then
            Bar:SetPoint("LEFT", LastHarmony, "RIGHT", 2*BorderSize + FrameSpacing, 0)
        end
        LastHarmony = Bar
    end
end


local function CreateStaggerDisplay(self)
    local Power = self.Power
    local Stagger = CreateFrame('StatusBar', self:GetName().."StaggerBar", Power)

    Stagger:SetFrameLevel(0)
    Stagger:CreateBackdrop()
    Stagger:SetStatusBarTexture(T.GetTexture(C["Textures"]["General"]))
    Stagger:SetHeight(BMBarHeight)
    Stagger:SetPoint("BOTTOMLEFT", Power, "TOPLEFT", 0, FrameSpacing + 2*BorderSize)
    Stagger:SetPoint("BOTTOMRIGHT", Power, "TOPRIGHT", 0, FrameSpacing + 2*BorderSize)

    self.Stagger = Stagger
end


local function OnSpecUpdate(self)
    local Spec = GetSpecialization()
    local Power = self.Power
    Power:ClearAllPoints()
    if (Spec == BREWMASTER_SPEC_INDEX) then
        self.BrewDisplay:Enable()
        Power:SetHeight(BMBarHeight)
        Power:SetPoint("TOP", Panels.UnitFrameAnchor, 0, -(2*BMBarHeight + 5*BorderSize + 2*FrameSpacing))
    else
        self.BrewDisplay:Disable()
        Power:SetHeight(NormalBarHeight)
        if (Spec == WINDWALKER_SPEC_INDEX) then
            Power:SetPoint("TOP", Panels.UnitFrameAnchor, 0, -(NormalBarHeight + 3*BorderSize + FrameSpacing))
        else
            Power:SetPoint("BOTTOM", Panels.UnitFrameAnchor, "BOTTOM", 0, BorderSize)
        end
    end
end

TukuiUF.EditClassFeatures["MONK"] = function(self)
    NormalBarHeight = self.Power:GetHeight()

    EditChiDisplay(self)
    CreateStaggerDisplay(self)
    CreateBrewDisplay(self)

    self:RegisterEvent("PLAYER_TALENT_UPDATE", OnSpecUpdate, true)
end

TukuiUF.EditClassProfile["MONK"] = function(self, isRanged)
    OnSpecUpdate(self)
end
