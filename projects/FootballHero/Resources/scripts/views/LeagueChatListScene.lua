module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local Navigator = require("scripts.views.Navigator")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local ViewUtils = require("scripts.views.ViewUtils")
local Logic = require("scripts.Logic").getInstance()
local Constants = require("scripts.Constants")

local mWidget
local mContainerHeight
local mHasTodayMessage
local MESSAGE_CONTAINER_NAME = "messageContainer"
local RELOAD_DELAY_TIME = 5

-- DS for chatMessages: see ChatMessages
function loadFrame()
    mCompetitionId = competitionId

    local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/Chat.json")
    mWidget = widget
    mWidget:registerScriptHandler( EnterOrExit )
    SceneManager.clearNAddWidget( widget )
    SceneManager.setKeypadBackListener( keypadBackEventHandler )

    Navigator.loadFrame( widget )

    
    local backBt = widget:getChildByName("Button_Back")
    backBt:addTouchEventListener( backEventHandler )

    initTitle();
    
    initContent()
end

function initTitle()    
    local title = tolua.cast( mWidget:getChildByName("title"), "Label" )
    title:setText( Constants.String.chat_room_title )
end

function initContent()

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

function backEventHandler( sender,eventType )
    if eventType == TOUCH_EVENT_ENDED then
        keypadBackEventHandler()
    end
end

function keypadBackEventHandler()
    EventManager:popHistory()
end
