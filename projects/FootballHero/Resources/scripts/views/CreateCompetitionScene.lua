module(..., package.seeall)

local Constants = require("scripts.Constants")
local SceneManager = require("scripts.SceneManager")
local Logic = require("scripts.Logic").getInstance()
local EventManager = require("scripts.events.EventManager").getInstance()
local SelectedLeaguesScene = require("scripts.views.SelectedLeaguesScene")
local Event = require("scripts.events.Event").EventList
local ViewUtils = require("scripts.views.ViewUtils")
local CountryConfig = require("scripts.config.Country")
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local Header = require("scripts.views.HeaderFrame")

local BLANK_AREA_HEIGHT = 120

local mWidget
local mInputWidget
local mTextInput
local mAccessToken

function loadFrame( selectedLeagues )
    local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/CreateCompetition.json")
    mWidget = widget
    mWidget:registerScriptHandler( EnterOrExit )
    SceneManager.clearNAddWidget(mWidget)
    
    Header.loadFrame( widget, Constants.String.community.title_create_competition, true )

    local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView"), "ScrollView" )
    contentContainer:removeAllChildrenWithCleanup( true )

    local lbDetails = tolua.cast( mWidget:getChildByName("Label_Details"), "Label" )
    lbDetails:setText( Constants.String.community.title_details )

    mInputWidget = GUIReader:shareReader():widgetFromJsonFile("scenes/CreateCompetitionContent.json")
    contentContainer:addChild( mInputWidget )

    createTextInput( mInputWidget )

    local ongoingCheckBox = tolua.cast( mInputWidget:getChildByName("Ongoing"), "CheckBox" )
    ongoingCheckBox:addTouchEventListener( ongoingEventHandler )

    local facebookCheckBox = tolua.cast( mInputWidget:getChildByName("Facebook"), "CheckBox" )
    facebookCheckBox:addTouchEventListener( facebookEventHandler )

    -- labels
    local lbFBShare = tolua.cast( mInputWidget:getChildByName( "Label_FBShare"), "Label" )
    local lbGiveDesc = tolua.cast( mInputWidget:getChildByName( "Label_GiveDesc"), "Label" )
    local lbGiveTitle = tolua.cast( mInputWidget:getChildByName( "Label_GiveTitle"), "Label" )
    local lbHowLong = tolua.cast( mInputWidget:getChildByName( "Label_HowLong"), "Label" )
    local lbMonths = tolua.cast( mInputWidget:getChildByName( "Label_Months"), "Label" )
    local lbOngoing = tolua.cast( mInputWidget:getChildByName( "Label_Ongoing"), "Label" )
    local lbSelectLeague = tolua.cast( mInputWidget:getChildByName( "Label_SelectLeague"), "Label" )

    lbFBShare:setText( Constants.String.community.label_fb_share )
    lbGiveDesc:setText( Constants.String.community.label_give_desc )
    lbGiveTitle:setText( Constants.String.community.label_give_title )
    lbHowLong:setText( Constants.String.community.label_how_long )
    lbMonths:setText( Constants.String.community.label_months )
    lbOngoing:setText( Constants.String.community.label_ongoing )
    lbSelectLeague:setText( Constants.String.community.label_select_league )

    if selectedLeagues ~= nil then
        Logic:setSelectedLeagues( { selectedLeagues } )
    elseif Logic:getSelectedLeagues() == nil then
        Logic:setSelectedLeagues( CountryConfig.getAllLeagues() )
    end

    local existingContentHeight = mInputWidget:getSize().height + BLANK_AREA_HEIGHT
    SelectedLeaguesScene.loadFrame( contentContainer, Logic:getSelectedLeagues(), true, existingContentHeight )

    local confirmBt = tolua.cast( mWidget:getChildByName("Button_Create"), "Button" )
    confirmBt:addTouchEventListener( confirmEventHandler )
    confirmBt:setTitleText( Constants.String.button.create )

    local desTextDisplay = mInputWidget:getChildByName("DescriptionText")
    desTextDisplay:addTouchEventListener( desInputEventHandler )

    mAccessToken = nil
end

function EnterOrExit( eventType )
    if eventType == "enter" then
    elseif eventType == "exit" then
        mWidget = nil
        mInputWidget = nil
        mTextInput = nil
    end
end

function preSetContent()
    local description = Constants.String.community.desc_create_comp
    local title = Logic:getDisplayName()..Constants.String.community.title_create_comp

    mInputWidget:getChildByName( "TitleInput" ):getNodeByTag( 1 ):setText( title )
    tolua.cast( mInputWidget:getChildByName( "DescriptionText" ), "Label" ):setText( description )
    mTextInput:setText( description )
    tolua.cast( mInputWidget:getChildByName("Ongoing"), "CheckBox" ):setSelectedState( true )
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

function facebookEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        local facebookCheckBox = tolua.cast( sender, "CheckBox" )
        if facebookCheckBox:getSelectedState() == false then
            local doShare = function()
                print("Do Share")
                local handler = function( accessToken, success )
                    if success then
                        -- already has permission
                        if accessToken == nil then
                            mAccessToken = Logic:getFBAccessToken()
                        else
                            mAccessToken = accessToken
                        end
                    else
                        facebookCheckBox:setSelectedState( false )
                    end
                    
                    ConnectingMessage.selfRemove()
                end
                ConnectingMessage.loadFrame()
                FacebookDelegate:sharedDelegate():grantPublishPermission( "publish_actions", handler )
            end

            if Logic:getFbId() == false then
                local successHandler = function()
                    doShare()
                end
                local failedHandler = function()
                    print("FB connect failed.")
                    facebookCheckBox:setSelectedState( false )
                end
                EventManager:postEvent( Event.Do_FB_Connect_With_User, { successHandler, failedHandler } )
            else
                doShare()
            end
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
            EventManager:postEvent( Event.Show_Error_Message, { Constants.String.error.invalid_month } )
        end
    end
end

function sendCreateCompetition()
    local numberOfMonth = mInputWidget:getChildByName( "MonthInput" ):getNodeByTag( 1 ):getText()
    local ongoingCheckBox = tolua.cast( mInputWidget:getChildByName("Ongoing"), "CheckBox" )
    local facebookCheckBox = tolua.cast( mInputWidget:getChildByName("Facebook"), "CheckBox" )
    if ongoingCheckBox:getSelectedState() then
        numberOfMonth = -1
    end

    local name = mInputWidget:getChildByName( "TitleInput" ):getNodeByTag( 1 ):getText()
    local description = tolua.cast( mInputWidget:getChildByName( "DescriptionText" ), "Label" ):getStringValue()
    local selectedLeagues = Logic:getSelectedLeagues() or {}
    local allLeaguesQualify = Logic:getAllLeaguesQualify() or false

    EventManager:postEvent( Event.Do_Create_Competition, { name, description, numberOfMonth, selectedLeagues, facebookCheckBox:getSelectedState(), mAccessToken, allLeaguesQualify } )
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
    mTextInput:setVisible( false )
    mTextInput:setDelegate( inputDelegate.__CCEditBoxDelegate__ )

    -- DD/MM/YYYY
    local monthInput = ViewUtils.createTextInput( widget:getChildByName( "MonthInput" ), "", 520, 50 )
    monthInput:setInputMode( kEditBoxInputModeNumeric )
    monthInput:setMaxLength( 2 )
    monthInput:setTouchPriority( SceneManager.TOUCH_PRIORITY_MINUS_ONE )
end