--My own Buff Timers (in icon form)
local T, C, L = unpack(Tukui)

-- TODO: (honestly it looks like a bit of a rewrite is needed)
--   Give config its own file
--   Make it behave like a Tukui module
--   Create Mechanism to Load this addon after Tukui is loaded (so I can parent to Tukui frames if I want)
--   Use Tukui GetTexture and GetFont stuff
--   Give bars backdrops like unit frames (stop using set template)
--   Clean up useless stuff (ticks, background)
--   Localise frequently used functions
--   Consider making bar and icon creation separate functions
--   Instead of CheckAuras(nil), call CheckAuras once for each unit in the unitIdList
--   Handle inventory changes



-- For testing
-- Provide argument to get a specific spell id
-- No argument will print all spell ids
function GetSpellId(spellName)
    local name, last
    for i = 1, 500, 1 do
        name = GetSpellBookItemName(i, BOOKTYPE_SPELL)
        if not name then break end
        if name ~= last then
            local stype, id = GetSpellBookItemInfo(i, BOOKTYPE_SPELL)
            last = name
            if not spellName or spellName == name then
                print(name, id)
            end
        end
    end
end


local INVENTORY_IDS = {
    ammo = 0, head = 1, neck = 2,
    shoulder = 3, shirt = 4, chest = 5,
    waist = 6, legs = 7, feet = 8, wrist = 9,
    hands = 10, finger1 = 11, finger2 = 12,
    trinket1 = 13, trinket2 = 14, back = 15,
    mainhand = 16, offhand = 17, ranged = 18,
    tabard = 19
}

local txtFont = C["Medias"].Express
local statusBarTex = C["Medias"].Blank
local defaultColor = T.Colors.class[T.MyClass]
local playerName = T.MyName



C["MyBuffTimers"] = {
    -- ["SHAMAN"] = {
    --     {
            -- Name = "ShamanTargetTimers",
            -- Direction = "DOWN",
            -- SortReverse = true,
            -- Width = 239,
            -- Height = 22,
            -- Spacing = 1,
            -- SetPointData = { "TOPLEFT", UIParent, "CENTER", -170, -270 },
            -- Mode = "BAR",
            -- HideOutOfCombat = false,
            -- ShowName = true,
            -- ShowTime = true,

            -- Flame Shock
            -- { spellId = 188389, unitId = "target", caster = "player", filter = "DEBUFF" },

    --     }
    -- }
}


if not C["MyBuffTimers"][T.MyClass] then return; end



-- Defaults and getting spell info
for i,data in ipairs(C["MyBuffTimers"][T.MyClass]) do
    if data.Size then
        data.Width = data.Size
        data.Height = data.Size
    end
    if not data.Spacing then data.Spacing = 0; end
    if data.HideOutOfCombat == nil then data.HideOutOfCombat = false; end

    if data.Mode == "BAR" then
        if not data.IconSpacing then data.IconSpacing = data.Spacing; end
        if data.ShowIcon == nil then data.ShowIcon = true; end
    end


    for j,spell in ipairs(data) do
        if spell.filter == "COOLDOWN" and not spell.GCD then
            spell.GCD = false
        end

        local spellName, spellIcon
        if spell.spellId then
            spellName, _, spellIcon = GetSpellInfo(spell.spellId)
        else
            spellName, _, _, _, _, _, _, _, _, spellIcon = GetItemInfo(GetInventoryItemLink("player", spell.slotId))
        end

        if not spell.name then spell.name = spellName; end
        spell.icon = spellIcon
    end
end


local function InsertFrame(self, frameToInsert)
    local endTime = frameToInsert.endTime
    for i, frame in ipairs(self.activeFrames) do
        if frame.endTime > endTime == self.SortReverse then
            table.insert(self.activeFrames, i, frameToInsert)
            return
        end
    end
    table.insert(self.activeFrames, frameToInsert)
end


-- Remove frame from active frames if it is there
local function RemoveFrame(self, frameToRemove)
    for i, frame in ipairs(self.activeFrames) do
        if frame == frameToRemove then
            table.remove(self.activeFrames, i)
            return
        end
    end
end


