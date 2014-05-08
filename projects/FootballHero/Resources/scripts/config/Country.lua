module(..., package.seeall)

local JsonConfigReader = require("scripts.config.JsonConfigReader")
local LeagueConfig = require("scripts.config.League")
local Constants = require("scripts.Constants")


local FILE_NAME = "config/countries.txt"
local mConfig = {}
local mIndex = {}
local mConfigNum = 0

function init()
	if mConfigNum > 0 then 
		return
	end
	print("Read Country config.")
	local filter = function( v )
		return v["isActive"]
	end
	mConfig, mConfigNum, mIndex = JsonConfigReader.read( FILE_NAME, "Id", filter )
	print( "Read active country number: "..mConfigNum )

	for i = 1, LeagueConfig.getConfigNum() do
		local countryId = LeagueConfig.getCountryId( i )
		addLeague( getConfigIdByKey( countryId ), i )
	end

	for i = 1, getConfigNum() do
		if getLeagueList( i ) == nil then
			assert( "County "..getCountryName( i ).." has no league." )
		else
			print( "County "..getCountryName( i ).." has "..table.getn( getLeagueList( i ) ).." leagues." )
		end
	end
end

function getConfig( id )
	assert( mConfig[id] ~= nil, FILE_NAME.." dosen't has "..id )

	return mConfig[id]
end

function getConfigIdByKey( key )
	assert( mIndex[key] ~= nil, FILE_NAME.." dosen't has "..key )

	return mIndex[key]
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
	if config["countryName"] ~= nil then
		return config["countryName"]
	else
		return config["countryCode"]
	end
end

function isActive( id )
	local config = getConfig( id )
	return config["isActive"]
end

function addLeague( id, leagueId )
	local config = getConfig( id )
	if config["leagueList"] == nil then
		config["leagueList"] = {}
	end
	table.insert( config["leagueList"], leagueId )
end

function getLeagueList( id )
	local config = getConfig( id )
	return config["leagueList"]
end

function getLogo( id )
	local config = getConfig( id )

	if config ~= nil then
		local fileUtils = CCFileUtils:sharedFileUtils()
		local filePath = fileUtils:fullPathForFilename( Constants.COUNTRY_IMAGE_PATH..config["Id"]..".png" )
		print( "Countries "..filePath )
		if fileUtils:isFileExist( filePath ) then
			return Constants.COUNTRY_IMAGE_PATH..config["Id"]..".png"
		else
			return Constants.COUNTRY_IMAGE_PATH.."default.png"
		end
	else
		return Constants.COUNTRY_IMAGE_PATH.."default.png"
	end
end

init()