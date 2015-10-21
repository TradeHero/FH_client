module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local Navigator = require("scripts.views.Navigator")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local Constants = require("scripts.Constants")

local mWidget

function loadFrame( response )
    mWidget = GUIReader:shareReader():widgetFromJsonFile("scenes/StoreFrame.json")
    mWidget:registerScriptHandler( EnterOrExit )
    SceneManager.clearNAddWidget( mWidget )
    SceneManager.clearKeypadBackListener()
    SceneManager.setKeypadBackListener( keypadBackEventHandler )

    local backBt = mWidget:getChildByName("Panel_Title"):getChildByName("Button_Back")
    backBt:addTouchEventListener( backEventHandler )

    Navigator.loadFrame( mWidget )

    initContent( response )
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

function backEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        keypadBackEventHandler()
    end
end

function keypadBackEventHandler()
    EventManager:popHistory()
end

function initContent( response )
    tolua.cast( mWidget:getChildByName("Panel_Title"):getChildByName("Label_Title"), "Label" ):setText( Constants.String.spinWheel.balance_title )

    local contentHeight = 0
    local layoutParameter = LinearLayoutParameter:create()
    layoutParameter:setGravity(LINEAR_GRAVITY_CENTER_VERTICAL)
 
    -- Prize Panel
    local container = mWidget:getChildByName("ScrollView")
    container:removeAllChildrenWithCleanup( true )

    for i = 1, 4 do
        local content = SceneManager.widgetFromJsonFile("scenes/StoreContentFrame.json")
 
        content:setLayoutParameter( layoutParameter )
        container:addChild( content )
        contentHeight = contentHeight + content:getSize().height
    end
    
 end



function refresh( moneyBalance )
end