local function UpdateFrames(self, frameToUpdate)
    -- If we are given a frame to update then remove and re-insert it
    if frameToUpdate then
        self:RemoveFrame(frameToUpdate)
        if frameToUpdate.isActive then
            self:InsertFrame(frameToUpdate)
        end
    end

    local childPoint, parentPoint, xSpacing, ySpacing, prevFrame, bgxSpacing, bgySpacing

    xSpacing, ySpacing, bgxSpacing, bgySpacing = 0, 0, 0, 0
    if self.direction == "DOWN" then
        childPoint = "TOP"
        parentPoint = "BOTTOM"
        ySpacing = -self.spacing
        bgySpacing = -1
    elseif self.direction == "UP" then
        childPoint = "BOTTOMLEFT"
        parentPoint = "TOPLEFT"
        ySpacing = self.spacing
        bgySpacing = 1
    elseif self.direction == "LEFT" then
        childPoint = "RIGHT"
        parentPoint = "LEFT"
        xSpacing = -self.spacing
        bgxSpacing = -1
    elseif self.direction == "RIGHT" then
        childPoint = "LEFT"
        parentPoint = "RIGHT"
        xSpacing = self.spacing
        bgxSpacing = 1
    end
    for i, frame in ipairs(self.activeFrames) do
        if not prevFrame then
            frame:Point(childPoint, self, childPoint)
        else
            frame:Point(childPoint, prevFrame, parentPoint, xSpacing, ySpacing)
        end
        prevFrame = frame
    end
    if self.background then
        if prevFrame then
            self.background:Show()
            self.background:Point(parentPoint, prevFrame, parentPoint, bgxSpacing, bgySpacing)
        else
            self.background:Hide()
        end
    end
end



local function CheckAuras(self, unitId)
    if not unitId or self.unitIdList[unitId] then
        for i, frame in ipairs(self.auras) do
            local spell = frame.spell
            if not unitId or unitId == spell.unitId then
                local name, count, duration, expTime, caster
                if spell.filter == "BUFF" then
                    name, _, _, count, _, duration, expTime, caster = UnitBuff(spell.unitId, spell.name)
                elseif spell.filter == "DEBUFF" then
                    name, _, _, count, _, duration, expTime, caster = UnitDebuff(spell.unitId, spell.name)
                end
                if name then
                    if not spell.caster or caster == spell.caster then
                        repeat -- Use repeat to achieve weird control flow
                        if not frame.isActive then
                            frame.isActive = true
                            frame:Show()
                        elseif frame.endTime == expTime then
                            break -- This is basically a goto "until true"
                        end

                        if frame.name then
                            if count > 1 then
                                frame.name:SetText(("%s (%s)"):format(name, count))
                            else
                                frame.name:SetText(name)
                            end
                        end

                        self:SetFrameEndTime(frame, expTime, duration)
                        self:UpdateFrames(frame)
                        until true
                    end
                elseif frame.isActive then
                    frame:Hide()
                    frame.isActive = false
                    self:UpdateFrames(frame)
                end
            end
        end
    end
end


local function CheckCooldowns(self)
    local currentTime = GetTime()
    for i, frame in ipairs(self.cooldowns) do
        local spell = frame.spell

        local startTime, duration
        if spell.spellId then
            startTime, duration = GetSpellCooldown(spell.spellId)
        else
            startTime, duration = GetInventoryItemCooldown("player", spell.slotId)
        end
        -- print(spell.name, startTime, duration)
        if duration > 1.5 or spell.GCD then
            local endTime = startTime + duration
            repeat -- Use repeat to achieve wierd control flow
                if not frame.isActive then
                    frame.isActive = true
                    frame:Show()
                elseif frame.endTime == endTime then
                    break -- This is basically a goto
                end

                self:SetFrameEndTime(frame, endTime, duration)
                self:UpdateFrames(frame)
            until true
        elseif frame.isActive then
            frame:Hide()
            frame.isActive = false
            self:UpdateFrames(frame)
        end
    end
end


local function CheckCombatLog(self, event, spellID, spellName)
    for i, frame in ipairs(self.combat_log) do
        local spell = frame.spell
            if event == spell.event and spellID == spell.spellId then
            if not frame.isActive then
                frame.isActive = true
                frame:Show()
            end
            if frame.name then
                frame.name:SetText(spellName)
            end
            self:SetFrameDuration(frame, spell.duration)
            self:UpdateFrames(frame)
        end
    end
end

local function OnEvent(self, event, ...)
    if not self.isActive then return; end

    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local _,event,_,_,sourceName,_,_,_,destName,_,_,spellID,spellName = ...
        if sourceName == playerName and destName == playerName then
            self:CheckCombatLog(event, spellID, spellName)
        end
    elseif event == "SPELL_UPDATE_COOLDOWN" then
        self:CheckCooldowns()
    elseif event == "UNIT_AURA" then
        local unitId = ...
        self:CheckAuras(unitId)
    elseif event == "PLAYER_TARGET_CHANGED" then
        self:CheckAuras("target")
    elseif event == "PLAYER_FOCUS_CHANGED" then
        self:CheckAuras("focus")
    elseif event == "UNIT_PET" then
        local unitId = ...
        if unitId == "player" then
            self:CheckAuras("pet")
        end
    else
        self:CheckAuras(nil)
        self:CheckCooldowns()
    end
