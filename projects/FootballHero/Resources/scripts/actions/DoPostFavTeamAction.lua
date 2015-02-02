module(..., package.seeall)

local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local Logic = require("scripts.Logic").getInstance()
local Json = require("json")
local RequestUtils = require("scripts.RequestUtils")
local Constants = require("scripts.Constants")

local mFailedCallback
local mFavTeamID

function action( param )
	
    mFavTeamID = param[1]
    local bLiked = param[2]
    mFailedCallback = param[3]

    local requestContent = { TeamId = mFavTeamID, Liked = bLiked }
    local requestContentText = Json.encode( requestContent )
    
    local url = RequestUtils.POST_FAV_TEAM_REST_CALL

    local requestInfo = {}
    requestInfo.requestData = requestContentText
    requestInfo.url = url

    local handler = function( isSucceed, body, header, status, errorBuffer )
        RequestUtils.messageHandler( requestInfo, isSucceed, body, header, status, errorBuffer, RequestUtils.HTTP_200, true, onRequestSuccess, onRequestFailed )
    end

    local httpRequest = HttpRequestForLua:create( CCHttpRequest.kHttpPost )
    httpRequest:addHeader( Constants.CONTENT_TYPE_JSON )
    httpRequest:addHeader( Logic:getAuthSessionString() )
    httpRequest:getRequest():setRequestData( requestContentText, string.len( requestContentText ) )
    httpRequest:sendHttpRequest( url, handler )

    ConnectingMessage.loadFrame()
end

function onRequestSuccess( jsonResponse )
    Logic:setFavoriteTeams( mFavTeamID )
    RequestUtils.invalidResponseCacheContainsUrl( RequestUtils.GET_SETTINGS )
end

function onRequestFailed( jsonResponse )
    mFailedCallback( jsonResponse )
end