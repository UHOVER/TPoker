local DiffType = {}

--gamelayer，分享码、授权带入提示、开始按、提示、提示背景
function DiffType.initDiffLayer(csloader)
	local nox = 1000
	local noy = -2000
	local gbigType = Single:gameModel():getGameBigType()
	local gtype = Single:gameModel():getGameType()

	--sng：没有 授权带入提示、开始按、提示、提示背景
	--mtt：没有 授权带入提示、开始按、提示、提示背景
	if gbigType == GAME_BIG_TYPE_SNG then 
		csloader:getChildByName('startBtn'):setPositionX(nox)
		csloader:getChildByName('ttfPromptBg'):setPositionX(nox)
		csloader:getChildByName('ttfPromptMsg'):setPositionX(nox)
	elseif gbigType == GAME_BIG_TYPE_MTT then
		csloader:getChildByName('startBtn'):setPositionX(nox)
		csloader:getChildByName('ttfPromptBg'):setPositionX(nox)
		csloader:getChildByName('ttfPromptMsg'):setPositionX(nox)
	end

	--大厅：没有 分享码、授权带入提示、开始按、提示、提示背景
	local noAuthorize = {}	
	noAuthorize[ GAME_TYPE_HALL_STANDARD ] = true
	noAuthorize[ GAME_TYPE_HALL_HEADSUP ] = true
	noAuthorize[ GAME_TYPE_HALL_SNG ] = true
	if noAuthorize[ gtype ] then
		csloader:getChildByName('startBtn'):setPositionX(nox)
		csloader:getChildByName('ttfPromptBg'):setPositionX(nox)
		csloader:getChildByName('ttfPromptMsg'):setPositionX(nox)
	end


	--大厅标准和heads-up没有倒计时
	local noTime = {}
	noTime[ GAME_TYPE_HALL_STANDARD ] = true		
	noTime[ GAME_TYPE_HALL_HEADSUP ] = true		
	if noTime[ gtype ] then
		csloader:getChildByName('ttfGameTime'):setPositionX(nox)
	end

	--只有标准局有发发看
	if not DZConfig.isStandardPoker(gtype) then
		csloader:getChildByName('btnLookPool'):setPositionY(noy)
	end
end


--模拟进入游戏广播，sng差几人牌局开始提示
function DiffType.broDiffLayer(csloader)
	--sng提示差几人游戏开始
	local function sngPromptSignupNum(csloader)
		local node = cc.Node:create()
		local gamem = Single:gameModel()

		local function checkPersons()
			local lpb = csloader:getChildByName('linePromptBg')

			if gamem:isStarting() then
				lpb:setPositionX(1500)
				if node then
					node:removeFromParent()
					node = nil
				end

				return
			end

			local seatNum = UserCtrol.getSeatUserNum()
			local limitNum = gamem:getGameNum()
			local nullNum = tonumber(limitNum) - tonumber(seatNum)
			
			local text = '报名成功! 还差  '..nullNum..'  人开始比赛'
			lpb:setPositionX(display.cx)
			lpb:getChildByName('ttfLine'):setString(text)
		end
		
		DZSchedule.runSchedule(checkPersons, 1, node)
		csloader:addChild(node)
		checkPersons()
	end

	--sng
	local gbType = Single:gameModel():getGameBigType()
	if gbType == GAME_BIG_TYPE_SNG then
		sngPromptSignupNum(csloader)
	end
end



--标准牌局是否有房主
-- function DiffType.diffMenuContent(mcs)
-- 	local gtype = Single:gameModel():getGameType()
-- 	local manager = {}
-- 	manager[ GAME_TYPE_HALL_STANDARD ] = true
-- 	manager[ GAME_TYPE_HALL_HEADSUP ] = true

-- 	--没有房主：大厅标准、大厅heads-up
-- 	if manager[ gtype ] then
-- 		mcs._notManager()	
-- 	end
-- end


--退出游戏
function DiffType.exitGameScene()
	display.removeUnusedSpriteFrames()

	local GameScene = require('game.GameScene')
	local intoScene = GameScene.getExitIntoScene()

	if intoScene == StatusCode.INTO_MAIN then
   	 	local MainScene = require('main.MainScene')
		MainScene:startScene(true)
	else
		local CardScene = require('cards.CardScene')
		CardScene.startScene()
	end

	Single:paltform():leaveGame()
end

function DiffType.userExitGame()
	local gtype = Single:gameModel():getGameBigType()

	local function response()
		if gtype == GAME_BIG_TYPE_SNG then
	        local gid = GData.getGamePId()
	        if not  Single:gameModel():isStarting() then
                MainCtrol.leaveSngGame(gid, nil)
            end
		elseif gtype == GAME_BIG_TYPE_STANDARD then
		elseif gtype == GAME_BIG_TYPE_MTT then
		end

	    DiffType.exitGameScene()

	    --关闭语音
	    Storage.setIsCloseVoice(true)
	end

	SocketCtrol.exitGame(response)
end


--点击左上角按钮展示不同界面
function DiffType.diffMenuBtn()
	local gtype = Single:gameModel():getGameBigType()

	--sng、标准
	if gtype == GAME_BIG_TYPE_SNG then
		GWindow.showSNGMenu()	
	elseif gtype == GAME_BIG_TYPE_STANDARD then
		GWindow.showMenu()
	elseif gtype == GAME_BIG_TYPE_MTT then
		GWindow.showMTTMenu()
	end
end




--data
function DiffType.getRecordFee(bigBlind)
	local gtype = Single:gameModel():getGameType()
	local mul = DZConfig.gameRecordFeeMul(bigBlind, gtype)

	return bigBlind * 100 * mul
