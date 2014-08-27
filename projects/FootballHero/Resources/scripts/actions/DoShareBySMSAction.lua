module(..., package.seeall)

local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local Json = require("json")
local Constants = require("scripts.Constants")

function action( param )
	local body = param[1]
	Misc:sharedDelegate():sendSMS( body, handler )
end

function handler( resultCode )
	if resultCode == -1 then
		EventManager:postEvent( Event.Show_Error_Message, { "You have no SMS set up." } )
	elseif resultCode == 1 then
		local params = { Platform = "sms", 
	                    Content = "competition code", 
	                    Action = "share", 
	                    Location = "competition share button" }
	    CCLuaLog("Send ANALYTICS_EVENT_SOCIAL_ACTION: "..Json.encode( params ) )
	    Analytics:sharedDelegate():postEvent( Constants.ANALYTICS_EVENT_SOCIAL_ACTION, Json.encode( params ) )
	end
end