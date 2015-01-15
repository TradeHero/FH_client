module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local Navigator = require("scripts.views.Navigator")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local SettingsConfig = require("scripts.config.Settings")
local SpinWheelConfig = require("scripts.config.SpinWheel")
local Constants = require("scripts.Constants")
local ViewUtils = require("scripts.views.ViewUtils")
local Logic = require("scripts.Logic").getInstance()
local ConnectingMessage = require("scripts.views.ConnectingMessage")


-- Below value is per second
local MAX_ROTATE_SPEED = 180
local BEGIN_ROTATE_ACCELERATE = 180
local STOP_ROTATE_ACCELERATE = -30
local MAX_WHEEL_START_BOUNCE_ROTATION = -5
local BEGIN_BOUNCE_SPEED = -10
local MAX_WHEEL_STOP_BOUNCE_ROTATION = 5
local STOP_BOUNCE_SPEED = 5
local STOP_ROTATION_SUM = 30 * 6 * 6 / 2 - 8
local ANGLE_PER_PIECE = 360 / 13

-- States
local WHEEL_STATE_START = 0
local WHEEL_STATE_START_BOUNCE = 1
local WHEEL_STATE_START_RUNNING = 2
local WHEEL_STATE_CHECK_STOP_ANGLE = 3
local WHEEL_STATE_STOP_RUNNING = 4
local WHEEL_STATE_STOP_BOUNCE = 5
local WHEEL_STATE_STOP = 6

local mInputFontColor = ccc3( 255, 255, 255 )
local mInputPlaceholderFontColor = ccc3( 200, 200, 200 )

local mWidget
local mSoundEffectHandle = nil
local mWheelTickHandler
local mWheelState
local mIsBonusSpin
local mWheelBG
local mWheelCurrentSpeed
local mTargetStopAngle
local mSpinnerAnimating
local mStopPressed
local mWinPrizeWidget
local mWinTicketWidget
local mWinShareWidget
local mWinTicketEmailInput
local mWinPrizeId
local mWinNumTicketLeft

function loadFrame()
	local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/SpinWheel.json")
    mWidget = widget

    widget:registerScriptHandler( EnterOrExit )
    SceneManager.clearNAddWidget( widget )
    SceneManager.setKeypadBackListener( keypadBackEventHandler )

    mWheelBG = tolua.cast( mWidget:getChildByName("wheelBG"), "ImageView" )
    local backBt = mWidget:getChildByName("Button_Back")
    local stopBt = mWidget:getChildByName("Button_stop")
    local winnerBt = mWidget:getChildByName("Button_winner")
    local balanceBt = mWidget:getChildByName("Button_balance")
    local normalSpinTitle = tolua.cast( mWidget:getChildByName("Label_normalTitle"), "Label" )
    local bonusSpinTitle = tolua.cast( mWidget:getChildByName("Label_bonusTitle"), "Label" )
    backBt:addTouchEventListener( backEventHandler )
    stopBt:addTouchEventListener( stopEventHandler )
    winnerBt:addTouchEventListener( winnerEventHandler )
    balanceBt:addTouchEventListener( balanceEventHandler )
    normalSpinTitle:setEnabled( true )
    bonusSpinTitle:setEnabled( false )

    Navigator.loadFrame( widget )

    initContent()
    initWinPrizeWidget()
    initWinTicketWidget()
    initShareWidget()

    mWheelState = WHEEL_STATE_START
    playStartAnim()

    mIsBonusSpin = false
    mSpinnerAnimating = false
    mStopPressed = false
end

function EnterOrExit( eventType )
    if eventType == "enter" then
    elseif eventType == "exit" then
        if mSoundEffectHandle then
            AudioEngine.stopEffect( mSoundEffectHandle )
            mSoundEffectHandle = nil
        end
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry( mWheelTickHandler )
        if mWinTicketEmailInput then
            mWinTicketEmailInput:closeKeyboard()
            mWinTicketEmailInput = nil
        end
        mWidget = nil
    end
end

function isFrameShown()
    return mWidget ~= nil
end

function backEventHandler( sender,eventType )
    if eventType == TOUCH_EVENT_ENDED then
        keypadBackEventHandler()
    end
end

function keypadBackEventHandler()
    EventManager:popHistory()
end

