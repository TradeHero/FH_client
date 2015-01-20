module(..., package.seeall)

local Json = require("json")
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local Logic = require("scripts.Logic").getInstance()
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local RequestUtils = require("scripts.RequestUtils")
local Constants = require("scripts.Constants")
local MatchCenterConfig = require("scripts.config.MatchCenter")

local mTabID

function action( param )
    mTabID = param[1]
    if param[1] then print("like? = true") else print("like? = false") end
    if mTabID == MatchCenterConfig.MATCH_CENTER_TAB_ID_MEETINGS then
        --url = RequestUtils.GET_COMPETITION_LIST_REST_CALL
        
    elseif mTabID == MatchCenterConfig.MATCH_CENTER_TAB_ID_DISCUSSION then

    end
--[[
    local url = RequestUtils.GET_GAME_MARKETS_REST_CALL.."?gameId="..matchId

    local requestInfo = {}
    requestInfo.requestData = ""
    requestInfo.url = url

    local handler = function( isSucceed, body, header, status, errorBuffer )
        RequestUtils.messageHandler( requestInfo, isSucceed, body, header, status, errorBuffer, RequestUtils.HTTP_200, true, onRequestSuccess, onRequestFailed )
    end

    local httpRequest = HttpRequestForLua:create( CCHttpRequest.kHttpGet )
    httpRequest:addHeader( Logic:getAuthSessionString() )
    httpRequest:sendHttpRequest( url, handler )

    ConnectingMessage.loadFrame()
--]]

    --loadMatchCenterScene( {}, mTabID )
end

function loadMatchCenterScene( jsonResponse )
    local MatchCenterScene = require("scripts.views.MatchCenterScene")
    
    if MatchCenterScene.isShown() then
        MatchCenterScene.refreshFrame( jsonResponse, mTabID )
    else
        MatchCenterScene.loadFrame( jsonResponse, mTabID )
    end
end

function onRequestSuccess( jsonResponse )
    loadMatchCenterScene( jsonResponse )
end

function onRequestFailed( jsonResponse )
    RequestUtils.onRequestFailedByErrorCode( jsonResponse["Message"] )
end