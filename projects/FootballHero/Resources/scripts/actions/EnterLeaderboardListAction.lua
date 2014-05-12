module(..., package.seeall)

local Json = require("json")
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local RequestUtils = require("scripts.RequestUtils")
local Logic = require("scripts.Logic").getInstance()

local mSortType = RequestUtils.LEADERBOARD_ROI

function action( param )
	local leaderboardId = param[1]
	local leaderboardType = param[2]
	local step = 1

	local url = RequestUtils.GET_MAIN_LEADERBOARD_REST_CALL
	-- Todo change the url for friends leaderboard when that is done.
	if leaderboardType == 1 then
		mSortType = RequestUtils.LEADERBOARD_ROI
	elseif leaderboardType == 2 then
		-- Todo change to played type
	elseif leaderboardType == 3 then
		mSortType = RequestUtils.LEADERBOARD_PROFIT
	elseif leaderboardType == 4 then
		mSortType = RequestUtils.LEADERBOARD_PERCENTAGE
	end

	local handler = function( isSucceed, body, header, status, errorBuffer )
        print( "Http reponse: "..status.." and errorBuffer: "..errorBuffer )
        print( "Http reponse body: "..body )
        
        local jsonResponse = {}
        if string.len( body ) > 0 then
            jsonResponse = Json.decode( body )
        else
            jsonResponse["Message"] = errorBuffer
        end
        ConnectingMessage.selfRemove()
        if status == RequestUtils.HTTP_200 then
            onRequestSuccess( jsonResponse )
        else
            onRequestFailed( jsonResponse["Message"] )
        end
    end

    local httpRequest = HttpRequestForLua:create( CCHttpRequest.kHttpGet )
    httpRequest:addHeader( Logic:getAuthSessionString() )
    httpRequest:sendHttpRequest( url.."?sortType="..mSortType.."&step="..step, handler )

    ConnectingMessage.loadFrame()
end

function onRequestSuccess( response )
	local dataColumnId = "Roi"
	if mSortType == RequestUtils.LEADERBOARD_ROI then
		dataColumnId = "Roi"
	elseif mSortType == RequestUtils.LEADERBOARD_PROFIT then
		dataColumnId = "Profit"
	elseif mSortType == RequestUtils.LEADERBOARD_PERCENTAGE then
		dataColumnId = "WinPercentage"
	end

    local leaderboardListScene = require("scripts.views.LeaderboardListScene")
    leaderboardListScene.loadFrame( response, dataColumnId )
end

function onRequestFailed( errorBuffer )
    EventManager:postEvent( Event.Show_Error_Message, { errorBuffer } )
end