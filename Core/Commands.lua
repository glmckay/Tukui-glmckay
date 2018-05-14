local T, C, L = unpack(Tukui)

T.GetSpellId = function(spellName)
    local name, last
    for i = 1, 500, 1 do
        name = GetSpellBookItemName(i, BOOKTYPE_SPELL)
        if not name then break end
        if name ~= last then
            local stype, id = GetSpellBookItemInfo(i, BOOKTYPE_SPELL)
            last = name
            if ((spellName == "") or (spellName == name)) then
                print(name, id)
            end
        end
    end
end

SLASH_GETSPELLID1 = "/GetSpellId"
SlashCmdList["GETSPELLID"] = T.GetSpellId
