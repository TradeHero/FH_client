module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local Navigator = require("scripts.views.Navigator")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local MarketConfig = require("scripts.config.Market")
local TeamConfig = require("scripts.config.Team")
local Constants = require("scripts.Constants")

local CONTENT_FADEIN_TIME = 1

local mWidget
local mIsOpen
local mGameCouponsDTOs

local mHomeTeamId
local mAwayTeamId

-- DS for matchInof, see CouponHistoryData
function loadFrame( isOpen, matchInfo )
	mIsOpen = isOpen
    mGameCouponsDTOs = matchInfo["GameCouponsDTOs"]

    local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/HistoryDetail.json")
    mWidget = widget
    mWidget:registerScriptHandler( EnterOrExit )
    SceneManager.clearNAddWidget( widget )

    Navigator.loadFrame( widget )

    local backBt = mWidget:getChildByName("back")
    backBt:addTouchEventListener( backEventHandler )

    helperInitMatchInfo( mWidget, matchInfo )
    initContent()
end

function EnterOrExit( eventType )
    if eventType == "enter" then
    elseif eventType == "exit" then
        mWidget = nil
    end
end

function backEventHandler( sender,eventType )
    if eventType == TOUCH_EVENT_ENDED then
        EventManager:postEvent( Event.Enter_History )
    end
end

function initContent()
    local contentWidgetFile = "scenes/HistoryDetailClosedContent.json"
    if mIsOpen then
        contentWidgetFile = "scenes/HistoryDetailOpenContent.json"
    end

	local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView"), "ScrollView" )
    contentContainer:removeAllChildrenWithCleanup( true )

    local layoutParameter = LinearLayoutParameter:create()
    layoutParameter:setGravity(LINEAR_GRAVITY_CENTER_VERTICAL)
    local contentHeight = 0

    local seqArray = CCArray:create()

    for i = 1, table.getn( mGameCouponsDTOs ) do
        seqArray:addObject( CCCallFuncN:create( function()
            local content = GUIReader:shareReader():widgetFromJsonFile( contentWidgetFile )
            content:setLayoutParameter( layoutParameter )
            contentContainer:addChild( content )
            contentHeight = contentHeight + content:getSize().height
            --content:addTouchEventListener( eventHandler )
            initCouponInfo( content, mGameCouponsDTOs[i] )


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

function helperInitMatchInfo( content, matchInfo )
    mHomeTeamId = TeamConfig.getConfigIdByKey( matchInfo["HomeTeamId"] )
    mAwayTeamId = TeamConfig.getConfigIdByKey( matchInfo["AwayTeamId"] )

    local team1Name = tolua.cast( content:getChildByName("team1Name"), "Label" )
    local team2Name = tolua.cast( content:getChildByName("team2Name"), "Label" )

    team1Name:setText( TeamConfig.getTeamName( mHomeTeamId ) )
    team2Name:setText( TeamConfig.getTeamName( mAwayTeamId ) )
    team1Name:setFontName("fonts/Newgtbxc.ttf")
    team2Name:setFontName("fonts/Newgtbxc.ttf")
end

function initCouponInfo( content, info )
    local answer = tolua.cast( content:getChildByName("answer"), "Label" )
    local points = tolua.cast( content:getChildByName("points"), "Label" )
    local stake = tolua.cast( content:getChildByName("stake"), "Label" )
    local choice = tolua.cast( content:getChildByName("choice"), "ImageView" )
    local statusBar = tolua.cast( content:getChildByName("statusBar"), "Button" )

    -- Init the answer string.
    local marketType = info["MarketTypeId"]
    local line = info["Line"]
    local answerId = ( info["OutcomeSide"] == 1 )

    local answerString
    local choiceImage
    if marketType == MarketConfig.MARKET_TYPE_MATCH then
        if answerId then
            answerString = TeamConfig.getTeamName( mHomeTeamId ).." to win."
            choiceImage = TeamConfig.getLogo( mHomeTeamId )
        else
            answerString = TeamConfig.getTeamName( mAwayTeamId ).." to win."
            choiceImage = TeamConfig.getLogo( mAwayTeamId )
        end
    elseif marketType == MarketConfig.MARKET_TYPE_TOTAL_GOAL then
        if answerId then
            answerString = string.format( "Total goals will be %d or more.", math.ceil( line ) )
            choiceImage = Constants.PREDICTION_CHOICE_IMAGE_PATH.."Will-total-goals-be-more-than-xx-yes.png"
        else
            answerString = string.format( "Total goals will less than %d.", math.ceil( line ) )
            choiceImage = Constants.PREDICTION_CHOICE_IMAGE_PATH.."Will-total-goals-be-more-than-xx-no.png"
        end
    elseif marketType == MarketConfig.MARKET_TYPE_ASIAN_HANDICAP then
        local teamName = TeamConfig.getTeamName( mAwayTeamId )
        if line < 0 then
            teamName = TeamConfig.getTeamName( mHomeTeamId )
            line = line * ( -1 )
        end 
        
        if answerId then
            answerString = string.format( "%s will win by %d goals or more.", teamName, math.ceil( line ) )
            choiceImage = Constants.PREDICTION_CHOICE_IMAGE_PATH.."Will-xx_team-score-a-goal-yes.png"
        else
            answerString = string.format( "%s will not win by %d goals or more.", teamName, math.ceil( line ) )
            choiceImage = Constants.PREDICTION_CHOICE_IMAGE_PATH.."Will-xx_team-score-a-goal-no.png"
        end
    end

    answer:setText( answerString )
    choice:loadTexture( choiceImage )
    points:setText( string.format( points:getStringValue(), info["Stake"] * info["Odd"] ) )
    stake:setText( string.format( stake:getStringValue(), info["Stake"] ) )

    if mIsOpen == false then
        if info["Won"] then
            statusBar:setHighlighted( true )
        else
            statusBar:setBright( false )
        end
    end
end