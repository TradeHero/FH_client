module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local Constants = require("scripts.Constants")
local Navigator = require("scripts.views.Navigator")
local Header = require("scripts.views.Lucky8Header")

local mWidget
local mWonPrize

function loadFrame()
    local widget = GUIReader:shareReader():widgetFromJsonFile( "scenes/Lucky8HistoryScene.json" )
    mWidget = widget
    widget:registerScriptHandler( EnterOrExit )
    SceneManager.clearNAddWidget( widget )
    Header.loadFrame( widget, Constants.String.lucky8.lucky8_title, true )

    initScrollView( 8 )

    showPrizeScene( true )
end

function showPrizeScene( isShow )
    if isShow == false then 
        return 
    end

    local wonPrice = SceneManager.widgetFromJsonFile( "scenes/Lucky8WonPrice.json" )
    mWonPrize = wonPrice
    mWidget:addChild( wonPrice )

    local btnClaim = tolua.cast( wonPrice:getChildByName("Button_Claim"), "Button" )
    btnClaim:addTouchEventListener( eventClaim )

    local claimText = tolua.cast( btnClaim:getChildByName("TextField_Claim"), "TextField" )
    claimText:setText( Constants.String.lucky8.won_prize_btn_claim )

    local wonText = tolua.cast( wonPrice:getChildByName("TextField_Won"), "TextField" )
    wonText:setText( Constants.String.lucky8.won_prize_won_txt )
end

function eventClaim( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        CCLuaLog( "Lucky8HistoryScene eventClaim" )
        mWonPrize:removeFromParentAndCleanup( true )
    end
end

function initScrollView( cellNum )
    local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView"), "ScrollView" )
    local scrollViewHeight = 0 
    for  i = 1, cellNum do
        local matchContent = SceneManager.widgetFromJsonFile( "scenes/Lucky8HistoryCell.json" )
        contentContainer:addChild( matchContent )
        scrollViewHeight = scrollViewHeight + matchContent:getSize().height
        updateScrollView( scrollViewHeight, content )
    end
end

function updateScrollView( scrollViewHeight, content )
    local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView"), "ScrollView" )
    contentContainer:setInnerContainerSize( CCSize:new(0, scrollViewHeight) )
    local layout = tolua.cast( contentContainer, "Layout" )
    layout:requestDoLayout()
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
