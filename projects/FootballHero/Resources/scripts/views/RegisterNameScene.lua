module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList

local USERNAME_CONTAINER_NAME = "usernameContainer"
local FIRSTNAME_CONTAINER_NAME = "firstnameContainer"
local LASTNAME_CONTAINER_NAME = "lastnameContainer"

local mWidget
local inputWidth = 400
local inputHeight = 50

function loadFrame()
	local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/LoginNReg/RegisterName.json")
    SceneManager.clearNAddWidget(widget)
    mWidget = widget

    local backBt = widget:getChildByName("back")
    local confirmBt = widget:getChildByName("confirm")

    backBt:addTouchEventListener( backEventHandler )
    confirmBt:addTouchEventListener( confirmEventHandler )

    createTextInput( USERNAME_CONTAINER_NAME, "Username", kEditBoxInputFlagInitialCapsAllCharacters, kEditBoxInputModeSingleLine )
    createTextInput( FIRSTNAME_CONTAINER_NAME, "First name", kEditBoxInputFlagInitialCapsAllCharacters, kEditBoxInputModeSingleLine )
    createTextInput( LASTNAME_CONTAINER_NAME, "Last name", kEditBoxInputFlagInitialCapsAllCharacters, kEditBoxInputModeSingleLine )
end

function backEventHandler( sender,eventType )
	if eventType == TOUCH_EVENT_ENDED then
        EventManager:postEvent( Event.Register )
    end
end

function confirmEventHandler( sender,eventType )
	if eventType == TOUCH_EVENT_ENDED then
        local email = mWidget:getChildByName( USERNAME_CONTAINER_NAME ):getNodeByTag( 1 ):getText()
        local pass = mWidget:getChildByName( FIRSTNAME_CONTAINER_NAME ):getNodeByTag( 1 ):getText()
        local passConf = mWidget:getChildByName( LASTNAME_CONTAINER_NAME ):getNodeByTag( 1 ):getText()

        EventManager:postEvent( Event.Load_Match_List )
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