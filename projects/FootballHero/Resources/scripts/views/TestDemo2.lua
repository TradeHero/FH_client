module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList

function loadFrame(  )
	local widget = GUIReader:shareReader():widgetFromJsonFile( "scenes/TestDemo2.json" )
	SceneManager.clearNAddWidget( widget )
	
end