--Encapsulate SimpleAudioEngine to AudioEngine,Play music and sound effects. 
local M = {}
local sharedEngine = SimpleAudioEngine:sharedEngine()

M.INTRO             = "sounds/fh_intro.mp3"
M.SELECT_PREDICTION = "sounds/fh_select_prediction.mp3"
M.SUBMIT_PREDICTION = "sounds/fh_submit_prediction.mp3"
M.SETTINGS_ON_OFF   = "sounds/fh_settings_on_off.mp3"
M.SPIN_WHEEL        = "sounds/fh_spinthewheel.mp3"

function M.stopAllEffects()
    sharedEngine:stopAllEffects()
end

function M.getMusicVolume()
    return sharedEngine:getBackgroundMusicVolume()
end

function M.isMusicPlaying()
    return sharedEngine:isBackgroundMusicPlaying()
end

function M.getEffectsVolume()
    return sharedEngine:getEffectsVolume()
end

function M.setMusicVolume(volume)
    sharedEngine:setBackgroundMusicVolume(volume)
end

function M.stopEffect(handle)
    sharedEngine:stopEffect(handle)
end

function M.stopMusic(isReleaseData)
    local releaseDataValue = false
    if nil ~= isReleaseData then
        releaseDataValue = isReleaseData
    end
    sharedEngine:stopBackgroundMusic(releaseDataValue)
end

function M.playMusic(filename, isLoop)
    local loopValue = false
    if nil ~= isLoop then
        loopValue = isLoop
    end
    sharedEngine:playBackgroundMusic(filename, loopValue)
end

function M.pauseAllEffects()
    sharedEngine:pauseAllEffects()
end

function M.preloadMusic(filename)
    sharedEngine:preloadBackgroundMusic(filename)
end

function M.resumeMusic()
    sharedEngine:resumeBackgroundMusic()
end

function M.playEffect(filename, isLoop)
    if CCUserDefault:sharedUserDefault():getBoolForKey( require("scripts.Constants").NOTIFICATION_KEY_SFX ) == true then
        return
    end

    local loopValue = false
    if nil ~= isLoop then
        loopValue = isLoop
    end
    return sharedEngine:playEffect(filename, loopValue)
end

function M.rewindMusic()
    sharedEngine:rewindBackgroundMusic()
end

function M.willPlayMusic()
    return sharedEngine:willPlayBackgroundMusic()
end

function M.unloadEffect(filename)
    sharedEngine:unloadEffect(filename)
end

function M.preloadEffect(filename)
    sharedEngine:preloadEffect(filename)
end

function M.setEffectsVolume(volume)
    sharedEngine:setEffectsVolume(volume)
end

function M.pauseEffect(handle)
    sharedEngine:pauseEffect(handle)
end

function M.resumeAllEffects(handle)
    sharedEngine:resumeAllEffects()
end

function M.pauseMusic()
    sharedEngine:pauseBackgroundMusic()
end

function M.resumeEffect(handle)
    sharedEngine:resumeEffect(handle)
end

local modename = "AudioEngine"
local proxy = {}
local mt    = {
    __index = M,
    __newindex =  function (t ,k ,v)
        print("attemp to update a read-only table")
    end
} 
setmetatable(proxy,mt)
_G[modename] = proxy
package.loaded[modename] = proxy


