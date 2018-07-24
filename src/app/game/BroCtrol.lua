local BroCtrol = {}
local _gameModel = nil
local _bros = nil

--玩家坐下2000
local function playerSeat(data)
	GameCtrol.handlePlayerSeat(data, data['protocolNum'])
end

--服务器给玩家发两张牌2001
local function sendCards(data)
	if GData.getNowAnte() <= 0 then
		GameCtrol.resetLayerData(StatusCode.START_CLEAR)
	end

	_gameModel:setStarting(true)
	_gameModel:setSayUserPos(data['currentSeatNum'])
	-- _gameModel:setSmallBlind(data['smallBlindBetNum'])
	_gameModel:setSmallBlind(data['currentGameBigblindBet'] / 2)
	_gameModel:setBeforeTalkBet(data['beforeTalkBet'])
	_gameModel:setRoundNum(StatusCode.GAME_ROUND0)

	-- local poolBet = tonumber(data['bigBlindBetNum']) + tonumber(data['smallBlindBetNum'])
	local poolBet = data['beforeTalkBet']
	_gameModel:setPoolNowBet(poolBet)

	if data['cards'] and #data['cards'] ~= 0 then
		_gameModel:setCardOne(data['cards'][1])
		_gameModel:setCardTwo(data['cards'][2])
	else
		_gameModel:setCardOne(nil)
		_gameModel:setCardTwo(nil)
	end

	GameCtrol.handleSendCards(data, data['protocolNum'])
end

--玩家做出选择操作如：弃牌、加注2002
local function playerSelect(data)
	_gameModel:setPoolNowBet(data['poolBet'])
	_gameModel:setSayUserPos(data['currentSeatNum'])
	GameCtrol.handlePlayerSelect(data, data['protocolNum'])
end

--服务器向牌池发牌2003
local function sendPool(data)
	_gameModel:setRoundNum(data['round'])
	_gameModel:setRoundPoolBet(data['roundPoolBet'])
	_gameModel:setSayUserPos(data['currentSeatNum'])
	_gameModel:addPoolCard(data['newCards'])
	
	GameCtrol.handleSendPool(data, data['protocolNum'])
end

--站起围观2005
local function standLook(data)
	GameCtrol.handleStandLook(data, data['protocolNum'])
end

--本回合结果2007
local function roundResult(data)
	--2007增加roundPoolBet字段后去掉
	-- _gameModel:setRoundPoolBet({_gameModel:getPoolNowBet()})
	_gameModel:setRoundPoolBet(data['roundPoolBet'])
	GameCtrol.handleRoundResult(data, data['protocolNum'])
end

--发送表情2008
local function sendEmoji(data)
	GameCtrol.handleSendEmoji(data, data['protocolNum'])
end

--房间关闭2009
local function closeHome(data)
	GameCtrol.handleCloseHome(data, data['protocolNum'])
end

--玩家进入游戏2010
local function userInto(data)
	GameCtrol.handleInto(data, data['protocolNum'])
end

--玩家退出游戏2011
local function userExit(data)
	GameCtrol.handleExit(data, data['protocolNum'])
end

--房主暂停游戏2012
local function pauseGame(data)
	GameCtrol.handleStopGame(data, data['protocolNum'])
end

--暂停后继续游戏2013
local function goonGame(data)
	GameCtrol.handleGoOnGame(data, data['protocolNum'])
end

--有玩家申请补充记分牌2014
local function applayAddScores(data)
	GameCtrol.handleApplayAddScores(data, data['protocolNum'])
end

--有玩家补充记分牌2015
local function addScores(data)
	GameCtrol.handleAddScores(data, data['protocolNum'])
end

--申请被拒绝2016
local function applayRefused(data)
	GameCtrol.handleApplayRefused(data, data['protocolNum'])
end

--申请通过2017
local function applayAgree(data)
	GameCtrol.handleApplayAgree(data, data['protocolNum'])
end

--没有补充记分牌申请2018
local function noApplay(data)
	-- GameCtrol.handleNoApplay(data, data['protocolNum'])
