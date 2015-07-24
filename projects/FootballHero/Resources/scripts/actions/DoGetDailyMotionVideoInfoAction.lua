module(..., package.seeall)

local Json = require("json")
local Constants = require("scripts.Constants")
local Logic = require("scripts.Logic").getInstance()
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local RequestUtils = require("scripts.RequestUtils")

function action( param )
    local videoUrl = param[1]
    local callback = param[2]

    local url = "http://www.dailymotion.com/services/oembed?url="..videoUrl

    local requestInfo = {}
    requestInfo.requestData = ""
    requestInfo.recordResponse = true
    requestInfo.ignoreJsonDecodeError = true
    requestInfo.url = url

    local onRequestSuccess = function ( jsonResponse )
        callback( true, jsonResponse )
    end

    local onRequestFailed = function ( jsonResponse )
        callback( false, jsonResponse )
    end

    local jsonResponseCache = RequestUtils.getResponseCache( url )
    if jsonResponseCache ~= nil then
        onRequestSuccess( jsonResponseCache )
    else
        local handler = function( isSucceed, body, header, status, errorBuffer )
            RequestUtils.messageHandler( requestInfo, isSucceed, body, header, status, errorBuffer, RequestUtils.HTTP_200, false, onRequestSuccess, onRequestFailed )
        end

        local httpRequest = HttpRequestForLua:create( CCHttpRequest.kHttpGet )
        httpRequest:setPriority( CCHttpRequest.pVeryLow )
        httpRequest:sendHttpRequest( url, handler )
    end   
end

--[[
    response data structure: 
    {
    "type": "video",
    "version": "1.0",
    "provider_name": "Dailymotion",
    "provider_url": "http://www.dailymotion.com",
    "title": "HD Everton Football Club 3-0 Manchester United ALL GOALS",
    "author_name": "FIML - Football is my life",
    "author_url": "http://www.dailymotion.com/FIML",
    "width": 480,
    "height": 271,
    "html": "<iframe src=\"http://www.dailymotion.com/embed/video/x2o25fz\" width=\"480\" height=\"271\" frameborder=\"0\" allowfullscreen></iframe>",
    "thumbnail_url": "http://s2.dmcdn.net/KLe5Z/x240-U2n.jpg",
    "thumbnail_width": 424,
    "thumbnail_height": 240
}
--]]
