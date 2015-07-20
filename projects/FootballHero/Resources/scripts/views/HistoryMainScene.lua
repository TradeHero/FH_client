module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local Navigator = require("scripts.views.Navigator")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local TeamConfig = require("scripts.config.Team")
local Logic = require("scripts.Logic").getInstance()
local Constants = require("scripts.Constants")
local CountryConfig = require("scripts.config.Country")
local SMIS = require("scripts.SMIS")
local StatsDropDownFilter = require("scripts.views.StatsDropDownFilter")
local CompetitionType = require("scripts.data.Competitions").CompetitionType
local RequestUtils = require("scripts.RequestUtils")
local Header = require("scripts.views.HeaderFrame")

local CONTENT_FADEIN_TIME = 1

local mWidget
local mStep
local mCompetitionId
local mUserId
local mHasMoreToLoad
local mAdditionalParam
local mCountryFilter

-- DS for couponHistory see CouponHistoryData
-- competitionId: The history only contains matches within the leagues in this competition.
--                  if it is nil, then the history will show everything. 
function loadFrame( userId, competitionId, couponHistory, additionalParam, countryFilter )
    mCompetitionId = competitionId
    mAdditionalParam = additionalParam
    mCountryFilter = countryFilter
    local showBackButton = false

    mWidget = GUIReader:shareReader():widgetFromJsonFile("scenes/MyPicksHome.json")

    local totalPoints = tolua.cast( mWidget:getChildByName("Label_Total_Points"), "Label" )
    totalPoints:setText( string.format( Constants.String.history.total_points, couponHistory:getBalance() ) )
    
    local follows = tolua.cast( mWidget:getChildByName("Label_Follow"), "Label" )
    local nFollow = couponHistory:getFollow()
    if nFollow == nil then
        follows:setVisible(false)
    else
        follows:setVisible( true )
        follows:setText( string.format( Constants.String.history.follows, nFollow ) )
    end
    
    mUserId = userId
    if mUserId == Logic:getUserId() then
        if mCompetitionId ~= nil or nFollow ~= nil then
            showBackButton = true
        end
    else
        showBackButton = true
    end

    if showBackButton then
        Header.loadFrame( mWidget, nil, true )
    else
        Header.loadFrame( mWidget, nil, false )
    end

    mWidget:registerScriptHandler( EnterOrExit )
    SceneManager.clearNAddWidget( mWidget )

    initFilter( mCountryFilter )
    initContent( couponHistory )

    Navigator.loadFrame( mWidget )

    mStep = 1
    mHasMoreToLoad = false
end

function refreshFrame( userId, competitionId, couponHistory, additionalParam, countryFilter )
    mCompetitionId = competitionId
    mAdditionalParam = additionalParam
    mCountryFilter = countryFilter

    local totalPoints = tolua.cast( mWidget:getChildByName("Label_Total_Points"), "Label" )
    totalPoints:setText( string.format( Constants.String.history.total_points, couponHistory:getBalance() ) )

    local follows = tolua.cast( mWidget:getChildByName("Label_Follow"), "Label" )
    local nFollow = couponHistory:getFollow()
    if nFollow == nil then
        follows:setVisible(false)
    else
        follows:setVisible( true )
        follows:setText( string.format( Constants.String.history.follows, nFollow ) )
    end
 
    mStep = 1
    mHasMoreToLoad = false
    initFilter( mCountryFilter )
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

function isSelf()
    if mUserId == Logic:getUserId() then
        return true
    else
        return false
    end
end

