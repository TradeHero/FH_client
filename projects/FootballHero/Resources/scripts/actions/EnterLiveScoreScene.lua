module(..., package.seeall)

local Json = require("json")
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local Logic = require("scripts.Logic").getInstance()
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local RequestUtils = require("scripts.RequestUtils")
local Constants = require("scripts.Constants")
local LiveScoreConfig = require("scripts.config.LiveScore")

local mPreviousLiveGames
local mDayOffset

function action( param )

	mDayOffset = param[1]
	local isSilent = param[2]

	local url = RequestUtils.GET_LIVE_SCORE_REST_CALL.."?dayOffset="..mDayOffset

    local requestInfo = {}
    requestInfo.requestData = ""
    requestInfo.url = url

    local handler = function( isSucceed, body, header, status, errorBuffer )
        RequestUtils.messageHandler( requestInfo, isSucceed, body, header, status, errorBuffer, RequestUtils.HTTP_200, (not isSilent), onRequestSuccess )
    end

    local httpRequest = HttpRequestForLua:create( CCHttpRequest.kHttpGet )
    httpRequest:addHeader( Logic:getAuthSessionString() )
    httpRequest:sendHttpRequest( url, handler )

    if not isSilent then
    	ConnectingMessage.loadFrame()
    end
end

function onRequestSuccess( response )
	local games = response["Games"]
	local groupedLeagueInfo = {}
    local liveGames = {}
	for i = 1, table.getn( games ) do
		local game = games[i]
        -- Check if the game is Live now.
        local status = game["Status"]
        if status == LiveScoreConfig.STATUS_1ST_HALF or status == LiveScoreConfig.STATUS_2ND_HALF or
            status == LiveScoreConfig.STATUS_HALF_TIME or
            status == LiveScoreConfig.STATUS_1ST_OVERTIME or status == LiveScoreConfig.STATUS_2ND_OVERTIME then

            if mPreviousLiveGames then
                for i = 1, table.getn( mPreviousLiveGames ) do
                    local previousGame = mPreviousLiveGames[i]
                    if game["Id"] == previousGame["Id"] then
                        if game["HomeGoals"] > previousGame["HomeGoals"] then
                            game["HomeGoalsNew"] = 1
                        end
                        if game["AwayGoals"] > previousGame["AwayGoals"] then
                            game["AwayGoalsNew"] = 1
                        end
                        break
                    end
                end
            end

            table.insert( liveGames, game )
        else
            local leagueId = game["LeagueId"]
            local leagueInfo = nil

            for k,v in pairs( groupedLeagueInfo ) do
                if k == leagueId then
                    leagueInfo = v
                end
            end

            if leagueInfo == nil then
                leagueInfo = {}
                groupedLeagueInfo[leagueId] = leagueInfo
            end

            table.insert( leagueInfo, game )
        end		
	end

    local liveScoreScene = require( "scripts.views.LiveScoreScene" )
    if liveScoreScene.isFrameShown() ~= true then
        liveScoreScene.loadFrame( liveGames, groupedLeagueInfo, mDayOffset )
    else
    	liveScoreScene.refreshFrame( liveGames, groupedLeagueInfo, mDayOffset )
    end

    mPreviousLiveGames = liveGames
end

--[[
	{
    "Games": [
        {
            "Id": 222002,
            "LeagueId": 60,
            "StartTime": 1432918800,
            "Status": "NS",
            "Minute": 0,
            "HomeTeamId": 6116,
            "HomeGoals": 0,
            "HomeRedCards": 0,
            "AwayTeamId": 471,
            "AwayGoals": 0,
            "AwayRedCards": 0
        },
        {
            "Id": 222006,
            "LeagueId": 60,
            "StartTime": 1432918800,
            "Status": "NS",
            "Minute": 0,
            "HomeTeamId": 472,
            "HomeGoals": 0,
            "HomeRedCards": 0,
            "AwayTeamId": 466,
            "AwayGoals": 0,
            "AwayRedCards": 0
        },
        {
            "Id": 222008,
            "LeagueId": 60,
            "StartTime": 1432908000,
            "Status": "NS",
            "Minute": 0,
            "HomeTeamId": 463,
            "HomeGoals": 0,
            "HomeRedCards": 0,
            "AwayTeamId": 460,
            "AwayGoals": 0,
            "AwayRedCards": 0
        },
        {
            "Id": 222009,
            "LeagueId": 60,
            "StartTime": 1432918800,
            "Status": "NS",
            "Minute": 0,
            "HomeTeamId": 470,
            "HomeGoals": 0,
            "HomeRedCards": 0,
            "AwayTeamId": 461,
            "AwayGoals": 0,
            "AwayRedCards": 0
        },
        {
            "Id": 269387,
            "LeagueId": 960,
            "StartTime": 1432918800,
            "Status": "NS",
            "Minute": 0,
            "HomeTeamId": 12439,
            "HomeGoals": 0,
            "HomeRedCards": 0,
            "AwayTeamId": 12440,
            "AwayGoals": 0,
            "AwayRedCards": 0
        },
        {
            "Id": 284428,
            "LeagueId": 964,
            "StartTime": 1432918800,
            "Status": "NS",
            "Minute": 0,
            "HomeTeamId": 12486,
            "HomeGoals": 0,
            "HomeRedCards": 0,
            "AwayTeamId": 12482,
            "AwayGoals": 0,
            "AwayRedCards": 0
        },
        {
            "Id": 292454,
            "LeagueId": 1007,
            "StartTime": 1432899900,
            "Status": "NS",
            "Minute": 0,
            "HomeTeamId": 13315,
            "HomeGoals": 0,
            "HomeRedCards": 0,
            "AwayTeamId": 13298,
            "AwayGoals": 0,
            "AwayRedCards": 0
        },
        {
            "Id": 311203,
            "LeagueId": 911,
            "StartTime": 1432893600,
            "Status": "HT1",
            "Minute": 2,
            "HomeTeamId": 14300,
            "HomeGoals": 0,
            "HomeRedCards": 0,
            "AwayTeamId": 422,
            "AwayGoals": 0,
            "AwayRedCards": 0
        },
        {
            "Id": 311336,
            "LeagueId": 911,
            "StartTime": 1432859400,
            "Status": "",
            "Minute": 0,
            "HomeTeamId": 573,
            "HomeGoals": 0,
            "HomeRedCards": 0,
            "AwayTeamId": 231,
            "AwayGoals": 0,
            "AwayRedCards": 0
        },
        {
            "Id": 311351,
            "LeagueId": 101,
            "StartTime": 1432863600,
            "Status": "FT",
            "Minute": 0,
            "HomeTeamId": 806,
            "HomeGoals": 5,
            "HomeRedCards": 0,
            "AwayTeamId": 5656,
            "AwayGoals": 0,
            "AwayRedCards": 0
        },
        {
            "Id": 311427,
            "LeagueId": 911,
            "StartTime": 1432917000,
            "Status": "NS",
            "Minute": 0,
            "HomeTeamId": 22626,
            "HomeGoals": 0,
            "HomeRedCards": 0,
            "AwayTeamId": 275,
            "AwayGoals": 0,
            "AwayRedCards": 0
        }
    ]
}

--]]