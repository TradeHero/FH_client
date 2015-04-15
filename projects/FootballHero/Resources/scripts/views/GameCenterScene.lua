module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local Constants = require("scripts.Constants")
local Navigator = require("scripts.views.Navigator")
local Header = require("scripts.views.HeaderFrame")

local mWidget
local mContentHeight

local ENTER_GAME_EVENT_LIST = {
    { Event.Enter_Spin_the_Wheel, nil },
    { Event.Enter_Lucky8, nil },
}

function loadFrame()
    local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/GameCenterScene.json")
    mWidget = widget
    widget:registerScriptHandler( EnterOrExit )
    SceneManager.clearNAddWidget( widget )
    Header.loadFrame( widget, nil, false )
    Navigator.loadFrame( widget )
    initCells( table.getn( ENTER_GAME_EVENT_LIST ) )
end

function initCells( cellNum )
    mContentHeight = 0
    local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView"), "ScrollView" )
    for i = 1, cellNum do
        local eventHandler = function ( sender, eventType )
            print( "chenjiang" )
            if eventType == TOUCH_EVENT_ENDED then
                enterGame( i )
            end
        end
        local content = SceneManager.widgetFromJsonFile( "scenes/GameCenterCell.json")
        contentContainer:addChild( content )
        mContentHeight = mContentHeight + content:getSize().height
        content:addTouchEventListener( eventHandler )
        updateContentContainer( mContentHeight, content )
    end
end

function updateContentContainer( contentHeight, content )
    local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView"), "ScrollView" )
    contentContainer:setInnerContainerSize( CCSize:new(0, contentHeight) )
    local layout = tolua.cast( contentContainer, "Layout" )
    layout:requestDoLayout()
end

function enterGame( index )
    EventManager:postEvent( ENTER_GAME_EVENT_LIST[index][1], ENTER_GAME_EVENT_LIST[index][2] )
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
