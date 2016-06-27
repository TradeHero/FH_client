module(..., package.seeall)

local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local Logic = require("scripts.Logic").getInstance()
local Json = require("json")
local Constants = require("scripts.Constants")
local RequestUtils = require("scripts.RequestUtils")

local mCallback

function action( param )
    local accessToken = param[1]
    mCallback = param[2]

    local requestContent = { FacebookToken = accessToken }
    local requestContentText = Json.encode( requestContent )
    
    local url = RequestUtils.POST_SHARE_SPIN_REST_CALL

    local requestInfo = {}
    requestInfo.requestData = requestContentText
    requestInfo.url = url

    local handler = function( isSucceed, body, header, status, errorBuffer )
        RequestUtils.messageHandler( requestInfo, isSucceed, body, header, status, errorBuffer, RequestUtils.HTTP_200, true, onRequestSuccess )
    end

    local httpRequest = HttpRequestForLua:create( CCHttpRequest.kHttpPost )
    httpRequest:addHeader( "Content-Type: application/json" )
    httpRequest:addHeader( Logic:getAuthSessionString() )
    httpRequest:getRequest():setRequestData( requestContentText, string.len( requestContentText ) )
    httpRequest:sendHttpRequest( url, handler )

    ConnectingMessage.loadFrame()
end

function onRequestSuccess( jsonResponse )
    local params = { Action = "share" }
    CCLuaLog("Send ANALYTICS_EVENT_SPINWHEEL: "..Json.encode( params ) )
    Analytics:sharedDelegate():postEvent( Constants.ANALYTICS_EVENT_SPINWHEEL, Json.encode( params ) )
    Analytics:sharedDelegate():postFlurryEvent( Constants.ANALYTICS_EVENT_SPINWHEEL, Json.encode( params ) )
    Analytics:sharedDelegate():postTongdaoEvent( Constants.ANALYTICS_EVENT_SPINWHEEL, Json.encode( params ) )

    mCallback( jsonResponse["GotExtraSpin"] )
end