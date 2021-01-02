local T, C, L = Tukui:unpack()

local Toolkit = T["Toolkit"]

local BorderSize = Toolkit.Functions.Scale(C.General.BorderSize)

-- Update the SetInside/SetOutsize functions to use C.General.BorderSize as its defaults
local function SetOutside(obj, anchor, xOffset, yOffset)
    xOffset = xOffset or BorderSize
    yOffset = yOffset or BorderSize
    anchor = anchor or obj:GetParent()

    if obj:GetPoint() then obj:ClearAllPoints() end

    obj:SetPoint("TOPLEFT", anchor, "TOPLEFT", -xOffset, yOffset)
    obj:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", xOffset, -yOffset)
end

local function SetInside(obj, anchor, xOffset, yOffset)
    xOffset = xOffset or BorderSize
    yOffset = yOffset or BorderSize
    anchor = anchor or obj:GetParent()

    if obj:GetPoint() then obj:ClearAllPoints() end

    obj:SetPoint("TOPLEFT", anchor, "TOPLEFT", xOffset, -yOffset)
    obj:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", -xOffset, yOffset)
end

Toolkit.API.CreateBackdrop = function(self, BackgroundTemplate, BackgroundTexture, BorderTemplate)
	if (self.Backdrop) then
		return
	end

	self.Backdrop = CreateFrame("Frame", nil, self, "BackdropTemplate")
	self.Backdrop:SetAllPoints()
	self.Backdrop:SetFrameLevel(self:GetFrameLevel())

	local BackgroundAlpha = 1 -- (BackgroundTemplate == "Transparent" and Toolkit.Settings.Transparency) or (1)
	local BorderR, BorderG, BorderB = unpack(Toolkit.Settings.BorderColor)
	local BackdropR, BackdropG, BackdropB = unpack(Toolkit.Settings.BackdropColor)
	local BorderSize = Toolkit.Functions.Scale(BorderSize)

	self.Backdrop:SetBackdrop({bgFile = BackgroundTexture or Toolkit.Settings.NormalTexture})
	self.Backdrop:SetBackdropColor(BackdropR, BackdropG, BackdropB, BackgroundAlpha * 0.6)

	self.Backdrop.BorderTop = self.Backdrop:CreateTexture(nil, "BORDER", nil, 1)
	self.Backdrop.BorderTop:SetSize(BorderSize, BorderSize)
	self.Backdrop.BorderTop:SetPoint("TOPLEFT", self.Backdrop, "TOPLEFT", 0, 0)
	self.Backdrop.BorderTop:SetPoint("TOPRIGHT", self.Backdrop, "TOPRIGHT", 0, 0)
	--self.Backdrop.BorderTop:SetSnapToPixelGrid(false)
	--self.Backdrop.BorderTop:SetTexelSnappingBias(0)

	self.Backdrop.BorderBottom = self.Backdrop:CreateTexture(nil, "BORDER", nil, 1)
	self.Backdrop.BorderBottom:SetSize(BorderSize, BorderSize)
	self.Backdrop.BorderBottom:SetPoint("BOTTOMLEFT", self.Backdrop, "BOTTOMLEFT", 0, 0)
	self.Backdrop.BorderBottom:SetPoint("BOTTOMRIGHT", self.Backdrop, "BOTTOMRIGHT", 0, 0)
	--self.Backdrop.BorderBottom:SetSnapToPixelGrid(false)
	--self.Backdrop.BorderBottom:SetTexelSnappingBias(0)

	self.Backdrop.BorderLeft = self.Backdrop:CreateTexture(nil, "BORDER", nil, 1)
	self.Backdrop.BorderLeft:SetSize(BorderSize, BorderSize)
	self.Backdrop.BorderLeft:SetPoint("TOPLEFT", self.Backdrop, "TOPLEFT", 0, 0)
	self.Backdrop.BorderLeft:SetPoint("BOTTOMLEFT", self.Backdrop, "BOTTOMLEFT", 0, 0)
	---self.Backdrop.BorderLeft:SetSnapToPixelGrid(false)
	--self.Backdrop.BorderLeft:SetTexelSnappingBias(0)

	self.Backdrop.BorderRight = self.Backdrop:CreateTexture(nil, "BORDER", nil, 1)
	self.Backdrop.BorderRight:SetSize(BorderSize, BorderSize)
	self.Backdrop.BorderRight:SetPoint("TOPRIGHT", self.Backdrop, "TOPRIGHT", 0, 0)
	self.Backdrop.BorderRight:SetPoint("BOTTOMRIGHT", self.Backdrop, "BOTTOMRIGHT", 0, 0)
	--self.Backdrop.BorderRight:SetSnapToPixelGrid(false)
	--self.Backdrop.BorderRight:SetTexelSnappingBias(0)

	self.Backdrop:SetBorderColor(BorderR, BorderG, BorderB, BorderA)
end


Toolkit.Functions.HideBackdrop = function(frame)
    if (not frame.Backdrop) then
        return
    end

    frame.Backdrop:SetBackdrop({})
    frame.Backdrop:Hide()
    for _, BorderName in ipairs({"Top", "Right", "Bottom", "Left"}) do
        frame.Backdrop["Border" .. BorderName]:Kill()
    end
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
    -- Frame:SetTemplate("Transparent")

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
    if object.CreateBackdrop then mt.CreateBackdrop = Toolkit.API.CreateBackdrop end
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
