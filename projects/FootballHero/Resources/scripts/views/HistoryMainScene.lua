module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local Navigator = require("scripts.views.Navigator")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local TeamConfig = require("scripts.config.Team")
local Logic = require("scripts.Logic").getInstance()
local Constants = require("scripts.Constants")

local CONTENT_FADEIN_TIME = 1

local mWidget
local mStep
local mCompetitionId
local mHasMoreToLoad

-- DS for couponHistory see CouponHistoryData
-- competitionId: The history only contains matches within the leagues in this competition.
--                  if it is nil, then the history will show everything. 
function loadFrame( userId, userName, competitionId, couponHistory )
    mCompetitionId = competitionId
    local showBackButton = false
    if userId == Logic:getUserId() then
        mWidget = GUIReader:shareReader():widgetFromJsonFile("scenes/HistoryHome.json")
        local totalPoints = tolua.cast( mWidget:getChildByName("totalPoints"), "Label" )
        totalPoints:setText( string.format( totalPoints:getStringValue(), couponHistory:getBalance() ) )
        
        if mCompetitionId ~= nil then
            showBackButton = true
        end
    else
        mWidget = GUIReader:shareReader():widgetFromJsonFile("scenes/HistoryHomeForOthers.json")
        local name = tolua.cast( mWidget:getChildByName("name"), "Label" )
        name:setText( userName )
        local totalPoints = tolua.cast( mWidget:getChildByName("totalPoints"), "Label" )
        totalPoints:setText( string.format( totalPoints:getStringValue(), couponHistory:getBalance() ) )

        showBackButton = true
    end

    local backBt = mWidget:getChildByName("Back")
    if showBackButton then
        local keypadBackEventHandler = function()
            EventManager:popHistory()
        end

        local backEventHandler = function( sender, eventType )
            if eventType == TOUCH_EVENT_ENDED then
                keypadBackEventHandler()
            end
        end
        
        backBt:addTouchEventListener( backEventHandler )
        SceneManager.setKeypadBackListener( keypadBackEventHandler )
    else
        backBt:setEnabled( false )
        SceneManager.clearKeypadBackListener()
    end

    mWidget:registerScriptHandler( EnterOrExit )
    SceneManager.clearNAddWidget( mWidget )

    Navigator.loadFrame( mWidget )

    mStep = 1
    mHasMoreToLoad = false
    initContent( couponHistory )
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

