module(..., package.seeall)

local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList

local Json = require("json")

KEY_OF_LANGUAGE = "app-language"
local LANGUAGE_NAME = {}
table.insert( LANGUAGE_NAME, "lang_English" )			-- 0
table.insert( LANGUAGE_NAME, "lang_Chinese" )			-- 1
table.insert( LANGUAGE_NAME, "lang_French" )			-- 2
table.insert( LANGUAGE_NAME, "lang_Italian" )			-- 3
table.insert( LANGUAGE_NAME, "lang_German" )			-- 4
table.insert( LANGUAGE_NAME, "lang_Spanish" )			-- 5
table.insert( LANGUAGE_NAME, "lang_Dutch" )				-- 6
table.insert( LANGUAGE_NAME, "lang_Russian" )			-- 7
table.insert( LANGUAGE_NAME, "lang_Korean" )			-- 8
table.insert( LANGUAGE_NAME, "lang_Japanese" )			-- 9
table.insert( LANGUAGE_NAME, "lang_Hungarian" )			-- 10
table.insert( LANGUAGE_NAME, "lang_Portuguese" )		-- 11
table.insert( LANGUAGE_NAME, "lang_Arabic" )			-- 12
table.insert( LANGUAGE_NAME, "lang_Bahasa_Indonesia" )	-- 13
table.insert( LANGUAGE_NAME, "lang_Thailand" )			-- 14
table.insert( LANGUAGE_NAME, "lang_Cambodian" )			-- 15

local Constants = require("scripts.Constants")


local mLanguageConfig = {
	{ ["id"] = 0, ["name"] = Constants.String.languages.english, ["key"] = "en", ["LocalizedStringFile"] = "en.LocalizedString", ["locale"] = "en_US" },
	{ ["id"] = 1, ["name"] = Constants.String.languages.chinese, ["key"] = "zh", ["LocalizedStringFile"] = "zh.LocalizedString", ["locale"] = "zh_CN" },
    { ["id"] = 12, ["name"] = Constants.String.languages.arabic, ["key"] = "ar", ["LocalizedStringFile"] = "ar.LocalizedString", ["locale"] = "ar_AE" },
	{ ["id"] = 13, ["name"] = Constants.String.languages.indonesian, ["key"] = "id", ["LocalizedStringFile"] = "id.LocalizedString", ["locale"] = "id_ID" },
	{ ["id"] = 14, ["name"] = Constants.String.languages.thailand, ["key"] = "th", ["LocalizedStringFile"] = "th.LocalizedString", ["locale"] = "th_TH" },
	--{ ["id"] = 5, ["name"] = Constants.String.languages.spanish, ["key"] = "es", ["LocalizedStringFile"] = "es.LocalizedString", ["locale"] = "es_ES" },
}

function getSupportedLanguages()
	return mLanguageConfig
end

function getLanguageConfigById( id )
	for i= 1, table.getn( mLanguageConfig ) do
		if mLanguageConfig[i]["id"] == id then
			return mLanguageConfig[i]
		end
	end

	return mLanguageConfig[1]		-- Make english the default one.
end

function getLanguageName( id )
	if id > 0 and id < table.getn( LANGUAGE_NAME ) then
		return LANGUAGE_NAME[id + 1]
	end

	return LANGUAGE_NAME[1]
end

function updateUALanguageTag()
	-- Remove all language Tags
	Misc:sharedDelegate():removeUATags( Json.encode( LANGUAGE_NAME ) )

	-- Add the current language tag.
	local currentLanguage = CCApplication:sharedApplication():getCurrentLanguage()
	local languageTag = getLanguageName( currentLanguage )
	local tagsToAdd = {}
	table.insert( tagsToAdd, languageTag )
	Misc:sharedDelegate():addUATags( Json.encode( tagsToAdd ) )

	-- Add the location tag.
	local callback = function( success, jsonResponse )
		if success and type( jsonResponse ) == "table" then
			local countryString = jsonResponse["country"]
			if countryString then
				countryString = "country_"..countryString
				CCLuaLog( "UA tag country "..countryString )

				local countryTags = {}
				table.insert( countryTags, countryString )
				Misc:sharedDelegate():addUATags( Json.encode( countryTags ) )
			end
		end
	end

	EventManager:postEvent( Event.Do_Get_IP_Info, { callback } )
end