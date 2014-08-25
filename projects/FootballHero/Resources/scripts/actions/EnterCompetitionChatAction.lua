module(..., package.seeall)

local Json = require("json")
local Constants = require("scripts.Constants")

local mSentOnce = false

function action( param )
	-- Do nothing. 
	-- Just put an event into the queue to work with EventManager:popHistory().
	-- Acutally logic is within DoGetChatMessageAction.lua

	if not mSentOnce then
		local params = { Action = "chat"}
	    CCLuaLog("Send ANALYTICS_EVENT_COMPETITION: "..Json.encode( params ) )
	    Analytics:sharedDelegate():postEvent( Constants.ANALYTICS_EVENT_COMPETITION, Json.encode( params ) )
	end
end