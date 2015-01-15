module(..., package.seeall)

local Json = require("json")
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local Logic = require("scripts.Logic").getInstance()
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local RequestUtils = require("scripts.RequestUtils")
local Constants = require("scripts.Constants")
local MatchCenterConfig = require("scripts.config.MatchCenter")

local mCallback

function action( param )
    local postId = param[1]
    local bLike = param[2]
    mCallback = param[3]
    
    local url = RequestUtils.POST_LIKE_DISCUSSION_REST_CALL

    local requestContent = { PostId = postId, Liked = bLike }
    local requestContentText = Json.encode( requestContent )

    local requestInfo = {}
    requestInfo.requestData = requestContentText
    requestInfo.url = url

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

function onRequestFailed( jsonResponse )
    local errorBuffer = jsonResponse["Message"]
    CCLuaLog("Error message is:"..errorBuffer )

    RequestUtils.onRequestFailed( errorBuffer )
end