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

function loadFrame( moneyBalance, ticketBalance, luckyDrawEmail )
	local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/SpinBalance.json")
    mWidget = widget
    mWidget:registerScriptHandler( EnterOrExit )
    SceneManager.clearNAddWidget( widget )
    SceneManager.clearKeypadBackListener()
    SceneManager.setKeypadBackListener( keypadBackEventHandler )

    local backBt = mWidget:getChildByName("Panel_Title"):getChildByName("Button_Back")
    backBt:addTouchEventListener( backEventHandler )

    Navigator.loadFrame( widget )

    initContent( moneyBalance, ticketBalance, luckyDrawEmail )
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

function initContent( moneyBalance, ticketBalance, luckyDrawEmail )
    tolua.cast( mWidget:getChildByName("Panel_Title"):getChildByName("Label_Title"), "Label" ):setText( Constants.String.spinWheel.balance_title )
 
    -- Prize Panel
    local container = mWidget:getChildByName("Panel_Prize")

    for i = 1, 2 do
        local info = ticketBalance[i]
        local ticketNum = info["NumberOfLuckyDrawTickets"]
        local prizeConfig = SpinWheelConfig.getPrizeConfigWithID( info["PrizeId"] )

        local labelTicket = tolua.cast( container:getChildByName("Label_Ticket"..i), "Label" )

        if ticketNum > 1 then
            labelTicket:setText( string.format( Constants.String.spinWheel.ticket_balance_2, ticketNum ) )
        else
            labelTicket:setText( string.format( Constants.String.spinWheel.ticket_balance_1, ticketNum ) )
        end
    end
    
    local labelCash = tolua.cast( container:getChildByName("Label_Money"), "Label" )
    labelCash:setText( string.format( Constants.String.spinWheel.money_balance, moneyBalance ) )

    -- Payment Panel
    container = mWidget:getChildByName("Panel_Payment")
    local panelTitle= mWidget:getChildByName("Panel_PayTitle")
    if moneyBalance >= MIN_MONEY_BALANCE_FOR_PAYOUT then
        emailInput = ViewUtils.createTextInput( container:getChildByName( "Input_Email" ), Constants.String.email )
        emailConfirmInput = ViewUtils.createTextInput( container:getChildByName( "Input_Confirm" ), Constants.String.email_confirm )
        emailInput:setFontColor( mInputFontColor )
        emailConfirmInput:setFontColor( mInputFontColor )

        emailInput:setPlaceholderFontColor( mInputPlaceholderFontColor )
        emailConfirmInput:setPlaceholderFontColor( mInputPlaceholderFontColor )
     
        emailInput:setTouchPriority( SceneManager.TOUCH_PRIORITY_ZERO )
        emailConfirmInput:setTouchPriority( SceneManager.TOUCH_PRIORITY_ZERO )

        luckyDrawEmail = "spiritrain@gmail.com"
        if type(luckyDrawEmail) ~= "userdata" and luckyDrawEmail ~= "" then
            emailInput:setText(luckyDrawEmail)
            emailConfirmInput:setText(luckyDrawEmail)
        end

        local btnSubmit = container:getChildByName("Button_Submit")
        local submitEventHandler = function( sender, eventType )
            if eventType == TOUCH_EVENT_ENDED then
                local email = emailInput:getText()
                local emailConfirm = emailConfirmInput:getText()

                local emailCollectSuccessCallback = function()
                    EventManager:postEvent( Event.Do_Spin_Payout, { moneyBalance, refresh } )
                end
                EventManager:postEvent( Event.Do_Post_Spin_Collect_Email, { email, emailConfirm, emailCollectSuccessCallback } )
            end
        end
        
        container:setEnabled( true )
        panelTitle:setEnabled( true )
       
        btnSubmit:addTouchEventListener( submitEventHandler )
    else
        container:setEnabled( false )
        panelTitle:setEnabled( false )
    end
end



function refresh( moneyBalance )
    local labelCash = tolua.cast( mWidget:getChildByName("Panel_Prize"):getChildByName("Label_Money"), "Label" )
    labelCash:setText( string.format( Constants.String.spinWheel.money_balance, moneyBalance ) )
    mWidget:getChildByName("Panel_PayTitle"):setEnabled( false )
    mWidget:getChildByName("Panel_Payment"):setEnabled( false )
    emailInput:setEnabled(false)
    emailConfirmInput:setEnabled(false)


    EventManager:postEvent( Event.Show_Info, { Constants.String.spinWheel.money_payout_success_notification } )
end