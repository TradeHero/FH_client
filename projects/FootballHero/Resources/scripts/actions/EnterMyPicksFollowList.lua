module(..., package.seeall)

local RequestUtils = require("scripts.RequestUtils")
local Logic = require("scripts.Logic").getInstance()

function action( param )
    local userId = param[1]
    local mType = param[2]
    local step = 1
    local url = RequestUtils.GET_COMPETITION_FOLLOW_REST_CALL .. "?userId=" ..userId .. "&type=" .. mType .. "&step=" .. step

    local requestInfo = {}
    requestInfo.requestData = ""
    requestInfo.recordResponse = false
    requestInfo.ignoreJsonDecodeError = true
    requestInfo.url = url

    local handler = function( isSucceed, body, header, status, errorBuffer )
        RequestUtils.messageHandler( requestInfo, isSucceed, body, header, status, errorBuffer, RequestUtils.HTTP_200, false, onRequestSuccess, onRequestFailed )
    end

    local httpRequest = HttpRequestForLua:create( CCHttpRequest.kHttpGet )
    httpRequest:addHeader( Logic:getAuthSessionString() )
    httpRequest:sendHttpRequest( url, handler )
end


function onRequestSuccess( jsonResponse )
    local FollowListScene = require("scripts.views.MyPicksFollowListScene")
    FollowListScene.loadFrame( jsonResponse )
end

function onRequestFailed( jsonResponse )
end
