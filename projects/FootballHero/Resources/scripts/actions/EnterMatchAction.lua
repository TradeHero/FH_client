module(..., package.seeall)

local Json = require("json")
local ConnectingMessage = require("scripts.views.ConnectingMessage")

function action( param )

	local RequestConstants = require("scripts.RequestConstants")
    local Logic = require("scripts.Logic").getInstance()

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

    local httpRequest = HttpRequestForLua:create( CCHttpRequest.kHttpGet, "Content-Type: application/json" )
    httpRequest:sendHttpRequest( RequestConstants.GET_GAME_MARKETS_REST_CALL.."?gameId="..matchId, handler )

    ConnectingMessage.loadFrame()

end

function onRequestSuccess( response )
    local MarketsForGameData = require("scripts.data.MarketsForGameData").MarketsForGameData
    local matchPredictionScene = require("scripts.views.MatchPredictionScene")
    matchPredictionScene.loadFrame( MarketsForGameData:new( response ) )
end

function onRequestFailed( errorBuffer )
    EventManager:postEvent( Event.Show_Error_Message, { errorBuffer } )
end