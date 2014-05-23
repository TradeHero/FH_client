module(..., package.seeall)

local Constants = require("scripts.Constants")

local PROJECT_ID = "544021a2e18b11e3923422000ab5bb50"
local ACCOUNT_ID = "sXq6y8k3RoWKE8pyCSEJfZH9LsTc3MmCv9wjNMVjx3zhSFZN-H9Vu0_VveSM2ITwFMxJF5nYlD4="
local SPLUNK_LOG_IP = "https://api.p3js-eqtr.data.splunkstorm.com/1/inputs/http"

function reportConfigError( log )
    report( log, "configError" )
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
end