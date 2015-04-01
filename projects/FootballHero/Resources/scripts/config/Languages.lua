module(..., package.seeall)

local Json = require("json")

KEY_OF_LANGUAGE = "app-language"
local LANGUAGE_NAME = {}
table.insert( LANGUAGE_NAME, "English" )			-- 0
table.insert( LANGUAGE_NAME, "Chinese" )			-- 1
table.insert( LANGUAGE_NAME, "French" )				-- 2
table.insert( LANGUAGE_NAME, "Italian" )			-- 3
table.insert( LANGUAGE_NAME, "German" )				-- 4
table.insert( LANGUAGE_NAME, "Spanish" )			-- 5
table.insert( LANGUAGE_NAME, "Dutch" )				-- 6
table.insert( LANGUAGE_NAME, "Russian" )			-- 7
table.insert( LANGUAGE_NAME, "Korean" )				-- 8
table.insert( LANGUAGE_NAME, "Japanese" )			-- 9
table.insert( LANGUAGE_NAME, "Hungarian" )			-- 10
table.insert( LANGUAGE_NAME, "Portuguese" )			-- 11
table.insert( LANGUAGE_NAME, "Arabic" )				-- 12
table.insert( LANGUAGE_NAME, "Bahasa Indonesia" )	-- 13
table.insert( LANGUAGE_NAME, "Thailand" )			-- 14
table.insert( LANGUAGE_NAME, "Cambodian" )			-- 15

local Constants = require("scripts.Constants")


local mLanguageConfig = {
	{ ["id"] = 0, ["name"] = Constants.String.languages.english, ["key"] = "en", ["LocalizedStringFile"] = "en.LocalizedString", ["locale"] = "en_US" },
	{ ["id"] = 1, ["name"] = Constants.String.languages.chinese, ["key"] = "zh", ["LocalizedStringFile"] = "zh.LocalizedString", ["locale"] = "zh_CN" },
    { ["id"] = 12, ["name"] = Constants.String.languages.arabic, ["key"] = "ar", ["LocalizedStringFile"] = "ar.LocalizedString", ["locale"] = "ar_AE" },
	{ ["id"] = 13, ["name"] = Constants.String.languages.indonesian, ["key"] = "id", ["LocalizedStringFile"] = "id.LocalizedString", ["locale"] = "id_ID" },
	{ ["id"] = 14, ["name"] = Constants.String.languages.thailand, ["key"] = "th", ["LocalizedStringFile"] = "th.LocalizedString", ["locale"] = "th_TH" },
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
end