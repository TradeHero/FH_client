module(..., package.seeall)

--[[
	LanguageType = {
		["kLanguageEnglish"] = 0,
	    ["kLanguageChinese"] = 1,
	    ["kLanguageFrench"] = 2,
	    ["kLanguageItalian"] = 3,
	    ["kLanguageGerman"] = 4,
	    ["kLanguageSpanish"] = 5,
	    ["kLanguageDutch"] = 6,
	    ["kLanguageRussian"] = 7,
	    ["kLanguageKorean"] = 8,
	    ["kLanguageJapanese"] = 9,
	    ["kLanguageHungarian"] = 10,
	    ["kLanguagePortuguese"] = 11,
	    ["kLanguageArabic"] = 12,
	    ["kLanguageBahasa"] = 13,
	}

--]]

KEY_OF_LANGUAGE = "app-language"

local Constants = require("scripts.Constants")


local mLanguageConfig = {
	{ ["id"] = 0, ["name"] = Constants.String.languages.english, ["key"] = "en", ["LocalizedStringFile"] = "en.LocalizedString", ["locale"] = "en_US" },
	{ ["id"] = 1, ["name"] = Constants.String.languages.chinese, ["key"] = "zh", ["LocalizedStringFile"] = "zh.LocalizedString", ["locale"] = "zh_CN" },
	{ ["id"] = 13, ["name"] = Constants.String.languages.indonesian, ["key"] = "id", ["LocalizedStringFile"] = "id.LocalizedString", ["locale"] = "id_ID" },
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

	return nil
end