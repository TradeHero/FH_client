module(..., package.seeall)

local Json = require("json")
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local Logic = require("scripts.Logic").getInstance()
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local RequestUtils = require("scripts.RequestUtils")


function action( param )
    local matchId = Logic:getSelectedMatch()["Id"]

    local url = RequestUtils.GET_GAME_MARKETS_REST_CALL.."?gameId="..matchId

    local requestInfo = {}
    requestInfo.requestData = ""
    requestInfo.url = url

    local handler = function( isSucceed, body, header, status, errorBuffer )
        RequestUtils.messageHandler( requestInfo, isSucceed, body, header, status, errorBuffer, RequestUtils.HTTP_200, onRequestSuccess )
    end

    local httpRequest = HttpRequestForLua:create( CCHttpRequest.kHttpGet )
    httpRequest:addHeader( Logic:getAuthSessionString() )
    httpRequest:sendHttpRequest( url, handler )

    ConnectingMessage.loadFrame()

--[[
    local JsonConfigReader = require("scripts.config.JsonConfigReader")
    local config = JsonConfigReader.read( "config/market.json" )

    local match = { Id = 4077,
                HomeTeamId = 2744,
                AwayTeamId = 2942,
                StartTime = 1398311338 }
    Logic:setSelectedMatch( match )
    onRequestSuccess( config )
--]]
end

function onRequestSuccess( response )
    local MarketsForGameData = require("scripts.data.MarketsForGameData").MarketsForGameData
    
    local marketInfo = MarketsForGameData:new( response )

    Logic:setCurMarketInfo( marketInfo )
    
    if marketInfo:getNum() > 0 then
        local TappablePredictionScene = require("scripts.views.TappablePredictionScene")
        TappablePredictionScene.loadFrame()
    else
        RequestUtils.onRequestFailed( "You have completed this match." )
    end
end