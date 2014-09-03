module(..., package.seeall)

local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local Logic = require("scripts.Logic").getInstance()
local Json = require("json")
local RequestUtils = require("scripts.RequestUtils")
local Constants = require("scripts.Constants")


function action( param )
    local fileUtils = CCFileUtils:sharedFileUtils()
    local path = fileUtils:getWritablePath()..Constants.LOGO_IMAGE_PATH
    if not fileUtils:isFileExist( path ) then
        print( "File does not exist: "..path )
        return
    end
    local requestContentText, fileSize = fileUtils:getFileData( path, "rb", 0 )
    
    local url = RequestUtils.POST_LOGO_REST_CALL

    local requestInfo = {}
    requestInfo.requestData = requestContentText
    requestInfo.url = url

    local handler = function( isSucceed, body, header, status, errorBuffer )
        RequestUtils.messageHandler( requestInfo, isSucceed, body, header, status, errorBuffer, RequestUtils.HTTP_200, onRequestSuccess, onRequestFailed )
    end

    local httpRequest = HttpRequestForLua:create( CCHttpRequest.kHttpPost )
    httpRequest:addHeader( Constants.CONTENT_TYPE_JPG )
    httpRequest:addHeader( Logic:getAuthSessionString() )
    httpRequest:getRequest():setRequestData( requestContentText, fileSize )
    httpRequest:sendHttpRequest( url, handler )

    ConnectingMessage.loadFrame()
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