function initContent()
    local wheelPanel = GUIReader:shareReader():widgetFromJsonFile("scenes/WheelPanel.json")
    local wheelPanelBG = wheelPanel:getChildByName("wheelBG")

    for i = 1, table.getn( SpinWheelConfig.getPrizeOrder() ) do
        local prize = tolua.cast( wheelPanelBG:getChildByName("prize"..i), "ImageView" )
        local text = tolua.cast (wheelPanelBG:getChildByName("text"..i), "Label" )
        local prizeId = SpinWheelConfig.getPrizeOrder()[i]
        local config = SpinWheelConfig.getPrizeConfigWithID( prizeId )

        prize:loadTexture( config["LocalUrl"] )
        text:setText( config["Name"] )
    end

    local FILE_NAME = "wheelPanelImage.png"
    local wheelPanelImage = CCRenderTexture:create( wheelPanel:getSize().width, wheelPanel:getSize().height )
    wheelPanelImage:beginWithClear(0, 0, 0, 0)
    wheelPanelBG:visit()
    wheelPanelImage:endToLua()
    wheelPanelImage:saveToFile( FILE_NAME,  kCCImageFormatPNG )
    mWheelBG:loadTexture( FILE_NAME )
    CCLuaLog( CCFileUtils:sharedFileUtils():fullPathForFilename( FILE_NAME ) )
end

function initWinPrizeWidget()
    mWinPrizeWidget = GUIReader:shareReader():widgetFromJsonFile("scenes/SpinWin.json")
    mWidget:addChild( mWinPrizeWidget )
    mWinPrizeWidget:setEnabled( false )
    
    mWinPrizeWidget:addTouchEventListener( onWinPrizeFrameTouch )
end

function initWinTicketWidget()
    mWinTicketWidget = GUIReader:shareReader():widgetFromJsonFile("scenes/SpinWinTicket.json")
    mWidget:addChild( mWinTicketWidget )
    mWinTicketWidget:setEnabled( false )
    
    mWinTicketWidget:addTouchEventListener( onWinTicketFrameTouch )
end

function initShareWidget()
    mWinShareWidget = GUIReader:shareReader():widgetFromJsonFile("scenes/SpinShare.json")
    mWidget:addChild( mWinShareWidget )
    mWinShareWidget:setEnabled( false )

    mWinShareWidget:addTouchEventListener( onShareFrameTouch )

    local shareBt = mWinShareWidget:getChildByName("Button_share")
    local cancelBt = mWinShareWidget:getChildByName("Button_cancel")

    shareBt:addTouchEventListener( shareDoShareEventHandler )
    cancelBt:addTouchEventListener( shareCancelEventHandler )
end

