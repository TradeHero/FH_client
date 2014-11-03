module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local Constants = require("scripts.Constants")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local ViewUtils = require("scripts.views.ViewUtils")
local Logic = require("scripts.Logic")


local mWidget
local mEmailInput
local mPasswordInput

local FADEIN_TIME = 0.5
local MOVE_TIME = 0.2
local EMAIL_CONTAINER_NAME = "emailContainer"
local PASSWORD_CONTAINER_NAME = "passwordContainer"

local mInputFontColor = ccc3( 0, 0, 0 )
local mInputPlaceholderFontColor = ccc3( 60, 58, 58 )

function loadFrame()
    mWidget = GUIReader:shareReader():widgetFromJsonFile("scenes/TutorialEmailSignin.json")
    mWidget:registerScriptHandler( EnterOrExit )
    SceneManager.addWidget( mWidget )
    mWidget:setPosition( ccp( Constants.GAME_WIDTH, 0 ) )

    local signin = mWidget:getChildByName("signin")
    signin:addTouchEventListener( signinEventHandler )

    local forgotPassword = mWidget:getChildByName("forgotPassword")
    forgotPassword:addTouchEventListener( forgotPasswordEventHandler )

    local backBt = mWidget:getChildByName("back")
    backBt:addTouchEventListener( backEventHandler )

    helperSetTouchEnabled( false )

    mEmailInput = ViewUtils.createTextInput( mWidget:getChildByName( EMAIL_CONTAINER_NAME ), Constants.String.email )
    mPasswordInput = ViewUtils.createTextInput( mWidget:getChildByName( PASSWORD_CONTAINER_NAME ), Constants.String.password )
    mPasswordInput:setInputFlag( kEditBoxInputFlagPassword )
    
    mEmailInput:setFontColor( mInputFontColor )
    mPasswordInput:setFontColor( mInputFontColor )

    mEmailInput:setPlaceholderFontColor( mInputPlaceholderFontColor )
    mPasswordInput:setPlaceholderFontColor( mInputPlaceholderFontColor )

    mEmailInput:setTouchPriority( SceneManager.TOUCH_PRIORITY_MINUS_ONE )
    mPasswordInput:setTouchPriority( SceneManager.TOUCH_PRIORITY_MINUS_ONE )

    mEmailInput:setText( Logic.getInstance():getEmail() )
    mPasswordInput:setText( Logic.getInstance():getPassword() )
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
    mEmailInput:closeKeyboard()
    mPasswordInput:closeKeyboard()
end

function signinEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        local email = mWidget:getChildByName( EMAIL_CONTAINER_NAME ):getNodeByTag( 1 ):getText()
        local pass = mWidget:getChildByName( PASSWORD_CONTAINER_NAME ):getNodeByTag( 1 ):getText()

        EventManager:postEvent( Event.Do_Login, { email, pass } )
    end
end

function forgotPasswordEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        EventManager:postEvent( Event.Enter_Tutorial_Ui_With_Type, { Constants.TUTORIAL_SHOW_FORGOT_PASSWORD } )
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
    local signin = mWidget:getChildByName("signin")
    signin:setTouchEnabled( enabled )

    local forgotPassword = mWidget:getChildByName("forgotPassword")
    forgotPassword:setTouchEnabled( enabled )

    local backBt = mWidget:getChildByName("back")
    backBt:setTouchEnabled( enabled )

    if enabled then
        mEmailInput:touchDownAction( nil, 0 )
    end
end

function helperGetTouchEnabled()
    local signin = mWidget:getChildByName("signin")
    return signin:isTouchEnabled()
end