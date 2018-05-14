local T, C, L = unpack(Tukui)

local AuraTimers = T["AuraTimers"]

local playerName = T.MyName
local MinCooldownTime = 1.5


local function UpdateBar(self, elapsed)
    if not self.TimeDirty then
        self.TimeLeft = self.TimeLeft - elapsed
    else
        self.TimeLeft = self.EndTime - GetTime()
        self.TimeDirty = false
    end

    if self.TimeLeft < 0 then
        if not self.IgnoreTime then
            if (self.OnFinished) then
                self:OnFinished()
            end
        end
    else
        self.Bar:SetValue(self.TimeLeft)
    end

    if self.Time then
        self.Elapsed = (self.Elapsed or 0) + elapsed
        if self.Elapsed >= 0.1 then
            self.Time:SetText(T.FormatTime(self.TimeLeft))
            self.Elapsed = 0
        end
    end
end


local function UpdateIcon(self, elapsed)
    self.Elapsed = (self.Elapsed or 0) + elapsed
    if self.Elapsed >= 0.1 then
        if not self.TimeDirty then
            self.TimeLeft = self.TimeLeft - self.Elapsed
        else
            self.TimeLeft = self.EndTime - GetTime()
            self.TimeDirty = false
        end
        self.Elapsed = 0
        if self.TimeLeft > 0 then
            local time = T.FormatTime(self.TimeLeft)
            self.Time:SetText(time)
            if self.TimeLeft <= 5 then
                self.Time:SetTextColor(0.99, 0.31, 0.31)
            else
                self.Time:SetTextColor(1, 1, 1)
            end
        elseif not self.IgnoreTime then
            if (self.OnFinished) then
                self:OnFinished()
            end
        end
    end
end


-- Returns true if EndTime has changed
local function UpdateBarSpellInfo(self, spell)
    local SpellChanged = (spell == self.Spell)

    if (SpellChanged == true) then
        self.Spell = spell
        if self.Icon then self.Icon:SetTexture(spell.Icon) end
    end

    if (spell.Count) then
        if (spell.Count > 1) then
            self.Name:SetText(("%s (%s)"):format(spell.Name, spell.Count))
        else
            self.Name:SetText(spell.Name)
        end
    elseif (SpellChanged == true) then
        self.Name:SetText(spell.Name)
    end

    if (spell.MultiBar) then
        if (spell.Count) then
            self.Bar:SetStatusBarColor(unpack(spell.ColorList[spell.Count + 1] or AuraTimers.DefaultColor))
            local r, g, b = unpack(spell.ColorList[spell.Count + 2] or {.3, .3, .3})
            self.Bar:SetBackdropColor(r, g, b, .5)
        else
            self.Bar:SetStatusBarColor(unpack(spell.ColorList[1] or AuraTimers.DefaultColor))
            self.Bar:SetBackdropColor(.3, .3, .3, .5)
        end
    else
        self.Bar:SetStatusBarColor(unpack(spell.Color or AuraTimers.DefaultColor))
        self.Bar:SetBackdropColor(.3, .3, .3, .5)
    end

    if (SpellChanged == true or self.EndTime ~= spell.EndTime) then
        self.EndTime = spell.EndTime
        self.Bar:SetMinMaxValues(0, spell.Duration)
        self.Finished = false
        self.TimeDirty = true
    end
end


-- Returns true if EndTime has changed
local function UpdateIconSpellInfo(self, spell)
    local SpellChanged = (spell == self.Spell)

    if (SpellChanged == true) then
        self.Spell = spell
        self.Icon:SetTexture(spell.Icon)
    end

    if (SpellChanged == true or self.EndTime ~= spell.EndTime) then
        self.EndTime = spell.EndTime
        self.CD:SetCooldown(spell.EndTime - spell.Duration, spell.Duration)
        self.Finished = false
        self.TimeDirty = true
    end
end


local function OnTimerFinished(self)
    self:GetParent():ClearTimer(self)
end


