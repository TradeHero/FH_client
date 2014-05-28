module(..., package.seeall)

local Json = require("json")
local RequestUtils = require("scripts.RequestUtils")
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local Logic = require("scripts.Logic").getInstance()

function action( param )
    local leagueId = Logic:getStartLeagueId()
    if Logic:getPreviousLeagueSelected() > 0 then
        leagueId = Logic:getPreviousLeagueSelected()
    end

    if param ~= nil and param[1] ~= nil then
        leagueId = param[1]
    end

    Logic:setPreviousLeagueSelected( leagueId )

    local url = RequestUtils.GET_UPCOMING_GAMES_BY_LEAGUE_REST_CALL.."?leagueId="..leagueId

    local requestInfo = {}
    requestInfo.requestData = ""
    requestInfo.url = url

    local handler = function( isSucceed, body, header, status, errorBuffer )
        RequestUtils.messageHandler( requestInfo, isSucceed, body, header, status, errorBuffer, RequestUtils.HTTP_200, onRequestSuccess, onRequestFailed )
    end

    local httpRequest = HttpRequestForLua:create( CCHttpRequest.kHttpGet )
    httpRequest:addHeader( Logic:getAuthSessionString() )
    httpRequest:sendHttpRequest( url, handler )

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

function onRequestFailed( jsonResponse )
    local errorBuffer = jsonResponse["Message"]
    local MatchListData = require("scripts.data.MatchListData").MatchListData
    local matchList = MatchListData:new()
    local matchListScene = require("scripts.views.MatchListScene")
    if matchListScene.isShown() then
        matchListScene.initMatchList( matchList )
    else
        matchListScene.loadFrame( matchList )
    end
    
    EventManager:postEvent( Event.Show_Error_Message, { errorBuffer } )
end