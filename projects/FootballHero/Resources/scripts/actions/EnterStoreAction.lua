module(..., package.seeall)

local Json = require("json")
local RequestUtils = require("scripts.RequestUtils")
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local Logic = require("scripts.Logic").getInstance()
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
    Store:sharedDelegate():requestProducts(storeHandler)
end

function storeHandler( products )
    ConnectingMessage.selfRemove()
    local StoreScene = require("scripts.views.StoreScene")
    StoreScene.loadFrame( mJsonResponse, products )
end