module(..., package.seeall)

local Constants = require("scripts.Constants")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local Json = require("json")
local RequestUtils = require("scripts.RequestUtils")
local Logic = require("scripts.Logic").getInstance()
local PushNotificationManager = require("scripts.PushNotificationManager")
local QuickBloxService = require("scripts.QuickBloxService")


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
                            SocialNetworkType = 3, 
                            DeviceToken = Logic:getDeviceToken(),
                            UserDeviceToken = Logic:getDeviceID(),
                            useDev = RequestUtils.USE_DEV,
                            Version = Constants.getClientVersion() }

    local requestContentText = Json.encode( requestContent )
    CCLuaLog("Yuuzoo Login data: "..requestContentText)
    
    local url = RequestUtils.YUUZOO_LOGIN_REST_CALL

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
    local sessionToken = jsonResponse["SessionToken"]
    local userId = jsonResponse["Id"]
    local configMd5Info = jsonResponse["ConfigMd5Info"]
    local displayName = jsonResponse["DisplayName"]
    local pictureUrl = jsonResponse["PictureUrl"]
    local startLeagueId = Constants.SpecialLeagueIds.MOST_POPULAR --jsonResponse["StartLeagueId"]
    local balance = jsonResponse["Balance"]
    local ticket = jsonResponse["Ticket"]
    local active = jsonResponse["ActiveInCompetition"]
    local FbId = jsonResponse["FbId"]
    local pushForPredictionsEnabled = jsonResponse["PushForPredictionsEnabled"]
    local pushGenerallyEnabled = jsonResponse["PushGenerallyEnabled"]
    local needUpdate = jsonResponse["Update"]
    local isExpert = jsonResponse["IsExpert"]
    local isBlock = jsonResponse["BlockedByCountry"]

    if type( pictureUrl ) == "userdata" then
        pictureUrl = ""
    end

    if needUpdate then
        EventManager:postEvent( Event.Show_Please_Update, { Constants.String.info.new_version } )
    else

        -- Popup Footballhero Championship if not already joined
        local stage = CCUserDefault:sharedUserDefault():getIntegerForKey( Constants.EVENT_FHC_STATUS_KEY )
        if stage ~= Constants.EVENT_FHC_STATUS_JOINED then
            CCUserDefault:sharedUserDefault():setIntegerForKey( Constants.EVENT_FHC_STATUS_KEY, Constants.EVENT_FHC_STATUS_TO_OPEN )
        end

        Logic:setUserInfo( mEmail, "", "", sessionToken, userId )
        Logic:setDisplayName( displayName )
        Logic:setPictureUrl( pictureUrl )
        Logic:setStartLeagueId( startLeagueId )
        Logic:setBalance( balance )
        Logic:setTicket( ticket )
        Logic:setActiveInCompetition( active )
        Logic:setFbId( FbId )
        Logic:setExpert( isExpert ) 
        Logic:setBetBlock( isBlock )

        PushNotificationManager.initFromServer( pushGenerallyEnabled, pushForPredictionsEnabled )
        
        local finishEvent = Event.Enter_Match_List
        
        local params = { Platform = "yuuzoo" }
        Analytics:sharedDelegate():postEvent( Constants.ANALYTICS_EVENT_LOGIN, Json.encode( params ) )
        Analytics:sharedDelegate():postFlurryEvent( Constants.ANALYTICS_EVENT_LOGIN, Json.encode( params ) )

        QuickBloxService.login( displayName, pictureUrl, userId, function( token )
            Logic:setQuickBloxToken( token )
        end )

        EventManager:postEvent( Event.Check_File_Version, { configMd5Info, finishEvent } )
    end
end

function onRequestFailed( jsonResponse )
    Logic:clearAccountInfoFile()
    RequestUtils.onRequestFailedByErrorCode( jsonResponse["Message"] )
end