module(..., package.seeall)

local Json = require("json")
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local Logic = require("scripts.Logic").getInstance()
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local RequestUtils = require("scripts.RequestUtils")
local Constants = require("scripts.Constants")


local mUserId 

function action( param )
    local historyMainScene = require("scripts.views.HistoryMainScene")

	local step = 1
    
    mUserId = param[1]

	local url = RequestUtils.GET_COMPETITION_EXPERT_HISTORY_REST_CALL.."?expertId="..mUserId.."&step="..step

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
    local CouponHistoryData = require("scripts.data.CouponHistoryData").CouponHistoryData
    local couponHistory = CouponHistoryData:new( response )
    
    local historyMainScene = require("scripts.views.HistoryMainScene")
    if historyMainScene:isFrameShown() then
        historyMainScene.refreshFrame( mUserId, nil, couponHistory, "Expert", Constants.STATS_SHOW_ALL )
    else
        historyMainScene.loadFrame( mUserId, nil, couponHistory, "Expert", Constants.STATS_SHOW_ALL )
    end
end