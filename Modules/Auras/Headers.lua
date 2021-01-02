local T, C, L = Tukui:unpack()

local TukuiAuras = T["Auras"]

local AuraSize = C.Auras.Size
local AuraSpacing = C.Auras.Spacing or C.General.FrameSpacing
local RowSpacing = 16
local BuffsMinHeight = 2*AuraSize + RowSpacing

local MinimapSize = C.Maps.MinimapSize
local DistanceFromMinimap = 3

local BorderSize = C.General.BorderSize

local Scale = T.Toolkit.Functions.Scale


-- Long note:
--  Auras are "secure objects" so their size is protected in combat.
--  To change their size we need to modify the intialconfigfunction or the TukuiAurasTemplate.
--  I used to use the fact that Skin was called before the initialconfigfunction was chcked by
--  blizzard's header code, but now this seems to create a bug (I blame blizz). So now we wrap
--  CreateHeaders and trick it into not showing the headers right away (luckily the headers still)
--  get created even if the config hides them).

TukuiAuras.OriginalCreateHeaders = TukuiAuras.CreateHeaders
function TukuiAuras:CreateHeaders()
    local Movers = T["Movers"]
    local Headers = TukuiAuras.Headers

    local InitConfigFcn = string.format([[
        self:SetWidth(%d)
        self:SetHeight(%d)
    ]], Scale(AuraSize), Scale(AuraSize))

    local TempHideBuffs = C.Auras.HideBuffs
    local TempHideDebuffs = C.Auras.HideDebuffs
    C.Auras.HideBuffs = true
    C.Auras.HideDebuffs = true

    -- Run Tukui's CreateHeaders
    self:OriginalCreateHeaders()

    for _, Header in ipairs(Headers) do
        Header:SetAttribute("minHeight", Scale(BuffsMinHeight))
        Header:SetAttribute("xOffset", -Scale(AuraSize + AuraSpacing))
        Header:SetAttribute("wrapYOffset", -Scale(AuraSize + RowSpacing))

        Header:SetAttribute("minWidth", C["Auras"].BuffsPerRow * Scale(AuraSize + AuraSpacing))
        Header:SetSize(AuraSize, AuraSize)

        Header:SetAttribute("initialconfigfunction", InitConfigFcn)
    end

    local Buffs = Headers[1]
    local Debuffs = Headers[2]

    C.Auras.HideBuffs = TempHideBuffs
    C.Auras.HideDebuffs = TempHideDebuffs

    if (not C.Auras.HideBuffs) then
        Buffs:SetPoint("TOPRIGHT", Minimap, "TOPLEFT", -(DistanceFromMinimap + BorderSize), BorderSize)
        Buffs:SetAttribute("filter", "HELPFUL")
        Buffs:SetAttribute("includeWeapons", 1)
        Buffs:Show()

        Movers:RegisterFrame(Buffs)
    end

    if (not C.Auras.HideDebuffs) then
        if (C.Auras.HideBuffs) then
            Debuffs:SetPoint("TOPRIGHT", Minimap, "TOPLEFT", -(DistanceFromMinimap + BorderSize), BorderSize)
        else
            Debuffs:SetPoint("TOP", Buffs, "BOTTOM", 0, -math.max(RowSpacing, (MinimapSize + 2*BorderSize - BuffsMinHeight - AuraSize)))
        end

        Debuffs:SetAttribute("filter", "HARMFUL")
        Debuffs:Show()

        Movers:RegisterFrame(Debuffs)
    end
 end


local function EditSkin(self)
    local Holder = self.Holder
    if (Holder) then
        Holder:SetWidth(AuraSize)
    end
end

hooksecurefunc(TukuiAuras, "Skin", EditSkin)