local function SpawnBarTimer(self)
    local Frame = CreateFrame("Frame", nil, self)
    Frame:Size(self.Width, self.Height)
    Frame:SetBackdrop(AuraTimers.Backdrop)
    Frame:SetBackdropColor(0, 0, 0)

    local Bar = CreateFrame("StatusBar", nil, Frame)
    Bar:Point("TOPLEFT", Frame)
    Bar:Point("BOTTOMRIGHT", Frame)
    Bar:SetStatusBarTexture(self.BarTexture, "ARTWORK")
    Bar:SetBackdrop({ bgFile = C.Medias.Blank })
    Bar:SetBackdropColor(0.3, 0.3, 0.3, 0.5)

    Frame.Bar = Bar

    if (self.ShowIcon == true) then
        Bar:Point("TOPLEFT", Frame, "TOPLEFT", self.Height + C.AuraTimers.BorderSize*2 + 1, 0)

        local Button = CreateFrame("Frame", nil, Frame)
        Button:Point("TOPLEFT", Frame)
        Button:Point("BOTTOMRIGHT", Frame, "BOTTOMLEFT", self.Height, 0)
        Button:SetBackdrop(AuraTimers.Backdrop)
        Button:SetBackdropColor(0, 0, 0)

        local Icon = Button:CreateTexture(nil, "ARTWORK")
        Icon:SetAllPoints()
        Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)

        Frame.Button = Button
        Frame.Icon = Icon
    end

    if (self.ShowName == true) then
        local Name = Bar:CreateFontString(nil, "OVERLAY")
        Name:SetFontObject(self.Font)
        Name:Point("LEFT", Bar, "LEFT", 2, 0)

        Frame.Name = Name
    end

    if (self.ShowTime == true) then
        local Time = Bar:CreateFontString(nil, "OVERLAY")
        Time:SetFontObject(self.Font)
        Time:Point("RIGHT", Bar, "RIGHT", -2, 0)
        Time:SetJustifyH("RIGHT")

        Frame.Time = Time
    end

    Frame.EndTime = 0
    Frame.IsActive = false
    Frame:Hide()

    Frame.UpdateSpellInfo = UpdateBarSpellInfo
    Frame.OnFinished = OnTimerFinished
    Frame:SetScript("OnUpdate", UpdateBar)

    return Frame
end


local function SpawnIconTimer(self)
    local Button = CreateFrame("Frame", nil, self)
    Button:Size(self.Width, self.Height)
    Button:SetBackdrop(AuraTimers.Backdrop)
    Button:SetBackdropColor(0, 0, 0)

    -- local Button = CreateFrame("Frame", nil, Frame)
    -- Button:SetAllPoints()
    -- Button:SetBackdrop(AuraTimers.Backdrop)
    -- Button:SetBackdropColor(0, 0, 0)

    local Icon = Button:CreateTexture(nil, "ARTWORK")
    Icon:SetAllPoints()
    Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)

    local CD = CreateFrame("Cooldown", nil, Button, "CooldownFrameTemplate")
    CD:SetAllPoints(Button)
    CD:SetReverse(true)
    CD.noCooldownCount = true -- hide since we make our own
    CD:SetHideCountdownNumbers(true)

    local OverlayFrame = CreateFrame("Frame", nil, Button)
    OverlayFrame:SetFrameLevel(CD:GetFrameLevel() + 1)

    local Time = OverlayFrame:CreateFontString(nil, "OVERLAY")
    Time:SetFontObject(self.Font)
    Time:Point("CENTER", Button)

    -- Frame:SetBackdrop({})
    -- Button:SetAlpha(0)

    Button.OverlayFrame = OverlayFrame
    Button.Icon = Icon
    Button.CD = CD
    Button.Time = Time

    Button.EndTime = 0
    Button.IsActive = false
    Button:Hide()

    Button.UpdateSpellInfo = UpdateIconSpellInfo
    Button.OnFinished = OnTimerFinished
    Button:SetScript("OnUpdate", UpdateIcon)

    return Button
end


local function UpdateHeader(self)
    if (self.ActiveTimersDirty == true) then
        self:UpdateActiveTimerPositions()
    end
