module(..., package.seeall)

local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local Constants = require("scripts.Constants")
local LanguageConfig = require("scripts.config.Languages")
local SideMenuScene = require("scripts.views.SideMenuScene")

function action( param )
	-- Update the UA Tag
	LanguageConfig.updateUALanguageTag()
  LanguageConfig.updateTongdaoLanguage()

	EventManager:postEvent( Event.Check_Start_Tutorial )

	SideMenuScene.loadFrame()
end