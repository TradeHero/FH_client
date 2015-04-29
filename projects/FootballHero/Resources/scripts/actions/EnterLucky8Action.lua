module(..., package.seeall)

local Json = require("json")
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local Logic = require("scripts.Logic").getInstance()
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local RequestUtils = require("scripts.RequestUtils")
local Constants = require("scripts.Constants")
-- local lucky8Scene = require("scripts.")

-- function requestLucky8MatchList(  )
--     local url = RequestUtils.GET_LUCKY8_GAMES
--     local requestInfo = {}
--     requestInfo.requestData = ""
--     requestInfo.url = url
--     local handler = function ( isSucceed, body, header, status, errorBuffer )
--         RequestUtils.messageHandler( requestInfo, isSucceed, body, header, status, errorBuffer, RequestUtils.HTTP_200, true, onRequestLucky8MatchListSuccess, onRequestLucky8MatchListFailed )
--     end

--     local httpRequest = HttpRequestForLua:create( CCHttpRequest.kHttpGet )
--     httpRequest:addHeader( Logic:getAuthSessionString() )
--     httpRequest:sendHttpRequest( url, handler )

--     ConnectingMessage.loadFrame()
-- end

-- function onRequestLucky8MatchListSuccess( json )
--     mScrollViewHeight = 0;
--     initScrollView( json )
-- end

-- function onRequestLucky8MatchListFailed( json )
--     -- body
-- end

function action( param )

	-- requestLucky8MatchList( )
    local lucky8Scene = require( "scripts.views.Lucky8Scene" )
    if lucky8Scene.isFrameShown() ~= true then
        lucky8Scene.loadFrame( data )
    end
end
