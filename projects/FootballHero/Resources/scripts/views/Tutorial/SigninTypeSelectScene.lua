module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local Constants = require("scripts.Constants")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList


local mWidget

local FADEIN_TIME = 1.0
local MOVE_TIME = 0.2

function loadFrame()
    mWidget = GUIReader:shareReader():widgetFromJsonFile("scenes/TutorialSigninType.json")
    mWidget:registerScriptHandler( EnterOrExit )
    mWidget:setOpacity( 0 )
    SceneManager.addWidget( mWidget )

    local email = mWidget:getChildByName("email")
    email:addTouchEventListener( signinTypeEmailEventHandler )

    local facebook = mWidget:getChildByName("facebook")
    facebook:addTouchEventListener( signinTypeFacebookEventHandler )
    
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
    SceneManager.clearKeypadBackListener()
end

function signinTypeEmailEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        EventManager:postEvent( Event.Enter_Tutorial_Ui_With_Type, { Constants.TUTORIAL_SHOW_EMAIL_SELECT } )
        sender:setTouchEnabled( false )
    end
end

function signinTypeFacebookEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        EventManager:postEvent( Event.Do_FB_Connect )
        sender:setTouchEnabled( false )
    end
end

function playFadeInAnim( delayTime )
    local resultSeqArray = CCArray:create()

    if delayTime ~= nil and delayTime > 0 then
        resultSeqArray:addObject( CCDelayTime:create( delayTime ) )
    end
    resultSeqArray:addObject( CCFadeIn:create( FADEIN_TIME ) )
    resultSeqArray:addObject( CCCallFunc:create( function() 
        helperSetTouchEnabled( true )
    end ) )

    mWidget:runAction( CCSequence:create( resultSeqArray ) )
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
    local email = mWidget:getChildByName("email")
    email:setTouchEnabled( enabled )

    local facebook = mWidget:getChildByName("facebook")
    facebook:setTouchEnabled( enabled )
end

function helperGetTouchEnabled()
    local email = mWidget:getChildByName("email")
    return email:isTouchEnabled()
end