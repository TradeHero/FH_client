module(..., package.seeall)

local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local Constants = require("scripts.Constants")

function action( param )
	Misc:sharedDelegate():sendMail( Constants.String.support_email, Constants.String.support_title, "", handler )
end

function handler( resultCode )
	if resultCode == -1 then
		EventManager:postEvent( Event.Show_Error_Message, { Constants.String.error.no_email } )
	end
end