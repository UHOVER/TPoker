local SceneBase = require 'ui.SceneBase'
local GameScene = class("GameScene", SceneBase)

local GameLayer 		= require 'game.GameLayer'
local GameWait 			= require 'game.GameWait'	
local BroCtrol			= require 'game.BroCtrol'

cc.exports.GText		= require 'game.GText'
cc.exports.SocketCtrol 	= require 'game.SocketCtrol'
cc.exports.GameCtrol 	= require 'game.GameCtrol'
cc.exports.GWindow 		= require 'game.GWindow'
cc.exports.GData 		= require 'game.GData'
cc.exports.GSelfData 	= require 'game.GSelfData'
cc.exports.SelfLayer 	= require 'game.SelfLayer'
cc.exports.GameHelp 	= require 'game.GameHelp'
cc.exports.GAnimation	= require 'game.GAnimation'
cc.exports.DiffType		= require 'game.DiffType'
cc.exports.DZSort		= require 'utils.DZSort'
cc.exports.GJust		= require 'game.GJust'
cc.exports.GUI			= require 'game.GUI'
cc.exports.BroAnimation	= require 'game.BroAnimation'
cc.exports.GMath		= require 'game.GMath'
cc.exports.UserCtrol	= require 'game.UserCtrol'
cc.exports.GMttBuy		= require 'game.GMttBuy'

local scheduler = cc.Director:getInstance():getScheduler()

local _node = nil
local _isGameScene = false
local _exitIntoScene = -1
local SCENE_NAME = 'GAME_SCENE_TAG'


local _gameSceneState = StatusCode.GAME_IDEL_STATE 
local _memcopyData = nil
local _needStateDelay = 0
local _statelistenId = -1
local function changeGameState(_targetState, delay, tmpData)
	if (_gameSceneState == _targetState) then 
		return 
	end
	_gameSceneState = _targetState
	_needStateDelay = delay
	_memcopyData = tmpData

	if _statelistenId < 0 then 
		_statelistenId = scheduler:scheduleScriptFunc(function(dt) 
				GameScene.updateGame(dt)
			end, 0, false)
	end
end

local function isGameScene()
	local runScene = cc.Director:getInstance():getRunningScene()
    if runScene and runScene:getName() ~= SCENE_NAME then
    	return false
    end
    return true
end

local function initScene(parent)
	_isGameScene = true
	
	GAnimation.startSchedule()
	Network.launchCacheBro()

	local function onEvent(event)
		if event == "enter" then
		elseif event == "exitTransitionStart" then
			_isGameScene = false
		elseif event == "enterTransitionFinish" then
			Network.closeCacheBro()
		elseif event == "exit" then
			_node = nil
			_isGameScene = false
			
			GameLayer:getInstance():clearGameLayer()
			-- Single:gameModel():clearData()
			
			-- GameCtrol.clearData()
			
			GAnimation.removeSchedule()
		end
	end

	--scene之上
	_node = cc.Node:create()
	_node:setName(GAME_SCENE_NODE)
	_node:registerScriptHandler(onEvent)
	parent:addChild(_node)
		
	local gameLayer = GameLayer:getInstance()
	_node:addChild(gameLayer)
	local csloader = gameLayer:createLayer()
	Single:playerManager():init(csloader)
	SelfLayer:initLayer(csloader)

end


local function initGame(data, cScene, brow)
	SocketCtrol.initGameData(data)
	initScene(cScene)
	SocketCtrol.initGameBro(data, brow)
end


function GameScene.getExitIntoScene()
	return _exitIntoScene
end


local _isEnter = true
function GameScene.startScene(pokerid, exitIntoScene, isAutoSeat)
	if not _isEnter then return end

	_isEnter = false
	DZSchedule.schedulerOnce(2, function()
		_isEnter = true
	end)


	NoticeCtrol.removeNoticeNode()

	_exitIntoScene = exitIntoScene

	local tScene = nil

	local function startSceneBack(data)
		if isGameScene() then return end

		local function onEvent(event)
			if event == "enter" then
				DZPlaySound.loadAllSound()
			elseif event == "exit" then
				DZPlaySound.stopAllSound()
				BroCtrol.unregisterBro()
			elseif event == "enterTransitionFinish" then
				initGame(data, tScene, WS_INTO_GAME_BRO)
				--scene切换完成
				BroCtrol.enterScened()
			end
		end

		--scene切换中
		BroCtrol.enterScening()

		--最前面
		Storage.setIsCloseVoice(false)

		local scene = GameScene:create()
		scene:setName(SCENE_NAME)
		cc.Director:getInstance():replaceScene(scene)
		tScene = scene
		scene:registerScriptHandler(onEvent)

		NewMsgMgr.registerDisplayScene(scene)



		GAnimation.clearData()
		local CheckNet = require 'network.CheckNet'
		CheckNet.checkGameNet(scene)
	    --打开
		Single:paltform():intoGame()
	end

	Single:gameModel():setNoPushEnd(false)
	SocketCtrol.conWSSocket(pokerid, startSceneBack, isAutoSeat)
end


