module(..., package.seeall)

local Json = require("json")
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local Logic = require("scripts.Logic").getInstance()
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local RequestUtils = require("scripts.RequestUtils")


local mUserId = Logic:getUserId()
local mUserName = ""

function action( param )
    local historyMainScene = require("scripts.views.HistoryMainScene")
    if historyMainScene.isFrameShown() then
        return 
    end                                                             

	local step = 1
    
    mUserId = Logic:getUserId()
    if param ~= nil and param[1] ~= nil and param[2] ~= nil then
        mUserId = param[1]
        mUserName = param[2]
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
    httpRequest:sendHttpRequest( RequestUtils.GET_COUPON_HISTORY_REST_CALL.."?userId="..mUserId.."&step="..step, handler )

    ConnectingMessage.loadFrame()
end

function onRequestSuccess( response )
    local CouponHistoryData = require("scripts.data.CouponHistoryData").CouponHistoryData
    local couponHistory = CouponHistoryData:new( response )
    
    local historyMainScene = require("scripts.views.HistoryMainScene")
    historyMainScene.loadFrame( mUserId, mUserName, couponHistory )
end

function onRequestFailed( errorBuffer )
    EventManager:postEvent( Event.Show_Error_Message, { errorBuffer } )
end