end


local function UpdateActiveTimerPositions(self)
    local ChildAnchor = self.ChildAnchor
    local ParentAnchor = self.ParentAnchor
    local HorizSpacing = self.HorizSpacing
    local VertSpacing = self.VertSpacing
    local PrevTimer = nil

    for _,Timer in ipairs(self.ActiveTimers) do
        if not PrevTimer then
            Timer:Point(ChildAnchor, self, ChildAnchor)
        else
            Timer:Point(ChildAnchor, PrevTimer, ParentAnchor, HorizSpacing, VertSpacing)
        end
        PrevTimer = Timer
    end
    self.ActiveTimersDirty = false
end


local function ClearSpell(self, spell)
    spell.IsActive = false
    if (self.AlwaysShow == true) then
        return
    end

    for i, Timer in ipairs(self.ActiveTimers) do
        if (Timer.Spell == spell) then
            Timer:Hide()
            table.remove(self.ActiveTimers, i)
            table.insert(self.AvailableTimers, Timer)
            self.ActiveTimersDirty = true
            return
        end
    end
end


local function ClearTimer(self, timerToClear)
    timerToClear.Spell.IsActive = false
    if (self.AlwaysShow == true) then
        return
    end

    for i, Timer in ipairs(self.ActiveTimers) do
        if (timerToClear == Timer) then
            Timer:Hide()
            table.remove(self.ActiveTimers, i)
            table.insert(self.AvailableTimers, Timer)
            self.ActiveTimersDirty = true
            return
        end
    end
end


local function GetTimer(self, spell)
    for i, Timer in ipairs(self.ActiveTimers) do
        if (Timer.Spell == spell) then
            return Timer
        end
    end

    local Timer = table.remove(self.AvailableTimers)

    if (Timer == nil) then
        Timer = self:SpawnTimer()
    end

    Timer.Spell = spell
    return Timer
end


local function SetTimer(self, spell)
    local NewTimer = self:GetTimer(spell)
    NewTimer:UpdateSpellInfo(spell)
    spell.IsActive = true
    NewTimer:Show()

    if (NewTimer.TimeDirty == true) then
        self.ActiveTimersDirty = true

        for i,Timer in ipairs(self.ActiveTimers) do
            if (Timer == NewTimer) then
                table.remove(self.ActiveTimers, i)
                break
            end
        end

        for i,Timer in ipairs(self.ActiveTimers) do
            if ((Timer.EndTime > spell.EndTime) == self.SortReverse) then
                table.insert(self.ActiveTimers, i, NewTimer)
                return
            end
        end
        table.insert(self.ActiveTimers, NewTimer)
    end
end


local function CheckAuras(self, unitId)
    for _, Spell in ipairs(self.Auras) do
        if unitId == Spell.UnitId then
            local Name, Count, Duration, ExpTime, Caster
            Name, _, _, Count, _, Duration, ExpTime, Caster = UnitAura(Spell.UnitId, Spell.Name, nil, Spell.Filter)
            if Name then
                if (not Spell.Caster or Caster == Spell.Caster) then
                    if (Count ~= Spell.Count or EndTime ~= Spell.EndTime) then
                        Spell.Count = Count
                        Spell.Duration = Duration
                        Spell.EndTime = ExpTime
                        self:SetTimer(Spell)
                    end
                end
            elseif Spell.IsActive then
                self:ClearSpell(Spell)
            end
        end
    end
end


local function CheckCooldowns(self)
    local CurrentTime = GetTime()
    for _,Spell in ipairs(self.Cooldowns) do
        local StartTime, Duration
        if (Spell.SpellId) then
            _, _, StartTime, Duration = GetSpellCooldown(Spell.SpellId)
        else
            StartTime, Duration = GetInventoryItemCooldown("player", Spell.SlotId)
        end

        if (Duration > MinCooldownTime) then
            local EndTime = StartTime + Duration
            if (EndTime ~= Spell.EndTime) then
                Spell.EndTime = EndTime
                Spell.Duration = Duration
                self:SetTimer(Spell)
            end
        elseif (Spell.IsActive) then
            self:ClearSpell(Spell)
        end
    end
