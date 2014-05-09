module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local ViewUtils = require("scripts.views.ViewUtils")
local Logic = require("scripts.Logic")

local EMAIL_CONTAINER_NAME = "emailContainer"
local PASSWORD_CONTAINER_NAME = "passwordContainer"

local mWidget
local inputWidth = 400
local inputHeight = 50

function loadFrame()
	local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/Signin.json")
    mWidget = widget
    mWidget:registerScriptHandler( EnterOrExit )
    SceneManager.clearNAddWidget(widget)

    local signinBt = widget:getChildByName("signin")
    local backBt = widget:getChildByName("back")
    local forgotPasswordBt = widget:getChildByName("forgotPassword")
    signinBt:addTouchEventListener( signinEventHandler )
    backBt:addTouchEventListener( backEventHandler )
    forgotPasswordBt:addTouchEventListener( forgotPasswordEventHandler )

    local emailInput = ViewUtils.createTextInput( mWidget:getChildByName( EMAIL_CONTAINER_NAME ), "E-mail address" )
    emailInput:setFontColor( ccc3( 0, 0, 0 ) )
    local passwordInput = ViewUtils.createTextInput( mWidget:getChildByName( PASSWORD_CONTAINER_NAME ), "Password" )
    passwordInput:setInputFlag( kEditBoxInputFlagPassword )
    passwordInput:setFontColor( ccc3( 0, 0, 0 ) )

    emailInput:setText( Logic.getInstance():getEmail() )
    passwordInput:setText( Logic.getInstance():getPassword() )
end

function EnterOrExit( eventType )
    if eventType == "enter" then
    elseif eventType == "exit" then
        mWidget = nil
    end
end

function backEventHandler( sender,eventType )
    if eventType == TOUCH_EVENT_ENDED then
        EventManager:postEvent( Event.Enter_Login_N_Reg )
    end
end

function signinEventHandler( sender,eventType )
	if eventType == TOUCH_EVENT_ENDED then
        local email = mWidget:getChildByName( EMAIL_CONTAINER_NAME ):getNodeByTag( 1 ):getText()
        local pass = mWidget:getChildByName( PASSWORD_CONTAINER_NAME ):getNodeByTag( 1 ):getText()

        EventManager:postEvent( Event.Do_Login, { email, pass } )
    end
end

function forgotPasswordEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        EventManager:postEvent( Event.Enter_Forgot_Password )
    end
end