function initContent( couponHistory )
	local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView"), "ScrollView" )
    contentContainer:removeAllChildrenWithCleanup( true )

    local layoutParameter = LinearLayoutParameter:create()
    layoutParameter:setGravity(LINEAR_GRAVITY_CENTER_VERTICAL)
    local contentHeight = 0

    local seqArray = CCArray:create()

    -- Add the open predictions 
    seqArray:addObject( CCCallFuncN:create( function()
        local content = GUIReader:shareReader():widgetFromJsonFile("scenes/HistoryMainTitle.json")
        local titleText = tolua.cast( content:getChildByName("titleText"), "Label" )
        titleText:setText( Constants.String.history.predictions_open )
        content:setLayoutParameter( layoutParameter )
        contentContainer:addChild( content )
        contentHeight = contentHeight + content:getSize().height

        content:setOpacity( 0 )
        content:setCascadeOpacityEnabled( true )
        mWidget:runAction( CCTargetedAction:create( content, CCFadeIn:create( CONTENT_FADEIN_TIME ) ) )
    end ) )
    seqArray:addObject( CCDelayTime:create( 0.2 ) )

    for i = 1, table.getn( couponHistory:getOpenData() ) do
    	local eventHandler = function( sender, eventType )
            if eventType == TOUCH_EVENT_ENDED then
                predictionClicked( true, couponHistory:getOpenData()[i] )
            end
        end

        seqArray:addObject( CCCallFuncN:create( function()
            -- Add the open matches
            local content = SceneManager.widgetFromJsonFile("scenes/HistoryMainMatchContent.json")
            content:setLayoutParameter( layoutParameter )
            contentContainer:addChild( content )
            contentHeight = contentHeight + content:getSize().height
            local bt = content:getChildByName("match")
            bt:addTouchEventListener( eventHandler )
            helperInitPredictionCommon( content, couponHistory:getOpenData()[i] )
            helperInitOpenPrediction( content, couponHistory:getOpenData()[i] )

            content:setOpacity( 0 )
            content:setCascadeOpacityEnabled( true )
            mWidget:runAction( CCTargetedAction:create( content, CCFadeIn:create( CONTENT_FADEIN_TIME ) ) )
        end ) )
        seqArray:addObject( CCDelayTime:create( 0.2 ) )
        seqArray:addObject( CCCallFuncN:create( function()
            contentContainer:setInnerContainerSize( CCSize:new( 0, contentHeight ) )
            local layout = tolua.cast( contentContainer, "Layout" )
            layout:requestDoLayout()
            contentContainer:addEventListenerScrollView( scrollViewEventHandler )
        end ) )
    end

    -- Add the closed predictions
    seqArray:addObject( CCCallFuncN:create( function()
        local content = GUIReader:shareReader():widgetFromJsonFile("scenes/HistoryMainTitle.json")
        local titleText = tolua.cast( content:getChildByName("titleText"), "Label" )
        titleText:setText( Constants.String.history.predictions_closed )
        content:setLayoutParameter( layoutParameter )
        contentContainer:addChild( content )
        contentHeight = contentHeight + content:getSize().height

        content:setOpacity( 0 )
        content:setCascadeOpacityEnabled( true )
        mWidget:runAction( CCTargetedAction:create( content, CCFadeIn:create( CONTENT_FADEIN_TIME ) ) )
    end ) )
    seqArray:addObject( CCDelayTime:create( 0.2 ) )


    if table.getn( couponHistory:getClosedData() ) == 0 then
        mHasMoreToLoad = false
    else
        for i = 1, table.getn( couponHistory:getClosedData() ) do
            local eventHandler = function( sender, eventType )
                if eventType == TOUCH_EVENT_ENDED then
                    predictionClicked( false, couponHistory:getClosedData()[i] )
                end
            end

            seqArray:addObject( CCCallFuncN:create( function()
                -- Add the open matches
                local content = SceneManager.widgetFromJsonFile("scenes/HistoryMainMatchContent.json")
                content:setLayoutParameter( layoutParameter )
                contentContainer:addChild( content )
                contentHeight = contentHeight + content:getSize().height
                local bt = content:getChildByName("match")
                bt:addTouchEventListener( eventHandler )
                helperInitPredictionCommon( content, couponHistory:getClosedData()[i] )
                helperInitClosedPrediction( content, couponHistory:getClosedData()[i] )

                content:setOpacity( 0 )
                content:setCascadeOpacityEnabled( true )
                mWidget:runAction( CCTargetedAction:create( content, CCFadeIn:create( CONTENT_FADEIN_TIME ) ) )
            end ) )
            seqArray:addObject( CCDelayTime:create( 0.2 ) )
            seqArray:addObject( CCCallFuncN:create( function()
                contentContainer:setInnerContainerSize( CCSize:new( 0, contentHeight ) )
                local layout = tolua.cast( contentContainer, "Layout" )
                layout:requestDoLayout()
                contentContainer:addEventListenerScrollView( scrollViewEventHandler )
            end ) )
        end
        seqArray:addObject( CCCallFuncN:create( function()
            -- Set the flag after loading everything.
            mHasMoreToLoad = true
        end ) )
    end

    mWidget:runAction( CCSequence:create( seqArray ) )
end

function predictionClicked( isOpen, matchInfo )
	EventManager:postEvent( Event.Enter_History_Detail, { isOpen, matchInfo } )
end

