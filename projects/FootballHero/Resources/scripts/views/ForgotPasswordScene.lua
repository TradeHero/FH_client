module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local ViewUtils = require("scripts.views.ViewUtils")

local EMAIL_CONTAINER_NAME = "emailContainer"

local mWidget

function loadFrame()
	local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/ForgotPassword.json")
    mWidget = widget
    mWidget:registerScriptHandler( EnterOrExit )
    SceneManager.clearNAddWidget(widget)

    local okBt = widget:getChildByName("OK")
    local cancelBt = widget:getChildByName("cancel")
    okBt:addTouchEventListener( okEventHandler )
    cancelBt:addTouchEventListener( cancelEventHandler )

    local emailInput = ViewUtils.createTextInput( mWidget:getChildByName( EMAIL_CONTAINER_NAME ), "E-mail address" )
    emailInput:setFontColor( ccc3( 0, 0, 0 ) )
end

function EnterOrExit( eventType )
    if eventType == "enter" then
    elseif eventType == "exit" then
        mWidget = nil
    end
end

function okEventHandler( sender,eventType )
    if eventType == TOUCH_EVENT_ENDED then
        local email = mWidget:getChildByName( EMAIL_CONTAINER_NAME ):getNodeByTag( 1 ):getText()
        EventManager:popHistory()
    end
end

function cancelEventHandler( sender,eventType )
	if eventType == TOUCH_EVENT_ENDED then
        EventManager:popHistory()
    end
end