end

local function SetBarDuration(self, frame, duration)
    local startTime = GetTime()
    frame.endTime = startTime + duration
    frame.bar:SetMinMaxValues(0, duration)
    -- frame.timeScale = min(self.tickScale, self.nonticksWidthScale / (duration - self.ticksDuration))
    frame.timeDirty = true
end

local function SetBarEndTime(self, frame, endTime, duration)
    frame.endTime = endTime
    frame.bar:SetMinMaxValues(0, duration)
    -- frame.timeScale = min(self.tickScale, self.nonticksWidthScale / (duration - self.ticksDuration))
    frame.timeDirty = true
end

local function SetIconEndTime(self, frame, endTime, duration)
    frame.endTime = endTime
    frame.cd:SetCooldown(endTime - duration, duration)
    frame.timeDirty = true
end

-- Stealing CreateAuraTimer from Tukui functions
-- Returns true when time is up
local function IconUpdate(self, elapsed)
    self.elapsed = (self.elapsed or 0) + elapsed
    if self.elapsed >= 0.1 then
        if not self.timeDirty then
            self.timeLeft = self.timeLeft - self.elapsed
        else
            self.timeLeft = self.endTime - GetTime()
            self.timeDirty = false
        end
        self.elapsed = 0
        if self.timeLeft > 0 then
            local time = T.FormatTime(self.timeLeft)
            self.remaining:SetText(time)
            if self.timeLeft <= 5 then
                self.remaining:SetTextColor(0.99, 0.31, 0.31)
            else
                self.remaining:SetTextColor(1, 1, 1)
            end
        elseif not self.ignoreTime then
            return true
        end
    end
    return false
end

-- Returns true when time is up
local function BarUpdate(self, elapsed)
    if not self.timeDirty then
        self.timeLeft = self.timeLeft - elapsed
    else
        self.timeLeft = self.endTime - GetTime()
        self.timeDirty = false
    end

    if self.timeLeft < 0 then
        if not self.ignoreTime then
            return true
        end
    -- Ignore the tick stuff for now, I'm not using it
    -- elseif self.timeLeft >= self.ticksDuration then
    --     frame.bar:SetValue(self.ticksWidthScale + self.timeScale * (self.timeLeft - self.ticksDuration))
    -- else
    --     frame.bar:SetValue(self.tickScale * self.timeLeft)
    else
        self.bar:SetValue(self.timeLeft)
    end

    if self.bar.time then
        self.elapsed = (self.elapsed or 0) + elapsed
        if self.elapsed >= 0.1 then
            self.bar.time:SetText(T.FormatTime(self.timeLeft))
            self.elapsed = 0
        end
    end
    return false
end


local function UpdateAllBars(self, elapsed)
    for _, frame in ipairs(self.activeFrames) do
        local timerEnded = BarUpdate(frame, elapsed)
        if timerEnded then
            frame:Hide()
            frame.isActive = false
            self:UpdateFrames(frame)
        end
    end
end

local function UpdateAllIcons(self, elapsed)
    for _, frame in ipairs(self.activeFrames) do
        local timerEnded = IconUpdate(frame, elapsed)
        if timerEnded then
            frame:Hide()
            frame.isActive = false
            self:UpdateFrames(frame)
        end
    end
end


