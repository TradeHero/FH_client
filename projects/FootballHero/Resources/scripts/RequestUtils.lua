module(..., package.seeall)

local Json = require("json")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local DoLogReport = require("scripts.actions.DoLogReport")
local FileUtils = require("scripts.FileUtils")
local Constants = require("scripts.Constants")
local ServerErrorConfig = require("scripts.config.ServerError")


HTTP_200 = 200
HTTP_204 = 204

SERVER_IP = "http://fhapi-prod1.cloudapp.net"
FACEBOOK_GRAPH_IP = "https://graph.facebook.com"
CDN_SERVER_IP = "http://fhmainstorage.blob.core.windows.net/fhsettings/"

WEBSITE_IP = "http://fhwebsite.cloudapp.net"
WEBSITE_DEV_IP = "http://192.168.1.99:44333"

SHOOT_TO_WIN_FB_REDIRECT_CALL = WEBSITE_IP.."/api/PenaltyKick/fhpenalty/FHFBRedirect?access_token="
SHOOT_TO_WIN_GET_USER_COMPETITION_CALL = WEBSITE_IP.."/api/PenaltyKick/fhpenalty/GetUserCompetitionDetails?userId="

FACEBOOK_FRIENDS_LIST_CALL = "/me/friends?access_token="
--USE_DEV = false
USE_DEV = true


EMAIL_REGISTER_REST_CALL = SERVER_IP.."/api/user/SignupWithEmail"
FULL_REGISTER_REST_CALL = SERVER_IP.."/api/user/fullSignupWithEmail"
EMAIL_LOGIN_REST_CALL = SERVER_IP.."/api/loginWithEmail"
SET_USER_METADATA_REST_CALL = SERVER_IP.."/api/user/setUserMetaData"
FB_LOGIN_REST_CALL = SERVER_IP.."/api/user/SignupWithFacebook"
FB_CONNECT_REST_CALL = SERVER_IP.."/api/user/connectUserWithFacebook"
GET_ALL_UPCOMING_GAMES_REST_CALL = SERVER_IP.."/api/games/allUpcoming"
GET_UPCOMING_GAMES_BY_LEAGUE_REST_CALL = SERVER_IP.."/api/games/upcomingByLeague"
GET_POPULAR_UPCOMING_REST_CALL = SERVER_IP.."/api/games/popularUpcoming"
GET_UPCOMING_TODAY_REST_CALL = SERVER_IP.."/api/games/upcomingToday"
GET_UPCOMING_NEXT_REST_CALL = SERVER_IP.."/api/games/upcomingNext"
GET_MOST_DISCUSSED_REST_CALL = SERVER_IP.."/api/games/mostDiscussed"
GET_TEAM_EXPERT_REST_CALL = SERVER_IP.."/api/games/TeamExpertGames"
GET_GAME_MARKETS_REST_CALL = SERVER_IP.."/api/markets/getMarketsForGame"
GET_COUPON_HISTORY_REST_CALL = SERVER_IP.."/api/couponHistory/getUserCouponHistory"
GET_MAIN_LEADERBOARD_REST_CALL = SERVER_IP.."/api/leaderboards/getMainLeaderboard"
GET_FRIENDS_LEADERBOARD_REST_CALL = SERVER_IP.."/api/leaderboards/getFriendsLeaderboard"
GET_COMPETITION_LIST_REST_CALL = SERVER_IP.."/api/competitions/getCompetitionsForUser"
GET_COMPETITION_DETAIL_REST_CALL = SERVER_IP.."/api/leaderboards/getCompetitionInfoAndLeaderboard"
GET_COMPETITION_LEAGUE_REST_CALL = SERVER_IP.."/api/competitions/getCompetitionLeagueIds"
GET_COMPETITION_DETAILS_REST_CALL = SERVER_IP.."/api/competitions/getCompetitionDetails"
GET_COMPETITION_TEAM_EXPERT_REST_CALL = SERVER_IP.."/api/teamexperts/getTeamExpertPicks"
GET_COMPETITION_EXPERT_HISTORY_REST_CALL = SERVER_IP.."/api/teamexperts/getTeamExpertCouponHistory"
GET_FOLLOW_EXPERTS = SERVER_IP.."/api/teamexperts/followorUnfollwExperts"
GET_CHAT_MESSAGE_REST_CALL = SERVER_IP.."/api/chat/getChatMessages"
GET_USER_META_DATA = SERVER_IP.."/api/user/getUsersMetaData"
GET_WHEEL_PRIZES_REST_CALL = SERVER_IP.."/api/wheel/load"
GET_SPIN_RESULT_REST_CALL = SERVER_IP.."/api/wheel/spin"
GET_SPIN_WINNERS_REST_CALL = SERVER_IP.."/api/wheel/winners"
GET_SPIN_BALANCE_REST_CALL = SERVER_IP.."/api/wheel/balance"
GET_DISCUSSION_REST_CALL = SERVER_IP.."/api/discuss/read"
GET_MATCH_CENTER_REST_CALL = SERVER_IP.."/api/games/matchCenter"
GET_SETTINGS_REST_CALL = SERVER_IP.."/api/user/settingsPage"
GET_LUCKY8_GAMES = SERVER_IP .. "/api/lucky8/games"
GET_LUCKY8_ROUNDS = SERVER_IP .. "/api/lucky8/rounds"
GET_LUCKY8_WINNERS_REST_CALL = SERVER_IP .. "/api/lucky8/winners"
GET_LIVE_SCORE_REST_CALL = SERVER_IP .. "/api/games/livescore"

