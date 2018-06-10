local T, C, L = Tukui:unpack()

local Tooltip = T["Tooltips"]
local HealthBar = GameTooltipStatusBar

local BorderSize = C["General"].BorderSize
local FrameSpacing = C["General"].FrameSpacing

local function EditAnchor(self)
    self.Anchor:ClearAllPoints()
    self.Anchor:Point("BOTTOMRIGHT", T["Panels"].DataTextRight, 0, 190)
end

-- The only way I could come up with to stop Tuki coloring the borders of the toolip
--  Replacing the tooltip's SetBackdropBorderColor doesn't seem to work :(
function Tooltip:SetColor()
    local GetMouseFocus = GetMouseFocus()

    local Unit = select(2, self:GetUnit()) or (GetMouseFocus and GetMouseFocus.GetAttribute and GetMouseFocus:GetAttribute("unit"))

    if (not Unit) and (UnitExists("mouseover")) then
        Unit = 'mouseover'
    end

    self:SetBackdropColor(unpack(C["General"].BackdropColor))
    self:SetBackdropBorderColor(unpack(C["General"].BorderColor))

    local Reaction = Unit and UnitReaction(Unit, "player")
    local Player = Unit and UnitIsPlayer(Unit)
    local Friend = Unit and UnitIsFriend("player", Unit)
    local R, G, B

    if Player and Friend then
        local Class = select(2, UnitClass(Unit))
        local Color = T.Colors.class[Class]

        R, G, B = Color[1], Color[2], Color[3]
        HealthBar:SetStatusBarColor(R, G, B)
    elseif Reaction then
        local Color = T.Colors.reaction[Reaction]

        R, G, B = Color[1], Color[2], Color[3]
        HealthBar:SetStatusBarColor(R, G, B)
    else
        local Link = select(2, self:GetItem())
        local Quality = Link and select(3, GetItemInfo(Link))

        if (Quality and Quality >= 2) then
            R, G, B = GetItemQualityColor(Quality)
            self:SetBackdropBorderColor(R, G, B)
        else
            local Color = T.Colors

            HealthBar:SetStatusBarColor(unpack(Color.reaction[5]))
        end
    end
end


local function EnableEdits(self)
    HealthBar:ClearAllPoints()
    HealthBar:Point("BOTTOMLEFT", HealthBar:GetParent(), "TOPLEFT", BorderSize, BorderSize + FrameSpacing)
    HealthBar:Point("BOTTOMRIGHT", HealthBar:GetParent(), "TOPRIGHT", -BorderSize, BorderSize + FrameSpacing)
end


hooksecurefunc(Tooltip, "CreateAnchor", EditAnchor)
hooksecurefunc(Tooltip, "Enable", EnableEdits)
