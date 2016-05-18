module(..., package.seeall)

local Json = require("json")
local RequestUtils = require("scripts.RequestUtils")
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local Logic = require("scripts.Logic").getInstance()
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local Constants = require("scripts.Constants")

local mJsonResponse

function action( param )
    local url = RequestUtils.GET_PRODUCTS_REST_CALL
   
    local requestInfo = {}
    requestInfo.requestData = ""
    requestInfo.url = url
    local handler = function( isSucceed, body, header, status, errorBuffer )
        RequestUtils.messageHandler( requestInfo, isSucceed, body, header, status, errorBuffer, RequestUtils.HTTP_200, false, onRequestSuccess )
    end

    local httpRequest = HttpRequestForLua:create( CCHttpRequest.kHttpGet )
    httpRequest:addHeader( Logic:getAuthSessionString() )
    httpRequest:sendHttpRequest( url, handler )

    ConnectingMessage.loadFrame()
end


function onRequestSuccess( jsonResponse )
    mJsonResponse = jsonResponse
    local productId = {}
    for i = 1, table.getn( jsonResponse ) do
        productId[i] = Constants.StorePrefix .. jsonResponse[i]["Level"]
    end
    Store:sharedDelegate():requestProducts( Json.encode( productId ), storeHandler)
end

function storeHandler( msg, success )
    ConnectingMessage.selfRemove()
    if success then
        local StoreScene = require("scripts.views.StoreScene")
        StoreScene.loadFrame( mJsonResponse, Json.decode( msg ) )
    else
        EventManager:postEvent( Event.Show_Error_Message, { "Connect to AppStore failed." } )
    end
end