module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local Navigator = require("scripts.views.Navigator")

local mWidget
local mURL

function loadFrame( name, id, type, index )
	local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/CompetitionPrize.json")
    mWidget = widget
    mWidget:registerScriptHandler( EnterOrExit )
    SceneManager.clearNAddWidget( widget )
    SceneManager.setKeypadBackListener( keypadBackEventHandler )

    Navigator.loadFrame( widget )

    local backBt = widget:getChildByName("back")
    backBt:addTouchEventListener( backEventHandler )
    local title = tolua.cast( widget:getChildByName("title"), "Label" )
    title:setText( name )

    mURL = "http://fhwebsite.cloudapp.net/prize/"..id.."/"..type.."_"..index..".html"
end

function EnterOrExit( eventType )
    if eventType == "enter" then
        CCLuaLog( "Prize url is: "..mURL )
        WebviewDelegate:sharedDelegate():openWebpage( "http://fhwebsite.cloudapp.net/Home/Faq", 0, 40, 320, 528 )
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