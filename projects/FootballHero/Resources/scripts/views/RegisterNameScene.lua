module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local ViewUtils = require("scripts.views.ViewUtils")

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

    ViewUtils.createTextInput( mWidget:getChildByName( USERNAME_CONTAINER_NAME ), "Username" )
    ViewUtils.createTextInput( mWidget:getChildByName( FIRSTNAME_CONTAINER_NAME ), "First name" )
    ViewUtils.createTextInput( mWidget:getChildByName( LASTNAME_CONTAINER_NAME ), "Last name" )
end

function backEventHandler( sender,eventType )
	if eventType == TOUCH_EVENT_ENDED then
        EventManager:postEvent( Event.Enter_Register )
    end
end

function confirmEventHandler( sender,eventType )
	if eventType == TOUCH_EVENT_ENDED then
        local email = mWidget:getChildByName( USERNAME_CONTAINER_NAME ):getNodeByTag( 1 ):getText()
        local pass = mWidget:getChildByName( FIRSTNAME_CONTAINER_NAME ):getNodeByTag( 1 ):getText()
        local passConf = mWidget:getChildByName( LASTNAME_CONTAINER_NAME ):getNodeByTag( 1 ):getText()

        EventManager:postEvent( Event.Enter_Match_List, { email, pass, passConf } )
    end
end