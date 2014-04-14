module(..., package.seeall)

HTTP_200 = 200

SERVER_IP = "http://fhapi-prod1.cloudapp.net"

EMAIL_REGISTER_REST_CALL = SERVER_IP.."/api/user/SignupWithEmail"
EMAIL_LOGIN_REST_CALL = SERVER_IP.."/api/loginWithEmail"