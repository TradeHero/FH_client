module(..., package.seeall)

local Constants = require("scripts.Constants")
local SceneManager = require("scripts.SceneManager")
local Navigator = require("scripts.views.Navigator")
local Logic = require("scripts.Logic").getInstance()
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local MatchCenterConfig = require("scripts.config.MatchCenter")

local mWidget
local mTextInput
local mMatch

function loadFrame()
    
    mMatch = Logic:getSelectedMatch()
    
	mWidget = GUIReader:shareReader():widgetFromJsonFile("scenes/MatchCenterDiscussionsPostScene.json")
    mWidget:registerScriptHandler( EnterOrExit )
    SceneManager.clearNAddWidget( mWidget )
    SceneManager.setKeypadBackListener( keypadBackEventHandler )
    
    Navigator.loadFrame( mWidget )

    local title = tolua.cast( mWidget:getChildByName("Label_Title"), "Label" )
    title:setText( Constants.String.match_center.title_discussion )

    local backBt = mWidget:getChildByName("Button_Back")
    backBt:addTouchEventListener( backEventHandler )

    local postBt = mWidget:getChildByName("Button_Post")
    postBt:addTouchEventListener( postEventHandler )

    createTextInput()
end

function EnterOrExit( eventType )
    if eventType == "enter" then
    elseif eventType == "exit" then
        mWidget = nil
        mTextInput = nil
    end
end

function backEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        keypadBackEventHandler()
    end
end

function keypadBackEventHandler()
    EventManager:popHistory()
end

function postEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
    	local description = tolua.cast( mWidget:getChildByName( "Panel_Text" ), "Label" ):getStringValue()
        EventManager:postEvent( Event.Do_Make_Discussion_Post, { mMatch["Id"], description } )
    end
end

function createTextInput()
    local textDisplay = tolua.cast( mWidget:getChildByName("Panel_Text"), "Label" )
    textDisplay:addTouchEventListener( inputEventHandler )

    local container = mWidget:getChildByName("Panel_Input")

    local inputDelegate = EditBoxDelegateForLua:create()
    inputDelegate:registerEventScriptHandler( EDIT_BOX_EVENT_TEXT_CHANGED, function ( textBox, text )
        textDisplay:setText( text )
    end )
    container:addNode( tolua.cast( inputDelegate, "CCNode" ) )

    mTextInput = CCEditBox:create( CCSizeMake( 600, 35 ), CCScale9Sprite:create() )
    container:addNode( mTextInput )
    mTextInput:setPosition( 600 / 2, 60 / 2 )
    mTextInput:setVisible( false )
    mTextInput:setDelegate( inputDelegate.__CCEditBoxDelegate__ )
end

function inputEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        mTextInput:touchDownAction( sender, eventType )
    end
end