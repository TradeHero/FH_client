module(..., package.seeall)

local Constants = require("scripts.Constants")
local SceneManager = require("scripts.SceneManager")
local CountryConfig = require("scripts.config.Country")
local LeagueConfig = require("scripts.config.League")
local TeamConfig = require("scripts.config.Team")
local Navigator = require("scripts.views.Navigator")
local LeagueListScene = require("scripts.views.LeagueListScene")
local LeagueListSceneUnexpended = require("scripts.views.LeagueListSceneUnexpended")
local Logic = require("scripts.Logic").getInstance()
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local SMIS = require("scripts.SMIS")
local Json = require("json")

local mWidget
local mTopLayer
local mOptionPanelShown
local mTheFirstDate = nil

local MIN_MOVE_DISTANCE = 100
local OPTION_MOVE_TIME = 0.5
local OPTION_VIEW_OFFSET_X = 475

local CONTENT_FADEIN_TIME = 0.1
local CONTENT_DELAY_TIME = 0.2

function isShown()
    return mWidget ~= nil
end

function loadFrame( matchList, leagueKey )
	local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/MatchListScene.json")
    mWidget = widget
    mWidget:registerScriptHandler( EnterOrExit )
    SceneManager.clearNAddWidget( widget )
    SceneManager.clearKeypadBackListener()

    Navigator.loadFrame( widget )
    Navigator.chooseNav( 1 )

    initLeagueList( leagueKey )

    -- Init the match list according to the data.
    initMatchList( matchList, leagueKey )

    -- Init the league list
    --[[
    LeagueListSceneUnexpended.loadFrame( "scenes/CountryListContent.json", "scenes/LeagueListContent.json", 
        tolua.cast( mWidget:getChildByName("leagueList"), "ScrollView" ), leagueSelectedCallback )
    --]]

    -- Option button
    --[[
    local optionBt = widget:getChildByName("option")
    optionBt:addTouchEventListener( optionEventHandler )
    --]]

    local userName = tolua.cast( widget:getChildByName("userName"), "Label" )
    userName:setText( Logic:getDisplayName() )
    
    if Logic:getPictureUrl() ~= nil then
        local handler = function( filePath )
            if filePath ~= nil then
                local userLogo = tolua.cast( widget:getChildByName("userPhoto"), "ImageView" )
                userLogo:loadTexture( filePath )
            end
        end
        SMIS.getSMImagePath( Logic:getPictureUrl(), handler )
    else
        local fileUtils = CCFileUtils:sharedFileUtils()
        local path = fileUtils:getWritablePath()..Constants.LOGO_IMAGE_PATH
        if fileUtils:isFileExist( path ) then
            local userLogo = tolua.cast( widget:getChildByName("userPhoto"), "ImageView" )
            userLogo:loadTexture( path )
        end
    end

    -- Init the toplayer to listen to the swap action.
    --[[
    mTopLayer = CCLayer:create()
    mTopLayer:registerScriptTouchHandler( onTopLevelTouch, false, -100)
    mWidget:addNode( mTopLayer )
    mTopLayer:setTouchEnabled( true )
    mOptionPanelShown = false
    --]]
end

function EnterOrExit( eventType )
    if eventType == "enter" then
    elseif eventType == "exit" then
        mWidget = nil
    end
end

