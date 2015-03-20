module(..., package.seeall)

require "extern"

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
local Header = require("scripts.views.HeaderFrame")
local ShareConfig = require("scripts.config.Share")


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
local mRemainingTime

function loadFrame()
	local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/SpinWheel.json")
    mWidget = widget

    -- Set the text
    tolua.cast( mWidget:getChildByName("Label_6"), "Label" ):setText( Constants.String.spinWheel.wheel_sub_title )
    tolua.cast( mWidget:getChildByName("Label_bonusTitle"), "Label" ):setText( Constants.String.spinWheel.spin_bonus )
    tolua.cast( mWidget:getChildByName("Label_normalTitle"), "Label" ):setText( Constants.String.spinWheel.spin_daily )
    tolua.cast( mWidget:getChildByName("Label_timeTitle"), "Label" ):setText( Constants.String.spinWheel.come_back_in )

    widget:registerScriptHandler( EnterOrExit )
    SceneManager.clearNAddWidget( widget )
    
    Header.loadFrame( mWidget, Constants.String.spinWheel.wheel_title, false )

    mWheelBG = tolua.cast( mWidget:getChildByName("wheelBG"), "ImageView" )
    
    local stopBt = mWidget:getChildByName("Button_stop")
    local winnerBt = mWidget:getChildByName("Button_winner")
    local balanceBt = mWidget:getChildByName("Button_balance")
    local normalSpinTitle = tolua.cast( mWidget:getChildByName("Label_normalTitle"), "Label" )
    local bonusSpinTitle = tolua.cast( mWidget:getChildByName("Label_bonusTitle"), "Label" )

    local btnPopup = tolua.cast( mWidget:getChildByName("CheckBox_Info"), "CheckBox" )

    local popupInfo = tolua.cast( mWidget:getChildByName("Image_Info"), "ImageView" )
    local headerPopup = tolua.cast( popupInfo:getChildByName("Image_Header"), "ImageView" )
    local titlePopup = tolua.cast( headerPopup:getChildByName("Label_Header"), "Label" )
    local popupText = tolua.cast( popupInfo:getChildByName("Label_Info"), "Label" )
    titlePopup:setText( Constants.String.spinWheel.wheel_title )
    popupText:setText( Constants.String.spinWheel.win_prizes )
    popupInfo:setEnabled( false )
    -- not working
    --popupInfo:setCascadeOpacityEnabled( true )
    
    local popupEventHandler = function( sender, eventType )
        if eventType == TOUCH_EVENT_ENDED then
            togglePopup( btnPopup:getSelectedState(), popupInfo )
        end
    end
    btnPopup:addTouchEventListener( popupEventHandler )

    
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

    mRemainingTime = SpinWheelConfig.getNextSpinTime() - os.time()
    local labelTime = tolua.cast( mWidget:getChildByName("Label_Time"), "Label" )
    local labelTimeTitle = tolua.cast( mWidget:getChildByName("Label_timeTitle"), "Label" )

    if mRemainingTime <= 0 then
        mWheelState = WHEEL_STATE_START
        playStartAnim()
        labelTime:setEnabled( false )
        labelTimeTitle:setEnabled( false )
    else
        labelTime:setEnabled( true )
        labelTimeTitle:setEnabled( true )
        labelTime:setText( os.date( "!%X", mRemainingTime ) )
        performWithDelay( mWidget, updateTimer, 1 )
    end
    

    mIsBonusSpin = false
    mSpinnerAnimating = false
    mStopPressed = false
end

function togglePopup( isSelected, popup )
    if isSelected then
        -- remove popup
       popup:setEnabled( false )
    else
        -- show popup
       popup:setEnabled( true )
       --mWidget:runAction( CCTargetedAction:create( popupHandicap, CCFadeIn:create( 5.0 ) ) )
   end
end


function updateTimer()
    mRemainingTime = mRemainingTime - 1
    local labelTime = tolua.cast( mWidget:getChildByName("Label_Time"), "Label" )
    local labelTimeTitle = tolua.cast( mWidget:getChildByName("Label_timeTitle"), "Label" )
    if mRemainingTime < 0 then    
        mWheelState = WHEEL_STATE_START
        playStartAnim()
        labelTime:setEnabled( false )
        labelTimeTitle:setEnabled( false )
    else
        labelTime:setText( os.date( "!%X", mRemainingTime ) )
        performWithDelay( mWidget, updateTimer, 1 )
    end
end

