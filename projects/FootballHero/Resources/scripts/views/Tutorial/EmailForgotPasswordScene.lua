module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local Constants = require("scripts.Constants")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local ViewUtils = require("scripts.views.ViewUtils")


local mWidget

local FADEIN_TIME = 0.5
local MOVE_TIME = 0.2
local EMAIL_CONTAINER_NAME = "emailContainer"

function loadFrame()
    mWidget = GUIReader:shareReader():widgetFromJsonFile("scenes/TutorialForgotPassword.json")
    mWidget:registerScriptHandler( EnterOrExit )
    SceneManager.addWidget( mWidget )
    mWidget:setPosition( ccp( Constants.GAME_WIDTH, 0 ) )

    local OK = mWidget:getChildByName("OK")
    OK:addTouchEventListener( okEventHandler )

    local cancel = mWidget:getChildByName("cancel")
    cancel:addTouchEventListener( cancelEventHandler )

    local backBt = mWidget:getChildByName("back")
    backBt:addTouchEventListener( backEventHandler )

    helperSetTouchEnabled( false )

    local emailInput = ViewUtils.createTextInput( mWidget:getChildByName( EMAIL_CONTAINER_NAME ), "E-mail Address" )
    emailInput:setTouchPriority( SceneManager.TOUCH_PRIORITY_MINUS_ONE )
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

function onShown()
    SceneManager.setKeypadBackListener( keypadBackEventHandler )
end

function backEventHandler( sender,eventType )
    if eventType == TOUCH_EVENT_ENDED then
        keypadBackEventHandler()
        sender:setTouchEnabled( false )
    end
end

function keypadBackEventHandler()
    EventManager:popHistory()
end

function okEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        local email = mWidget:getChildByName( EMAIL_CONTAINER_NAME ):getNodeByTag( 1 ):getText()
        EventManager:postEvent( Event.Do_Password_Reset, { email } )
    end
end

function cancelEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        EventManager:popHistory()
        sender:setTouchEnabled( false )
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
    local OK = mWidget:getChildByName("OK")
    OK:setTouchEnabled( enabled )

    local cancel = mWidget:getChildByName("cancel")
    cancel:setTouchEnabled( enabled )

    local backBt = mWidget:getChildByName("back")
    backBt:setTouchEnabled( enabled )
end

function helperGetTouchEnabled()
    local OK = mWidget:getChildByName("OK")
    return OK:isTouchEnabled()
end