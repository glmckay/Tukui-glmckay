--My own Maelstrom Stack Counter
local T, C, L = unpack(Tukui)

if T.MyClass ~= "SHAMAN" then return end

local ENHANCEMENT_SPEC_INDEX = 2

local TOTAL_BAR_WIDTH  = 300
local HEIGHT = 7
local BORDER = 2
local SPACING = 1
local MAX_STACKS = 5

local WIDTH = (TOTAL_BAR_WIDTH - (BORDER * 2 + SPACING) * (MAX_STACKS - 1)) / MAX_STACKS

--Number of stacks currently shown (used to know if an update is needed)
local CachedStacks = -1 -- Invalid value, forces an update
local CachedDuration = 0

--Create the main frame
local MCountView = CreateFrame("Frame", "MCountView", UIParent)

--Create a frame to monitor talents (to make OnEvent scripts more efficient)
local MCountController = CreateFrame("Frame", nil, UIParent)

--Create 5 frames (with status bars to shown time remaining)
for i = 1, MAX_STACKS do
	MCountView[i] = CreateFrame("StatusBar", "MCountView"..i, MCountView)
    MCountView[i]:SetStatusBarTexture(C["Medias"].Normal)
	if i == 1 then
		MCountView[i]:Point("BOTTOMLEFT", UIParent, "CENTER", -(TOTAL_BAR_WIDTH / 2), -130)
	else
		MCountView[i]:Point("LEFT", MCountView[i-1], "RIGHT", BORDER * 2 + SPACING, 0)
	end
    MCountView[i]:Size(WIDTH, HEIGHT)
    MCountView[i]:SetFrameLevel(2)
	MCountView[i]:SetStatusBarColor(1 - ((i - 1) / MAX_STACKS), (i - 1) / MAX_STACKS, 0)
	MCountView[i]:Hide()

    MCountView[i].Bg = CreateFrame("Frame", nil, MCountView[i])
    MCountView[i].Bg:SetTemplate("Transparent")
    MCountView[i].Bg:Point("BOTTOMLEFT", -BORDER, -BORDER)
    MCountView[i].Bg:Point("TOPRIGHT", BORDER, BORDER)
    MCountView[i].Bg:SetFrameLevel(1)
    MCountView[i].Bg:CreateShadow("Default")
end

-- Function to check if Maelstrom has charges
function CheckMaelstrom(self, event, ...)
    local _,_,_,Stacks,_,Duration,ExpTime = UnitAura("player", "Maelstrom Weapon");

    if Stacks == nil then
        Stacks = 0
    end

    if Stacks ~= CachedStacks then	--Only update if needed
        for i = 1, MAX_STACKS do
            if i <= Stacks then
                if not MCountView[i]:IsShown() then
                    MCountView[i]:Show()
                end
            else
                if MCountView[i]:IsShown() then
                    MCountView[i]:Hide()
                end
            end
        end
        CachedStacks = Stacks
    end

    if Stacks ~= 0 then
        if Duration ~= CachedDuration then
            for i = 1,MAX_STACKS do
                MCountView[i]:SetMinMaxValues(0, Duration)
            end
        end

        local remainingTime = ExpTime - GetTime()
        for i = 1,MAX_STACKS do
            MCountView[i]:SetValue(remainingTime)
        end
    end
end

-- Function to check if current spec is enhancement
-- Note: I don't check if our level is high enough to have learnt Maelstrom Weapon
--       because all my shamans are high enough level
function CheckSpec()
	local currentSpec = GetSpecialization()
	if currentSpec ~= nil and currentSpec == ENHANCEMENT_SPEC_INDEX then
    -- If the talent is active set the update handler
		CachedStacks = -1 -- Invalid to force update
		MCountView:SetScript("OnUpdate", CheckMaelstrom)
	else
        -- If the talent is inactive remove the update handler
		MCountView:SetScript("OnUpdate", nil)
		for i = 1,MAX_STACKS do
			MCountView[i]:Hide()
		end
	end
end

--Register for events on the controller
MCountController:RegisterEvent("PLAYER_ENTERING_WORLD")
MCountController:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
MCountController:RegisterEvent("PLAYER_REGEN_DISABLED")
MCountController:RegisterEvent("PLAYER_REGEN_ENABLED")
MCountController:SetScript("OnEvent", function(self, event)
    -- Enable/Disable the view on combat enter/leave
    if event == "PLAYER_REGEN_DISABLED" then
        MCountView:Show()
    elseif event == "PLAYER_REGEN_ENABLED" then
        MCountView:Hide()
    else
        -- Check spec on entering world or spec change
        CheckSpec()
        if not InCombatLockdown() then
            MCountView:Hide()
        end
    end
end)
