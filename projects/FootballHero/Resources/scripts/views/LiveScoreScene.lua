module(..., package.seeall)

require "Cocos2d"
local SceneManager = require("scripts.SceneManager")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local Constants = require("scripts.Constants")
local Navigator = require("scripts.views.Navigator")
local Header = require("scripts.views.HeaderFrame")

local mWidget
local mDate

function loadFrame()
    local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/LiveScoreScene.json")
    mWidget = widget
    widget:registerScriptHandler( EnterOrExit )
    SceneManager.clearNAddWidget( widget )
    Header.loadFrame( widget, nil, false )
    Header.showLiveButton( true )
    Navigator.loadFrame( widget )

    initDates( 14 )

    initMatchList( 14 )

    -- local arrDate = CCArray:create()
    -- mDate = arrDate:retain()
end

function eventSelectDate( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        -- for i = 1, mDate:count() do
            -- local cell = mDate:objectAtIndex( i )
            -- if cell == sender then
                CCLuaLog( "cell == sender" )
                sender:setBright( false )
                sender:setTouchEnabled( false )
            -- else
            --     CCLuaLog( "cell ~= sender" )
            --     sender:setBright( true )
            --     sender:setTouchEnabled( true )
            -- end
        -- end
    end
end

function initDates( num )
    local scrollWidth = 0
    local dateScroll = tolua.cast( mWidget:getChildByName( "ScrollView" ), "ScrollView" )
    for i = 1, num do
        local cell = SceneManager.widgetFromJsonFile( "scenes/LiveScoreDateCell.json" )
        local btnSelectDate = tolua.cast( cell:getChildByName("Button_Date"), "Button" )
        btnSelectDate:addTouchEventListener( eventSelectDate )
        dateScroll:addChild( cell )
        scrollWidth = scrollWidth + cell:getSize().width
        updateContentContainer( scrollWidth, cell )
        -- mDate:addObject( cell )
    end
end

function getLeagueCell( )
    local cell = CCSprite:create()
    local cellHeight = 0
    local liveScoreCell = SceneManager.widgetFromJsonFile( "scenes/LiveScoreCell.json" )
    cell:addChild( liveScoreCell )
    cellHeight = cellHeight + liveScoreCell:getSize().height

    local subCells = {}
    for i = 1, 5 do
        local subCell = SceneManager.widgetFromJsonFile( "scenes/LiveScoreMatchCell.json" )
        cell:addChild( subCell )
        table.insert( subCells, subCell )
        cellHeight = cellHeight + subCell:getSize().height
    end

    cell:setContentSize( CCSize:new(640, cellHeight) )

    local x = cell:getContentSize().width / 2.0
    local y = cell:getContentSize().height
    liveScoreCell:setAnchorPoint( CCPoint:new(0.5, 1) )
    liveScoreCell:setPosition( CCPoint(x, y) )

    for i = 1, #subCells do
        -- local 
    end

    return cell
end

function initMatchList( num )
    local matchListContent = tolua.cast( mWidget:getChildByName("ScrollView_LiveScore"), "ScrollView" )
    local height = 0
    for i = 1, num do
        local cell = SceneManager.widgetFromJsonFile( "scenes/LiveScoreCell.json" )
        matchListContent:addChild( cell )
        height = height + cell:getSize().height
        updateContentContainerHeight( height, matchListContent )
    end
end

function updateContentContainerHeight( height, content )
    local content = tolua.cast( mWidget:getChildByName("ScrollView_LiveScore"), "ScrollView" )
    content:setInnerContainerSize( CCSize:new(0, height))
    local layout = tolua.cast( content , "Layout" )
    layout:requestDoLayout()
end

function updateContentContainer( width, content )
    local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView"), "ScrollView" )
    contentContainer:setInnerContainerSize( CCSize:new(width, 0) )
    local layout = tolua.cast( contentContainer, "Layout" )
    layout:requestDoLayout()
end

-- function enterGame( index )
--     EventManager:postEvent( ENTER_GAME_EVENT_LIST[index][1], ENTER_GAME_EVENT_LIST[index][2] )
-- end

function EnterOrExit( eventType )
    if eventType == "enter" then
        elseif eventType == "exit" then
        mWidget = nil
    end
end

function isFrameShown()
    return mWidget ~= nil
end
