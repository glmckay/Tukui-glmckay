local T, C, L = Tukui:unpack()

local ClassNameplateDebuffBL = nil

if (T.MyClass == "DEATHKNIGHT") then
    C["Misc"]["NumExpBars"] = 1
    ClassNameplateDebuffBL = {
        199721, -- Decomposing Aura
        214968, -- Necrotic Aura
    }
end

if (T.MyClass == "DEMONHUNTER") then
    C["Misc"]["NumExpBars"] = 2
end


if (T.MyClass == "MAGE") then
    C["Misc"]["NumExpBars"] = 2
end

if (T.MyClass == "MONK") then
    ClassNameplateDebuffBL = {
        -- 113746, -- Mystic Touch
        -- 115804, -- Mortal Wounds
        196608, -- Eye of the Tiger
        -- 273299, -- Sunrise Technique
        299905, -- Fusion Burn (Salvaged Incendiary Tool DoT)
    }

    -- Filter Stagger debuffs on me
    local StaggerFilter = { OtherPlayerOnly = true }
    for i = 124273,124275 do
        C["Party"]["DebuffBlacklist"][i] = StaggerFilter
    end
end


if (T.MyClass == "WARLOCK") then
    C["UnitFrames"]["UnlinkPower"] = false
end


-- Add debuffs to blacklist
if (ClassNameplateDebuffBL) then
    for _,debuff in ipairs(ClassNameplateDebuffBL) do
        C["NamePlates"]["PlayerDebuffBlacklist"][debuff] = true
    end
end
