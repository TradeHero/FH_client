module(..., package.seeall)

local Json = require("json")
local RequestUtils = require("scripts.RequestUtils")
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local Logic = require("scripts.Logic").getInstance()
local Constants = require("scripts.Constants")
local CommunityConfig = require("scripts.config.Community")
local LeaderboardConfig = require("scripts.config.Leaderboard")

local mTabID
local mLeaderboardId
local mSubType = LeaderboardConfig.LeaderboardSubType[1]

function action( param )

    mTabID = param[1]

    local url
    if mTabID == CommunityConfig.COMMUNITY_TAB_ID_COMPETITION then
        url = RequestUtils.GET_COMPETITION_LIST_REST_CALL
        url = url.."?showSpecial=true"
    elseif mTabID == CommunityConfig.COMMUNITY_TAB_ID_LEADERBOARD then

        mLeaderboardId = param[2]
        local leaderboardType = param[3]
        local minPrediction = param[4] or 1
        local step = 1

        url = LeaderboardConfig.LeaderboardType[mLeaderboardId]["request"]
        if LeaderboardConfig.LeaderboardSubType[leaderboardType] ~= nil then
            mSubType = LeaderboardConfig.LeaderboardSubType[leaderboardType]
        end

        url = url.."?sortType="..mSubType["sortType"].."&step="..step.."&perPage="..Constants.RANKINGS_PER_PAGE
        if minPrediction > 1 then
            url = url.."&numberOfCouponsRequired="..minPrediction
        end
    else
        url = RequestUtils.GET_COMPETITION_LIST_REST_CALL
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
            RequestUtils.messageHandler( requestInfo, isSucceed, body, header, status, errorBuffer, RequestUtils.HTTP_200, onRequestSuccess )
        end

        local httpRequest = HttpRequestForLua:create( CCHttpRequest.kHttpGet )
        httpRequest:addHeader( Logic:getAuthSessionString() )
        httpRequest:sendHttpRequest( url, handler )

        ConnectingMessage.loadFrame()
    end
end

function onRequestSuccess( jsonResponse )
    loadCommunityScene( jsonResponse )
end

function loadCommunityScene( jsonResponse )
    local communityScene = require("scripts.views.CommunityBaseScene")
    
    if communityScene.isShown() then
        communityScene.refreshFrame( jsonResponse, mTabID, mLeaderboardId, mSubType )
    else
        communityScene.loadFrame( jsonResponse, mTabID, mLeaderboardId, mSubType )
    end
end
