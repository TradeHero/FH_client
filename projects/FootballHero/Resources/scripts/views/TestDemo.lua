module(..., package.seeall)

local Constants = require("scripts.Constants")
local SceneManager = require("scripts.SceneManager")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local RateManager = require("scripts.RateManager")


local mWidget

function loadFrame()
	local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/TestDemo.json")
    SceneManager.clearNAddWidget( widget )
    -- widget
    -- mWidget:registerScriptHandler( EnterOrExit )
    SceneManager.clearNAddWidget( widget )
    
    Header.loadFrame( widget, nil, false )

    Navigator.loadFrame( widget )
    
    if widget == nil then
        CCLuaLog( "scenes/TestDemo.json 加载失败" )
    else
        CCLuaLog( "scenes/TestDemo.json 加载成功" )
    end

    -- CCLuaLog("widget = " .. widget)
end


function onFrameTouch( sender, eventType )
    -- Do nothing, just block touch event.
end