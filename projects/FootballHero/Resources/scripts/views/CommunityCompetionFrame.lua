module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local ViewUtils = require("scripts.views.ViewUtils")
local Constants = require("scripts.Constants")

local MAX_CONTAINER_HEIGHT = 560

local mWidget

-- DS, see Competitions.lua
function loadFrame( parent, compList )
    local mWidget = SceneManager.widgetFromJsonFile("scenes/CommunityCompetitionFrame.json")
    parent:addChild( mWidget )
    
    initCompetitionScene( compList )
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

function initCompetitionScene( compList )
    local createEventHandler = function( sender, eventType )
        if eventType == TOUCH_EVENT_ENDED then
            EventManager:postEvent( Event.Enter_Create_Competition )
        end
    end
    local joinEventHandler = function( sender, eventType )
        if eventType == TOUCH_EVENT_ENDED then
            local token = mWidget:getChildByName( "Panel_Code" ):getNodeByTag( 1 ):getText()
            EventManager:postEvent( Event.Do_Join_Competition, { token } )
        end
    end

    local btnNew = mWidget:getChildByName("Button_New")
    btnNew:addTouchEventListener( createEventHandler )
    local btnJoin = mWidget:getChildByName("Button_Join")
    btnJoin:addTouchEventListener( joinEventHandler )

    local scrollBG = mWidget:getChildByName( "Panel_BG_Joined_Comp" )
    local scrollViewJoined = tolua.cast( mWidget:getChildByName("ScrollView_Joined_Comp"), "ScrollView" )
    -- bug! layout type is automatically set to LAYOUT_ABSOLUTE(0) ???
    scrollViewJoined:setLayoutType(LAYOUT_LINEAR_VERTICAL) 
    
    local panelNone = scrollBG:getChildByName("Panel_No_Comp")
    if compList:getSize() > 0 then
        panelNone:setEnabled( false )
        scrollViewJoined:setEnabled( true )
        scrollViewJoined:removeAllChildrenWithCleanup( true )

        local height = 0
        local layoutParameter = LinearLayoutParameter:create()
        layoutParameter:setGravity(LINEAR_GRAVITY_CENTER_VERTICAL)
        for i = 1, compList:getSize() do
            local eventHandler = function( sender, eventType )
                if eventType == TOUCH_EVENT_ENDED then
                    enterCompetition( compList:get( i )["Id"] )
                end
            end
            
            local content = SceneManager.widgetFromJsonFile("scenes/CompetitionItemNew.json")
            content:setLayoutParameter( layoutParameter )
            scrollViewJoined:addChild( content )
            height = height + content:getSize().height

            local name = tolua.cast( content:getChildByName("Label_Name"), "Label" )
            name:setText( compList:get( i )["Name"] )

            local bt = content:getChildByName("Panel_Button")
            bt:addTouchEventListener( eventHandler )

            --[[if i == compList:getSize() then
                local separator = content:getChildByName("Image_Separator")
                separator:setEnabled( false )
            end]]--
        end

        local originalHeight = scrollViewJoined:getInnerContainerSize().height
        local scrollHeight = math.max( height, originalHeight )
        local newContainerHeight = math.min( MAX_CONTAINER_HEIGHT, scrollHeight )
        local deltaY = math.max( newContainerHeight - originalHeight, 0 )

        scrollViewJoined:setInnerContainerSize( CCSize:new( 0, scrollHeight ) )
        scrollViewJoined:setSize( CCSize:new( scrollViewJoined:getSize().width, newContainerHeight ) )
        scrollViewJoined:setPositionY( scrollViewJoined:getPositionY() - deltaY )

        local scrollBGDeltaY = scrollBG:getSize().height - originalHeight
        scrollBG:setSize( CCSize:new( scrollBG:getSize().width, newContainerHeight + scrollBGDeltaY ) )
        scrollBG:setPositionY( scrollBG:getPositionY() - deltaY )

        local layout = tolua.cast( scrollViewJoined, "Layout" )
        layout:requestDoLayout()
    else
        scrollViewJoined:setEnabled( false )
        local btnCreate = panelNone:getChildByName("Button_Create")
        btnCreate:addTouchEventListener( createEventHandler )

        local lblCTA = tolua.cast( panelNone:getChildByName("Label_CTA"), "Label" )
        lblCTA:setText( Constants.String.community.label_call_to_arm )
    end

    local tokenInput = ViewUtils.createTextInput( mWidget:getChildByName( "Panel_Code" ), Constants.String.enter_comp_code, 224 )
    tokenInput:setFontColor( ccc3( 0, 0, 0 ) )
    tokenInput:setPlaceholderFontColor( ccc3( 127, 127, 127 ) )
    tokenInput:setTouchPriority( SceneManager.TOUCH_PRIORITY_MINUS_ONE )
    local inputDelegate = EditBoxDelegateForLua:create()
    inputDelegate:registerEventScriptHandler( EDIT_BOX_EVENT_DID_BEGIN, function ( textBox )
        -- In order not to change the object-c code, here is the work around.
        -- recall the setPosition() to invoke the CCEditBoxImplIOS::adjustTextFieldPosition()
        -- Todo remove this code after the object-c fix is pushed out.
        tokenInput:setPosition( tokenInput:getPosition() )
    end )
    mWidget:getChildByName( "Panel_Code" ):addNode( tolua.cast( inputDelegate, "CCNode" ) )
    tokenInput:setDelegate( inputDelegate.__CCEditBoxDelegate__ )
end

function enterCompetition( competitionId )
    EventManager:postEvent( Event.Enter_Competition_Detail, { competitionId } )
end