function initLeagueList( leagueKey )
    SceneManager.clearKeypadBackListener()
    
    local content = SceneManager.widgetFromJsonFile("scenes/LeagueListDropDown.json")
    mWidget:addChild( content )

    local list = tolua.cast( content:getChildByName("leagueList"), "ScrollView" )
    local expendedIndicator = content:getChildByName( "expendIndi" )
    local mask = content:getChildByName("mask")
    local buttonEventHandler = function( sender, eventType )
        if eventType == TOUCH_EVENT_ENDED then
            if list:isEnabled() then
                list:setEnabled( false )
                mask:setEnabled( false )
                expendedIndicator:setBrightStyle( BRIGHT_NORMAL )
            else
                list:setEnabled( true )
                mask:setEnabled( true )
                expendedIndicator:setBrightStyle( BRIGHT_HIGHLIGHT )
            end
        end
    end
    local button = content:getChildByName("button")
    button:addTouchEventListener( buttonEventHandler )
    list:setEnabled( false )
    mask:setEnabled( false )

    local initCurrentLeague = function( leagueKey )
        local logo = tolua.cast( content:getChildByName("countryLogo"), "ImageView" )
        local leagueName = tolua.cast( content:getChildByName("countryName"), "Label" )

        -- Hardcode Popular League texts and logo

        if leagueKey == Constants.MOST_POPULAR_LEAGUE_ID then
            leagueName:setText( Constants.String.most_popular )
            logo:loadTexture( Constants.COUNTRY_IMAGE_PATH.."favorite.png" )
        else
            local leagueId = LeagueConfig.getConfigIdByKey( leagueKey )
            local countryId = CountryConfig.getConfigIdByKey( LeagueConfig.getCountryId( leagueId ) )
            leagueName:setText( CountryConfig.getCountryName( countryId ).." - "..LeagueConfig.getLeagueName( leagueId ) )
            logo:loadTexture( CountryConfig.getLogo( countryId ) )
        end
    end

    local leagueSelectedCallback = function( leagueKey )
        list:setEnabled( false )
        mask:setEnabled( false )
        expendedIndicator:setBrightStyle( BRIGHT_NORMAL )
        
        initCurrentLeague( leagueKey )

        mWidget:stopAllActions()
        EventManager:postEvent( Event.Enter_Match_List, { leagueKey } )
    end

    LeagueListSceneUnexpended.loadFrame( "scenes/LeagueContentInDropDown.json", "", 
        list, leagueSelectedCallback )

    initCurrentLeague( leagueKey )
end

-- Param matchList is Object of MatchListData
function initMatchList( matchList, leagueKey )
    local predictionScene = SceneManager.getWidgetByName( "TappablePredictionScene" )
    local predictionConfirmScene = SceneManager.getWidgetByName( "PredTotalConfirmScene" )
    if predictionScene ~= nil then
        SceneManager.removeWidget( predictionScene )

        if predictionConfirmScene ~= nil then
            SceneManager.removeWidget( predictionConfirmScene )
        else
            -- Skip the refresh and show directly
            return
        end
    end

    local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView"), "ScrollView" )
    contentContainer:removeAllChildrenWithCleanup( true )

    local seqArray = CCArray:create()
    seqArray:addObject( CCDelayTime:create( 0.3 ) )
    seqArray:addObject( CCCallFunc:create( function()
        local layoutParameter = LinearLayoutParameter:create()
        layoutParameter:setGravity(LINEAR_GRAVITY_CENTER_VERTICAL)
        local contentHeight = 0
        
        mTheFirstDate = nil
        for k,v in pairs( matchList:getMatchDateList() ) do
            local matchDate = v

            -- Vincent: for most popular leagues, there are no matches before the "Tap to make a prediction!" hint, thus there is no need for zOrder position shifting
            local zOrder = matchDate["date"]
            if leagueKey == Constants.MOST_POPULAR_LEAGUE_ID then
                zOrder = 1
            end

            local content = SceneManager.widgetFromJsonFile("scenes/MatchDate.json")
            local dateDisplay = tolua.cast( content:getChildByName("Label_Date"), "Label" )
            local timeDisplay = tolua.cast( content:getChildByName("Label_Time"), "Label" )
            dateDisplay:setText( matchDate["dateDisplay"] )
            timeDisplay:setText( matchDate["timeDisplay"] )
            content:setLayoutParameter( layoutParameter )
            content:setZOrder( zOrder )

            if mTheFirstDate == nil then
                local hintContent = SceneManager.widgetFromJsonFile("scenes/TapToMakePrediction.json")
                hintContent:setLayoutParameter( layoutParameter )
                hintContent:setZOrder( zOrder )
                contentContainer:addChild( hintContent )
                contentHeight = contentHeight + hintContent:getSize().height

                mTheFirstDate = content
            end

            -- Add the date
            contentContainer:addChild( content )
            contentHeight = contentHeight + content:getSize().height

            content:setOpacity( 0 )
            content:setCascadeOpacityEnabled( true )
            mWidget:runAction( CCTargetedAction:create( content, CCFadeIn:create( CONTENT_FADEIN_TIME ) ) )

            local i = 1
            for inK, inV in pairs( matchDate["matches"] ) do
                local eventHandler = function( sender, eventType )
                    if eventType == TOUCH_EVENT_ENDED then
                        enterMatch( inV )
                    end
                end

                local content = SceneManager.widgetFromJsonFile("scenes/MatchListContent.json")
                helperInitMatchInfo( content, inV )

                content:setLayoutParameter( layoutParameter )
                content:setZOrder( zOrder )
                contentContainer:addChild( content )
                contentHeight = contentHeight + content:getSize().height

                content:addTouchEventListener( eventHandler )

                if i == table.getn( matchDate["matches"] ) then
                    local separator = content:getChildByName("Panel_Separator")
                    separator:setEnabled( false )
                end

                content:setOpacity( 0 )
                content:setCascadeOpacityEnabled( true )
                mWidget:runAction( CCTargetedAction:create( content, CCFadeIn:create( CONTENT_FADEIN_TIME ) ) )
                
                updateContentContainer( contentHeight, content )

                i = i + 1
            end
        end

        if contentContainer:getChildrenCount() == 0 then
            local content = SceneManager.widgetFromJsonFile("scenes/MatchListEmptyIndi.json")
            content:setLayoutParameter( layoutParameter )
            contentContainer:addChild( content )
            contentHeight = contentHeight + content:getSize().height
            updateContentContainer( contentHeight, content )
        end
    end ) )

    seqArray:addObject( CCCallFunc:create( checkMiniGame ) )
    mWidget:runAction( CCSequence:create( seqArray ) )
