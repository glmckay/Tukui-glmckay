local T, C, L = Tukui:unpack()

local BorderSize = C.General.BorderSize

-- Update the SetInside/SetOutsize functions to use C.General.BorderSize as its defaults
local function SetOutside(obj, anchor, xOffset, yOffset)
    xOffset = xOffset or BorderSize
    yOffset = yOffset or BorderSize
    anchor = anchor or obj:GetParent()

    if obj:GetPoint() then obj:ClearAllPoints() end

    obj:Point("TOPLEFT", anchor, "TOPLEFT", -xOffset, yOffset)
    obj:Point("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", xOffset, -yOffset)
end

local function SetInside(obj, anchor, xOffset, yOffset)
    xOffset = xOffset or BorderSize
    yOffset = yOffset or BorderSize
    anchor = anchor or obj:GetParent()

    if obj:GetPoint() then obj:ClearAllPoints() end

    obj:Point("TOPLEFT", anchor, "TOPLEFT", xOffset, -yOffset)
    obj:Point("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", -xOffset, yOffset)
end


-- Replace the Tukui SetTemplate function with our own
local function SetTemplate(f, t, tex)
    local borderr, borderg, borderb = unpack(C.General.BorderColor)
    local backdropr, backdropg, backdropb, backdropa = unpack(C.General.BackdropColor)
    local texture = C.Medias.Blank
    backdropa = (backdropa or 1) -- avoid nil
    if t == "Transparent" then backdropa = backdropa*backdropa end

    if tex then
        texture = C.Medias.Normal
    end

    f:SetBackdrop({
        bgFile = texture,
        edgeFile = C.Medias.Blank,
        edgeSize = T.Scale(BorderSize)
    })

    f:SetBackdropColor(backdropr, backdropg, backdropb, backdropa)
    f:SetBackdropBorderColor(borderr, borderg, borderb)
end


local function SkinButton(Frame, Strip)
    Frame:TukuiSkinButton()

    Frame:HookScript("OnEnter", function(self)
        local Color = RAID_CLASS_COLORS[select(2, UnitClass("player"))]
        local backdropa = select(4, C.General.BackdropColor) or 1

        self:SetBackdropColor(Color.r * .15, Color.g * .15, Color.b * .15, backdropa^2)
        self:SetBackdropBorderColor(Color.r, Color.g, Color.b)
    end)

    Frame:HookScript("OnLeave", function(self)
        local Color = C.General.BackdropColor

        self:SetBackdropColor(Color[1], Color[2], Color[3], (Color[4] or 1)^2)
        self:SetBackdropBorderColor(C.General.BorderColor[1], C.General.BorderColor[2], C.General.BorderColor[3])
    end)
end


local function EditAPI(object)
    local mt = getmetatable(object).__index
    if object.SetTemplate then mt.SetTemplate = SetTemplate end
    if object.SetOutside then mt.SetOutside = SetOutside end
    if object.SetInside then mt.SetInside = SetInside end
    if object.SkinButton then
        mt.TukuiSkinButton = object.SkinButton
        mt.SkinButton = SkinButton
    end
end

local Handled = {["Frame"] = true}

local Object = CreateFrame("Frame")
EditAPI(Object)
EditAPI(Object:CreateTexture())
EditAPI(Object:CreateFontString())

Object = EnumerateFrames()

while Object do
    if not Object:IsForbidden() and not Handled[Object:GetObjectType()] then
        EditAPI(Object)
        Handled[Object:GetObjectType()] = true
    end

    Object = EnumerateFrames(Object)
end
