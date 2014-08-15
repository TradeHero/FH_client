module(..., package.seeall)

local Json = require("json")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local DoLogReport = require("scripts.actions.DoLogReport")

HTTP_200 = 200
HTTP_204 = 204

SERVER_IP = "http://fhapi-prod1.cloudapp.net"
FACEBOOK_GRAPH_IP = "https://graph.facebook.com"
CDN_SERVER_IP = "http://portalvhdss3c1vgx5mrzv.blob.core.windows.net/fhsettings/"

EMAIL_REGISTER_REST_CALL = SERVER_IP.."/api/user/SignupWithEmail"
EMAIL_LOGIN_REST_CALL = SERVER_IP.."/api/loginWithEmail"
SET_USER_METADATA_REST_CALL = SERVER_IP.."/api/user/setUserMetaData"
FB_LOGIN_REST_CALL = SERVER_IP.."/api/user/SignupWithFacebook"
FB_CONNECT_REST_CALL = SERVER_IP.."/api/user/connectUserWithFacebook"
GET_ALL_UPCOMING_GAMES_REST_CALL = SERVER_IP.."/api/games/allUpcoming"
GET_UPCOMING_GAMES_BY_LEAGUE_REST_CALL = SERVER_IP.."/api/games/upcomingByLeague"
GET_GAME_MARKETS_REST_CALL = SERVER_IP.."/api/markets/getMarketsForGame"
GET_COUPON_HISTORY_REST_CALL = SERVER_IP.."/api/couponHistory/getUserCouponHistory"
GET_MAIN_LEADERBOARD_REST_CALL = SERVER_IP.."/api/leaderboards/getMainLeaderboard"
GET_FRIENDS_LEADERBOARD_REST_CALL = SERVER_IP.."/api/leaderboards/getFriendsLeaderboard"
GET_COMPETITION_LIST_REST_CALL = SERVER_IP.."/api/competitions/getCompetitionsForUser"
GET_COMPETITION_DETAIL_REST_CALL = SERVER_IP.."/api/leaderboards/getCompetitionInfoAndLeaderboard"
GET_COMPETITION_LEAGUE_REST_CALL = SERVER_IP.."/api/competitions/getCompetitionLeagueIds"
GET_CHAT_MESSAGE_REST_CALL = SERVER_IP.."/api/chat/getChatMessages"
POST_COUPONS_REST_CALL = SERVER_IP.."/api/coupons/placeCoupons"
POST_FAV_TEAM_REST_CALL = SERVER_IP.."/api/user/setFavoriteTeam"
POST_LOGO_REST_CALL = SERVER_IP.."/api/user/uploadProfilePicture"
POST_CREATE_COMPETITION_REST_CALL = SERVER_IP.."/api/competitions/createUserCompetition"
POST_JOIN_COMPETITION_REST_CALL = SERVER_IP.."/api/competitions/joinCompetitionWithToken"
POST_SHARE_COMPETITION_REST_CALL = SERVER_IP.."/api/competitions/shareCompetitionToFacebookWall"
POST_PASSWORD_RESET_REST_CALL = SERVER_IP.."/api/user/requestPasswordResetLink"
POST_CHAT_MESSAGE_REST_CALL = SERVER_IP.."/api/chat/postChatMessage"


FACEBOOK_FRIENDS_LIST_CALL = "/me/friends?access_token="
USE_DEV = false

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

