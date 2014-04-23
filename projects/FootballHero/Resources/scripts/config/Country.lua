module(..., package.seeall)

local JsonConfigReader = require("scripts.config.JsonConfigReader")


local FILE_NAME = "config/countries.txt"
local mConfig = {}
local mConfigNum = 0

function init()
	if mConfigNum > 0 then 
		return
	end
	print("Read Country config.")
	mConfig, mConfigNum = JsonConfigReader.read( FILE_NAME, "countryId" )
end

function getConfig( id )
	assert( mConfig[id] ~= nil, FILE_NAME.." dosen't has "..id )

	return mConfig[id]
end

function getConfigNum()
	return mConfigNum
end

--[[
	Provide additional getters.
--]]

function getCountryCode( id )
	local config = getConfig( id )
	return config["countryCode"]
end

function getCountryName( id )
	local config = getConfig( id )
	return config["countryName"]
end

init()