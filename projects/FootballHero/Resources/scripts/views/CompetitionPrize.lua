module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local Navigator = require("scripts.views.Navigator")
local Constants = require("scripts.Constants")
local Header = require("scripts.views.HeaderFrame")

local mWidget
local mURL

function loadFrame( name, token, type, index )
	local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/EmptyTemplate.json")
    mWidget = widget
    mWidget:registerScriptHandler( EnterOrExit )
    SceneManager.clearNAddWidget( widget )
    
    Header.loadFrame( mWidget, name, true, true )

    mURL = "http://footballheroapp.com/prize/"..token.."/"..type
    if type ~= Constants.COMPETITION_PRIZE_OVERALL then
        mURL = mURL.."_"..index
    end
    mURL = mURL..".html"
    CCLuaLog( "Prize url is: "..mURL )
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
