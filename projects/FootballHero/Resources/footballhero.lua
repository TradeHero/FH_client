require "AudioEngine" 
require "Cocos2d"

-- for CCLuaEngine traceback
function __G__TRACKBACK__(msg)
    print("----------------------------------------")
    print("LUA ERROR: " .. tostring(msg) .. "\n")
    print(debug.traceback())
    print("----------------------------------------")

    local errorDesc = "\nLUA ERROR: "..msg .. "\n"
    errorDesc = errorDesc.."\n"..debug.traceback()
    CCMessageBox( errorDesc, "LUA ERROR: " )
end

local cclog = function(...)
    print(string.format(...))
end

local function main()
    -- avoid memory leak
    collectgarbage("setpause", 100)
    collectgarbage("setstepmul", 5000)

    cclog("Game start.")
    local sceneManager = require("scripts.SceneManager")
    sceneManager.init()

    local eventManager = require("scripts.events.EventManager").getInstance()
    local event = require("scripts.events.Event").EventList
    --eventManager:postEvent( event.Enter_Login_N_Reg )
    --eventManager:postEvent( event.Enter_Sel_Fav_Team )
    --eventManager:postEvent( event.Enter_Match_List )
    --eventManager:postEvent( event.Enter_Match )
    --eventManager:postEvent( event.Enter_Prediction_Confirm, { 0, 0, 0 } )

    local MD5 = require("MD5")
    local Json = require("json")
    local handler = function( isSucceed, body, header, status, errorBuffer )
        print("MD5: ".. MD5.sumhexa( body ))
    end
    local httpRequest = HttpRequestForLua:create( CCHttpRequest.kHttpGet )
    httpRequest:sendHttpRequest( "http://portalvhdss3c1vgx5mrzv.blob.core.windows.net/fhsettings/countries.txt", handler )


--[[
    local handler = function( num )
        cclog("Get login result "..num)
    end

    FacebookDelegate:sharedDelegate():login( handler, handler )
--]]
end

xpcall(main, __G__TRACKBACK__)
