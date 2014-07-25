module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList

local mWidget

function loadFrame()
	local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/LoginNReg.json")
    mWidget = widget
    mWidget:registerScriptHandler( EnterOrExit )
    SceneManager.clearNAddWidget(widget)

    local loginNRegEmailBt = widget:getChildByName("loginNRegEmail")
    local facebookBt = widget:getChildByName("facebookConnect")
    local dev = tolua.cast( widget:getChildByName("dev"), "Button" )

    loginNRegEmailBt:addTouchEventListener( loginNRegEmailEventHandler )
    facebookBt:addTouchEventListener( facebookEventHandler )
    dev:addTouchEventListener( devEventHandler )
    dev:setEnabled( false )

    --local pProgram = CCShaderCache:sharedShaderCache():programForKey( 3 )
    --mWidget:setShaderProgram( pProgram )
end

function EnterOrExit( eventType )
    if eventType == "enter" then
    elseif eventType == "exit" then
        mWidget = nil
    end
end

function loginNRegEmailEventHandler( sender,eventType )
    if eventType == TOUCH_EVENT_ENDED then
        EventManager:postEvent( Event.Enter_Email_Login_N_Reg )
    end
end

function facebookEventHandler( sender,eventType )
    if eventType == TOUCH_EVENT_ENDED then
        EventManager:postEvent( Event.Do_FB_Connect ) 
    end
end

function devEventHandler( sender,eventType )
    if eventType == TOUCH_EVENT_ENDED then
         local RequestUtils = require("scripts.RequestUtils")
         RequestUtils.setServerIP("http://fhapi-dev1.cloudapp.net")
    end
end