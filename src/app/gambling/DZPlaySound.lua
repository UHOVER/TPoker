--
-- Author: Your Name
-- Date: 2016-08-26 10:46:31
--
local DZPlaySound = {}
local gdir = 'sound/game/'

DZPlaySound.isQuiet = false--是否静音 false没静音

--播发音效
--filePath 音频文件路径名字
--isLoop 是否循环播发 true循环 false不循环
--返回该音频id
function DZPlaySound.playSound(filePath, isLoop)
	--如果静音状态，不播放任何音效返回－1
	if(DZPlaySound.isQuiet == true) then
		return -1
	end

	return ccexp.AudioEngine:play2d(filePath, isLoop, 1.0)
end

--停止播放音效
--音效ID
function DZPlaySound.stopSound(soundID)
	ccexp.AudioEngine:stop(soundID)
end

--加载音效
--soundFilePath 文件路径
function DZPlaySound.loadSound(soundFilePath)
	ccexp.AudioEngine:preload(soundFilePath)
end
	
--卸载音效
--soundFilePath 文件路径
function DZPlaySound.unloadSound(soundFilePath)
	ccexp.AudioEngine:uncache(soundFilePath)
end



--游戏中音乐
--进到游戏时候就会初始化一下
local _isGameQuiet = false
function DZPlaySound.setGameQuiet(isQuiet)
	_isGameQuiet = isQuiet
end
function DZPlaySound.getGameQuiet()
	return _isGameQuiet
end

function DZPlaySound.playGameSound(filePath, isLoop)
	--如果静音状态，不播放任何音效返回－1
	if _isGameQuiet == true then
		return -1
	end

	--设置里关闭音效了
	if Storage.isCloseGameSound() then
		return -1
	end

	local vid = ccexp.AudioEngine:play2d(filePath, isLoop, 1.0)
	-- ccexp.AudioEngine:setVolume(vid, 1)
	return vid
end
function DZPlaySound.stopGameSound(soundID)
	ccexp.AudioEngine:stop(soundID)
end




--游戏中
local function getSound(file)
	return gdir..file..'.wav'
end


function DZPlaySound.stopAllSound()
	ccexp.AudioEngine:stopAll()
end
function DZPlaySound.loadAllSound()
end


local _gbetId = -1
function DZPlaySound.playBet()
	-- 下注时声音
	_gbetId = DZPlaySound.playGameSound(getSound('bet'))
end
function DZPlaySound.stopBet()
	DZPlaySound.stopGameSound(_gbetId)
end

local _gcheckId = -1
function DZPlaySound.playCheck()
	-- 看牌按钮时声音
	_gcheckId = DZPlaySound.playGameSound(getSound('check'))
end
function DZPlaySound.stopCheck()
	DZPlaySound.stopGameSound(_gcheckId)
end

local _gclockId = -1
function DZPlaySound.playClock()
	-- 倒计时的声音
	DZPlaySound.stopClock()
	_gclockId = DZPlaySound.playGameSound(getSound('clock'), true)
end
function DZPlaySound.stopClock()
	DZPlaySound.stopGameSound(_gclockId)
	_gclockId = -1
end


local _gdealId = -1
function DZPlaySound.playDeal()
	-- 每个人发基础牌的声音
	_gdealId = DZPlaySound.playGameSound(getSound('deal'))
end
function DZPlaySound.stopDeal()
	DZPlaySound.stopGameSound(_gdealId)
end

local _gflopId = -1
function DZPlaySound.playFlop()
	-- 翻牌时声音
	_gflopId = DZPlaySound.playGameSound(getSound('flop'))
end
function DZPlaySound.stopFlop()
	DZPlaySound.stopGameSound(_gflopId)
end

local _gfoldId = -1
function DZPlaySound.playFold()
	-- 弃牌时声音
	_gfoldId = DZPlaySound.playGameSound(getSound('fold'))
end
function DZPlaySound.stopFold()
	DZPlaySound.stopGameSound(_gfoldId)
end

local _ggearId = -1
function DZPlaySound.playGear()
	_ggearId = DZPlaySound.playGameSound(getSound('gear'))
end
function DZPlaySound.stopGear()
	DZPlaySound.stopGameSound(_ggearId)
end

local _gwinId = -1
function DZPlaySound.playWin()
	-- youwin时的声音
	_gwinId = DZPlaySound.playGameSound(getSound('movechips'))
end
function DZPlaySound.stopWin()
	DZPlaySound.stopGameSound(_gwinId)
end

local _gturnMeId = -1
function DZPlaySound.playTurnMe()
	-- 轮到自己的提示音
	_gturnMeId = DZPlaySound.playGameSound(getSound('myturn'))
end
function DZPlaySound.stopTurnMe()
	DZPlaySound.stopGameSound(_gturnMeId)
end


function DZPlaySound.gameResumeAll()
	ccexp.AudioEngine:resumeAll()
end

function DZPlaySound.gamePauseAll()
	ccexp.AudioEngine:pauseAll()
end


return DZPlaySound
