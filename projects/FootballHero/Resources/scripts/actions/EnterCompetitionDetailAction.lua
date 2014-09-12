module(..., package.seeall)

local Json = require("json")
local RequestUtils = require("scripts.RequestUtils")
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local Logic = require("scripts.Logic").getInstance()
local LeaderboardConfig = require("scripts.config.Leaderboard")
local CompetitionDetail = require("scripts.data.CompetitionDetail").CompetitionDetail

local competitionId
local showRequestPush

function action( param )
    local url = RequestUtils.GET_COMPETITION_DETAIL_REST_CALL

    local step = 1
    local sortType = 1
    competitionId = param[1]
    showRequestPush = param[2] or false

    url = url.."?competitionId="..competitionId.."&sortType="..sortType.."&step="..step
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
    CompetitionDetailScene.loadFrame( LeaderboardConfig.LeaderboardSubType[1], competitionId, showRequestPush )
end