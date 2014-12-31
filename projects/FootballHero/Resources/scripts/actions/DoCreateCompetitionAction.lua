module(..., package.seeall)

local Json = require("json")
local Constants = require("scripts.Constants")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local RequestUtils = require("scripts.RequestUtils")
local Logic = require("scripts.Logic").getInstance()
local CompetitionConfig = require("scripts.data.Competitions")

local mFacebookShare

function action( param )

    local name, description, numberOfMonth, selectedLeagues, facebookShare, accessToken, allLeaguesQualify = param[1], param[2], param[3], param[4], param[5], param[6], param[7]
    mFacebookShare = facebookShare

    if string.len( name ) == 0 then
        RequestUtils.onRequestFailed( Constants.String.error.blank_title )
        return
    end
    if string.len( description ) == 0 then
        RequestUtils.onRequestFailed( Constants.String.error.blank_desc )
        return
    end

    if table.getn( selectedLeagues ) == 0 then
        RequestUtils.onRequestFailed( Constants.String.error.blank_league )
        return
    end

    local requestContent = { Name = name, 
                            Description = description, 
                            NumberOfMonth = numberOfMonth,
                            AllLeaguesQualify = allLeaguesQualify,
                            AllowedLeaguesIds = selectedLeagues,
                            ShareOnFacebook = facebookShare,
                            FacebookToken = accessToken, }
    local requestContentText = Json.encode( requestContent )
    print( requestContentText )
    
    local url = RequestUtils.POST_CREATE_COMPETITION_REST_CALL

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
    local competitionId = jsonResponse["CompetitionId"]
    local joinToken = jsonResponse["JoinToken"]

    if mFacebookShare then
        local params = { Platform = "facebook", 
                        Content = "competition code", 
                        Action = "wall share", 
                        Location = "competition creation" }
        CCLuaLog("Send ANALYTICS_EVENT_SOCIAL_ACTION: "..Json.encode( params ) )
        Analytics:sharedDelegate():postEvent( Constants.ANALYTICS_EVENT_SOCIAL_ACTION, Json.encode( params ) )
    end

    local params = { Action = "create"}
    CCLuaLog("Send ANALYTICS_EVENT_COMPETITION: "..Json.encode( params ) )
    Analytics:sharedDelegate():postEvent( Constants.ANALYTICS_EVENT_COMPETITION, Json.encode( params ) )

    EventManager:popHistoryWithoutExec()    -- Remove the create competition event in history. So that it can back direct to the Community scene.
    EventManager:postEvent( Event.Enter_Competition_Detail, { competitionId, true, 3, CompetitionConfig.COMPETITION_TAB_ID_OVERALL } )
end