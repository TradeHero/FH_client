module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList

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

    createTextInput( EMAIL_CONTAINER_NAME, "E-mail address", kEditBoxInputFlagInitialCapsAllCharacters, kEditBoxInputModeEmailAddr )
    createTextInput( PASSWORD_CONTAINER_NAME, "Password", kEditBoxInputFlagPassword, kEditBoxInputModeSingleLine )
    createTextInput( PASSWORD_CONF_CONTAINER_NAME, "Confirm Password", kEditBoxInputFlagPassword, kEditBoxInputModeSingleLine )
end

function backEventHandler( sender,eventType )
	if eventType == TOUCH_EVENT_ENDED then
        EventManager:postEvent( Event.Login_N_Reg )
    end
end

function registerEventHandler( sender,eventType )
	if eventType == TOUCH_EVENT_ENDED then
        local email = mWidget:getChildByName( EMAIL_CONTAINER_NAME ):getNodeByTag( 1 ):getText()
        local pass = mWidget:getChildByName( PASSWORD_CONTAINER_NAME ):getNodeByTag( 1 ):getText()
        local passConf = mWidget:getChildByName( PASSWORD_CONF_CONTAINER_NAME ):getNodeByTag( 1 ):getText()

        EventManager:postEvent( Event.Register_Name )
    end
end

function createTextInput( containerID, placeholderText, inputFlag, inputMode )
    local textInput = CCEditBox:create( CCSizeMake( inputWidth, inputHeight ), CCScale9Sprite:create() )
    local container = mWidget:getChildByName( containerID )
    container:addNode( textInput, 0, 1 )
    textInput:setPosition( inputWidth / 2, inputHeight / 2 )
    textInput:setFont("Newgtbxc", 20)
    textInput:setPlaceHolder( placeholderText )
    textInput:setInputFlag( inputFlag )
    textInput:setInputMode( inputMode )
end