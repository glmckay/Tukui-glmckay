local T, C, L = Tukui:unpack()

local Panels = T["Panels"]
local TukuiUF = T["UnitFrames"]

local FrameSpacing = C.General.FrameSpacing

-- Localised globals
local gsub = gsub
local format = format
local UnitIsConnected = UnitIsConnected
local UnitIsGhost = UnitIsGhost
local UnitIsDead = UnitIsDead


-- UnitFrame dimensions
TukuiUF.FrameHeight = 32
TukuiUF.TargetAuraSize = 29
TukuiUF.TargetAurasPerRow = 8
TukuiUF.PlayerTargetWidth = TukuiUF.TargetAuraSize*TukuiUF.TargetAurasPerRow + FrameSpacing*(TukuiUF.TargetAurasPerRow - 1)
TukuiUF.PetTotWidth = 90
TukuiUF.OtherHeight = 30
TukuiUF.OtherWidth = 200
TukuiUF.PowerHeight = 2


-- Empty table for class specific functions
TukuiUF.EditClassFeatures = {}


-- Notes: 1- The Tukui version of ShortValue uses a local "Value" which seems unnecessary
--           I left it out, maybe something weird will happen so I can learn why it was there.
--        2- Conditionals are (hopefully) ordered from most to least likely
function TukuiUF:ShortValue()
    if self < 1e3 then
        return self
    elseif self < 2e4 then
        return gsub(format("%.1fK", self / 1e3), "%.?0+([KMB])$", "%1")
    elseif self < 1e6 then
        return ("%dK"):format(self / 1e3)
    elseif self < 2e7 then
        return gsub(format("%.1fM", self / 1e6), "%.?0+([KMB])$", "%1")
    elseif self < 1e9 then
        return format("%dM", self / 1e6)
    elseif self < 2e10 then
        return gsub(format("%.1fB", self / 1e9), "%.?0+([KMB])$", "%1")
    else
        return format("%dB", self / 1e9)
    end
end


function TukuiUF:PlayerTargetPostUpdateHealth(unit, min, max)
    if (not UnitIsConnected(unit)) then
        self.Value:SetText("|cffD7BEA5"..FRIENDS_LIST_OFFLINE.."|r")
    elseif (UnitIsDead(unit)) then
        self.Value:SetText("|cffD7BEA5"..DEAD.."|r")
    elseif (UnitIsGhost(unit)) then
        self.Value:SetText("|cffD7BEA5"..L.UnitFrames.Ghost.."|r")
    else
        self.Value:SetText(TukuiUF.ShortValue(min))
        self.Percent:SetFormattedText("%s%%", floor(min / max * 100))
    end
end

-- Remove this function
function TukuiUF:UpdateNamePosition()
end