end


local function CheckChargeCooldowns(self)
    local CurrentTime = GetTime()
    for _, Spell in ipairs(self.ChargeCooldowns) do
        local Charges, MaxCharges, StartTime, Duration = GetSpellCharges(Spell.SpellId)

        if (Charges < MaxCharges) then
            local EndTime = StartTime + Duration
            if (Charges ~= Spell.Count or EndTime ~= Spell.EndTime) then
                Spell.Count = Charges
                Spell.EndTime = EndTime
                Spell.Duration = Duration
                self:SetTimer(Spell)
            end
        elseif (Spell.IsActive) then
            self:ClearSpell(Spell)
        end
    end
end


local function CheckTotem(self, slot)
    haveTotem, totemName, startTime, duration = GetTotemInfo(slot)
    print("TotemInfo:")
    print(haveTotem)
    print(totemName)
    print(startTime)
    print(duration)
end


local function CheckCombatLog(self, event, spellID, spellName)
    for i,Spell in ipairs(self.CombatLog) do
        if event == Spell.Event and spellID == Spell.SpellId then
            Spell.EndTime = GetTime() + Spell.Duration
            self:SetTimer(Spell)
        end
    end
end


local function HeaderOnEvent(self, event, ...)
    -- if not self.IsActive then return end

    if (event == "SPELL_UPDATE_COOLDOWN") then
        self:CheckCooldowns()
    elseif (event == "SPELL_UPDATE_CHARGES") then
        self:CheckChargeCooldowns()
    elseif (event == "UNIT_AURA") then
        local unitId = ...
        if (self.UnitIdList[unitId] == true) then
            self:CheckAuras(unitId)
        end
    elseif (event == "PLAYER_TARGET_CHANGED") then
        self:CheckAuras("target")
    elseif (event == "PLAYER_FOCUS_CHANGED") then
        self:CheckAuras("focus")
    elseif (event == "UNIT_PET") then
        local unitId = ...
        if (unitId == "player") then
            self:CheckAuras("pet")
        end
    -- elseif (event == "PLAYER_TOTEM_UPDATE") then
    --     local slot = ...
    --     CheckTotem(self, slot)
    elseif (event == "COMBAT_LOG_EVENT_UNFILTERED") then
        local _,event,_,_,sourceName,_,_,_,destName,_,_,spellID,spellName = ...
        if sourceName == playerName and destName == playerName then
            self:CheckCombatLog(event, spellID, spellName)
        end
    end
end


local function CheckAll(self)
    for unitId,val in pairs(self.UnitIdList) do
        if (val == true) then
            self:CheckAuras(unitId)
        end
    end
    self:CheckCooldowns()
    self:CheckChargeCooldowns()
    -- for slot = 1,MAX_TOTEMS do
    --     self:CheckTotem(slot)
    -- end
end


local function EnableHeader(self)
    if #self.Auras > 0 then
        self:RegisterEvent("UNIT_AURA")
        if self.UnitIdList["target"] then
            self:RegisterEvent("PLAYER_TARGET_CHANGED")
        end
        if self.UnitIdList["focus"] then
            self:RegisterEvent("PLAYER_FOCUS_CHANGED")
        end
        if self.UnitIdList["pet"] then
            self:RegisterEvent("UNIT_PET")
        end
    end

    if #self.Cooldowns > 0 then
        self:RegisterEvent("SPELL_UPDATE_COOLDOWN")
    end

    if #self.ChargeCooldowns > 0 then
        self:RegisterEvent("SPELL_UPDATE_CHARGES")
    end

    self:RegisterEvent("PLAYER_TOTEM_UPDATE")

    if #self.CombatLog > 0 then
        self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    end
end


