module(..., package.seeall)

local Json = require("json")
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local Logic = require("scripts.Logic").getInstance()
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local RequestUtils = require("scripts.RequestUtils")

function action( param )
    local step = param[1]
    local competitionId = param[2]
    local userId = param[3]
    local additionalParam = param[4]
    
    local url = RequestUtils.GET_COUPON_HISTORY_REST_CALL.."?userId="..userId.."&step="..step
    if competitionId ~= nil then
        url = url.."&competitionId="..competitionId
    end
    if additionalParam ~= nil then
        url = url..additionalParam
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

    --ConnectingMessage.loadFrame()
end

function onRequestSuccess( response )
    local CouponHistoryData = require("scripts.data.CouponHistoryData").CouponHistoryData
    local couponHistory = CouponHistoryData:new( response )
    
    local historyMainScene = require("scripts.views.HistoryMainScene")
    historyMainScene.loadMoreContent( couponHistory )
end