
--require "Cocos2d"

-- for CCLuaEngine traceback
function __G__TRACKBACK__(msg)
    CCLuaLog("----------------------------------------")
    CCLuaLog("LUA ERROR: " .. tostring(msg) .. "\n")
    CCLuaLog(debug.traceback())
    CCLuaLog("----------------------------------------")

    local errorDesc = "\nLUA ERROR: "..msg .. "\n"
    errorDesc = errorDesc.."\n"..debug.traceback()
    if CCApplication:sharedApplication():getTargetPlatform() ~= kTargetWindows then
        local DoLogReport = require("scripts.actions.DoLogReport")
        DoLogReport.reportError( errorDesc )
    else
        CCMessageBox( errorDesc, "LUA ERROR: " )    
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

    --local st = os.clock()
    --initPackageLoader( false )
    --CCLuaLog( "initPackageLoader took: "..( os.clock() - st ) )

    require "AudioEngine" 

    AudioEngine.playEffect( AudioEngine.INTRO )

    local sceneManager = require("scripts.SceneManager")
    sceneManager.init()

    local eventManager = require("scripts.events.EventManager").getInstance()
    local event = require("scripts.events.Event").EventList
    eventManager:postEvent( event.Check_Start_Tutorial )

    --eventManager:postEvent( event.Export_Unlocalized_String )
    --eventManager:postEvent( event.Import_Localized_String )
end

function initPackageLoader( decrypt )
    local fileUtils = CCFileUtils:sharedFileUtils()
    local filePath = fileUtils:fullPathForFilename( "game.bin" )
    local Json = require("json")
    if fileUtils:isFileExist( filePath ) then
        local text
        if decrypt then
            text = fileUtils:getDecryptedFileData( filePath, "rb" )
        else
            text = fileUtils:getFileData( filePath, "r", 0 )
        end

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
            return assert( loadstring( destLuaFile, path ) )
        end

        table.insert( package.loaders, 1, loadFromCompact )
    end
end

xpcall(main, __G__TRACKBACK__)
