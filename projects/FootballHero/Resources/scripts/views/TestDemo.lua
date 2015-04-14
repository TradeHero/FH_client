module(..., package.seeall)

local Constants = require("scripts.Constants")
local SceneManager = require("scripts.SceneManager")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local RateManager = require("scripts.RateManager")
local Navigator = require("scripts.views.Navigator")
local Header = require("scripts.views.HeaderFrame")

local mWidget
local contentHeight

function loadFrame()
	local widget = GUIReader:shareReader():widgetFromJsonFile( "scenes/TestDemo.json" )

    mWidget = widget

    local scrollViewMain = tolua.cast( widget:getChildByName( "ScrollView_Main"), "ScrollView" )
    scrollViewMain:removeAllChildrenWithCleanup( true )
    SceneManager.clearNAddWidget( widget )
    Header.loadFrame( widget, nil, false )
    Navigator.loadFrame( widget )
    Navigator.chooseNav( 2 )

    contentHeight = 0

    local btnAdd = tolua.cast( widget:getChildByName("Button_add"), "Button" )
    btnAdd:addTouchEventListener( eventAddCell )
end

function eventAddCell( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        local eventHandler = function ( sender, eventType )
            if eventType == TOUCH_EVENT_ENDED then
                print( "chenjiang......." )
                EventManager.postEvent( Event.Enter_TestDemo2, nil )
            end
        end
        local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView_Main"), "ScrollView" )
        local content = SceneManager.widgetFromJsonFile( "scenes/TestDemoCell.json" )
        content:addTouchEventListener( eventHandler )
        contentContainer:addChild( content )
        contentHeight = contentHeight + content:getSize().height
        updateContentContainer( contentHeight, content, false )
    end
end

function initContent( cellNumber )
    local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView_Main"), "ScrollView" )
    contentContainer:removeAllChildrenWithCleanup( true )

    local contentHeight = 0
    for i = 1, cellNumber do
        local content = SceneManager.widgetFromJsonFile("scenes/MatchListContent.json")
        contentContainer:addChild( content )
        contentHeight = contentHeight + content:getSize().height
        updateContentContainer ( contentHeight, content, false )
    end
end

function updateContentContainer( contentHeight, addContent, bPopular )
    local contentContainer = tolua.cast( mWidget:getChildByName( "ScrollView_Main" ), "ScrollView" )
    contentContainer:setInnerContainerSize( CCSize:new( 0, contentHeight ) )
    local layout = tolua.cast( contentContainer, "Layout" )
    layout:requestDoLayout()
end

function onFrameTouch( sender, eventType )
    -- Do nothing, just block touch event.
end























