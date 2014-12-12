module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local Navigator = require("scripts.views.Navigator")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local Constants = require("scripts.Constants")
local SMIS = require("scripts.SMIS")

local mWidget

function loadFrame( winners )
	local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/MinigameWinnersScene.json")
    mWidget = widget
    mWidget:registerScriptHandler( EnterOrExit )
    SceneManager.clearNAddWidget( widget )
    SceneManager.clearKeypadBackListener()
    SceneManager.setKeypadBackListener( keypadBackEventHandler )
    
    Navigator.loadFrame( widget )

    initContent( winners )
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

function initContent( winners )
    initTitle()

    -- init main content
    loadMainContent( winners )
end

function initTitle()
    local title = tolua.cast( mWidget:getChildByName("Label_Title"), "Label" )
    title:setText( Constants.String.minigame.winners )
end

function loadMainContent( winners )
    
    local backBt = mWidget:getChildByName("Button_Back")
    backBt:addTouchEventListener( backEventHandler )

    local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView_Leaderboard"), "ScrollView" )
    local CTA = tolua.cast( mWidget:getChildByName("Label_CTA"), "Label" )

    if table.getn( winners ) > 0 then
        CTA:setEnabled( false )
        
        contentContainer:removeAllChildrenWithCleanup( true )

        local layoutParameter = LinearLayoutParameter:create()
        layoutParameter:setGravity(LINEAR_GRAVITY_CENTER_VERTICAL)
        local contentHeight = 0

        for i = 1, table.getn( winners ) do
            local content = SceneManager.widgetFromJsonFile("scenes/MinigameScrollviewContentFrame.json")
            content:setLayoutParameter( layoutParameter )
            contentContainer:addChild( content )
            contentHeight = contentHeight + content:getSize().height
            initLeaderboardContent( i, content, winners[i] )
        end

        contentContainer:setInnerContainerSize( CCSize:new( 0, contentHeight ) )
        local layout = tolua.cast( contentContainer, "Layout" )
        layout:requestDoLayout()
    else
        CTA:setText( Constants.String.minigame.no_one_won )
    end
end

function initLeaderboardContent( i, content, info )
    local top  = content:getChildByName("Panel_Top")
    local name = tolua.cast( top:getChildByName("Label_Name"), "Label" )
    local score = tolua.cast( top:getChildByName("Label_Score"), "Label" )
    local logo = tolua.cast( top:getChildByName("Image_Logo"), "ImageView" )

    if info["DisplayName"] == nil then
        name:setText( Constants.String.unknown_name )
    else
        name:setText( info["DisplayName"] )
    end

    score:setText( Constants.String.minigame.iPhone6_winner )

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