--
local function connGame(cpokerId)
	local function startNodeBack(data)
		if _node then
			_node:removeFromParent()
		end

		local runScene = cc.Director:getInstance():getRunningScene()
		initGame(data, runScene, WS_INTO_GAME_BRO)
	end

	SocketCtrol.conWSSocket(cpokerId, startNodeBack)
end

--1.从后台进入断网重连
--2.断网重连
function GameScene.EnterForeground(data)
	changeGameState(StatusCode.GAME_ENTER_FORE, 0, data)
end

--mtt拆桌重新请求数据
function GameScene.mttChangeDesk(cpokerId)
	connGame(cpokerId)
end

--数据出错重新请求
function GameScene.updateGameData()
    if not isGameScene() then return end
	connGame( GData.getGamePId() )
end

function GameScene.EnterBackground()
    if not isGameScene() then return end
    changeGameState(StatusCode.GAME_ENTER_BACK, 0)
	-- 清除广播队列
	-- GAnimation.clearData()
end

function GameScene.NetworkDisconnection()
    if not GameScene.isDisGameScene() then return end
  	changeGameState(StatusCode.GAME_RECONNECT, 0)
end

function GameScene.NetworkConnectionAgain()
    if not GameScene.isDisGameScene() then return end
    changeGameState(StatusCode.GAME_RECONNECT, 0)
end


function GameScene.isDisGameScene()
	return _isGameScene
end



--3000广播
--显示新消息
function GameScene.disNewMsgSignUp()
	NewMsgMgr.setNewMsgTrue()

    if not GameScene.isDisGameScene() then return end
	GameCtrol.displayNewMsgSignUp()
end


--移除新消息标示
function GameScene.removeNewMsgSignUp()
	NewMsgMgr.setNewMsgFalse()
	
    if not GameScene.isDisGameScene() then return end
	GameCtrol.removeNewMsgSignUp()
end


--mtt授权补充记分牌审核结果
function GameScene.mttCheckResult(isPass)
    if not GameScene.isDisGameScene() then return end
	local text = '审核通过'
	if isPass then
		text = '审核通过'
	else
		text = '审核被拒'
	end
	ViewCtrol.showMsg(text, 1.2)
end

--解散游戏
function GameScene.disbandGame(gid)
	if not GameScene.isDisGameScene() then return end
	
	local function exitFunc()
		-- SocketCtrol.exitGame(function()
            local MainScene = require 'main.MainScene'
            MainScene:startScene()
        -- end)
	end

	if GData.getGamePId() == gid then
		local params = {}
		params['listener'] = exitFunc
		params['title'] = '提示信息'
		params['content'] = '当前牌桌已被房主解散'
		MessageWin.showTip(params)
	end
end


------------------------------------------------------
-- 根绝设备与游戏所处状态进行不同的处理
------------------------------------------------------


local function processConnectionAgain(data)
    local WaitServer = require 'ui.WaitServer'
	WaitServer.removeForeverWait()
	Network.connect()
end

local function processDisConnection(data)
    local WaitServer = require 'ui.WaitServer'
    Network.close()
    WaitServer.showForeverWait()
end

local function processEnterForeground(data)
	--玩家刚登录进入,检查是否在游戏中，在游戏中跳转到之前的牌桌
    if not isGameScene() then
    	if data and data['roomId'] and data['seatNum'] then
    		if data['seatNum'] ~= -1 then
    			if data['mttCode'] then
    				--mtt
    				GameWait.requestMttCodeAndPokerId(data['mttCode'], data['roomId'])
    			else
					GameScene.startScene(data['roomId'])
				end
			end
		end
    	return 
    end

    local bigtype = Single:gameModel():getGameBigType()
    if bigtype == GAME_BIG_TYPE_MTT then
    	GameWait.requestPokerId(GData.getMttCode(), connGame)	
    else
    	connGame( GData.getGamePId() )
    end

end

local function processEnterBackground(data)
end

local processes = {}
processes[StatusCode.GAME_IDEL_STATE] = function() 
	if _statelistenId > 0 and _needStateDelay <= 0 then 
		scheduler:unscheduleScriptEntry(_statelistenId)
		_statelistenId = -1
	end 
end

processes[StatusCode.GAME_RECONNECT] = processConnectionAgain
processes[StatusCode.GAME_EXITCONNECT]=processDisConnection
processes[StatusCode.GAME_ENTER_BACK] =processEnterBackground
processes[StatusCode.GAME_ENTER_FORE] =processEnterForeground

------------------------------------------------
--- 闲置60秒左右，自动终止
--- 当有状态变化，通过changeGameState自动启动
------------------------------------------------
function GameScene.updateGame(dt)
	local curState = _gameSceneState
	_needStateDelay = _needStateDelay - dt
	if _needStateDelay > 0 then 
		_needStateDelay = 0
		return 
	end

	local processHandler = processes[curState]
	if processHandler then 
		processHandler(_memcopyData)

		changeGameState(StatusCode.GAME_IDEL_STATE, 60)
		_memcopyData = nil
	end
end
--------------------------------------------------
--END
--------------------------------------------------
return GameScene
