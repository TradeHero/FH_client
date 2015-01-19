module(..., package.seeall)

local Json = require("json")
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local RequestUtils = require("scripts.RequestUtils")
local Logic = require("scripts.Logic").getInstance()
local Constants = require("scripts.Constants")
local MatchCenterConfig = require("scripts.config.MatchCenter")

local m_bIsComment

function action( param )
	
    -- Parent ID can be a game ID or a post ID
    local parentId = param[1]
    local step = param[2]
    local discussionObjectId = param[3]
    m_bIsComment =  discussionObjectId == MatchCenterConfig.DISCUSSION_POST_TYPE_POST

    local url = RequestUtils.GET_DISCUSSION_REST_CALL..
                "?discussionObjectId="..discussionObjectId..
                "&parentId="..parentId..
                "&step="..step..
                "&perPage="..Constants.DISCUSSIONS_PER_PAGE
                --"&lastPostTime=<unixTimeStamp>"

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

function onRequestSuccess( jsonResponse )
    local discussionScene
    if m_bIsComment then
        discussionScene = require("scripts.views.MatchCenterDiscussionsDetailScene")
        
    else
        discussionScene = require("scripts.views.MatchCenterDiscussionsFrame")
    end
    discussionScene.loadMoreContent( jsonResponse )
end