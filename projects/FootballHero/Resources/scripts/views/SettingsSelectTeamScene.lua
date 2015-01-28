module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local Navigator = require("scripts.views.Navigator")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local SettingsConfig = require("scripts.config.Settings")
local Constants = require("scripts.Constants")
local Logic = require("scripts.Logic").getInstance()
local RequestUtils = require("scripts.RequestUtils")

local LeagueTeamConfig = require("scripts.config.LeagueTeams")
local TeamConfig = require("scripts.config.Team")

local mWidget


function loadFrame( leagueId )
	local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/SettingsHome.json")
    mWidget = widget
    mWidget:registerScriptHandler( EnterOrExit )
    SceneManager.clearNAddWidget( widget )
    SceneManager.clearKeypadBackListener()
    SceneManager.setKeypadBackListener( keypadBackEventHandler )

    Navigator.loadFrame( widget )

    local backBt = mWidget:getChildByName("Button_Back")
    backBt:addTouchEventListener( backEventHandler )

    initContent( leagueId )
end

function backEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        keypadBackEventHandler()
    end
end

function keypadBackEventHandler()
    EventManager:popHistory()
end

function EnterOrExit( eventType )
    if eventType == "enter" then
    elseif eventType == "exit" then
        mWidget = nil
        mLogo = nil
    end
end

function isFrameShown()
    return mWidget ~= nil
end


function initContent( leagueId )
    local title = tolua.cast( mWidget:getChildByName("Label_Title"), "Label" )
    title:setText( Constants.String.settings.set_favorite_tams )

    local done = tolua.cast( mWidget:getChildByName("Button_Logout"), "Button" )
    done:loadTextureNormal( Constants.SETTINGS_IMAGE_PATH.."btn-done.png" )
    done:setOpacity( 255 )
    done:setTitleText( "" )
    
    local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView"), "ScrollView" )
    contentContainer:removeAllChildrenWithCleanup( true )

    local layoutParameter = LinearLayoutParameter:create()
    layoutParameter:setGravity(LINEAR_GRAVITY_CENTER_VERTICAL)

    initTeamsList( contentContainer, leagueId )
end

function initTeamsList( contentContainer, leagueId )
    local contentHeight = 0
    local childIndex = 1

    local leagueTeams = LeagueTeamConfig.getConfig( leagueId )

    for i = 1, table.getn( leagueTeams ) do
        local teamKey = leagueTeams[i]["teamId"]
        local teamId = TeamConfig.getConfigIdByKey( teamKey )
        local teamName = TeamConfig.getTeamName( teamId )
        local teamLogo = TeamConfig.getLogo( teamId )
    
        local content = SceneManager.widgetFromJsonFile( "scenes/SettingsTeamListContentFrame.json" )
        contentContainer:addChild( content, 0, childIndex )

        local logo = tolua.cast( content:getChildByName("Image_Jersey"), "ImageView" )
        local name = tolua.cast( content:getChildByName("Label_Name"), "Label" )
        local check = tolua.cast( content:getChildByName("CheckBox_Favorite"), "CheckBox" )

        name:setText( teamName )
        logo:loadTexture( teamLogo )

        contentHeight = contentHeight + content:getSize().height
        childIndex = childIndex + 1

        local eventHandler = function( sender, eventType )
            if eventType == TOUCH_EVENT_ENDED then
                local favorite = tolua.cast( sender, "CheckBox" )
                
                if favorite:getSelectedState() then
                    print( "unliked "..teamName )
                else
                    print( "favorited "..teamName )
                end
            end
        end
        check:addTouchEventListener( eventHandler )
    end

    contentContainer:setInnerContainerSize( CCSize:new( 0, contentHeight ) )
    local layout = tolua.cast( contentContainer, "Layout" )
    layout:requestDoLayout()
    layout:setLayoutType(LAYOUT_LINEAR_VERTICAL)
end