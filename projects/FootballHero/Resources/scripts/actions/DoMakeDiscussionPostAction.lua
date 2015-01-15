module(..., package.seeall)

local Json = require("json")
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local Logic = require("scripts.Logic").getInstance()
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local RequestUtils = require("scripts.RequestUtils")
local Constants = require("scripts.Constants")
local MatchCenterConfig = require("scripts.config.MatchCenter")

local m_bIsComment

function action( param )

    -- Parent ID can be a game ID or a post ID
    local parentId = param[1]
    m_bIsComment =  type( tonumber( parentId ) ) ~= "number"

    local text = param[2]
    local discussionObject = MatchCenterConfig.DISCUSSION_POST_TYPE_GAME
        
    local url = RequestUtils.POST_NEW_DISCUSSION_REST_CALL

    local requestContent = { ParentId = parentId, Text = text, DiscussionObject = discussionObject }
    local requestContentText = Json.encode( requestContent )

    local requestInfo = {}
    requestInfo.requestData = requestContentText
    requestInfo.url = url

     local handler = function( isSucceed, body, header, status, errorBuffer )
        RequestUtils.messageHandler( requestInfo, isSucceed, body, header, status, errorBuffer, RequestUtils.HTTP_200, true, onRequestSuccess )
    end

    local httpRequest = HttpRequestForLua:create( CCHttpRequest.kHttpPost )
    httpRequest:addHeader( Constants.CONTENT_TYPE_JSON )
    httpRequest:addHeader( Logic:getAuthSessionString() )
    httpRequest:getRequest():setRequestData( requestContentText, string.len( requestContentText ) )
    httpRequest:sendHttpRequest( url, handler )

    ConnectingMessage.loadFrame()
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
    RequestUtils.invalidResponseCacheContainsUrl( RequestUtils.GET_DISCUSSION_REST_CALL )

    if m_bIsComment then
        local bJumpToTop = true
        local MatchCenterDiscussionsDetailScene = require("scripts.views.MatchCenterDiscussionsDetailScene")
        MatchCenterDiscussionsDetailScene.loadMoreContent( { jsonResponse }, bJumpToTop )
    else
        EventManager:postEvent( Event.Enter_Match_Center, { MatchCenterConfig.MATCH_CENTER_TAB_ID_DISCUSSION } )
    end
end

function onRequestFailed( jsonResponse )
    local errorBuffer = jsonResponse["Message"]
    CCLuaLog("Error message is:"..errorBuffer )

    RequestUtils.onRequestFailed( errorBuffer )
end