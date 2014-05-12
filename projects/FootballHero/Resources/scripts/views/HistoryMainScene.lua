module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local Navigator = require("scripts.views.Navigator")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local TeamConfig = require("scripts.config.Team")


local CONTENT_FADEIN_TIME = 1

local mWidget

-- DS for couponHistory see CouponHistoryData
function loadFrame( couponHistory )
	local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/HistoryHome.json")
    mWidget = widget
    mWidget:registerScriptHandler( EnterOrExit )
    SceneManager.clearNAddWidget( widget )

    Navigator.loadFrame( widget )

    initContent( couponHistory )
end

function EnterOrExit( eventType )
    if eventType == "enter" then
    elseif eventType == "exit" then
        mWidget = nil
    end
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
                predictionClicked( false, couponHistory:getOpenData()[i] )
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
            helperInitClosedPrediction( content, couponHistory:getOpenData()[i] )

            content:setOpacity( 0 )
            content:setCascadeOpacityEnabled( true )
            mWidget:runAction( CCTargetedAction:create( content, CCFadeIn:create( CONTENT_FADEIN_TIME ) ) )
        end ) )
        seqArray:addObject( CCDelayTime:create( 0.2 ) )
    end

    seqArray:addObject( CCCallFuncN:create( function()
        contentContainer:setInnerContainerSize( CCSize:new( 0, contentHeight ) )
        local layout = tolua.cast( contentContainer, "Layout" )
        layout:requestDoLayout()
    end ) )

    mWidget:runAction( CCSequence:create( seqArray ) )
end

function predictionClicked( isOpen, matchInfo )
	EventManager:postEvent( Event.Enter_History_Detail, { isOpen, matchInfo } )
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
    local roi = tolua.cast( content:getChildByName("roi"), "Label" )
    local winPercentage = tolua.cast( content:getChildByName("winPercentage"), "Label" )
    local pointWinInd = tolua.cast( content:getChildByName("pointWinInd"), "Button" )

    points:setText( "-" )
    roi:setText( string.format( roi:getStringValue(), "0 %" ) )
    winPercentage:setText( string.format( winPercentage:getStringValue(), "%" ) )
    pointWinInd:setEnabled( false )
end

function helperInitClosedPrediction( content, matchInfo )
    local points = tolua.cast( content:getChildByName("points"), "Label" )
    local roi = tolua.cast( content:getChildByName("roi"), "Label" )
    local winPercentage = tolua.cast( content:getChildByName("winPercentage"), "Label" )
    local vs = tolua.cast( content:getChildByName("vs"), "Label" )
    local pointWinInd = tolua.cast( content:getChildByName("pointWinInd"), "Button" )
    local statusBar = tolua.cast( content:getChildByName("statusBar"), "Button" )
    
    if matchInfo["Result"] then
        statusBar:setHighlighted( true )
    else
        pointWinInd:setBright( false )
        statusBar:setBright( false )
    end

    points:setText( 1000 )
    roi:setText( string.format( roi:getStringValue(), "50 %" ) )
    winPercentage:setText( string.format( winPercentage:getStringValue(), "50 %" ) )
end