end

function sendAnalytics( nextImageID, shared )
    local params
    if nextImageID == Constants.MINIGAME_IMAGE_ONE then
        params = { ImageOne = shared }
    else
        params = { ImageTwo = shared }
    end
    
    CCLuaLog("Send ANALYTICS_EVENT_MINIGAME_ACTION: "..Json.encode( params ) )
    Analytics:sharedDelegate():postEvent( Constants.ANALYTICS_EVENT_MINIGAME, Json.encode( params ) )
end

function checkMiniGame()
    -- check if popup should appear
    local bAppear = shouldShowMiniGame()

    if bAppear then
        local minigamePopup = SceneManager.widgetFromJsonFile("scenes/MinigamePopup.json")
        minigamePopup:setZOrder( Constants.ZORDER_POPUP )
        mWidget:addChild( minigamePopup )

        local nextImage = getNextMiniGameImage()
        local closeEventHandler = function( sender, eventType )
            if eventType == TOUCH_EVENT_ENDED then
                -- save in localDB
                local stage = CCUserDefault:sharedUserDefault():getIntegerForKey( Constants.EVENT_NEXT_MINIGAME_STAGE )
                setMiniGameNextStage( stage )
                mWidget:removeChild(minigamePopup)
                sendAnalytics( nextImage, "closed" )
            end
        end

        local playEventHandler = function( sender, eventType )
            if eventType == TOUCH_EVENT_ENDED then
                -- save in localDB
                setMiniGameNextStage( Constants.MINIGAME_STAGE_ENDED )
                mWidget:removeChild(minigamePopup)
                checkFacebookAndOpenWebview()
                sendAnalytics( nextImage, "shared" )
            end
        end

        local close = minigamePopup:getChildByName( "Button_Close" )
        close:addTouchEventListener( closeEventHandler )
        
        --local later = minigamePopup:getChildByName( "Button_Later" )
        --later:addTouchEventListener( closeEventHandler )

        --local play = minigamePopup:getChildByName( "Button_Play" )
        --play:addTouchEventListener( playEventHandler )

        local mask = minigamePopup:getChildByName( "Panel_Mask" )
        mask:addTouchEventListener( closeEventHandler )

        -- Set Background Image, reposition buttons
        local BG = tolua.cast( minigamePopup:getChildByName( "Image_BG" ), "ImageView" )
        BG:loadTexture( Constants.MINIGAME_IMAGE_PATH.."pop-out-"..nextImage..".png" )
        BG:addTouchEventListener( playEventHandler )

        local bgPos = ccp( BG:getPositionX(), BG:getPositionY() )
        local bgScale = BG:getScale()
        local bgSize = BG:getSize()
        
        close:setPosition( ccp( bgPos.x + bgSize.width / 2 * bgScale, bgPos.y + bgSize.height / 2 * bgScale ) )

        --later:setPositionY( bgPos.y - bgSize.height / 2 + 75 )
        --play:setPositionY( bgPos.y - bgSize.height / 2 + 75 )
    end

