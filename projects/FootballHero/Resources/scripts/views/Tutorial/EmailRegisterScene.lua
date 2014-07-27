module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local Constants = require("scripts.Constants")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList


local mWidget

local FADEIN_TIME = 0.5
local MOVE_TIME = 0.2

function loadFrame()
    mWidget = GUIReader:shareReader():widgetFromJsonFile("scenes/TutorialEmailRegister.json")
    mWidget:registerScriptHandler( EnterOrExit )
    SceneManager.addWidget( mWidget )
    mWidget:setPosition( ccp( Constants.GAME_WIDTH, 0 ) )

    local register = mWidget:getChildByName("register")
    register:addTouchEventListener( registerEventHandler )

    local backBt = mWidget:getChildByName("back")
    backBt:addTouchEventListener( backEventHandler )

    helperSetTouchEnabled( false )
end

function isFrameShown()
    return mWidget:getPositionX() == 0
end

function EnterOrExit( eventType )
    if eventType == "enter" then
    elseif eventType == "exit" then
        mWidget = nil
    end
end

function backEventHandler( sender,eventType )
    if eventType == TOUCH_EVENT_ENDED then
        EventManager:popHistory()
        sender:setTouchEnabled( false )
    end
end


function registerEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        
    end
end

function playMoveAnim( moveDirection, delayTime )
    local resultSeqArray = CCArray:create()
    if delayTime ~= nil and delayTime > 0 then
        resultSeqArray:addObject( CCDelayTime:create( delayTime ) )
    end
    if helperGetTouchEnabled() then
        resultSeqArray:addObject( CCCallFunc:create( function()
            helperSetTouchEnabled( false )
        end ) )
    end
    resultSeqArray:addObject( CCMoveBy:create( MOVE_TIME, ccp( Constants.GAME_WIDTH * moveDirection, 0 ) ) )
    if not helperGetTouchEnabled() then
        resultSeqArray:addObject( CCCallFunc:create( function()
            helperSetTouchEnabled( true )
        end ) )
    end

    mWidget:runAction( CCSequence:create( resultSeqArray ) )

    return MOVE_TIME
end

function helperSetTouchEnabled( enabled )
    local register = mWidget:getChildByName("register")
    register:setTouchEnabled( enabled )

    local backBt = mWidget:getChildByName("back")
    backBt:setTouchEnabled( enabled )
end

function helperGetTouchEnabled()
    local register = mWidget:getChildByName("register")
    return register:isTouchEnabled()
end