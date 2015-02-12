module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local Constants = require("scripts.Constants")
local Header = require("scripts.views.HeaderFrame")

local mWidget

function loadFrame()
	local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/EmptyTemplate.json")
    mWidget = widget
    mWidget:registerScriptHandler( EnterOrExit )
    SceneManager.clearNAddWidget( widget )
    
    Header.loadFrame( widget, Constants.String.settings.faq, true )
end

function EnterOrExit( eventType )
    if eventType == "enter" then
        WebviewDelegate:sharedDelegate():openWebpage( "http://footballheroapp.com/faq.html", 0, 40, 320, 528 )
    elseif eventType == "exit" then
        mWidget = nil
    end
end

function isFrameShown()
    return mWidget ~= nil
end