function loadMoreContent( couponHistory )
    if table.getn( couponHistory ) == 0 then
        mHasMoreToLoad = false
        return
    end

    local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView"), "ScrollView" )

    local layoutParameter = LinearLayoutParameter:create()
    layoutParameter:setGravity(LINEAR_GRAVITY_CENTER_VERTICAL)
    local contentHeight = contentContainer:getInnerContainerSize().height

    for i = 1, table.getn( couponHistory:getClosedData() ) do
        local eventHandler = function( sender, eventType )
            if eventType == TOUCH_EVENT_ENDED then
                predictionClicked( false, couponHistory:getClosedData()[i] )
            end
        end

        -- Add the open matches
        local content = SceneManager.widgetFromJsonFile("scenes/HistoryMainMatchContent.json")
        content:setLayoutParameter( layoutParameter )
        contentContainer:addChild( content )
        contentHeight = contentHeight + content:getSize().height
        local bt = content:getChildByName("match")
        bt:addTouchEventListener( eventHandler )
        helperInitPredictionCommon( content, couponHistory:getClosedData()[i] )
        helperInitClosedPrediction( content, couponHistory:getClosedData()[i] )
    end

    contentContainer:setInnerContainerSize( CCSize:new( 0, contentHeight ) )
    local layout = tolua.cast( contentContainer, "Layout" )
    layout:requestDoLayout()
end

function scrollViewEventHandler( target, eventType )
    if eventType == SCROLLVIEW_EVENT_BOUNCE_BOTTOM and mHasMoreToLoad then
        mStep = mStep + 1
        EventManager:postEvent( Event.Load_More_In_History, { mStep, mCompetitionId } )
    end
end

function helperInitPredictionCommon( content, matchInfo )
    local team1 = tolua.cast( content:getChildByName("team1"), "ImageView" )
    local team2 = tolua.cast( content:getChildByName("team2"), "ImageView" )
    local team1Name = tolua.cast( content:getChildByName("team1Name"), "Label" )
    local team2Name = tolua.cast( content:getChildByName("team2Name"), "Label" )
    
    team1:loadTexture( TeamConfig.getLogo( TeamConfig.getConfigIdByKey( matchInfo["HomeTeamId"] ) ) )
    team2:loadTexture( TeamConfig.getLogo( TeamConfig.getConfigIdByKey( matchInfo["AwayTeamId"] ) ) )
    team1Name:setText( TeamConfig.getTeamName( TeamConfig.getConfigIdByKey( matchInfo["HomeTeamId"] ) ) )
    team2Name:setText( TeamConfig.getTeamName( TeamConfig.getConfigIdByKey( matchInfo["AwayTeamId"] ) ) )
end

function helperInitOpenPrediction( content, matchInfo )
    local points = tolua.cast( content:getChildByName("points"), "Label" )
    local pointsTitle = tolua.cast( content:getChildByName("pointsTitle"), "Label" )
    local roi = tolua.cast( content:getChildByName("roi"), "Label" )
    local winPercentage = tolua.cast( content:getChildByName("winPercentage"), "Label" )
    local pointWinInd = tolua.cast( content:getChildByName("pointWinInd"), "Button" )
    local score = tolua.cast( content:getChildByName("score"), "Label" )

    --points:setText( "-" )
    --roi:setText( string.format( roi:getStringValue(), 0 ) )
    --winPercentage:setText( string.format( winPercentage:getStringValue(), "%" ) )
    points:setEnabled( false )
    pointsTitle:setEnabled( false )
    roi:setEnabled( false )
    winPercentage:setEnabled( false )
    pointWinInd:setEnabled( false )
    score:setEnabled( false )
end

function helperInitClosedPrediction( content, matchInfo )
    local points = tolua.cast( content:getChildByName("points"), "Label" )
    local roi = tolua.cast( content:getChildByName("roi"), "Label" )
    local winPercentage = tolua.cast( content:getChildByName("winPercentage"), "Label" )
    local vs = tolua.cast( content:getChildByName("VS"), "Label" )
    local pointWinInd = tolua.cast( content:getChildByName("pointWinInd"), "Button" )
    local statusBar = tolua.cast( content:getChildByName("statusBar"), "Button" )
    local score = tolua.cast( content:getChildByName("score"), "Label" )
    
    if matchInfo["Profit"] >= 0 then
        statusBar:setFocused( true )
    else
        pointWinInd:setBright( false )
        statusBar:setBright( false )
    end

    points:setText( matchInfo["Profit"] )
    roi:setText( string.format( roi:getStringValue(), matchInfo["Roi"] ) )
    winPercentage:setText( string.format( winPercentage:getStringValue(), matchInfo["WinPercentage"] ) )
    vs:setEnabled( false )
    score:setText( matchInfo["Result"] )
end