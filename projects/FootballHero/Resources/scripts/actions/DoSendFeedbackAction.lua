module(..., package.seeall)

local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList

function action( param )
	Misc:sharedDelegate():sendMail("support@footballheroapp.com", "FootballHero - Support", "", errorHandler )
end

function errorHandler()
	EventManager:postEvent( Event.Show_Error_Message, { "You have no email account set up." } )
end