end

--改变授权带入状态2019
local function changeApplay(data)
	_gameModel:setOpenApplay(data['controlBuyin'])
	GameCtrol.handleChangeApplay(data, data['protocolNum'])
end

--核查记分牌2020
local function checkBet(data)
	GameCtrol.handleCheckBet(data, data['protocolNum'])

	GameCtrol.resetLayerData(StatusCode.END_CLEAR)
end

--sng
--升盲2021
local function upBlind(data)
	GameCtrol.handleUpBlind(data, data['protocolNum'])
end

--托管2022
local function trusteeship(data)
	GameCtrol.handleTrusteeship(data, data['protocolNum'])
end

--增加思考时间2023
local function addThinkTime(data)
	GameCtrol.handleAddThinkTime(data, data['protocolNum'])
end

--发送动画2024
local function sendAnimation(data)
	GameCtrol.handleSendAnimation(data, data['protocolNum'])	
end

--重置倒计时2025
local function resetGameTime(data)
	GameCtrol.handleResetGameTime(data, data['protocolNum'])	
end

--玩家亮牌2026
local function displayTwoCard(data)
	GameCtrol.handleDisTwoCard(data, data['protocolNum'])
end

--mtt决赛或中场休息2027
local function mttRest(data)
	GameCtrol.handleMttRest(data, data['protocolNum'])
end

--玩家重购提示2028
local function promptRevive(data)
	GameCtrol.handlePromptRevive(data, data['protocolNum'])
end

--mtt游戏结束通知2029
local function mttGameOver(data)
	GameCtrol.handlMttOver(data, data['protocolNum'])
end

--mtt拆桌合桌提示2030
local function mttDeskPrompt(data)
	GameCtrol.handlePromptDesk(data, data['protocolNum'])
end

--房间关闭2031
local function closeGameRoom(data)
	GameCtrol.handleCloseGameRoom(data, data['protocolNum'])
end

--发发看广播2032
local function lookPoolPoker(data)
	if not data['round'] or not data['newCards'] then
		return
	end
	if not GAnimation.isRun2007() then return end

	_gameModel:setRoundNum(data['round'])
	_gameModel:addPoolCard(data['newCards'])
	GameCtrol.handleLookPoolPoker(data, data['protocolNum'])
end

--玩家排名2033:mtt
local function playerRank(data)
	GameCtrol.handlePlayerRank(data['rank'])
end

--移除中场和决赛前休息提示2034:mtt
local function removeRest(data)
	GameCtrol.handleRemoveRest(data, data['protocolNum'])
end

--mtt玩家已经增购和重构次数
local function updateBuyTimes(data)
	GameCtrol.handleUpdateBuyTimes(data)
end


--玩家进入保险模式 2101
local function displayIntoInsureAnim(data)
	GameCtrol.handlerIntoInsureModeAnim(data, data['protocolNum'])
end

--玩家进入购买保险界面 2102
local function displayInsurePanel(data)
	print("进入保险 请注意 displayInsurePanel")
	-- local isAnim = true;
	-- if data['needSelect'] then 
	-- 	local poolCards = data['poolCards'] 
	-- 	local num = #poolCards
		
	-- 	if num >= 4 then 
	-- 		isAnim = false
	-- 	end
	-- else 
	-- 	isAnim = false
	-- end
	GameCtrol.handlerInsurePanel(data, isAnim, data['protocolNum'])
end

--玩家购买保险的界面变化同步 2103
local function displaySycInsureUIPanel(data)
	print("同步保险UI")
	GameCtrol.sycInsureUIPanel(data, data['protocolNum'])
end

--有人购买了保险 		2104
local function insureNotification(data)
	print("insureNotification")
	GameCtrol.notifiyPurchase(data, data['protocolNum'])
end

--搓牌  开始搓牌
local function displayTwistCard(data)
	--TODO: tanhaiting
end

