module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local Navigator = require("scripts.views.Navigator")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local SettingsConfig = require("scripts.config.Settings")

local mWidget


function loadFrame()
	local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/SettingsHome.json")
    mWidget = widget
    mWidget:registerScriptHandler( EnterOrExit )
    SceneManager.clearNAddWidget( widget )
    SceneManager.clearKeypadBackListener()

    Navigator.loadFrame( widget )

    initContent()
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

function initContent()
	local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView"), "ScrollView" )
    contentContainer:removeAllChildrenWithCleanup( true )

    local layoutParameter = LinearLayoutParameter:create()
    layoutParameter:setGravity(LINEAR_GRAVITY_CENTER_VERTICAL)
    local contentHeight = 0

    for i = 1, table.getn( SettingsConfig.SettingsItem ) do
    	local eventHandler = function( sender, eventType )
            if eventType == TOUCH_EVENT_ENDED then
                EventManager:postEvent( SettingsConfig.SettingsItem[i]["event"] )
            end
        end

        local content = SceneManager.widgetFromJsonFile("scenes/SettingsHomeContent.json")
        content:setLayoutParameter( layoutParameter )
        contentContainer:addChild( content )
        contentHeight = contentHeight + content:getSize().height
        content:addTouchEventListener( eventHandler )
        initSettingsItemContent( content, SettingsConfig.SettingsItem[i] )
    end

    contentContainer:setInnerContainerSize( CCSize:new( 0, contentHeight ) )
    local layout = tolua.cast( contentContainer, "Layout" )
    layout:requestDoLayout()
end

function initSettingsItemContent( content, info )
    local name = tolua.cast( content:getChildByName("name"), "Label" )

    name:setText( info["itemName"] )
end