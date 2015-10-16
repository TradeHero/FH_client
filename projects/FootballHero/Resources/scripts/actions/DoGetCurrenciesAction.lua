module(..., package.seeall)

local RequestUtils = require("scripts.RequestUtils")
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local Logic = require("scripts.Logic").getInstance()
local FriendReferalScene = require("scripts.views.FriendReferalScene")

local mCallback


function action( param )
    local mCallback = param[1]
    mCallback(100, 100)
    -- local url = RequestUtils.GET_FRIEND_REFERAL_REST_CALL .. "?referralType=" .. referralType
    -- CCLuaLog ("GET_FRIEND_REFERAL_REST_CALL:" .. url)
   
    -- local requestInfo = {}
    -- requestInfo.requestData = ""
    -- requestInfo.url = url

    -- local handler = function( isSucceed, body, header, status, errorBuffer )
    --     RequestUtils.messageHandler( requestInfo, isSucceed, body, header, status, errorBuffer, RequestUtils.HTTP_200, true, onRequestSuccess )
    -- end

    -- local httpRequest = HttpRequestForLua:create( CCHttpRequest.kHttpGet )
    -- httpRequest:addHeader( Logic:getAuthSessionString() )
    -- httpRequest:sendHttpRequest( url, handler )

    -- ConnectingMessage.loadFrame()
end


function onRequestSuccess( jsonResponse )
    CCLuaLog ("onRequestSuccess:" .. jsonResponse["LeftFriendCount"] .. jsonResponse["TicketCount"] )
    mCallback(100, 100)
end