function initFilter( countryFilter )
    local filterPanel = mWidget:getChildByName("Panel_League_Select")
    local filterExpend = filterPanel:getChildByName( "Button_FilterExpand" )
    local mask = filterPanel:getChildByName("Panel_Mask")
    local filterList = tolua.cast( filterPanel:getChildByName("ScrollView_Filter"), "ScrollView" )
    local logo = tolua.cast( filterPanel:getChildByName("countryLogo"), "ImageView" )
    local league = tolua.cast( filterPanel:getChildByName("Label_League"), "Label" )

    league:setText( Constants.String.leaderboard.stats_league )

    filterList:setEnabled( false )
    mask:setEnabled( false )
    filterExpend:setBrightStyle( BRIGHT_NORMAL )

    local filterHandler = function( sender, eventType )
        if eventType == TOUCH_EVENT_ENDED then
            if filterList:isEnabled() then
                mask:setEnabled( false )
                filterList:setEnabled( false )
                filterExpend:setBrightStyle( BRIGHT_NORMAL )
            else
                mask:setEnabled( true )
                filterList:setEnabled( true )
                filterExpend:setBrightStyle( BRIGHT_HIGHLIGHT )
            end
        end
    end
    filterPanel:addTouchEventListener( filterHandler )


    local refreshFilter = function( index )
        if index == Constants.STATS_SHOW_ALL then
            logo:loadTexture( Constants.COUNTRY_IMAGE_PATH.."favorite.png" )
        else
            logo:loadTexture( CountryConfig.getLogo( index ) )
        end
    end
    
    local filterSelectedCallback = function( index )
        mask:setEnabled( false )
        filterList:setEnabled( false )
        filterExpend:setBrightStyle( BRIGHT_NORMAL )
        
        refreshFilter( index )

        if index == Constants.STATS_SHOW_ALL then
            EventManager:postEvent( Event.Enter_History, { mUserId, mCompetitionId, mAdditionalParam } )
        else
            local countryId = CountryConfig.getCountryId( index )
            CCLuaLog("Stats filter by: "..countryId)
            EventManager:postEvent( Event.Enter_History, { mUserId, mCompetitionId, mAdditionalParam, countryId } )
        end
    end

    StatsDropDownFilter.loadFrame( filterList, filterSelectedCallback )

    if countryFilter == Constants.STATS_SHOW_ALL then
        refreshFilter( countryFilter )
    else
        local countryIndex = CountryConfig.getConfigIdByKey( countryFilter )
        refreshFilter( countryIndex )
    end
    
end

