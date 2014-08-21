module(..., package.seeall)

local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local RequestUtils = require("scripts.RequestUtils")
local Logic = require("scripts.Logic").getInstance()

function action( param )
	Logic:clearAccountInfoFile()
	RequestUtils.clearResponseCache()
	EventManager:postEvent( Event.Check_Start_Tutorial )
end