end

function getNextMiniGameImage()
    local nextImage = CCUserDefault:sharedUserDefault():getIntegerForKey( Constants.EVENT_MINIGAME_NEXT_IMAGE )
    
    local image_id
    if nextImage == 0 then
        -- first image
        if Logic:getUserId() % 2 == 0 then
            image_id = Constants.MINIGAME_IMAGE_TWO 
            CCUserDefault:sharedUserDefault():setIntegerForKey( Constants.EVENT_MINIGAME_NEXT_IMAGE, Constants.MINIGAME_IMAGE_ONE )
        else
            image_id = Constants.MINIGAME_IMAGE_ONE 
            CCUserDefault:sharedUserDefault():setIntegerForKey( Constants.EVENT_MINIGAME_NEXT_IMAGE, Constants.MINIGAME_IMAGE_TWO )
        end
    else
        if nextImage == Constants.MINIGAME_IMAGE_ONE then
            image_id = Constants.MINIGAME_IMAGE_ONE 
            CCUserDefault:sharedUserDefault():setIntegerForKey( Constants.EVENT_MINIGAME_NEXT_IMAGE, Constants.MINIGAME_IMAGE_TWO )
        else
            image_id = Constants.MINIGAME_IMAGE_TWO 
            CCUserDefault:sharedUserDefault():setIntegerForKey( Constants.EVENT_MINIGAME_NEXT_IMAGE, Constants.MINIGAME_IMAGE_ONE )
        end
    end

    return image_id
end

function shouldShowMiniGame()
    local nowTimeStamp = os.time()
    local minigameStage = CCUserDefault:sharedUserDefault():getIntegerForKey( Constants.EVENT_NEXT_MINIGAME_STAGE )
    local nextTimeStamp = CCUserDefault:sharedUserDefault():getIntegerForKey( Constants.EVENT_NEXT_MINIGAME_TIME_KEY )
    local bShouldShow = false

    if minigameStage == Constants.MINIGAME_STAGE_ENDED then
        -- Already played, do not show
        print( "Already played, do not show" )
    elseif minigameStage == 0 then
        -- Next time does not exist, init
        print( "Next time does not exist, init" )
        setMiniGameNextStage( 0 )
    elseif nextTimeStamp < nowTimeStamp then
        print( "show popup" )
        bShouldShow = true
    else
        print( "waiting to show popup" )
    end
    
    return bShouldShow
end

function setMiniGameNextStage( stage )
    --local stage = CCUserDefault:sharedUserDefault():getIntegerForKey( Constants.EVENT_NEXT_MINIGAME_STAGE )

    if stage == Constants.MINIGAME_STAGE_ENDED then
        -- No more minigame popup
        print( "No more minigame popup" )
        CCUserDefault:sharedUserDefault():setIntegerForKey( Constants.EVENT_NEXT_MINIGAME_STAGE, Constants.MINIGAME_STAGE_ENDED )

    else
        if stage < table.getn( Constants.MinigameStages ) then
            -- Set to next stage
            print( "Set to next stage from stage: ".. stage )
            stage = stage + 1
            CCUserDefault:sharedUserDefault():setIntegerForKey( Constants.EVENT_NEXT_MINIGAME_STAGE, stage )
        end

        local nowTimeStamp = os.time()
        CCUserDefault:sharedUserDefault():setIntegerForKey( Constants.EVENT_NEXT_MINIGAME_TIME_KEY, nowTimeStamp + Constants.MinigameStages[stage] )
        print( "Current Timestamp: ".. nowTimeStamp )
        print( "Set next timestamp to ".. nowTimeStamp + Constants.MinigameStages[stage] )
    end
