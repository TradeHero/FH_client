module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local Navigator = require("scripts.views.Navigator")
local Constants = require("scripts.Constants")


local mWidget
local mURL

function loadFrame( name, token)
	local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/CompetitionWebview.json")
    mWidget = widget
    mWidget:registerScriptHandler( EnterOrExit )
    SceneManager.clearNAddWidget( widget )
    SceneManager.setKeypadBackListener( keypadBackEventHandler )

    local backBt = widget:getChildByName("back")
    backBt:addTouchEventListener( backEventHandler )
    local title = tolua.cast( widget:getChildByName("title"), "Label" )
    title:setText( name )

    mURL = "http://footballheroapp.com/rules/"..token.."/".."rules.html"
    CCLuaLog( "Rules url is: "..mURL )
    WebviewDelegate:sharedDelegate():openWebpage( mURL, 0, 40, 320, 528 )
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

function backEventHandler( sender,eventType )
    if eventType == TOUCH_EVENT_ENDED then
        keypadBackEventHandler()
    end
end

function keypadBackEventHandler()
    WebviewDelegate:sharedDelegate():closeWebpage()
    EventManager:popHistory()
end