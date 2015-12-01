module(..., package.seeall)

local Constants = require("scripts.Constants")
local SceneManager = require("scripts.SceneManager")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList

local mWidget

function loadFrame()
	local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/GetTickets.json")
    local bg = widget:getChildByName("Image_bg")
    
    local btnBuy = bg:getChildByName("Button_Buy")
    btnBuy:addTouchEventListener( buyEventHandler )

    local btnCancel =  bg:getChildByName("Button_Cancel")
    btnCancel:addTouchEventListener( onCancel )


    widget:addTouchEventListener( onFrameTouch )
    mWidget = widget
    mWidget:registerScriptHandler( EnterOrExit )
    SceneManager.addWidget( widget )
    SceneManager.setKeyPadBackEnabled( false )
end

function isShown()
    return mWidget ~= nil
end

function EnterOrExit( eventType )
    if eventType == "enter" then
    elseif eventType == "exit" then
        mWidget = nil
    end
end

function buyEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        SceneManager.removeWidget( mWidget )
        SceneManager.setKeyPadBackEnabled( true )
        EventManager:postEvent( Event.Enter_Store )
    end
end

function onCancel( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        SceneManager.setKeyPadBackEnabled( true )
        SceneManager.removeWidget( mWidget )
    end
end

function onFrameTouch( sender, eventType )
    -- Do nothing, just block touch event.
end