local T, C, L = Tukui:unpack()

local TukuiAuras = T["Auras"]

local AuraSize = C.Auras.Size
local AuraSpacing = C.Auras.Spacing or C.General.FrameSpacing
local RowSpacing = 16
local BuffsMinHeight = 2*AuraSize + RowSpacing

local MinimapSize = C.Maps.MinimapSize
local DistanceFromMinimap = 10

local BorderSize = C.General.BorderSize

-- Long note:
--  Auras are "secure objects" (or something like that) so their size is protected in combat.
--  I found two ways of *properly* (in my opinion) changing the size of auras:
--  1- replace the TukuiAurasTemplate with one of the desired size. This means hardcoding the
--     size, which I find a little inelegant (though it wouldn't be a big deal)
--  2- Set the "initialConfigFunction" attribute. This is acceptably elegant. However, we need
--     to set the attribute before any auras are created. This is difficult since we don't have
--     easy access to the headers until after Tukui has already made them visible (which triggers)
--     the creation of auras. Luckily, the Skin function is called immediately when an aura is
--     created (before the header can call initialConfigFunction).

local function SetInitialConfig(header)
    header:SetAttribute("initialConfigFunction", string.format([[
        self:SetWidth(%d)
        self:SetHeight(%d)
    ]], T.Scale(AuraSize), T.Scale(AuraSize)))
end

-- This is only needed until EditHeaders is called
local function CheckInitialConfig()
    for i,Header in ipairs(TukuiAuras.Headers) do
        if (not Header:GetAttribute("initialConfigFunction")) then
            SetInitialConfig(Header)
        end
    end
end

local function EditHeaders(self)
    local Headers = TukuiAuras.Headers

    for i, Header in ipairs(Headers) do
        if (i == 3) then
            Header:SetAttribute("wrapYOffset", -T.Scale(AuraSize + AuraSpacing))
        else
            Header:SetAttribute("minHeight", T.Scale(BuffsMinHeight))
            Header:SetAttribute("xOffset", -T.Scale(AuraSize + AuraSpacing))
            Header:SetAttribute("wrapYOffset", -T.Scale(AuraSize + RowSpacing))
        end

        Header:SetAttribute("minWidth", C["Auras"].BuffsPerRow * T.Scale(AuraSize + AuraSpacing))
        Header:Size(AuraSize)

        SetInitialConfig(Header)
    end
    -- Get rid of this function now that we know the initialConfigFunction is set
    CheckInitialConfig = function() end

    local Buffs = Headers[1]
    local Debuffs = Headers[2]
    local Consolidate = Headers[3]

    if (not C.Auras.HideBuffs) then
        Buffs:Point("TOPRIGHT", Minimap, "TOPLEFT", -DistanceFromMinimap, BorderSize)

        local Proxy = Buffs:GetAttribute("consolidateProxy")
        Consolidate:Point("CENTER", Proxy, "CENTER", 0, -(AuraSize + AuraSpacing))
    end

    if (not C.Auras.HideDebuffs) then
        if (C.Auras.HideBuffs) then
            Debuffs:Point("TOPRIGHT", Minimap, "TOPLEFT", -DistanceFromMinimap, BorderSize)
        else
            Debuffs:Point("TOP", Buffs, "BOTTOM", 0, -math.max(RowSpacing, (MinimapSize - BuffsMinHeight - AuraSize)))
        end
    end
end

local function EditSkin(self)
    local Holder = self.Holder

    CheckInitialConfig() -- In case an aura is created before EditHeaders is called

    if (Holder) then
        Holder:Width(AuraSize)
    end
end

hooksecurefunc(TukuiAuras, "CreateHeaders", EditHeaders)
hooksecurefunc(TukuiAuras, "Skin", EditSkin)