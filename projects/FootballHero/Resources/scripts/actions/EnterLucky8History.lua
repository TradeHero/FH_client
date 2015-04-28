module(..., package.seeall)

local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local RequestUtils = require("scripts.RequestUtils")
local Logic = require("scripts.Logic").getInstance()
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local Json = require("json")

function requestLucky8History( cellInfo )
	local roundId = cellInfo["RoundId"]
	local url = RequestUtils.GET_LUCKY8_GAMES .. "?roundId=" .. string.format("%d", roundId)
    local requestInfo = {}
    requestInfo.requestData = ""
    requestInfo.url = url
    local handler = function ( isSucceed, body, header, status, errorBuffer )
        RequestUtils.messageHandler( requestInfo, isSucceed, body, header, status, errorBuffer, RequestUtils.HTTP_200, true, onRequestLucky8MatchListSuccess, onRequestLucky8MatchListFailed )
    end

    local httpRequest = HttpRequestForLua:create( CCHttpRequest.kHttpGet )
    httpRequest:addHeader( Logic:getAuthSessionString() )
    httpRequest:sendHttpRequest( url, handler )

    ConnectingMessage.loadFrame()
end

function onRequestLucky8MatchListSuccess( jsonResponse )
	local lucky8HistoryScene = require( "scripts.views.Lucky8HistoryScene" )
	lucky8HistoryScene.loadFrame( jsonResponse )
end

function onRequestLucky8MatchListFailed( jsonResponse )
	RequestUtils.onRequestFailedByErrorCode( jsonResponse["Message"] )
end

function action( param )
	requestLucky8History( param )
end