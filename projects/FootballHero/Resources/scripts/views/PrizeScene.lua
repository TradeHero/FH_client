module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local Constants = require("scripts.Constants")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList

local mWidget

function loadFrame(mToken)
    local widget = SceneManager.secondLayerWidgetFromJsonFile("scenes/PrizeFrame.json")
    mWidget = widget
    mWidget:registerScriptHandler( EnterOrExit )
    SceneManager.clearNAddWidget( widget )
    SceneManager.clearKeypadBackListener()
    SceneManager.setKeypadBackListener( keypadBackEventHandler )

    widget = tolua.cast( widget, "Layout" )
    widget:setBackGroundImage( Constants.COMPETITION_IMAGE_PATH.. Constants.PrizeBgPrefix .. mToken ..".png" )

    local btnBack = mWidget:getChildByName("Button_Back")
    btnBack:addTouchEventListener( backEventHandler )

    local btnOk = mWidget:getChildByName("Button_OK")
    btnOk:addTouchEventListener( backEventHandler )

    local logo = tolua.cast( mWidget:getChildByName("Image_logo"), "ImageView" )
    logo:loadTexture( Constants.COMPETITION_IMAGE_PATH.. Constants.PrizeLogoPrefix .. mToken ..".png" )

    local item = tolua.cast( mWidget:getChildByName("Image_item"), "ImageView" ) 
    item:loadTexture( Constants.COMPETITION_IMAGE_PATH.. Constants.PrizeItemPrefix .. mToken ..".png" )
   
end

function EnterOrExit( eventType )
    if eventType == "enter" then
    elseif eventType == "exit" then
        mWidget = nil
    end
end

function isFrameShown()
    return mWidget ~= nil
end

function keypadBackEventHandler()
    EventManager:popHistory()
end

function backEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        keypadBackEventHandler()
    end
end