end



----------------------------------sng升盲计时--------------------------------
--sng
local function standardTime(cslayer)
	if cslayer:getChildByName('START_TIME_TAG') then
		cslayer:getChildByName('START_TIME_TAG'):removeFromParent()
	end
	local tnode = cc.Node:create()
	tnode:setName('START_TIME_TAG')
	cslayer:addChild(tnode)


	local function updateTime()
		local ttime = Single:gameModel():getGameTime()
		ttime = ttime - 1
		Single:gameModel():setGameTime(ttime)

		local times = DZTime.secondsHourFormat(ttime)
		cslayer:getChildByName('ttfGameTime'):setString(times)

		if ttime == 10 * 60 or ttime == 6 * 60 then
			SocketCtrol.checkSurplusTime()
		end
		if ttime == 1.5 * 60 or ttime == 2 * 60 or ttime == 0.5 * 60 then
			SocketCtrol.checkSurplusTime()
		end

		if ttime == 5 * 60 then
			GUI.showPromptTime('5分钟')
		end
		if ttime == 1 * 60 then
			GUI.showPromptTime('1分钟')
		end
	end

	updateTime()
	DZSchedule.runSchedule(updateTime, 1, tnode)
end

--升盲计时
local _uptime = 0
local function getUPTime()
	return _uptime
end
local function setUPTime(utime)
	if utime < 0 then utime = 0 end
	_uptime = utime
end

local _resttime = 0
local function getRestTime()
	return _resttime
end
local function setRestTime(resttime)
	if resttime < 0 then resttime = 0 end
	_resttime = resttime
end

local function sngTime(cslayer)
	if cslayer:getChildByName('START_TIME_TAG') then
		cslayer:getChildByName('START_TIME_TAG'):removeFromParent()
	end
	local tnode = cc.Node:create()
	tnode:setName('START_TIME_TAG')
	cslayer:addChild(tnode)

	_uptime = GData.getUpblindSurplusTime()
	
	local function isStart()
		if Single:gameModel():isStarting() then
			return true
		end

		cslayer:getChildByName('ttfGameTime'):setString('升盲 00:00')
		_uptime = GData.getUPBlindTime()
		return false
	end

	local function updateTime()
		--游戏没有开始
		if not isStart() then
			return
		end
		-- local times = ''
		if Single:gameModel():isResting() then
			local ttime = getRestTime() - 1
			setRestTime(ttime)
			-- times = '休息 '..DZTime.secondsMinFormat(ttime)
		else
			local ttime = getUPTime() - 1
			setUPTime(ttime)
			-- times = '升盲 '..DZTime.secondsMinFormat(ttime)
		end
		-- cslayer:getChildByName('ttfGameTime'):setString(times)
	end
	local function updateTimeLayer()
		--游戏没有开始
		if not isStart() then
			return
		end
		
		local times = ''
		if Single:gameModel():isResting() then
			times = '休息 '..DZTime.secondsMinFormat( getRestTime() )
		else
			times = '升盲 '..DZTime.secondsMinFormat( getUPTime() )
		end
		cslayer:getChildByName('ttfGameTime'):setString(times)
	end

	updateTime()
	DZSchedule.runSchedule(updateTime, 1, tnode)
	updateTimeLayer()
	DZSchedule.runSchedule(updateTimeLayer, 1.01, tnode)
end

--只有mtt升忙倒计时用
function DiffType.getUPBlindSeconds()
	if Single:gameModel():isResting() then
		return getRestTime()
	end
	return getUPTime()
end

function DiffType.getRestSeconds()
	return getRestTime()
end
function DiffType.resetRestTime(restTime)
	setRestTime(restTime)
end


--倒计时
function DiffType.countTime(cslayer)
	local nox = 1000
	local gBigType = Single:gameModel():getGameBigType()

	if gBigType == GAME_BIG_TYPE_SNG then
		-- cslayer:getChildByName('ttfGameTime'):setPositionX(nox)
		sngTime(cslayer)
	elseif gBigType == GAME_BIG_TYPE_STANDARD then
		--大厅标准没有
		local stype = Single:gameModel():getGameType()
		if stype ~= GAME_TYPE_HALL_STANDARD then
			standardTime(cslayer)
		end
	elseif gBigType == GAME_BIG_TYPE_MTT then
		sngTime(cslayer)
	end
end

--重置升盲计时
function DiffType.resetUpBlindTime()
	setUPTime(GData.getUPBlindTime())
end

--设置升盲剩余时间
function DiffType.setSurplusUpBlindTime(surplusUPTime)
	setUPTime(surplusUPTime)
end
--切换翻牌转牌河牌按钮
function DiffType.switchLookPookBtn()
	local round = Single:gameModel():getRoundNum()
	local resutImg = nil
	print ("当前回合名称："..round)
	if round == StatusCode.GAME_ROUND0 then 
		resutImg = "game/game_look_pool_text1.png"
	elseif  round == StatusCode.GAME_ROUND1 then 
		resutImg = "game/game_look_pool_text2.png"
	elseif round == StatusCode.GAME_ROUND2  then 
		resutImg = "game/game_look_pool_text3.png"
	elseif round == StatusCode.GAME_ROUND3 then 
		resutImg = "game/game_look_pool_text3.png"
	end
	return resutImg
end
return DiffType

--sng和普通区别
--1.左上角按钮显示
--2.左下角实时战况有个排名
--3.升盲时间
--4.升盲提示
--5.还有几个人开局