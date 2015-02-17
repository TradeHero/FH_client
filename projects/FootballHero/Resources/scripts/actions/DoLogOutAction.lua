module(..., package.seeall)

local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local RequestUtils = require("scripts.RequestUtils")
local Logic = require("scripts.Logic").getInstance()
local QuickBloxService = require("scripts.QuickBloxService")


function action( param )
	Logic:clearAccountInfoFile()
	RequestUtils.clearResponseCache()
	QuickBloxService.logout()
	EventManager:postEvent( Event.Check_Start_Tutorial )
end