module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local Constants = require("scripts.Constants")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local Logic = require("scripts.Logic").getInstance()


local mWidget

local FADEIN_TIME = 0.5
local MOVE_TIME = 0.2

function loadFrame()
    mWidget = GUIReader:shareReader():widgetFromJsonFile("scenes/TutorialEmail.json")
    mWidget:registerScriptHandler( EnterOrExit )
    SceneManager.addWidget( mWidget )
    mWidget:setPosition( ccp( Constants.GAME_WIDTH, 0 ) )

    local newUser = mWidget:getChildByName("newUser")
    newUser:addTouchEventListener( newUserEventHandler )

    local existingUser = mWidget:getChildByName("existingUser")
    existingUser:addTouchEventListener( existingUserEventHandler )

    local backBt = mWidget:getChildByName("Back")
    backBt:addTouchEventListener( backEventHandler )
    
    helperSetTouchEnabled( false )
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

function newUserEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        EventManager:postEvent( Event.Enter_Tutorial_Ui_With_Type, { Constants.TUTORIAL_SHOW_EMAIL_REGISTER } )
        sender:setTouchEnabled( false )
    end
end

function existingUserEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        if string.len( Logic:getEmail() ) > 0 and string.len( Logic:getPassword() ) > 0 then
            EventManager:postEvent( Event.Do_Login, { Logic:getEmail(), Logic:getPassword() } )
        else
            EventManager:postEvent( Event.Enter_Tutorial_Ui_With_Type, { Constants.TUTORIAL_SHOW_EMAIL_SIGNIN } )
            sender:setTouchEnabled( false )
        end
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
    local newUser = mWidget:getChildByName("newUser")
    newUser:setTouchEnabled( enabled )

    local existingUser = mWidget:getChildByName("existingUser")
    existingUser:setTouchEnabled( enabled )

    local backBt = mWidget:getChildByName("Back")
    backBt:setTouchEnabled( enabled )
end

function helperGetTouchEnabled()
    local newUser = mWidget:getChildByName("newUser")
    return newUser:isTouchEnabled()
end