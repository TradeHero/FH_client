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

    local DoLogReport = require("scripts.actions.DoLogReport")
    DoLogReport.reportError( errorDesc )
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
    eventManager:postEvent( event.Enter_Login_N_Reg )
    --eventManager:postEvent( event.Enter_Sel_Fav_Team )
    --eventManager:postEvent( event.Enter_Match_List )
    --eventManager:postEvent( event.Enter_Match )
    --eventManager:postEvent( event.Enter_Prediction_Confirm, { 0, 0, 0 } )
    --eventManager:postEvent( event.Enter_History )
    --eventManager:postEvent( event.Enter_Leaderboard )
    --eventManager:postEvent( event.Enter_Pred_Total_Confirm )

    --local ConnectingMessage = require("scripts.views.ConnectingMessage")
    --ConnectingMessage.loadFrame()

    local DoLogReport = require("scripts.actions.DoLogReport")
    DoLogReport.reportError( "test" )
end

xpcall(main, __G__TRACKBACK__)
