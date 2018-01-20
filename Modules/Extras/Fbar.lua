-- My own Focus bar mod for Tukui
local T, C, L = unpack(Tukui)

if T.MyClass ~= "HUNTER" then return end

--Create the Anchor/BG frame
local Fbar = CreateFrame("Frame", "Fbar", UIParent)
Fbar:SetTemplate("Transparent")
Fbar:Size(304, 26)
Fbar:Point("CENTER", UIParent, "CENTER", 0, -119)
Fbar:CreateShadow("Default")

local FocusValue = 0

--Create the Status Bar
Fbar.sBar = CreateFrame("StatusBar", "Fbar.sBar",Fbar)
Fbar.sBar:SetStatusBarTexture(C.Medias.Blank)
Fbar.sBar:SetFrameLevel(5)
Fbar.sBar:Point("TOPLEFT", Fbar, "TOPLEFT", 2, -2)
Fbar.sBar:Point("BOTTOMRIGHT", Fbar, "BOTTOMRIGHT", -2, 2)
Fbar.sBar:SetStatusBarColor(171/255, 214/255, 116/255)	-- OuF Hunter Color

local Ftext = T.FontString(Fbar.sBar, nil, C.Medias.Font, 16, "THINOUTLINE")
Ftext:Point('CENTER', Fbar.sBar, 'CENTER', 0, 0)

--Function to update the focus
function UpdateFocus()
	if FocusValue ~= UnitPower('player') then
		FocusValue = UnitPower('player')
		Fbar.sBar:SetValue(FocusValue)
		Ftext:SetText(FocusValue)
	end
end

--Register Events
Fbar:RegisterEvent("PLAYER_ENTERING_WORLD")
Fbar:RegisterEvent("UNIT_MAXPOWER")		--Flags when the max power changes
Fbar:RegisterEvent("PLAYER_REGEN_DISABLED")
Fbar:RegisterEvent("PLAYER_REGEN_ENABLED")

--Set the Scripts
Fbar.sBar:SetScript("OnUpdate", UpdateFocus) --OnUpdate should only be called when the frame is shown
Fbar:SetScript("OnEvent", function (self, event)
	if event == "PLAYER_REGEN_DISABLED" then	--Show when entering combat
		Fbar:Show()
	elseif event == 'PLAYER_REGEN_ENABLED' then	--Hide when leaving combat
		-- Fbar:Hide()
	else										--Set the max power on load or when max power changes
		Fbar.sBar:SetMinMaxValues(0, UnitPowerMax("player"))
		if not InCombatLockdown() then			--Hide if not in combat
			-- Fbar:Hide()
		end
    end
end)