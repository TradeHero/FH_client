module(..., package.seeall)

local Json = require("json")
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local Logic = require("scripts.Logic").getInstance()
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local RequestUtils = require("scripts.RequestUtils")


local mUserId = Logic:getUserId()
local mUserName = ""

function action( param )
    local historyMainScene = require("scripts.views.HistoryMainScene")
    if historyMainScene.isFrameShown() then
        return 
    end                                                             

	local step = 1
    
    mUserId = Logic:getUserId()
    if param ~= nil and param[1] ~= nil and param[2] ~= nil then
        mUserId = param[1]
        mUserName = param[2]
    end

	local url = RequestUtils.GET_COUPON_HISTORY_REST_CALL.."?userId="..mUserId.."&step="..step

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
    historyMainScene.loadFrame( mUserId, mUserName, couponHistory )
end