local T, C, L = Tukui:unpack()

local DataTexts = T["DataTexts"]
local Panels = T["Panels"]

local FadeOutAlpha = 0.4

local Noop = function() end

-- Remove & in between FPS and MS for FPS/MS datatext
L.DataText.FPS = "FPS"


-- Magic numbers for now until I figure out how I want to space these out nicely
local function EditAnchors(self)
    local DataTextCenter = Panels.DataTextCenter
    local width = math.floor(DataTextCenter:GetWidth() / 14)

    for i = 1, 6 do
        local Frame = self.Anchors[i]

        Frame:ClearAllPoints()
        if (i == 3) then
            Frame:SetWidth(width*2)
            Frame:SetPoint("CENTER", DataTextCenter)
        else
            Frame:SetWidth(width*3)
            if (i < 3) then
                Frame:SetPoint("CENTER", DataTextCenter, "LEFT", width*(i*3-1), 0)
            else
                Frame:SetPoint("CENTER", DataTextCenter, "RIGHT", -width*((6-i)*3-1), 0)
            end
        end
    end
end


-- For now just put it on the left (maybe eventually put firends/guild on left and others
--  at usual tooltip location)
local function GetTooltipAnchor(self)
    return DataTexts.Panels.Left, "ANCHOR_CURSOR", 0, 4
end


local function FadeIn(self)
    self.Text:SetAlpha(1)
end


local function FadeOut(self)
    self.Text:SetAlpha(FadeOutAlpha)
end


local function HookMouseOver(dt)
    dt:HookScript("OnEnter", FadeIn)
    dt:HookScript("OnLeave", FadeOut)
    dt.Text:SetAlpha(FadeOutAlpha)
end


local function EnableEdits(self)
    for name,dt in pairs(self["DataTexts"]) do
        if (dt.Text) then
            HookMouseOver(dt)
        end
        dt.GetTooltipAnchor = GetTooltipAnchor
    end

    for _, Panel in pairs(self.Panels) do
        T.Toolkit.Functions.HideBackdrop(Panel)
    end
end

-- Change default datatext positions
function DataTexts:AddDefaults()
    TukuiData[GetRealmName()][UnitName("player")].DataTexts = {}
    TukuiData[GetRealmName()][UnitName("player")].DataTexts["Guild"] = {true, 2}
    TukuiData[GetRealmName()][UnitName("player")].DataTexts["System"] = {true, 1}
    TukuiData[GetRealmName()][UnitName("player")].DataTexts["Time"] = {true, 3}
    TukuiData[GetRealmName()][UnitName("player")].DataTexts["Friends"] = {true, 4}
    TukuiData[GetRealmName()][UnitName("player")].DataTexts["Character"] = {true, 5}
end


hooksecurefunc(DataTexts, "Enable", EnableEdits)
hooksecurefunc(DataTexts, "CreateAnchors", EditAnchors)

