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

function requestLucky8Rounds(  )
    local url = RequestUtils.GET_LUCKY8_ROUNDS
    local requestInfo = {}
    requestInfo.requestData = ""
    requestInfo.url = url
    local handler = function ( isSucceed, body, header, status, errorBuffer )
        RequestUtils.messageHandler( requestInfo, isSucceed, body, header, status, errorBuffer, RequestUtils.HTTP_200, true, onRequestLucky8RoundsSucess, onRequestLucky8RoundsFailed )
    end

    local httpRequest = HttpRequestForLua:create( CCHttpRequest.kHttpGet )
    httpRequest:addHeader( Logic:getAuthSessionString() )
    httpRequest:sendHttpRequest( url, handler )

    ConnectingMessage.loadFrame()
end

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

function onRequestLucky8RoundsSucess( jsonResponse )
    local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView_Content"), "ScrollView" )
    contentContainer:removeAllChildrenWithCleanup( true )
    mScrollViewHeight = 0
    
    local Rounds = jsonResponse["Rounds"]
    for k,v in pairs( Rounds ) do
        local cell = SceneManager.widgetFromJsonFile( CELL_RES_STRING[1] )
        contentContainer:addChild( cell )
        helperInitPickscell( cell, v )
        mScrollViewHeight = mScrollViewHeight + cell:getSize().height
        updateScrollView( mScrollViewHeight, contentContainer )
    end
end

function onRequestLucky8RoundsFailed( jsonResponse )
    
end

function requestLucky8MatchList(  )
    local url = RequestUtils.GET_LUCKY8_GAMES
    local requestInfo = {}
    requestInfo.requestData = ""
    requestInfo.url = url
    local handler = function ( isSucceed, body, header, status, errorBuffer )
        RequestUtils.messageHandler( requestInfo, isSucceed, body, header, status, errorBuffer, RequestUtils.HTTP_200, true, onRequestLucky8MatchListSuccess, onRequestLucky8MatchListFailed )
    end

    local httpRequest = HttpRequestForLua:create( CCHttpRequest.kHttpGet )
    httpRequest:addHeader( Logic:getAuthSessionString() )
    httpRequest:sendHttpRequest( url, handler )

    ConnectingMessage.loadFrame()
end

function onRequestLucky8MatchListSuccess( json )
    mScrollViewHeight = 0;
    initScrollView( json ) 
end

function onRequestLucky8MatchListFailed( json )
    -- body
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

    initButtonInfo()

    requestLucky8MatchList()
end

function eventSubmit( sender, eventType )
    local odds = {}
    for k,v in pairs( mMatchlistCellInfo ) do
        local selectedIndex = v["selectedIndex"]
        table.insert( odds, selectedIndex )
    end
    print( mCurrentRoundId[1]["roundid"] )
    local debugTools = require("scripts.DebugTools")
    debugTools.print_lua_table( mCurrentRoundId )
    local requestContent = {
        RoundId = mCurrentRoundId[1]["roundid"],
        FHOddIds = odds,
    }
    local requestContentText = Json.encode( requestContent )
    print( "Post message: "..requestContentText )
    local url = RequestUtils.POST_LUCKY8_PREDICT
    local requestInfo = {}
    requestInfo.requestData = requestContentText
    requestInfo.url = url

    local handler = function ( isSucceed, body, header, status, errorBuffer )
        RequestUtils.messageHandler( requestInfo, isSucceed, body, header, status, errorBuffer, RequestUtils.HTTP_200, true, onPostLucky8PredictSucess, onPostLucky8PredictFailed )
    end

    local httpRequest = HttpRequestForLua:create( CCHttpRequest.kHttpPost )
    httpRequest:addHeader( Constants.CONTENT_TYPE_JSON )
    httpRequest:addHeader( Logic:getAuthSessionString() )
    httpRequest:getRequest():setRequestData( requestContentText, string.len( requestContentText ) )
    httpRequest:sendHttpRequest( url, handler )

    ConnectingMessage.loadFrame()
end

-- {"Information":"successful"}
function onPostLucky8PredictSucess( json )
    
end

-- {"Message":"Round already played!"}
function onPostLucky8PredictFailed( jsonResponse )
    RequestUtils.onRequestFailedByErrorCode( jsonResponse["Message"] )
end

function helpInitMatchListcell( cell, cellInfo, Played )
    local panelFade = cell:getChildByName("Panel_Fade")
    local imageLock = panelFade:getChildByName("Image_Lock")
    imageLock:setVisible( Played )

    local btnHome = tolua.cast( panelFade:getChildByName( "Button_Home" ), "Button" )
    btnHome:addTouchEventListener( eventSelectWhoWin )
    local btnAway = tolua.cast( panelFade:getChildByName( "Button_Away" ), "Button" )
    btnAway:addTouchEventListener( eventSelectWhoWin )
    local btnDrawBig = tolua.cast( panelFade:getChildByName("Button_Draw_Big"), "Button" )
    btnDrawBig:addTouchEventListener( eventSelectWhoWin )

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

    local btn1 = tolua.cast( panelFade:getChildByName("Button_1"), "Button" )
    -- btn1:addTouchEventListener( eventSelectWhoWin )

    local btn2 = tolua.cast( panelFade:getChildByName("Button_2"), "Button" )
    -- btn2:addTouchEventListener( eventSelectWhoWin )

    local btnDraw = tolua.cast( panelFade:getChildByName("Button_Draw"), "Button" )
    -- btnDraw:addTouchEventListener( eventSelectWhoWin )

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
    mMatchlistCellInfo = {}
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

function getCurrentTime(  )
    local currentTime = os.time()
    -- local currentDate = os.date( "%B %")
end

-- function changeScrollView( index, cellNum )
--     local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView_Content"), "ScrollView" )
--     contentContainer:removeAllChildrenWithCleanup( true )
--     mScrollViewHeight = 0
--     if index == 1 or index == 3 then
--         mBtnSubmits:setVisible( false )
--     else
--         mBtnSubmits:setVisible( true )
--     end
--     for i = 1, cellNum do
--         local cell = SceneManager.widgetFromJsonFile( CELL_RES_STRING[index] )
--         if index == 1 then
--             cell:addTouchEventListener( enterHistory )
--         elseif index == 2 then
--             -- requestLucky8MatchList()
--         else
--             local text = tolua.cast( cell:getChildByName("TextField_Rule"), "TextField" )
--             text:setText( Constants.String.lucky8.lucky8_rule )
--         end
--         contentContainer:addChild( cell )
--         mScrollViewHeight = mScrollViewHeight + cell:getSize().height
--         updateScrollView( mScrollViewHeight, cell )
--     end
-- end

function enterHistory( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        EventManager:postEvent( Event.Enter_Lucky8History )
    end
end

function changeTab( index )
    -- changeScrollView( index )
    if index == 1 or index == 3 then
        mBtnSubmits:setVisible( false )
    else
        mBtnSubmits:setVisible( true )
    end

    if index == 1 then
        requestLucky8Rounds()
    elseif index == 2 then
        requestLucky8MatchList()
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
    getCurrentTime()

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
