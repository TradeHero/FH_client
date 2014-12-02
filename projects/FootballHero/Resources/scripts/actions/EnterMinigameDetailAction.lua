module(..., package.seeall)

local Json = require("json")
local RequestUtils = require("scripts.RequestUtils")
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local Logic = require("scripts.Logic").getInstance()
local Constants = require("scripts.Constants")

local mMinigame
local mJsonResponse

function action( param )

    mMinigame = param[1]
    local goalScorers = mMinigame["GoalScorers"]
    --table.insert( mMinigame["GoalScorers"], { playingUserId = 779, points = 3} )
    local userIds = getAllUserIDs( goalScorers )

    local url = RequestUtils.GET_USER_META_DATA
   
    local requestContentText = Json.encode( userIds )
    local requestInfo = {}
    requestInfo.requestData = requestContentText
    requestInfo.url = url

    local handler = function( isSucceed, body, header, status, errorBuffer )
        RequestUtils.messageHandler( requestInfo, isSucceed, body, header, status, errorBuffer, RequestUtils.HTTP_200, onRequestSuccess )
    end

    local httpRequest = HttpRequestForLua:create( CCHttpRequest.kHttpPost )
    httpRequest:addHeader( Constants.CONTENT_TYPE_JSON )
    httpRequest:addHeader( Logic:getAuthSessionString() )
    httpRequest:getRequest():setRequestData( requestContentText, string.len( requestContentText ) )
    httpRequest:sendHttpRequest( url, handler )

    ConnectingMessage.loadFrame()
end

function onRequestSuccess( jsonResponse )
    local goalScorers = mMinigame["GoalScorers"]

    local selfUserId = Logic:getUserId()
    -- add display names and profile pics
    for i = 1, table.getn( jsonResponse ) do
        for j = 1, table.getn( goalScorers ) do
            if jsonResponse[i]["UserId"] == goalScorers[j]["playingUserId"] then
                goalScorers[j]["DisplayName"] = jsonResponse[i]["DisplayName"]
                goalScorers[j]["PictureUrl"] = jsonResponse[i]["PictureUrl"]
                break
            elseif jsonResponse[i]["UserId"] == selfUserId then
                mMinigame["DisplayName"] = jsonResponse[i]["DisplayName"]
                mMinigame["PictureUrl"] = jsonResponse[i]["PictureUrl"]
                break
            end
        end
    end

    loadMinigameDetailScene()
end

function loadMinigameDetailScene()
    local minigameDetailScene = require("scripts.views.MinigameDetailScene")
    minigameDetailScene.loadFrame( mMinigame )
end

function getAllUserIDs( goalScorers )
    local ids = { UserIds = {} }
    -- insert own user id in to retrieve name and profile pic
    table.insert( ids["UserIds"], Logic:getUserId() )
    for i = 1, table.getn( goalScorers ) do
        table.insert( ids["UserIds"], goalScorers[i]["playingUserId"] )
    end

    return ids
end

