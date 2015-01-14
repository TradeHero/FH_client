module(..., package.seeall)

local Json = require("json")
local Constants = require("scripts.Constants")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local RequestUtils = require("scripts.RequestUtils")
local Logic = require("scripts.Logic").getInstance()
local PushNotificationManager = require("scripts.PushNotificationManager")


local mSuccessCallback
local mCallback

function action( param )
    local email = param[1]
    local emailConfirm = param[2]
    local amount = param[3]
    mCallback = param[4]

    if email == nil or string.len( email ) == 0 or emailConfirm == nil or string.len( emailConfirm ) == 0 then
        RequestUtils.onRequestFailed( Constants.String.error.blank_email )
        return
    end

    if email ~= emailConfirm then
        RequestUtils.onRequestFailed( Constants.String.error.email_not_match )
        return
    end

    local requestContent = { PaypalEmailAddress = email, Amount = amount }
    local requestContentText = Json.encode( requestContent )
    
    local url = RequestUtils.POST_SPIN_PAYOUT_REST_CALL

    local requestInfo = {}
    requestInfo.requestData = requestContentText
    requestInfo.url = url

     local handler = function( isSucceed, body, header, status, errorBuffer )
        RequestUtils.messageHandler( requestInfo, isSucceed, body, header, status, errorBuffer, RequestUtils.HTTP_200, true, onRequestSuccess )
    end

    local httpRequest = HttpRequestForLua:create( CCHttpRequest.kHttpPost )
    httpRequest:addHeader( Constants.CONTENT_TYPE_JSON )
    httpRequest:addHeader( Logic:getAuthSessionString() )
    httpRequest:getRequest():setRequestData( requestContentText, string.len( requestContentText ) )
    httpRequest:sendHttpRequest( url, handler )

    ConnectingMessage.loadFrame()
end

--[[
    response data structure:
    {"RealMoneyBalance":0.0,"NumberOfLuckyDrawTickets":1,"NumberOfLuckDrawTicketsLeft":3487,"NumberOfLuckyDrawTicketsEachRound":3500,"LuckyDrawEmail":null}
--]]
function onRequestSuccess( jsonResponse )
    local newBalance = jsonResponse["RealMoneyBalance"]
    mCallback( newBalance )
end