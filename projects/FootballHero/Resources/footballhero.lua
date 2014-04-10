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
    eventManager:postEvent( event.Login_N_Reg )

    local handler = function( isSucceed, body, header, status, errorBuffer )
        cclog( "Http reponse: "..body )
    end

--[[
    local httpRequest = HttpRequestForLua:create( CCHttpRequest.kHttpGet, "application/json", "kdjfkj" )
    httpRequest:sendHttpRequest( "http://192.168.1.12:8080/source/", handler )
--]]

--[[
    local handler = function( num )
        cclog("Get login result "..num)
    end

    FacebookDelegate:sharedDelegate():login( handler, handler )
--]]
end



xpcall(main, __G__TRACKBACK__)
