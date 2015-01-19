module(..., package.seeall)

local RequestUtils = require("scripts.RequestUtils")

-- Default strings
require "DefaultString"
local mDefaultString = StringsDefault

-- Localized strings
local TARGET_LANGUAGE = "zh"
local mLocalizedStrings =
	require(TARGET_LANGUAGE..".LocalizedString").Strings

-- Output string
local mSeperate = "\t"
local mInput = "
league_chat.feedback	Feedback & Comments	反馈
league_chat.spanish	Spanish League	西班牙联赛
league_chat.others	Other Competitions	其他联赛
share_type_title	Share your competition using...	分享
enter_email	Please enter your email address.	请输入你的Email地址
match_center.played	Played %d out of %d	玩了%d/%d
match_center.just_now	Just Now	刚刚
"


function action( param )
	local newTranslations = RequestUtils.split( mInput, "\n" )

	for i = 1, table.getn( newTranslations ) do
		local translation = newTranslations[i]
		local keyValues = RequestUtils.split( translation, "\t" )
		CCLuaLog("Key is: "..keyValues[1])
		CCLuaLog("En is: "..keyValues[2])
		CCLuaLog("zh is: "..keyValues[3])
	end

	--[[
	local mt    = {
	    __index = function ( t ,k )
	    	return nil
	    end
	} 
	setmetatable( mLocalizedStrings, mt )

	for k, v in pairs( mDefaultString ) do
    	if type( v ) == "table" then
    		for innerK, innerV in pairs( mDefaultString[k] ) do
    			if ( not mLocalizedStrings[k] ) or 
    				( not mLocalizedStrings[k][innerK] ) then
					
					mResultString = mResultString.."\n"..
									k.."."..innerK..mSeperate..
									mDefaultString[k][innerK]..mSeperate
				end	
    		end
    	else
			if not mLocalizedStrings[k] then
				
				mResultString = mResultString.."\n"..
								k..mSeperate..
								mDefaultString[k]..mSeperate
			end
    	end
    end

    CCLuaLog(mResultString)
    --]]
end