-- Create a macro-style conditional for the player's roles (cache the string since it won't change)
--  Conditional returns same strings as GetSpecializationRole ("TANK", "DAMAGER", "HEALER") or "ERROR" (shouldn't happen)
function TukuiUF:GetRoleConditional()
    if (not self._RoleConditionalString) then
        local NumSpecs = GetNumSpecializations()
        local RoleSpecs = {}
        for spec = 1,NumSpecs do
            local role = GetSpecializationRole(spec)
            if (RoleSpecs[role]) then
                table.insert(RoleSpecs[role], spec)
            else
                RoleSpecs[role] = { spec }
            end
        end

        local FullString = ""
        for role,specs in pairs(RoleSpecs) do
            FullString = string.format("[spec:%s]%s; ERROR", table.concat(specs, "][spec:"), role) .. FullString
        end
        self._RoleConditionalString = FullString
    end
    return self._RoleConditionalString
end


function TukuiUF:CheckInterrupt(unit)
    if (unit == "vehicle") then
        unit = "player"
    end

    if (self.notInterruptible and UnitCanAttack("player", unit)) then
        self:SetStatusBarColor(0.87, 0.37, 0.37, 1)
    else
        self:SetStatusBarColor(0.31, 0.45, 0.63, 1)

    end
end


local function CreateUnits(self)
    if (C.UnitFrames.Enable) then
        local Player = self.Units.Player
        local Target = self.Units.Target
        local ToT = self.Units.TargetOfTarget
        local Pet = self.Units.Pet
        local Focus = self.Units.Focus
        local FocusTarget = self.Units.FocusTarget

        Player:ClearAllPoints()
        Player:SetParent(Panels.UnitFrameAnchor)
        Player:Point("LEFT", Panels.UnitFrameAnchor)
        Player:Size(self.PlayerTargetWidth, self.FrameHeight)

        Target:ClearAllPoints()
        Target:Point("RIGHT", Panels.UnitFrameAnchor)
        Target:Size(self.PlayerTargetWidth, self.FrameHeight)

        Pet:ClearAllPoints()
        Pet:SetParent(Panels.UnitFrameAnchor)
        Pet:Point("RIGHT", Panels.UnitFrameAnchor, "LEFT", -FrameSpacing, 0)
        Pet:Size(self.PetTotWidth, self.FrameHeight)

        ToT:ClearAllPoints()
        ToT:SetParent(Panels.UnitFrameAnchor)
        ToT:Point("LEFT", Panels.UnitFrameAnchor, "RIGHT", FrameSpacing, 0)
        ToT:Size(self.PetTotWidth, self.FrameHeight)

        Focus:ClearAllPoints()
        Focus:Point("TOPRIGHT", UIParent, "CENTER", -415, 300)
        Focus:Size(self.OtherWidth, self.OtherHeight)

        FocusTarget:ClearAllPoints()
        FocusTarget:Point("TOP", Focus, "BOTTOM", 0, -35)
        FocusTarget:Size(self.OtherWidth, self.OtherHeight)

        if (C.UnitFrames.Arena) then
            local Arena = TukuiUF.Units.Arena

            for i = 1, 5 do
                Arena[i]:ClearAllPoints()
                if (i == 1) then
                    Arena[i]:Point("TOPLEFT", UIParent, "CENTER", 485, -30)
                else
                    Arena[i]:Point("BOTTOM", Arena[i-1], "TOP", 0, 32)
                end
                Arena[i]:Size(self.OtherWidth, self.OtherHeight)
            end
        end

        if (C.UnitFrames.Boss) then
            local Boss = TukuiUF.Units.Boss

            for i = 1, 5 do
                Boss[i]:ClearAllPoints()
                if (i == 1) then
                    Boss[i]:Point("TOPLEFT", UIParent, "CENTER", 485, -30)
                else
                    Boss[i]:Point("BOTTOM", Boss[i-1], "TOP", 0, 32)
                end
                Boss[i]:Size(self.OtherWidth, self.OtherHeight)
            end
        end

        if (C.Raid.Enable) then
            local Raid = TukuiUF.Headers.Raid

            if (C.Raid.ShowPets) then
                local Pets = TukuiUF.Headers.RaidPet

                Pets:ClearAllPoints()
                Pets:Point("TOPRIGHT", Raid, "TOPLEFT", -FrameSpacing, 0)
            end
        end
    end

    if (C.NamePlates.Enable) then
        -- Nameplate stuff
    end
end


function TukuiUF:GetPartyFramesAttributes()
    return
        "TukuiParty",
        nil,
        "solo,party",
        "oUF-initialConfigFunction", [[
            local header = self:GetParent()
            self:SetWidth(header:GetAttribute("initial-width"))
            self:SetHeight(header:GetAttribute("initial-height"))
        ]],
        "initial-width", self.PartyListWidth,
        "initial-height", self.PartyListHeight,
        "showSolo", C["Party"].ShowSolo,
        "showParty", true,
        "showPlayer", C["Party"].ShowPlayer,
        "showRaid", true,
        "groupFilter", "1,2,3,4,5,6,7,8",
        "groupingOrder", "1,2,3,4,5,6,7,8",
        "groupBy", "GROUP",
        "point", "LEFT",
        "xOffset", T.Scale(FrameSpacing),
        "yOffset", T.Scale(-FrameSpacing)
end


function TukuiUF:GetRaidFramesAttributes()
    local Properties = C.Party.Enable and "raid" or "solo,party,raid"
    -- local Properties = string.format("custom %s show;hide", self:GetHealerConditional())

    return
        "TukuiRaid",
        nil,
        Properties,
        "oUF-initialConfigFunction", [[
            local header = self:GetParent()
            self:SetWidth(header:GetAttribute("initial-width"))
            self:SetHeight(header:GetAttribute("initial-height"))
        ]],
        "initial-width", self.GridWidth,
        "initial-height", self.GridMaxHeight,
        "showParty", true,
        "showRaid", true,
        "showPlayer", true,
        "showSolo", C["Raid"].ShowSolo,
        "xoffset", T.Scale(FrameSpacing),
        "yOffset", T.Scale(-FrameSpacing),
        "point", "LEFT",
        "groupFilter", "1,2,3,4,5,6,7,8",
        "groupingOrder", "1,2,3,4,5,6,7,8",
        "groupBy", C["Raid"].GroupBy.Value,
        "maxColumns", math.ceil( 40 / C["Raid"].MaxUnitPerColumn),
        "unitsPerColumn", C["Raid"].MaxUnitPerColumn,
        "columnSpacing", T.Scale(FrameSpacing),
        "columnAnchorPoint", "TOP"
end


function TukuiUF:GetPetRaidFramesAttributes()
    local Properties = C.Party.Enable and "custom [@raid6,exists] show;hide" or "custom [@raid26,exists] hide;show"

    return
        "TukuiRaidPet",
        "SecureGroupPetHeaderTemplate",
        Properties,
        "showParty", false,
        "showRaid", C["Raid"].ShowPets,
        "showSolo", false, -- testing
        "maxColumns", math.ceil(40 / C["Raid"].MaxUnitPerColumn),
        "point", "TOP",
        "unitsPerColumn", C["Raid"].MaxUnitPerColumn,
        "columnSpacing", T.Scale(FrameSpacing),
        "columnAnchorPoint", "RIGHT",
        "xOffset", T.Scale(FrameSpacing),
        "yOffset", T.Scale(-FrameSpacing),
        "initial-width", self.GridWidth,
        "initial-height", self.GridMaxHeight,
        "oUF-initialConfigFunction", [[
            local header = self:GetParent()
            self:SetWidth(header:GetAttribute("initial-width"))
            self:SetHeight(header:GetAttribute("initial-height"))
        ]]
end


-- Skin Auras
local function PostCreateAura(self, button)
    -- button:HideInsets()
    button.cd:SetInside()
    button.icon:SetInside()
end


function TukuiUF:UpdateDebuffsHeaderPosition()
    local NumBuffs = self.visibleBuffs
    local Row = math.ceil((NumBuffs / self.numRow))
    local Debuffs = self:GetParent().Debuffs
    local Y = self.size * Row
    local Offset = 3

    if (NumBuffs == 0) then -- No buffs
        Offset = 14
    end

    Debuffs:ClearAllPoints()
    Debuffs:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 0, Y + Offset)
