module(..., package.seeall)

local Json = require("json")
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local Logic = require("scripts.Logic").getInstance()
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local RequestUtils = require("scripts.RequestUtils")
local Constants = require("scripts.Constants")
local MatchCenterConfig = require("scripts.config.MatchCenter")

local mDiscussionInfo

function action( param )

	mDiscussionInfo = param
	local postId = mDiscussionInfo["Id"]
	local step = 1

	local url = RequestUtils.GET_DISCUSSION_REST_CALL..
                "?discussionObjectId="..MatchCenterConfig.DISCUSSION_POST_TYPE_POST..
                "&parentId="..postId..
                "&step="..step..
                "&perPage="..Constants.DISCUSSIONS_PER_PAGE
                --"&lastPostTime=<unixTimeStamp>"

	local requestInfo = {}
    requestInfo.requestData = ""
    requestInfo.url = url

    local handler = function( isSucceed, body, header, status, errorBuffer )
        RequestUtils.messageHandler( requestInfo, isSucceed, body, header, status, errorBuffer, RequestUtils.HTTP_200, true, onRequestSuccess )
    end

    local httpRequest = HttpRequestForLua:create( CCHttpRequest.kHttpGet )
    httpRequest:addHeader( Logic:getAuthSessionString() )
    httpRequest:sendHttpRequest( url, handler )

    ConnectingMessage.loadFrame()
end

function onRequestSuccess( jsonResponse )
    local DiscussionsDetailsScene = require("scripts.views.MatchCenterDiscussionsDetailScene")

    if DiscussionsDetailsScene.isShown() then
		DiscussionsDetailsScene.refreshFrame( mDiscussionInfo, jsonResponse )
    else
    	DiscussionsDetailsScene.loadFrame( mDiscussionInfo, jsonResponse )
	end
end