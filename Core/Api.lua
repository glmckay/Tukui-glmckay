local T, C, L = Tukui:unpack()

-- For some reason Tukui sets UIScale to 0.71 by default and only updates it (via AutoScale)
-- to a more accurate value later during the Loading script.
-- I'm not waiting that long because the unitframe scripts that hook Tukui's functions might
-- run before my Loading script. So my I'm setting it to the proper value here.
if (C.General.AutoScale) then
    C.General.UIScale = min(2, max(0.32, 768 / string.match(T.Resolution, "%d+x(%d+)")))
end
T.Mult = 768 / string.match(T.Resolution, "%d+x(%d+)") / C.General.UIScale


local borderSize = C.General.BorderSize

-- Update the SetInside/SetOutsize functions to use C.General.BorderSize as its defaults
local function SetOutside(obj, anchor, xOffset, yOffset)
    xOffset = xOffset or borderSize
    yOffset = yOffset or borderSize
    anchor = anchor or obj:GetParent()

    if obj:GetPoint() then obj:ClearAllPoints() end

    obj:Point("TOPLEFT", anchor, "TOPLEFT", -xOffset, yOffset)
    obj:Point("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", xOffset, -yOffset)
end

local function SetInside(obj, anchor, xOffset, yOffset)
    xOffset = xOffset or borderSize
    yOffset = yOffset or borderSize
    anchor = anchor or obj:GetParent()

    if obj:GetPoint() then obj:ClearAllPoints() end

    obj:Point("TOPLEFT", anchor, "TOPLEFT", xOffset, -yOffset)
    obj:Point("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", -xOffset, yOffset)
end


-- Replace the Tukui SetTemplate function with our own
local function SetTemplate(f, t, tex)
    local balpha = 1
    if t == "Transparent" then balpha = 0.6 end
    local borderr, borderg, borderb = unpack(C.General.BorderColor)
    local backdropr, backdropg, backdropb = unpack(C.General.BackdropColor)
    local backdropa = balpha
    local texture = C.Medias.Blank

    if tex then
        texture = C.Medias.Normal
    end

    f:SetBackdrop({
        bgFile = texture,
        edgeFile = C.Medias.Blank,
        edgeSize = T.Scale(borderSize)
    })

    f:SetBackdropColor(backdropr, backdropg, backdropb, backdropa)
    f:SetBackdropBorderColor(borderr, borderg, borderb)
end


local function EditAPI(object)
    local mt = getmetatable(object).__index
    if object.SetTemplate then mt.SetTemplate = SetTemplate end
    if object.SetOutside then mt.SetOutside = SetOutside end
    if object.SetInside then mt.SetInside = SetInside end
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
