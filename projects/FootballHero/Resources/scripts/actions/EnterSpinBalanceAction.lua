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
    {

   "RealMoneyBalance": 8,

   "LuckyDrawEmail": null,

   "DrawTicketBalances": [

      {

         "PrizeId": 8,

         "NumberOfLuckyDrawTickets": 3,

         "NumberOfLuckDrawTicketsLeft": 3492,

         "NumberOfLuckyDrawTicketsEachRound": 3500

      },

      {

         "PrizeId": 12,

         "NumberOfLuckyDrawTickets": 3,

         "NumberOfLuckDrawTicketsLeft": 3496,

         "NumberOfLuckyDrawTicketsEachRound": 3500

      }
   ]
}
--]]

function onRequestSuccess( jsonResponse )
    local moneyBalance = jsonResponse["RealMoneyBalance"]
    local luckyDrawEmail = jsonResponse["LuckyDrawEmail"]
    local ticketBalance = jsonResponse["DrawTicketBalances"]

    local SpinBalanceScene = require("scripts.views.SpinBalanceScene")
    SpinBalanceScene.loadFrame( moneyBalance, ticketBalance, luckyDrawEmail )
end
