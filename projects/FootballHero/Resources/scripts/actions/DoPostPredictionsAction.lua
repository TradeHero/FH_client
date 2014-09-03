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
        postPredictionData( param )
    else
        EventManager:postEvent( Event.Enter_Match_List )
    end
end

function postPredictionData( param )
	local requestContentText = "{"..Logic:getPredictions():toString()
    local accessToken = param[1]
    if accessToken ~= nil then
        local accessTokenString = ", FacebookToken: \""..accessToken.."\""
        requestContentText = requestContentText..accessTokenString
    end
    requestContentText = requestContentText.."}"

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

    local predictions = Logic:getPredictions()
    for i = 1, predictions:getSize() do
        local prediction = predictions:get( i )

        local params = { Type = prediction["PredictionType"],
                        Leagueid = prediction["LeagueId"],
                        Teamid1 = prediction["TeamId1"],
                        Teamid2 = prediction["TeamId2"], }
        CCLuaLog("Send ANALYTICS_EVENT_PREDICTION: "..Json.encode( params ) )
        Analytics:sharedDelegate():postEvent( Constants.ANALYTICS_EVENT_PREDICTION, Json.encode( params ) )
    end

    if predictions:getShareOnFacebook() then
        local params = { Platform = "facebook", 
                        Content = "prediction", 
                        Action = "wall share", 
                        Location = "prediction summary" }
        CCLuaLog("Send ANALYTICS_EVENT_SOCIAL_ACTION: "..Json.encode( params ) )
        Analytics:sharedDelegate():postEvent( Constants.ANALYTICS_EVENT_SOCIAL_ACTION, Json.encode( params ) )
    end

    Logic:resetPredictions()
    Logic:setBalance( balance )
    EventManager:postEvent( Event.Enter_Match_List )
end

function onRequestFailed( jsonResponse )
    local errorBuffer = jsonResponse["Message"]
    EventManager:postEvent( Event.Show_Error_Message, { errorBuffer, postPredictionData } )
end