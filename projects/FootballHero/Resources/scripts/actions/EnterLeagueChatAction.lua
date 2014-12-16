module(..., package.seeall)

local Json = require("json")
local Constants = require("scripts.Constants")

local mSentOnce = false

function action( param )
	
	local chatType = param[1]
	local channelId = param[2]

	-- Just put an event into the queue to work with EventManager:popHistory().
	if not mSentOnce then
		local params = { Action = chatType }
	    CCLuaLog("Send ANALYTICS_EVENT_LEAGUE: "..Json.encode( params ) )
	    Analytics:sharedDelegate():postEvent( Constants.ANALYTICS_EVENT_LEAGUE, Json.encode( params ) )
	end

    -- Load empty chat scene
    -- Chat message GET logic is within DoGetChatMessageAction.lua
    local ChatScene = require("scripts.views.LeagueChatScene")
    ChatScene.loadFrame( channelId )
end