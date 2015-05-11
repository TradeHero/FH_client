module(..., package.seeall)

local Json = require("json")
local Constants = require("scripts.Constants")
local Logic = require("scripts.Logic").getInstance()
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local RequestUtils = require("scripts.RequestUtils")
local CheckList = require("scripts.data.CheckList").getCheckList()


local mCheckingItemIndex

function action( param )
    mCheckingItemIndex = 1
    checkItem( mCheckingItemIndex )

    
end

function checkItem( index )
    if index > table.getn( CheckList ) then
        -- All check is done.
        return
    else
        local item = CheckList[mCheckingItemIndex]
        CCLuaLog( "Check item "..item["name"] )
        local url = item["URL"]

        local requestInfo = {}
        requestInfo.requestData = ""
        requestInfo.recordResponse = false
        requestInfo.ignoreJsonDecodeError = true
        requestInfo.url = url

        local handler = function( isSucceed, body, header, status, errorBuffer )
            if isSucceed and body then
                item["checkNewFunction"]( body )
            end

            mCheckingItemIndex = mCheckingItemIndex + 1
            checkItem( mCheckingItemIndex )
        end

        local httpRequest = HttpRequestForLua:create( CCHttpRequest.kHttpGet )
        httpRequest:setPriority( CCHttpRequest.pVeryLow )
        httpRequest:sendHttpRequest( url, handler )
    end
end