module(..., package.seeall)

local Json = require("json")
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local Logic = require("scripts.Logic").getInstance()
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local RequestUtils = require("scripts.RequestUtils")
local Constants = require("scripts.Constants")

function requestLucky8MatchList(  )
    local url = RequestUtils.GET_LUCKY8_GAMES
    local requestInfo = {}
    requestInfo.requestData = ""
    requestInfo.url = url
    local handler = function ( isSucceed, body, header, status, errorBuffer )
        RequestUtils.messageHandler( requestInfo, isSucceed, body, header, status, errorBuffer, RequestUtils.HTTP_200, true, onRequestLucky8MatchListSuccess, nil )
    end

    local httpRequest = HttpRequestForLua:create( CCHttpRequest.kHttpGet )
    httpRequest:addHeader( Logic:getAuthSessionString() )
    httpRequest:sendHttpRequest( url, handler )

    ConnectingMessage.loadFrame()
end

function onRequestLucky8MatchListSuccess( json )
	local lucky8Scene = require( "scripts.views.Lucky8Scene" )
	if lucky8Scene.isFrameShown() then
		lucky8Scene.refreshPage( json )
	else
		lucky8Scene.loadFrame( json )
	end

    local params = {
        Action = "Enter lucky8",
    }
    Analytics:sharedDelegate():postEvent( Constants.ANALYTICS_EVENT_ENTER_LUCKY8, Json.encode( params ) )
    Analytics:sharedDelegate():postFlurryEvent( Constants.ANALYTICS_EVENT_ENTER_LUCKY8, Json.encode( params ) )
end

function action( param )
	requestLucky8MatchList( )
end
