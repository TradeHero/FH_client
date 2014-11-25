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
local Constants = require("scripts.Constants")

local competitionId
local showRequestPush
local mTabID
local mSortType
local mWeekNumber
local mMonthNumber
local mYearNumber

function action( param )
    local url = RequestUtils.GET_COMPETITION_DETAIL_REST_CALL

    local step = 1
    mSortType = param[3] or 1
    competitionId = param[1]
    showRequestPush = param[2] or false
    mTabID = param[4] or CompetitionConfig.COMPETITION_TAB_ID_OVERALL

    url = url.."?competitionId="..competitionId.."&sortType="..mSortType.."&step="..step.."&perPage="..Constants.RANKINGS_PER_PAGE
    if RequestUtils.USE_DEV then
        url = url.."&useDev=true"
    end

    local nowTime = os.time()
    mYearNumber = os.date( "%Y", nowTime )
    mMonthNumber = os.date( "%m", nowTime )
    mWeekNumber = os.date( "%W", nowTime )

    if mTabID == CompetitionConfig.COMPETITION_TAB_ID_MONTHLY then
        if param[5] ~= nil then
            print ("monthly param 5 not nil")
            mYearNumber = param[5]
            mMonthNumber = param[6]
        end

        url = url.."&yearNumber="..mYearNumber.."&monthNumber="..mMonthNumber

    elseif mTabID == CompetitionConfig.COMPETITION_TAB_ID_WEEKLY then
        
        if param[5] ~= nil then
            print ("weekly param 5 not nil")
            mYearNumber = param[5]
            mWeekNumber = param[6]
        end

        url = url.."&yearNumber="..mYearNumber.."&weekNumber="..mWeekNumber
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
    if CompetitionDetailScene.isShown() then
        CompetitionDetailScene.refreshFrame( mTabID, mYearNumber, mMonthNumber, mWeekNumber )
    else
        CompetitionDetailScene.loadFrame( LeaderboardConfig.LeaderboardSubType[mSortType], competitionId, showRequestPush, mTabID, mYearNumber, mMonthNumber, mWeekNumber )
    end
end