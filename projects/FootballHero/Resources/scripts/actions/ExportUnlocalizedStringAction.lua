module(..., package.seeall)

-- Default strings
require "DefaultString"
local mDefaultString = StringsDefault

-- Localized strings
local TARGET_LANGUAGE = "zh"
local mLocalizedStrings =
	require(TARGET_LANGUAGE..".LocalizedString").Strings

-- Output string
local mSeperate = "\t"
local mResultString = "key"..mSeperate.."en"..mSeperate..TARGET_LANGUAGE


function action( param )
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
end