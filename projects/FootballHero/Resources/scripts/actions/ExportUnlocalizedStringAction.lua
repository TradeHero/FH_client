module(..., package.seeall)

-- Default strings
require "DefaultString"
local mDefaultString = StringsDefault

-- Localized strings
local TARGET_LANGUAGE = "zh"

-- Output string
local mSeperate = "\t"
local mResultString = "key"..mSeperate.."en"..mSeperate..TARGET_LANGUAGE


function action( param )
	local mLocalizedStrings = require(TARGET_LANGUAGE..".LocalizedString").Strings

	local mt    = {
	    __index = function ( t ,k )
	    	return nil
	    end
	}

	setmetatable( mLocalizedStrings, mt )
	for i = 1 , table.getn( StringDefaultSubTableList ) do
	    local subTableTitle = StringDefaultSubTableList[i]
	    if mLocalizedStrings[subTableTitle] then
	        setmetatable( mLocalizedStrings[subTableTitle], mt )  
	    end
	end

	for k, v in pairs( mDefaultString ) do
    	if type( v ) == "table" then
    		if k == "languages" then
    			-- skip the languages
    		else
    			for innerK, innerV in pairs( mDefaultString[k] ) do
	    			if ( not mLocalizedStrings[k] ) or 
	    				( not mLocalizedStrings[k][innerK] ) then

						local enValue = string.gsub(mDefaultString[k][innerK], "\n", "\\n")
						mResultString = mResultString.."\n"..
										k.."."..innerK..mSeperate..
										enValue..mSeperate
					else
						--CCLuaLog( mLocalizedStrings[k][innerK] )
					end	
	    		end
    		end
    	else
			if not mLocalizedStrings[k] then
				
				local enValue = string.gsub(mDefaultString[k], "\n", "\\n")
				mResultString = mResultString.."\n"..
								k..mSeperate..
								enValue..mSeperate
			else
				--CCLuaLog( mLocalizedStrings[k] )
			end
    	end
    end

    CCLuaLog(mResultString)
end