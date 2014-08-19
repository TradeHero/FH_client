require "AudioEngine" 
require "Cocos2d"

-- for CCLuaEngine traceback
function __G__TRACKBACK__(msg)
    print("----------------------------------------")
    print("LUA ERROR: " .. tostring(msg) .. "\n")
    print(debug.traceback())
    print("----------------------------------------")

    if CCApplication:sharedApplication():getTargetPlatform() ~= kTargetWindows then
        cclog( msg )
        local DoLogReport = require("scripts.actions.DoLogReport")
        DoLogReport.reportError( errorDesc )
    end

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
    initPackageLoader( true )

    local sceneManager = require("scripts.SceneManager")
    sceneManager.init()

    local eventManager = require("scripts.events.EventManager").getInstance()
    local event = require("scripts.events.Event").EventList
    eventManager:postEvent( event.Check_Start_Tutorial )

    --eventManager:postEvent( event.Enter_Competition_Chat )
end

function initPackageLoader( decrypt )
    local fileUtils = CCFileUtils:sharedFileUtils()
    local filePath = fileUtils:fullPathForFilename( "game.bin" )
    local Json = require("json")
    if fileUtils:isFileExist( filePath ) then
        --[[
        local fileHandler, errorCode = io.open( filePath, "rb" )
        if fileHandler == nil then
            print( "Read failed from file "..filePath.." with error: "..errorCode )
            return ""
        end
        
        local text = fileHandler:read("*all")
        fileHandler:close()
        
        -- For crypted file.
        if decrypt then
            local DES56 = require("DES56")
            local key = tostring( "tuantuan" )
            text = DES56.decrypt( text, key )
        end
        --]]
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

--[[
function initClientVersion( version )
    local recordedVersion = CCUserDefault:sharedUserDefault():getStringForKey( KEY_OF_VERSION )
    if recordedVersion == nil or recordedVersion == "" then
        CCUserDefault:sharedUserDefault():setStringForKey( KEY_OF_VERSION, version )
    end
end

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
    local filePath = fileUtils:fullPathForFilename( "ttt.txt" )
    if fileUtils:isFileExist( filePath ) then
        print( filePath )
        local fileHandler, errorCode = io.open( filePath, "rb" )
        if fileHandler == nil then
            print( "Read failed from file"..filePath.." with error: "..errorCode )
            return ""
        end
        
        local text = fileHandler:read("*all")
        fileHandler:close()
        text = tostring( text )
        
        local DES56 = require("DES56")
        local key = tostring( "tuantuan" )
        local decoded = DES56.decrypt( text, key )
        print(decoded)
    end    
end
--]]

xpcall(main, __G__TRACKBACK__)
