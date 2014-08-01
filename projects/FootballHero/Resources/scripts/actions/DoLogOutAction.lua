module(..., package.seeall)

local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local RequestUtils = require("scripts.RequestUtils")

function action( param )
	RequestUtils.clearResponseCache()
	EventManager:postEvent( Event.Check_Start_Tutorial )
end