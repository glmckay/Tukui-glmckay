local T, C, L = unpack(Tukui)

function pairsByKeys (t, f)
    local a = {}
    for n in pairs(t) do table.insert(a, n) end
    table.sort(a)
    local i = 0      -- iterator variable
    local iter = function ()   -- iterator function
        i = i + 1
        if a[i] == nil then return nil
        else return a[i], t[a[i]]
        end
    end
    return iter
end

T.GetSpellId = function(searchString)
    local name, last
    local names = {}
    for i = 1, 500, 1 do
        name = GetSpellBookItemName(i, BOOKTYPE_SPELL)
        if not name then break end
        local stype, id = GetSpellBookItemInfo(i, BOOKTYPE_SPELL)
        if searchString ~= "" then
            if string.find(name, searchString) then
                print(name, id)
            end
        else
            names[name] = id
        end
    end

    if searchString == "" then
        for name, id in pairsByKeys(names) do
            print(name, id)
        end
    end
end

T.GetAuraIds = function(unit, filter)
    if (unit == "") then
        unit = "player"
    end
    local names = {}
    for i = 1,40 do
        local Name, _, _, _, _, _, _, _, _, SpellId = UnitAura(unit, i, filter)
        if not Name then break end
        names[Name] = SpellId
    end
    for name, id in pairsByKeys(names) do
        print(name, id)
    end
end



SLASH_SPELLS1 = "/spells"
SlashCmdList["SPELLS"] = T.GetSpellId

SLASH_BUFFS1 = "/buffs"
SlashCmdList["BUFFS"] = function(unit) T.GetAuraIds(unit, "HELPFUL") end

SLASH_DEBUFFS1 = "/debuffs"
SlashCmdList["DEBUFFS"] = function(unit) T.GetAuraIds(unit, "HARMFUL") end


T.testy = function(y)
    T.Panels.DataTextRight:SetPoint("RIGHT", T.Panels.BottomLine, -4, -y)
end

SLASH_TESTY1 = "/testy"
SlashCmdList["TESTY"] = T.testy