end

function checkFacebookAndOpenWebview()
    
    local openWebview = function()
        EventManager:postEvent( Event.Enter_Minigame, { Logic:getFBAccessToken() } )
    end

    if Logic:getFbId() == false then
        local successHandler = function()
            openWebview()
        end
        local failedHandler = function()
            -- Nothing to do.
        end
        EventManager:postEvent( Event.Do_FB_Connect_With_User, { successHandler, failedHandler } )
    else
        openWebview()
    end
end

function updateContentContainer( contentHeight, addContent )
    local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView"), "ScrollView" )

    contentContainer:setInnerContainerSize( CCSize:new( 0, contentHeight ) )
    local layout = tolua.cast( contentContainer, "Layout" )
    layout:requestDoLayout()

    if mTheFirstDate ~= nil then
        if addContent:getZOrder() < mTheFirstDate:getZOrder() then
            local y = contentContainer:getInnerContainer():getPositionY() + addContent:getSize().height
            contentContainer:jumpToDestination( ccp( 0, y ) )
        end
    end
end

function enterMatch( match )
    if match["PredictionsAvailable"] > 0 and match["PredictionsPlayed"] == match["PredictionsAvailable"] then
        EventManager:postEvent( Event.Show_Info, { Constants.String.info.predictions_entered } )
        return
    end

    Logic:setSelectedMatch( match )
    EventManager:postEvent( Event.Enter_Match )
end

function leagueSelectedCallback( leagueId )
    EventManager:postEvent( Event.Enter_Match_List, { leagueId } )
end

function helperInitMatchInfo( topContent, matchInfo )
    local team1 = tolua.cast( topContent:getChildByName("team1"), "ImageView" )
    local team2 = tolua.cast( topContent:getChildByName("team2"), "ImageView" )
    local team1Name = tolua.cast( topContent:getChildByName("team1Name"), "Label" )
    local team2Name = tolua.cast( topContent:getChildByName("team2Name"), "Label" )
    local homePercent = tolua.cast( topContent:getChildByName("home_percent"), "Label" )
    local awayPercent = tolua.cast( topContent:getChildByName("away_percent"), "Label" )
    local drawPercent = tolua.cast( topContent:getChildByName("draw_percent"), "Label" )

    local points = tolua.cast( topContent:getChildByName("Points"), "Label")
    local stamp = tolua.cast( topContent:getChildByName("Stamp"), "ImageView" )
    
    local content = topContent:getChildByName("fade_panel")
    local fhNum = tolua.cast( content:getChildByName("fhNum"), "Label" )
    local played = tolua.cast( content:getChildByName("played"), "Label" )
    
    -- Load the team logo
    team1:loadTexture( TeamConfig.getLogo( TeamConfig.getConfigIdByKey( matchInfo["HomeTeamId"] ) ) )
    team2:loadTexture( TeamConfig.getLogo( TeamConfig.getConfigIdByKey( matchInfo["AwayTeamId"] ) ) )

    -- Load the team names
    local teamName = TeamConfig.getTeamName( TeamConfig.getConfigIdByKey( matchInfo["HomeTeamId"] ) )
    if string.len( teamName ) > 20 then
        team1Name:setFontSize( 20 )
    end
    team1Name:setText( teamName )
    teamName = TeamConfig.getTeamName( TeamConfig.getConfigIdByKey( matchInfo["AwayTeamId"] ) )
    if string.len( teamName ) > 20 then
        team2Name:setFontSize( 20 )
    end
    team2Name:setText( teamName )

    local score = tolua.cast( topContent:getChildByName("score"), "Label" )
    if matchInfo["HomeGoals"] >= 0 and matchInfo["AwayGoals"] >= 0 then
        score:setText( string.format( score:getStringValue(), matchInfo["HomeGoals"], matchInfo["AwayGoals"] ) )
    
        if matchInfo["PredictionsPlayed"] == 0 then
            content:setEnabled( false )
            stamp:loadTexture( Constants.MATCH_LIST_CONTENT_IMAGE_PATH.."stamp-ended.png" )
            points:setEnabled( false )
        elseif matchInfo["Profit"] == nil then
            stamp:setEnabled( false )
            points:setEnabled( false )
        elseif matchInfo["Profit"] >= 0 then
            content:setEnabled( false )
            stamp:loadTexture( Constants.MATCH_LIST_CONTENT_IMAGE_PATH.."stamp-won.png" )
            points:setText( string.format( points:getStringValue(), math.abs( matchInfo["Profit"] ) ) )
            points:setColor( ccc3( 92, 200, 80 ) )
        else
            content:setEnabled( false )
            stamp:loadTexture( Constants.MATCH_LIST_CONTENT_IMAGE_PATH.."stamp-lost.png" )
            points:setText( string.format( points:getStringValue(), math.abs( matchInfo["Profit"] ) ) )
            points:setColor( ccc3( 238, 56, 47 ) )
        end
    else
        score:setText( "-:-" )
        stamp:setEnabled( false )
        points:setEnabled( false )
    end

    local totalWinPredictions = matchInfo["HomePredictions"] + matchInfo["AwayPredictions"] + matchInfo["DrawPredictions"]
    local homeWinPercent = matchInfo["HomePredictions"] / totalWinPredictions * 100
    local awayWinPercent = matchInfo["AwayPredictions"] / totalWinPredictions * 100
    local drawWinPercent = matchInfo["DrawPredictions"] / totalWinPredictions * 100
    homePercent:setText( string.format( homePercent:getStringValue(), homeWinPercent ) )
    awayPercent:setText( string.format( awayPercent:getStringValue(), awayWinPercent ) )
    drawPercent:setText( string.format( drawPercent:getStringValue(), drawWinPercent ) )
    fhNum:setText( matchInfo["TotalUsersPlayed"] )
    played:setText( string.format( played:getStringValue(), matchInfo["PredictionsPlayed"], matchInfo["PredictionsAvailable"] ) )

    local isGameStart = matchInfo["StartTime"] > os.time()
    if isGameStart then
        topContent:setTouchEnabled( true )
    else
        topContent:setTouchEnabled( false )
    end
