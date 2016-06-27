module(..., package.seeall)

local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local Json = require("json")
local Constants = require("scripts.Constants")

function action( param )
	local body = param[1]
	local title = param[2]
	Misc:sharedDelegate():sendMail("", title, body, handler )
end

function handler( resultCode )
	if resultCode == -1 then
		EventManager:postEvent( Event.Show_Error_Message, { Constants.String.error.no_email } )
	else
		local params = { Platform = "email", 
	                    Content = "competition code", 
	                    Action = "share", 
	                    Location = "competition share button" }
	    CCLuaLog("Send ANALYTICS_EVENT_SOCIAL_ACTION: "..Json.encode( params ) )
	    Analytics:sharedDelegate():postEvent( Constants.ANALYTICS_EVENT_SOCIAL_ACTION, Json.encode( params ) )
	    Analytics:sharedDelegate():postFlurryEvent( Constants.ANALYTICS_EVENT_SOCIAL_ACTION, Json.encode( params ) )
	    Analytics:sharedDelegate():postTongdaoEvent( Constants.ANALYTICS_EVENT_SOCIAL_ACTION, Json.encode( params ) )
	end
end