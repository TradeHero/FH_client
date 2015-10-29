module(..., package.seeall)

local Json = require("json")
local Constants = require("scripts.Constants")

local mSentOnce = false

function action( param )
	
	local channelId = param[1]

	-- Just put an event into the queue to work with EventManager:popHistory().
	if not mSentOnce then
		local params = { Action = "chat"}
	    CCLuaLog("Send ANALYTICS_EVENT_COMPETITION: "..Json.encode( params ) )
	    Analytics:sharedDelegate():postEvent( Constants.ANALYTICS_EVENT_COMPETITION, Json.encode( params ) )
	    Analytics:sharedDelegate():postFlurryEvent( Constants.ANALYTICS_EVENT_COMPETITION, Json.encode( params ) )
	end

    -- Load empty chat scene
    -- Chat message GET logic is within DoGetChatMessageAction.lua
    local ChatScene = require("scripts.views.CompetitionChatScene")
    ChatScene.loadFrame( channelId )
end