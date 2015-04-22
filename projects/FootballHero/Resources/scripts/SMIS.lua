module(..., package.seeall)

local RequestUtils = require("scripts.RequestUtils")
local FileUtils = require("scripts.FileUtils")

local SMI_FOLDER = "SMI/"
local SPIN_FOLDER = "Spin/"

function getSMImagePath( fileUrl, handler )
	getRemoteFile( fileUrl, SMI_FOLDER, handler )
end

function getSpinPrizeImagePath( fileUrl, handler )
	getRemoteFile( fileUrl, SPIN_FOLDER, handler )
end

-- Return the local file path if the file exist.
-- Otherwise download it, return the local path.
function getRemoteFile( fileUrl, localFolder, handler )
	local fileName = tostring( fileUrl )
	
	local toBeRemove = string.find(fileName, "?")
	if toBeRemove ~= nil then
			fileName = string.sub(fileName, 1, toBeRemove - 1)
	end

	local list = RequestUtils.split( fileName, "/" )
	fileName = list[table.getn( list )]

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