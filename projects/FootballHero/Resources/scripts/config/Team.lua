module(..., package.seeall)

local Constants = require("scripts.Constants")
local JsonConfigReader = require("scripts.config.JsonConfigReader")
local DoLogReport = require("scripts.actions.DoLogReport")


local FILE_NAME = "config/teams.txt"
local mConfig = {}
local mIndex = {}
local mConfigNum = 0

function init()
	if mConfigNum > 0 then 
		return
	end
	CCLuaLog("Read Team config.")
	mConfig, mConfigNum, mIndex = JsonConfigReader.read( FILE_NAME, "Id" )
end

function getConfig( id )
	if id == nil then
		return nil
	end
	assert( mConfig[id] ~= nil, FILE_NAME.." dosen't has "..id )

	return mConfig[id]
end

function getConfigIdByKey( key )
	if key == nil then
		return nil
	end
	if mIndex[key] == nil then
		local log = FILE_NAME.." dosen't has "..key
		print( log )
		DoLogReport.reportConfigError( log )
	end

	return mIndex[key]
end

function getConfigNum()
	return mConfigNum
end

--[[
	Provide additional getters.
--]]

function getTeamId( id )
	local config = getConfig( id )
	if config ~= nil then
		return config["Id"]
	else
		return 0
	end
end

function getTeamName( id )
	local config = getConfig( id )
	if config ~= nil then
		return config["teamName"]
	else
		if id ~= nil then
			return Constants.String.unknown_team..": "..id
		else
			return Constants.String.unknown_team
		end
	end
end

function getLogo( id )
	local config = getConfig( id )

	if config ~= nil then
		local fileUtils = CCFileUtils:sharedFileUtils()
		local filePath = fileUtils:fullPathForFilename( Constants.TEAM_IMAGE_PATH..config["Id"]..".png" )
		if fileUtils:isFileExist( filePath ) then
			return Constants.TEAM_IMAGE_PATH..config["Id"]..".png"
		else
			return Constants.TEAM_IMAGE_PATH.."default.png"
		end
	else
		return Constants.TEAM_IMAGE_PATH.."default.png"
	end
end

function getThumbUrl( id )
	local config = getConfig( id )
	if config ~= nil then
		return config["thumbUrl"]
	else
		return "Unknown"
	end
	
end

init()