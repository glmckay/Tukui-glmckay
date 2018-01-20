local T, C, L = Tukui:unpack()

local UnitFrames = T.UnitFrames

local borderSize = C.General.BorderSize
UnitFrames.ufHeight = 23


-- Define new Backdrop here since we don't get a chance to change it before frames are created
UnitFrames.SkinnedBackdrop = {
    bgFile = C.Medias.Blank,
    insets = { top =    -T.Scale(borderSize),
               left =   -T.Scale(borderSize),
               bottom = -T.Scale(borderSize),
               right =  -T.Scale(borderSize) },
}

local ufSpacing = 2*C.General.BorderSize + 1

-- Empty table for class specific functions
UnitFrames.EditClassFeatures = {}


local function CreateUnits(self)
    local Player = self.Units.Player
    local Target = self.Units.Target
    local ToT = self.Units.TargetOfTarget
    local Pet = self.Units.Pet
    local Focus = self.Units.Focus
    local FocusTarget = self.Units.FocusTarget

    Player:ClearAllPoints()
    Player:Point("TOPRIGHT", UIParent, "CENTER", -170, -280)
    Player:Size(self.PlayerTargetWidth, self.ufHeight)

    Target:ClearAllPoints()
    Target:Point("TOPLEFT", UIParent, "CENTER", 170, -280)
    Target:Size(self.PlayerTargetWidth, self.ufHeight)

    Pet:ClearAllPoints()
    Pet:Point("RIGHT", Player, "LEFT", -ufSpacing, 0)
    Pet:Size(self.PetTotWidth, self.ufHeight)

    ToT:ClearAllPoints()
    ToT:Point("LEFT", Target, "RIGHT", ufSpacing, 0)
    ToT:Size(self.PetTotWidth, self.ufHeight)

    Focus:ClearAllPoints()
    Focus:Point("TOPRIGHT", UIParent, "CENTER", -415, 300)
    Focus:Size(self.OtherWidth, self.ufHeight)

    FocusTarget:ClearAllPoints()
    FocusTarget:Point("BOTTOM", Focus, "TOP", 0, 35)
    FocusTarget:Size(self.OtherWidth, self.ufHeight)

    if (C.UnitFrames.Arena) then
        local Arena = UnitFrames.Units.Arena

        for i = 1, 5 do
            Arena[i]:ClearAllPoints()
            if (i == 1) then
                Arena[i]:Point("TOPLEFT", UIParent, "CENTER", 500, -130)
            else
                Arena[i]:Point("BOTTOM", Arena[i-1], "TOP", 0, 32)
            end
            Arena[i]:Size(self.OtherWidth, self.ufHeight)
        end
    end

    if (C.UnitFrames.Boss) then
        local Boss = UnitFrames.Units.Boss

        for i = 1, 5 do
            Boss[i]:ClearAllPoints()
            if (i == 1) then
                Boss[i]:Point("TOPLEFT", UIParent, "CENTER", 500, -130)
            else
                Boss[i]:Point("BOTTOM", Boss[i-1], "TOP", 0, 32)
            end
            Boss[i]:Size(self.OtherWidth, self.ufHeight)
        end
    end

    if (C.Raid.Enable) then
        local Raid = UnitFrames.Headers.Raid

        Raid:ClearAllPoints()
        Raid:Point("BOTTOMRIGHT", UIParent, "CENTER", -300, -200)

        if (C.Raid.ShowPets) then
            local Pets = UnitFrames.Headers.RaidPet

            Pets:ClearAllPoints()
            Pets:Point("TOPRIGHT", Raid, "TOPLEFT", -ufSpacing, 0)
        end
    end
end


function UnitFrames:GetRaidFramesAttributes()
    local Properties = C.Party.Enable and "custom [@raid6,exists] show;hide" or "solo,party,raid"

    return
        "TukuiRaid",
        nil,
        Properties,
        "oUF-initialConfigFunction", [[
            local header = self:GetParent()
            self:SetWidth(header:GetAttribute("initial-width"))
            self:SetHeight(header:GetAttribute("initial-height"))
        ]],
        "initial-width", T.Scale(UnitFrames.RaidWidth),
        "initial-height", T.Scale(UnitFrames.RaidHeight),
        "showParty", true,
        "showRaid", true,
        "showPlayer", true,
        "showSolo", false, -- testing
        "xoffset", T.Scale(ufSpacing),
        "yOffset", T.Scale(-ufSpacing),
        "point", "TOP",
        "groupFilter", "1,2,3,4,5,6,7,8",
        "groupingOrder", "1,2,3,4,5,6,7,8",
        "groupBy", C["Raid"].GroupBy.Value,
        "maxColumns", math.ceil(40/5),
        "unitsPerColumn", C["Raid"].MaxUnitPerColumn,
        "columnSpacing", T.Scale(ufSpacing),
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
        "maxColumns", math.ceil(40/5),
        "point", "TOP",
        "unitsPerColumn", C["Raid"].MaxUnitPerColumn,
        "columnSpacing", T.Scale(ufSpacing),
        "columnAnchorPoint", "RIGHT",
        "xOffset", T.Scale(ufSpacing),
        "yOffset", T.Scale(-ufSpacing),
        "initial-width", T.Scale(UnitFrames.RaidWidth),
        "initial-height", T.Scale(UnitFrames.RaidHeight),
        "oUF-initialConfigFunction", [[
            local header = self:GetParent()
            self:SetWidth(header:GetAttribute("initial-width"))
            self:SetHeight(header:GetAttribute("initial-height"))
        ]]
end


-- Skin Auras
local function PostCreateAura(self, button)
    button.Shadow:Kill()
    button:HideInsets()
    button:SetBackdrop(UnitFrames.SkinnedBackdrop)
    button:SetBackdropColor(0, 0, 0)
    button.cd:SetAllPoints()
    button.icon:SetAllPoints()
end


hooksecurefunc(UnitFrames, "CreateUnits", CreateUnits)
hooksecurefunc(UnitFrames, "PostCreateAura", PostCreateAura)