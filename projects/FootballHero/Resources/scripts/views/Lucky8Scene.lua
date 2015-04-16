module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local Constants = require("scripts.Constants")
local Navigator = require("scripts.views.Navigator")
local Header = require("scripts.views.Lucky8Header")

local mWidget 
local mScrollViewHeight
local mTabButtons
local mBtnSubmits

local CELL_RES_STRING = 
{
    "scenes/YourPicksCell.json",
    "scenes/Lucky8MatchListCell.json",
    "scenes/Lucky8MatchListCell.json",
}

function loadFrame()
    local widget = GUIReader:shareReader():widgetFromJsonFile( "scenes/lucky8MainScene.json" )
    mWidget = widget
    widget:registerScriptHandler( EnterOrExit )
    SceneManager.clearNAddWidget( widget )
    Header.loadFrame( widget, Constants.String.lucky8.lucky8_title, true )
    Navigator.loadFrame( widget )

    local btnSubmit = tolua.cast( mWidget:getChildByName("Button_Submit"), "Button" )
    mBtnSubmits = btnSubmit
    btnSubmit:addTouchEventListener( eventSubmit )
    local submitTitle = tolua.cast( btnSubmit:getChildByName("TextField_Submit"), "TextField" )
    submitTitle:setText( Constants.String.lucky8.btn_submit_title )

    initButtonInfo()

    mScrollViewHeight = 0;
    initScrollView( 8 ) 
end

function eventSubmit( sender, eventType )
    CCLuaLog( "eventSubmit" )
end

function initScrollView( cellNum )
    local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView_Content"), "ScrollView" )
    for  i = 1, cellNum do
        local matchContent = SceneManager.widgetFromJsonFile( "scenes/Lucky8MatchListCell.json" )
        contentContainer:addChild( matchContent )
        mScrollViewHeight = mScrollViewHeight + matchContent:getSize().height
        updateScrollView( mScrollViewHeight, content )
    end
end

function updateScrollView( scrollViewHeight, content )
    local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView_Content"), "ScrollView" )
    contentContainer:setInnerContainerSize( CCSize:new(0, scrollViewHeight) )
    local layout = tolua.cast( contentContainer, "Layout" )
    layout:requestDoLayout()
end

function getCurrentTime(  )
    local currentTime = os.time()
    -- local currentDate = os.date( "%B %")
end

function changeScrollView( index, cellNum )
    local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView_Content"), "ScrollView" )
    contentContainer:removeAllChildrenWithCleanup( true )
    mScrollViewHeight = 0
    if mBtnSubmits == nil then
        CCLuaLog( "chenjiang,dfdjfkjdskfjsdkfjdskfdsfasdfdsf" )
    else
        CCLuaLog("nnnnnnnnnnnnnnnn")
    end
    if index == 1 or index == 3 then
        mBtnSubmits:setVisible( false )
    else
        mBtnSubmits:setVisible( true )
    end
    for i = 1, cellNum do
        local cell = SceneManager.widgetFromJsonFile( CELL_RES_STRING[index] )
        CCLuaLog( CELL_RES_STRING[i] )
        contentContainer:addChild( cell )
        mScrollViewHeight = mScrollViewHeight + cell:getSize().height
        updateScrollView( mScrollViewHeight, cell )
    end
end

function changeTab( index )
    changeScrollView( index, 8 )
end

function onSelectTab( index )
    for i = 1, table.getn( mTabButtons ) do
        local btnTab = mTabButtons[ i ]
        if i == index then
            btnTab:setBright( false )
            btnTab:setTouchEnabled( false )
            btnTab:setTitleColor( ccc3( 255, 255, 255 ) )
            changeTab( index )
        else
            btnTab:setBright( true )
            btnTab:setTouchEnabled( true )
            btnTab:setTitleColor( ccc3( 127, 127, 127 ) )
        end
    end
end

function bindEventHandler( btnTab, index )
    local eventHandler = function ( sender, eventType )
        if eventType == TOUCH_EVENT_ENDED then
            onSelectTab( index )
        end
    end
    btnTab:addTouchEventListener( eventHandler )
end

function initButtonInfo(  )
    mTabButtons = {}
    local btnPicks = tolua.cast( mWidget:getChildByName( "Button_Picks" ), "Button" )  
    btnPicks:setTitleText( Constants.String.lucky8.btn_picks_title )
    table.insert( mTabButtons, btnPicks )
    bindEventHandler( btnPicks, 1 )

    local btnMatchLists = tolua.cast( mWidget:getChildByName( "Button_MatchLists" ), "Button" )
    table.insert( mTabButtons, btnMatchLists )
    bindEventHandler( btnMatchLists, 2 )
    getCurrentTime()

    local btnRules = tolua.cast( mWidget:getChildByName( "Button_Rules" ), "Button" )
    table.insert( mTabButtons, btnRules )
    btnRules:setTitleText( Constants.String.lucky8.btn_rules_title )
    bindEventHandler( btnRules, 3 )

    onSelectTab( 2 )
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
