module(..., package.seeall)

local Json = require("json")
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local Logic = require("scripts.Logic").getInstance()
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local RequestUtils = require("scripts.RequestUtils")
local Constants = require("scripts.Constants")

local mCallBack 

function requestLucky8Rounds( param )
    mCallBack = param[1]
    local url = RequestUtils.GET_LUCKY8_ROUNDS
    local requestInfo = {}
    requestInfo.requestData = ""
    requestInfo.url = url
    local handler = function ( isSucceed, body, header, status, errorBuffer )
        RequestUtils.messageHandler( requestInfo, isSucceed, body, header, status, errorBuffer, RequestUtils.HTTP_200, true, onRequestRoundsSuccess, nil )
    end

    local httpRequest = HttpRequestForLua:create( CCHttpRequest.kHttpGet )
    httpRequest:addHeader( Logic:getAuthSessionString() )
    httpRequest:sendHttpRequest( url, handler )

    ConnectingMessage.loadFrame()
end

-- {
--     "Rounds": [
--         {
--             "RoundId": 3,
--             "Checked": false,
--             "Settled": false,
--             "StartTime": 1430222400,
--             "PredictionsMade": 8,
--             "PredictionsCorrect": 0,
--             "UsdWon": 500
--         }
--     ]
-- }
function onRequestRoundsSuccess( json )
    local lucky8Scene = require( "scripts.views.Lucky8Scene" )
    if lucky8Scene.isFrameShown() then
        lucky8Scene.refreshPageOfPicks( json )
    else
        lucky8Scene.loadFrameWithPicks( json )
    end
end

function action( param )
	requestLucky8Rounds( param )
end
