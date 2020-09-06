local T, C, L = Tukui:unpack()

local TukuiUnitFrames = T["UnitFrames"]

local function Defaults(priorityOverride)
    return {["enable"] = true, ["priority"] = priorityOverride or 0, ["stackThreshold"] = 0}
end

local UldirDebuffs = {
    -- Taloc
    271222, -- Plasma Discharge
    275189, -- Hardened Arteries (mythic)
    275205, -- Enlarged Heart (mythic)

    -- MOTHER
    267787, -- Sanitizing Strike (not sure about id)
    279660, -- Endemic Virus (mythic)
    279663, -- Spreading Epidemic (mythic)
    268198, -- Clinging Corruption

    -- Fetid Devourer
    262314, -- Putrid Paroxysm
    262313, -- Malodorous Miasma

    -- Zek'voz
    265360, -- Roiling Deceit
    270589, -- Void Wail
    270620, -- Psionic Blast
    265264, -- Void Lash
    264210, -- Jagged Mandible
    265662, -- Corruptor's Pact
    265646, -- Will of the Corruptor

    -- Vectis
    265129, -- Omega Vector
    265212, -- Gestate

    -- Zul, Reborn
    274271, -- Deathwish
    273365, -- Dark Revelation
    273434, -- Pit of Despair
    274358, -- Rupturing Blood

    -- Mythrax
    272536, -- Imminent Ruin
    272407, -- Oblivion Sphere (not sure about id)

    -- G'hunn
    267813, -- Blood Host
    267700, -- Gaze of G'hunn
    272508, -- Explosive Corruption
    273405, -- Dark Bargain
}


for _,debuff in ipairs(UldirDebuffs) do
    TukuiUnitFrames.DebuffsTracking["RaidDebuffs"]["spells"][debuff] = Defaults()
end
