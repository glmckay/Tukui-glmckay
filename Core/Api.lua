local T, C, L = Tukui:unpack()

local BorderSize = C.General.BorderSize

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
        bgFile = C.Medias.Blank,
        edgeFile = C.Medias.Blank,
        edgeSize = T.Scale(BorderSize)
    })

    f:SetBackdropColor(backdropr, backdropg, backdropb, backdropa)
    f:SetBackdropBorderColor(borderr, borderg, borderb)
end

local function EditAPI(object)
    local mt = getmetatable(object).__index
    if object.SetTemplate then mt.SetTemplate = SetTemplate end
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
