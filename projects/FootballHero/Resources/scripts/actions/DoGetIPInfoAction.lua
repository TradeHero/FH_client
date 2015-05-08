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

    local url = "http://ipinfo.io/json"

    local requestInfo = {}
    requestInfo.requestData = ""
    requestInfo.recordResponse = false
    requestInfo.ignoreJsonDecodeError = true
    requestInfo.url = url

    local handler = function( isSucceed, body, header, status, errorBuffer )
        RequestUtils.messageHandler( requestInfo, isSucceed, body, header, status, errorBuffer, RequestUtils.HTTP_200, false, onRequestSuccess, onRequestFailed )
    end

    local httpRequest = HttpRequestForLua:create( CCHttpRequest.kHttpGet )
    httpRequest:sendHttpRequest( url, handler )
end

function onRequestSuccess( jsonResponse )
    mCallback( true, jsonResponse )
end

function onRequestFailed( jsonResponse )
    mCallback( false, jsonResponse )
end

--[[
    response data structure: 
{
    "ip": "101.231.88.242",
    "hostname": "No Hostname",
    "city": "Shanghai",
    "region": "Shanghai",
    "country": "CN",
    "loc": "31.0456,121.3997",
    "org": "AS4812 China Telecom (Group)"
}
--]]
