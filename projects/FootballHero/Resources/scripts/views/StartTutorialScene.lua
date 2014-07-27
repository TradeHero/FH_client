module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local Navigator = require("scripts.views.Navigator")
local Constants = require("scripts.Constants")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList


local mWidget
-- Children list:
-- 1 to 5: page buttons
local mHomepageWidget
local mMovableContainer

local mTopLayer
local mTutorialImages = {
    "TutorialP1.png",
    "TutorialP2.png",
    "TutorialP3.png",
    "TutorialP4.png",
    "TutorialP5.png",
}
local mCurrentTutorialIndex
local mCallbackFunc


local MIN_MOVE_DISTANCE = 100
local MOVE_TIME = 0.2
local SCALE_TIME = 0.3

function loadFrame( callback )
    mCallbackFunc = callback

    mWidget = Layout:create()
    mWidget:registerScriptHandler( EnterOrExit )
    SceneManager.clearNAddWidget( mWidget )

    mMovableContainer = Layout:create()
    mMovableContainer:setSize( CCSize:new( Constants.GAME_WIDTH * table.getn( mTutorialImages ), Constants.GAME_HEIGHT ) )
    mMovableContainer:setTouchEnabled( true )
    mMovableContainer:addTouchEventListener( onFrameTouch )
    mWidget:addChild( mMovableContainer )

    local fileUtils = CCFileUtils:sharedFileUtils()
    for i = 1, table.getn( mTutorialImages ) do
        if i == 1 then
            mHomepageWidget = GUIReader:shareReader():widgetFromJsonFile("scenes/TutorialHomepage.json")
            mMovableContainer:addChild( mHomepageWidget )
        else
            local image = ImageView:create()
            local imagePath = fileUtils:fullPathForFilename( Constants.TUTORIAL_IMAGE_PATH..mTutorialImages[i] )
            image:loadTexture( imagePath )
            mMovableContainer:addChild( image )
            image:setPosition( ccp( i * Constants.GAME_WIDTH - Constants.GAME_WIDTH / 2, Constants.GAME_HEIGHT / 2 ) )
        end
    end

    local intervalX = 30
    local startX = ( Constants.GAME_WIDTH - intervalX * ( table.getn( mTutorialImages ) - 1 ) ) / 2
    local startY = 350
    for i = 1, table.getn( mTutorialImages )  do
        local button = Button:create()
        button:loadTextures( fileUtils:fullPathForFilename( Constants.TUTORIAL_IMAGE_PATH.."dot_inactivepage.png" ),
                            fileUtils:fullPathForFilename( Constants.TUTORIAL_IMAGE_PATH.."dot_activepage.png" ),
                            nil )
        mWidget:addChild( button, 0, i )
        button:setPosition( ccp( startX + ( i - 1 ) * intervalX, startY ) )
    end

    mCurrentTutorialIndex = 1
    updatePageIndicator()

    playStartAnim()
end

function EnterOrExit( eventType )
    if eventType == "enter" then
    elseif eventType == "exit" then
        mWidget = nil
    end
end

function signinTypeEmailEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then

    end
end

function signinTypeFacebookEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        EventManager:postEvent( Event.Do_FB_Connect )
    end
end