function tick( dt )
    local currentRotation = mWheelBG:getRotation()
    local newRotation = currentRotation

    if mWheelState == WHEEL_STATE_START or mWheelState == WHEEL_STATE_STOP then
        -- Do thing.
    elseif mWheelState == WHEEL_STATE_START_BOUNCE then
        if currentRotation < MAX_WHEEL_START_BOUNCE_ROTATION then
            mWheelState = WHEEL_STATE_START_RUNNING
            mWheelCurrentSpeed = 0
        else
            mWheelBG:setRotation( currentRotation + dt * BEGIN_BOUNCE_SPEED )
        end
    elseif mWheelState == WHEEL_STATE_START_RUNNING then
        mWheelCurrentSpeed = mWheelCurrentSpeed + dt * BEGIN_ROTATE_ACCELERATE
        if mWheelCurrentSpeed > MAX_ROTATE_SPEED then
            mWheelCurrentSpeed = MAX_ROTATE_SPEED
        end

        newRotation = currentRotation + dt * mWheelCurrentSpeed
        mWheelBG:setRotation( newRotation )

    elseif mWheelState == WHEEL_STATE_CHECK_STOP_ANGLE then
        local rotationForCompare = currentRotation % 360
        if math.abs( rotationForCompare - mTargetStopAngle) < 5 then
            mWheelBG:setRotation( mTargetStopAngle )
            mWheelState = WHEEL_STATE_STOP_RUNNING
        else
            newRotation = currentRotation + dt * mWheelCurrentSpeed
            mWheelBG:setRotation( newRotation )
        end
    elseif mWheelState == WHEEL_STATE_STOP_RUNNING then
        mWheelCurrentSpeed = mWheelCurrentSpeed + dt * STOP_ROTATE_ACCELERATE
        if mWheelCurrentSpeed < -10 then
            mWheelCurrentSpeed = -10
            mWheelState = WHEEL_STATE_STOP_BOUNCE
        end
        newRotation = currentRotation + dt * mWheelCurrentSpeed
        mWheelBG:setRotation( newRotation )
    elseif mWheelState == WHEEL_STATE_STOP_BOUNCE then
        if currentRotation > MAX_WHEEL_STOP_BOUNCE_ROTATION then
            mWheelState = WHEEL_STATE_STOP
            CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry( mWheelTickHandler )

            local showPrize = function()
                if SpinWheelConfig.isLuckDrawPrizeId( mWinPrizeId ) then
                    -- luck draw.
                    mWinTicketWidget:setEnabled( true )

                    local ticketLeftText = tolua.cast( mWinTicketWidget:getChildByName("Label_ticketLeft"), "Label" )
                    local descriptionText = tolua.cast( mWinTicketWidget:getChildByName("Label_description"), "Label" )
                    ticketLeftText:setText( mWinNumTicketLeft )
                    descriptionText:setText( SpinWheelConfig.getLuckDrawDescription() )
                else
                    -- normal prize.
                    mWinPrizeWidget:setEnabled( true )
                    local prizeText = tolua.cast( mWinPrizeWidget:getChildByName("Label_prize"), "Label" )
                    local prizeImage = tolua.cast( mWinPrizeWidget:getChildByName("Image_prize"), "ImageView" )
                    local prizeConfig = SpinWheelConfig.getPrizeConfigWithID( mWinPrizeId )
                    prizeText:setText( prizeConfig["Name"] )
                    prizeImage:loadTexture( prizeConfig["LocalUrl"] )    
                end
                
            end
            EventManager:scheduledExecutor( showPrize, 0.5 )

            if mSoundEffectHandle then
                AudioEngine.stopEffect( mSoundEffectHandle )
                mSoundEffectHandle = nil
            end
        else
            newRotation = currentRotation + dt * STOP_BOUNCE_SPEED
            mWheelBG:setRotation( newRotation )
        end
    end
    if mSpinnerAnimating == false and math.floor( newRotation / ANGLE_PER_PIECE ) > math.floor( currentRotation / ANGLE_PER_PIECE )  then
        --beginSpinnerAnim()
    end
end

function beginSpinnerAnim()
    local spinner = mWidget:getChildByName("Image_spinner")

    local seqArray = CCArray:create()
    seqArray:addObject( CCCallFunc:create( function()
        mSpinnerAnimating = true
    end ) )
    seqArray:addObject( CCRotateBy:create( 0.05, -40 ) )
    seqArray:addObject( CCRotateBy:create( 0.05, 40 ) )
    seqArray:addObject( CCCallFunc:create( function()
        mSpinnerAnimating = false
    end ) )

    spinner:runAction( CCSequence:create( seqArray ) )
end

function playStartAnim()
    mWheelTickHandler = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc( tick, 0.025, false )
    mWheelState = WHEEL_STATE_START_BOUNCE

    mSoundEffectHandle = AudioEngine.playEffect( AudioEngine.SPIN_WHEEL, true )
end

function stopEventHandler( sender,eventType )
    if eventType == TOUCH_EVENT_ENDED then
        if mWheelState == WHEEL_STATE_START_RUNNING and mWheelCurrentSpeed >= MAX_ROTATE_SPEED and mStopPressed == false then
            mStopPressed = true
            local handler = function( prizeId, numberOfLuckyDrawTicketsLeft )
                mWheelState = WHEEL_STATE_CHECK_STOP_ANGLE
                mTargetStopAngle = ( 360 - SpinWheelConfig.getStopAngleByPrizeID( prizeId ) - STOP_ROTATION_SUM ) % 360
                mWinPrizeId = prizeId
                mWinNumTicketLeft = numberOfLuckyDrawTicketsLeft
            end
            EventManager:postEvent( Event.Do_Spin, { handler } )

        end
    end
end

function winnerEventHandler( sender,eventType )
    if eventType == TOUCH_EVENT_ENDED then
        EventManager:postEvent( Event.Enter_Spin_winner )
    end
end

function balanceEventHandler( sender,eventType )
    if eventType == TOUCH_EVENT_ENDED then
        EventManager:postEvent( Event.Enter_Spin_balance )
    end
end

function onCollectEmailFrameTouch( sender, eventType )
    -- Do nothing, just block.
end