--翻开一张牌  保险界面
local function handlerInsureFlopCards(data)
	print("=====handlerInsureFlopCards=====")
	-- _gameModel:setRoundNum(data['round'])
	-- _gameModel:setRoundPoolBet(data['roundPoolBet'])
	-- _gameModel:setSayUserPos(data['currentSeatNum'])
	--------------
	--start Test 开始测试
		-- _gameModel:clearPoolCard()
	--end Test 结束测试
	--------------
	_gameModel:addPoolCard({data['card']})
	GameCtrol.handlerInsureFlopCards(data)
end
 
--保险局亮牌操作 2108
local function handlerPresentCards(data)
	GameCtrol.handlerPresentCards(data)
end

--下ante前注 2200
local function handleAnte(data)
	GameCtrol.resetLayerData(StatusCode.ANTE_CLEAR)
	if not data['ante'] then
		data['ante'] = 0
	end
	GData.setNowAnte(data['ante'])
	_gameModel:setPoolNowBet(data['ante'])
	_gameModel:setRoundPoolBet(data['roundPoolBet'])

	GameCtrol.handleGameAnte(data, data['protocolNum'])
end

--游戏模式切换 2050
local function handleStraddle(data)

	GameCtrol.handlerStraddlePrompt(data)
end


--广
local handles = {}
handles[ BRO_PLAYER_SEAT ] 		= playerSeat
handles[ BRO_SEND_CARDS ] 		= sendCards
handles[ BRO_PLAYER_SELECT ] 	= playerSelect
handles[ BRO_SEND_POOL ] 		= sendPool
handles[ BRO_STAND_LOOK ] 		= standLook
handles[ BRO_ROUND_RESULT ] 	= roundResult
handles[ BRO_SEND_EMOJI ] 		= sendEmoji
handles[ BRO_HOME_CLOSE ] 		= closeHome
handles[ BRO_USER_INTO ] 		= userInto
handles[ BRO_USER_EXIT ] 		= userExit
handles[ BRO_PAUSE_GAME ] 		= pauseGame
handles[ BRO_GOON_GAME ] 		= goonGame

--补充记分牌
handles[ BRO_APPLAY_SCORES ] 	= applayAddScores
handles[ BRO_ADD_SCORES ] 		= addScores
handles[ BRO_APPLAY_REFUSED ] 	= applayRefused
handles[ BRO_APPLAY_AGREE ] 	= applayAgree
handles[ BRO_NO_APPLAY ] 		= noApplay
handles[ BRO_APPLAY_CHANGE ] 	= changeApplay

handles[ BRO_CHECK_BET ] 		= checkBet
handles[ BRO_ADD_THINK_TIME ] 	= addThinkTime
handles[ BRO_ANIMATION ] 		= sendAnimation
handles[ BRO_RESET_TIME ] 		= resetGameTime
handles[ BRO_DIS_CARD ] 		= displayTwoCard

handles[ BRO_MTT_REVIVE ] 		= promptRevive
handles[ BRO_MTT_OVER ] 		= mttGameOver
handles[ BRO_MTT_DESK ] 		= mttDeskPrompt
handles[ BRO_MTT_REST ] 		= mttRest
handles[ BRO_CLOSE_ROOM ] 		= closeGameRoom

handles[ BRO_LOOK_LOOK ] 		= lookPoolPoker

handles[ BRO_PLAYER_RANK ] 		= playerRank
handles[ BRO_REMOVE_MTT_REST ] 	= removeRest

handles[ BRO_UPDATE_BUY_TIMES ] = updateBuyTimes

--sng
handles[ BRO_UP_BLIND ] 		= upBlind
handles[ BRO_TRUSTEESHIP ] 		= trusteeship

