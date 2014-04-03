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
    --eventManager:postEvent( event.Load_Match_List )

    FacebookDelegate:sharedDelegate():login()
end



xpcall(main, __G__TRACKBACK__)
