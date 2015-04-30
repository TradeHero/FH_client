module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local Constants = require("scripts.Constants")
local Navigator = require("scripts.views.Navigator")
local Header = require("scripts.views.Lucky8Header")
local TeamConfig = require("scripts.config.Team")
local RequestUtils = require("scripts.RequestUtils")
local Logic = require("scripts.Logic").getInstance()
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local Json = require("json")

local mWidget 
local mScrollViewHeight
local mTabButtons
local mBtnSubmits

local mMatchlistCells
local mCurrentRoundId

local mYourPicksData;

local CELL_RES_STRING = 
{
    "scenes/YourPicksCell.json",
    "scenes/Lucky8MatchListCell.json",
    "scenes/Lucky8RuleCell.json",
}

local MATHLISTCELL_PICK_RES = {
    pick = Constants.LUCKY8_IMAGE_PATH .. "img-pick.png",
    notpick = Constants.LUCKY8_IMAGE_PATH .. "img-notpick.png",
}

-- cell info
local SingleCell = {
    isTeam1Selected,
    isDrawSelected,
    isTeam2Selected,
}

local mArrMatchData;

local mMatchlistCellInfo

function helperInitPickscell( cell, cellInfo )
    local PredictionsCorrect = cellInfo["PredictionsCorrect"]
    local PredictionsMade = cellInfo["PredictionsMade"]
    local StartTime = cellInfo["StartTime"]
    local Settled = cellInfo["Settled"]
    local curTime = os.time()
    local panelBg = cell:getChildByName( "Panel_Bg" )
    local imagePick = tolua.cast( panelBg:getChildByName("Image_Pick"), "ImageView" )
    local txtNumber = tolua.cast( imagePick:getChildByName("TextField_Number"), "TextField" )
    local txtDate = tolua.cast( panelBg:getChildByName( "TextField_Date" ), "TextField" )
    txtDate:setText( os.date("%b %d, %A", StartTime) )
    local txtDateMiddle = tolua.cast( panelBg:getChildByName( "TextField_Date_Middle" ), "TextField" )
    txtDateMiddle:setText( os.date("%b %d, %A", StartTime) )

    local imageChecked = panelBg:getChildByName("Image_Check")
    if Settled == false then
        imagePick:loadTexture( "images/lucky8/lucky8_img_newresult.png" )
        txtNumber:setText( " " )
        local txtResult = tolua.cast( panelBg:getChildByName("TextField_Result"), "TextField" )
        txtResult:setVisible( false )
        txtDate:setVisible( false )
        txtDateMiddle:setVisible( true )
        imageChecked:setVisible( false )
    else
        imagePick:loadTexture( "images/lucky8/lucky8_img_newresult.png" )
        local txt = string.format("%d", PredictionsCorrect) .. "/" .. string.format("%d", PredictionsMade)
        txtNumber:setText( txt )
        local txtResult = tolua.cast( panelBg:getChildByName("TextField_Result"), "TextField" )
        txtResult:setVisible( true )
        txtResult:setText( "You've got " .. string.format("%d", PredictionsCorrect) .. " out of " .. string.format("%d", PredictionsMade) .. " games correct.")
        txtDate:setVisible( true )
        txtDateMiddle:setVisible( false )

        local Checked = cellInfo["Checked"]
        if Checked == false then
            imageChecked:setVisible( true )
        else
            imageChecked:setVisible( false )
        end
    end
end

function updateYourPicks( jsonResponse )
    mYourPicksData = {}
    local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView_Content"), "ScrollView" )
    contentContainer:removeAllChildrenWithCleanup( true )
    mScrollViewHeight = 0
    
    local Rounds = jsonResponse["Rounds"]
    for k,v in pairs( Rounds ) do
        local cell = SceneManager.widgetFromJsonFile( CELL_RES_STRING[1] )
        cell:addTouchEventListener( enterHistory )
        contentContainer:addChild( cell )
        helperInitPickscell( cell, v )
        mScrollViewHeight = mScrollViewHeight + cell:getSize().height
        updateScrollView( mScrollViewHeight, contentContainer )

        local cellData = {
            kCell = cell,
            cellInfo = v,
        }

        table.insert( mYourPicksData, cellData )
    end
