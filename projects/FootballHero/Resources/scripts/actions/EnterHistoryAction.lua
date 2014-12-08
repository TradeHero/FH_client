module(..., package.seeall)

local Json = require("json")
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local Logic = require("scripts.Logic").getInstance()
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local RequestUtils = require("scripts.RequestUtils")
local Constants = require("scripts.Constants")


local mUserId = Logic:getUserId()
local mUserName = ""
local mCompetitionId = nil
local mAdditionalParam
local mCountryFilter = Constants.STATS_SHOW_ALL

--[[
    param[1] is the user id, default is show myself.
    param[2] is the user name, default is show myself.
    param[3] is the competition id, default is nil which means show the life time history.
    param[4] is the weekly/monthly paramters, default is empty which means show the overall history.
    param[5] is the country filter, default is show_all.
]]

function action( param )
    local historyMainScene = require("scripts.views.HistoryMainScene")
    -- if historyMainScene.isFrameShown() then
    --     EventManager:popHistoryWithoutExec()
    --     return
    -- end                                                             

	local step = 1
    
    mUserId = Logic:getUserId()
    if param ~= nil and param[1] ~= nil and param[2] ~= nil then
        mUserId = param[1]
        mUserName = param[2]
    end

	local url = RequestUtils.GET_COUPON_HISTORY_REST_CALL.."?userId="..mUserId.."&step="..step
    if param ~= nil and param[3] ~= nil then
        mCompetitionId = param[3]
        url = url.."&competitionId="..mCompetitionId
    else
        mCompetitionId = nil
    end

    mAdditionalParam = nil
    if param ~= nil and param[4] ~= nil then
        mAdditionalParam = param[4]
        url = url..mAdditionalParam
    end

    mCountryFilter = Constants.STATS_SHOW_ALL
    if param ~= nil and param[5] ~= nil and param[5] ~= Constants.STATS_SHOW_ALL then
        mCountryFilter = param[5]
        url = url.."&countryId="..mCountryFilter
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

function onRequestSuccess( response )
    local CouponHistoryData = require("scripts.data.CouponHistoryData").CouponHistoryData
    local couponHistory = CouponHistoryData:new( response )
    
    local historyMainScene = require("scripts.views.HistoryMainScene")
    if historyMainScene:isFrameShown() then
        historyMainScene.refreshFrame( mUserId, mUserName, mCompetitionId, couponHistory, mAdditionalParam, mCountryFilter )
    else
        historyMainScene.loadFrame( mUserId, mUserName, mCompetitionId, couponHistory, mAdditionalParam, mCountryFilter )
    end
end