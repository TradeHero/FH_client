module(..., package.seeall)

local Constants = require("scripts.Constants")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local Json = require("json")
local RequestUtils = require("scripts.RequestUtils")
local Logic = require("scripts.Logic").getInstance()

local mAccessToken
local mSuccessHandler
local mFailedHandler

function action( param )
    mAccessToken = param[1]
    mSuccessHandler = param[2]
    mFailedHandler = param[3]

    if mAccessToken then
        onFBConnectSuccess()
    else
        local handler = function( state, platType, accessToken )
            if state == C2DXResponseStateCancel or state == C2DXResponseStateFail then
                -- To handle user reject to the oAuth.
                CCLuaLog("FB connect with existing user failed.")
                onFBConnectFailed()
            elseif state == C2DXResponseStateSuccess then
                CCLuaLog("Get login result "..accessToken)
                mAccessToken = accessToken
                onFBConnectSuccess()
            end
            ConnectingMessage.selfRemove()
        end

        ConnectingMessage.loadFrame()
        C2DXShareSDK:authorize( C2DXPlatTypeFacebook, handler )
    end
end

function onFBConnectFailed()
    mFailedHandler( true )
end

function onFBConnectSuccess()
    local requestContent = { SocialNetworkType = 0, AuthToken = mAccessToken, useDev = RequestUtils.USE_DEV }
    local requestContentText = Json.encode( requestContent )
    CCLuaLog("Request content text: "..requestContentText)
    
    local url = RequestUtils.FB_CONNECT_REST_CALL
    
    local requestInfo = {}
    requestInfo.requestData = requestContentText
    requestInfo.url = url

    local handler = function( isSucceed, body, header, status, errorBuffer )
        RequestUtils.messageHandler( requestInfo, isSucceed, body, header, status, errorBuffer, RequestUtils.HTTP_200, true, onRequestSuccess, onRequestFailed )
    end

    local httpRequest = HttpRequestForLua:create( CCHttpRequest.kHttpPost )
    httpRequest:addHeader( Constants.CONTENT_TYPE_JSON )
    httpRequest:addHeader( Logic:getAuthSessionString() )
    httpRequest:getRequest():setRequestData( requestContentText, string.len( requestContentText ) )
    httpRequest:sendHttpRequest( url, handler )

    ConnectingMessage.loadFrame()
end

function onRequestSuccess( jsonResponse )
    -- Bind the FB account with the current email account.
    Logic:setFbId( mAccessToken )
    mSuccessHandler()
end

function onRequestFailed( jsonResponse )
    mFailedHandler()
    RequestUtils.onRequestFailedByErrorCode( jsonResponse["Message"] )
end