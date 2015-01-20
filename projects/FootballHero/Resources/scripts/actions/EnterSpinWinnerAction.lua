module(..., package.seeall)

local Json = require("json")
local RequestUtils = require("scripts.RequestUtils")
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local Logic = require("scripts.Logic").getInstance()
local Constants = require("scripts.Constants")

local mOnlyShowBigPrize

function action( param )
    mOnlyShowBigPrize = false
    if param ~= nil and param[1] ~= nil then
        mOnlyShowBigPrize = param[1]
    end

    local url = RequestUtils.GET_SPIN_WINNERS_REST_CALL.."?step=1&bigOnly="..tostring(mOnlyShowBigPrize)
   
    local requestInfo = {}
    requestInfo.requestData = ""
    requestInfo.url = url
    local handler = function( isSucceed, body, header, status, errorBuffer )
        RequestUtils.messageHandler( requestInfo, isSucceed, body, header, status, errorBuffer, RequestUtils.HTTP_200, true, onRequestSuccess )
    end

    local httpRequest = HttpRequestForLua:create( CCHttpRequest.kHttpGet )
    httpRequest:addHeader( Logic:getAuthSessionString() )
    httpRequest:sendHttpRequest( url, handler )

    ConnectingMessage.loadFrame()
end

function onRequestSuccess( jsonResponse )
    local SpinWinnersScene = require("scripts.views.SpinWinnersScene")
    if SpinWinnersScene.isShown() then
        SpinWinnersScene.refreshFrame( jsonResponse["Winners"], mOnlyShowBigPrize )
    else
        SpinWinnersScene.loadFrame( jsonResponse["Winners"], mOnlyShowBigPrize )
    end
end
