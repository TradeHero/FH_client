module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local Navigator = require("scripts.views.Navigator")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local TeamConfig = require("scripts.config.Team")
local Logic = require("scripts.Logic").getInstance()


local CONTENT_FADEIN_TIME = 1

local mWidget
local mStep
local mCompetitionId

-- DS for couponHistory see CouponHistoryData
-- competitionId: The history only contains matches within the leagues in this competition.
--                  if it is nil, then the history will show everything. 
function loadFrame( userId, userName, competitionId, couponHistory )
    if userId == Logic:getUserId() then
        mWidget = GUIReader:shareReader():widgetFromJsonFile("scenes/HistoryHome.json")
        local totalPoints = tolua.cast( mWidget:getChildByName("totalPoints"), "Label" )
        totalPoints:setText( string.format( totalPoints:getStringValue(), couponHistory:getBalance() ) )
    else
        mWidget = GUIReader:shareReader():widgetFromJsonFile("scenes/HistoryHomeForOthers.json")
        local name = tolua.cast( mWidget:getChildByName("name"), "Label" )
        name:setText( userName )
        local totalPoints = tolua.cast( mWidget:getChildByName("totalPoints"), "Label" )
        totalPoints:setText( string.format( totalPoints:getStringValue(), couponHistory:getBalance() ) )

        local backEventHandler = function( sender, eventType )
            if eventType == TOUCH_EVENT_ENDED then
                EventManager:popHistory()
            end
        end

        local backBt = mWidget:getChildByName("Back")
        backBt:addTouchEventListener( backEventHandler )
    end
	
    mCompetitionId = competitionId

    mWidget:registerScriptHandler( EnterOrExit )
    SceneManager.clearNAddWidget( mWidget )

    Navigator.loadFrame( mWidget )

    initContent( couponHistory )
    mStep = 1
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
        titleText:setText( "Open Predictions" )
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
    end

    -- Add the closed predictions
    seqArray:addObject( CCCallFuncN:create( function()
        local content = GUIReader:shareReader():widgetFromJsonFile("scenes/HistoryMainTitle.json")
        local titleText = tolua.cast( content:getChildByName("titleText"), "Label" )
        titleText:setText( "Closed Predictions" )
        content:setLayoutParameter( layoutParameter )
        contentContainer:addChild( content )
        contentHeight = contentHeight + content:getSize().height

        content:setOpacity( 0 )
        content:setCascadeOpacityEnabled( true )
        mWidget:runAction( CCTargetedAction:create( content, CCFadeIn:create( CONTENT_FADEIN_TIME ) ) )
    end ) )
    seqArray:addObject( CCDelayTime:create( 0.2 ) )

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
    end

    seqArray:addObject( CCCallFuncN:create( function()
        if table.getn( couponHistory:getClosedData() ) > 0 then
            -- Add the "More" button
            contentHeight = contentHeight + addMoreButton( contentContainer, layoutParameter ):getSize().height
        end

        contentContainer:setInnerContainerSize( CCSize:new( 0, contentHeight ) )
        local layout = tolua.cast( contentContainer, "Layout" )
        layout:requestDoLayout()
    end ) )

    mWidget:runAction( CCSequence:create( seqArray ) )
end

function predictionClicked( isOpen, matchInfo )
	EventManager:postEvent( Event.Enter_History_Detail, { isOpen, matchInfo } )
end

function addMoreButton( contentContainer, layoutParameter )
    local content = SceneManager.widgetFromJsonFile("scenes/MoreContent.json")
    content:setLayoutParameter( layoutParameter )
    contentContainer:addChild( content )
    content:addTouchEventListener( loadMore )
    content:setName("More")

    return content
end

function loadMore( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        mStep = mStep + 1
        EventManager:postEvent( Event.Load_More_In_History, { mStep, mCompetitionId } )
    end
end

function loadMoreContent( couponHistory )
    local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView"), "ScrollView" )

    -- Remove the "More" button
    local moreButton = contentContainer:getChildByName("More")
    moreButton:removeFromParent()

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

    if table.getn( couponHistory:getClosedData() ) > 0 then
        -- Add back the "More" button
        addMoreButton( contentContainer, layoutParameter )
    end

    contentContainer:setInnerContainerSize( CCSize:new( 0, contentHeight ) )
    local layout = tolua.cast( contentContainer, "Layout" )
    layout:requestDoLayout()
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
    team1Name:setFontName("fonts/Newgtbxc.ttf")
    team2Name:setFontName("fonts/Newgtbxc.ttf")
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