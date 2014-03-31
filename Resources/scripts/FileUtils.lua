module(..., package.seeall)

local Json = require("json")

function writeTableToFile( fileName, content )
	local platformType = CCApplication:sharedApplication():getTargetPlatform()
	if platformType ~= kTargetWindows then
		return
	end

	local fileUtils = CCFileUtils:sharedFileUtils()
	local writePath = fileUtils:getWritablePath()..fileName
	local fileHandle, errorCode = io.open( writePath, "w+" )
	--print( "Write to: "..writePath )
	if fileHandle == nil then
		assert( false, "Write failed to file"..fileName.." with error: "..errorCode )
		return
	end
	
	local text = Json.encode( content )
	fileHandle:write( text )
	fileHandle:close()
end

function readTableFromFile( fileName )
	local platformType = CCApplication:sharedApplication():getTargetPlatform()
	if platformType ~= kTargetWindows then
		return
	end

	local fileUtils = CCFileUtils:sharedFileUtils()
	local writePath = fileUtils:getWritablePath()..fileName
	local fileHandler, errorCode = io.open( writePath, "r" )
	print( "Read from: "..writePath )
	if fileHandler == nil then
		assert( false, "Read failed from file"..fileName.." with error: "..errorCode )
		return
	end
	
	local text = fileHandler:read("*all")
	fileHandler:close()
	print( "File text: "..text )
	return Json.decode( text )
end