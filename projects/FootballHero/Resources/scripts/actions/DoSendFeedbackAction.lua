module(..., package.seeall)

local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList

function action( param )
	Misc:sharedDelegate():sendMail("support@footballheroapp.com", "FootballHero - Support", "", handler )
end

function handler( resultCode )
	if resultCode == -1 then
		EventManager:postEvent( Event.Show_Error_Message, { "You have no email account set up." } )
	end
end