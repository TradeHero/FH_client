module(..., package.seeall)

local Json = require("json")
local RequestUtils = require("scripts.RequestUtils")
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local Logic = require("scripts.Logic").getInstance()
local LeaderboardConfig = require("scripts.config.Leaderboard")
local CompetitionDetail = require("scripts.data.CompetitionDetail").CompetitionDetail
local CompetitionConfig = require("scripts.data.Competitions")

local competitionId
local showRequestPush
local mTabID
local mSortType

function action( param )
    local url = RequestUtils.GET_COMPETITION_DETAIL_REST_CALL

    local step = 1
    mSortType = param[3] or 1
    competitionId = param[1]
    showRequestPush = param[2] or false
    mTabID = param[4] or CompetitionConfig.COMPETITION_TAB_ID_OVERALL

    url = url.."?competitionId="..competitionId.."&sortType="..mSortType.."&step="..step
    if RequestUtils.USE_DEV then
        url = url.."&useDev=true"
    end

    local requestInfo = {}
    requestInfo.requestData = ""
    requestInfo.url = url

    local handler = function( isSucceed, body, header, status, errorBuffer )
        RequestUtils.messageHandler( requestInfo, isSucceed, body, header, status, errorBuffer, RequestUtils.HTTP_200, onRequestSuccess )
    end

    local httpRequest = HttpRequestForLua:create( CCHttpRequest.kHttpGet )
    httpRequest:addHeader( Logic:getAuthSessionString() )
    httpRequest:sendHttpRequest( url, handler )

    ConnectingMessage.loadFrame()
end

function onRequestSuccess( jsonResponse )
    local competitionDetail = CompetitionDetail:new( jsonResponse )
    Logic:setCompetitionDetail( competitionDetail )

    local CompetitionDetailScene = require("scripts.views.CompetitionDetailScene")
    if CompetitionDetailScene:isShown() then
        CompetitionDetailScene.refreshFrame( mTabID )
    else
        CompetitionDetailScene.loadFrame( LeaderboardConfig.LeaderboardSubType[mSortType], competitionId, showRequestPush, mTabID )
    end
end