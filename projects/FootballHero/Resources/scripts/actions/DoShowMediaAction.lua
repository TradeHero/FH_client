module(..., package.seeall)

local RequestUtils = require("scripts.RequestUtils")
local ConnectingMessage = require("scripts.views.ConnectingMessage")

local mTabID
local mCallback

function action( param )
    mTabID = param[1]
    mCallback = param[2]
 
    local url
    if mTabID == 1 then
        url = RequestUtils.CDN_SERVER_IP.."highlights.txt"
    elseif mTabID == 2 then
        url = RequestUtils.CDN_SERVER_IP.."videos.txt"
    end

    local requestInfo = {}
    requestInfo.requestData = ""
    requestInfo.url = url
    requestInfo.recordResponse = false

    local jsonResponseCache = RequestUtils.getResponseCache( url )
    if jsonResponseCache ~= nil then
        onRequestSuccess( jsonResponseCache )
    else
        local handler = function( isSucceed, body, header, status, errorBuffer )
            RequestUtils.messageHandler( requestInfo, isSucceed, body, header, status, errorBuffer, RequestUtils.HTTP_200, true, onRequestSuccess )
        end

        local httpRequest = HttpRequestForLua:create( CCHttpRequest.kHttpGet )
        httpRequest:sendHttpRequest( url, handler )

        ConnectingMessage.loadFrame()
    end
end

function onRequestSuccess( jsonResponse )
    mCallback( mTabID, jsonResponse )
end