--insure
handles[ BRO_INSURE_PURCHASE ]	= displayInsurePanel
handles[ BRO_INTO_INSURE_MODE]  = displayIntoInsureAnim
handles[ BRO_INSURE_BUY_END ]   = insureNotification
handles[ BRO_INSURE_UICHANGE ]  = displaySycInsureUIPanel
handles[ BRO_INSURE_FLOP_CARD ] = handlerInsureFlopCards
handles[ BRO_INSURE_LIGHT_CARD ] = handlerPresentCards
--ante
handles[ BRO_ANTE_BET ] 		=  handleAnte
handles[ BRO_STRADDLE_MODE ]    = handleStraddle
function BroCtrol.sendBro(data)
	if GData.isGameOver() then return end
	local pnum = tonumber(data['protocolNum'])
	print('出栈广播  '..pnum..'    '..os.time())
	handles[ pnum ](data)
end


--socket 连接成功注册广播
local noPushHandles = {}
--继续游戏2013、发动画2024、发表情2008、升盲2021、重置房间剩余时间2025
noPushHandles[ BRO_GOON_GAME ] 		= true
noPushHandles[ BRO_ANIMATION ] 		= true
noPushHandles[ BRO_SEND_EMOJI ] 	= true
noPushHandles[ BRO_UP_BLIND ] 		= true
noPushHandles[ BRO_RESET_TIME ] 	= true

--玩家托管状态变化2022、控制房间带入变更2019、已无补充记分牌2018、玩家亮手牌2026
noPushHandles[ BRO_RESET_TIME ] 	= true
noPushHandles[ BRO_APPLAY_CHANGE ] 	= true
noPushHandles[ BRO_NO_APPLAY ] 		= true
noPushHandles[ BRO_DIS_CARD ] 		= true

--发发看2032、2033玩家排名、补充记分牌2015
noPushHandles[ BRO_LOOK_LOOK ] 		= true
noPushHandles[ BRO_PLAYER_RANK ] 	= true
-- noPushHandles[ BRO_ADD_SCORES ] 	= true

--等待 2000、2034移除中场会决赛休息倒计时
noPushHandles[ BRO_PLAYER_SEAT ] 	= true
noPushHandles[ BRO_REMOVE_MTT_REST ]= true
noPushHandles[ BRO_STRADDLE_MODE ] = true

local function handleBro(opcode, data)
	if opcode == BRO_HOME_CLOSE then
		Single:gameModel():setNoPushEnd(true)
	elseif opcode == BRO_MTT_REST then
		--mtt中场或决赛休息计时
		data['client_os_time'] = os.time()
	elseif opcode == BRO_MTT_DESK then
		if GJust.isMttChangeDesk(data) then
			Network.setIgnoreBro(true)
			GData.setGamePId(data['pokerId'])
		end
	end

	if handles[ opcode ] then
		--继续游戏，不需要进栈
		if noPushHandles[ opcode ] then
			--2000玩家坐下
			if opcode == BRO_PLAYER_SEAT then
				--位置已经有人了
				if UserCtrol.getSeatUserByPos(data['seatNum']) then
					GAnimation.pushData(data)
				else
					handles[ opcode ](data)
				end
			else
				print('没有进栈的广播  '..data['protocolNum'])
				handles[ opcode ](data)
			end
		else
			GAnimation.pushData(data)
		end
	end
end

--1000之后的广播数组(场景切换开始-场景切换结束)这段时间广播
local _befarr = nil
--场景切换中
function BroCtrol.enterScening()
	_befarr = {}
end
--场景切换完成
function BroCtrol.enterScened()
	if _befarr then
		for i=1,#_befarr do			
			local tdata = _befarr[ i ]
			handleBro(tdata['protocolNum'], tdata)
		end
	end
	_befarr = nil
end


function BroCtrol.registerBro(temdata)
    _gameModel = Single:gameModel()
	
	if _bros then
		assert(nil, 'registerBro 再次注册了')
	end

	local function broFunc(opcode, data)
		if _befarr then
			table.insert(_befarr, data)
		else
			handleBro(opcode, data)
		end
	end
	local handleId = Network.bindBroadcast(broFunc)
	_bros = {}
	table.insert(_bros, handleId)
end


function BroCtrol.unregisterBro()
	if not _bros then return end

	for i=1,#_bros do
		Network.unbindBroadcast(_bros[ i ])
	end
	_bros = nil
	_gameModel = nil
end

return BroCtrol