module(..., package.seeall)

local Json = require("json")
local RequestUtils = require("scripts.RequestUtils")
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local Logic = require("scripts.Logic").getInstance()
local Constants = require("scripts.Constants")

local mCallback

function action( param )
    local expertId = param[1] 
    local follow = param[2]
    mCallback = param[3]
    CCLuaLog( "id:" .. expertId .. "\tfollow:" .. tostring(follow))
 
    local requestContent = { ExpertId = expertId, IsFollowed = follow }
    local requestContentText = Json.encode( requestContent )
    local url = RequestUtils.GET_FOLLOW_EXPERTS

    local requestInfo = {}
    requestInfo.requestData = requestContentText
    requestInfo.url = url
    requestInfo.recordResponse = false

    local handler = function( isSucceed, body, header, status, errorBuffer )
        RequestUtils.messageHandler( requestInfo, isSucceed, body, header, status, errorBuffer, RequestUtils.HTTP_200, true, onRequestSuccess )
    end

    local httpRequest = HttpRequestForLua:create( CCHttpRequest.kHttpPost )
    httpRequest:addHeader( Constants.CONTENT_TYPE_JSON )
    httpRequest:addHeader( Logic:getAuthSessionString() )
    httpRequest:getRequest():setRequestData( requestContentText, string.len( requestContentText ) )
    httpRequest:sendHttpRequest( url, handler )

    ConnectingMessage.loadFrame()
end

function onRequestSuccess( jsonResponse )
    mCallback( jsonResponse )
end
