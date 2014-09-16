module(..., package.seeall)

local Constants = require("scripts.Constants")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local Json = require("json")
local RequestUtils = require("scripts.RequestUtils")
local Logic = require("scripts.Logic").getInstance()

local mAccessToken

function action( param )
	local Json = require("json")
	local RequestUtils = require("scripts.RequestUtils")

    local handler = function( accessToken )
        if accessToken == nil then
            -- To handle user reject to the oAuth.
            onFBConnectFailed()
        else
            CCLuaLog("Get login result "..accessToken)
            onFBConnectSuccess( accessToken )
        end
    end

    ConnectingMessage.loadFrame()
    FacebookDelegate:sharedDelegate():login( handler )
end

function onFBConnectFailed()
    ConnectingMessage.selfRemove()
end

function onFBConnectSuccess( accessToken )
    mAccessToken = accessToken
    local requestContent = { SocialNetworkType = 0, AuthToken = accessToken, 
                            GMTOffset = RequestUtils.getTimezoneOffset(), DeviceToken = Logic:getDeviceToken(),
                            useDev = RequestUtils.USE_DEV,
                            Version = Constants.getClientVersion() }
    local requestContentText = Json.encode( requestContent )
    
    local url = RequestUtils.FB_LOGIN_REST_CALL
    
    local requestInfo = {}
    requestInfo.requestData = requestContentText
    requestInfo.url = url

    local handler = function( isSucceed, body, header, status, errorBuffer )
        RequestUtils.messageHandler( requestInfo, isSucceed, body, header, status, errorBuffer, RequestUtils.HTTP_200, onRequestSuccess, onRequestFailed )
    end

    local httpRequest = HttpRequestForLua:create( CCHttpRequest.kHttpPost )
    httpRequest:addHeader( Constants.CONTENT_TYPE_JSON )
    httpRequest:getRequest():setRequestData( requestContentText, string.len( requestContentText ) )
    httpRequest:sendHttpRequest( url, handler )

    ConnectingMessage.loadFrame()
end

function onRequestSuccess( jsonResponse )
    local sessionToken = jsonResponse["SessionToken"]
    local userId = jsonResponse["Id"]
    local configMd5Info = jsonResponse["ConfigMd5Info"]
    local displayName = jsonResponse["DisplayName"]
    local pictureUrl = jsonResponse["PictureUrl"]
    local startLeagueId = jsonResponse["StartLeagueId"]
    local balance = jsonResponse["Balance"]
    local active = jsonResponse["ActiveInCompetition"]
    local FbId = jsonResponse["FbId"]

    Logic:setUserInfo( "", "", mAccessToken, sessionToken, userId )
    Logic:setDisplayName( displayName )
    Logic:setPictureUrl( pictureUrl )
    Logic:setStartLeagueId( startLeagueId )
    Logic:setBalance( balance )
    Logic:setActiveInCompetition( active )
    Logic:setFbId( FbId )
    
    local finishEvent = Event.Enter_Sel_Fav_Team
    if displayName == nil then
        finishEvent = Event.Enter_Register_Name
    end

    local params = { Platform = "facebook" }
    Analytics:sharedDelegate():postEvent( Constants.ANALYTICS_EVENT_LOGIN, Json.encode( params ) )

    EventManager:postEvent( Event.Check_File_Version, { configMd5Info, finishEvent } )
end

function onRequestFailed( jsonResponse )
    local errorBuffer = jsonResponse["Message"]
    if errorBuffer == "" then
        errorBuffer = "Login failed. Please retry."
    end

    Logic:clearAccountInfoFile()
    EventManager:postEvent( Event.Show_Error_Message, { errorBuffer } )
end