require "AudioEngine" 
require "Cocos2d"

-- for CCLuaEngine traceback
function __G__TRACKBACK__(msg)
    print("----------------------------------------")
    print("LUA ERROR: " .. tostring(msg) .. "\n")
    print(debug.traceback())
    print("----------------------------------------")
end

local function main()
    -- avoid memory leak
    collectgarbage("setpause", 100)
    collectgarbage("setstepmul", 5000)

    local cclog = function(...)
        print(string.format(...))
    end

    require "hello2"
    cclog("result is " .. myadd(3, 5))

    -- run
    local sceneGame = CCScene:create()
    CCDirector:sharedDirector():runWithScene(sceneGame)
    local layer = TouchGroup:create()
    sceneGame:addChild(layer)

    --[[ UI example --]]
    local widget = GUIReader:shareReader():widgetFromJsonFile("SceneOneUI.ExportJson")
    layer:addWidget(widget)

    --local textLabel = tolua.cast(widget:getChildByName("ImageView_22"):getChildByName("welcomeWord"), "Label")
    --textLabel:setText("Welcome to china\n欢迎来中国玩")

    --[[ Pure Anim example 
    CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo("fish070.png","fish070.plist","fish07.ExportJson")
    CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo("fish071.png","fish071.plist","fish07.ExportJson")
    CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo("fish072.png","fish072.plist","fish07.ExportJson")
    CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo("fish073.png","fish073.plist","fish07.ExportJson")
    CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo("fish074.png","fish074.plist","fish07.ExportJson")

    local animFrameEventHandler = function( sender, frameEventName, originFrameIndex, currentFrameIndex )
        print("animFrameEventHandler: "..frameEventName.."|"..originFrameIndex.."|"..currentFrameIndex)
    end

    local animMovementEventHandler = function( sender, movementType, movementID )
        if movementType == START then
            print("Anim start: "..movementID)
        elseif movementType == LOOP_COMPLETE then
            print("Anim loop end: "..movementID)
        end
    end
    
    local armature = CCArmature:create("fish07")
    armature:setPosition( ccp( 150, 200 ) )
    armature:getAnimation():setFrameEventCallFunc( animFrameEventHandler )
    armature:getAnimation():setMovementEventCallFunc( animMovementEventHandler )
    armature:getAnimation():playWithIndex(0)
    layer:addChild(armature)

        -- For the frameeventhandler, it seems the event would be triggered twice:
        -- One is that the frame marked by the event and the other occurs at the end of the animation.
    --]]


    --[[ UI anim example
    local uianimation_root = GUIReader:shareReader():widgetFromJsonFile("SampleUIAnimation.json")
    layer:addWidget(uianimation_root)

    ActionManager:shareManager():playActionByName("SampleUIAnimation.json", "Animation1")
    --]]

    --[[ Json config loading example
    local Json = require("json")
    local packageFilePath = "test001.json"
    local fileHandle, errorCode = io.open( packageFilePath, "r" )
    local text = fileHandle:read( "*all" )
    print("Text is "..text)
    fileHandle:close()

    local t_luaFileContent = Json.decode( text )
    for i,v in pairs(t_luaFileContent) do
        for m,n in pairs(v) do
            print(m..": "..n)
        end
    end
    --]]

    --[[ Load scene example & button event handler
    local sceneNode = SceneReader:sharedSceneReader():createNodeWithSceneFile("SceneOne.json")
    sceneGame:addChild(sceneNode)
    local bgNode = sceneNode:getChildByTag("10003")
    --bgNode:setScaleX(0.5)
    local bgComRender = tolua.cast(bgNode:getComponent("GUIComponent"), "CCComRender")
    local bgNode = tolua.cast(bgComRender:getNode(), "TouchGroup")
    local leftButton = bgNode:getWidgetByName("Button_23")

    local leftButtonEventHandler = function( sender,eventType )
        if eventType == TOUCH_EVENT_BEGAN then
            print("LEft button event begin")
        elseif eventType == TOUCH_EVENT_ENDED then
            print("LEft button event ended")
        end
    end

    leftButton:addTouchEventListener( leftButtonEventHandler )
    --]]

    --[[ Scene embedded config file load example
    local sceneNode = SceneReader:sharedSceneReader():createNodeWithSceneFile("SceneOne.json")
    sceneGame:addChild(sceneNode)
    local configObj = sceneNode:getChildByTag("10011")
    local config = tolua.cast(configObj:getComponent("CCComAttribute"), "CCComAttribute")
    print(config:getInt("x"))

        -- Seems not working properly since data editor cannot export pure object json format file.
    --]]

end

xpcall(main, __G__TRACKBACK__)
