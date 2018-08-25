local T, C, L = Tukui:unpack()

local TukuiDT = T["DataTexts"]
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
            Frame:Width(width*2)
            Frame:Point("CENTER", DataTextCenter)
        else
            Frame:Width(width*3)
            if (i < 3) then
                Frame:Point("CENTER", DataTextCenter, "LEFT", width*(i*3-1), 0)
            else
                Frame:Point("CENTER", DataTextCenter, "RIGHT", -width*((6-i)*3-1), 0)
            end
        end
    end
end


-- For now just put it on the left (maybe eventually put firends/guild on left and others
--  at usual tooltip location)
local function GetTooltipAnchor(self)
    return T["Panels"].DataTextLeft, "ANCHOR_CURSOR", 0, T.Scale(5)
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
    for name,dt in pairs(self["Texts"]) do
        if (dt.Text) then
            HookMouseOver(dt)
        end
        dt.GetTooltipAnchor = GetTooltipAnchor
    end
end

-- Change default datatext positions
function TukuiDT:AddDefaults()
    TukuiData[GetRealmName()][UnitName("player")].Texts = {}
    TukuiData[GetRealmName()][UnitName("player")].Texts[L.DataText.Guild] = {true, 2}
    TukuiData[GetRealmName()][UnitName("player")].Texts[L.DataText.FPSAndMS] = {true, 1}
    TukuiData[GetRealmName()][UnitName("player")].Texts[L.DataText.Time] = {true, 3}
    TukuiData[GetRealmName()][UnitName("player")].Texts[L.DataText.Friends] = {true, 4}
    TukuiData[GetRealmName()][UnitName("player")].Texts[L.DataText.Gold] = {true, 5}
end


hooksecurefunc(TukuiDT, "Enable", EnableEdits)
hooksecurefunc(TukuiDT, "CreateAnchors", EditAnchors)

