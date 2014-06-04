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

    if CCApplication:sharedApplication():getTargetPlatform() ~= kTargetWindows then
        local DoLogReport = require("scripts.actions.DoLogReport")
        DoLogReport.reportError( errorDesc )
    end
end

local cclog = function(...)
    print(string.format(...))
end

local function main()
    -- avoid memory leak
    collectgarbage("setpause", 100)
    collectgarbage("setstepmul", 5000)

    cclog("Game start.")
    initPackageLoader()

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

    --WebviewDelegate:sharedDelegate():openWebpage( "http://www.baidu.com", 0, 0, 320, 576 )

end

function initPackageLoader()
    local fileUtils = CCFileUtils:sharedFileUtils()
    local filePath = fileUtils:fullPathForFilename( "game.bin" )
    local Json = require("json")
    if fileUtils:isFileExist( filePath ) then
        print( filePath )
        local fileHandler, errorCode = io.open( filePath, "r" )
        if fileHandler == nil then
            print( "Read failed from file"..filePath.." with error: "..errorCode )
            return ""
        end
        
        local text = fileHandler:read("*all")
        fileHandler:close()
        local gameContent = Json.decode( text )


        local function loadFromCompact( path )
            print( "loadFromCompact: "..path )
            if gameContent == nil then
                return
            end
            
            local destLuaFile = gameContent[path]
            if destLuaFile == nil then
                return
            end
            
            gameContent[path] = nil
            return assert( loadstring( destLuaFile ) )
        end

        table.insert( package.loaders, 1, loadFromCompact )
    end
end

--[[
function encrypt()
    local fileUtils = CCFileUtils:sharedFileUtils()
    local filePath = fileUtils:fullPathForFilename( "game.bin" )
    if fileUtils:isFileExist( filePath ) then
        print( "crypt "..filePath )
        local fileHandler, errorCode = io.open( filePath, "rb" )
        if fileHandler == nil then
            print( "Read failed from file"..filePath.." with error: "..errorCode )
            return ""
        end
        
        local text = fileHandler:read("*all")
        fileHandler:close()
        
        local DES56 = require("DES56")
        local key = 'gooddoggy'
        local encoded = DES56.crypt( text, key )

        fileHandler, errorCode = io.open( "gameEncodec.bin", "wb" )
        if fileHandler == nil then
            print( "Read failed from file".."gameEncodec.bin".." with error: "..errorCode )
            return ""
        end
        fileHandler:write( encoded )
        fileHandler:close()
    end
end

function decrypt()
    
    local fileUtils = CCFileUtils:sharedFileUtils()
    local filePath = fileUtils:fullPathForFilename( "game.bin" )
    if fileUtils:isFileExist( filePath ) then
        print( filePath )
        local fileHandler, errorCode = io.open( filePath, "rb" )
        if fileHandler == nil then
            print( "Read failed from file"..filePath.." with error: "..errorCode )
            return ""
        end
        
        local text = fileHandler:read("*all")
        fileHandler:close()
        print(text)
        
        local DES56 = require("DES56")
        local key = 'gooddoggy'
        local decoded = DES56.decrypt( text, key )
        print(decoded)
    end    
end
--]]


xpcall(main, __G__TRACKBACK__)
