module(..., package.seeall)

local Json = require("json")
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local Logic = require("scripts.Logic").getInstance()
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local RequestUtils = require("scripts.RequestUtils")
local CompetitionDetail = require("scripts.data.CompetitionDetail").CompetitionDetail
local CompetitionConfig = require("scripts.data.Competitions")
local Constants = require("scripts.Constants")

local mTabID

function action( param )
    local url = RequestUtils.GET_COMPETITION_DETAIL_REST_CALL

    local competitionId = param[1]
    local step = param[2]
    local sortType = param[3] or 1
    mTabID = param[4] or CompetitionConfig.COMPETITION_TAB_ID_OVERALL
    
    url = url.."?competitionId="..competitionId.."&sortType="..sortType.."&step="..step.."&perPage="..Constants.RANKINGS_PER_PAGE

    local nowTime = os.time()
    mYearNumber = os.date( "%Y", nowTime )
    mMonthNumber = os.date( "%m", nowTime )
    mWeekNumber = os.date( "%W", nowTime ) + 1      -- Lua calculate week number worngly. It is one behind.

    if mTabID == CompetitionConfig.COMPETITION_TAB_ID_MONTHLY then
        if param[5] ~= nil then
            mYearNumber = param[5]
            mMonthNumber = param[6]
        end

        url = url.."&yearNumber="..mYearNumber.."&monthNumber="..mMonthNumber

    elseif mTabID == CompetitionConfig.COMPETITION_TAB_ID_WEEKLY then
        
        if param[5] ~= nil then
            mYearNumber = param[5]
            mWeekNumber = param[6]
        end

        url = url.."&yearNumber="..mYearNumber.."&weekNumber="..mWeekNumber
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
            RequestUtils.messageHandler( requestInfo, isSucceed, body, header, status, errorBuffer, RequestUtils.HTTP_200, true, onRequestSuccess )
        end

        local httpRequest = HttpRequestForLua:create( CCHttpRequest.kHttpGet )
        httpRequest:addHeader( Logic:getAuthSessionString() )
        httpRequest:sendHttpRequest( url, handler )

        ConnectingMessage.loadFrame()
    end
end

function onRequestSuccess( jsonResponse )
    local competitionDetail = CompetitionDetail:new( jsonResponse )

    local CompetitionDetailScene = require("scripts.views.CompetitionDetailScene")
    CompetitionDetailScene.loadMoreContent( competitionDetail:getDto() )
end