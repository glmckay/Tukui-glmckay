local T, C, L = Tukui:unpack()

local UnitFrames = T["UnitFrames"]

if (T.MyClass ~= "WARLOCK") then
    return
end

local BorderSize = C.General.BorderSize
local FrameWidth = UnitFrames.PlayerTargetWidth
local FrameHeight = 6
local ShardWidth = (FrameWidth - 4*BorderSize) / 5


UnitFrames.EditClassFeatures["WARLOCK"] = function(self)
    local Bar = self.SoulShards

    Bar:SetBackdrop(UnitFrames.SkinnedBackdrop)
    Bar:SetBackdropColor(0, 0, 0)

    Bar:ClearAllPoints()
    Bar:Size(FrameWidth, FrameHeight)

    if (C.UnitFrames.UnlinkPower) then
        Bar:Point("BOTTOMLEFT", self, "TOPLEFT", 0, BorderSize)
    else
        Bar:SetParent(self.PowerDisplayAnchor)
        Bar:Point("TOP", self.PowerDisplayAnchor)
    end

    for i = 1,5 do
        if (i == 3) then
            Bar[i]:Size(FrameWidth - 4*(ShardWidth + BorderSize), FrameHeight)
        else
            Bar[i]:Size(ShardWidth, FrameHeight)
        end

        if (i ~= 1) then
            Bar[i]:Point("LEFT", Bar[i-1], "RIGHT", BorderSize, 0)
        end
    end
end

-- hooksecurefunc(UnitFrames.AddClassFeatures, "WARLOCK", SetWarlockFeatures)