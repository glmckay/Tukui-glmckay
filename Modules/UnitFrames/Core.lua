local T, C, L = Tukui:unpack()

local Panels = T["Panels"]
local UnitFrames = T["UnitFrames"]

local BorderSize = C.General.BorderSize
local FrameSpacing = C.General.FrameSpacing

-- Localised globals
local gsub = gsub
local format = format
local UnitIsConnected = UnitIsConnected
local UnitIsGhost = UnitIsGhost
local UnitIsDead = UnitIsDead
local UnitGroupRolesAssigned = UnitGroupRolesAssigned

local Scale = T.Toolkit.Functions.Scale


-- UnitFrame dimensions
UnitFrames.FrameHeight = 30
UnitFrames.TargetAuraSize = 27
UnitFrames.TargetAurasPerRow = 8
UnitFrames.PlayerTargetWidth = UnitFrames.TargetAuraSize*UnitFrames.TargetAurasPerRow + FrameSpacing*(UnitFrames.TargetAurasPerRow - 1) + 2*BorderSize
UnitFrames.PetTotWidth = 90
UnitFrames.OtherHeight = 28
UnitFrames.OtherWidth = 200
UnitFrames.PowerHeight = 2


-- Empty table for class specific functions
UnitFrames.EditClassFeatures = {}


-- Notes: 1- The Tukui version of ShortValue uses a local "Value" which seems unnecessary
--           I left it out, maybe something weird will happen so I can learn why it was there.
--        2- Conditionals are (hopefully) ordered from most to least likely
function UnitFrames:ShortValue()
    if self < 1e3 then
        return self
    elseif self < 1e4 then
        return gsub(format("%.1fK", self / 1e3), "%.?0+([KMB])$", "%1")
    elseif self < 1e6 then
        return ("%dK"):format(self / 1e3)
    elseif self < 1e7 then
        return gsub(format("%.1fM", self / 1e6), "%.?0+([KMB])$", "%1")
    elseif self < 1e9 then
        return format("%dM", self / 1e6)
    elseif self < 1e10 then
        return gsub(format("%.1fB", self / 1e9), "%.?0+([KMB])$", "%1")
    else
        return format("%dB", self / 1e9)
    end
end


function UnitFrames:GroupRoleIndicatorUpdate(event)
    local element = self.GroupRoleIndicator
    local role = UnitGroupRolesAssigned(self.unit)

    if(element.PreUpdate) then
		element:PreUpdate()
    end

	if(role == 'TANK' or role == 'HEALER' or role == 'DAMAGER') then
		element:SetTexture(C.Medias.Role[role])
    else
        element:SetTexture()
	end

    if(element.PostUpdate) then
		return element:PostUpdate(role)
    end
end



-- Remove this function
function UnitFrames:UpdateNamePosition() end


