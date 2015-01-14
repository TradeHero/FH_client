module(..., package.seeall)

local Json = require("json")
local RequestUtils = require("scripts.RequestUtils")
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local Logic = require("scripts.Logic").getInstance()
local Constants = require("scripts.Constants")

local mJsonResponse

function action( param )
    local url = RequestUtils.GET_SPIN_BALANCE_REST_CALL
   
    local requestInfo = {}
    requestInfo.requestData = ""
    requestInfo.url = url
    local handler = function( isSucceed, body, header, status, errorBuffer )
        RequestUtils.messageHandler( requestInfo, isSucceed, body, header, status, errorBuffer, RequestUtils.HTTP_200, true, onRequestSuccess )
    end

    local httpRequest = HttpRequestForLua:create( CCHttpRequest.kHttpGet )
    httpRequest:addHeader( Logic:getAuthSessionString() )
    httpRequest:sendHttpRequest( url, handler )

    ConnectingMessage.loadFrame()
end

--[[
    response data structure
    {"RealMoneyBalance":17.0,"NumberOfLuckyDrawTickets":1,"NumberOfLuckDrawTicketsLeft":3487,"NumberOfLuckyDrawTicketsEachRound":3500,"LuckyDrawEmail":null}
--]]

function onRequestSuccess( jsonResponse )
    local moneyBalance = jsonResponse["RealMoneyBalance"]
    local ticketBalance = jsonResponse["NumberOfLuckyDrawTickets"]

    local SpinBalanceScene = require("scripts.views.SpinBalanceScene")
    SpinBalanceScene.loadFrame( moneyBalance, ticketBalance )
end
