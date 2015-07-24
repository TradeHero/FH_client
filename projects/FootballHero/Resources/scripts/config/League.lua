module(..., package.seeall)

local JsonConfigReader = require("scripts.config.JsonConfigReader")
local DoLogReport = require("scripts.actions.DoLogReport")


local FILE_NAME = "config/leagues.txt"
local mConfig = {}
local mIndex = {}
local mConfigNum = 0

function init()
	if mConfigNum > 0 then 
		return
	end
	CCLuaLog("Read League config.")
	local filter = function( v )
		return v["isActive"]
	end
	mConfig, mConfigNum, mIndex = JsonConfigReader.read( FILE_NAME, "Id", filter )
	CCLuaLog( "Read active league number: "..mConfigNum )
end

function getConfig( id )
	assert( mConfig[id] ~= nil, FILE_NAME.." dosen't has "..id )

	return mConfig[id]
end

function getConfigIdByKey( key )
	if mIndex[key] == nil then
		local log = FILE_NAME.." dosen't has "..key
		print( log )
		DoLogReport.reportConfigError( log )
		return nil
	end

	return mIndex[key]
end

function getConfigNum()
	return mConfigNum
end

--[[
	Provide additional getters.
--]]

function getConfigId( id )
	local config = getConfig( id )
	return config["Id"]
end

function getCountryId( id )
	local config = getConfig( id )
	return config["countryId"]
end

function getLogo( id )
	local config = getConfig( id )
	return config["Id"]..".png"
end

function getLeagueName( id )
	local config = getConfig( id )
	return config["leagueName"]
end

function getThumbUrl( id )
	local config = getConfig( id )
	return config["thumbUrl"]
end

function isActive( id )
	local config = getConfig( id )
	return config["isActive"]
end

function isHidden( id )
	local config = getConfig( id )
	return config["isHidden"]
end

function getSportId( id )
	local config = getConfig( id )
	return config["SportId"]
end

init()