local function DisableHeader(self)
    self:UnregisterAllEvents()

    -- clean up all timers
    for i, Timer in ipairs(self.ActiveTimers) do
        table.insert(self.AvailableTimers, Timer)
        self.ActiveTimers[i] = nil
    end

    for _, Spell in ipairs(self.Auras) do
        Spell.IsActive = false
    end

    for _, Spell in ipairs(self.Cooldowns) do
        Spell.IsActive = false
    end

    for _, Spell in ipairs(self.ChargeCooldowns) do
        Spell.IsActive = false
    end

    for _, Spell in ipairs(self.CombatLog) do
        Spell.IsActive = false
    end
end


function AuraTimers:SpawnTimerHeader(data)
    local Header = CreateFrame("Frame", "AuraTimer:"..data.Name, UIParent)

    Header.Width = data.Width
    Header.Height = data.Height
    Header.Font = T.GetFont(data.Font)

    if (data.Mode == "BAR") then
        Header.BarTexture = T.GetTexture(data.BarTexture)
    end

    if (data.ExtraOptions) then
        for option, val in pairs(data.ExtraOptions) do
            Header[option] = val
        end
    end

    Header:Size(data.Width, data.Height)
    Header:Point(unpack(data.AnchorPoint))
    if (data.ParentFrame) then
        Header:SetParent(data.ParentFrame)
    end

    Header.HorizSpacing = 0
    Header.VertSpacing = 0
    local TimerSpacing = (data.Spacing + 2*C.AuraTimers.BorderSize)
    if data.Direction == "DOWN" then
        Header.ChildAnchor = "TOP"
        Header.ParentAnchor = "BOTTOM"
        Header.VertSpacing = -TimerSpacing
    elseif data.Direction == "UP" then
        Header.ChildAnchor = "BOTTOM"
        Header.ParentAnchor = "TOP"
        Header.VertSpacing = TimerSpacing
    elseif data.Direction == "LEFT" then
        Header.ChildAnchor = "RIGHT"
        Header.ParentAnchor = "LEFT"
        Header.HorizSpacing = -TimerSpacing
    elseif data.Direction == "RIGHT" then
        Header.ChildAnchor = "LEFT"
        Header.ParentAnchor = "RIGHT"
        Header.HorizSpacing = TimerSpacing
    end

    Header.Auras = {}
    Header.UnitIdList = {}
    Header.Cooldowns = {}
    Header.ChargeCooldowns = {}
    Header.CombatLog = {}

    for _,Spell in ipairs(data) do
        if (Spell.Filter == "HELPFUL" or Spell.Filter == "HARMFUL") then
            table.insert(Header.Auras, Spell)
            Header.UnitIdList[Spell.UnitId] = true
        elseif (Spell.Filter == "COOLDOWN") then
            table.insert(Header.Cooldowns, Spell)
        elseif (Spell.Filter == "CHARGE_COOLDOWN") then
            table.insert(Header.ChargeCooldowns, Spell)
        elseif (Spell.Filter == "COMBAT_LOG") then
            table.insert(Header.CombatLog, Spell)
        end
    end

    Header.ActiveTimers = {}
    Header.AvailableTimers = {}

    -- functions
    Header.UpdateActiveTimerPositions = UpdateActiveTimerPositions
    Header.SetTimer = SetTimer
    Header.GetTimer = GetTimer
    Header.ClearSpell = ClearSpell
    Header.ClearTimer = ClearTimer
    Header.CheckAuras = CheckAuras
    Header.CheckCooldowns = CheckCooldowns
    Header.CheckChargeCooldowns = CheckChargeCooldowns
    Header.CheckCombatLog = CheckCombatLog
    Header.CheckAll = CheckAll
    Header.Enable = EnableHeader
    Header.Disable = DisableHeader

    if (data.Mode == "BAR") then
        Header.SpawnTimer = SpawnBarTimer
    else
        Header.SpawnTimer = SpawnIconTimer
    end

    Header:SetScript("OnEvent", HeaderOnEvent)
    Header:SetScript("OnUpdate", UpdateHeader)

    Header.ActiveTimersDirty = false
    return Header
end