POST_LUCKY8_PREDICT = SERVER_IP .. "/api/lucky8/predict"
POST_COUPONS_REST_CALL = SERVER_IP.."/api/coupons/placeCoupons"
POST_FAV_TEAM_REST_CALL = SERVER_IP.."/api/user/favoriteTeam"
POST_LOGO_REST_CALL = SERVER_IP.."/api/user/uploadProfilePicture"
POST_CREATE_COMPETITION_REST_CALL = SERVER_IP.."/api/competitions/createUserCompetition"
POST_JOIN_COMPETITION_REST_CALL = SERVER_IP.."/api/competitions/joinCompetitionWithToken"
POST_LEAVE_COMPETITION_REST_CALL = SERVER_IP.."/api/competitions/leaveUserCompetition"
POST_SHARE_COMPETITION_REST_CALL = SERVER_IP.."/api/competitions/claimBonus"
POST_PASSWORD_RESET_REST_CALL = SERVER_IP.."/api/user/requestPasswordResetLink"
POST_CHAT_MESSAGE_REST_CALL = SERVER_IP.."/api/chat/postChatMessage"
POST_COMPETITION_PUSH_SETTING_REST_CALL = SERVER_IP.."/api/competitions/setPushNotificationSettings"
POST_USER_PUSH_SETTING_REST_CALL = SERVER_IP.."/api/user/setPushNotificationSettings"
POST_UPDATE_DEVICD_TOKEN_REST_CALL = SERVER_IP.."/api/user/updateDeviceToken"
POST_SPIN_LUCKY_DRAW_REST_CALL = SERVER_IP.."/api/wheel/submitEmail"
POST_SHARE_SPIN_REST_CALL = SERVER_IP.."/api/wheel/shareToFacebook"
POST_SPIN_PAYOUT_REST_CALL = SERVER_IP.."/api/wheel/payout"
POST_NEW_DISCUSSION_REST_CALL = SERVER_IP.."/api/discuss/write"
POST_LIKE_DISCUSSION_REST_CALL = SERVER_IP.."/api/discuss/like"


--[[
    DS:
    {
        "url": {
            "timeStamp": 10000,
            "body": "jsonResponse"
        }
    }

--]]
local mResponseCache = {}
local RESPONSE_CACHE_TIME = 600

