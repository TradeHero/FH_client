module(..., package.seeall)

local Json = require("json")
local RequestUtils = require("scripts.RequestUtils")
local Logic = require("scripts.Logic").getInstance()

local mJsonResponse

function action( param )
    local url = RequestUtils.GET_ADD_TICKET .. "?productId=" .. param[1]

    local requestInfo = {}
    requestInfo.requestData = ""
    requestInfo.url = url
    local handler = function( isSucceed, body, header, status, errorBuffer )
        RequestUtils.messageHandler( requestInfo, isSucceed, body, header, status, errorBuffer, RequestUtils.HTTP_200, false, onRequestSuccess )
    end

    local httpRequest = HttpRequestForLua:create( CCHttpRequest.kHttpGet )
    httpRequest:addHeader( Logic:getAuthSessionString() )
    httpRequest:sendHttpRequest( url, handler )
end


function onRequestSuccess( jsonResponse )
    local balance = jsonResponse["SpAmount"]
    local tickets = jsonResponse["TicketAmount"]
    Logic:setBalance( balance + Logic:getBalance() )
    Logic:setTicket( tickets + Logic:getTicket() )
end
