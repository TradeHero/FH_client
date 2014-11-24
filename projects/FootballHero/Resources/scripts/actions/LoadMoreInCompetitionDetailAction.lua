module(..., package.seeall)

local Json = require("json")
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local Logic = require("scripts.Logic").getInstance()
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local RequestUtils = require("scripts.RequestUtils")
local CompetitionDetail = require("scripts.data.CompetitionDetail").CompetitionDetail

function action( param )
    local url = RequestUtils.GET_COMPETITION_DETAIL_REST_CALL

    local competitionId = param[1]
    local step = param[2]
    local sortType = 1 or param[3]
    

    url = url.."?competitionId="..competitionId.."&sortType="..sortType.."&step="..step

    local requestInfo = {}
    requestInfo.requestData = ""
    requestInfo.url = url

    local handler = function( isSucceed, body, header, status, errorBuffer )
        RequestUtils.messageHandler( requestInfo, isSucceed, body, header, status, errorBuffer, RequestUtils.HTTP_200, onRequestSuccess )
    end

    local httpRequest = HttpRequestForLua:create( CCHttpRequest.kHttpGet )
    httpRequest:addHeader( Logic:getAuthSessionString() )
    httpRequest:sendHttpRequest( url, handler )

    ConnectingMessage.loadFrame()
end

function onRequestSuccess( jsonResponse )
    local competitionDetail = CompetitionDetail:new( jsonResponse )

    local CompetitionDetailScene = require("scripts.views.CompetitionDetailScene")
    CompetitionDetailScene.loadMoreContent( competitionDetail:getDto() )
end