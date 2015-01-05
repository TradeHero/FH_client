module(..., package.seeall)

local Json = require("json")

function writeStringToFile( fileName, str )
	local fileUtils = CCFileUtils:sharedFileUtils()
	local writePath = fileUtils:getWritablePath()..fileName

	createFolderRecur( fileUtils:getWritablePath(), fileName )

	local fileHandle, errorCode = io.open( writePath, "w+" )
	--print( "Write to: "..writePath )
	if fileHandle == nil then
		assert( false, "Write failed to file"..fileName.." with error: "..errorCode )
		return
	end

	fileHandle:write( str )
	fileHandle:close()
end

function createFolderRecur( existFolder, toCreateFolder )
	print("createFolderRecur: "..existFolder.."|"..toCreateFolder)
	local pos = string.find( toCreateFolder, "/" )
	if pos ~= nil then
		local folderToCreate = existFolder..string.sub( toCreateFolder, 1, pos )
		if lfs.mkdir( folderToCreate ) then
			createFolderRecur( folderToCreate, string.sub( toCreateFolder, pos + 1 ) )
		end
	end
end

-- 1. check the writable path
-- 2. check the file in the package
function readStringFromFile( fileName )
	local text = ""
	local textLength = 0
	local fileUtils = CCFileUtils:sharedFileUtils()
	local path = fileUtils:getWritablePath()..fileName
	if fileUtils:isFileExist( path ) then
		print("Read local file from: "..path)
		local startTime = os.clock()
		local fileHandler, errorCode = io.open( path, "r" )
		--print( "Read from: "..path )
		if fileHandler == nil then
			assert( false, "Read failed from file"..fileName.." with error: "..errorCode )
			return ""
		end
		
		text = fileHandler:read("*all")
		fileHandler:close()

		local endTime = os.clock()
		CCLuaLog("Read file "..fileName.." took "..( endTime - startTime ) )
	else
		local fileName = fileUtils:fullPathForFilename( fileName )
		CCLuaLog("Read file from package: "..fileName)
		text, textLength = fileUtils:getFileData( fileName, "r", 0 )
		if text ~= nil and textLength > 0 then
			text = string.sub( text, 1, textLength )
		end
	end


	return text
end

