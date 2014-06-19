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
local mDay
local mMonth
local mYear

function loadFrame()
    local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/CreateCompetition.json")
    mWidget = widget
    mWidget:registerScriptHandler( EnterOrExit )
    SceneManager.clearNAddWidget(widget)

    createTextInput()

    if mTitleText ~= nil then
        mWidget:getChildByName( "TitleInput" ):getNodeByTag( 1 ):setText( mTitleText )
    end

    if mDescriptionText ~= nil then
        tolua.cast( mWidget:getChildByName( "DescriptionText" ), "Label" ):setText( mDescriptionText )
    end

    if mDay ~= nil then
        mWidget:getChildByName( "DayInput" ):getNodeByTag( 1 ):setText( mDay )
    end

    if mMonth ~= nil then
        mWidget:getChildByName( "MonthInput" ):getNodeByTag( 1 ):setText( mMonth )
    end

    if mYear ~= nil then
        mWidget:getChildByName( "YearInput" ):getNodeByTag( 1 ):setText( mYear )
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

function confirmEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        -- Check the date
        local checkDate = function()
            local endTime = os.time{ year = tonumber( mWidget:getChildByName( "DayInput" ):getNodeByTag( 1 ):getText() ), 
                                    month = tonumber( mWidget:getChildByName( "MonthInput" ):getNodeByTag( 1 ):getText() ), 
                                    day = tonumber( mWidget:getChildByName( "YearInput" ):getNodeByTag( 1 ):getText() ),
                                    hour = 0 }
            local name = mWidget:getChildByName( "TitleInput" ):getNodeByTag( 1 ):getText()
            local description = tolua.cast( mWidget:getChildByName( "DescriptionText" ), "Label" ):getStringValue()
            local startTime = os.time()
            local selectedLeagues = Logic:getSelectedLeagues() or {}

            EventManager:postEvent( Event.Do_Create_Competition, { name, description, startTime, endTime, selectedLeagues } )
        end

        local errorHandler = function( msg )
            EventManager:postEvent( Event.Show_Error_Message, { "Date format is not correct." } )
        end

        xpcall( checkDate, errorHandler )
    end
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
        mDay = mWidget:getChildByName( "DayInput" ):getNodeByTag( 1 ):getText()
        mMonth = mWidget:getChildByName( "MonthInput" ):getNodeByTag( 1 ):getText()
        mYear = mWidget:getChildByName( "YearInput" ):getNodeByTag( 1 ):getText()

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
    local dayInput = ViewUtils.createTextInput( mWidget:getChildByName( "DayInput" ), "DD", 110, 50 )
    dayInput:setFontColor( ccc3( 0, 0, 0 ) )
    dayInput:setInputMode( kEditBoxInputModeNumeric )
    dayInput:setMaxLength( 2 )
    dayInput:setTouchPriority( SceneManager.TOUCH_PRIORITY_MINUS_ONE )

    local monthInput = ViewUtils.createTextInput( mWidget:getChildByName( "MonthInput" ), "MM", 110, 50 )
    monthInput:setFontColor( ccc3( 0, 0, 0 ) )
    monthInput:setInputMode( kEditBoxInputModeNumeric )
    monthInput:setMaxLength( 2 )
    monthInput:setTouchPriority( SceneManager.TOUCH_PRIORITY_MINUS_ONE )

    local yearInput = ViewUtils.createTextInput( mWidget:getChildByName( "YearInput" ), "YYYY", 150, 50 )
    yearInput:setFontColor( ccc3( 0, 0, 0 ) )
    yearInput:setInputMode( kEditBoxInputModeNumeric )
    yearInput:setMaxLength( 4 )
    yearInput:setTouchPriority( SceneManager.TOUCH_PRIORITY_MINUS_ONE )
end