function AuraTimers:SetDefaultSettings(data)
    for _,Header in ipairs(data) do
        if Header.Size then
            if (not Header.Width) then Header.Width = Header.Size end
            if (not Header.Height) then Header.Height = Header.Size end
        end
        if (not Header.Spacing) then Header.Spacing = 0 end

        if (Header.Mode == "BAR") then
            if (not Header.IconSpacing) then Header.IconSpacing = Header.Spacing end
        end

        for _,Spell in ipairs(Header) do
            local Name, Icon
            if Spell.SpellId then
                Name, _, Icon = GetSpellInfo(Spell.SpellId)
            else
                Name, _, _, _, _, _, _, _, _, Icon = GetItemInfo(GetInventoryItemLink("player", Spell.SlotId))
            end

            if (not Spell.Name) then Spell.Name = Name end
            Spell.Icon = Icon

            if (Spell.Filter == "BUFF") then
                Spell.Filter = "HELPFUL"
            elseif (Spell.Filter == "DEBUFF") then
                Spell.Filter = "HARMFUL"
            end

            if (Spell.MultiBar) then
                Spell.BgColorList = {}
                for i, Color in ipairs(Spell.ColorList) do
                    Spell.BgColorList[i] = {}
                    for j, x in ipairs(Color) do
                        Spell.BgColorList[i][j] = x*0.8
                    end
                end
            end
        end
    end
end


function AuraTimers:ShowHeaders()
    for _,Header in ipairs(self.Headers) do
        if (Header.IsActive and not Header:IsShown()) then
            Header:Show()
            Header:CheckAll()
        end
    end
end


function AuraTimers:HideHeaders()
    for _,Header in ipairs(self.Headers) do
        if (Header.IsActive and Header.HideOutOfCombat == true) then
            Header:Hide()
        end
    end
end


function AuraTimers:ToggleSpecTimers()
    local tree = GetSpecialization()
    local combat = InCombatLockdown()
    local spec = ""
    if (tree) then
        spec = select(2, GetSpecializationInfo(tree))
    end

    print("Loading AuraTimers for ".. spec)

    for _,Header in ipairs(self.Headers) do
        if (Header.AllowedSpecs and Header.AllowedSpecs[spec]) then
            if (not Header.IsActive) then
                Header.IsActive = true
                Header:Enable()
                if (combat or not Header.HideOutOfCombat) then
                    Header:Show()
                    Header:CheckAll()
                end
            end
        else
            if (Header.IsActive) then
                Header:Disable()
                Header:Hide()
                Header.IsActive = false
            end
        end
    end
end


function AuraTimers:OnEvent(event)
    if (event == "PLAYER_REGEN_ENABLED") then
        self:HideHeaders()
    elseif (event == "PLAYER_REGEN_DISABLED") then
        self:ShowHeaders()
    elseif (event == "ACTIVE_TALENT_GROUP_CHANGED") then
        self:ToggleSpecTimers()
    end
end


function AuraTimers:Enable()
    self:LoadSettings()

    local Data = C["AuraTimers"][T.MyClass]

    if (not Data) then return end

    self:SetDefaultSettings(Data)

    self.DefaultColor = T.Colors.class[T.MyClass]
    self.Backdrop = {
        bgFile = C.Medias.Blank,
        insets = { top =    -T.Scale(C.AuraTimers.BorderSize),
                   left =   -T.Scale(C.AuraTimers.BorderSize),
                   bottom = -T.Scale(C.AuraTimers.BorderSize),
                   right =  -T.Scale(C.AuraTimers.BorderSize) },
    }

    self.Headers = {}
    for _,HeaderData in ipairs(Data) do
        local Header = self:SpawnTimerHeader(HeaderData)
        Header:Hide()
        Header.IsActive = false
        table.insert(self.Headers, Header)
    end

    self:ToggleSpecTimers()

    self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
    self:RegisterEvent("PLAYER_REGEN_ENABLED")
    self:RegisterEvent("PLAYER_REGEN_DISABLED")
    self:SetScript("OnEvent", self.OnEvent)
end