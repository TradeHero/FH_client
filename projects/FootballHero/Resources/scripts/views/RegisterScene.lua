module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local ViewUtils = require("scripts.views.ViewUtils")

local EMAIL_CONTAINER_NAME = "emailContainer"
local PASSWORD_CONTAINER_NAME = "passwordContainer1"
local PASSWORD_CONF_CONTAINER_NAME = "passwordContainer2"

local mWidget
local inputWidth = 400
local inputHeight = 50

function loadFrame()
	local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/LoginNReg/Register.json")
    SceneManager.clearNAddWidget(widget)
    mWidget = widget

    local backBt = widget:getChildByName("back")
    local registerBt = widget:getChildByName("register")

    backBt:addTouchEventListener( backEventHandler )
    registerBt:addTouchEventListener( registerEventHandler )

    local emailInput = ViewUtils.createTextInput( mWidget:getChildByName( EMAIL_CONTAINER_NAME ), "E-mail address" )
    local passwordInput = ViewUtils.createTextInput( mWidget:getChildByName( PASSWORD_CONTAINER_NAME ), "Password" )
    local passwordConfInput = ViewUtils.createTextInput( mWidget:getChildByName( PASSWORD_CONF_CONTAINER_NAME ), "Confirm Password" )

    passwordInput:setInputFlag( kEditBoxInputFlagPassword )
    passwordConfInput:setInputFlag( kEditBoxInputFlagPassword )
end

function backEventHandler( sender,eventType )
	if eventType == TOUCH_EVENT_ENDED then
        EventManager:postEvent( Event.Enter_Login_N_Reg )
    end
end

function registerEventHandler( sender,eventType )
	if eventType == TOUCH_EVENT_ENDED then
        local email = mWidget:getChildByName( EMAIL_CONTAINER_NAME ):getNodeByTag( 1 ):getText()
        local pass = mWidget:getChildByName( PASSWORD_CONTAINER_NAME ):getNodeByTag( 1 ):getText()
        local passConf = mWidget:getChildByName( PASSWORD_CONF_CONTAINER_NAME ):getNodeByTag( 1 ):getText()

        EventManager:postEvent( Event.Do_Register, { email, pass, passConf } )

        --EventManager:postEvent( Event.Enter_Register_Name )
    end
end