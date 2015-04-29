module(..., package.seeall)

local Json = require("json")
local RequestUtils = require("scripts.RequestUtils")
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local Logic = require("scripts.Logic").getInstance()
local Constants = require("scripts.Constants")

local mJsonResponse

function action( param )
    local step = 1
    if param ~= nil and param[1] ~= nil then
        step = param[1]
    end

    local onlyShowBigPrize = false
    if param ~= nil and param[2] ~= nil then
        onlyShowBigPrize = param[2]
    end

    local url = RequestUtils.GET_SPIN_WINNERS_REST_CALL.."?step="..step.."&bigOnly="..tostring(onlyShowBigPrize)

    if param ~= nil and param[3] ~= nil then
        if param[3] == Constants.GAME_WINNERS_LUCKY8 then
            url = RequestUtils.GET_LUCKY8_WINNERS_REST_CALL.."?step="..step.."&bigOnly="..tostring(onlyShowBigPrize)
        else
            url = RequestUtils.GET_SPIN_WINNERS_REST_CALL.."?step="..step.."&bigOnly="..tostring(onlyShowBigPrize)
        end
    else
        url = RequestUtils.GET_SPIN_WINNERS_REST_CALL.."?step="..step.."&bigOnly="..tostring(onlyShowBigPrize)
    end
   
    local requestInfo = {}
    requestInfo.requestData = ""
    requestInfo.url = url
    local handler = function( isSucceed, body, header, status, errorBuffer )
        RequestUtils.messageHandler( requestInfo, isSucceed, body, header, status, errorBuffer, RequestUtils.HTTP_200, false, onRequestSuccess )
    end

    local httpRequest = HttpRequestForLua:create( CCHttpRequest.kHttpGet )
    httpRequest:addHeader( Logic:getAuthSessionString() )
    httpRequest:sendHttpRequest( url, handler )

    --ConnectingMessage.loadFrame()
end

function onRequestSuccess( jsonResponse )
    local SpinWinnersScene = require("scripts.views.SpinWinnersScene")
    SpinWinnersScene.loadMoreWinners( jsonResponse["Winners"] )
end
