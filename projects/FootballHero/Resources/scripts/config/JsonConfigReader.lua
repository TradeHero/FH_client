module(..., package.seeall)

local Json = require("json")
local FileUtils = require("scripts.FileUtils")

function read( fileName, primaryKey, filter )
	filter = filter or passAll
	if primaryKey == nil then
		return readWithoutPrimaryKey( fileName, filter )
	else
		return readWithPrimaryKey( fileName, primaryKey, filter )
	end
end

function readWithPrimaryKey( fileName, primaryKey, filter )
	local config = {}
	local index = {}
	local configNum = 0

	-- Check if there is a local version
	local text = FileUtils.readStringFromFile( fileName )
	--print( text )
	local jsonObject = Json.decode( text )
	for i, v in pairs( jsonObject ) do
		if filter( v ) then
		    table.insert( config, v )
	    	configNum = configNum + 1

	    	local id = v[primaryKey]
		    index[id] = configNum
		end
	end

	return config, configNum, index
end

function readWithoutPrimaryKey( fileName, filter )
	local config = {}
	local configNum = 0

	local text = FileUtils.readStringFromFile( fileName )
	--print( text )
	local jsonObject = Json.decode( text )
	for i, v in pairs( jsonObject ) do
		if filter( v ) then
			table.insert( config, v )
	    	configNum = configNum + 1
		end
	end

	return config, configNum
end

function passAll( v )
	return true
end

function readAndCombine( fileName, primaryKey )
	local config = {}

	local text = FileUtils.readStringFromFile( fileName )
	--print( text )
	local jsonObject = Json.decode( text )
	for i, v in pairs( jsonObject ) do
		local id = v[primaryKey]
		if config[id] == nil then
			config[id] = {}
		end

		table.insert( config[id], v )
	end

	return config
end