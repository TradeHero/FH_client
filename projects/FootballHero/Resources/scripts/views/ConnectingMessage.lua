module(..., package.seeall)

local Constants = require("scripts.Constants")
local SceneManager = require("scripts.SceneManager")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList

local mWidget
local mWaitingArmature

function loadFrame( message )
    if mWidget == nil then
        local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/ConnectingMessage.json")

        widget:addTouchEventListener( onFrameTouch )
        mWidget = widget
        mWidget:registerScriptHandler( EnterOrExit )
        SceneManager.addWidget( widget )

        CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo("anims/waiting0.png","anims/waiting0.plist","anims/waiting.ExportJson")

        mWaitingArmature = CCArmature:create("waiting")
        mWaitingArmature:setPosition( ccp( 220, 646 ) )
        mWaitingArmature:getAnimation():playWithIndex(0)
        mWidget:addNode(mWaitingArmature)

    end
    setMessage( message )
end

function EnterOrExit( eventType )
    if eventType == "enter" then
    elseif eventType == "exit" then
        mWidget = nil
        mWaitingArmature:getAnimation():stop()
        mWaitingArmature = nil
    end
end

function setMessage( message )
    message = message or "Connecting..."
    print( "Load connecting message scene:"..message )
    local messageLabel = tolua.cast( mWidget:getChildByName("connectMessage"), "Label" )
    messageLabel:setText( message )
end

function selfRemove()
    SceneManager.removeWidget( mWidget )
end

function onFrameTouch( sender, eventType )
    -- Do nothing, just block touch event.
end