function setServerIP( serverIp, cdnServerIp, useDev )
    EMAIL_REGISTER_REST_CALL = serverIp.."/api/user/SignupWithEmail"
    FULL_REGISTER_REST_CALL = serverIp.."/api/user/fullSignupWithEmail"
    EMAIL_LOGIN_REST_CALL = serverIp.."/api/loginWithEmail"
    SET_USER_METADATA_REST_CALL = serverIp.."/api/user/setUserMetaData"
    FB_LOGIN_REST_CALL = serverIp.."/api/user/SignupWithFacebook"
    FB_CONNECT_REST_CALL = serverIp.."/api/user/connectUserWithFacebook"
    GET_ALL_UPCOMING_GAMES_REST_CALL = serverIp.."/api/games/allUpcoming"
    GET_UPCOMING_GAMES_BY_LEAGUE_REST_CALL = serverIp.."/api/games/upcomingByLeague"
    GET_POPULAR_UPCOMING_REST_CALL = serverIp.."/api/games/popularUpcoming"
    GET_UPCOMING_TODAY_REST_CALL = serverIp.."/api/games/upcomingToday"
    GET_UPCOMING_NEXT_REST_CALL = serverIp.."/api/games/upcomingNext"
    GET_MOST_DISCUSSED_REST_CALL = serverIp.."/api/games/mostDiscussed"
    GET_TEAM_EXPERT_REST_CALL = serverIp.."/api/games/TeamExpertGames"
    GET_GAME_MARKETS_REST_CALL = serverIp.."/api/markets/getMarketsForGame"
    GET_COUPON_HISTORY_REST_CALL = serverIp.."/api/couponHistory/getUserCouponHistory"
    GET_MAIN_LEADERBOARD_REST_CALL = serverIp.."/api/leaderboards/getMainLeaderboard"
    GET_FRIENDS_LEADERBOARD_REST_CALL = serverIp.."/api/leaderboards/getFriendsLeaderboard"
    GET_COMPETITION_LIST_REST_CALL = serverIp.."/api/competitions/getCompetitionsForUser"
    GET_COMPETITION_DETAIL_REST_CALL = serverIp.."/api/leaderboards/getCompetitionInfoAndLeaderboard"
    GET_COMPETITION_LEAGUE_REST_CALL = serverIp.."/api/competitions/getCompetitionLeagueIds"
    GET_COMPETITION_DETAILS_REST_CALL = serverIp.."/api/competitions/getCompetitionDetails"
    GET_COMPETITION_TEAM_EXPERT_REST_CALL = serverIp.."/api/teamexperts/getTeamExpertPicks"
    GET_COMPETITION_EXPERT_HISTORY_REST_CALL = serverIp.."/api/teamexperts/getTeamExpertCouponHistory"
    GET_FOLLOW_EXPERTS = serverIp.."/api/teamexperts/followorUnfollwExperts"
    GET_CHAT_MESSAGE_REST_CALL = serverIp.."/api/chat/getChatMessages"
    GET_USER_META_DATA = serverIp.."/api/user/getUsersMetaData"
    GET_WHEEL_PRIZES_REST_CALL = serverIp.."/api/wheel/load"
    GET_SPIN_RESULT_REST_CALL = serverIp.."/api/wheel/spin"
    GET_SPIN_WINNERS_REST_CALL = serverIp.."/api/wheel/winners"
    GET_SPIN_BALANCE_REST_CALL = serverIp.."/api/wheel/balance"
    GET_DISCUSSION_REST_CALL = serverIp.."/api/discuss/read"
    GET_MATCH_CENTER_REST_CALL = serverIp.."/api/games/matchCenter"
    GET_SETTINGS_REST_CALL = serverIp.."/api/user/settingsPage"
    GET_LUCKY8_GAMES = serverIp .. "/api/lucky8/games"
    GET_LUCKY8_ROUNDS = serverIp .. "/api/lucky8/rounds"
    GET_LUCKY8_WINNERS_REST_CALL = serverIp .. "/api/lucky8/winners"
    GET_LIVE_SCORE_REST_CALL = serverIp .. "/api/games/livescore"
    
    POST_LUCKY8_PREDICT = serverIp .. "/api/lucky8/predict"
    POST_COUPONS_REST_CALL = serverIp.."/api/coupons/placeCoupons"
    POST_FAV_TEAM_REST_CALL= serverIp.."/api/user/favoriteTeam"
    POST_LOGO_REST_CALL = serverIp.."/api/user/uploadProfilePicture"
    POST_CREATE_COMPETITION_REST_CALL = serverIp.."/api/competitions/createUserCompetition"
    POST_JOIN_COMPETITION_REST_CALL = serverIp.."/api/competitions/joinCompetitionWithToken"
    POST_LEAVE_COMPETITION_REST_CALL = serverIp.."/api/competitions/leaveUserCompetition"
    POST_SHARE_COMPETITION_REST_CALL = serverIp.."/api/competitions/claimBonus"
    POST_PASSWORD_RESET_REST_CALL = serverIp.."/api/user/requestPasswordResetLink"
    POST_CHAT_MESSAGE_REST_CALL = serverIp.."/api/chat/postChatMessage"
    POST_COMPETITION_PUSH_SETTING_REST_CALL = serverIp.."/api/competitions/setPushNotificationSettings"
    POST_USER_PUSH_SETTING_REST_CALL = serverIp.."/api/user/setPushNotificationSettings"
    POST_UPDATE_DEVICD_TOKEN_REST_CALL = serverIp.."/api/user/updateDeviceToken"
    POST_SPIN_LUCKY_DRAW_REST_CALL = serverIp.."/api/wheel/submitEmail"
    POST_SHARE_SPIN_REST_CALL = serverIp.."/api/wheel/shareToFacebook"
    POST_SPIN_PAYOUT_REST_CALL = serverIp.."/api/wheel/payout"
    POST_NEW_DISCUSSION_REST_CALL = serverIp.."/api/discuss/write"
    POST_LIKE_DISCUSSION_REST_CALL = serverIp.."/api/discuss/like"

	CDN_SERVER_IP = cdnServerIp
    USE_DEV = useDev
