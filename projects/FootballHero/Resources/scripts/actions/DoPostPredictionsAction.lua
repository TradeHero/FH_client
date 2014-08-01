module(..., package.seeall)

local Json = require("json")
local Constants = require("scripts.Constants")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local Logic = require("scripts.Logic").getInstance()
local RequestUtils = require("scripts.RequestUtils")
local ConnectingMessage = require("scripts.views.ConnectingMessage")

function action( param )
    if Logic:getPredictions():getSize() > 0 then
        postPredictionData()
    else
        EventManager:postEvent( Event.Enter_Match_List )
    end
end

function postPredictionData()
	local requestContentText = Logic:getPredictions():toString()

    local url = RequestUtils.POST_COUPONS_REST_CALL

    local requestInfo = {}
    requestInfo.requestData = requestContentText
    requestInfo.url = url

    local handler = function( isSucceed, body, header, status, errorBuffer )
        RequestUtils.messageHandler( requestInfo, isSucceed, body, header, status, errorBuffer, RequestUtils.HTTP_200, onRequestSuccess, onRequestFailed )
    end

    local httpRequest = HttpRequestForLua:create( CCHttpRequest.kHttpPost )
    httpRequest:addHeader( Constants.CONTENT_TYPE_JSON )
    httpRequest:addHeader( Logic:getAuthSessionString() )
    
    httpRequest:getRequest():setRequestData( requestContentText, string.len( requestContentText ) )
    httpRequest:sendHttpRequest( url, handler )

    ConnectingMessage.loadFrame()
end

function onRequestSuccess( jsonResponse )
    local balance = jsonResponse["Balance"]

    Logic:resetPredictions()
    Logic:setBalance( balance )

    RequestUtils.clearResponseCache()
    EventManager:postEvent( Event.Enter_Match_List )
end

function onRequestFailed( jsonResponse )
    local errorBuffer = jsonResponse["Message"]
    EventManager:postEvent( Event.Show_Error_Message, { errorBuffer, postPredictionData } )
end