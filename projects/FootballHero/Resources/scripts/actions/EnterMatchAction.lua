module(..., package.seeall)

local Json = require("json")
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local Logic = require("scripts.Logic").getInstance()


function action( param )

	local RequestConstants = require("scripts.RequestConstants")

    local matchId = Logic:getSelectedMatch()["Id"]

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
        if status == RequestConstants.HTTP_200 then
            onRequestSuccess( jsonResponse )
        else
            onRequestFailed( jsonResponse["Message"] )
        end
    end

    local httpRequest = HttpRequestForLua:create( CCHttpRequest.kHttpGet )
    httpRequest:sendHttpRequest( RequestConstants.GET_GAME_MARKETS_REST_CALL.."?gameId="..matchId, handler )

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
    local matchPredictionScene = require("scripts.views.MatchPredictionScene")
    local marketInfo = MarketsForGameData:new( response )

    Logic:setCurMarketInfo( marketInfo )
    matchPredictionScene.loadFrame( marketInfo:getMatchMarket() )
end

function onRequestFailed( errorBuffer )
    EventManager:postEvent( Event.Show_Error_Message, { errorBuffer } )
end