end


function TukuiUF:Highlight()
    if UnitIsUnit("focus", self.unit) then
        self.Highlight:SetBackdropBorderColor(218 / 255, 197 / 255, 92 / 255, .7)
        self.Highlight:Show()
    elseif UnitIsUnit("target", self.unit) then
        self.Highlight:SetBackdropBorderColor(100 / 255, 100 / 255, 100 / 255, 1)
        self.Highlight:Show()
    else
        self.Highlight:Hide()
    end
end


-- All the stuff that needs to be changed with spec and does not need a protected environment
-- This might end up getting moved somewhere else since it's not strictly unitframe stuff
local PrevSpec = 0
function TukuiUF:AdjustForSpec()
    local NewSpec = GetSpecialization()
    if (NewSpec == PrevSpec) then return end

    local SpecName = select(2, GetSpecializationInfo(NewSpec))
    local SpecRole = GetSpecializationRole(NewSpec)
    local IsRanged = (SpecRole == "HEALER"  or
                     T.MyClass == "MAGE"    or
                     T.MyClass == "WARLOCK" or
                     T.MyClass == "PRIEST"  or
                    (T.MyClass == "DRUID"  and SpecName == "Balance")  or
                    (T.MyClass == "HUNTER" and SpecName ~= "Survival") or
                    (T.MyClass == "SHAMAN" and SpecName == "Elemental"))

    self:SetPlayerProfile(SpecRole, IsRanged)

    if (SpecRole == "HEALER") then
        Panels.CenterActionBars[2]:Hide()
    else
        Panels.CenterActionBars[2]:Show()
    end

    if (self.ClassSpecChanges) then
        self:ClassSpecChanges(NewSpec)
    end

    PrevSpec = NewSpec
end



