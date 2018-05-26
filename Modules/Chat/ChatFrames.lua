local T, C, L = Tukui:unpack()

local TukuiChat = T["Chat"]

local ChatFrameHeight = 190
local DefaultChatFontSize = 13


-- Blizz doesn't treat the two default tabs the same way it treats the "dynamic" tabs created
-- user. the dynamic tabs are in a horizontal scroll frame and all get the same width regardless
-- of tab text. So when the tabs are at full width and don't overflow the scroll frame we let
-- the tabs get resized according to their text.
local FCFDock_UpdateTabs_Old = FCFDock_UpdateTabs

function FCFDock_UpdateTabs(dock, forceUpdate)
    local MAX_TAB_SIZE = 90 -- pulled from blizz files
    local wasDirty = dock.isDirty -- so we know if tabs were updated

    FCFDock_UpdateTabs_Old(dock, forceUpdate)

    if (wasDirty or forceUpdate) then
        local dynTabSize, hasOverflow = FCFDock_CalculateTabSize(dock, dock.scrollFrame.numDynFrames)

        if (dynTabSize == MAX_TAB_SIZE and not hasOverflow) then
            for i, chatFrame in ipairs(dock.DOCKED_CHAT_FRAMES) do
                if ( not chatFrame.isStaticDocked ) then
                    local chatTab = _G[chatFrame:GetName().."Tab"]
                    PanelTemplates_TabResize(chatTab, chatTab.sizePadding or 0) -- No 3rd arg dynTabSize
                end
            end
        end
    end
end


local function EditFrameStyle(self, frame)
    if frame.IsSkinEdited then
        return
    end

    local ID = frame:GetID()
    local FrameName = frame:GetName()
    local EditBox = _G[FrameName.."EditBox"]

    -- Reset the backdrop since Tukui forces backdrop color/alpha
    EditBox.Backdrop:SetTemplate()

    frame.IsSkinEdited = true
end


local function EditDefaultPositions()
    for i = 1,NUM_CHAT_WINDOWS do
        local Frame = _G["ChatFrame"..i]
        Frame:Height(ChatFrameHeight)

        local Settings = TukuiData[GetRealmName()][UnitName("Player")].Chat["Frame" .. i]
        Settings[6] = ChatFrameHeight
    end
end


local function EditInstall()
    -- I won't make font size a config option since it's only a default and
    -- it's possible to set it in-game.
    for i = 1,NUM_CHAT_WINDOWS do
        Frame = _G["ChatFrame"..i]
        FCF_SetChatWindowFontSize(Frame, Frame, DefaultChatFontSize)
    end

    -- Dock loot frame with the others
    if (C.Chat.LootFrame) then
        FCF_DockFrame(ChatFrame4)
        FCF_SetLocked(ChatFrame4, 1)
    end
end


hooksecurefunc(TukuiChat, "StyleFrame", EditFrameStyle)
hooksecurefunc(TukuiChat, "SetDefaultChatFramesPositions", EditDefaultPositions)
hooksecurefunc(TukuiChat, "Install", EditInstall)

