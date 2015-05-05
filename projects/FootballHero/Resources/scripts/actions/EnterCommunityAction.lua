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
local mJsonResponse

function action( param )

    if param ~= nil and param[1] ~= nil then
        mTabID = param[1]
    else
        mTabID = CommunityConfig.COMMUNITY_TAB_ID_COMPETITION
    end

    local url
    local needRequestHeader = true
    local record = false
    if mTabID == CommunityConfig.COMMUNITY_TAB_ID_COMPETITION then
        url = RequestUtils.GET_COMPETITION_LIST_REST_CALL
        url = url.."?showSpecial=true"

    elseif mTabID == CommunityConfig.COMMUNITY_TAB_ID_HIGHLIGHT then
        url = RequestUtils.CDN_SERVER_IP.."highlights.txt"
        needRequestHeader = false
    elseif 
        mTabID == CommunityConfig.COMMUNITY_TAB_ID_VIDEO then
        url = RequestUtils.CDN_SERVER_IP.."videos.txt"
        needRequestHeader = false
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
        record = true
    else
        url = RequestUtils.GET_COMPETITION_LIST_REST_CALL
    end

    local requestInfo = {}
    requestInfo.requestData = ""
    requestInfo.url = url
    requestInfo.recordResponse = record

    local jsonResponseCache = RequestUtils.getResponseCache( url )
    if jsonResponseCache ~= nil then
        onRequestSuccess( jsonResponseCache )
    else
        local handler = function( isSucceed, body, header, status, errorBuffer )
            RequestUtils.messageHandler( requestInfo, isSucceed, body, header, status, errorBuffer, RequestUtils.HTTP_200, true, onRequestSuccess )
        end

        local httpRequest = HttpRequestForLua:create( CCHttpRequest.kHttpGet )
        if needRequestHeader then
            httpRequest:addHeader( Logic:getAuthSessionString() )
        end
        httpRequest:sendHttpRequest( url, handler )

        ConnectingMessage.loadFrame()
    end
end

function onRequestSuccess( jsonResponse )
    if mTabID == CommunityConfig.COMMUNITY_TAB_ID_COMPETITION then
        mJsonResponse = jsonResponse
        -- check for minigame info
        if Constants.MINIGAME_PK_ENABLED then
            doMinigameRequest()
        else
            loadCommunityScene( jsonResponse )
        end
    else
        loadCommunityScene( jsonResponse )
    end
end

function loadCommunityScene( jsonResponse, minigameResponse )
    local communityScene = require("scripts.views.CommunityBaseScene")
    
    if communityScene.isShown() then
        communityScene.refreshFrame( jsonResponse, mTabID, mLeaderboardId, mSubType, minigameResponse )
    else
        communityScene.loadFrame( jsonResponse, mTabID, mLeaderboardId, mSubType, minigameResponse )
    end
end

function doMinigameRequest()
    
    ConnectingMessage.loadFrame()
    
    local URL = RequestUtils.SHOOT_TO_WIN_GET_USER_COMPETITION_CALL..Logic:getUserId()
    local requestContent = {}
    local requestContentText = Json.encode( requestContent )

    local requestInfo = {}
    requestInfo.requestData = requestContentText
    requestInfo.url = URL

    local handler = function( isSucceed, body, header, status, errorBuffer )
        RequestUtils.messageHandler( requestInfo, isSucceed, body, header, status, errorBuffer, RequestUtils.HTTP_200, true, onMinigameRequestSuccess )
    end

    local httpRequest = HttpRequestForLua:create( CCHttpRequest.kHttpGet )
    httpRequest:addHeader( Logic:getAuthSessionString() )
    httpRequest:sendHttpRequest( URL, handler )
end

function onMinigameRequestSuccess( jsonResponse )
    loadCommunityScene( mJsonResponse, jsonResponse )
end
