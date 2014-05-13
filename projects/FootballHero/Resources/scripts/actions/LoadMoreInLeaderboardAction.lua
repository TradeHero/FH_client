module(..., package.seeall)

local Json = require("json")
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local RequestUtils = require("scripts.RequestUtils")
local LeaderboardConfig = require("scripts.config.Leaderboard")
local Logic = require("scripts.Logic").getInstance()

local mLeaderboardId
local mSubType

function action( param )
	mLeaderboardId = param[1]
	mSubType = param[2]
	local step = param[3]

	local url = RequestUtils.GET_MAIN_LEADERBOARD_REST_CALL

	local handler = function( isSucceed, body, header, status, errorBuffer )
        print( "Http reponse: "..status.." and errorBuffer: "..errorBuffer )
        print( "Http reponse body: "..body )
        
        local jsonResponse = {}
        if string.len( body ) > 0 then
            jsonResponse = Json.decode( body )
        else
            jsonResponse["Message"] = errorBuffer
        end
        ConnectingMessage.selfRemove()
        if status == RequestUtils.HTTP_200 then
            onRequestSuccess( jsonResponse )
        else
            onRequestFailed( jsonResponse["Message"] )
        end
    end

    local httpRequest = HttpRequestForLua:create( CCHttpRequest.kHttpGet )
    httpRequest:addHeader( Logic:getAuthSessionString() )
    httpRequest:sendHttpRequest( url.."?sortType="..mSubType["sortType"].."&step="..step, handler )

    ConnectingMessage.loadFrame()
end

function onRequestSuccess( response )
    local leaderboardListScene = require("scripts.views.LeaderboardListScene")
    leaderboardListScene.loadMoreContent( response )
end

function onRequestFailed( errorBuffer )
    EventManager:postEvent( Event.Show_Error_Message, { errorBuffer } )
end