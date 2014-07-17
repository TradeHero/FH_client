module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local Navigator = require("scripts.views.Navigator")
local Constants = require("scripts.Constants")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList


local mWidget
-- Children list:
-- 1 to 5: page buttons

local mMovableContainer

local mTopLayer
local mOkButton
local mExitButton
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
        local image = ImageView:create()
        local imagePath = fileUtils:fullPathForFilename( Constants.TUTORIAL_IMAGE_PATH..mTutorialImages[i] )
        image:loadTexture( imagePath )
        mMovableContainer:addChild( image )
        image:setPosition( ccp( i * Constants.GAME_WIDTH - Constants.GAME_WIDTH / 2, Constants.GAME_HEIGHT / 2 ) )

        if i == table.getn( mTutorialImages ) then
            mOkButton = Button:create()
            mOkButton:loadTextures( fileUtils:fullPathForFilename( Constants.TUTORIAL_IMAGE_PATH.."OK_grey.png" ),
                                nil,
                                nil )
            image:addChild( mOkButton )
            mOkButton:setPosition( ccp( 0, 130 - Constants.GAME_HEIGHT / 2 ) )
            mOkButton:setTouchEnabled( true )
            mOkButton:addTouchEventListener( okEventHandler )
            mOkButton:setOpacity( 0 )
        end
    end

    mExitButton = Button:create()
    mExitButton:loadTextures( fileUtils:fullPathForFilename( Constants.TUTORIAL_IMAGE_PATH.."X_button.png" ),
                            nil,
                            nil )
    mWidget:addChild( mExitButton )
    mExitButton:setPosition( ccp( Constants.GAME_WIDTH - 120, Constants.GAME_HEIGHT - 120 ) )
    mExitButton:setTouchEnabled( true )
    mExitButton:addTouchEventListener( exitEventHandler )

    local intervalX = 40
    local startX = ( Constants.GAME_WIDTH - intervalX * ( table.getn( mTutorialImages ) - 1 ) ) / 2
    local startY = 130
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
end

function EnterOrExit( eventType )
    if eventType == "enter" then
    elseif eventType == "exit" then
        mWidget = nil
    end
end

function tutorialEnd()
    EventManager:postEvent( Event.Enter_Login_N_Reg )

    mCallbackFunc()
end

local originWidgetX
function onFrameTouch( sender, eventType )
    if eventType == TOUCH_EVENT_BEGAN then
        originWidgetX = mMovableContainer:getPositionX()
        mExitButton:setOpacity( 0 )
    elseif eventType == TOUCH_EVENT_ENDED or eventType == TOUCH_EVENT_CANCELED then
        local touchBeginPoint = sender:getTouchStartPos()
        local touchEndPoint = sender:getTouchEndPos()
        if touchBeginPoint.x - touchEndPoint.x > MIN_MOVE_DISTANCE then
            -- Swap to Left
            local seqArray = CCArray:create()
            seqArray:addObject( CCCallFunc:create( function()
                mMovableContainer:setTouchEnabled( false )
            end ) )
            seqArray:addObject( CCMoveTo:create( MOVE_TIME, ccp( mCurrentTutorialIndex * Constants.GAME_WIDTH * ( -1 ), 0 ) ) )
            seqArray:addObject( CCCallFunc:create( function()
                if mCurrentTutorialIndex < table.getn( mTutorialImages ) then
                    mCurrentTutorialIndex = mCurrentTutorialIndex + 1
                    updatePageIndicator()
                    mMovableContainer:setTouchEnabled( true )
                else
                    tutorialEnd()
                end
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
    if mCurrentTutorialIndex == table.getn( mTutorialImages ) then
        for i = 1, table.getn( mTutorialImages ) do
            local button = tolua.cast( mWidget:getChildByTag( i ), "Button" )
            button:setEnabled( false )
        end
        mOkButton:runAction( CCFadeIn:create( 0.1 ) )
        mExitButton:setOpacity( 0 )
    else
        for i = 1, table.getn( mTutorialImages ) do
            local button = tolua.cast( mWidget:getChildByTag( i ), "Button" )
            button:setEnabled( true )
            if i == mCurrentTutorialIndex then
                button:setBrightStyle( BRIGHT_HIGHLIGHT )
            else
                button:setBrightStyle( BRIGHT_NORMAL )
            end
        end
        mOkButton:setOpacity( 0 )
        mExitButton:runAction( CCFadeIn:create( 0.1 ) )
    end
end

function okEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        tutorialEnd()
    end
end

function exitEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        tutorialEnd()
    end
end