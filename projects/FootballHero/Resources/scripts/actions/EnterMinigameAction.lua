module(..., package.seeall)

local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local RequestUtils = require("scripts.RequestUtils")
local Logic = require("scripts.Logic").getInstance()
local Json = require("json")
local Constants = require("scripts.Constants")
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local CommunityConfig = require("scripts.config.Community")

local LOAD_WEBVIEW = false

function action( param )
    local fbToken = param[1]
    local reshare = param[2] or false

    if LOAD_WEBVIEW then
		local MinigameWebview = require("scripts.views.MinigameWebview")
	    MinigameWebview.loadFrame( fbToken )

	else
		local URL = RequestUtils.SHOOT_TO_WIN_FB_REDIRECT_CALL..fbToken
		if reshare then
			URL = URL.."&reshare=true"
		end
	    local requestContent = {}
	    local requestContentText = Json.encode( requestContent )

	    local requestInfo = {}
	    requestInfo.requestData = requestContentText
	    requestInfo.url = URL

	    local handler = function( isSucceed, body, header, status, errorBuffer )
	        RequestUtils.messageHandler( requestInfo, isSucceed, body, header, status, errorBuffer, RequestUtils.HTTP_200, true, onRequestSuccess )
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
	EventManager:postEvent( Event.Enter_Community, { CommunityConfig.COMMUNITY_TAB_ID_COMPETITION } )
	Misc:sharedDelegate():openUrl( jsonResponse )
    --EventManager:postEvent( Event.Show_Info, { Constants.String.info.shared_to_fb_minigame, callback } )
end