function onWinPrizeFrameTouch( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        local touchHandler = function()
            mWinPrizeWidget:setEnabled( false )
            if mIsBonusSpin then
                leaveSpin()
            else
                checkNCollectEmail()
            end
        end

        if mWinPrizeId == SpinWheelConfig.PRIZE_XIAOMI or mWinPrizeId == SpinWheelConfig.PIRZE_JERSEY then
            local claimText = string.format( Constants.String.spinWheel.claimVirtualPrize, SpinWheelConfig.getPrizeConfigWithID( mWinPrizeId )["Name"] )
            EventManager:postEvent( Event.Show_Info, { claimText, touchHandler } ) 
        else
            touchHandler()
        end
    end
end

function onWinTicketFrameTouch( sender, eventType )
     if eventType == TOUCH_EVENT_ENDED then
        mWinTicketWidget:setEnabled( false )
        if mIsBonusSpin then
            leaveSpin()
        else
            checkNCollectEmail()
        end
    end
end

function onShareFrameTouch( sender, eventType )
    -- Do nothing, just block.
end

function checkNCollectEmail()
    if SpinWheelConfig.getContactEmail() then
        mWinShareWidget:setEnabled( true )
    else
        local collectEmailWidget = GUIReader:shareReader():widgetFromJsonFile("scenes/SpinEmailCollect.json")
        mWidget:addChild( collectEmailWidget )
        collectEmailWidget:addTouchEventListener( onCollectEmailFrameTouch )

        local emailInput = ViewUtils.createTextInput( collectEmailWidget:getChildByName( "emailContainer" ), Constants.String.email )
        emailInput:setFontColor( mInputFontColor )
        emailInput:setPlaceholderFontColor( mInputPlaceholderFontColor )
        emailInput:setTouchPriority( SceneManager.TOUCH_PRIORITY_MINUS_ONE )

        local emailConfirmInput = ViewUtils.createTextInput( collectEmailWidget:getChildByName( "emailContainerConfirm" ), Constants.String.email_confirm )
        emailConfirmInput:setFontColor( mInputFontColor )
        emailConfirmInput:setPlaceholderFontColor( mInputPlaceholderFontColor )
        emailConfirmInput:setTouchPriority( SceneManager.TOUCH_PRIORITY_MINUS_ONE )

        local submitHandler = function( sender, eventType )
            if eventType == TOUCH_EVENT_ENDED then
                local email = emailInput:getText()
                local emailConfirm = emailConfirmInput:getText()

                local emailCollectSuccessCallback = function()
                    collectEmailWidget:removeFromParent()
                    mWinShareWidget:setEnabled( true )
                end

                EventManager:postEvent( Event.Do_Post_Spin_Collect_Email, { email, emailConfirm, emailCollectSuccessCallback } )
            end
        end
        local submitBt = collectEmailWidget:getChildByName("Button_submit")
        submitBt:addTouchEventListener( submitHandler )
    end
end

function shareDoShareEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        local doShare = function()
            local handler = function( accessToken, success )
                ConnectingMessage.selfRemove()
                if success then
                    -- already has permission
                    if accessToken == nil then
                        accessToken = Logic:getFBAccessToken()
                    end
                    EventManager:postEvent( Event.Do_Share_Spin, { accessToken, shareCompleteEventHandler } )
                end
            end
            ConnectingMessage.loadFrame()
            FacebookDelegate:sharedDelegate():grantPublishPermission( "publish_actions", handler )
        end

        if Logic:getFbId() == false then
            local successHandler = function()
                doShare()
            end
            local failedHandler = function()
                -- Nothing to do.
            end
            EventManager:postEvent( Event.Do_FB_Connect_With_User, { successHandler, failedHandler } )
        else
            doShare()
        end
    end
end

function shareCancelEventHandler( sender, eventType )
    mWinShareWidget:setEnabled( false )
    leaveSpin()
end

function shareCompleteEventHandler( success )
    mWinShareWidget:setEnabled( false )
    if success then
        -- Start bonus spin
        mIsBonusSpin = true
        mStopPressed = false
        local normalSpinTitle = tolua.cast( mWidget:getChildByName("Label_normalTitle"), "Label" )
        local bonusSpinTitle = tolua.cast( mWidget:getChildByName("Label_bonusTitle"), "Label" )
        normalSpinTitle:setEnabled( false )
        bonusSpinTitle:setEnabled( true )
        mWheelBG:setRotation( 0 )
        playStartAnim()
    end
end

function leaveSpin()
    local leaveHandler = function()
        EventManager:postEvent( Event.Enter_Community )
    end
    EventManager:postEvent( Event.Show_Info, { Constants.String.spinWheel.leave_message, leaveHandler } ) 
end