end

function initServer()
    local serverContextText = FileUtils.readStringFromFile("server")
    CCLuaLog("Server context: "..serverContextText)
    local serverContext = Json.decode( serverContextText )
    setServerIP( serverContext.serverURL, serverContext.CDNserverURL, serverContext.useDev )
end

initServer()

function createHeaderObject( headerStr )
	local headerList = split( headerStr, "\r\n" )
    local headers = {}
    for k, v in pairs( headerList ) do
        local headerObj = split( v, ": " )
        if table.getn( headerObj ) >= 2 then
        	headers[headerObj[1]] = headerObj[2]
        end
    end

    return headers
end

local mTimezoneOffset = nil
function getTimezoneOffset()
    if mTimezoneOffset == nil then
        local ts = os.time()
        local utcDate   = os.date( "!*t", ts )
        local localDate = os.date( "*t", ts )
        localDate.isdst = false
        mTimezoneOffset =  os.difftime( os.time( localDate ), os.time( utcDate ) ) / 60 / 60
    end

    return mTimezoneOffset
end

function split(str, delim, maxNb)   
    -- Eliminate bad cases...  
    if delim == "." then
        delim = "%."
    end

    if string.find(str, delim) == nil then  
        return { str }  
    end 
    if maxNb == nil or maxNb < 1 then  
        maxNb = 0    -- No limit   
    end  
    local result = {} 
    local pat = "(.-)" .. delim .. "()"   
    local nb = 0  
    local lastPos   
    for part, pos in string.gfind(str, pat) do  
        nb = nb + 1  
        result[nb] = part   
        lastPos = pos   
        if nb == maxNb then break end  
    end  
    -- Handle the last field   
    if nb ~= maxNb then  
        result[nb + 1] = string.sub(str, lastPos)   
    end  
    return result   