function setServerIP( serverIp )
    EMAIL_REGISTER_REST_CALL = serverIp.."/api/user/SignupWithEmail"
    EMAIL_LOGIN_REST_CALL = serverIp.."/api/loginWithEmail"
    SET_USER_METADATA_REST_CALL = serverIp.."/api/user/setUserMetaData"
    FB_LOGIN_REST_CALL = serverIp.."/api/user/SignupWithFacebook"
    FB_CONNECT_REST_CALL = serverIp.."/api/user/connectUserWithFacebook"
    GET_ALL_UPCOMING_GAMES_REST_CALL = serverIp.."/api/games/allUpcoming"
    GET_UPCOMING_GAMES_BY_LEAGUE_REST_CALL = serverIp.."/api/games/upcomingByLeague"
    GET_GAME_MARKETS_REST_CALL = serverIp.."/api/markets/getMarketsForGame"
    GET_COUPON_HISTORY_REST_CALL = serverIp.."/api/couponHistory/getUserCouponHistory"
    GET_MAIN_LEADERBOARD_REST_CALL = serverIp.."/api/leaderboards/getMainLeaderboard"
    GET_FRIENDS_LEADERBOARD_REST_CALL = serverIp.."/api/leaderboards/getFriendsLeaderboard"
    GET_COMPETITION_LIST_REST_CALL = serverIp.."/api/competitions/getCompetitionsForUser"
    GET_COMPETITION_DETAIL_REST_CALL = serverIp.."/api/leaderboards/getCompetitionInfoAndLeaderboard"
    GET_COMPETITION_LEAGUE_REST_CALL = serverIp.."/api/competitions/getCompetitionLeagueIds"
    GET_CHAT_MESSAGE_REST_CALL = serverIp.."/api/chat/getChatMessages"
    POST_COUPONS_REST_CALL = serverIp.."/api/coupons/placeCoupons"
    POST_FAV_TEAM_REST_CALL= serverIp.."/api/user/setFavoriteTeam"
    POST_LOGO_REST_CALL = serverIp.."/api/user/uploadProfilePicture"
    POST_CREATE_COMPETITION_REST_CALL = serverIp.."/api/competitions/createUserCompetition"
    POST_JOIN_COMPETITION_REST_CALL = serverIp.."/api/competitions/joinCompetitionWithToken"
    POST_SHARE_COMPETITION_REST_CALL = serverIp.."/api/competitions/shareCompetitionToFacebookWall"
    POST_PASSWORD_RESET_REST_CALL = serverIp.."/api/user/requestPasswordResetLink"
    POST_CHAT_MESSAGE_REST_CALL = serverIp.."/api/chat/postChatMessage"

    if USE_DEV then 
		CDN_SERVER_IP = "http://portalvhdss3c1vgx5mrzv.blob.core.windows.net/fhdevsettings/"
	end
end

--setServerIP( "http://192.168.1.123" )
if USE_DEV then
	setServerIP( "http://fhapi-dev1.cloudapp.net" )
else
	setServerIP( SERVER_IP )
end


function createHeaderObject( headerStr )
	local headerList = split( headerStr, "\n" )
    local headers = {}
    for k, v in pairs( headerList ) do
        local headerObj = split( v, ": " )
        if table.getn( headerObj ) >= 2 then
        	headers[headerObj[1]] = headerObj[2]
        end
    end

    return headers
end

function split(str, delim, maxNb)   
    -- Eliminate bad cases...   
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

function messageHandler( requestInfo, isSucceed, body, header, status, errorBuffer, successRequestID, successHandler, failedHandler )
    print( "Http reponse: "..status.." and errorBuffer: "..errorBuffer )
    print( "Http reponse body: "..body )
    
    local jsonResponse = {}
    if string.len( body ) > 0 then
        jsonResponse = Json.decode( body )
    else
        jsonResponse["Message"] = errorBuffer
    end
    ConnectingMessage.selfRemove()
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
            onRequestFailed( jsonResponse["Message"] )
        end
    end
end

function reportRequestFailed( requestInfo, errorBuffer )
    if errorBuffer == "An error has occurred." then
        local unknowErrorPostText = "Get "..errorBuffer.." with request: "..Json.encode( requestInfo )
        print( unknowErrorPostText )
        DoLogReport.reportNetworkError( unknowErrorPostText )
    end
end

function onRequestFailed( errorBuffer )
    EventManager:postEvent( Event.Show_Error_Message, { errorBuffer } )
end

function getResponseCache( url )
    if mResponseCache[url] ~= nil then
        local response = mResponseCache[url]
        local now = os.time()
        if now - response["timeStamp"] < RESPONSE_CACHE_TIME then
            print( "Cache hit for "..url )
            return response["body"]
        else
            print( "Cache hit but expired for "..url )
            return nil
        end
    end
    print( "Cache miss for "..url )
    return nil
end

function clearResponseCache()
    mResponseCache = {}
end