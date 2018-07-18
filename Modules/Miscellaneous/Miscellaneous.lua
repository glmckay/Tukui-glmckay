local T, C, L = Tukui:unpack()

local Miscellaneous = T["Miscellaneous"]
local Movers = T["Movers"]

-- A bunch of small changes to miscellaneous Tukui things



local MirrorTimers = Miscellaneous["MirrorTimers"]

local function UpdateMirrorTimers(self)
    for i = 1, MIRRORTIMER_NUMTIMERS, 1 do
        local Bar = _G["MirrorTimer"..i]
        if not Bar.isTextEdited then
            local Text = _G[Bar:GetName().."Text"]

            Text:SetFont(C["Medias"].RegFont, 14, "OUTLINE")

            Bar.isTextEdited = true
        end
    end
end

hooksecurefunc(MirrorTimers, "Update", UpdateMirrorTimers)



local VehicleIndicator = Miscellaneous["VehicleIndicator"]

local function PositionVehicleIndicator(self)
    local Indicator = VehicleSeatIndicator

    Indicator:SetPoint("BOTTOMLEFT", T.ScreenWidth / 7, T.ScreenHeight / 4)

    Movers:RegisterFrame(Indicator)
end

hooksecurefunc(VehicleIndicator, "Enable", PositionVehicleIndicator)



local ObjectiveTracker = Miscellaneous["ObjectiveTracker"]

local function PositionObjectiveTracker(self)
    local Data = TukuiData[GetRealmName()][UnitName("Player")]
    local Anchor1, Parent, Anchor2, X, Y = "TOPRIGHT", UIParent, "TOPRIGHT", -30, -T.ScreenHeight / 4

    Movers:SaveDefaults(self, Anchor1, Parent, Anchor2, X, Y)

    -- Move the frame if the user hasn't specified a position (since Enable is run on PLAYER_ENTERING_WORLD)
    if not (Data and Data.Move and Data.Move.TukuiObjectiveTracker) then
        self:SetPoint(Anchor1, Parent, Anchor2, X, Y)
    end
end

hooksecurefunc(ObjectiveTracker, "Enable", PositionObjectiveTracker)

