module(..., package.seeall)

HTTP_200 = 200
HTTP_204 = 204

SERVER_IP = "http://fhapi-prod1.cloudapp.net"
FACEBOOK_GRAPH_IP = "https://graph.facebook.com"
CDN_SERVER_IP = "http://portalvhdss3c1vgx5mrzv.blob.core.windows.net/fhsettings/"

EMAIL_REGISTER_REST_CALL = SERVER_IP.."/api/user/SignupWithEmail"
EMAIL_LOGIN_REST_CALL = SERVER_IP.."/api/loginWithEmail"
SET_USER_METADATA_REST_CALL = SERVER_IP.."/api/user/setUserMetaData"
FB_LOGIN_REST_CALL = SERVER_IP.."/api/user/SignupWithFacebook"
GET_ALL_UPCOMING_GAMES_REST_CALL = SERVER_IP.."/api/games/allUpcoming"
GET_UPCOMING_GAMES_BY_LEAGUE_REST_CALL = SERVER_IP.."/api/games/upcomingByLeague"
GET_GAME_MARKETS_REST_CALL = SERVER_IP.."/api/markets/getMarketsForGame"
GET_COUPON_HISTORY_REST_CALL = SERVER_IP.."/api/couponHistory/getUserCouponHistory"
GET_MAIN_LEADERBOARD_REST_CALL = SERVER_IP.."/api/leaderboards/getMainLeaderboard"
GET_FRIENDS_LEADERBOARD_REST_CALL = SERVER_IP.."/api/leaderboards/getFriendsLeaderboard"
POST_COUPONS_REST_CALL = SERVER_IP.."/api/coupons/placeCoupons"
POST_FAV_TEAM_REST_CALL = SERVER_IP.."/api/user/setFavoriteTeam"

FACEBOOK_FRIENDS_LIST_CALL = "/me/friends?access_token="
USE_DEV = false

function setServerIP( serverIp )
    EMAIL_REGISTER_REST_CALL = serverIp.."/api/user/SignupWithEmail"
    EMAIL_LOGIN_REST_CALL = serverIp.."/api/loginWithEmail"
    SET_USER_METADATA_REST_CALL = serverIp.."/api/user/setUserMetaData"
    FB_LOGIN_REST_CALL = serverIp.."/api/user/SignupWithFacebook"
    GET_ALL_UPCOMING_GAMES_REST_CALL = serverIp.."/api/games/allUpcoming"
    GET_UPCOMING_GAMES_BY_LEAGUE_REST_CALL = serverIp.."/api/games/upcomingByLeague"
    GET_GAME_MARKETS_REST_CALL = serverIp.."/api/markets/getMarketsForGame"
    GET_COUPON_HISTORY_REST_CALL = serverIp.."/api/couponHistory/getUserCouponHistory"
    GET_MAIN_LEADERBOARD_REST_CALL = serverIp.."/api/leaderboards/getMainLeaderboard"
    GET_FRIENDS_LEADERBOARD_REST_CALL = serverIp.."/api/leaderboards/getFriendsLeaderboard"
    POST_COUPONS_REST_CALL = serverIp.."/api/coupons/placeCoupons"
    POST_FAV_TEAM_REST_CALL= serverIp.."/api/user/setFavoriteTeam"

    CDN_SERVER_IP = "http://portalvhdss3c1vgx5mrzv.blob.core.windows.net/fhdevsettings/"

    USE_DEV = true
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