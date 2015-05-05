module(..., package.seeall)

local Json = require("json")
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local Logic = require("scripts.Logic").getInstance()
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local RequestUtils = require("scripts.RequestUtils")
local Constants = require("scripts.Constants")

function action( param )
	local url = RequestUtils.GET_WHEEL_PRIZES_REST_CALL

    local requestInfo = {}
    requestInfo.requestData = ""
    requestInfo.url = url
    requestInfo.recordResponse = true

    local jsonResponseCache = RequestUtils.getResponseCache( url )
    if jsonResponseCache ~= nil then
        onRequestSuccess( jsonResponseCache )
    else
    	local handler = function( isSucceed, body, header, status, errorBuffer )
	        RequestUtils.messageHandler( requestInfo, isSucceed, body, header, status, errorBuffer, RequestUtils.HTTP_200, true, onRequestSuccess )
	    end

	    local httpRequest = HttpRequestForLua:create( CCHttpRequest.kHttpGet )
	    httpRequest:addHeader( Logic:getAuthSessionString() )
	    httpRequest:sendHttpRequest( url, handler )

	    ConnectingMessage.loadFrame()
    end
end

function onRequestSuccess( response )
    ConnectingMessage.loadFrame()
    loadRemoteImage( response, 1 )
end

function loadRemoteImage( response, id )
    local prizeConfig = response["PrizeInformation"]["Prizes"]
    if id > table.getn( prizeConfig ) then
        ConnectingMessage.selfRemove()
        loadGameCenter( response )
    else
        local SMIS = require("scripts.SMIS")
        local imageUrl = prizeConfig[id]["PictureUrl"]
        local handler = function( path )
            prizeConfig[id]["LocalUrl"] = path
            loadRemoteImage( response, id + 1 )
        end        
        SMIS.getSpinPrizeImagePath( imageUrl, handler )
    end
end

function loadGameCenter( response )
	local SpinWheelConfig = require("scripts.config.SpinWheel")
	SpinWheelConfig.init( response )

    local gameCenterScene = require( "scripts.views.GameCenterScene" )
    if gameCenterScene.isFrameShown() ~= true then
        gameCenterScene.loadFrame()
    end
end
