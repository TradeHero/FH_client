module(..., package.seeall)

local Json = require("json")
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local Logic = require("scripts.Logic").getInstance()
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local RequestUtils = require("scripts.RequestUtils")
local Constants = require("scripts.Constants")

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
	for i = 1, table.getn( games ) do
		local game = games[i]
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

    local liveScoreScene = require( "scripts.views.LiveScoreScene" )
    if liveScoreScene.isFrameShown() ~= true then
        liveScoreScene.loadFrame( groupedLeagueInfo, mDayOffset )
    else
    	liveScoreScene.refreshFrame( groupedLeagueInfo, mDayOffset )
    end
end

--[[
	{

   "Games": [

      {

         "Id": 292904,

         "LeagueId": 148,

         "Status": null,

         "Minute": 0,

         "HomeTeamId": 13482,

         "HomeGoals": 0,

         "HomeRedCards": 0,

         "AwayTeamId": 13247,

         "AwayGoals": 0,

         "AwayRedCards": 0

      },

      {

         "Id": 292905,

         "LeagueId": 148,

         "Status": null,

         "Minute": 0,

         "HomeTeamId": 13481,

         "HomeGoals": 0,

         "HomeRedCards": 0,

         "AwayTeamId": 13602,

         "AwayGoals": 0,

         "AwayRedCards": 0

      },

      {

         "Id": 292906,

         "LeagueId": 148,

         "Status": null,

         "Minute": 0,

         "HomeTeamId": 1155,

         "HomeGoals": 0,

         "HomeRedCards": 0,

         "AwayTeamId": 13603,

         "AwayGoals": 0,

         "AwayRedCards": 0

      }

   ]

}

--]]