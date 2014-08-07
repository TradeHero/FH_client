module(..., package.seeall)

local Constants = require("scripts.Constants")
local SceneManager = require("scripts.SceneManager")
local Logic = require("scripts.Logic").getInstance()
local EventManager = require("scripts.events.EventManager").getInstance()
local SelectedLeaguesScene = require("scripts.views.SelectedLeaguesScene")
local Event = require("scripts.events.Event").EventList
local ViewUtils = require("scripts.views.ViewUtils")
local CountryConfig = require("scripts.config.Country")


local BLANK_AREA_HEIGHT = 120

local mWidget
local mInputWidget
local mTextInput

function loadFrame()
    local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/CreateCompetition.json")
    mWidget = widget
    mWidget:registerScriptHandler( EnterOrExit )
    SceneManager.clearNAddWidget(mWidget)

    local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView"), "ScrollView" )
    contentContainer:removeAllChildrenWithCleanup( true )

    mInputWidget = GUIReader:shareReader():widgetFromJsonFile("scenes/CreateCompetitionContent.json")
    contentContainer:addChild( mInputWidget )

    createTextInput( mInputWidget )

    local ongoingCheckBox = tolua.cast( mInputWidget:getChildByName("Ongoing"), "CheckBox" )
    ongoingCheckBox:addTouchEventListener( ongoingEventHandler )

    if Logic:getSelectedLeagues() == nil then
        Logic:setSelectedLeagues( CountryConfig.getAllLeagues() )
    end

    local existingContentHeight = mInputWidget:getSize().height + BLANK_AREA_HEIGHT
    print( existingContentHeight )
    SelectedLeaguesScene.loadFrame( mWidget, Logic:getSelectedLeagues(), true, existingContentHeight )

    local confirmBt = mWidget:getChildByName("Create")
    confirmBt:addTouchEventListener( confirmEventHandler )
    local backBt = mWidget:getChildByName("Back")
    backBt:addTouchEventListener( backEventHandler )

    local desTextDisplay = mInputWidget:getChildByName("DescriptionText")
    desTextDisplay:addTouchEventListener( desInputEventHandler )
end

function EnterOrExit( eventType )
    if eventType == "enter" then
    elseif eventType == "exit" then
        mWidget = nil
        mInputWidget = nil
        mTextInput = nil
    end
end

function ongoingEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        local ongoingCheckBox = tolua.cast( sender, "CheckBox" )
        local monthInput = tolua.cast( mInputWidget:getChildByName( "MonthInput" ):getNodeByTag( 1 ), "CCEditBox" )
        if ongoingCheckBox:getSelectedState() == true then
            monthInput:setEnabled( true )
            monthInput:setFontColor( ccc3( 0, 0, 0 ) )
        else
            monthInput:setEnabled( false )
            monthInput:setFontColor( ccc3( 125, 125, 125 ) )
        end
    end
end

function confirmEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        -- Check the date
        local checkPass = true
        local checkDate = function()
            local numberOfMonth = tonumber( mInputWidget:getChildByName( "MonthInput" ):getNodeByTag( 1 ):getText() )
            local ongoingCheckBox = tolua.cast( mInputWidget:getChildByName("Ongoing"), "CheckBox" )
            if ongoingCheckBox:getSelectedState() == false and numberOfMonth == nil then
                checkPass = false
            end
        end

        local errorHandler = function( msg )
            print( msg )
            print(debug.traceback())
            checkPass = false
        end

        xpcall( checkDate, errorHandler )
        
        if checkPass then
            sendCreateCompetition()
        else
            EventManager:postEvent( Event.Show_Error_Message, { "Number of month is not number." } )
        end
    end
end

function sendCreateCompetition()
    local numberOfMonth = mInputWidget:getChildByName( "MonthInput" ):getNodeByTag( 1 ):getText()
    local ongoingCheckBox = tolua.cast( mInputWidget:getChildByName("Ongoing"), "CheckBox" )
    if ongoingCheckBox:getSelectedState() then
        numberOfMonth = -1
    end

    local name = mInputWidget:getChildByName( "TitleInput" ):getNodeByTag( 1 ):getText()
    local description = tolua.cast( mInputWidget:getChildByName( "DescriptionText" ), "Label" ):getStringValue()
    local selectedLeagues = Logic:getSelectedLeagues() or {}

    EventManager:postEvent( Event.Do_Create_Competition, { name, description, numberOfMonth, selectedLeagues } )
end

function backEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        EventManager:popHistory()
    end
end

function cancelEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        SceneManager.removeWidget( mWidget )
    end
end

function desInputEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        mTextInput:touchDownAction( sender, eventType )
    end
end

function createTextInput( widget )
    -- Title
    local titleInput = ViewUtils.createTextInput( widget:getChildByName( "TitleInput" ), "Title", 520, 50 )
    titleInput:setFontColor( ccc3( 0, 0, 0 ) )
    titleInput:setTouchPriority( SceneManager.TOUCH_PRIORITY_MINUS_ONE )

    -- Description
    local container = widget:getChildByName("DescriptionInput")

    local inputDelegate = EditBoxDelegateForLua:create()
    inputDelegate:registerEventScriptHandler( EDIT_BOX_EVENT_TEXT_CHANGED, function ( textBox, text )
        local textDisplay = tolua.cast( widget:getChildByName("DescriptionText"), "Label" )
        textDisplay:setText( text )
    end )
    container:addNode( tolua.cast( inputDelegate, "CCNode" ) )

    mTextInput = CCEditBox:create( CCSizeMake( 540, 35 ), CCScale9Sprite:create() )
    container:addNode( mTextInput )
    mTextInput:setPosition( 540 / 2, 35 / 2 )
    mTextInput:setFontColor( ccc3( 0, 0, 0 ) )
    mTextInput:setVisible( false )
    mTextInput:setDelegate( inputDelegate.__CCEditBoxDelegate__ )

    -- DD/MM/YYYY
    local monthInput = ViewUtils.createTextInput( widget:getChildByName( "MonthInput" ), "Enter number of months", 520, 50 )
    monthInput:setFontColor( ccc3( 0, 0, 0 ) )
    monthInput:setInputMode( kEditBoxInputModeNumeric )
    monthInput:setMaxLength( 2 )
    monthInput:setTouchPriority( SceneManager.TOUCH_PRIORITY_MINUS_ONE )
end