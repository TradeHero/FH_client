module(..., package.seeall)

local RequestUtils = require("scripts.RequestUtils")
local FileUtils = require("scripts.FileUtils")

local FOLDER = "SMI/"

-- Return the local file path if the file exist.
-- Otherwise download it, save it locally and return the file path.
function getSMImagePath( fileUrl, handler )
	local list = RequestUtils.split( fileUrl, "/" )
	local fileName = list[table.getn( list )]

	local fileUtils = CCFileUtils:sharedFileUtils()
	local path = fileUtils:getWritablePath()..FOLDER..fileName
	if fileUtils:isFileExist( path ) then
		handler( path )
	else
		local successHandler = function( body )
			FileUtils.writeStringToFile( FOLDER..fileName, body )
			handler( path )
		end

		local failedHandler = function()
			handler( nil )
		end

		downloadSMImage( fileUrl, successHandler, failedHandler )
	end
end

function downloadSMImage( fileUrl, onRequestSuccess, onRequestFailed )
	local handler = function( isSucceed, body, header, status, errorBuffer )
        print( "Http reponse: "..status.." and errorBuffer: "..errorBuffer )

        if status == RequestUtils.HTTP_200 then
            onRequestSuccess( body )
        else
            onRequestFailed()
        end
    end

    local httpRequest = HttpRequestForLua:create( CCHttpRequest.kHttpGet )
    httpRequest:sendHttpRequest( fileUrl, handler )
end