local originWidgetX
function onFrameTouch( sender, eventType )
    if eventType == TOUCH_EVENT_BEGAN then
        originWidgetX = mMovableContainer:getPositionX()
    elseif eventType == TOUCH_EVENT_ENDED or eventType == TOUCH_EVENT_CANCELED then
        local touchBeginPoint = sender:getTouchStartPos()
        local touchEndPoint = sender:getTouchEndPos()
        if touchBeginPoint.x - touchEndPoint.x > MIN_MOVE_DISTANCE and mCurrentTutorialIndex < table.getn( mTutorialImages ) then
            -- Swap to Left
            local seqArray = CCArray:create()
            seqArray:addObject( CCCallFunc:create( function()
                mMovableContainer:setTouchEnabled( false )
            end ) )
            seqArray:addObject( CCMoveTo:create( MOVE_TIME, ccp( mCurrentTutorialIndex * Constants.GAME_WIDTH * ( -1 ), 0 ) ) )
            seqArray:addObject( CCCallFunc:create( function()
                mCurrentTutorialIndex = mCurrentTutorialIndex + 1
                updatePageIndicator()
                mMovableContainer:setTouchEnabled( true )
            end ) )

            mMovableContainer:runAction( CCSequence:create( seqArray ) )
            
        elseif touchBeginPoint.x - touchEndPoint.x < MIN_MOVE_DISTANCE * (-1) and mCurrentTutorialIndex > 1 then
            -- Swap to Right
            local seqArray = CCArray:create()
            seqArray:addObject( CCCallFunc:create( function()
                mMovableContainer:setTouchEnabled( false )
            end ) )
            seqArray:addObject( CCMoveTo:create( MOVE_TIME, ccp( ( mCurrentTutorialIndex - 2 ) * Constants.GAME_WIDTH * ( -1 ), 0 ) ) )
            seqArray:addObject( CCCallFunc:create( function()
                mCurrentTutorialIndex = mCurrentTutorialIndex - 1
                updatePageIndicator()
                mMovableContainer:setTouchEnabled( true )
            end ) )

            mMovableContainer:runAction( CCSequence:create( seqArray ) )
        else
            -- Reset back
            local seqArray = CCArray:create()
            seqArray:addObject( CCCallFunc:create( function()
                mMovableContainer:setTouchEnabled( false )
            end ) )
            seqArray:addObject( CCMoveTo:create( MOVE_TIME, ccp( ( mCurrentTutorialIndex - 1 ) * Constants.GAME_WIDTH * ( -1 ), 0 ) ) )
            seqArray:addObject( CCCallFunc:create( function()
                mMovableContainer:setTouchEnabled( true )
                updatePageIndicator()
            end ) )

            mMovableContainer:runAction( CCSequence:create( seqArray ) )
        end
    elseif eventType == TOUCH_EVENT_MOVED then
        local touchBeginPoint = sender:getTouchStartPos()
        local touchMovPoint = sender:getTouchMovePos()
        local moveOffsetX = touchBeginPoint.x - touchMovPoint.x

        mMovableContainer:setPosition( ccp( originWidgetX - moveOffsetX, mMovableContainer:getPositionY() ) )
    end
end

function updatePageIndicator()
    for i = 1, table.getn( mTutorialImages ) do
        local button = tolua.cast( mWidget:getChildByTag( i ), "Button" )
        button:setEnabled( true )
        if i == mCurrentTutorialIndex then
            button:setBrightStyle( BRIGHT_HIGHLIGHT )
        else
            button:setBrightStyle( BRIGHT_NORMAL )
        end
    end
end

function playStartAnim()
    local homepageLogo = mHomepageWidget:getChildByName("Logo")
    local bg = mHomepageWidget:getChildByName("bg")

    local resultSeqArray = CCArray:create()

    local spawnArray = CCArray:create()
    spawnArray:addObject( CCTargetedAction:create( homepageLogo, CCScaleTo:create( SCALE_TIME, 0.7 ) ) )
    spawnArray:addObject( CCTargetedAction:create( homepageLogo, CCMoveBy:create( SCALE_TIME, ccp( 0, 200 ) ) ) )
    spawnArray:addObject( CCTargetedAction:create( bg, CCFadeTo:create( SCALE_TIME, 180 ) ) )
    resultSeqArray:addObject( CCSpawn:create( spawnArray ) )

    resultSeqArray:addObject( CCCallFunc:create( function() 
        EventManager:postEvent( Event.Enter_Tutorial_Ui_With_Type, { Constants.TUTORIAL_SHOW_SIGNIN_TYPE } )
    end ) )

    mWidget:runAction( CCSequence:create( resultSeqArray ) )
end

function playSwitchToEmailSignin()

end