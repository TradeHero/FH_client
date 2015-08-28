module(..., package.seeall)

local RequestUtils = require("scripts.RequestUtils")
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local Logic = require("scripts.Logic").getInstance()

function action( param )
	local referralType = param[1]

    local url = RequestUtils.GET_FRIEND_REFERAL_REST_CALL .. "?referralType=" .. referralType
    CCLuaLog ("GET_FRIEND_REFERAL_REST_CALL:" .. url)
   
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


function onRequestSuccess( jsonResponse )
    CCLuaLog ("onRequestSuccess:" .. jsonResponse["LeftFriendCount"] .. jsonResponse["TicketCount"] )
end

