module(..., package.seeall)

local RequestUtils = require("scripts.RequestUtils")

-- Localized strings
local TARGET_LANGUAGE = "es"

local ID_KEY = 1
local ID_EN_VALUE = 2
local ID_TARGET_VALUE = 3

local ID_TABLE = 1
local ID_SUB_TABLE = 2
local mInput


function action( param )
	local mLocalizedStrings = require(TARGET_LANGUAGE..".LocalizedString").Strings
	-- Load the existing translation text.
	local mt    = {
	    __index = function ( t ,k )
	    	return nil
	    end
	} 
	setmetatable( mLocalizedStrings, mt )

	-- Load the new translation text.
	local fileUtils = CCFileUtils:sharedFileUtils()
    local filePath = fileUtils:fullPathForFilename( "config/newTranslations.txt" )
    mInput = fileUtils:getFileData( filePath, "r", 0 )
	
	local newTranslations = RequestUtils.split( mInput, "\r\n" )

	for i = 1, table.getn( newTranslations ) do

		local translation = newTranslations[i]
		--CCLuaLog(translation)
		local keyValues = RequestUtils.split( translation, "\t" )
		if keyValues[ID_TARGET_VALUE] == nil or keyValues[ID_TARGET_VALUE] == "" then
			keyValues[ID_TARGET_VALUE] = keyValues[ID_EN_VALUE]
		end
		local keys = RequestUtils.split( keyValues[ID_KEY], "." )
		
		if table.getn( keys ) == 1 then
			--CCLuaLog(keyValues[ID_KEY].."|"..keys[1])
			mLocalizedStrings[keys[ID_TABLE]] = keyValues[ID_TARGET_VALUE]
		elseif table.getn( keys ) == 2 then
			--CCLuaLog(keyValues[ID_KEY].."|"..keys[1]..".."..keys[2])

			if not mLocalizedStrings[keys[ID_TABLE]] then
				mLocalizedStrings[keys[ID_TABLE]] = {}
			end
			mLocalizedStrings[keys[ID_TABLE]][keys[ID_SUB_TABLE]] = keyValues[ID_TARGET_VALUE]
		end
	end

	-- Output
	local outputStr = "Strings = {\n"
	for k, v in pairs( mLocalizedStrings ) do
		if type( v ) == "table" then
			outputStr = outputStr.."\t"..k.." = {\n"
			for innerK, innerV in pairs( v ) do

				innerV = string.gsub(innerV, "\n", "\\n")
				outputStr = outputStr.."\t\t"..innerK.." = \""..innerV.."\",\n" 
			end
			outputStr = outputStr.."\t},\n"
		else
			v = string.gsub(v, "\n", "\\n")
			outputStr = outputStr.."\t"..k.." = \""..v.."\",\n" 
		end
	end
	outputStr = outputStr.."}\n"

	CCLuaLog( outputStr )
end