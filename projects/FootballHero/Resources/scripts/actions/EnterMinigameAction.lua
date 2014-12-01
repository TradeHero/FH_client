module(..., package.seeall)

local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local RequestUtils = require("scripts.RequestUtils")
local Logic = require("scripts.Logic").getInstance()
local Json = require("json")
local Constants = require("scripts.Constants")
local ConnectingMessage = require("scripts.views.ConnectingMessage")

local LOAD_WEBVIEW = false

function action( param )
    local fbToken = param[1]

    if LOAD_WEBVIEW then
		local MinigameWebview = require("scripts.views.MinigameWebview")
	    MinigameWebview.loadFrame( fbToken )

	else
		--local URL = "http://fhwebsite.cloudapp.net/api/PenaltyKick/fhpenalty/FacebookShare?req=true&access_token="..fbToken
		local URL = "http://192.168.1.100:44333/api/PenaltyKick/fhpenalty/FHFBRedirect?access_token="..fbToken
	    local requestContent = {}
	    local requestContentText = Json.encode( requestContent )

	    local requestInfo = {}
	    requestInfo.requestData = requestContentText
	    requestInfo.url = URL

	    local handler = function( isSucceed, body, header, status, errorBuffer )
	        RequestUtils.messageHandler( requestInfo, isSucceed, body, header, status, errorBuffer, RequestUtils.HTTP_200, onRequestSuccess )
	    end

		local httpRequest = HttpRequestForLua:create( CCHttpRequest.kHttpGet )
	    httpRequest:addHeader( Logic:getAuthSessionString() )
	    httpRequest:sendHttpRequest( URL, handler )

	    ConnectingMessage.loadFrame()
	end
end

function onRequestSuccess( jsonResponse )
	local MinigameWebview = require("scripts.views.MinigameWebview")
	--MinigameWebview.loadFrame( jsonResponse )
	Misc:sharedDelegate():openUrl( jsonResponse )
    --EventManager:postEvent( Event.Show_Info, { Constants.String.info.shared_to_fb_minigame, callback } )
end