module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local Navigator = require("scripts.views.Navigator")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local MarketConfig = require("scripts.config.Market")
local TeamConfig = require("scripts.config.Team")
local Constants = require("scripts.Constants")
local MatchCenterConfig = require("scripts.config.MatchCenter")
local Header = require("scripts.views.HeaderFrame")
local ViewUtils = require("scripts.views.ViewUtils")


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
    
    Header.loadFrame( widget, nil, true )

    Navigator.loadFrame( widget )

    helperInitMatchInfo( mWidget, matchInfo )
    initContent( matchInfo["GameId"] )
end

function EnterOrExit( eventType )
    if eventType == "enter" then
    elseif eventType == "exit" then
        mWidget = nil
    end
end

function initContent( matchId )

    local matchCenterEvent = function( sender,eventType  )
        if eventType == TOUCH_EVENT_ENDED then
            EventManager:postEvent( Event.Enter_Match_Center, { MatchCenterConfig.MATCH_CENTER_TAB_ID_DISCUSSION, matchId } )
        end
    end
    local matchCenter = tolua.cast( mWidget:getChildByName("Button_MatchCenter"), "Button" )
    matchCenter:setTitleText( Constants.String.match_center.title )
    matchCenter:addTouchEventListener( matchCenterEvent )

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
    local vs = tolua.cast( content:getChildByName("Label_VS"), "Label" )

    team1Name:setText( TeamConfig.getTeamName( mHomeTeamId ) )
    team2Name:setText( TeamConfig.getTeamName( mAwayTeamId ) )
    vs:setText( Constants.String.vs )
end

function initCouponInfo( content, info )
    local answer = tolua.cast( content:getChildByName("answer"), "Label" )
    local winLoseLabel = tolua.cast( content:getChildByName("winLoseLabel"), "Label" )
    local points = tolua.cast( content:getChildByName("points"), "Label" )
    local stake = tolua.cast( content:getChildByName("stake"), "Label" )
    local choice = tolua.cast( content:getChildByName("choice"), "ImageView" )
    local statusBar = tolua.cast( content:getChildByName("Label_BG_Status"), "Button" )
    local infoCheckBox = tolua.cast( content:getChildByName("CheckBox_Handicap"), "CheckBox" )
    local infoPanel = tolua.cast( content:getChildByName("Image_HandicapPopup"), "ImageView" )

    -- Init the answer string.
    local marketType = info["MarketTypeId"]
    local line = info["Line"]
    local answerId = ( info["OutcomeSide"] == 1 )

    local answerString
    local choiceImage
    local infoCheckBoxVisible
    if marketType == MarketConfig.MARKET_TYPE_MATCH then
        answerString = Constants.String.history.which_team
        if info["OutcomeSide"] == MarketConfig.ODDS_TYPE_ONE_OPTION then
            choiceImage = TeamConfig.getLogo( mHomeTeamId )
        elseif info["OutcomeSide"] == MarketConfig.ODDS_TYPE_TWO_OPTION then
            choiceImage = TeamConfig.getLogo( mAwayTeamId )
        elseif info["OutcomeSide"] == MarketConfig.ODDS_TYPE_THREE_OPTION then
            choiceImage = Constants.PREDICTION_CHOICE_IMAGE_PATH.."img-draw-blue.png"
        end
        infoCheckBoxVisible = false
    elseif marketType == MarketConfig.MARKET_TYPE_TOTAL_GOAL then
        answerString = string.format( Constants.String.history.total_goals, math.ceil( line ) )
        if answerId then
            choiceImage = Constants.PREDICTION_CHOICE_IMAGE_PATH.."prediction-yes.png"
        else
            choiceImage = Constants.PREDICTION_CHOICE_IMAGE_PATH.."prediction-no.png"
        end
        infoCheckBoxVisible = false
    elseif marketType == MarketConfig.MARKET_TYPE_ASIAN_HANDICAP then
        local teamName = TeamConfig.getTeamName( mAwayTeamId )
        local absLine = math.abs( line )
        if line <= 0 then
            teamName = TeamConfig.getTeamName( mHomeTeamId )
        end 
        
        if absLine == 0 then
            answerString = string.format( Constants.String.history.win_by_line0, teamName )
        else
            answerString = string.format( Constants.String.history.win_by, teamName, absLine )
        end
        
        if answerId then
            choiceImage = Constants.PREDICTION_CHOICE_IMAGE_PATH.."prediction-yes.png"
        else
            choiceImage = Constants.PREDICTION_CHOICE_IMAGE_PATH.."prediction-no.png"
        end
        infoCheckBoxVisible = true
    end

    answer:setText( answerString )
    choice:loadTexture( choiceImage )
    stake:setText( string.format( Constants.String.history.stake, info["Stake"] ) )
    infoCheckBox:setEnabled( infoCheckBoxVisible )
    infoPanel:setEnabled( false )

    if infoCheckBoxVisible then
        local popupEventHandler = function( sender, eventType )
            if eventType == TOUCH_EVENT_ENDED then
                if infoCheckBox:getSelectedState() then
                    -- remove popup
                   infoPanel:setEnabled( false )
                else
                    -- show popup
                   infoPanel:setEnabled( true )
               end
            end
        end
        infoCheckBox:addTouchEventListener( popupEventHandler )

        local labelHome = tolua.cast( infoPanel:getChildByName( "Label_TitleHome"), "Label" )
        local labelAway = tolua.cast( infoPanel:getChildByName( "Label_TitleAway"), "Label" )
        local txtHome = tolua.cast( infoPanel:getChildByName( "Label_GuideHome"), "Label" )
        local txtAway = tolua.cast( infoPanel:getChildByName( "Label_GuideAway"), "Label" )

        local homeTeam = TeamConfig.getTeamName( mHomeTeamId )
        local awayTeam = TeamConfig.getTeamName( mAwayTeamId )
        labelHome:setText( string.format( Constants.String.handicap.predict_on, Constants.String.button.yes ) )
        labelAway:setText( string.format( Constants.String.handicap.predict_on, Constants.String.button.no ) )

        local yesText, noText = ViewUtils.getYesNoText( line, homeTeam, awayTeam )
        txtHome:setText( yesText )
        txtAway:setText( noText )
    end
    

    if mIsOpen == false then
        local refund = tolua.cast( content:getChildByName("Label_Refund"), "Label" )
        if info["Won"] then
            statusBar:setFocused( true )
            winLoseLabel:setText(Constants.String.history.won_colon)
            points:setText( string.format( Constants.String.num_of_points, info["Profit"] ) )
            refund:setEnabled( false )
        elseif info["Profit"] == 0 then
            winLoseLabel:setText(Constants.String.history.push_colon)
            points:setText( string.format( Constants.String.num_of_points, info["Stake"] ) )
            refund:setText( Constants.String.history.refund )
        else
            statusBar:setBright( false )
            winLoseLabel:setText(Constants.String.history.lost_colon)
            points:setText( string.format( Constants.String.num_of_points, -info["Profit"] ) )
            refund:setEnabled( false )
        end
    else
        points:setText( string.format( Constants.String.num_of_points, info["Profit"] ) )
        winLoseLabel:setText(Constants.String.history.won_colon)
    end
end