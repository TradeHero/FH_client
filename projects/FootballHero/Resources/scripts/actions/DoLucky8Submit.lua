module(..., package.seeall)

local Json = require("json")
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local Logic = require("scripts.Logic").getInstance()
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local RequestUtils = require("scripts.RequestUtils")
local Constants = require("scripts.Constants")

function requestSubmit( requestContentText )
    local url = RequestUtils.POST_LUCKY8_PREDICT
    local requestInfo = {}
    requestInfo.requestData = requestContentText
    requestInfo.url = url

    local handler = function ( isSucceed, body, header, status, errorBuffer )
        RequestUtils.messageHandler( requestInfo, isSucceed, body, header, status, errorBuffer, RequestUtils.HTTP_200, true, onRequestSubmitSuccess, onRequestSubmitFailed )
    end

    local httpRequest = HttpRequestForLua:create( CCHttpRequest.kHttpPost )
    httpRequest:addHeader( Constants.CONTENT_TYPE_JSON )
    httpRequest:addHeader( Logic:getAuthSessionString() )
    httpRequest:getRequest():setRequestData( requestContentText, string.len( requestContentText ) )
    httpRequest:sendHttpRequest( url, handler )

    ConnectingMessage.loadFrame()
end

-- {"Information":"successful"}
function onRequestSubmitSuccess( json )
	EventManager:postEvent( Event.Enter_Lucky8 )
end

function onRequestSubmitFailed( json )
    RequestUtils.onRequestFailedByErrorCode( json["Message"] )
end

function action( param )
	requestSubmit( param )
end