-- Create a macro-style conditional for the player's roles (cache the string since it won't change)
--  Conditional returns same strings as GetSpecializationRole ("TANK", "DAMAGER", "HEALER") or "ERROR" (shouldn't happen)
function UnitFrames:GetRoleConditional()
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


function UnitFrames:CheckInterrupt(unit)
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
        Player:SetPoint("LEFT", Panels.UnitFrameAnchor)
        Player:SetSize(self.PlayerTargetWidth, self.FrameHeight)

        Target:ClearAllPoints()
        Target:SetParent(Panels.UnitFrameAnchor)
        Target:SetPoint("RIGHT", Panels.UnitFrameAnchor)
        Target:SetSize(self.PlayerTargetWidth, self.FrameHeight)

        Pet:ClearAllPoints()
        Pet:SetParent(Panels.UnitFrameAnchor)
        Pet:SetPoint("RIGHT", Panels.UnitFrameAnchor, "LEFT", -FrameSpacing, 0)
        Pet:SetSize(self.PetTotWidth, self.FrameHeight)

        ToT:ClearAllPoints()
        ToT:SetParent(Panels.UnitFrameAnchor)
        ToT:SetPoint("LEFT", Panels.UnitFrameAnchor, "RIGHT", FrameSpacing, 0)
        ToT:SetSize(self.PetTotWidth, self.FrameHeight)

        Focus:ClearAllPoints()
        Focus:SetPoint("TOPRIGHT", Panels.UnitFrameAnchor, "TOPRIGHT", 50, -80)
        Focus:SetSize(self.OtherWidth, self.OtherHeight)

        FocusTarget:ClearAllPoints()
        FocusTarget:SetPoint("TOP", Focus, "BOTTOM", 0, -35)
        FocusTarget:SetSize(self.OtherWidth, self.OtherHeight)

        if (C.UnitFrames.Arena) then
            local Arena = UnitFrames.Units.Arena

            for i = 1, 5 do
                Arena[i]:ClearAllPoints()
                if (i == 1) then
                    Arena[i]:SetPoint("TOPLEFT", UIParent, "CENTER", 485, -30)
                else
                    Arena[i]:SetPoint("BOTTOM", Arena[i-1], "TOP", 0, 32)
                end
                Arena[i]:SetSize(self.OtherWidth, self.OtherHeight)
            end
        end

        if (C.UnitFrames.Boss) then
            local Boss = UnitFrames.Units.Boss

            for i = 1, 5 do
                Boss[i]:ClearAllPoints()
                if (i == 1) then
                    Boss[i]:SetPoint("TOPLEFT", UIParent, "CENTER", 485, -30)
                else
                    Boss[i]:SetPoint("BOTTOM", Boss[i-1], "TOP", 0, 32)
                end
                Boss[i]:SetSize(self.OtherWidth, self.OtherHeight)
            end
        end

        if (C.Raid.Enable) then
            local Raid = UnitFrames.Headers.Raid

            if (C.Raid.ShowPets) then
                local Pets = UnitFrames.Headers.RaidPet

                Pets:ClearAllPoints()
                Pets:SetPoint("TOPRIGHT", Raid, "TOPLEFT", -FrameSpacing, 0)
            end
        end
    end
end


local function EditStyle(self, unit)
    if (not unit or unit:match("nameplate")) then
        return
    end

    if (self.Panel) then
        self.Panel:Kill()
    end

    self.Backdrop:Kill()
    self.Backdrop = nil
    self:CreateBackdrop()
end


function UnitFrames:GetPartyFramesAttributes()
    return
        "TukuiParty",
        nil,
        "custom [@player,exists,nogroup:party][@raid6,noexists] show; hide",
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
        "xOffset", Scale(FrameSpacing),
        "yOffset", Scale(-FrameSpacing-4)
end


function UnitFrames:GetRaidFramesAttributes()
    local Properties = C.Party.Enable and "custom [@raid6,exists] show; hide" or "solo,party,raid"

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
        "xoffset", Scale(FrameSpacing),
        "yOffset", Scale(-FrameSpacing),
        "point", "LEFT",
        "groupFilter", "1,2,3,4,5,6,7,8",
        "groupingOrder", "1,2,3,4,5,6,7,8",
        "groupBy", C["Raid"].GroupBy.Value,
        "maxColumns", math.ceil( 40 / C["Raid"].MaxUnitPerColumn),
        "unitsPerColumn", C["Raid"].MaxUnitPerColumn,
        "columnSpacing", Scale(FrameSpacing),
        "columnAnchorPoint", "RIGHT"
end


function UnitFrames:GetPetRaidFramesAttributes()
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
        "columnSpacing", Scale(FrameSpacing),
        "columnAnchorPoint", "RIGHT",
        "xOffset", Scale(FrameSpacing),
        "yOffset", Scale(-FrameSpacing),
        "initial-width", self.GridWidth,
        "initial-height", self.GridMaxHeight,
        "oUF-initialConfigFunction", [[
            local header = self:GetParent()
            self:SetWidth(header:GetAttribute("initial-width"))
            self:SetHeight(header:GetAttribute("initial-height"))
        ]]
end


function UnitFrames:GetBigRaidFramesAttributes()
	local Properties = "hide"

	return
		"TukuiRaid40",
		nil,
		Properties,
		"oUF-initialConfigFunction", [[
			local header = self:GetParent()
			self:SetWidth(header:GetAttribute("initial-width"))
			self:SetHeight(header:GetAttribute("initial-height"))
		]],
		"initial-width", C.Raid.Raid40WidthSize,
		"initial-height", C.Raid.Raid40HeightSize,
		"showParty", true,
		"showRaid", true,
		"showPlayer", true,
		"showSolo", true,
		"xoffset", C.Raid.Padding40,
		"yOffset", -C.Raid.Padding40,
		"point", "TOP",
		"groupFilter", "1,2,3,4,5,6,7,8",
		"groupingOrder", "1,2,3,4,5,6,7,8",
		"groupBy", C["Raid"].GroupBy.Value,
		"maxColumns", math.ceil(40 / 5),
		"unitsPerColumn", C["Raid"].Raid40MaxUnitPerColumn,
		"columnSpacing", C.Raid.Padding40,
		"columnAnchorPoint", "LEFT"
end


-- Skin Auras
local function PostCreateAura(self, button)
    button.cd:SetInside()
    button.icon:SetInside()
end


function UnitFrames:UpdateDebuffsHeaderPosition()
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


function UnitFrames:Highlight()
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
function UnitFrames:AdjustForSpec()
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

    -- if (SpecRole == "HEALER") then
    --     Panels.CenterActionBars[2]:Hide()
    -- else
    --     Panels.CenterActionBars[2]:Show()
    -- end

    if (self.ClassSpecChanges) then
        self:ClassSpecChanges(NewSpec)
    end

    PrevSpec = NewSpec
end


function UnitFrames:SetupPartyRoleSwtich()
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
            framePoint = "TOP"
            w = %d
            h = %d
            style = "GRID"
            header:ClearAllPoints()
            header:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 700, -680)
        else
            framePoint = "TOP"
            w = %d
            h = %d
            style = "LIST"
            header:ClearAllPoints()
            header:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 350, -500)
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


