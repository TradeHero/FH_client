module(..., package.seeall)

local Json = require("json")
local RequestUtils = require("scripts.RequestUtils")
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local Logic = require("scripts.Logic").getInstance()
local StoreConfig = require("scripts.config.Store") 

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
    for i = 1, table.getn( jsonResponse ) - 1 do
        productId[i] = StoreConfig.ProductInfo[ jsonResponse[i]["Level"] ][ "id" ]
    end
    Store:sharedDelegate():requestProducts( Json.encode( productId ), storeHandler)
end

function storeHandler( products )
    ConnectingMessage.selfRemove()
    local StoreScene = require("scripts.views.StoreScene")
    StoreScene.loadFrame( mJsonResponse, Json.decode( products ) )
end