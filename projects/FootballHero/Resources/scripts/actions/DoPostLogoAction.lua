module(..., package.seeall)

local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local Logic = require("scripts.Logic").getInstance()
local Json = require("json")
local RequestUtils = require("scripts.RequestUtils")
local Constants = require("scripts.Constants")

local BOUNDARY = "----WebKitFormBoundary0RE40S3jy2bDPXOM"

function action( param )
    local fileUtils = CCFileUtils:sharedFileUtils()
    local path = fileUtils:getWritablePath()..Constants.LOGO_IMAGE_PATH
    if not fileUtils:isFileExist( path ) then
        CCLuaLog( "File does not exist: "..path )
        return
    end

    local beginStr = "--"..BOUNDARY.."\r\nContent-Disposition: form-data; name=\"picture\"; filename=\"myLogo.jpg\"\r\nContent-Type: image/jpeg\r\n\r\n"
    local endStr = "\r\n--"..BOUNDARY.."--\r\n"
    
    local url = RequestUtils.POST_LOGO_REST_CALL

    local requestInfo = {}
    requestInfo.requestData = "myLogo.jpg"
    requestInfo.url = url

    local handler = function( isSucceed, body, header, status, errorBuffer )
        RequestUtils.messageHandler( requestInfo, isSucceed, body, header, status, errorBuffer, RequestUtils.HTTP_200, onRequestSuccess, onRequestFailed )
    end

    local httpRequest = HttpRequestForLua:create( CCHttpRequest.kHttpPost )
    httpRequest:addHeader( "Content-Type: multipart/form-data; boundary="..BOUNDARY )
    httpRequest:addHeader( Logic:getAuthSessionString() )
    Misc:sharedDelegate():setFileToRequestData( httpRequest, beginStr, endStr, path, "rb" )
    httpRequest:sendHttpRequest( url, handler )
end

function onRequestSuccess( jsonResponse )
    -- Do nothing
    CCLuaLog( "Do Post Logo action success with: "..jsonResponse )
end

function onRequestFailed( jsonResponse )
    -- Do nothing
    local errorBuffer = jsonResponse["Message"]
    CCLuaLog( "Do Post Logo action failed with: "..errorBuffer )
end