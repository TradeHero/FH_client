module(..., package.seeall)

local Json = require("json")
local RequestUtils = require("scripts.RequestUtils")
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local Logic = require("scripts.Logic").getInstance()
local Constants = require("scripts.Constants")

local mJsonResponse

function action( param )

    local userIds = param[1]
    --table.insert( userIds, 779 )
    userIds = getAllUserIDs( userIds )
    
    local url = RequestUtils.GET_USER_META_DATA
   
    local requestContentText = Json.encode( userIds )
    local requestInfo = {}
    requestInfo.requestData = requestContentText
    requestInfo.url = url
    local handler = function( isSucceed, body, header, status, errorBuffer )
        RequestUtils.messageHandler( requestInfo, isSucceed, body, header, status, errorBuffer, RequestUtils.HTTP_200, onRequestSuccess )
    end

    local httpRequest = HttpRequestForLua:create( CCHttpRequest.kHttpPost )
    httpRequest:addHeader( Constants.CONTENT_TYPE_JSON )
    httpRequest:addHeader( Logic:getAuthSessionString() )
    httpRequest:getRequest():setRequestData( requestContentText, string.len( requestContentText ) )
    httpRequest:sendHttpRequest( url, handler )

    ConnectingMessage.loadFrame()
end

function onRequestSuccess( jsonResponse )
    loadMinigameWinnersScene( jsonResponse)
end

function loadMinigameWinnersScene( jsonResponse )
    local minigameWinnersScene = require("scripts.views.MinigameWinnersScene")
    minigameWinnersScene.loadFrame( jsonResponse )
end

function getAllUserIDs( rawIds )
    local ids = { UserIds = {} }
    -- insert own user id in to retrieve name and profile pic
    for i = 1, table.getn( rawIds ) do
        table.insert( ids["UserIds"], rawIds[i] )
    end

    return ids
end
