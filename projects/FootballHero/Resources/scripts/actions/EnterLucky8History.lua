module(..., package.seeall)

local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local Logic = require("scripts.Logic")

function action( param )
	local lucky8HistoryScene = require( "scripts.views.Lucky8HistoryScene" )
	lucky8HistoryScene.loadFrame()
end