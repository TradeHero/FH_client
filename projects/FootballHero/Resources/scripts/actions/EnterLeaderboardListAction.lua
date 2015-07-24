module(..., package.seeall)

local Json = require("json")
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local RequestUtils = require("scripts.RequestUtils")
local LeaderboardConfig = require("scripts.config.Leaderboard")
local Logic = require("scripts.Logic").getInstance()
local SportsConfig = require("scripts.config.Sports")


local mLeaderboardId
local mSubType = LeaderboardConfig.LeaderboardSubType[1]

function action( param )
	mLeaderboardId = param[1]
	local leaderboardType = param[2]
    local minPrediction = param[3] or 1
	local step = 1

	local url = LeaderboardConfig.LeaderboardType[mLeaderboardId]["request"]
	if LeaderboardConfig.LeaderboardSubType[leaderboardType] ~= nil then
		mSubType = LeaderboardConfig.LeaderboardSubType[leaderboardType]
	end

	url = url.."?sortType="..mSubType["sortType"].."&step="..step
    if minPrediction > 1 then
        url = url.."&numberOfCouponsRequired="..minPrediction
    end

    url = SportsConfig.appendSportIdToURLHelper( url )

    local requestInfo = {}
    requestInfo.requestData = ""
    requestInfo.url = url

	local handler = function( isSucceed, body, header, status, errorBuffer )
        RequestUtils.messageHandler( requestInfo, isSucceed, body, header, status, errorBuffer, RequestUtils.HTTP_200, true, onRequestSuccess )
    end

    local httpRequest = HttpRequestForLua:create( CCHttpRequest.kHttpGet )
    httpRequest:addHeader( Logic:getAuthSessionString() )
    httpRequest:sendHttpRequest( url, handler )

    ConnectingMessage.loadFrame()
end

function onRequestSuccess( response )
    local leaderboardListScene = require("scripts.views.LeaderboardListScene")

    if leaderboardListScene.isShown() then
    	leaderboardListScene.refreshFrame( response, mLeaderboardId, mSubType )
    else
    	leaderboardListScene.loadFrame( response, mLeaderboardId, mSubType )
    end
end