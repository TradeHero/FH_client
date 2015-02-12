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

-- DS for chatMessages: see ChatMessages
function loadFrame()
    local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/ChatroomSelectScene.json")
    mWidget = widget
    mWidget:registerScriptHandler( EnterOrExit )
    SceneManager.clearNAddWidget( widget )
    
    Header.loadFrame( mWidget, Constants.String.chat_room_title, false )

    Navigator.loadFrame( widget )
    
    initContent()
end

function reloadFrame()
    initContent()
end

function initContent()

    for i = 1, table.getn( LeagueChatConfig ) do
        local button = mWidget:getChildByName( LeagueChatConfig[i]["buttonName"] )
        local label = tolua.cast( mWidget:getChildByName( LeagueChatConfig[i]["labelName"] ), "Label" )

        label:setText( Constants.String.league_chat[LeagueChatConfig[i]["displayNameKey"]] )
        --button:loadTexture( LeagueChatConfig[i]["logo"] )

        local counter = tolua.cast( button:getChildByName( "Button_Counter" ), "Button" )
        -- if no new messages
        counter:setEnabled( false )
        -- else
        -- counter:setTitleText()

        local eventHandler = function ( sender, eventType )
            if eventType == TOUCH_EVENT_ENDED then
                EventManager:postEvent( Event.Enter_League_Chat, { LeagueChatConfig[i]["chatRoomId"], i } )
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
