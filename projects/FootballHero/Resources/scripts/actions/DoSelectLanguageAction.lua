module(..., package.seeall)

local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local Json = require("json")
local Constants = require("scripts.Constants")
local LanguagesConfig = require("scripts.config.Languages")

function action( param )
	local appLanguage = param[1]
	CCLuaLog("appLanguage = "..appLanguage)

	local languageConfig = LanguagesConfig.getLanguageConfigById( appLanguage )
	Constants.setLanguage( languageConfig["LocalizedStringFile"] )
end