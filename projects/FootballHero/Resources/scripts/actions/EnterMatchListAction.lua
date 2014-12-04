module(..., package.seeall)

local Json = require("json")
local RequestUtils = require("scripts.RequestUtils")
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local Logic = require("scripts.Logic").getInstance()
local Constants = require("scripts.Constants")

local mLeagueId
local mCheckShowMarketingMessage

function action( param )
    local leagueId = Logic:getStartLeagueId()
    if Logic:getPreviousLeagueSelected() ~= 0 then
        leagueId = Logic:getPreviousLeagueSelected()
    end

    if param ~= nil and param[1] ~= nil then
        leagueId = param[1]
    end
    if param ~= nil then
        mCheckShowMarketingMessage = param[2]
    else
        mCheckShowMarketingMessage = false
    end

    mLeagueId = leagueId

    Logic:setPreviousLeagueSelected( leagueId )

    -- Use a different URL for popular leagues (id == SpecialLeagueIds.MOST_POPULAR)
    local url;
    if mLeagueId == Constants.SpecialLeagueIds.MOST_POPULAR then
        url = RequestUtils.GET_POPULAR_UPCOMING_REST_CALL
    else
        url = RequestUtils.GET_UPCOMING_GAMES_BY_LEAGUE_REST_CALL.."?leagueId="..leagueId
    end

    local requestInfo = {}
    requestInfo.requestData = ""
    requestInfo.url = url
    requestInfo.recordResponse = true

    local jsonResponseCache = RequestUtils.getResponseCache( url )
    if jsonResponseCache ~= nil then
        onRequestSuccess( jsonResponseCache )
    else

        local handler = function( isSucceed, body, header, status, errorBuffer )
            RequestUtils.messageHandler( requestInfo, isSucceed, body, header, status, errorBuffer, RequestUtils.HTTP_200, onRequestSuccess, onRequestFailed )
        end

        local httpRequest = HttpRequestForLua:create( CCHttpRequest.kHttpGet )
        httpRequest:addHeader( Logic:getAuthSessionString() )
        httpRequest:sendHttpRequest( url, handler )

        ConnectingMessage.loadFrame()
    end
--[[
    local JsonConfigReader = require("scripts.config.JsonConfigReader")
    local config = JsonConfigReader.read( "config/matchList.json" )
    onRequestSuccess( config )
--]]
end

function onRequestSuccess( matchList )
    local MatchListData = require("scripts.data.MatchListData").MatchListData

    if mLeagueId ~= Constants.SpecialLeagueIds.MOST_POPULAR then
        -- Sort the match according to its start time.
        local currentTime = os.time()
        local currentDate = os.time{year=os.date("%Y", currentTime), month=os.date("%m", currentTime), day=os.date("%d", currentTime), hour=0}
        table.sort( matchList, function ( n1, n2 )
            if n1["StartTime"] < n2["StartTime"] then
                if n2["StartTime"] < currentDate then
                    return false
                elseif n1["StartTime"] < currentDate then
                    return false
                else
                    return true
                end
            elseif  n1["StartTime"] > n2["StartTime"] then
                if n1["StartTime"] < currentDate then
                    return true
                elseif n2["StartTime"] < currentDate then
                    return true
                else
                    return false
                end
            else
                return false
            end
        end )
    end

    -- Group and sort.
    local sortedMatchList = MatchListData:new()
    for k,v in pairs( matchList ) do
        sortedMatchList:addMatch( v )
    end

	local matchListScene = require("scripts.views.MatchListScene")
    if matchListScene.isShown() then
        matchListScene.initMatchList( sortedMatchList, mLeagueId )
    else
        matchListScene.loadFrame( sortedMatchList, mLeagueId )
    end
    
    if mCheckShowMarketingMessage then
        EventManager:postEvent( Event.Show_Marketing_Message, { mLeagueId } )
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
        matchListScene.loadFrame( matchList, mLeagueId )
    end
    
    EventManager:postEvent( Event.Show_Error_Message, { errorBuffer } )
end