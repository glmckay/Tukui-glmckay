local T, C, L = Tukui:unpack()

local UnitFrames = T.UnitFrames

if (Class ~= "SHAMAN") then
    return
end

UnitFrames.EditClassFeatures["SHAMAN"] = function(self)
    local Health = self.Health

    if (C.UnitFrames.TotemBar) then
        local Bar = self.Totems

        Bar:Width(ufWidth)
        Bar.Override = nil

        for i = 1, MAX_TOTEMS do
            local Icon = Bar[i].Icon

            Bar[i]:Kill()
            Bar[i] = CreateFrame("Frame", "TukuiTotemBarSlot"..i, Bar)
            Bar[i]:Size(30)
            Bar[i]:EnableMouse(true)
            Bar[i]:SetFrameLevel(Health:GetFrameLevel())
            Bar[i]:IsMouseEnabled(true)
            Bar[i]:SetBackdrop(UnitFrames.SkinnedBackdrop)
            Bar[i]:SetBackdropColor(0, 0, 0)

            if (i == 1) then
                Bar[i]:Point("BOTTOMLEFT", Bar, "BOTTOMLEFT", 0, 0)
            else
                Bar[i]:Point("LEFT", Bar[i-1], "RIGHT", ufSpacing, 0)
            end

            Bar[i].Cooldown = CreateFrame("Cooldown", nil, Bar[i])
            Bar[i].Cooldown:SetAllPoints()

            Icon:SetParent(Bar[i])
            Icon:SetAllPoints(Bar[i])
            Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
            Bar[i].Icon = Icon
        end
    end
end