function EnterOrExit( eventType )
    if eventType == "enter" then
    elseif eventType == "exit" then
        if mSoundEffectHandle then
            AudioEngine.stopEffect( mSoundEffectHandle )
            mSoundEffectHandle = nil
        end
        if mWheelTickHandler then
            CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry( mWheelTickHandler )
            mWheelTickHandler = nil
        end
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

    -- Set the text
    tolua.cast( mWinPrizeWidget:getChildByName("Label_won"), "Label" ):setText( Constants.String.spinWheel.won )
    local claimPanel = mWinPrizeWidget:getChildByName("Panel_claimPrize")
    tolua.cast( claimPanel:getChildByName("Label_please"), "Label" ):setText( Constants.String.spinWheel.please_contact )
    tolua.cast( claimPanel:getChildByName("Label_claim"), "Label" ):setText( Constants.String.spinWheel.to_claim_prize )

    mWidget:addChild( mWinPrizeWidget )
    mWinPrizeWidget:setEnabled( false )
    
    mWinPrizeWidget:addTouchEventListener( onWinPrizeFrameTouch )
end

function initWinTicketWidget()
    mWinTicketWidget = GUIReader:shareReader():widgetFromJsonFile("scenes/SpinWinTicket.json")

    -- Set the text
    tolua.cast( mWinTicketWidget:getChildByName("Label_won"), "Label" ):setText( Constants.String.spinWheel.won )
    tolua.cast( mWinTicketWidget:getChildByName("Label_prize"), "Label" ):setText( Constants.String.spinWheel.win_ticket_prize )
    tolua.cast( mWinTicketWidget:getChildByName("Label_left"), "Label" ):setText( Constants.String.spinWheel.win_ticket_left )

    mWidget:addChild( mWinTicketWidget )
    mWinTicketWidget:setEnabled( false )
    
    mWinTicketWidget:addTouchEventListener( onWinTicketFrameTouch )
end

function initShareWidget()
    mWinShareWidget = GUIReader:shareReader():widgetFromJsonFile("scenes/SpinShare.json")

    -- Set the text.
    tolua.cast( mWinShareWidget:getChildByName("Label_prize"), "Label" ):setText( Constants.String.spinWheel.share_description )

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
                local prizeConfig = SpinWheelConfig.getPrizeConfigWithID( mWinPrizeId )
                if prizeConfig["DrawTicket"] then
                    -- luck draw.
                    mWinTicketWidget:setEnabled( true )

                    local ticketLeftText = tolua.cast( mWinTicketWidget:getChildByName("Label_ticketLeft"), "Label" )
                    local descriptionText = tolua.cast( mWinTicketWidget:getChildByName("Label_description"), "Label" )
                    ticketLeftText:setText( mWinNumTicketLeft )
                    descriptionText:setText( prizeConfig["DrawInformation"] )
                else
                    -- normal prize.
                    mWinPrizeWidget:setEnabled( true )
                    local claimPanel = mWinPrizeWidget:getChildByName("Panel_claimPrize")
                    if SpinWheelConfig.isShowContactInfo(mWinPrizeId) then
                        claimPanel:setEnabled( true )
                    else
                        claimPanel:setEnabled( false )
                    end
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
            AudioEngine.playEffect( AudioEngine.SETTINGS_ON_OFF )
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
        mWinPrizeWidget:setEnabled( false )

        if SpinWheelConfig.isShowContactInfo( mWinPrizeId ) then
            function handler( resultCode )
                -- Do nothing
            end
            Misc:sharedDelegate():sendMail( Constants.String.support_email, Constants.String.support_title, "", handler )
        end

        if mIsBonusSpin then
            leaveSpin()
        else
            checkNCollectEmail()
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
        Header.loadFrame( collectEmailWidget, Constants.String.spinWheel.collect_email_label_title, true )
        -- Set the text.
        --tolua.cast( collectEmailWidget:getChildByName("Label_Title"), "Label" ):setText( Constants.String.spinWheel.collect_email_label_title )
        tolua.cast( collectEmailWidget:getChildByName("Label_1"), "Label" ):setText( Constants.String.spinWheel.collect_email_you_won )
        tolua.cast( collectEmailWidget:getChildByName("Label_ticket"), "Label" ):setText( SpinWheelConfig.getPrizeConfigWithID( mWinPrizeId )["Name"] )
        tolua.cast( collectEmailWidget:getChildByName("Label_3"), "Label" ):setText( Constants.String.spinWheel.collect_email_towards_wallet )
        tolua.cast( collectEmailWidget:getChildByName("Label_min"), "Label" ):setText( Constants.String.spinWheel.collect_email_min )
        tolua.cast( collectEmailWidget:getChildByName("Label_prizeDescription"), "Label" ):setText( Constants.String.spinWheel.collect_email_description )
        tolua.cast( collectEmailWidget:getChildByName("Label_disclaimer"), "Label" ):setText( Constants.String.community.disclaimer )

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
        local callback = function( success, platType )
            if success then
                EventManager:postEvent( Event.Do_Share_Spin, { "", shareCompleteEventHandler } )
            end
        end

        EventManager:postEvent( Event.Enter_Share, { ShareConfig.SHARE_SPINTHEWHEEL, callback } )
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