function TukuiUF:SetupPartyRoleSwtich()
    -- Hook OnAttributeChanged to easily do non-protected update
    self.Headers.Party:HookScript("OnAttributeChanged", function(self, attr, value)
        if (attr == "framestyle") then
            local frames = { self:GetChildren() }
            for _,frame in ipairs(frames) do
                if (frame.UpdateStyle) then
                    frame:UpdateStyle(value)
                end
            end
        elseif (attr == "initial-width") then
            local frames = { self:GetChildren() }
            for _,frame in ipairs(frames) do
                if (frame.UpdateWidth) then
                    frame:UpdateWidth(value)
                end
            end
        end -- Don't need to to bother with initial-height for now
    end)

    local SecurePartyAdjuster = CreateFrame("Frame", nil, UIParent, "SecureHandlerStateTemplate")
    SecurePartyAdjuster:SetFrameRef("PartyHeader", self.Headers.Party)
    SecurePartyAdjuster:SetAttribute("_onstate-role", string.format([[
        local header = self:GetFrameRef("PartyHeader")

        local framePoint, w, h, style
        if (newstate == "HEALER") then
            framePoint = "LEFT"
            w = %d
            h = %d
            style = "GRID"
            header:ClearAllPoints()
            header:SetPoint("TOPLEFT", UIParent, "BOTTOM", -250, 300)
        else
            framePoint = "TOP"
            w = %d
            h = %d
            style = "LIST"
            header:ClearAllPoints()
            header:SetPoint("LEFT", UIParent, "LEFT", 300, 0)
        end
        header:SetAttribute("framestyle", style)
        header:ChildUpdate("framestyle", style)


        local frames = newtable(header:GetChildren())

        -- The header will update the position of the frames, but doesn't call ClearAllPoints()...
        for _,frame in ipairs(frames) do frame:ClearAllPoints(); end
        header:SetAttribute("point", framePoint)

        for _,frame in ipairs(frames) do
            frame:SetWidth(w)
            frame:SetHeight(h)
        end

        header:SetAttribute("initial-width", w)
        header:SetAttribute("initial-height", h)
    ]], self.GridWidth, self.GridMaxHeight,
        self.PartyListWidth, self.PartyListHeight))

    RegisterStateDriver(SecurePartyAdjuster, "role", self:GetRoleConditional())

end


