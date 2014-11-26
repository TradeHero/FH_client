module(..., package.seeall)

local Json = require("json")
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local Logic = require("scripts.Logic").getInstance()
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local RequestUtils = require("scripts.RequestUtils")
local CompetitionDetail = require("scripts.data.CompetitionDetail").CompetitionDetail
local Constants = require("scripts.Constants")

function action( param )
    local url = RequestUtils.GET_COMPETITION_DETAIL_REST_CALL

    local competitionId = param[1]
    local step = param[2]
    local sortType = param[3] or 1
    

    url = url.."?competitionId="..competitionId.."&sortType="..sortType.."&step="..step.."&perPage="..Constants.RANKINGS_PER_PAGE

    local requestInfo = {}
    requestInfo.requestData = ""
    requestInfo.url = url
    requestInfo.recordResponse = true

    local jsonResponseCache = RequestUtils.getResponseCache( url )
    if jsonResponseCache ~= nil then
        onRequestSuccess( jsonResponseCache )
    else
        local handler = function( isSucceed, body, header, status, errorBuffer )
            RequestUtils.messageHandler( requestInfo, isSucceed, body, header, status, errorBuffer, RequestUtils.HTTP_200, onRequestSuccess )
        end

        local httpRequest = HttpRequestForLua:create( CCHttpRequest.kHttpGet )
        httpRequest:addHeader( Logic:getAuthSessionString() )
        httpRequest:sendHttpRequest( url, handler )

        ConnectingMessage.loadFrame()
    end
end

function onRequestSuccess( jsonResponse )
    local competitionDetail = CompetitionDetail:new( jsonResponse )

    local CompetitionDetailScene = require("scripts.views.CompetitionDetailScene")
    CompetitionDetailScene.loadMoreContent( competitionDetail:getDto() )
end