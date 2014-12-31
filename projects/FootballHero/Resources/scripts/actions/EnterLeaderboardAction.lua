module(..., package.seeall)

local Json = require("json")
local RequestUtils = require("scripts.RequestUtils")
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local Logic = require("scripts.Logic").getInstance()
local Competitions = require("scripts.data.Competitions").Competitions

function action( param )
    local url = RequestUtils.GET_COMPETITION_LIST_REST_CALL

    local requestInfo = {}
    requestInfo.requestData = ""
    requestInfo.url = url

    local handler = function( isSucceed, body, header, status, errorBuffer )
        RequestUtils.messageHandler( requestInfo, isSucceed, body, header, status, errorBuffer, RequestUtils.HTTP_200, true, onRequestSuccess )
    end

    local httpRequest = HttpRequestForLua:create( CCHttpRequest.kHttpGet )
    httpRequest:addHeader( Logic:getAuthSessionString() )
    httpRequest:sendHttpRequest( url, handler )

    ConnectingMessage.loadFrame()
end

function onRequestSuccess( jsonResponse )
	local compList = Competitions:new( jsonResponse )

    local leaderboardMainScene = require("scripts.views.LeaderboardMainScene")
	if leaderboardMainScene.isFrameShown() then
		return
	end
    leaderboardMainScene.loadFrame( compList )
end