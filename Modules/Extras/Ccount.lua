--My own Combo Point bar (took a lot of code from Smelly's sCombo for Tukui)
local T, C, L = unpack(Tukui)

if T.MyClass ~= "ROGUE" and T.MyClass ~= "DRUID" then return end

--Hide the normal combo points
--TukuiTarget:DisableElement('CPoints')
--for i = 1, 5 do TukuiTarget.CPoints[i]:Hide() end

--Create the main frame
local Ccount = CreateFrame("Frame", "Ccount", UIParent)

--Create the five bars
for i = 1, 5 do
	Ccount[i] = CreateFrame("Frame", "Ccount"..i, UIParent)
	if i == 1 then
		Ccount[i]:CreatePanel("Default", 50, 10, "LEFT", UIParent, "CENTER", -131, -150)
	else
		Ccount[i]:CreatePanel("Default", 50, 10, "LEFT", Ccount[i-1], "RIGHT", 3, 0)
	end
	Ccount[i]:CreateShadow("Default")
	Ccount[i]:SetBackdropBorderColor((255 - 51 * (i - 1)) / 255, (51 * (i - 1)) / 255, 0)
	Ccount[i]:Hide()
end

--Function to check and update the bars
function CheckCombo()
	local pts = GetComboPoints("player", "target")
	if pts > 0 then
		for i = 1, pts do
			Ccount[i]:Show()
		end
	else
		for i = 1, 5 do
			Ccount[i]:Hide()
		end
	end
end

--Register Events
Ccount:RegisterEvent("PLAYER_ENTERING_WORLD")
Ccount:RegisterEvent("UNIT_COMBO_POINTS")
Ccount:RegisterEvent("PLAYER_TARGET_CHANGED")

--Set the script
Ccount:SetScript("OnEvent", CheckCombo)
