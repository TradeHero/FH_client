module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local Navigator = require("scripts.views.Navigator")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local SettingsConfig = require("scripts.config.Settings")
local Constants = require("scripts.Constants")
local SpinWheelConfig = require("scripts.config.SpinWheel")
local ViewUtils = require("scripts.views.ViewUtils")


local mInputFontColor = ccc3( 255, 255, 255 )
local mInputPlaceholderFontColor = ccc3( 200, 200, 200 )
local MIN_MONEY_BALANCE_FOR_PAYOUT = 0
local mWidget

function loadFrame( moneyBalance, ticketBalance )
	local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/SpinBalance.json")
    mWidget = widget
    mWidget:registerScriptHandler( EnterOrExit )
    SceneManager.clearNAddWidget( widget )
    SceneManager.clearKeypadBackListener()
    SceneManager.setKeypadBackListener( keypadBackEventHandler )

    local backBt = mWidget:getChildByName("Button_Back")
    backBt:addTouchEventListener( backEventHandler )

    Navigator.loadFrame( widget )

    initContent( moneyBalance, ticketBalance )
end

function EnterOrExit( eventType )
    if eventType == "enter" then
    elseif eventType == "exit" then
        mWidget = nil
    end
end

function isFrameShown()
    return mWidget ~= nil
end

function backEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        keypadBackEventHandler()
    end
end

function keypadBackEventHandler()
    EventManager:popHistory()
end

function initContent( moneyBalance, ticketBalance )
    local ticketText = tolua.cast( mWidget:getChildByName("Label_ticket"), "Label" )
    local moneyText = tolua.cast( mWidget:getChildByName("Label_balance"), "Label" )
    local prizeDescriptionText = tolua.cast( mWidget:getChildByName("Label_prizeDescription"), "Label" )

    if ticketBalance > 1 then
        ticketText:setText( string.format( Constants.String.spinWheel.ticket_balance_2, ticketBalance ) )
    else
        ticketText:setText( string.format( Constants.String.spinWheel.ticket_balance_1, ticketBalance ) )
    end
    
    moneyText:setText( string.format( Constants.String.spinWheel.money_balance, moneyBalance ) )

    prizeDescriptionText:setText( SpinWheelConfig.getLuckDrawDescription() )

    local payoutPanel = mWidget:getChildByName("Panel_payout")
    if moneyBalance > MIN_MONEY_BALANCE_FOR_PAYOUT then
        payoutPanel:setEnabled( true )
        local emailInput = ViewUtils.createTextInput( payoutPanel:getChildByName( "emailContainer" ), Constants.String.email )
        emailInput:setFontColor( mInputFontColor )
        emailInput:setPlaceholderFontColor( mInputPlaceholderFontColor )
        emailInput:setTouchPriority( SceneManager.TOUCH_PRIORITY_MINUS_ONE )

        local emailInputConfirm = ViewUtils.createTextInput( payoutPanel:getChildByName( "emailContainerConfirm" ), Constants.String.email_confirm )
        emailInputConfirm:setFontColor( mInputFontColor )
        emailInputConfirm:setPlaceholderFontColor( mInputPlaceholderFontColor )
        emailInputConfirm:setTouchPriority( SceneManager.TOUCH_PRIORITY_MINUS_ONE )

        local submitEventHandler = function( sender, eventType )
            if eventType == TOUCH_EVENT_ENDED then
                local email = emailInput:getText()
                local emailConfirm = emailInputConfirm:getText()

                EventManager:postEvent( Event.Do_Spin_Payout, { email, emailConfirm, moneyBalance, refresh } )
            end
        end

        local submitBt = payoutPanel:getChildByName("Button_submit")
        submitBt:addTouchEventListener( submitEventHandler )
    end
end

function refresh( moneyBalance )
    local moneyText = tolua.cast( mWidget:getChildByName("Label_balance"), "Label" )
    moneyText:setText( string.format( Constants.String.spinWheel.money_balance, moneyBalance ) )

    EventManager:postEvent( Event.Show_Info, { Constants.String.spinWheel.money_payout_success_notification } )
end