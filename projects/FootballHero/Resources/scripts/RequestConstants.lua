module(..., package.seeall)

HTTP_200 = 200

SERVER_IP = "http://fhapi-prod1.cloudapp.net"

EMAIL_REGISTER_REST_CALL = SERVER_IP.."/api/user/SignupWithEmail"
EMAIL_LOGIN_REST_CALL = SERVER_IP.."/api/loginWithEmail"
FB_LOGIN_REST_CALL = SERVER_IP.."/api/user/SignupWithFacebook"
GET_ALL_UPCOMING_GAMES_REST_CALL = SERVER_IP.."/api/games/allUpcoming"
GET_UPCOMING_GAMES_BY_LEAGUE_REST_CALL = SERVER_IP.."/api/games/upcomingByLeague"