module(..., package.seeall)

local Json = require("json")
local Constants = require("scripts.Constants")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local Logic = require("scripts.Logic").getInstance()
local RequestConstants = require("scripts.RequestConstants")
local ConnectingMessage = require("scripts.views.ConnectingMessage")

function action( param )
    if Logic:getPredictions():getSize() > 0 then
        postPredictionData()
    else
        EventManager:postEvent( Event.Enter_Match_List )
    end
end

function postPredictionData()
	local handler = function( isSucceed, body, header, status, errorBuffer )
        print( "Http reponse: "..status.." and errorBuffer: "..errorBuffer )
        print( "Http reponse body: "..body )
        
        local jsonResponse = {}
        if string.len( body ) > 0 then
            jsonResponse = Json.decode( body )
        else
            jsonResponse["Message"] = errorBuffer
        end
        ConnectingMessage.selfRemove()
        if status == RequestConstants.HTTP_200 then
            onRequestSuccess()
        else
            onRequestFailed( jsonResponse["Message"] )
        end
    end

    local requestContentText = Json.encode( Logic:getPredictions() )
    print("Request content is "..requestContentText)

    local httpRequest = HttpRequestForLua:create( CCHttpRequest.kHttpPost )
    httpRequest:addHeader( Constants.CONTENT_TYPE_JSON )
    httpRequest:addHeader( Logic:getAuthSessionString() )
    
    httpRequest:getRequest():setRequestData( requestContentText, string.len( requestContentText ) )
    httpRequest:sendHttpRequest( RequestConstants.POST_COUPONS_REST_CALL, handler )

    ConnectingMessage.loadFrame()
end

function onRequestSuccess()
    EventManager:postEvent( Event.Enter_Match_List )
end

function onRequestFailed( errorBuffer )
    EventManager:postEvent( Event.Show_Error_Message, { errorBuffer, postPredictionData } )
end