end

function loadFrame( params )
    mCurrentRoundId = {}
    local widget = GUIReader:shareReader():widgetFromJsonFile( "scenes/lucky8MainScene.json" )
    mWidget = widget
    widget:registerScriptHandler( EnterOrExit )
    SceneManager.clearNAddWidget( widget )
    Header.loadFrame( widget, Constants.String.lucky8.lucky8_title, true )
    Navigator.loadFrame( widget )

    local btnSubmit = tolua.cast( mWidget:getChildByName("Button_Submit"), "Button" )
    mBtnSubmits = btnSubmit
    btnSubmit:addTouchEventListener( eventSubmit )
    local submitTitle = tolua.cast( btnSubmit:getChildByName("TextField_Submit"), "TextField" )
    submitTitle:setText( Constants.String.lucky8.btn_submit_title )

    initButtonInfo( )
    initScrollView( params )
end

function eventSubmit( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        local odds = {}
        for k,v in pairs( mMatchlistCellInfo ) do
            local selectedIndex = v["selectedIndex"]
            local StartTime = v["data"]["StartTime"]
            if os.time() < StartTime then
                if selectedIndex ~= 0 then
                    table.insert( odds, selectedIndex )
                else
                    EventManager:postEvent( Event.Show_Error_Message, { Constants.String.lucky8.select_all_matches } )
                    return 
                end
            end
        end

        local requestContent = {
            RoundId = mCurrentRoundId[1]["roundid"],
            FHOddIds = odds,
        }

        local requestContentText = Json.encode( requestContent )
        EventManager:postEvent( Event.Do_Lucky8_Submit, requestContentText )
    end
end

function refreshPage( data )
    initScrollView( data )
end

function helpInitMatchListcell( cell, cellInfo, Played )
    local panelFade = cell:getChildByName("Panel_Fade")
    local imageLock = panelFade:getChildByName("Image_Lock")
    imageLock:setVisible( Played )

    local textTeamHome = tolua.cast( panelFade:getChildByName("TextField_TeamName1"), "TextField" )
    local homeTeamId = cellInfo["Home"]["TeamId"]
    textTeamHome:setText( TeamConfig.getTeamName( TeamConfig.getConfigIdByKey( homeTeamId ) ) ) 
    local textTeamAway = tolua.cast( panelFade:getChildByName("TextField_TeamName2"), "TextField" )
    local awayTeamId = cellInfo["Away"]["TeamId"]
    textTeamAway:setText( TeamConfig.getTeamName(TeamConfig.getConfigIdByKey( awayTeamId )) )

    local LeagueName = tolua.cast( panelFade:getChildByName("TextField_Legaue"), "TextField" )
    LeagueName:setText( cellInfo["LeagueName"] )

    local team1 = tolua.cast( panelFade:getChildByName("Image_Team1"), "ImageView" )
    team1:loadTexture( TeamConfig.getLogo( TeamConfig.getConfigIdByKey(homeTeamId)) )
    local team2 = tolua.cast( panelFade:getChildByName("Image_Team2"), "ImageView" )
    team2:loadTexture( TeamConfig.getLogo( TeamConfig.getConfigIdByKey(awayTeamId)) ) 

    local timeDisplay = os.date( "%H:%M", cellInfo["StartTime"] )
    local textFieldTime = tolua.cast( panelFade:getChildByName("TextField_Time"), "TextField" )
    textFieldTime:setText( timeDisplay )

    local labelScore = tolua.cast( panelFade:getChildByName("Label_Score_0" ), "Label" )
    labelScore:setText( "-:-" )

    local btnHome = tolua.cast( panelFade:getChildByName( "Button_Home" ), "Button" )
    btnHome:addTouchEventListener( eventSelectWhoWin )
    local btnAway = tolua.cast( panelFade:getChildByName( "Button_Away" ), "Button" )
    btnAway:addTouchEventListener( eventSelectWhoWin )
    local btnDrawBig = tolua.cast( panelFade:getChildByName("Button_Draw_Big"), "Button" )
    btnDrawBig:addTouchEventListener( eventSelectWhoWin )

    local btn1 = tolua.cast( panelFade:getChildByName("Button_1"), "Button" )
    local btn2 = tolua.cast( panelFade:getChildByName("Button_2"), "Button" )
    local btnDraw = tolua.cast( panelFade:getChildByName("Button_Draw"), "Button" )

    if Played == true then
        btnHome:setTouchEnabled( false )
        btnDrawBig:setTouchEnabled( false )
        btnAway:setTouchEnabled( false )

        local PickId = cellInfo["PickId"]
        if PickId == cellInfo["Home"]["FHOddId"] then
            btn1:setBright( false )
            btn2:setBright( true )
            btnDraw:setBright( true )
        elseif PickId == cellInfo["Away"]["FHOddId"] then
            btn1:setBright( true )
            btn2:setBright( false )
            btnDraw:setBright( true )
        elseif PickId == cellInfo["Draw"]["FHOddId"] then
            btn1:setBright( true )
            btn2:setBright( true )
            btnDraw:setBright( false )
        else 
            btn1:setBright( true )
            btn2:setBright( true )
            btnDraw:setBright( true )
        end
        if os.time() > cellInfo["StartTime"] then
            cell:setOpacity( 125 )
            cell:setCascadeOpacityEnabled( true )
        else
            cell:setOpacity( 255 )
            cell:setCascadeOpacityEnabled( true )
        end
    else
        local imageStart = tolua.cast( panelFade:getChildByName("Image_Started"), "ImageView" )
        if os.time() > cellInfo["StartTime"] then
            imageStart:setVisible( true )
            textFieldTime:setVisible( false )
            btnHome:setTouchEnabled( false )
            btnDrawBig:setTouchEnabled( false )
            btnAway:setTouchEnabled( false )
        else
            imageStart:setVisible( false )
            textFieldTime:setVisible( true )
            btnHome:setTouchEnabled( true )
            btnDrawBig:setTouchEnabled( true )
            btnAway:setTouchEnabled( true )
        end
    end

    local cellData = {
        btn_home     = btnHome,
        btn_away     = btnAway,
        btn_draw_big = btnDrawBig,
        btn_one      = btn1,
        btn_two      = btn2,
        btn_draw     = btnDraw,
        data         = cellInfo,
        selectedIndex = 0,
    } 
    table.insert( mMatchlistCellInfo, cellData )
end

function eventSelectWhoWin( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        for k,v in pairs( mMatchlistCellInfo ) do
            local btn1 = v["btn_one"]
            local btnHome = v["btn_home"]
            if btnHome == sender then
                btn1:setBright( false )
                v["selectedIndex"] = v["data"]["Home"]["FHOddId"]
                v["btn_two"]:setBright( true )
                v["btn_draw"]:setBright( true )
            end

            local btn2 = v["btn_two"]
            local btnAway = v["btn_away"]
            if btnAway == sender then
                btn2:setBright( false )
                v["selectedIndex"] = v["data"]["Away"]["FHOddId"]
                v["btn_one"]:setBright( true )
                v["btn_draw"]:setBright( true )
            end

            local btnDraw = v["btn_draw"]
            local btnDrawBig = v["btn_draw_big"]
            if btnDrawBig == sender then
                btnDraw:setBright( false )
                v["selectedIndex"] = v["data"]["Draw"]["FHOddId"]
                v["btn_one"]:setBright( true )
                v["btn_two"]:setBright( true )
            end
        end
    end
end

function initScrollView( data )
    local games = data["Games"]
    table.insert( mCurrentRoundId, { roundid = data["RoundId"] } )
    local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView_Content"), "ScrollView" )
    contentContainer:removeAllChildrenWithCleanup( true )
    local Played = data["Played"]
    local btnSubmit = tolua.cast( mWidget:getChildByName("Button_Submit"), "Button" )
    if Played == true then
        btnSubmit:setBright( false )
        btnSubmit:setTouchEnabled( false )
    else
        btnSubmit:setBright( true )
        btnSubmit:setTouchEnabled( true )
    end

    mMatchlistCellInfo = {}
    mScrollViewHeight = 0
    for k,v in pairs( games ) do
        local matchContent = SceneManager.widgetFromJsonFile( "scenes/Lucky8MatchListCell.json" )
        helpInitMatchListcell( matchContent, v, Played )
        contentContainer:addChild( matchContent )
        mScrollViewHeight = mScrollViewHeight + matchContent:getSize().height
        updateScrollView( mScrollViewHeight, content )
    end
end

function updateScrollView( scrollViewHeight, content )
    local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView_Content"), "ScrollView" )
    contentContainer:setInnerContainerSize( CCSize:new(0, scrollViewHeight) )
    local layout = tolua.cast( contentContainer, "Layout" )
    layout:requestDoLayout()
end

function enterHistory( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        for k,v in pairs(mYourPicksData) do
            local cell = v["kCell"]
            if cell == sender then
                local cellInfo = v["cellInfo"]
                EventManager:postEvent( Event.Enter_Lucky8History, cellInfo )
            end
        end
    end
end

function changeTab( index )
    if index == 1 or index == 3 then
        mBtnSubmits:setVisible( false )
    else
        mBtnSubmits:setVisible( true )
    end

    if index == 1 then
        -- requestLucky8Rounds()
        EventManager:postEvent( Event.Do_Lucky8_Rounds, {updateYourPicks} )
    elseif index == 2 then
        EventManager:postEvent( Event.Enter_Lucky8 )
    else
        local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView_Content"), "ScrollView" )
        contentContainer:removeAllChildrenWithCleanup( true )
        mScrollViewHeight = 0
        local cell = SceneManager.widgetFromJsonFile( CELL_RES_STRING[index] )
        local text = tolua.cast( cell:getChildByName("TextField_Rule"), "TextField" )
        text:setText( Constants.String.lucky8.lucky8_rule )
        contentContainer:addChild( cell )
        mScrollViewHeight = mScrollViewHeight + cell:getSize().height
        updateScrollView( mScrollViewHeight, cell )
    end
end

function onSelectTab( index )
    for i = 1, table.getn( mTabButtons ) do
        local btnTab = mTabButtons[ i ]
        if i == index then
            btnTab:setBright( false )
            btnTab:setTouchEnabled( false )
            btnTab:setTitleColor( ccc3( 255, 255, 255 ) )
            changeTab( index )
        else
            btnTab:setBright( true )
            btnTab:setTouchEnabled( true )
            btnTab:setTitleColor( ccc3( 127, 127, 127 ) )
        end
    end
end

function bindEventHandler( btnTab, index )
    local eventHandler = function ( sender, eventType )
        if eventType == TOUCH_EVENT_ENDED then
            onSelectTab( index )
        end
    end
    btnTab:addTouchEventListener( eventHandler )
end

function initButtonInfo(  )
    mTabButtons = {}
    local btnPicks = tolua.cast( mWidget:getChildByName( "Button_Picks" ), "Button" )  
    btnPicks:setTitleText( Constants.String.lucky8.btn_picks_title )
    table.insert( mTabButtons, btnPicks )
    bindEventHandler( btnPicks, 1 )

    local btnMatchLists = tolua.cast( mWidget:getChildByName( "Button_MatchLists" ), "Button" )
    table.insert( mTabButtons, btnMatchLists )
    bindEventHandler( btnMatchLists, 2 )
    local txtDate = tolua.cast( btnMatchLists:getChildByName( "TextField_Date" ), "TextField" )
    local txtWeekDay = tolua.cast( btnMatchLists:getChildByName("TextField_WeekDay"), "TextField" )
    local displayDate = os.date( "%b %d", os.time() )
    local displayWeekDay = os.date( "%A", os.time() )
    txtDate:setText( displayDate )
    txtWeekDay:setText( displayWeekDay )

    local btnRules = tolua.cast( mWidget:getChildByName( "Button_Rules" ), "Button" )
    table.insert( mTabButtons, btnRules )
    btnRules:setTitleText( Constants.String.lucky8.btn_rules_title )
    bindEventHandler( btnRules, 3 )

    onSelectTab( 2 )
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
