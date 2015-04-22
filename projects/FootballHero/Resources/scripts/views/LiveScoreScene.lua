module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local Constants = require("scripts.Constants")
local Navigator = require("scripts.views.Navigator")
local Header = require("scripts.views.HeaderFrame")

local mWidget

function loadFrame()
    local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/LiveScoreScene.json")
    mWidget = widget
    widget:registerScriptHandler( EnterOrExit )
    SceneManager.clearNAddWidget( widget )
    Header.loadFrame( widget, nil, false )
    Header.showLiveButton( true )
    Navigator.loadFrame( widget )

    initDates( 14 )
end

function initDates( num )
    local scrollWidth = 0
    local dateScroll = tolua.cast( mWidget:getChildByName( "ScrollView" ), "ScrollView" )
    for i = 1, num do
        local cell = SceneManager.widgetFromJsonFile( "scenes/LiveScoreDateCell.json" )
        dateScroll:addChild( cell )
        scrollWidth = scrollWidth + cell:getSize().width
        updateContentContainer( scrollWidth, cell )
    end
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
