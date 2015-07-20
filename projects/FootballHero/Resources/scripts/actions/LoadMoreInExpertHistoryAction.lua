module(..., package.seeall)

local Json = require("json")
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local Logic = require("scripts.Logic").getInstance()
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local RequestUtils = require("scripts.RequestUtils")
local Constants = require("scripts.Constants")


function action( param )
    local step = param[1]
    local competitionId = param[2]
    local userId = param[3]
    local additionalParam = param[4]
    local countryFilter = param[5]
    
    local url = RequestUtils.GET_COMPETITION_EXPERT_HISTORY_REST_CALL.."?expertId="..userId.."&step="..step

    local requestInfo = {}
    requestInfo.requestData = ""
    requestInfo.url = url
    requestInfo.recordResponse = true

    local jsonResponseCache = RequestUtils.getResponseCache( url )
    if jsonResponseCache ~= nil then
        onRequestSuccess( jsonResponseCache )
    else
        local handler = function( isSucceed, body, header, status, errorBuffer )
            RequestUtils.messageHandler( requestInfo, isSucceed, body, header, status, errorBuffer, RequestUtils.HTTP_200, false, onRequestSuccess )
        end

        local httpRequest = HttpRequestForLua:create( CCHttpRequest.kHttpGet )
        httpRequest:addHeader( Logic:getAuthSessionString() )
        httpRequest:sendHttpRequest( url, handler )
        --ConnectingMessage.loadFrame()
    end
end

function onRequestSuccess( response )
    local CouponHistoryData = require("scripts.data.CouponHistoryData").CouponHistoryData
    local couponHistory = CouponHistoryData:new( response )
    
    local historyMainScene = require("scripts.views.HistoryMainScene")
    historyMainScene.loadMoreContent( couponHistory )
end