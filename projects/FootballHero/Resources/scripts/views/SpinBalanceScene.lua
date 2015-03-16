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
local MIN_MONEY_BALANCE_FOR_PAYOUT = 25
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
    tolua.cast( mWidget:getChildByName("Label_5"), "Label" ):setText( Constants.String.spinWheel.money_payout_limit )
    tolua.cast( mWidget:getChildByName("Label_disclaimer"), "Label" ):setText( Constants.String.community.disclaimer )

    for i = 1, 2 do
        local info = ticketBalance[i]
        local ticketNum = info["NumberOfLuckyDrawTickets"]
        local prizeConfig = SpinWheelConfig.getPrizeConfigWithID( info["PrizeId"] )

        -- Usage label
        tolua.cast( mWidget:getChildByName("Label_usage"..i), "Label" ):setText( Constants.String.spinWheel.ticket_usage )
        
        -- Prize Image
        local image = tolua.cast( mWidget:getChildByName("Image_prize"..i), "ImageView" )
        image:loadTexture( prizeConfig["LocalUrl"] )

        -- Ticket Label
        local ticketText = tolua.cast( mWidget:getChildByName("Label_ticket"..i), "Label" )
        if ticketNum > 1 then
            ticketText:setText( string.format( Constants.String.spinWheel.ticket_balance_2, ticketNum ) )
        else
            ticketText:setText( string.format( Constants.String.spinWheel.ticket_balance_1, ticketNum ) )
        end

        -- Description label
        local prizeDescriptionText = tolua.cast( mWidget:getChildByName("Label_prizeDescription"..i), "Label" )
        prizeDescriptionText:setText( prizeConfig["DrawInformation"] )
    end
    
    local moneyText = tolua.cast( mWidget:getChildByName("Label_balance"), "Label" )
    moneyText:setText( string.format( Constants.String.spinWheel.money_balance, moneyBalance ) )

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