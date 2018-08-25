local T, C, L = unpack(Tukui)

local ObjectiveTracker = T["Miscellaneous"]["ObjectiveTracker"]
local ObjectiveTrackerFrame = ObjectiveTrackerFrame

local function EditDefaultPosition(self)
    local Movers = T["Movers"]
    local Data = TukuiData[GetRealmName()][UnitName("Player")]
    local Anchor1, Parent, Anchor2, X, Y = "TOPRIGHT", UIParent, "TOPRIGHT", -30, -T.ScreenHeight / 4

    Movers:SaveDefaults(ObjectiveTrackerFrame, Anchor1, Parent, Anchor2, X, Y)

    -- Move the frame if the user hasn't specified a position (since Enable is run on PLAYER_ENTERING_WORLD)
    if not (Data and Data.Move and Data.Move.TukuiObjectiveTracker) then
        ObjectiveTrackerFrame:ClearAllPoints()
        ObjectiveTrackerFrame:SetPoint(Anchor1, Parent, Anchor2, X, Y)
    end
end

hooksecurefunc(ObjectiveTracker, "SetDefaultPosition", EditDefaultPosition)