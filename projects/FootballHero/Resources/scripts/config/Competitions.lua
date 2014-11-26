module(..., package.seeall)

local JsonConfigReader = require("scripts.config.JsonConfigReader")
local DoLogReport = require("scripts.actions.DoLogReport")


local FILE_NAME = "config/competitions.txt"
local mConfig = {}
local mIndex = {}
local mConfigNum = 0

function init()
	if mConfigNum > 0 then 
		return
	end
	print("Read Competitions config.")
	local filter = function( v )
		return true
	end
	mConfig, mConfigNum, mIndex = JsonConfigReader.read( FILE_NAME, "token", filter )
	print( "Read competitions: "..mConfigNum )
end

function getConfig( id )
	assert( mConfig[id] ~= nil, FILE_NAME.." does not contain "..id )

	return mConfig[id]
end

function getConfigIdByKey( key )
	if mIndex[key] == nil then
		local log = FILE_NAME.." does not contain "..key
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
	return config["token"]
end

function getTitle1( id )
	local config = getConfig( id )
	return config["title1"]
end


function getTitle2( id )
	local config = getConfig( id )
	return config["title2"]
end


function getBody( id )
	local config = getConfig( id )
	return config["body"]
end

init()