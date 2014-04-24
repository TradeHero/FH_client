module(..., package.seeall)

local ConnectingMessage = require("scripts.views.ConnectingMessage")
local JsonConfigReader = require("scripts.config.JsonConfigReader")

function action( param )
--[[
    local Json = require("json")
	local RequestConstants = require("scripts.RequestConstants")

    local handler = function( isSucceed, body, header, status, errorBuffer )
        print( "Http reponse: "..status.." and errorBuffer: "..errorBuffer )
        print( "Http reponse body: "..body )
        local jsonResponse = Json.decode( body )
        ConnectingMessage.selfRemove()
        if status == RequestConstants.HTTP_200 then
            onRequestSuccess( jsonResponse )
        else
            onRequestFailed( jsonResponse["Message"] )
        end
    end

    local httpRequest = HttpRequestForLua:create( CCHttpRequest.kHttpGet, "Content-Type: application/json" )
    httpRequest:sendHttpRequest( RequestConstants.GET_ALL_UPCOMING_GAMES_REST_CALL, handler )

    ConnectingMessage.loadFrame()
--]]
    local config = JsonConfigReader.read( "config/matchList.json" )
    onRequestSuccess( config )
end

function onRequestSuccess( matchList )
    local MatchListData = require("scripts.data.MatchListData").MatchListData

    -- Sort the match according to its start time.
    table.sort( matchList, function (n1, n2)
        return n1["StartTime"] < n2["StartTime"]
    end )

    -- Group and sort.
    local sortedMatchList = MatchListData:new()
    for k,v in pairs( matchList ) do
        sortedMatchList:addMatch( v )
    end

	local matchListScene = require("scripts.views.MatchListScene")
    matchListScene.loadFrame( sortedMatchList )
end