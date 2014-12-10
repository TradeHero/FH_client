module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local Constants = require("scripts.Constants")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local ViewUtils = require("scripts.views.ViewUtils")


local mWidget
local mEmailInput

local FADEIN_TIME = 0.5
local MOVE_TIME = 0.2
local EMAIL_CONTAINER_NAME = "emailContainer"
local PASSWORD_CONTAINER_NAME = "passwordContainer1"
local PASSWORD_CONF_CONTAINER_NAME = "passwordContainer2"
local USERNAME_CONTAINER_NAME = "usernameContainer"
local FIRSTNAME_CONTAINER_NAME = "firstnameContainer"
local LASTNAME_CONTAINER_NAME = "lastnameContainer"

local mInputFontColor = ccc3( 0, 0, 0 )
local mInputPlaceholderFontColor = ccc3( 60, 58, 58 )


local mLogoSelected

function loadFrame()
    mWidget = GUIReader:shareReader():widgetFromJsonFile("scenes/TutorialEmailRegister.json")
    mWidget:registerScriptHandler( EnterOrExit )
    SceneManager.addWidget( mWidget )
    mWidget:setPosition( ccp( Constants.GAME_WIDTH, 0 ) )

    local register = mWidget:getChildByName("register")
    register:addTouchEventListener( registerEventHandler )

    local backBt = mWidget:getChildByName("back")
    backBt:addTouchEventListener( backEventHandler )

    helperSetTouchEnabled( false )

    mEmailInput = ViewUtils.createTextInput( mWidget:getChildByName( EMAIL_CONTAINER_NAME ), Constants.String.email )
    local passwordInput = ViewUtils.createTextInput( mWidget:getChildByName( PASSWORD_CONTAINER_NAME ), Constants.String.password )
    local passwordConfInput = ViewUtils.createTextInput( mWidget:getChildByName( PASSWORD_CONF_CONTAINER_NAME ), Constants.String.password_confirm )
    local userNameInput = ViewUtils.createTextInput( mWidget:getChildByName( USERNAME_CONTAINER_NAME ), Constants.String.user_name )
    local firstNameInput = ViewUtils.createTextInput( mWidget:getChildByName( FIRSTNAME_CONTAINER_NAME ), Constants.String.first_name )
    local lastnameInput = ViewUtils.createTextInput( mWidget:getChildByName( LASTNAME_CONTAINER_NAME ), Constants.String.last_name )
    local logoInput = mWidget:getChildByName("logo")

    mEmailInput:setFontColor( mInputFontColor )
    passwordInput:setFontColor( mInputFontColor )
    passwordConfInput:setFontColor( mInputFontColor )
    userNameInput:setFontColor( mInputFontColor )
    firstNameInput:setFontColor( mInputFontColor )
    lastnameInput:setFontColor( mInputFontColor )

    mEmailInput:setPlaceholderFontColor( mInputPlaceholderFontColor )
    passwordInput:setPlaceholderFontColor( mInputPlaceholderFontColor )
    passwordConfInput:setPlaceholderFontColor( mInputPlaceholderFontColor )
    userNameInput:setPlaceholderFontColor( mInputPlaceholderFontColor )
    firstNameInput:setPlaceholderFontColor( mInputPlaceholderFontColor )
    lastnameInput:setPlaceholderFontColor( mInputPlaceholderFontColor )

    mEmailInput:setTouchPriority( SceneManager.TOUCH_PRIORITY_ZERO )
    passwordInput:setTouchPriority( SceneManager.TOUCH_PRIORITY_ZERO )
    passwordConfInput:setTouchPriority( SceneManager.TOUCH_PRIORITY_ZERO )
    userNameInput:setTouchPriority( SceneManager.TOUCH_PRIORITY_ZERO )
    firstNameInput:setTouchPriority( SceneManager.TOUCH_PRIORITY_ZERO )
    lastnameInput:setTouchPriority( SceneManager.TOUCH_PRIORITY_ZERO )

    passwordInput:setInputFlag( kEditBoxInputFlagPassword )
    passwordConfInput:setInputFlag( kEditBoxInputFlagPassword )

    logoInput:addTouchEventListener( logoEventHandler )

    mLogoSelected = false
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

function registerEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        local email = mWidget:getChildByName( EMAIL_CONTAINER_NAME ):getNodeByTag( 1 ):getText()
        local pass = mWidget:getChildByName( PASSWORD_CONTAINER_NAME ):getNodeByTag( 1 ):getText()
        local passConf = mWidget:getChildByName( PASSWORD_CONF_CONTAINER_NAME ):getNodeByTag( 1 ):getText()
        local userName = mWidget:getChildByName( USERNAME_CONTAINER_NAME ):getNodeByTag( 1 ):getText()
        local firstName = mWidget:getChildByName( FIRSTNAME_CONTAINER_NAME ):getNodeByTag( 1 ):getText()
        local lastName = mWidget:getChildByName( LASTNAME_CONTAINER_NAME ):getNodeByTag( 1 ):getText()

        EventManager:postEvent( Event.Do_Register, { email, pass, passConf, userName, firstName, lastName, mLogoSelected } )
    end
end

function logoEventHandler( sender,eventType )
    if eventType == TOUCH_EVENT_ENDED then
        local logoSelectResultHandler = function( success )
            if success then
                local logoInput = tolua.cast( mWidget:getChildByName("logo"), "ImageView" )
                logoInput:loadTexture( Constants.LOGO_IMAGE_PATH )
                mLogoSelected = true
            end
        end

        Misc:sharedDelegate():selectImage( Constants.LOGO_IMAGE_PATH, 100, 100, logoSelectResultHandler )
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
    local register = mWidget:getChildByName("register")
    register:setTouchEnabled( enabled )

    local backBt = mWidget:getChildByName("back")
    backBt:setTouchEnabled( enabled )

    if enabled then
        mEmailInput:touchDownAction( nil, 0 )
    end
end

function helperGetTouchEnabled()
    local register = mWidget:getChildByName("register")
    return register:isTouchEnabled()
end