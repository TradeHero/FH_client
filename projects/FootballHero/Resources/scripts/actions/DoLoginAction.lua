module(..., package.seeall)

local Json = require("json")
local Constants = require("scripts.Constants")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local RequestUtils = require("scripts.RequestUtils")
local Logic = require("scripts.Logic").getInstance()
local PushNotificationManager = require("scripts.PushNotificationManager")


local mEmail = "test126@abc.com"
local mPassword = "test126"


function action( param )

    mEmail, mPassword = param[1], param[2]

    if string.len( mEmail ) == 0 then
        RequestUtils.onRequestFailed( Constants.String.error.blank_email )
        return
    end
    if string.len( mPassword ) == 0 then
        RequestUtils.onRequestFailed( Constants.String.error.blank_password )
        return
    end

    local requestContent = { Email = mEmail, Password = mPassword, 
                            DeviceToken = Logic:getDeviceToken(),
                            useDev = RequestUtils.USE_DEV,
                            Version = Constants.getClientVersion() }
    local requestContentText = Json.encode( requestContent )
    CCLuaLog("Email Login data: "..requestContentText)
    
    local url = RequestUtils.EMAIL_LOGIN_REST_CALL

    local requestInfo = {}
    requestInfo.requestData = requestContentText
    requestInfo.url = url

     local handler = function( isSucceed, body, header, status, errorBuffer )
        RequestUtils.messageHandler( requestInfo, isSucceed, body, header, status, errorBuffer, RequestUtils.HTTP_200, true, onRequestSuccess, onRequestFailed )
    end

    local httpRequest = HttpRequestForLua:create( CCHttpRequest.kHttpPost )
    httpRequest:addHeader( Constants.CONTENT_TYPE_JSON )
    httpRequest:getRequest():setRequestData( requestContentText, string.len( requestContentText ) )
    httpRequest:sendHttpRequest( url, handler )

    ConnectingMessage.loadFrame()
end

function onRequestSuccess( jsonResponse )
    local profileDto = jsonResponse["ProfileDto"]

    local sessionToken = profileDto["SessionToken"]
    local userId = profileDto["Id"]
    local configMd5Info = profileDto["ConfigMd5Info"]
    local displayName = profileDto["DisplayName"]
    local pictureUrl = profileDto["PictureUrl"]
    local startLeagueId = Constants.SpecialLeagueIds.UPCOMING_MATCHES --profileDto["StartLeagueId"]
    local balance = profileDto["Balance"]
    local active = profileDto["ActiveInCompetition"]
    local FbId = profileDto["FbId"]
    local pushForPredictionsEnabled = profileDto["PushForPredictionsEnabled"]
    local pushGenerallyEnabled = profileDto["PushGenerallyEnabled"]
    local needUpdate = profileDto["Update"]

    if needUpdate then
        EventManager:postEvent( Event.Show_Please_Update, { Constants.String.info.new_version } )
    else

        -- Popup Footballhero Championship if not already joined
        local stage = CCUserDefault:sharedUserDefault():getIntegerForKey( Constants.EVENT_FHC_STATUS_KEY )
        if stage ~= Constants.EVENT_FHC_STATUS_JOINED then
            CCUserDefault:sharedUserDefault():setIntegerForKey( Constants.EVENT_FHC_STATUS_KEY, Constants.EVENT_FHC_STATUS_TO_OPEN )
        end

        Logic:setUserInfo( mEmail, mPassword, "", sessionToken, userId )
        Logic:setDisplayName( displayName )
        Logic:setPictureUrl( pictureUrl )
        Logic:setStartLeagueId( startLeagueId )
        Logic:setBalance( balance )
        Logic:setActiveInCompetition( active )
        Logic:setFbId( FbId )

        PushNotificationManager.initFromServer( pushGenerallyEnabled, pushForPredictionsEnabled )

        local finishEvent = Event.Enter_Match_List
        local finishEventParam = {}

        local params = { Platform = "email" }
        Analytics:sharedDelegate():postEvent( Constants.ANALYTICS_EVENT_LOGIN, Json.encode( params ) )

        EventManager:postEvent( Event.Check_File_Version, { configMd5Info, finishEvent, finishEventParam } )
    end
end

function onRequestFailed( jsonResponse )
    local errorBuffer = jsonResponse["Message"]
    if errorBuffer == nil or errorBuffer == "" then
        errorBuffer = Constants.String.error.login_failed
    end

    Logic:clearAccountInfoFile()
    EventManager:postEvent( Event.Show_Error_Message, { errorBuffer } )
end