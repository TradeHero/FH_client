module(..., package.seeall)

local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local Constants = require("scripts.Constants")
local LanguageConfig = require("scripts.config.Languages")

function action( param )
	-- Update the UA Tag
	LanguageConfig.updateUALanguageTag()

	EventManager:postEvent( Event.Check_Start_Tutorial )
end