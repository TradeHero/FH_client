module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local Navigator = require("scripts.views.Navigator")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local Constants = require("scripts.Constants")
local SMIS = require("scripts.SMIS")
local Minigame = require("scripts.data.Minigame").Minigame
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local Logic = require("scripts.Logic").getInstance()

local mWidget

function loadFrame( minigameDetails )
	local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/MinigameDetailScene.json")
    mWidget = widget
    mWidget:registerScriptHandler( EnterOrExit )
    SceneManager.clearNAddWidget( widget )
    SceneManager.clearKeypadBackListener()
    SceneManager.setKeypadBackListener( keypadBackEventHandler )

    Navigator.loadFrame( widget )

    initContent( minigameDetails )
end

function EnterOrExit( eventType )
    if eventType == "enter" then
    elseif eventType == "exit" then
        mWidget = nil
    end
end

function isShown()
    return mWidget ~= nil
end

function backEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        keypadBackEventHandler()
    end
end

function keypadBackEventHandler()
    EventManager:popHistory()
end

function checkFacebookAndOpenWebview( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        
    end
end

function initContent( minigameDetails )
    initTitle()

    -- top info
    initTopContent( minigameDetails )

    -- self info
    initSelfContent( minigameDetails )

    -- init main content
    loadMainContent( minigameDetails )
end

function initTitle()
    local lbTitle = tolua.cast( mWidget:getChildByName( "Label_Title" ), "Label" )
    lbTitle:setText( Constants.String.minigame.title )
end

function loadMainContent( minigameDetails )

    local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView_Leaderboard"), "ScrollView" )
    local CTA = mWidget:getChildByName("Panel_CTA")

    if table.getn( minigameDetails["GoalScorers"] ) > 0 then
        CTA:setEnabled( false )
        
        contentContainer:removeAllChildrenWithCleanup( true )

        local layoutParameter = LinearLayoutParameter:create()
        layoutParameter:setGravity(LINEAR_GRAVITY_CENTER_VERTICAL)
        local contentHeight = 0

        for i = 1, table.getn( minigameDetails["GoalScorers"] ) do
            local content = SceneManager.widgetFromJsonFile("scenes/MinigameScrollviewContentFrame.json")
            content:setLayoutParameter( layoutParameter )
            contentContainer:addChild( content )
            contentHeight = contentHeight + content:getSize().height
            initLeaderboardContent( i, content, minigameDetails["GoalScorers"][i] )
        end

        contentContainer:setInnerContainerSize( CCSize:new( 0, contentHeight ) )
        local layout = tolua.cast( contentContainer, "Layout" )
        layout:requestDoLayout()
    else
        local button = tolua.cast( CTA:getChildByName("Button_Share"), "Button" )
        button:addTouchEventListener( checkFacebookAndOpenWebview )
        button:setTitleText( Constants.String.minigame.ask_friends_help )

        local lbCTA = tolua.cast( CTA:getChildByName("Label_CTA"), "Label" )
        lbCTA:setText( Constants.String.minigame.call_to_action )

        contentContainer:setEnabled( false )
    end
end

function initLeaderboardContent( i, content, info )
    local top  = content:getChildByName("Panel_Top")
    local name = tolua.cast( top:getChildByName("Label_Name"), "Label" )
    local score = tolua.cast( top:getChildByName("Label_Score"), "Label" )
    local logo = tolua.cast( top:getChildByName("Image_Logo"), "ImageView" )

    if info["DisplayName"] == nil or type(info["DisplayName"]) ~= "string" then
        name:setText( Constants.String.unknown_name )
    else
        name:setText( info["DisplayName"] )
    end

    if info["points"] == 0 then
        score:setText( Constants.String.minigame.failed_to_score )
    else
        score:setText( string.format( Constants.String.minigame.helped_to_score, info["points"] ) )
    end

    local seqArray = CCArray:create()
    seqArray:addObject( CCDelayTime:create( i * 0.2 ) )
    seqArray:addObject( CCCallFuncN:create( function()
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
    end ) )

    mWidget:runAction( CCSequence:create( seqArray ) )
end

function initTopContent( minigameDetails )
    --[[local obj = {
        Joined = response["joined"],
        GoalsScored = response["goals_scored"],
        Target = response["target"],
        GoalsToTarget = response["goals_to_target"],
        GoalScorers = response["users_helping"],
        Winners = response["previous_winners"]
      }]]
    --for key,value in pairs(minigameDetails) do print(key,value) end

    local backBt = mWidget:getChildByName("Button_Back")
    backBt:addTouchEventListener( backEventHandler )

    local winnerEventHandler = function( sender, eventType )
        if eventType == TOUCH_EVENT_ENDED then
            EventManager:postEvent( Event.Enter_Minigame_Winners, { minigameDetails["Winners"] } )
        end
    end

    local rulesEventHandler = function( sender, eventType )
        if eventType == TOUCH_EVENT_ENDED then
            EventManager:postEvent( Event.Enter_Competition_Rules, { "minigame" } )
        end
    end

    local banner = mWidget:getChildByName("Panel_Banner")
    local winners = tolua.cast( banner:getChildByName("Button_Winners"), "Button" )
    local rules = tolua.cast( banner:getChildByName("Button_Rules"), "Button" )
    winners:addTouchEventListener( winnerEventHandler )
    rules:addTouchEventListener( rulesEventHandler )

    winners:setTitleText( Constants.String.minigame.winners )
    rules:setTitleText( Constants.String.minigame.rules )

    local info = mWidget:getChildByName("Panel_Info")
    local button = info:getChildByName("Button_Share")
    local button = tolua.cast( info:getChildByName("Button_Share"), "Button" )
    
    local scoreNum = tolua.cast( info:getChildByName("Label_ScoreNum"), "Label" )
    local scoreDenom = tolua.cast( info:getChildByName("Label_ScoreDenom"), "Label" )
    local helpCount = tolua.cast( info:getChildByName("Label_HelpCount"), "Label" )
    local lbTitleScore = tolua.cast( info:getChildByName("Label_TitleScore"), "Label" )
    local lbHelpText = tolua.cast( info:getChildByName("Label_HelpText"), "Label" )

    button:setTitleText( Constants.String.minigame.ask_more_friends )
    lbTitleScore:setText( Constants.String.minigame.current_score )
    lbHelpText:setText( Constants.String.minigame.friend_help )

    if minigameDetails["GoalsToTarget"] <= 0 then
        button:setEnabled( false )
    else
        button:addTouchEventListener( checkFacebookAndOpenWebview )
    end

    scoreNum:setText( minigameDetails["GoalsScored"] )

    scoreDenom:setText( "/"..minigameDetails["Target"] )

    helpCount:setText( table.getn( minigameDetails["GoalScorers"] ) )
end

function initSelfContent( minigameDetails )
    local self = mWidget:getChildByName("Panel_Self")
    local name = tolua.cast( self:getChildByName("Label_Name"), "Label" )
    local score = tolua.cast( self:getChildByName("Label_Score"), "Label" )
    local logo = tolua.cast( self:getChildByName("Image_Logo"), "ImageView" )
    
    -- TODO
    if minigameDetails["DisplayName"] == nil or type(minigameDetails["DisplayName"]) ~= "string" then
        name:setText( Constants.String.unknown_name )
    else
        name:setText( minigameDetails["DisplayName"] )
    end

    if minigameDetails["GoalsToTarget"] == 0 then
        score:setText( Constants.String.minigame.shoot_to_win_won )
    else
        score:setText( string.format( Constants.String.minigame.goal_to_win, minigameDetails["GoalsToTarget"] ) )
    end
    
    local seqArray = CCArray:create()
    seqArray:addObject( CCDelayTime:create( 0.2 ) )
    seqArray:addObject( CCCallFuncN:create( function()
        if minigameDetails["PictureUrl"] ~= nil then
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
            SMIS.getSMImagePath( minigameDetails["PictureUrl"], handler )
        end
    end ) )

    mWidget:runAction( CCSequence:create( seqArray ) )
end