end 



function messageHandler( requestInfo, isSucceed, body, header, status, errorBuffer, successRequestID, removeMask, successHandler, failedHandler )
    CCLuaLog( "Http reponse: "..status.." and errorBuffer: "..errorBuffer )
    local headers = createHeaderObject( header )
    local responseEncoding = headers["Content-Encoding"]
    --[[
        to (de-)compress deflate format, use wbits = -zlib.MAX_WBITS
        to (de-)compress zlib format, use wbits = zlib.MAX_WBITS
        to (de-)compress gzip format, use wbits = zlib.MAX_WBITS | 16
    --]]
    if responseEncoding == "deflate" then
        local wbits = -15
        body = zlib.inflate( wbits )( body )
    elseif responseEncoding == nil then
        -- no encoding
    end
    
    CCLuaLog( "Http reponse body: "..body )
    
    local jsonResponse = {}
    local responseError = false
    if string.len( body ) > 0 then
        local safeLoadJson = function()
            jsonResponse = Json.decode( body )
        end

        local errorHandler = function( msg )
            responseError = true
        end

        xpcall( safeLoadJson, errorHandler )
    else
        jsonResponse["Message"] = errorBuffer
    end
    
    if removeMask then
        ConnectingMessage.selfRemove()
    end

    if responseError then
        if requestInfo["ignoreJsonDecodeError"] then
            if failedHandler ~= nil then
                failedHandler( jsonResponse )
            end
        else
            onRequestFailedByErrorCode( "default" )
        end
        
        return
    end
    
    if status == successRequestID then
        -- Check to record the response
        if requestInfo["recordResponse"] then
            local response = {}
            response["timeStamp"] = os.time()
            response["body"] = jsonResponse

            mResponseCache[requestInfo.url] = response
        end

        if successHandler ~= nil then
            successHandler( jsonResponse )
        end
    else
        reportRequestFailed( requestInfo, jsonResponse["Message"] )
        if failedHandler ~= nil then
            failedHandler( jsonResponse )
        else
            onRequestFailedByErrorCode( jsonResponse["Message"] )
        end
    end
end

function reportRequestFailed( requestInfo, errorCode )
    if ServerErrorConfig.isExceptionalErrorByCode( errorCode ) then
        local unknowErrorPostText = "Get error code: "..errorCode.." with request body: "..Json.encode( requestInfo )
        DoLogReport.reportNetworkError( unknowErrorPostText )
    end
end

function onRequestFailedByErrorCode( errorCode )
    local errorMessage = Constants.String.serverError[errorCode]
    if errorMessage == nil then
        errorMessage = Constants.String.serverError.DEFAULT
    end
    onRequestFailed( errorMessage )
end

function onRequestFailed( errorBuffer )
    EventManager:postEvent( Event.Show_Error_Message, { errorBuffer } )
end

function getResponseCache( url )
    if mResponseCache[url] ~= nil then
        local response = mResponseCache[url]
        local now = os.time()
        if now - response["timeStamp"] < RESPONSE_CACHE_TIME then
            CCLuaLog( "Cache hit for "..url )
            return response["body"]
        else
            CCLuaLog( "Cache hit but expired for "..url )
            return nil
        end
    end
    CCLuaLog( "Cache miss for "..url )
    return nil
end

function invalidResponseCacheContainsUrl( urlKey )
    for url, _ in pairs( mResponseCache ) do
        local lengthOfUrlKey = string.len( urlKey )

        if string.sub( url, 1, lengthOfUrlKey ) == urlKey then
            mResponseCache[url] = nil
            CCLuaLog("Cleared cache for url: "..url)
        end
    end
end

function clearResponseCache()
    mResponseCache = {}
end