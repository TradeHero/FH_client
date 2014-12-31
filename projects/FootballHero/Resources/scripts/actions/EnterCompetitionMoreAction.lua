module(..., package.seeall)

local Json = require("json")
local RequestUtils = require("scripts.RequestUtils")
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local Logic = require("scripts.Logic").getInstance()

local mCompetitionId

function action( param )
    mCompetitionId = param[1]

    local url = RequestUtils.GET_COMPETITION_DETAILS_REST_CALL
    url = url.."?competitionId="..mCompetitionId

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
    local competitionLeagueIds = jsonResponse["CompetitionLeagueIds"]
    local pushNotificationsEnabled = jsonResponse["PushNotificationsEnabled"]

	local CompetitionMoreScene = require("scripts.views.CompetitionMoreScene")
    CompetitionMoreScene.loadFrame( competitionLeagueIds, mCompetitionId, pushNotificationsEnabled )
end