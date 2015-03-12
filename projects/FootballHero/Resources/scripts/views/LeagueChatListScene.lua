module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local Navigator = require("scripts.views.Navigator")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local ViewUtils = require("scripts.views.ViewUtils")
local Logic = require("scripts.Logic").getInstance()
local Constants = require("scripts.Constants")
local LeagueChatConfig = require("scripts.config.LeagueChat").LeagueChatType
local Header = require("scripts.views.HeaderFrame")

local mWidget
local mContainerHeight
local mHasTodayMessage
local MESSAGE_CONTAINER_NAME = "messageContainer"
local RELOAD_DELAY_TIME = 5

-- DS for roomInfos: { quickbloxRoomId: unreadMessageCount }
function loadFrame( roomInfos )
    local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/ChatroomSelectScene.json")
    mWidget = widget
    mWidget:registerScriptHandler( EnterOrExit )
    SceneManager.clearNAddWidget( widget )
    SceneManager.clearKeypadBackListener()
    
    Header.loadFrame( mWidget, Constants.String.chat_room_title, false )

    Navigator.loadFrame( widget )
    
    initContent( roomInfos )
end

function reloadFrame( roomInfos )
    initContent( roomInfos )
end

function initContent( roomInfos )

    for i = 1, table.getn( LeagueChatConfig ) do
        local chatConfig = LeagueChatConfig[i]
        local button = mWidget:getChildByName( chatConfig["buttonName"] )
        local label = tolua.cast( mWidget:getChildByName( chatConfig["labelName"] ), "Label" )
        local counter = tolua.cast( button:getChildByName( "Button_Counter" ), "Button" )

        label:setText( Constants.String.league_chat[chatConfig["displayNameKey"]] )

        -- Update the unread message counter.
        counter:setEnabled( false )
        if chatConfig["useQuickBlox"] then
            local unreadMessageCount = roomInfos[chatConfig["quickBloxID"]]
            if unreadMessageCount and unreadMessageCount > 0 then
                counter:setEnabled( true )
                if unreadMessageCount < 100 then
                    counter:setTitleText( unreadMessageCount )
                else
                    counter:setTitleText( "99+" )
                end
            end
        end

        local eventHandler = function ( sender, eventType )
            if eventType == TOUCH_EVENT_ENDED then
                if chatConfig["useQuickBlox"] then
                    EventManager:postEvent( Event.Enter_Quickblox_Chatroom, { chatConfig["quickBloxJID"], i } )
                else
                    EventManager:postEvent( Event.Enter_League_Chat, { chatConfig["chatRoomId"], i } )
                end
            end
        end
        button:addTouchEventListener( eventHandler )
    end

    local facebookBtn = mWidget:getChildByName( "Button_Facebook" )
    local facebookLbl = tolua.cast( mWidget:getChildByName( "Label_Facebook" ), "Label" )
    local likeCount = tolua.cast( facebookBtn:getChildByName( "Label_Likes"), "Label" )

    facebookLbl:setText( Constants.String.league_chat.facebook )

end

function EnterOrExit( eventType )
    if eventType == "enter" then
    elseif eventType == "exit" then
        mWidget = nil
    end
end

function isFrameShown()
    return mWidget ~= nil
end
