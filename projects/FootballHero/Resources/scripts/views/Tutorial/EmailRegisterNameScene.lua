module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local Constants = require("scripts.Constants")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local ViewUtils = require("scripts.views.ViewUtils")


local mWidget

local FADEIN_TIME = 0.5
local MOVE_TIME = 0.2
local USERNAME_CONTAINER_NAME = "usernameContainer"
local FIRSTNAME_CONTAINER_NAME = "firstnameContainer"
local LASTNAME_CONTAINER_NAME = "lastnameContainer"

function loadFrame()
    mWidget = GUIReader:shareReader():widgetFromJsonFile("scenes/TutorialRegisterName.json")
    mWidget:registerScriptHandler( EnterOrExit )
    SceneManager.addWidget( mWidget )
    mWidget:setPosition( ccp( Constants.GAME_WIDTH, 0 ) )

    local confirmBt = mWidget:getChildByName("confirm")
    confirmBt:addTouchEventListener( confirmEventHandler )
    local logo = mWidget:getChildByName("logo")
    logo:addTouchEventListener( logoEventHandler )

    helperSetTouchEnabled( false )

    local userNameInput = ViewUtils.createTextInput( mWidget:getChildByName( USERNAME_CONTAINER_NAME ), Constants.String.user_name )
    local firstNameInput = ViewUtils.createTextInput( mWidget:getChildByName( FIRSTNAME_CONTAINER_NAME ), Constants.String.first_name_optional )
    local lastnameInput = ViewUtils.createTextInput( mWidget:getChildByName( LASTNAME_CONTAINER_NAME ), Constants.String.last_name_optional )

    userNameInput:setTouchPriority( SceneManager.TOUCH_PRIORITY_MINUS_ONE )
    firstNameInput:setTouchPriority( SceneManager.TOUCH_PRIORITY_MINUS_ONE )
    lastnameInput:setTouchPriority( SceneManager.TOUCH_PRIORITY_MINUS_ONE )
end

function isFrameShown()
    return mWidget:getPositionX() == 0
end

function EnterOrExit( eventType )
    if eventType == "enter" then
    elseif eventType == "exit" then
        mWidget = nil
    end
end

function confirmEventHandler( sender,eventType )
    if eventType == TOUCH_EVENT_ENDED then
        local userName = mWidget:getChildByName( USERNAME_CONTAINER_NAME ):getNodeByTag( 1 ):getText()
        local firstName = mWidget:getChildByName( FIRSTNAME_CONTAINER_NAME ):getNodeByTag( 1 ):getText()
        local lastName = mWidget:getChildByName( LASTNAME_CONTAINER_NAME ):getNodeByTag( 1 ):getText()

        EventManager:postEvent( Event.Do_Register_Name, { userName, firstName, lastName } )
    end
end

function logoEventHandler( sender,eventType )
    if eventType == TOUCH_EVENT_ENDED then
        Misc:sharedDelegate():selectImage( Constants.LOGO_IMAGE_PATH, logoSelectResultHandler )
    end
end

function playMoveAnim( moveDirection, delayTime )
    local resultSeqArray = CCArray:create()
    if delayTime ~= nil and delayTime > 0 then
        resultSeqArray:addObject( CCDelayTime:create( delayTime ) )
    end
    if helperGetTouchEnabled() then
        resultSeqArray:addObject( CCCallFunc:create( function()
            helperSetTouchEnabled( false )
        end ) )
    end
    resultSeqArray:addObject( CCMoveBy:create( MOVE_TIME, ccp( Constants.GAME_WIDTH * moveDirection, 0 ) ) )
    if not helperGetTouchEnabled() then
        resultSeqArray:addObject( CCCallFunc:create( function()
            helperSetTouchEnabled( true )
        end ) )
    end

    mWidget:runAction( CCSequence:create( resultSeqArray ) )

    return MOVE_TIME
end

function helperSetTouchEnabled( enabled )
    local confirmBt = mWidget:getChildByName("confirm")
    confirmBt:setTouchEnabled( enabled )
end

function helperGetTouchEnabled()
    local confirmBt = mWidget:getChildByName("confirm")
    return confirmBt:isTouchEnabled()
end