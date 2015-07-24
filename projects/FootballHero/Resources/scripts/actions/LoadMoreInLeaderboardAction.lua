module(..., package.seeall)

local Json = require("json")
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local RequestUtils = require("scripts.RequestUtils")
local LeaderboardConfig = require("scripts.config.Leaderboard")
local Logic = require("scripts.Logic").getInstance()
local Constants = require("scripts.Constants")
local SportsConfig = require("scripts.config.Sports")


local mLeaderboardId
local mSubType

function action( param )
	mLeaderboardId = param[1]
	mSubType = param[2]
	local step = param[3]
    local minPrediction = param[4] or 1

    local url = LeaderboardConfig.LeaderboardType[mLeaderboardId]["request"].."?sortType="..mSubType["sortType"].."&step="..step.."&perPage="..Constants.RANKINGS_PER_PAGE
    if minPrediction > 1 then
        url = url.."&numberOfCouponsRequired="..minPrediction
    end

    url = SportsConfig.appendSportIdToURLHelper( url )

    local requestInfo = {}
    requestInfo.requestData = ""
    requestInfo.url = url
    requestInfo.recordResponse = true

    local jsonResponseCache = RequestUtils.getResponseCache( url )
    if jsonResponseCache ~= nil then
        onRequestSuccess( jsonResponseCache )
    else
        local handler = function( isSucceed, body, header, status, errorBuffer )
            RequestUtils.messageHandler( requestInfo, isSucceed, body, header, status, errorBuffer, RequestUtils.HTTP_200, true, onRequestSuccess )
        end

        local httpRequest = HttpRequestForLua:create( CCHttpRequest.kHttpGet )
        httpRequest:addHeader( Logic:getAuthSessionString() )
        httpRequest:sendHttpRequest( url, handler )

        ConnectingMessage.loadFrame()
    end
end

function onRequestSuccess( response )
    local communityLeaderboardFrame = require("scripts.views.CommunityLeaderboardFrame")
    communityLeaderboardFrame.loadMoreContent( response )
end