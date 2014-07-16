module(..., package.seeall)

local Constants = require("scripts.Constants")
local SceneManager = require("scripts.SceneManager")
local Logic = require("scripts.Logic").getInstance()
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local ViewUtils = require("scripts.views.ViewUtils")
local CountryConfig = require("scripts.config.Country")


local mWidget
local mTextInput

local mTitleText
local mDescriptionText
local mMonth
local mOngoingChecked

function loadFrame()
    local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/CreateCompetition.json")
    mWidget = widget
    mWidget:registerScriptHandler( EnterOrExit )
    SceneManager.clearNAddWidget(widget)

    createTextInput()

    local ongoingCheckBox = tolua.cast( mWidget:getChildByName("Ongoing"), "CheckBox" )
    ongoingCheckBox:addTouchEventListener( ongoingEventHandler )

    if mTitleText ~= nil then
        mWidget:getChildByName( "TitleInput" ):getNodeByTag( 1 ):setText( mTitleText )
    end

    if mDescriptionText ~= nil then
        tolua.cast( mWidget:getChildByName( "DescriptionText" ), "Label" ):setText( mDescriptionText )
    end

    if mMonth ~= nil then
        mWidget:getChildByName( "MonthInput" ):getNodeByTag( 1 ):setText( mMonth )
    end

    if mOngoingChecked ~= nil then
        ongoingCheckBox:setSelectedState( mOngoingChecked )
        if mOngoingChecked then
            local monthInput = tolua.cast( mWidget:getChildByName( "MonthInput" ):getNodeByTag( 1 ), "CCEditBox" )
            monthInput:setEnabled( false )
            monthInput:setFontColor( ccc3( 125, 125, 125 ) )
        end
    end

    if Logic:getSelectedLeagues() == nil then
        Logic:setSelectedLeagues( CountryConfig.getAllLeagues() )
    end

    local confirmBt = widget:getChildByName("Create")
    confirmBt:addTouchEventListener( confirmEventHandler )
    local backBt = widget:getChildByName("Back")
    backBt:addTouchEventListener( backEventHandler )
    local selectLeagueBt = widget:getChildByName("SelectLeague")
    selectLeagueBt:addTouchEventListener( selectLeagueEventHandler )

    local desTextDisplay = mWidget:getChildByName("DescriptionText")
    desTextDisplay:addTouchEventListener( desInputEventHandler )
end

function EnterOrExit( eventType )
    if eventType == "enter" then
    elseif eventType == "exit" then
        mWidget = nil
        mTextInput = nil
    end
end

function ongoingEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        local ongoingCheckBox = tolua.cast( sender, "CheckBox" )
        local monthInput = tolua.cast( mWidget:getChildByName( "MonthInput" ):getNodeByTag( 1 ), "CCEditBox" )
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
            local numberOfMonth = tonumber( mWidget:getChildByName( "MonthInput" ):getNodeByTag( 1 ):getText() )
            local ongoingCheckBox = tolua.cast( mWidget:getChildByName("Ongoing"), "CheckBox" )
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
    local numberOfMonth = mWidget:getChildByName( "MonthInput" ):getNodeByTag( 1 ):getText()
    local ongoingCheckBox = tolua.cast( mWidget:getChildByName("Ongoing"), "CheckBox" )
    if ongoingCheckBox:getSelectedState() then
        numberOfMonth = -1
    end

    local name = mWidget:getChildByName( "TitleInput" ):getNodeByTag( 1 ):getText()
    local description = tolua.cast( mWidget:getChildByName( "DescriptionText" ), "Label" ):getStringValue()
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

function selectLeagueEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        -- Cache the content so that they will not got missing back from the league select UI.
        mTitleText = mWidget:getChildByName( "TitleInput" ):getNodeByTag( 1 ):getText()
        mDescriptionText = tolua.cast( mWidget:getChildByName( "DescriptionText" ), "Label" ):getStringValue()
        mMonth = mWidget:getChildByName( "MonthInput" ):getNodeByTag( 1 ):getText()

        local ongoingCheckBox = tolua.cast( mWidget:getChildByName("Ongoing"), "CheckBox" )
        mOngoingChecked = ongoingCheckBox:getSelectedState()

        EventManager:postEvent( Event.Enter_View_Selected_Leagues )
    end
end

function desInputEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        mTextInput:touchDownAction( sender, eventType )
    end
end

function createTextInput()
    -- Title
    local titleInput = ViewUtils.createTextInput( mWidget:getChildByName( "TitleInput" ), "Title", 520, 50 )
    titleInput:setFontColor( ccc3( 0, 0, 0 ) )
    titleInput:setTouchPriority( SceneManager.TOUCH_PRIORITY_MINUS_ONE )

    -- Description
    local container = mWidget:getChildByName("DescriptionInput")

    local inputDelegate = EditBoxDelegateForLua:create()
    inputDelegate:registerEventScriptHandler( EDIT_BOX_EVENT_TEXT_CHANGED, function ( textBox, text )
        local textDisplay = tolua.cast( mWidget:getChildByName("DescriptionText"), "Label" )
        textDisplay:setText( text )
    end )
    container:addNode( tolua.cast( inputDelegate, "CCNode" ) )

    mTextInput = CCEditBox:create( CCSizeMake( 550, 35 ), CCScale9Sprite:create() )
    container:addNode( mTextInput )
    mTextInput:setPosition( 550 / 2, 35 / 2 )
    mTextInput:setFontColor( ccc3( 0, 0, 0 ) )
    mTextInput:setVisible( false )
    mTextInput:setDelegate( inputDelegate.__CCEditBoxDelegate__ )

    -- DD/MM/YYYY
    local monthInput = ViewUtils.createTextInput( mWidget:getChildByName( "MonthInput" ), "0-24", 110, 50 )
    monthInput:setFontColor( ccc3( 0, 0, 0 ) )
    monthInput:setInputMode( kEditBoxInputModeNumeric )
    monthInput:setMaxLength( 2 )
    monthInput:setTouchPriority( SceneManager.TOUCH_PRIORITY_MINUS_ONE )
end