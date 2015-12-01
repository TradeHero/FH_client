module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList

local mWidget

function loadFrame()
	local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/GoldenTicketsIntroduce.json")
    local bg = widget:getChildByName("Image_bg")

    local btnClose = tolua.cast( bg:getChildByName("Button_Close"), "Button" )
    local btnBuy = tolua.cast( bg:getChildByName("Button_Buy"), "Button" )

    btnClose:addTouchEventListener( closeEventHandler )
    btnBuy:addTouchEventListener( buyEventHandler )

    widget:addTouchEventListener( onFrameTouch )
    mWidget = widget
    mWidget:registerScriptHandler( EnterOrExit )
    SceneManager.addWidget( mWidget )
    SceneManager.setKeyPadBackEnabled( false )
    CCUserDefault:sharedUserDefault():setBoolForKey( "INTRO_TICKET", true )
end

function EnterOrExit( eventType )
    if eventType == "enter" then
    elseif eventType == "exit" then
        mWidget = nil
    end
end

function closeEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        SceneManager.removeWidget( mWidget )
        SceneManager.setKeyPadBackEnabled( true )
    end
end

function buyEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        EventManager:postEvent( Event.Enter_Store )
    end
end


function onFrameTouch( sender, eventType )
    -- Do nothing, just block touch event.
end