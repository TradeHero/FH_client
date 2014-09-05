module(..., package.seeall)

local Constants = require("scripts.Constants")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local Json = require("json")
local Logic = require("scripts.Logic").getInstance()
local RequestUtils = require("scripts.RequestUtils")

local mEmail = "test126@abc.com"
local mPassword = "test126"
local mPasswordConf = "test126"
local mUserName = "SamYu"
local mFirstName = "Yu"
local mLastName = "Zheng"

local mConfigMd5Info

function action( param )

    mEmail, mPassword, mPasswordConf = param[1], param[2], param[3]
    if string.len( mEmail ) == 0 then
        RequestUtils.onRequestFailed( "Email is blank." )
        return
    end
    if mPassword ~= mPasswordConf then
        RequestUtils.onRequestFailed( "Two passwords are not the same." )
        return
    end
    if string.len( mPassword ) < 6 then
        RequestUtils.onRequestFailed( "Password too short." )
        return
    end
    if string.len( mPassword ) > 160 then
        RequestUtils.onRequestFailed( "Password too long." )
        return
    end
    if string.find( mEmail, "([-%a%d%._]+)@([-%a%d.]+)" ) == nil then
        RequestUtils.onRequestFailed( "Bad email format." )
        return
    end

    mUserName, mFirstName, mLastName = param[4], param[5], param[6]
    if string.len( mUserName ) == 0 then
        RequestUtils.onRequestFailed( "User name is blank." )
        return
    end
    if mFirstName == nil then
        mFirstName = ""
    end

    if mLastName == nil then
        mLastName = ""
    end

    local requestContent = { Email = mEmail, Password = mPassword, 
                            GMTOffset = RequestUtils.getTimezoneOffset(), DeviceToken = Logic:getDeviceToken(),
                            useDev = RequestUtils.USE_DEV }
    local requestContentText = Json.encode( requestContent )
    print( requestContentText )
    
    local url = RequestUtils.EMAIL_REGISTER_REST_CALL

    local requestInfo = {}
    requestInfo.requestData = requestContentText
    requestInfo.url = url

    local handler = function( isSucceed, body, header, status, errorBuffer )
        RequestUtils.messageHandler( requestInfo, isSucceed, body, header, status, errorBuffer, RequestUtils.HTTP_200, onRegisterRequestSuccess )
    end

    local httpRequest = HttpRequestForLua:create( CCHttpRequest.kHttpPost )
    httpRequest:addHeader( Constants.CONTENT_TYPE_JSON )
    httpRequest:getRequest():setRequestData( requestContentText, string.len( requestContentText ) )
    httpRequest:sendHttpRequest( url, handler )

    ConnectingMessage.loadFrame()
end

function onRegisterRequestSuccess( jsonResponse )
    local sessionToken = jsonResponse["SessionToken"]
    local userId = jsonResponse["Id"]
    local configMd5Info = jsonResponse["ConfigMd5Info"]
    local displayName = jsonResponse["DisplayName"]
    local pictureUrl = jsonResponse["PictureUrl"]
    local startLeagueId = jsonResponse["StartLeagueId"]
    local balance = jsonResponse["Balance"]
    local FbId = jsonResponse["FbId"]

    mConfigMd5Info = configMd5Info

    Logic:setUserInfo( mEmail, mPassword, "", sessionToken, userId )
    Logic:setDisplayName( displayName )
    Logic:setPictureUrl( pictureUrl )
    Logic:setStartLeagueId( startLeagueId )
    Logic:setBalance( balance )
    Logic:setFbId( FbId )


    local requestContent = { DisplayName = mUserName, FirstName = mFirstName, LastName = mLastName, DoB = "" }
    local requestContentText = Json.encode( requestContent )
    
    local url = RequestUtils.SET_USER_METADATA_REST_CALL

    local requestInfo = {}
    requestInfo.requestData = requestContentText
    requestInfo.url = url

    local handler = function( isSucceed, body, header, status, errorBuffer )
        RequestUtils.messageHandler( requestInfo, isSucceed, body, header, status, errorBuffer, RequestUtils.HTTP_200, onRegisterNameRequestSuccess )
    end

    local httpRequest = HttpRequestForLua:create( CCHttpRequest.kHttpPost )
    httpRequest:addHeader( "Content-Type: application/json" )
    httpRequest:addHeader( Logic:getAuthSessionString() )
    httpRequest:getRequest():setRequestData( requestContentText, string.len( requestContentText ) )
    httpRequest:sendHttpRequest( url, handler )

    ConnectingMessage.loadFrame()
end

function onRegisterNameRequestSuccess( jsonResponse )
    Logic:setDisplayName( mUserName )
    
    --EventManager:postEvent( Event.Do_Post_Logo )

    local finishEvent = Event.Enter_Sel_Fav_Team
    local finishEventParam = {}

    local params = { Platform = "email" }
    Analytics:sharedDelegate():postEvent( Constants.ANALYTICS_EVENT_LOGIN, Json.encode( params ) )

    EventManager:postEvent( Event.Check_File_Version, { mConfigMd5Info, finishEvent, finishEventParam } )
end