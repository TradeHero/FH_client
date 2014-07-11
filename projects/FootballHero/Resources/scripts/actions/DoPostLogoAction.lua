module(..., package.seeall)

local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local Logic = require("scripts.Logic").getInstance()
local Json = require("json")
local RequestUtils = require("scripts.RequestUtils")
local Constants = require("scripts.Constants")


function action( param )
    if true then
        --return 
    end

    -- Todo later.

    local fileUtils = CCFileUtils:sharedFileUtils()
    local path = fileUtils:getWritablePath()..Constants.LOGO_IMAGE_PATH
    if not fileUtils:isFileExist( path ) then
        print( "File does not exist: "..path )
        return
    end
    local beginStr = "------WebKitFormBoundary0RE40S3jy2bDPXOM\r\nContent-Disposition: form-data; name = \"picture\"; filename = \"myLogo.jpg\"\r\nContent-Type: image/jpeg"
    local endStr = "\r\n------WebKitFormBoundary0RE40S3jy2bDPXOM--"
    local requestContentText, fileSize = Misc:sharedDelegate():createFormWithFile( beginStr, endStr, path, "rb" )
    
    local url = RequestUtils.POST_LOGO_REST_CALL
    --url = "http://127.0.0.1:8080/testServlet"

    local requestInfo = {}
    requestInfo.requestData = requestContentText
    requestInfo.url = url

    local handler = function( isSucceed, body, header, status, errorBuffer )
        RequestUtils.messageHandler( requestInfo, isSucceed, body, header, status, errorBuffer, RequestUtils.HTTP_200, onRequestSuccess, onRequestFailed )
    end

    local httpRequest = HttpRequestForLua:create( CCHttpRequest.kHttpPost )
    httpRequest:addHeader( "Content-Type: multipart/form-data; boundary=------WebKitFormBoundary0RE40S3jy2bDPXOM" )
    httpRequest:addHeader( Logic:getAuthSessionString() )
    httpRequest:getRequest():setRequestData( requestContentText, fileSize )
    httpRequest:sendHttpRequest( url, handler )
end

function onRequestSuccess( jsonResponse )
    -- Do nothing
    print( "Do Post Logo action success with: "..jsonResponse )
end

function onRequestFailed( jsonResponse )
    -- Do nothing
    local errorBuffer = jsonResponse["Message"]
    print( "Do Post Logo action failed with: "..errorBuffer )
end