module(..., package.seeall)

local Json = require("json")
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local Logic = require("scripts.Logic").getInstance()
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local RequestUtils = require("scripts.RequestUtils")
local Constants = require("scripts.Constants")
local SportsConfig = require("scripts.config.Sports")


function action( param )
    local matchId = param[1]

    local url = RequestUtils.GET_GAME_MARKETS_REST_CALL.."?gameId="..matchId
    url = SportsConfig.appendSportIdToURLHelper( url )

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

--[[
    local JsonConfigReader = require("scripts.config.JsonConfigReader")
    local config = JsonConfigReader.read( "config/market.json" )

    local match = { Id = 4077,
                HomeTeamId = 2744,
                AwayTeamId = 2942,
                StartTime = 1398311338 }
    Logic:setSelectedMatch( match )
    onRequestSuccess( config )
--]]
end

function onRequestSuccess( response )
    local MarketsForGameData = require("scripts.data.MarketsForGameData").MarketsForGameData
    
    local marketInfo = MarketsForGameData:new( response )

    Logic:setCurMarketInfo( marketInfo )
    
    if marketInfo:getNum() > 0 then
        local TappablePredictionScene = require("scripts.views.TappablePredictionScene")
        TappablePredictionScene.loadFrame()
    else
        RequestUtils.onRequestFailed( Constants.String.error.match_completed )
    end
end

function onRequestFailed( jsonResponse )
    local errorBuffer = jsonResponse["Message"]
    CCLuaLog("Error message is:"..errorBuffer )

    if errorBuffer ~= "" then
        local callback = function( eventType )
        end

        EventManager:postEvent( Event.Show_Info, { Constants.String.info.odds_not_ready, callback, Constants.String.info.announcement_title } )
    else
        RequestUtils.onRequestFailedByErrorCode( jsonResponse["Message"] )
    end
end