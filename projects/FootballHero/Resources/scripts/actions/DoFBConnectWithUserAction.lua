module(..., package.seeall)

local Constants = require("scripts.Constants")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local Json = require("json")
local RequestUtils = require("scripts.RequestUtils")
local Logic = require("scripts.Logic").getInstance()


local mSuccessHandler
local mFailedHandler

function action( param )
    mSuccessHandler = param[1]
    mFailedHandler = param[2]

	local Json = require("json")
	local RequestUtils = require("scripts.RequestUtils")

    local successHandler = function( accessToken )
        if accessToken == nil then
            -- To handle user reject to the oAuth.
            onFBConnectFailed()
        else
            print("Get token "..accessToken)
            onFBConnectSuccess( accessToken )
        end
    end

    FacebookDelegate:sharedDelegate():login( successHandler, successHandler )
end

function onFBConnectFailed()
    mFailedHandler( true )
end

function onFBConnectSuccess( accessToken )
    local requestContent = { SocialNetworkType = 0, AuthToken = accessToken, useDev = RequestUtils.USE_DEV }
    local requestContentText = Json.encode( requestContent )
    
    local url = RequestUtils.FB_CONNECT_REST_CALL
    
    local requestInfo = {}
    requestInfo.requestData = requestContentText
    requestInfo.url = url

    local handler = function( isSucceed, body, header, status, errorBuffer )
        RequestUtils.messageHandler( requestInfo, isSucceed, body, header, status, errorBuffer, RequestUtils.HTTP_200, onRequestSuccess, onRequestFailed )
    end

    local httpRequest = HttpRequestForLua:create( CCHttpRequest.kHttpPost )
    httpRequest:addHeader( Constants.CONTENT_TYPE_JSON )
    httpRequest:addHeader( Logic:getAuthSessionString() )
    httpRequest:getRequest():setRequestData( requestContentText, string.len( requestContentText ) )
    httpRequest:sendHttpRequest( url, handler )

    ConnectingMessage.loadFrame()
end

function onRequestSuccess( jsonResponse )
    Logic:setFbId( "" )
    mSuccessHandler()
end

function onRequestFailed( jsonResponse )
    local errorBuffer = jsonResponse["Message"]
    mFailedHandler( false )
    EventManager:postEvent( Event.Show_Error_Message, { errorBuffer } )
end