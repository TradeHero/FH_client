module(..., package.seeall)

local ConnectingMessage = require("scripts.views.ConnectingMessage")
local RequestUtils = require("scripts.RequestUtils")
local Logic = require("scripts.Logic").getInstance()

local mStep

function action( param )
    mStep = 1
    if param ~= nil and param[1] ~= nil then
        mStep = param[1]
    end
    local url = RequestUtils.GET_TIMELINE_REST_CALL.."?step="..mStep
   
    local requestInfo = {}
    requestInfo.requestData = ""
    requestInfo.url = url
    local handler = function( isSucceed, body, header, status, errorBuffer )
        RequestUtils.messageHandler( requestInfo, isSucceed, body, header, status, errorBuffer, RequestUtils.HTTP_200, false, onRequestSuccess )
    end

    local httpRequest = HttpRequestForLua:create( CCHttpRequest.kHttpGet )
    httpRequest:addHeader( Logic:getAuthSessionString() )
    httpRequest:sendHttpRequest( url, handler )

--    ConnectingMessage.loadFrame()
end

function onRequestSuccess( jsonResponse )
    local CommunityTimelineFrame = require("scripts.views.CommunityTimelineFrame")
    if mStep == 1 then
        CommunityTimelineFrame.refreshFrame( jsonResponse )
    else
        CommunityTimelineFrame.loadMoreContent( jsonResponse )
    end
end
