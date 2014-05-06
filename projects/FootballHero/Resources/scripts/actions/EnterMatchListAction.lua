module(..., package.seeall)

local ConnectingMessage = require("scripts.views.ConnectingMessage")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList

function action( param )
    local leagueId = 1
    if param ~= nil and param[1] ~= nil then
        leagueId = param[1]
    end

    local Json = require("json")
	local RequestUtils = require("scripts.RequestUtils")

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
    httpRequest:sendHttpRequest( RequestUtils.GET_UPCOMING_GAMES_BY_LEAGUE_REST_CALL.."?leagueId="..leagueId, handler )

    ConnectingMessage.loadFrame()

--[[
    local JsonConfigReader = require("scripts.config.JsonConfigReader")
    local config = JsonConfigReader.read( "config/matchList.json" )
    onRequestSuccess( config )
--]]
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
    if matchListScene.isShown() then
        matchListScene.initMatchList( sortedMatchList )
    else
        matchListScene.loadFrame( sortedMatchList )
    end
    
end

function onRequestFailed( errorBuffer )
    EventManager:postEvent( Event.Show_Error_Message, { errorBuffer } )
end