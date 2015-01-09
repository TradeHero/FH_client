module(..., package.seeall)

local Json = require("json")
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local Logic = require("scripts.Logic").getInstance()
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local RequestUtils = require("scripts.RequestUtils")
local Constants = require("scripts.Constants")
local MatchCenterConfig = require("scripts.config.MatchCenter")

function action( param )
    local postId = param[1]
    local bLike = param[2]
    --TODO param 3 : like post or comments / callback function

    local url = RequestUtils.POST_LIKE_DISCUSSION_REST_CALL
--[[
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
--]]

    --loadMatchCenterScene( {}, mTabID )
end

function loadMatchCenterScene( jsonResponse )
    local MatchCenterScene = require("scripts.views.MatchCenterScene")
    
    if MatchCenterScene.isShown() then
        MatchCenterScene.refreshFrame( jsonResponse, mTabID )
    else
        MatchCenterScene.loadFrame( jsonResponse, mTabID )
    end
end

function onRequestSuccess( jsonResponse )
    --TODO handle like
    loadMatchCenterScene( jsonResponse )
end

function onRequestFailed( jsonResponse )
    local errorBuffer = jsonResponse["Message"]
    CCLuaLog("Error message is:"..errorBuffer )

    RequestUtils.onRequestFailed( errorBuffer )
end