function TukuiUF:SetupRaidRoleSwtich()
--shortstat-- Hook OnAttributeChanged to easily do non-protected update
    self.Headers.Raid:HookScript("OnAttributeChanged", function(self, attr, value)
        if (attr == "framestyle") then
            local frames = { self:GetChildren() }
            for _,frame in ipairs(frames) do
                if (frame.UpdateStyle) then
                    frame:UpdateStyle(value)
                end
            end
        elseif (attr == "initial-width") then
            local frames = { self:GetChildren() }
            for _,frame in ipairs(frames) do
                if (frame.UpdateWidth) then
                    frame:UpdateWidth(value)
                end
            end
        elseif (attr == "initial-height") then
            local frames = { self:GetChildren() }
            for _,frame in ipairs(frames) do
                if (frame.UpdateHeight) then
                    frame:UpdateHeight(value)
                end
            end
        end
    end)


    local SecureRaidAdjuster = CreateFrame("Frame", nil, UIParent, "SecureHandlerStateTemplate")

    -- This assumes that the raid header reference is called "header"
    --  and a table of its children called "frames"
    local UpdateRaidFrameSizes = [[
        local w,h
        if (header:GetAttribute("framestyle") == "GRID") then
            w = self:GetAttribute("GridFrameWidth")
            h = self:GetAttribute("GridFrameHeight")
        else
            w = self:GetAttribute("ListFrameWidth")
            h = self:GetAttribute("ListFrameHeight")
        end

        for _,frame in ipairs(frames) do
            frame:SetWidth(w)
            frame:SetHeight(h)
        end
        header:SetAttribute("initial-width", w)
        header:SetAttribute("initial-height", h)
    ]]

    -- SecureRaidAdjuster:SetFrameRef("ListHeader", self.Headers.Party)
    SecureRaidAdjuster:SetFrameRef("RaidHeader", self.Headers.Raid)

    SecureRaidAdjuster:SetAttribute("_onstate-groups", string.format([[
        -- Note: Arguments are self, stateid, newstate
        local numGroups = newstate

        local ListMaxHeight = %d
        local ListTotalHeight = %d
        local List20Width = %d
        local List40Width = %d

        local GridMaxHeight = %d
        local GridTotalHeight = %d

        if (ListMaxHeight * numGroups * 5 <= ListTotalHeight) then
            self:SetAttribute("ListFrameWidth", List20Width)
            self:SetAttribute("ListFrameHeight", ListMaxHeight)
        else
            self:SetAttribute("ListFrameWidth", List40Width)
            self:SetAttribute("ListFrameHeight", math.min(ListMaxHeight, math.floor(ListTotalHeight / (numGroups * 5))))
        end

        self:SetAttribute("GridFrameHeight", math.min(GridMaxHeight, math.floor(GridTotalHeight / numGroups)))

        local header = self:GetFrameRef("RaidHeader")
        local frames = newtable(header:GetChildren())
        %s
        ]], self.ListMaxHeight, self.ListTotalHeight, self.ListLargeWidth, self.ListSmallWidth,
            self.GridMaxHeight, self.GridTotalHeight,
            UpdateRaidFrameSizes))

    SecureRaidAdjuster:SetAttribute("GridFrameWidth", self.GridWidth)

    RegisterStateDriver(SecureRaidAdjuster, "groups", "[@raid36,exists] 8;[@raid31,exists] 7;[@raid26,exists] 6;[@raid21,exists] 5;[@raid16,exists] 4;[@raid11,exists] 3;[@raid6,exists] 2; 1")

    SecureRaidAdjuster:SetAttribute("_onstate-role", string.format([[
        local header = self:GetFrameRef("RaidHeader")

        local unitsPerColumn, framePoint
        if (newstate == "HEALER") then
            unitsPerColumn = 5
            framePoint = "LEFT"
            header:ClearAllPoints()
            header:SetPoint("TOPLEFT", UIParent, "BOTTOM", -250, 300)
            header:SetAttribute("framestyle", "GRID")
        else
            unitsPerColumn = nil
            framePoint = "TOP"
            -- header:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 30, -35)
            header:ClearAllPoints()
            header:SetPoint("LEFT", UIParent, "LEFT", 30, 130)
            header:SetAttribute("framestyle", "LIST")
        end

        local frames = newtable(header:GetChildren())

        -- The header will update the position of the frames, but doesn't call ClearAllPoints()...
        for _,frame in ipairs(frames) do frame:ClearAllPoints(); end
        header:SetAttribute("unitsPerColumn", unitsPerColumn)
        for _,frame in ipairs(frames) do frame:ClearAllPoints(); end
        header:SetAttribute("point", framePoint)

        %s
    ]], UpdateRaidFrameSizes))

    RegisterStateDriver(SecureRaidAdjuster, "role", self:GetRoleConditional())
end


function EnableEdits(self)
    if (not C.UnitFrames.Enable) then
        return
    end

    -- For namplates
    -- self:CreateTankListFrame()

    if (C.Party.Enable) then
        self:SetupPartyRoleSwtich()
    end

    if (C.Raid.Enable) then
        self:SetupRaidRoleSwtich()
    end


    local SecureSpecAdjuster = CreateFrame("Frame", nil, UIParent, "SecureHandlerStateTemplate")
    SecureSpecAdjuster:SetFrameRef("ufAnchor", Panels.UnitFrameAnchor)

    SecureSpecAdjuster:SetAttribute("_onstate-role", [[
        -- Note: Arguments are self, stateid, newstate
        local ufAnchor = self:GetFrameRef("ufAnchor")

        if (newstate == "HEALER") then
            ufAnchor:SetPoint("TOP", UIParent, "CENTER", 0, -160)
        else
            ufAnchor:SetPoint("TOP", UIParent, "CENTER", 0, -(160 + ufAnchor:GetHeight()))
        end
        ]])

    RegisterStateDriver(SecureSpecAdjuster, "role", self:GetRoleConditional())
    local UnitFrameAdjuster = CreateFrame("Frame", nil, UIParent)
    UnitFrameAdjuster:SetScript("OnEvent", function(self, event)
        TukuiUF:AdjustForSpec()
    end)
    UnitFrameAdjuster:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")

    self:AdjustForSpec()

    self.SecureRaidAdjuster = SecureRaidAdjuster
    self.SecureSpecAdjuster = SecureSpecAdjuster
    self.UnitFrameAdjuster = UnitFrameAdjuster
end



hooksecurefunc(TukuiUF, "CreateUnits", CreateUnits)
hooksecurefunc(TukuiUF, "PostCreateAura", PostCreateAura)
hooksecurefunc(TukuiUF, "Enable", EnableEdits)


