local T, C, L = unpack(Tukui)

local Fonts = T["Fonts"]

function Fonts:EditWoWFonts()
    local SetFont = self.SetFont

    local COMBAT = C.Medias.RegFontCond
    local NORMAL = C.Medias.ThinFontCond
    local NUMBER = C.Medias.ThinFontCond

    UNIT_NAME_FONT = NORMAL
    DAMAGE_TEXT_FONT = COMBAT
    STANDARD_TEXT_FONT = NORMAL

	SetFont(GameTooltipHeader, NORMAL, 12)
	SetFont(NumberFont_OutlineThick_Mono_Small, NUMBER, 12, "OUTLINE")
	SetFont(NumberFont_Outline_Huge, NUMBER, 28, "THICKOUTLINE", 28)
	SetFont(NumberFont_Outline_Large, NUMBER, 15, "OUTLINE")
	SetFont(NumberFont_Outline_Med, NUMBER, 13, "OUTLINE")
	SetFont(NumberFont_Shadow_Med, NORMAL, 12)
	SetFont(NumberFont_Shadow_Small, NORMAL, 12)
	SetFont(QuestFont, NORMAL, 14)
	SetFont(QuestFont_Large, NORMAL, 14)
	SetFont(SystemFont_Large, NORMAL, 15)
	SetFont(SystemFont_Med1, NORMAL, 12)
	SetFont(SystemFont_Med3, NORMAL, 13)
	SetFont(SystemFont_OutlineThick_Huge2, NORMAL, 20, "THICKOUTLINE")
	SetFont(SystemFont_Outline_Small, NUMBER, 12, "OUTLINE")
	SetFont(SystemFont_Shadow_Large, NORMAL, 15)
	SetFont(SystemFont_Shadow_Med1, NORMAL, 12)
	SetFont(SystemFont_Shadow_Med3, NORMAL, 13)
	-- SetFont(SystemFont_Shadow_Outline_Huge2, NORMAL, 20, "OUTLINE")
	SetFont(SystemFont_Shadow_Small, NORMAL, 11)
	SetFont(SystemFont_Small, NORMAL, 12)
	SetFont(SystemFont_Tiny, NORMAL, 12)
	SetFont(Tooltip_Med, NORMAL, 12)
	SetFont(Tooltip_Small, NORMAL, 12)
	SetFont(CombatTextFont, COMBAT, 200, "OUTLINE")
	SetFont(SystemFont_Shadow_Huge1, NORMAL, 20, "THINOUTLINE")
	SetFont(ZoneTextString, NORMAL, 32, "OUTLINE")
	SetFont(SubZoneTextString, NORMAL, 25, "OUTLINE")
	SetFont(PVPInfoTextString, NORMAL, 22, "THINOUTLINE")
	SetFont(PVPArenaTextString, NORMAL, 22, "THINOUTLINE")
	SetFont(FriendsFont_Normal, NORMAL, 12)
	SetFont(FriendsFont_Small, NORMAL, 11)
	SetFont(FriendsFont_Large, NORMAL, 14)
	SetFont(FriendsFont_UserText, NORMAL, 11)
end

Fonts:EditWoWFonts()
