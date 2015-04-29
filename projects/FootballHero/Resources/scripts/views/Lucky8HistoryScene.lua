module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local Constants = require("scripts.Constants")
local Navigator = require("scripts.views.Navigator")
local Header = require("scripts.views.Lucky8Header")
local TeamConfig = require("scripts.config.Team")

local mWidget
local mWonPrize

function loadFrame( param, cellInfo )
    local widget = GUIReader:shareReader():widgetFromJsonFile( "scenes/Lucky8HistoryScene.json" )
    mWidget = widget
    widget:registerScriptHandler( EnterOrExit )
    SceneManager.clearNAddWidget( widget )
    Header.loadFrame( widget, Constants.String.lucky8.lucky8_title, true )

    initScrollView( param )

    initResultText( cellInfo )
end

function initResultText( cellInfo )
    local textResult = tolua.cast( mWidget:getChildByName("TextField_4"), "TextField" )
    local PredictionsCorrect = cellInfo["PredictionsCorrect"]
    local PredictionsMade = cellInfo["PredictionsMade"]
    local text = string.format( "You've got %d out of %d games correct", PredictionsCorrect, PredictionsMade )
    textResult:setText( text )

    local UsdWon = cellInfo["UsdWon"]
    if UsdWon == 500 then
        showPrizeScene( true )
    end
end

function showPrizeScene( isShow )
    if isShow == false then 
        return 
    end

    local wonPrice = SceneManager.widgetFromJsonFile( "scenes/Lucky8WonPrice.json" )
    mWonPrize = wonPrice
    mWidget:addChild( wonPrice )

    local btnClaim = tolua.cast( wonPrice:getChildByName("Button_Claim"), "Button" )
    btnClaim:addTouchEventListener( eventClaim )

    local claimText = tolua.cast( btnClaim:getChildByName("TextField_Claim"), "TextField" )
    claimText:setText( Constants.String.lucky8.won_prize_btn_claim )

    local wonText = tolua.cast( wonPrice:getChildByName("TextField_Won"), "TextField" )
    wonText:setText( Constants.String.lucky8.won_prize_won_txt )
end

function eventClaim( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        CCLuaLog( "Lucky8HistoryScene eventClaim" )
        mWonPrize:removeFromParentAndCleanup( true )
    end
end

function helperInitCells( cell, data )
    local panelFade = cell:getChildByName( "Panel_Fade" )
    local imageHome = tolua.cast( panelFade:getChildByName("Image_Team1"), "ImageView" )
    local imageAway = tolua.cast( panelFade:getChildByName("Image_Team2"), "ImageView" )
    local teamId1 = data["Home"]["TeamId"]
    local teamId2 = data["Away"]["TeamId"]
    imageHome:loadTexture( TeamConfig.getLogo( TeamConfig.getConfigIdByKey(teamId1) ) )
    imageAway:loadTexture( TeamConfig.getLogo( TeamConfig.getConfigIdByKey(teamId1) ) )

    local textLeague = tolua.cast( panelFade:getChildByName("TextField_Legaue"), "TextField" )
    textLeague:setText( data["LeagueName"] )

    local teamName1 = tolua.cast( panelFade:getChildByName("TextField_TeamName1"), "TextField" )
    local teamName2 = tolua.cast( panelFade:getChildByName("TextField_TeamName2"), "TextField" )
    local txtDraw = tolua.cast( panelFade:getChildByName("TextField_Draw"), "TextField" )
    txtDraw:setText( Constants.String.lucky8.draw )
    teamName1:setText( TeamConfig.getTeamName( TeamConfig.getConfigIdByKey( teamId1 ) ) )
    teamName2:setText( TeamConfig.getTeamName( TeamConfig.getConfigIdByKey( teamId1 ) ) )

    local imageResult = tolua.cast( panelFade:getChildByName("Image_Result"), "ImageView" )
    local isWon = data["Won"]
    if isWon == true then
        imageResult:loadTexture( Constants.LUCKY8_IMAGE_PATH .. "lucky8_img_won.png" )
    else
        imageResult:loadTexture( Constants.LUCKY8_IMAGE_PATH .. "lucky8_img_lost.png" )
    end

    local txtScore = tolua.cast( panelFade:getChildByName("Label_Score_0" ), "Label" )
    if data["ScoreString"] == nil then
        txtScore:setText( " " )
    else
        txtScore:setText( tostring(data["ScoreString"]) )
    end
    
    local btnHome = tolua.cast( panelFade:getChildByName("Button_1"), "Button" )
    local btnAway = tolua.cast( panelFade:getChildByName("Button_2"), "Button" )
    local btnDraw = tolua.cast( panelFade:getChildByName("Button_Draw"), "Button" )
    local PickId = data["PickId"]
    if PickId == data["Home"]["FHOddId"] then
        btnHome:setBright( false )
        btnDraw:setBright( true )
        btnAway:setBright( true )
    elseif PickId == data["Away"]["FHOddId"] then
        btnHome:setBright( true )
        btnDraw:setBright( false )
        btnAway:setBright( true )
    else
        btnHome:setBright( true )
        btnDraw:setBright( true )
        btnAway:setBright( false )
    end
end

function initScrollView( param )
    local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView"), "ScrollView" )
    local scrollViewHeight = 0 
    local games = param["Games"]
    for k,v in pairs(games) do
        local matchContent = SceneManager.widgetFromJsonFile( "scenes/Lucky8HistoryCell.json" )
        contentContainer:addChild( matchContent )
        helperInitCells( matchContent, v )
        scrollViewHeight = scrollViewHeight + matchContent:getSize().height
        updateScrollView( scrollViewHeight, content )
    end
end

function updateScrollView( scrollViewHeight, content )
    local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView"), "ScrollView" )
    contentContainer:setInnerContainerSize( CCSize:new(0, scrollViewHeight) )
    local layout = tolua.cast( contentContainer, "Layout" )
    layout:requestDoLayout()
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
