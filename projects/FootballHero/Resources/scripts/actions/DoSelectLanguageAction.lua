module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local Json = require("json")
local Constants = require("scripts.Constants")
local LanguagesConfig = require("scripts.config.Languages")

function action( param )
	SceneManager.clear()

	local appLanguage = param[1]
	CCLuaLog("appLanguage = "..appLanguage)

	local languageConfig = LanguagesConfig.getLanguageConfigById( appLanguage )
	Constants.setLanguage( languageConfig["LocalizedStringFile"] )



	-- Reload the settings page.
	local reloadHandler
	local reloadFunc = function()
		CCTextureCache:sharedTextureCache():removeAllTextures()
		CCFileUtils:sharedFileUtils():purgeCachedEntries()
		CCFileUtils:sharedFileUtils():setSearchPathToLocale( languageConfig["key"] )

		local SettingsScene = require("scripts.views.SettingsScene")
		if SettingsScene.isFrameShown() then
			return
		end
	    SettingsScene.loadFrame()
	    if reloadHandler then
	    	CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry( reloadHandler )
		end
	end
	reloadHandler = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc( reloadFunc, 2, false )
	
end