function UnitFrames:SetupRaidRoleSwtich()
    -- Hook OnAttributeChanged to easily do non-protected update
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
            framePoint = "TOP"
            columnAnchorPoint = "RIGHT"
            header:ClearAllPoints()
            header:SetPoint("TOPRIGHT", UIParent, "TOPLEFT", 800, -680)
            header:SetAttribute("framestyle", "GRID")
        else
            unitsPerColumn = nil
            framePoint = "TOP"
            columnAnchorPoint = "TOP"
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
        header:SetAttribute("columnAnchorPoint", columnAnchorPoint)

        %s
    ]], UpdateRaidFrameSizes))

    RegisterStateDriver(SecureRaidAdjuster, "role", self:GetRoleConditional())
end


function EnableEdits(self)
    if (not C.UnitFrames.Enable) then
        return
    end

    if (C.Party.Enable) then
        self:SetupPartyRoleSwtich()
    end

    if (C.Raid.Enable) then
        self:SetupRaidRoleSwtich()
    end


    local SecureSpecAdjuster = CreateFrame("Frame", nil, UIParent, "SecureHandlerStateTemplate")
    SecureSpecAdjuster:SetFrameRef("ufAnchor", Panels.UnitFrameAnchor)

    SecureSpecAdjuster:SetAttribute("_onstate-role", string.format([[
        -- Note: Arguments are self, stateid, newstate
        local ufAnchor = self:GetFrameRef("ufAnchor")
        local xOffset = %f

        -- if (newstate == "HEALER") then
        --     ufAnchor:SetPoint("TOP", UIParent, "CENTER", xOffset, -220)
        -- else
            ufAnchor:SetPoint("TOP", UIParent, "CENTER", xOffset, -(180 + ufAnchor:GetHeight()))
        -- end
        ]], (Panels.CenterPanelWidth % 2 == 1 and 0.5) or 0 -- Shift by half a pixel for odd width
    ))

    RegisterStateDriver(SecureSpecAdjuster, "role", self:GetRoleConditional())
    local UnitFrameAdjuster = CreateFrame("Frame", nil, UIParent)
    UnitFrameAdjuster:SetScript("OnEvent", function(self, event)
        UnitFrames:AdjustForSpec()
    end)
    UnitFrameAdjuster:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")

    self:AdjustForSpec()

    self.SecureRaidAdjuster = SecureRaidAdjuster
    self.SecureSpecAdjuster = SecureSpecAdjuster
    self.UnitFrameAdjuster = UnitFrameAdjuster
end



hooksecurefunc(UnitFrames, "CreateUnits", CreateUnits)
hooksecurefunc(UnitFrames, "Style", EditStyle)
hooksecurefunc(UnitFrames, "PostCreateAura", PostCreateAura)
hooksecurefunc(UnitFrames, "Enable", EnableEdits)


