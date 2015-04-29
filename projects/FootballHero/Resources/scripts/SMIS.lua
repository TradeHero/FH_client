module(..., package.seeall)

local RequestUtils = require("scripts.RequestUtils")
local FileUtils = require("scripts.FileUtils")

local SMI_FOLDER = "SMI/"
local SPIN_FOLDER = "Spin/"
local VIDEO_FOLDER = "Video/"

function getSMImagePath( fileUrl, handler, preferedFileName )
	getRemoteFile( fileUrl, SMI_FOLDER, handler, preferedFileName )
end

function getSpinPrizeImagePath( fileUrl, handler, preferedFileName )
	getRemoteFile( fileUrl, SPIN_FOLDER, handler, preferedFileName )
end

function getVideoImagePath( fileUrl, handler, preferedFileName )
	getRemoteFile( fileUrl, VIDEO_FOLDER, handler, preferedFileName )
end

-- Return the local file path if the file exist.
-- Otherwise download it, return the local path.
function getRemoteFile( fileUrl, localFolder, handler, preferedFileName )
	local fileName = tostring( fileUrl )
	
	if preferedFileName then
		fileName = preferedFileName
	else
		local toBeRemove = string.find(fileName, "?")
		if toBeRemove ~= nil then
				fileName = string.sub(fileName, 1, toBeRemove - 1)
		end

		local list = RequestUtils.split( fileName, "/" )
		fileName = list[table.getn( list )]	
	end

	local fileUtils = CCFileUtils:sharedFileUtils()
	local path = fileUtils:getWritablePath()..localFolder..fileName
	if fileUtils:isFileExist( path ) then
		handler( path )
	else
		local successHandler = function( body )
			FileUtils.writeStringToFile( localFolder..fileName, body )
			handler( path )
		end

		local failedHandler = function()
			handler( nil )
		end

		downloadImage( fileUrl, successHandler, failedHandler )
	end
end

function downloadImage( fileUrl, onRequestSuccess, onRequestFailed )
	local handler = function( isSucceed, body, header, status, errorBuffer )
        print( "Http reponse: "..status.." and errorBuffer: "..errorBuffer )

        if status == RequestUtils.HTTP_200 then
            onRequestSuccess( body )
        else
            onRequestFailed()
        end
    end

    local httpRequest = HttpRequestForLua:create( CCHttpRequest.kHttpGet )
    httpRequest:setPriority( CCHttpRequest.pVeryLow )
    httpRequest:sendHttpRequest( tostring( fileUrl ), handler )
end