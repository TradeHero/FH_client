module(..., package.seeall)

local Json = require("json")
local Constants = require("scripts.Constants")
local Logic = require("scripts.Logic").getInstance()
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local RequestUtils = require("scripts.RequestUtils")

local mCallback

function action( param )

    mCallback = param[1]

    local url = RequestUtils.GET_SPIN_RESULT

    local requestInfo = {}
    requestInfo.requestData = requestContentText
    requestInfo.url = url

     local handler = function( isSucceed, body, header, status, errorBuffer )
        RequestUtils.messageHandler( requestInfo, isSucceed, body, header, status, errorBuffer, RequestUtils.HTTP_200, true, onRequestSuccess )
    end

    local httpRequest = HttpRequestForLua:create( CCHttpRequest.kHttpGet )
    httpRequest:addHeader( Logic:getAuthSessionString() )
    httpRequest:sendHttpRequest( url, handler )
end

--[[
    response data structure: {"PrizeId":4,"PrizeName":"US$ 1.00","NumberOfLuckyDrawTicketsLeft":0}
--]]
function onRequestSuccess( jsonResponse )
    mCallback( jsonResponse["PrizeId"], jsonResponse["NumberOfLuckyDrawTicketsLeft"] )
end