module(..., package.seeall)

local Constants = require("scripts.Constants")
local RequestUtils = require("scripts.RequestUtils")
local Logic = require("scripts.Logic").getInstance()
local Json = require("json")


local PROJECT_ID = "544021a2e18b11e3923422000ab5bb50"
local ACCOUNT_ID = "sXq6y8k3RoWKE8pyCSEJfZH9LsTc3MmCv9wjNMVjx3zhSFZN-H9Vu0_VveSM2ITwFMxJF5nYlD4="
local SPLUNK_LOG_IP = "https://api.p3js-eqtr.data.splunkstorm.com/1/inputs/http"

local LOGGLY_IP = "http://logs-01.loggly.com/inputs/f5c98c57-6d4d-4e6d-9ccb-1fd03e899e70/tag/http/"
local KEY_OF_VERSION = "current-version-code"


function reportConfigError( log )
    if not RequestUtils.USE_DEV then
        --report( log, "configError" )
    end
end

function reportNetworkError( log )
    report( log, "networkError" )
end

function reportLog( log )
	report( log, "clientLog" )
end

function reportError( log )
	report( log, "clientError" )
end

function report( log, sourceType )
    --[[
        --Splunk storm log
        local handler = function( isSucceed, body, header, status, errorBuffer )
        end

        local httpRequest = HttpRequestForLua:create( CCHttpRequest.kHttpPost )
        httpRequest:addHeader( Constants.CONTENT_TYPE_PLAINTEXT )
        httpRequest:setUserpwd( "samyu:"..ACCOUNT_ID )
        httpRequest:getRequest():setRequestData( log, string.len( log ) )

        local url = SPLUNK_LOG_IP
        url = url.."?index="..PROJECT_ID
        url = url.."&sourcetype="..sourceType

        httpRequest:sendHttpRequest( url, handler )
    ]]

    --Loggly log
    local requestObject = {}
    requestObject["ErrorType"] = sourceType
    requestObject["ClientVersion"] = CCUserDefault:sharedUserDefault():getStringForKey( KEY_OF_VERSION )
    requestObject["Device"] = getDeviceName()
    requestObject["UserDisplayName"] = Logic:getDisplayName() or "Unknown"
    requestObject["StackTrace"] = log

    local requestContent = Json.encode( requestObject )

    local handler = function( isSucceed, body, header, status, errorBuffer )
    end

    local httpRequest = HttpRequestForLua:create( CCHttpRequest.kHttpPost )
    httpRequest:addHeader( Constants.CONTENT_TYPE_PLAINTEXT )
    httpRequest:getRequest():setRequestData( requestContent, string.len( requestContent ) )

    local url = LOGGLY_IP

    httpRequest:sendHttpRequest( url, handler )
end

function getDeviceName()
    if CCApplication:sharedApplication():getTargetPlatform() == kTargetAndroid then
        return "Android"
    elseif CCApplication:sharedApplication():getTargetPlatform() == kTargetIphone then
        return "Iphone"
    elseif CCApplication:sharedApplication():getTargetPlatform() == kTargetIpad then
        return "Ipad"
    else
        return "Unknown"
    end
end