anchors = {}
local function loadBuffTimers()
    anchor = {}

    for i,data in ipairs(C["MyBuffTimers"][T.MyClass]) do
        local anchor = CreateFrame("Frame", "BuffTimerAnchor"..i, UIParent)
        anchor.Name = data.Name
        anchor:Size(data.Width, data.Height)
        anchor.direction = data.Direction
        anchor.spacing = data.Spacing
        anchor.HideOutOfCombat = data.HideOutOfCombat
        if data.SortReverse == true then anchor.SortReverse = true else anchor.SortReverse = false end

        anchor:Point(unpack(data.SetPointData))
        anchor:SetFrameLevel(3)

        if data.Mode == "BAR" then
            local bg = CreateFrame("Frame", "BuffTimerAnchor"..i.."BG", anchor)
            bg:Point("TOPLEFT", anchor, "TOPLEFT", -1, 1)
            bg:Point("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", 1, -1)
            bg:SetTemplate("Transparent")
            bg:CreateShadow("Default")
            bg:SetFrameLevel(1)
            bg:Kill()

            if data.Ticks then
                anchor.ticks = {}
                for i = 1,data.Ticks.num do
                    local tick = anchor:CreateTexture()
                    tick:SetTexture(C.Medias.blank)
                    tick:SetVertexColor(0, 0, 0, .5)
                    tick:Size(data.Ticks.tickSize)
                    tick:Point("TOP", bg, "TOPLEFT", i * data.Ticks.tickSpacing, -1)
                    tick:Point("BOTTOM", bg, "BOTTOMLEFT", i * data.Ticks.tickSpacing, 1)
                    anchor.ticks[i] = tick
                end
            end

            anchor.background = bg

            anchor.ticksWidthScale = 0
            anchor.tickScale = 1                -- Time scaling in ticks section
            anchor.ticksDuration = 0            -- Duration of all ticks combined
            anchor.nonticksWidthScale = 1       -- Factor by which to scale total duration to obtain time scale during ticks
            if data.Ticks then
                local ticksWidthScale = data.Ticks.tickSpacing * data.Ticks.num / data.Width
                anchor.ticksWidthScale = ticksWidthScale
                anchor.ticksDuration = data.Ticks.timePerTick * data.Ticks.num
                anchor.tickScale = ticksWidthScale / anchor.ticksDuration
                anchor.nonticksWidthScale = 1 - ticksWidthScale
            end
        end

        anchor.auras = {}
        anchor.cooldowns = {}
        anchor.combat_log = {}

        local prevFrame = nil
        for j,spell in ipairs(data) do

            local frame = CreateFrame("Frame", "BuffTimer".. i.. "_".. j, anchor)
            frame.spell = spell
            frame:Size(data.Width, data.Height)
            if spell.ignoreTime == true then frame.ignoreTime = true; end

            if data.Mode == "ICON" then
                frame:SetTemplate("Border")

                local icon = frame:CreateTexture("$parentIcon", "ARTWORK")
                icon:Point("TOPLEFT", frame, "TOPLEFT", 2, -2)
                icon:Point("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -2, 2)
                icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
                icon:SetTexture(spell.icon)

                local cd = CreateFrame("Cooldown", nil,  frame)
                cd:SetAllPoints(icon)
                cd:SetReverse(true)
                cd.noOCC = true -- hide OmniCC CDs, because we  create our own cd with CreateAuraTimer()
                cd.noCooldownCount = true -- hide CDC CDs, because we create our own cd with CreateAuraTimer()

                frame.icon = icon
                frame.cd = cd

                frame.remaining = T.SetFontString(frame, txtFont, C["unitframes"].auratextscale, "THINOUTLINE")
                frame.remaining:Point("CENTER", 1, 0)

                frame.overlayFrame = CreateFrame("frame", nil, frame, nil)
                frame.overlayFrame:SetFrameLevel(frame.cd:GetFrameLevel() + 1)
                frame.remaining:SetParent(frame.overlayFrame)

            elseif data.Mode == "BAR" then
                local bar = CreateFrame("StatusBar", "$parentBar", frame)
                bar:SetMinMaxValues(0, 1)
                bar:Point("TOPLEFT", frame, "TOPLEFT", 2, -2)
                bar:Point("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -2, 2)
                bar:SetStatusBarTexture(statusBarTex, "ARTWORK")
                bar:SetStatusBarColor(unpack(spell.color or defaultColor))
                bar:SetFrameLevel(2)

                bar.bg = bar:CreateTexture(nil, 'BORDER')
                bar.bg:Point("TOPLEFT", -2, 2)
                bar.bg:Point("BOTTOMRIGHT", 2, -2)
                bar.bg:SetTexture(0, 0, 0)

                if data.ShowIcon == true then
                    bar:Point("TOPLEFT", frame, "TOPLEFT", data.Height + 3, -2)

                    local icon = CreateFrame("Frame", nil, frame)
                    icon:Point("TOPLEFT", frame, "TOPLEFT")
                    icon:Point("BOTTOMRIGHT", frame, "BOTTOMLEFT", data.Height, 0)
                    icon:SetTemplate("Default")

                    icon.tex = icon:CreateTexture("$parentIcon", "ARTWORK")
                    icon.tex:Point("TOPLEFT",icon, 2, -2)
                    icon.tex:Point("BOTTOMRIGHT", icon, -2, 2)
                    icon.tex:SetTexCoord(0.1, 0.9, 0.1, 0.9)
                    icon.tex:SetTexture(spell.icon)

                    frame.icon = icon
                end

                if data.ShowName == true then
                    bar.name = T.FontString(bar, nil, txtFont, 11, "THINOUTLINE")
                    bar.name:Point("LEFT", bar, "LEFT", 2, 0)
                    bar.name:SetText(spell.name)
                    frame.name = bar.name
                end

                if data.ShowTime == true and frame.ignoreTime ~= true then
                    bar.time = T.FontString(bar, nil, txtFont, 11, "THINOUTLINE")
                    bar.time:Point("RIGHT", bar, "RIGHT", -2, 0)
                    bar.time:SetJustifyH("RIGHT")
                end

                frame.bar = bar
            end

            frame.endTime = 0           -- Time at which buff/cd ends
            frame.isActive = false
            frame:Hide()

            if spell.filter == "BUFF" or spell.filter == "DEBUFF" then
                table.insert(anchor.auras, frame)
            elseif spell.filter == "COOLDOWN" then
                table.insert(anchor.cooldowns, frame)
            elseif spell.filter == "COMBAT_LOG" then
                table.insert(anchor.combat_log, frame)
            end

            prevFrame = frame
        end

        if not anchor.InsertFrame then anchor.InsertFrame = InsertFrame; end
        if not anchor.RemoveFrame then anchor.RemoveFrame = RemoveFrame; end
        if not anchor.UpdateFrames then anchor.UpdateFrames = UpdateFrames; end
        if not anchor.CheckAuras then anchor.CheckAuras = CheckAuras; end
        if not anchor.CheckCooldowns then anchor.CheckCooldowns = CheckCooldowns; end
        if not anchor.CheckCombatLog then anchor.CheckCombatLog = CheckCombatLog; end
        if not anchor.SetFrameEndTime then
            if data.Mode == "BAR" then
                anchor.SetFrameEndTime = SetBarEndTime
            elseif data.Mode == "ICON" then
                anchor.SetFrameEndTime = SetIconEndTime
            end
        end
        if not anchor.SetFrameDuration then
            if data.Mode == "BAR" then
                anchor.SetFrameDuration = SetBarDuration
            end
        end

        if #anchor.auras > 0 then
            local unitIdList = {}
            for i,aura in ipairs(anchor.auras) do
                local unitId = aura.spell.unitId
                if not unitIdList[unitId] then
                    unitIdList[unitId] = true
                end
            end
            anchor:RegisterEvent("UNIT_AURA")
            if unitIdList["target"] then
                anchor:RegisterEvent("PLAYER_TARGET_CHANGED")
            end
            if unitIdList["focus"] then
                anchor:RegisterEvent("PLAYER_FOCUS_CHANGED")
            end
            if unitIdList["pet"] then
                anchor:RegisterEvent("UNIT_PET")
            end
            anchor.unitIdList = unitIdList
        end

        if #anchor.cooldowns > 0 then
            anchor:RegisterEvent("SPELL_UPDATE_COOLDOWN")
        end

        if #anchor.combat_log > 0 then
            anchor:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        end

        anchor:SetScript("OnEvent", OnEvent)

        if data.Mode == "BAR" then
            anchor:SetScript("OnUpdate", UpdateAllBars)
        elseif data.Mode == "ICON" then
            anchor:SetScript("OnUpdate", UpdateAllIcons)
        end

        anchor.activeFrames = {}
        anchor:Show()
        anchor.isActive = true
        anchors[i] = anchor
    end
end

local function ShowAll(event)
    for _, anchor in ipairs(anchors) do
        anchor:Show()
        anchor.isActive = true
        OnEvent(anchor, event)
    end
end

local function HideAll()
    for _, anchor in ipairs(anchors) do
        if anchor.HideOutOfCombat then
            anchor.isActive = false
            anchor:Hide()
        end
    end
end

local CombatCheck = CreateFrame("Frame", nil, UIParent)
CombatCheck:RegisterEvent("PLAYER_ENTERING_WORLD")
CombatCheck:RegisterEvent("PLAYER_REGEN_ENABLED")
CombatCheck:RegisterEvent("PLAYER_REGEN_DISABLED")

CombatCheck:SetScript("OnEvent", function (self, event)
    if event == "PLAYER_REGEN_ENABLED" then
        HideAll()
    elseif event == "PLAYER_REGEN_DISABLED" then
        ShowAll(event)
    else
        loadBuffTimers()
        ShowAll(event)
        if not InCombatLockdown() then
            HideAll()
        end
    end
end)