function initContent( couponHistory )
	local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView"), "ScrollView" )
    contentContainer:removeAllChildrenWithCleanup( true )

    local layoutParameter = LinearLayoutParameter:create()
    layoutParameter:setGravity(LINEAR_GRAVITY_CENTER_VERTICAL)
    local contentHeight = 0

    local seqArray = CCArray:create()

    local competitionDetail = Logic:getCompetitionDetail()
    local info = couponHistory:getStats()
    local label = tolua.cast( mWidget:getChildByName("Label_CompTitle"), "Label" )
    local show = tolua.cast( mWidget:getChildByName("Button_Show"), "Button" )
    CCLuaLog("initContent")
    if mAdditionalParam == "Expert" then
        show:setTitleText( Constants.String.history.show_all )
        label:setText( Constants.String.history.predictions_team )
        local eventHandler = function( sender, eventType )
            if eventType == TOUCH_EVENT_ENDED then
                EventManager:postEvent( Event.Enter_History, { mUserId } )
            end
        end
        show:addTouchEventListener( eventHandler )
        show:setEnabled( true )
    elseif mCompetitionId ~= nil then
        label:setText( competitionDetail:getName() )
        show:setTitleText( Constants.String.history.show_all )
        local eventHandler = function( sender, eventType )
            if eventType == TOUCH_EVENT_ENDED then
                EventManager:postEvent( Event.Enter_History, { mUserId } )
            end
        end
        show:addTouchEventListener( eventHandler )
        show:setEnabled( true )
    else
        label:setText( Constants.String.history.predictions_all )
        show:setEnabled( false )
    end
    
    -- Stats
    local stats = mWidget:getChildByName("Panel_Stats")
    local stat_win = tolua.cast( stats:getChildByName("Label_Win"), "Label" )
    local stat_lose = tolua.cast( stats:getChildByName("Label_Lose"), "Label" )
    local stat_win_percent = tolua.cast( stats:getChildByName("Label_Win_Percent"), "Label" )
    local stat_gain_percent = tolua.cast( stats:getChildByName("Label_Gain_Percent"), "Label" )
    local stat_last_10_win = tolua.cast( stats:getChildByName("Label_W"), "Label" )
    local stat_last_10_lose = tolua.cast( stats:getChildByName("Label_L"), "Label" )

    --Labels
    local lb_stat_win = tolua.cast( stats:getChildByName("Label_Title_Win"), "Label" )
    local lb_stat_lose = tolua.cast( stats:getChildByName("Label_Title_Lose"), "Label" )
    local lb_stat_win_percent = tolua.cast( stats:getChildByName("Label_Title_Win_Percent"), "Label" )
    local lb_stat_gain_percent = tolua.cast( stats:getChildByName("Label_Title_Gain_Percent"), "Label" )
    local lb_stat_last_10 = tolua.cast( stats:getChildByName("Label_Title_Last_10"), "Label" )
    local lb_stat_last_10_win = tolua.cast( stats:getChildByName("Label_Title_W"), "Label" )
    local lb_stat_last_10_lose = tolua.cast( stats:getChildByName("Label_Title_L"), "Label" )

    stat_win:setText( info["NumberOfCouponsWon"] )
    stat_lose:setText( info["NumberOfCouponsLost"] )
    stat_win_percent:setText( info["WinPercentage"] )
    stat_gain_percent:setText( info["Roi"] )
    stat_last_10_win:setText( info["WinStreakCouponsWon"] )
    stat_last_10_lose:setText( info["WinStreakCouponsLost"] )

    lb_stat_win:setText( Constants.String.leaderboard.stats_win )
    lb_stat_lose:setText( Constants.String.leaderboard.stats_lose )

    lb_stat_win_percent:setText( Constants.String.leaderboard.stats_win_rate )
    lb_stat_gain_percent:setText( Constants.String.leaderboard.stats_gain_rate )
    lb_stat_last_10:setText( Constants.String.leaderboard.stats_last_ten )
    lb_stat_last_10_win:setText( Constants.String.leaderboard.stats_w )
    lb_stat_last_10_lose:setText( Constants.String.leaderboard.stats_l )

    if info["Roi"] < 0 then
        stat_gain_percent:setColor( ccc3( 240, 75, 79 ) )
    else
        stat_gain_percent:setColor( ccc3( 79, 199, 93 ) )
    end

    local name = tolua.cast( mWidget:getChildByName("Label_Name"), "Label" )
    if info["DisplayName"] == nil or type(info["DisplayName"]) ~= "string" then
        name:setText( Constants.String.unknown_name )
    else
        -- TODO: name width check
        if string.len( info["DisplayName"] ) > Constants.MAX_USER_NAME_LENGTH then
            info["DisplayName"] = string.sub( info["DisplayName"], 0, Constants.MAX_USER_NAME_LENGTH ).."..."
        end
        name:setText( info["DisplayName"] )
    end

    local logo = tolua.cast( mWidget:getChildByName("Image_Profile_Pic"), "ImageView" )
    if isSelf() then
        logo:addTouchEventListener( logoEventHandler )
    end
    
    if info["PictureUrl"] ~= nil then
        local handler = function( filePath )
            if filePath ~= nil and mWidget ~= nil and logo ~= nil then
                local safeLoadTexture = function()
                    logo:loadTexture( filePath )
                end

                local errorHandler = function( msg )
                    -- Do nothing
                end

                xpcall( safeLoadTexture, errorHandler )
            end
        end
        SMIS.getSMImagePath( info["PictureUrl"], handler )
    end

    -- Add the open predictions 
    seqArray:addObject( CCCallFuncN:create( function()
        local content = GUIReader:shareReader():widgetFromJsonFile("scenes/HistoryMainTitle.json")
        local titleText = tolua.cast( content:getChildByName("Label_Title"), "Label" )
        titleText:setText( Constants.String.history.predictions_open )
        content:setLayoutParameter( layoutParameter )
        contentContainer:addChild( content )
        contentHeight = contentHeight + content:getSize().height

        content:setOpacity( 0 )
        content:setCascadeOpacityEnabled( true )
        mWidget:runAction( CCTargetedAction:create( content, CCFadeIn:create( CONTENT_FADEIN_TIME ) ) )
    end ) )
    seqArray:addObject( CCDelayTime:create( 0.2 ) )

    if table.getn( couponHistory:getOpenData() ) == 0 then
        -- Call to arm
        seqArray:addObject( CCCallFuncN:create( function()
            local content = SceneManager.widgetFromJsonFile("scenes/MyPicksEmptyFrame.json")
            local closedPredictionContent = content:getChildByName( "Panel_ClosedPrediction" )
            closedPredictionContent:setEnabled( false )
            
            local openPredictionContent = content:getChildByName( "Panel_OpenPrediction" )
            local CTA = tolua.cast( openPredictionContent:getChildByName("Label_CTA"), "Label" )
            local button = tolua.cast( openPredictionContent:getChildByName("Button_Create"), "Button" )

            button:setTitleText( Constants.String.button.predict )

            if isSelf() then
                CTA:setText( Constants.String.history.no_open_prediction )

                local eventHandler = function( sender, eventType )
                    if eventType == TOUCH_EVENT_ENDED then
                        EventManager:postEvent( Event.Enter_Match_List )
                    end
                end
                button:addTouchEventListener( eventHandler ) 
            else
                CTA:setText( Constants.String.history.no_open_prediction_others )
                button:setEnabled( false )
            end

            content:setLayoutParameter( layoutParameter )
            contentContainer:addChild( content )
            contentHeight = contentHeight + content:getSize().height

            content:setOpacity( 0 )
            content:setCascadeOpacityEnabled( true )
            mWidget:runAction( CCTargetedAction:create( content, CCFadeIn:create( CONTENT_FADEIN_TIME ) ) )
        end ) )
    else
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
    end

    -- Add the closed predictions
    seqArray:addObject( CCCallFuncN:create( function()
        local content = GUIReader:shareReader():widgetFromJsonFile("scenes/HistoryMainTitle.json")
        local titleText = tolua.cast( content:getChildByName("Label_Title"), "Label" )
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
        
        seqArray:addObject( CCCallFuncN:create( function()
            local content = SceneManager.widgetFromJsonFile("scenes/MyPicksEmptyFrame.json")
            local openPredictionContent = content:getChildByName( "Panel_OpenPrediction" )
            openPredictionContent:setEnabled( false )
            local closedPredictionContent = content:getChildByName( "Panel_ClosedPrediction" )
            closedPredictionContent:setEnabled( true )
            local CTA = tolua.cast( closedPredictionContent:getChildByName("Label_CTA"), "Label" )

            if isSelf() then
                CTA:setText( Constants.String.history.no_closed_prediction )
            else
                CTA:setText( Constants.String.history.no_closed_prediction_others )
            end
            
            content:setLayoutParameter( layoutParameter )
            contentContainer:addChild( content )
            contentHeight = contentHeight + content:getSize().height

            content:setOpacity( 0 )
            content:setCascadeOpacityEnabled( true )
            mWidget:runAction( CCTargetedAction:create( content, CCFadeIn:create( CONTENT_FADEIN_TIME ) ) )
        end ) )
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
	EventManager:postEvent( Event.Enter_History_Detail, { mUserId, isOpen, matchInfo } )
end

function logoEventHandler( sender,eventType )
    if eventType == TOUCH_EVENT_ENDED then
        local logoSelectResultHandler = function( success )
            if success then
                local postLogoCallback = function()
                    local logo = tolua.cast( mWidget:getChildByName("Image_Profile_Pic"), "ImageView" )
                    logo:loadTexture( Constants.LOGO_IMAGE_PATH )

                    RequestUtils.invalidResponseCacheContainsUrl( RequestUtils.GET_COUPON_HISTORY_REST_CALL )
                end

                EventManager:postEvent( Event.Do_Post_Logo, { postLogoCallback } )
                
            end
        end

        Misc:sharedDelegate():selectImage( Constants.LOGO_IMAGE_PATH, 100, 100, logoSelectResultHandler )
    end
end

function loadMoreContent( couponHistory )
    if table.getn( couponHistory:getClosedData() ) == 0 then
        mHasMoreToLoad = false
        return
    end
    if not mWidget then
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
        if mAdditionalParam == "Expert" then
            EventManager:postEvent( Event.Load_More_In_Expert_History, { mStep, mCompetitionId, mUserId, mAdditionalParam, mCountryFilter } )
        else
            EventManager:postEvent( Event.Load_More_In_History, { mStep, mCompetitionId, mUserId, mAdditionalParam, mCountryFilter } )
        end
    end
end

function helperInitPredictionCommon( content, matchInfo )
    local team1 = tolua.cast( content:getChildByName("team1"), "ImageView" )
    local team2 = tolua.cast( content:getChildByName("team2"), "ImageView" )
    local team1Name = tolua.cast( content:getChildByName("team1Name"), "Label" )
    local team2Name = tolua.cast( content:getChildByName("team2Name"), "Label" )
    
    team1:loadTexture( TeamConfig.getLogo( TeamConfig.getConfigIdByKey( matchInfo["HomeTeamId"] ), true ) )
    team2:loadTexture( TeamConfig.getLogo( TeamConfig.getConfigIdByKey( matchInfo["AwayTeamId"] ), false ) )
    team1Name:setText( TeamConfig.getTeamName( TeamConfig.getConfigIdByKey( matchInfo["HomeTeamId"] ) ) )
    team2Name:setText( TeamConfig.getTeamName( TeamConfig.getConfigIdByKey( matchInfo["AwayTeamId"] ) ) )
end

function helperInitOpenPrediction( content, matchInfo )
    local points = tolua.cast( content:getChildByName("Label_Points"), "Label" )
    local pointsTitle = tolua.cast( content:getChildByName("Label_Title_Points"), "Label" )
    local winCount = tolua.cast( content:getChildByName("Label_WinCount"), "Label" )
    local winType = tolua.cast( content:getChildByName("Label_WinType"), "Label" )
    local score = tolua.cast( content:getChildByName("Label_Score"), "Label" )
    local vs = tolua.cast( content:getChildByName("Label_VS"), "Label" )

    points:setEnabled( false )
    pointsTitle:setEnabled( false )
    winCount:setEnabled( false )
    winType:setEnabled( false )
    score:setEnabled( false )
    vs:setText( Constants.String.vs )
end

function helperInitClosedPrediction( content, matchInfo )
    local points = tolua.cast( content:getChildByName("Label_Points"), "Label" )
    local pointsTitle = tolua.cast( content:getChildByName("Label_Title_Points"), "Label" )
    local winCount = tolua.cast( content:getChildByName("Label_WinCount"), "Label" )
    local winType = tolua.cast( content:getChildByName("Label_WinType"), "Label" )
    local vs = tolua.cast( content:getChildByName("Label_VS"), "Label" )
    local statusBG = tolua.cast( content:getChildByName("Label_BG_Status"), "Button" )
    local score = tolua.cast( content:getChildByName("Label_Score"), "Label" )
    
    vs:setEnabled( false )
    score:setText( matchInfo["Result"] )
    points:setText( matchInfo["Profit"] )

    if matchInfo["Profit"] >= 0 then
        statusBG:setFocused( true )
        pointsTitle:setText( Constants.String.history.won )
        points:setColor( ccc3( 79, 199, 93 ) )
    else
        statusBG:setBright( false )
        pointsTitle:setText( Constants.String.history.lost )
        points:setColor( ccc3( 240, 75, 79 ) )
    end

    local matchDetails = matchInfo["GameCouponsDTOs"]
    local wins = 0
    local totalMatches = table.getn( matchDetails )
    for i = 1, totalMatches do
        
        if matchDetails[i]["Won"] then
            wins = wins + 1
        end
    end

    if wins >= totalMatches / 2 then
        winType:setText( Constants.String.history.won_small )
        winCount:setText( string.format( Constants.String.history.win_count, wins, totalMatches ) )
        winCount:setColor( ccc3( 79, 199, 93 ) )
    else
        winType:setText( Constants.String.history.lost_small )
        winCount:setText( string.format( Constants.String.history.win_count, totalMatches - wins, totalMatches ) )
        winCount:setColor( ccc3( 240, 75, 79 ) )
    end

end
