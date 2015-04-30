module(..., package.seeall)

local Json = require("json")
local RequestUtils = require("scripts.RequestUtils")
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local Logic = require("scripts.Logic").getInstance()
local Constants = require("scripts.Constants")

local mOnlyShowBigPrize
local mWhichGame

function action( param )
    mOnlyShowBigPrize = false
    if param ~= nil and param[1] ~= nil then
        mOnlyShowBigPrize = param[1]
    end

    if param == nil then
        mWhichGame = Constants.GAME_WINNERS_SPINWHEEL
    else
        if param[2] == nil then 
            mWhichGame = Constants.GAME_WINNERS_SPINWHEEL
        else
            mWhichGame = param[2]
        end
    end
print( "mWhichGame == " .. mWhichGame)
    local url = RequestUtils.GET_SPIN_WINNERS_REST_CALL.."?step=1&bigOnly="..tostring(mOnlyShowBigPrize)
    if mWhichGame == Constants.GAME_WINNERS_LUCKY8 then
        url = RequestUtils.GET_LUCKY8_WINNERS_REST_CALL.."?step=1&bigOnly="..tostring(mOnlyShowBigPrize)
    end

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

-- {
--     "TotalWinners": 2,
--     "Winners": [
--         {
--             "Id": 7,
--             "WinTimeUtc": 1430206700,
--             "DisplayName": null,
--             "PrizeName": "US$ 500",
--             "PictureUrl": null
--         },
--         {
--             "Id": 6,
--             "WinTimeUtc": 1430201093,
--             "DisplayName": "forwind2014",
--             "PrizeName": "US$ 5",
--             "PictureUrl": null
--         }
--     ]
-- }
function onRequestSuccess( jsonResponse )
    local SpinWinnersScene = require("scripts.views.SpinWinnersScene")
    if SpinWinnersScene.isShown() then
        SpinWinnersScene.refreshFrame( jsonResponse["Winners"], mOnlyShowBigPrize, jsonResponse["TotalWinners"] )
        SpinWinnersScene.updateWhichGame( mWhichGame )
    else
        SpinWinnersScene.loadFrame( jsonResponse["Winners"], mOnlyShowBigPrize, jsonResponse["TotalWinners"] )
        SpinWinnersScene.updateWhichGame( mWhichGame )
    end
end
