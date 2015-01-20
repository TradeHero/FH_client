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
    tolua.cast( mWidget:getChildByName("Label_Title"), "Label" ):setText( Constants.String.spinWheel.balance_title )
    tolua.cast( mWidget:getChildByName("Label_1"), "Label" ):setText( Constants.String.spinWheel.ticket_you_have )
    tolua.cast( mWidget:getChildByName("Label_3"), "Label" ):setText( Constants.String.spinWheel.ticket_usage )
    tolua.cast( mWidget:getChildByName("Label_5"), "Label" ):setText( Constants.String.spinWheel.money_payout_limit )
    tolua.cast( mWidget:getChildByName("Label_disclaimer"), "Label" ):setText( Constants.String.community.disclaimer )
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

    local submitBt = mWidget:getChildByName("Button_submit")
    if moneyBalance > MIN_MONEY_BALANCE_FOR_PAYOUT then
        local submitEventHandler = function( sender, eventType )
            if eventType == TOUCH_EVENT_ENDED then
                EventManager:postEvent( Event.Do_Spin_Payout, { moneyBalance, refresh } )
            end
        end
        
        submitBt:setEnabled( true )
        submitBt:addTouchEventListener( submitEventHandler )
    else
        submitBt:setEnabled( false )
    end
end

function refresh( moneyBalance )
    local moneyText = tolua.cast( mWidget:getChildByName("Label_balance"), "Label" )
    moneyText:setText( string.format( Constants.String.spinWheel.money_balance, moneyBalance ) )

    EventManager:postEvent( Event.Show_Info, { Constants.String.spinWheel.money_payout_success_notification } )
end