end

function optionEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        if mOptionPanelShown then
            hideOptionAnim()
        else
            showOptionAnim()
        end
    end
end

local startPosX, startPosY
function onTopLevelTouch( eventType, x, y )
    if eventType == "began" then
        startPosX, startPosY = x, y
        return true
    elseif eventType == "ended" then
        if startPosX - x > MIN_MOVE_DISTANCE and mOptionPanelShown == true then
            -- Swap to Left
            hideOptionAnim()
        elseif startPosX < 80 and x - startPosX > MIN_MOVE_DISTANCE and mOptionPanelShown == false then
            -- Swap to Right
            showOptionAnim()
        end
    end
end

function showOptionAnim( callbackFunc )
    local optionBt = mWidget:getChildByName("option")
    optionBt:setTouchEnabled( false )
    mTopLayer:setTouchEnabled( false )

    local seqArray = CCArray:create()
    seqArray:addObject( CCMoveBy:create( OPTION_MOVE_TIME, ccp( OPTION_VIEW_OFFSET_X, 0 ) ) )
    seqArray:addObject( CCCallFuncN:create( function()
        optionBt:setTouchEnabled( true )
        mTopLayer:setTouchEnabled( true )
        mOptionPanelShown = true

        if callbackFunc ~= nil then
            callbackFunc()
        end
    end ) )
    mWidget:runAction( CCSequence:create( seqArray ) )
end

function hideOptionAnim( callbackFunc )
    local optionBt = mWidget:getChildByName("option")
    optionBt:setTouchEnabled( false )
    mTopLayer:setTouchEnabled( false )

    local seqArray = CCArray:create()
    seqArray:addObject( CCMoveBy:create( OPTION_MOVE_TIME, ccp( OPTION_VIEW_OFFSET_X * (-1), 0 ) ) )
    seqArray:addObject( CCCallFuncN:create( function()
        optionBt:setTouchEnabled( true )
        mTopLayer:setTouchEnabled( true )
        mOptionPanelShown = false

        if callbackFunc ~= nil then
            callbackFunc()
        end
    end ) )
    mWidget:runAction( CCSequence:create( seqArray ) )
end