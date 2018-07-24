local SocketCtrol = {}
local _gameModel = nil
local _broCtrol = require ('game.BroCtrol')

--1000处理进入游戏数据
-- local function handleNoGaming(hdata, susers)
-- 	hdata['poolCard'] = {}
-- 	hdata['poolBet'] = nil
-- 	hdata['nowPoolBet'] = nil

-- 	for i=1,#susers do
-- 		susers[i]['isDealer'] = nil
-- 		susers[i]['betNum'] = nil
-- 	end
-- end

local function getDiffUsers(hdata)
	if hdata['users'] == nil then
		hdata['users'] = {}
	end

	local sUsers = {}
	local lUsers = {}
	local allusers = hdata['users']
		
	-- -1不在座位上，看客
	for i=1,#allusers do
		local tuser = allusers[ i ]

		if tuser['seatNum'] ~= -1 then
			table.insert(sUsers, tuser)
		else
			table.insert(lUsers, tuser)
		end

		--me
		if Single:playerModel():getId() == tuser['userId'] then
			--两张手牌
			if tuser['cards'] then
				Single:gameModel():setCardOne(tuser['cards'][1])
				Single:gameModel():setCardTwo(tuser['cards'][2])
			else
				Single:gameModel():setCardOne(nil)
				Single:gameModel():setCardTwo(nil)
			end
		end
	end
	return sUsers, lUsers
end

local function handleMtt(mttData)
	GData.setUpblindSurplusTime(mttData['raiseBlindSurplusTime'])
	GData.setUPBlindTime(mttData['raiseBlindTime'])
	GData.setMttEntryFee(mttData['entryFee'])

	local mtt = mttData['mtt']
	GData.setOverBlindLevel(mtt['overLevel'])
	GData.setNowBlindLevel(mtt['blindLevel'])
	GData.setMaxAgainTimes(mtt['repurchaseMaxNum'])
	GData.setMaxAddTimes(mtt['addMaxNum'])
	GData.setMttInitScore(mtt['initScore'])

	GData.setMttBuyMul(mtt['addMul'])
	GData.setBlindNote(mtt['blindTag'])
	GData.setStartBlind(mtt['startBlind'])

	--玩家没有参与游戏-1
	GData.setAddTimes(mtt['addNum'])
	GData.setAgainTimes(mtt['repurchaseNum'])

	Single:gameModel():setGameRest(mtt['restType'], mtt['restTime'])
end

local function handleSng(sngData)
	GData.setUpblindSurplusTime(sngData['raiseBlindSurplusTime'])
	GData.setUPBlindTime(sngData['raiseBlindTime'])
	GData.setSngEntryFee(sngData['entryFee'])
end


function SocketCtrol.initGameBro(data, broNum)
	local seatUsers,lookUsers = getDiffUsers(data)
	GameCtrol.broUsersBaseMsg(data, seatUsers, broNum)

	UserCtrol.intoGame(seatUsers, lookUsers)
end
function SocketCtrol.initGameData(data)
	Single:gameModel():clearData()
	_gameModel = Single:gameModel()
		
	if not data['limitPlayers'] then
		Single:appLogs('游戏类型：'..data['gameMode'], 'SocketCtrol.initGameData')
	end

	-- local seatUsers,lookUsers = getDiffUsers(data)
	-- data['cuoTime'], data['insuraceTime'] = 25,25
	_gameModel:setManager(data['isManager'])
	_gameModel:setStarting(data['isStart'])
	_gameModel:setThinkTime(data['thinkTime'])
	_gameModel:setInsuranceTime(data['insureTime'])
	_gameModel:setCuoTime(data['cuoTime'])
	_gameModel:setGameName(data['roomName'])
	_gameModel:setShareCode(data['joinCode'])			--
	_gameModel:setGameNum(data['limitPlayers'])
	_gameModel:setGameType(data['gameMode'])
	-- _gameModel:setSmallBlind(data['bigBlind'] / 2)
	_gameModel:setSmallBlind(data['currentGameBigblindBet'] / 2)
	_gameModel:setOpenApplay(data['controlBuyin'])		--
	_gameModel:setBeforeTalkBet(data['beforeTalkBet'])

	--straddle、gps、ip
	_gameModel:setStraddle(data['straddleTag'])
	_gameModel:setStraddleSeatNum(data['straddleSeatNum'])
	_gameModel:setGPS(data['isGPS'])
	_gameModel:setIP(data['isIP'])

	--设置大盲, 小盲，庄家位置
	_gameModel:setDealerSeatNo(data['dealerSeatNum'])
	_gameModel:setBigBlindSeatNo(data['bigBlindSeatNum'])
	_gameModel:setSmallBlindSeatNo(data['smallBlindSeatNum'])
	
	--保险
	_gameModel:setIsInsurance(data['isInsure'])
	--游戏中、不在游戏中
	local poolBet = data['poolBet']
	if poolBet and poolBet > 0 then
		_gameModel:setPokerStartTag(true)
		_gameModel:setPoolCard(data['poolCard'])
		_gameModel:setPoolNowBet(data['poolBet'])
		_gameModel:setRoundPoolBet(data['roundPoolBet'])
		_gameModel:setRoundNum(data['gameRound'])

	else
		_gameModel:setPokerStartTag(false)
		-- handleNoGaming(data, seatUsers)
	end
	--是否暂停
	_gameModel:setPause(data['isPause'])
	_gameModel:setPauseTime(data['pauseTime'])
	
	--融云聊天
	_gameModel:setGamePRYId(data['roomRongyunId'])

	--GSelfData.setDelayDiamond(data['addThinkTimePrice'])
	local timePrice = data['addTimePrice']
	if not timePrice then timePrice = {} end
	GSelfData.setDelayDiamond(timePrice['thinking'])
	GSelfData.setInsureDelayDiamond(timePrice['insuranceThinking'])
	GSelfData.setCuopaiDelayDiamond(timePrice['cuo'])
	--延迟需要花费的砖石数、砖石余额
	Single:playerModel():setPDiaNum(data['diamonds'])

	--房主
	-- if data['isManager'] then
		--有申请补充记分牌
		GData.setHaveUnhandledApply(data['haveUnhandledApply'])
	-- end

	local bigType = Single:gameModel():getGameBigType()
	if bigType == GAME_BIG_TYPE_SNG then
		handleSng(data)
	elseif bigType == GAME_BIG_TYPE_MTT then
		handleMtt(data)
	elseif bigType == GAME_BIG_TYPE_STANDARD then
		_gameModel:setGameTime(data['surplusTime'])
	end
	
	if data['ante'] == 0 then
		data['ante'] = nil
	end
	GData.setNowAnte(data['ante'])
	GData.setInsureBuying(false)
	--初始化牌局提示信息：在设置model后面
	GText.clearPokerMsg()
	GText.setPokerMsg(StatusCode.PROMPT_NAME, data['roomName'])
	GText.setPokerMsg(StatusCode.PROMPT_BLIND, data['bigBlind'])
	GText.setPokerMsg(StatusCode.PROMPT_CODE, data['joinCode'])
	GText.setPokerMsg(StatusCode.PROMPT_ANTE, data['ante'])
	GText.setPokerMsg(StatusCode.PROMPT_UPTIME, data['raiseBlindTime'])
	GText.setPokerMsg(StatusCode.PROMPT_AUTHOR, data['controlBuyin'])
	GText.setPokerMsg(StatusCode.PROMPT_INSURE, data['isInsure'])

	GText.setPokerMsg(StatusCode.PROMPT_GPS_IP, '')
	GText.setPokerMsg(StatusCode.PROMPT_STRADDLE, '')

	--融云聊天
	DZChat.initGamingRYId()
end


--连接ws
--pokerid:牌局id、进入游戏1000
--暂时没用：isInRoom、
function SocketCtrol.conWSSocket(pokerid, funcBack, isAutoSeat)
	_gameModel = Single:gameModel()

	GData.setGamePId(pokerid)
	DZPlaySound.stopAllSound()
	Network.setIgnoreBro(false)

	local function response(data)
		-- print_f(data)
		_broCtrol.unregisterBro()
		GameCtrol.clearData()
		GAnimation.clearData()
		_broCtrol.registerBro()
		funcBack(data)
	end

	local userid = Single:playerModel():getId()
	local tab = {}
	tab['userId'] = userid
	tab['pokerId'] = pokerid
	tab['token'] = XMLHttp.getGameToken()
	tab['isAutoSeat'] = false

	if isAutoSeat then
		tab['isAutoSeat'] = isAutoSeat
	end

	tab['smallVersion'] = DZ_VERSION
	tab['bigVersion'] = UPDATE_VERSION

	GData.setGameOverStatus(false)
	SocketCtrol.socketFilter(WS_INTO_GAME, tab, response, true)
end

--选择位置1001
--pos位置
function SocketCtrol.selectPosition(pos, funcBack)
	-- local glayer = nil
	-- local function buyBetBack()
	-- 	if glayer then
	-- 		glayer:removeFromParent()
	-- 	end
	-- end

	--牌局开启GPS限制了，但玩家没有开启GPS
	-- local isGPS = Single:gameModel():isLimitGPS()
	-- if isGPS then
	-- 	if not Single:paltform():isOpenGPS() then
	-- 		DZWindow.showGPSPrompt()
	-- 		return
	-- 	end
	-- end

	local function response(data)
		funcBack()
		if tonumber(data['applyStatus']) == 3 then
			-- glayer = GWindow.showBuy(buyBetBack, GWindow.STAND)
			GWindow.showBuy(function()end, GWindow.STAND)
		end
	end

	local function longitude_latitude_back(lJ, lW)
		local tab = {}
		local gmode = Single:gameModel():getGameType()
		if gmode == GAME_UNION_STABDARD then
			if GData.getUclubId() then
				tab['clubId'] = GData.getUclubId()
			end
		end
		tab['seatNum'] = pos
		tab['longitude'] = lJ
		tab['latitude'] = lW
		SocketCtrol.socketFilter(WS_PLAYER_SEAT, tab, response, true)
	end
	local isGPS = Single:gameModel():isLimitGPS()
	Single:paltform():getLatitudeAndLongitude(longitude_latitude_back, isGPS)
	-- local longitude,latitude = Single:paltform():getLatitudeAndLongitude(longitude_latitude_back)

	-- local tab = {}
	-- tab['seatNum'] = pos
	-- tab['longitude'] = longitude
	-- tab['latitude'] = latitude
	-- SocketCtrol.socketFilter(WS_PLAYER_SEAT, tab, response, true)
end

--开始游戏1002
--
function SocketCtrol.startGame(funcBack)
	local function response(data)
		_gameModel:setStarting(true)
		funcBack()
	end
	SocketCtrol.socketFilter(WS_START_GAME, {}, response, true)
end

--押注选择1003
--
function SocketCtrol.selectBet(ctype, betNum, funcBack)
	local ttype = ctype
	local smode = GSelfData.getSelfModel()

	--1/2、2/3、1
	local pools,_ = GameHelp.selectPoolsValue()
	if ctype == StatusCode.GAME_ADD_12 then
		ttype = StatusCode.GAME_ADD
		betNum = pools[1]
	elseif ctype == StatusCode.GAME_ADD_23 then
		ttype = StatusCode.GAME_ADD
		betNum = pools[2]
	elseif ctype == StatusCode.GAME_ADD_11 then
		ttype = StatusCode.GAME_ADD
		betNum = pools[3]
	end

	-- if betNum >= smode:getSurplusNum() then
	-- 	ttype = StatusCode.GAME_ALLIN
	-- end

	local function response(data)
		funcBack()
	end

	local tab = {}
	tab['selectType'] = ttype
	tab['betNum'] = betNum
	SocketCtrol.socketFilter(WS_BET_SELECT, tab, response)
end

--站起围观1004
--
function SocketCtrol.leaveGame(funcBack, errBack)
	local function response(data)
		funcBack()
	end

	SocketCtrol.socketFilter(WS_STAND_LOOK, {}, response, false, errBack)
end

--退出游戏1005
--
function SocketCtrol.exitGame(funcBack)
	local function response(data)
		funcBack()
		Single:playerModel():setPBetNum(data['playerSocres'])
	end

	SocketCtrol.socketFilter(WS_EXIT_GAME, {}, response, true)
end

--暂停游戏1006
--
function SocketCtrol.stopGame(funcBack)
	local function response(data)
		funcBack()
	end
	SocketCtrol.socketFilter(WS_STOP_GAME, {}, response)
end

--发表情1007
--
function SocketCtrol.sendEmoji(emoji, funcBack)
	local function response(data)
		funcBack()
	end
	local tab = {}
	tab['emoji'] = tostring(emoji)

	SocketCtrol.socketFilter(WS_SEND_EMOJI, tab, response)
end

--核查游戏剩余时间1008
--
function SocketCtrol.checkSurplusTime()
	local function response(data)
		_gameModel:setGameTime(data['surplusTime'])
		-- funcBack()
	end

	local tab = {}
	SocketCtrol.socketFilter(WS_GET_SURPLUS_TIME, tab, response)
end

--结束后是不是亮牌1009
--
function SocketCtrol.setShowPoker(sone, stwo, funcBack)
	local function response(data)
		funcBack()
	end

	local tone = {}
	tone['id'] = _gameModel:getCardOne()
	tone['status'] = sone
	local ttwo = {}
	ttwo['id'] = _gameModel:getCardTwo()
	ttwo['status'] = stwo

	local tcards = {}
	table.insert(tcards, tone)
	table.insert(tcards, ttwo)
	local tab = {}
	tab['cards'] = tcards

	SocketCtrol.socketFilter(WS_SHOW_CARD, tab, response)
end

--实时战况1010
--
function SocketCtrol.getRealTimeData(funcBack)
	local function response(data)
		funcBack(data)
	end

	local tab = {}
	SocketCtrol.socketFilter(WS_REAL_TIME, tab, response)
end

--补充记分牌1011
--
function SocketCtrol.supplementScores(buyin, funcBack, errBack)
	local function response(data)
		funcBack()
	end

	local tab = {}
	tab['buyin'] = buyin
	SocketCtrol.socketFilter(WS_SUPPLEMENT_SCORE, tab, response, true, errBack)
end

--房主继续游戏1012
--
function SocketCtrol.goonGame(funcBack)
	local function response(data)
		funcBack()
	end

	local tab = {}
	SocketCtrol.socketFilter(WS_GOON_GAME, tab, response)
end

--查看记分牌列表1013
--
function SocketCtrol.applayList(funcBack)
	local function response(data)
		funcBack(data)
	end

	local tab = {}
	SocketCtrol.socketFilter(WS_LOOK_APPLAY_LIST, tab, response)
	-- funcBack()
end

--房主同意或拒绝1014
--
function SocketCtrol.homeSelectResult(playerId, agree, funcBack)
	local function response(data)
		funcBack()
	end

	local tab = {}
	tab['playerId'] = playerId
	tab['agree'] = agree
	SocketCtrol.socketFilter(WS_AGREE_REFUSE, tab, response)
end

--授权带入开启或关闭1015
--
function SocketCtrol.changeAuthorize(controlBuyin, funcBack)
	local function response(data)
		funcBack()
	end

	local tab = {}
	tab['controlBuyin'] = controlBuyin
	SocketCtrol.socketFilter(WS_APPLAY_CHAGE, tab, response)
end


--sng
--sng取消托管1016
--
function SocketCtrol.sngCancelTrusteeship(funcBack)
	local function response(data)
		-- funcBack()
		--取消托管成功
		GameCtrol.meCancelTrusteeship()
	end

	local tab = {}
	SocketCtrol.socketFilter(WS_CANCEL_TRUSTEESHIP, tab, response)
end


--回顾历史1017
--
function SocketCtrol.lookHistoryData(funcBack)
	local function response(data)
		funcBack(data)
	end
	local tab = {}
	SocketCtrol.socketFilter(WS_LOOK_HISTORY, tab, response)
end

function SocketCtrol.lookHistoryDataByPage(pageNum,funcBack)
	local function response(data)
		funcBack(data)
	end
	local tab = {}
	tab['curPage'] = pageNum
	SocketCtrol.socketFilter(WS_LOOK_HISTORY, tab, response)
end

--收藏牌铺1018
--
function SocketCtrol.collectionPoker(gameId, funcBack)
	local function response(data)
		funcBack(data)
	end
	local tab = {}
	tab['gameId'] = gameId
	SocketCtrol.socketFilter(WS_COLLECTION_POKER, tab, response)
end

--得到玩家基本信息1019
--
function SocketCtrol.getPlayerMsg(playerId, playerRYId, funcBack)
	local function response(data)
		data['clientRYid'] = playerRYId
		data['playerId'] = playerId
		funcBack(data)
	end
	local tab = {}
	tab['playerId'] = playerId
	SocketCtrol.socketFilter(WS_PLAYER_MSG, tab, response)
end

--请求延迟1020
function SocketCtrol.requestDelay(funcBack)
	local function response(data)
		Single:playerModel():setPDiaNum(data['diamonds'])
		GSelfData.setDelayDiamond(data['addThinkTimePrice'])
		print_f(data)
		funcBack(data)
	end
	local tab = {}
	SocketCtrol.socketFilter(WS_REQUEST_DELAY, tab, response)
end

--请求延迟1020   1020的补充方法，主要用于保险，搓牌，
--后期可以跟requestDelay融合
--addType 1:喊注思考时间 2:保险思考时间 3：搓牌时间
function SocketCtrol.requestDelayOther(addType,funcBack)
	dump(addType, "1020回复")
	local function response(data)
		print_f(data)

		local result = data['result']
		if result ~= 1 then 
			print("1020 错误:"..tostring(result))
			do return end
		end

		local purchaseType = data['addType']
		local diamond = data['diamonds']
		local addThinkTimePrice = data['addThinkTimePrice']
		Single:playerModel():setPDiaNum(diamond)
		if purchaseType == 1 then 
			GSelfData.setDelayDiamond(addThinkTimePrice)
		elseif purchaseType == 2 then 
			GSelfData.setInsureDelayDiamond(addThinkTimePrice)
		elseif purchaseType == 3 then 
			GSelfData.setCuopaiDelayDiamond(addThinkTimePrice)
		end
		if funcBack then funcBack(data) end
	end
	local tab = {}
	tab['addType'] = addType
	SocketCtrol.socketFilter(WS_REQUEST_DELAY, tab, response)
end

--发送动画1021
function SocketCtrol.sendAnimation(toSeatNum, aniTag, funcBack)
	local function response(data)
		funcBack(data)
		Single:playerModel():updatePBetNum(-20)
	end
	local tab = {}
	tab['toSeatNum'] = toSeatNum
	tab['emoji'] = aniTag
	SocketCtrol.socketFilter(WS_SEND_ANIMATION, tab, response)
end


--mtt奖励规则1022
function SocketCtrol.mttRewardRule(funcBack)
	local function response(data)
		funcBack(data)
	end
	local tab = {}
	tab['mttCode'] = GData.getMttCode()
	tab['playerId'] = Single:playerModel():getId()
	SocketCtrol.socketFilter(WS_MTT_REWARD, tab, response)
 --    local data = {}
 --    data['allPool'] = 1232
 --    data['allPerson'] = 232
 --    data['surpPerson'] = 32
 --    data['rewardNum'] = 30
 --    data['addLevel'] = 8
 --    data['rewards'] = {12332, 2312, 323, 12, 9, 8, 7, 5, 4}
 --    funcBack(data)
end


--mtt重购增购弃购积分1024
local _isBuyIng = false
function SocketCtrol.mttBuyScore(buyTag, funcBack)
	if _isBuyIng then return end
	DZSchedule.schedulerOnce(1.5, function()
		_isBuyIng = false
	end)

	local function response(data)
		--已经重构、已经增购
		if data['repurchaseNum'] then
			GData.setAgainTimes(data['repurchaseNum'])
		end
		if data['addNum'] then
			GData.setAddTimes(data['addNum'])
		end
		funcBack(data)

		ViewCtrol.showMsg('已购买,等待下一局为您补充所购买记分牌', 2.5)
		
		BroAnimation.removeAddOn()
	end
	local function errBack()
		BroAnimation.removeAddOn()
	end

	local tab = {}
	tab['buyTag'] = buyTag
	SocketCtrol.socketFilter(WS_MTT_BUY_SCORE, tab, response, nil, errBack)
	-- funcBack()
	_isBuyIng = true
end

--mtt请求mtt牌局id1025
function SocketCtrol.mttMttCode(mttCode, funcBack)
	local function response(data)
		funcBack(data)
	end

	local function errBack()
		--数据没有清理可能出错
		DiffType.exitGameScene()
	end
	local tab = {}
	tab['mttCode'] = mttCode
	tab['playerId'] = Single:playerModel():getId()


	Single:gameModel():setNoPushEnd(false)
	GData.setGameOverStatus(false)
	SocketCtrol.socketFilter(WS_MTT_INTO_GAME, tab, response, true, errBack)
	-- local data = {}
	-- data['countDown'] = 15
	-- data['pokerId'] = '15'
	-- funcBack(data)
end

--发发看请求1026
local _islinkIng = false
function SocketCtrol.lookPoolPoker(funcBack)
	if _islinkIng then return end
	_islinkIng = true

	 DZSchedule.schedulerOnce(0.8, function()
	 	_islinkIng = false
	 end)

	local cards = Single:gameModel():getPoolCard()
	if #cards >= 5 then
		print('发发看 没有牌了了')
		return
	end
	local function response(data)
		_islinkIng = false
		funcBack(data)
	end
	local tab = {}
	SocketCtrol.socketFilter(WS_LOOK_LOOK, tab, response)
end

--mtt赛事数据1027
function SocketCtrol.mttMatchData(funcBack)
	local function response(data)
		funcBack(data)
	end
	local tab = {}
	tab['playerId'] = Single:playerModel():getId()
	tab['pokerId'] = GData.getGamePId()
	tab['mttCode'] = GData.getMttCode()
	SocketCtrol.socketFilter(WS_MTT_MATCH_DATA, tab, response)
	-- funcBack()
end

--mtt排名数据1028
function SocketCtrol.mttRankData(funcBack, rankTag, pageNum)
	local function response(data)
		funcBack(data)
	end
	local tab = {}
	tab['rank_tag'] = rankTag
	-- tab['pageNum'] = pageNum
	tab['pageNum'] = nil
	tab['mttCode'] = GData.getMttCode()
	SocketCtrol.socketFilter(WS_MTT_RANK, tab, response)
	-- funcBack()
end


--购买保险1103
function SocketCtrol.insuranPurchase(selectType, outs, amount, callback)
	local function response(data)
		callback(data)
	end 
	local tab = {}
	tab['selectType'] = selectType
	tab['outs'] = outs
	tab['amount'] = amount
	SocketCtrol.socketFilter(WS_INSURE_TO_BUY, tab, response)
end

--购买保险的界面变化1101
--服务器将obj直接返回
function SocketCtrol.sendInsuranUIChange(obj, callback)
	local function response(data)
		callback(data)
	end
	SocketCtrol.socketFilter(WS_INSURE_UI_CHANGE, obj, response)
end 


--变化StraddleMode 1050
function SocketCtrol.sendStraddleMode(mode,pid,tid,callback)
	 local function response(data)
	 end
	 local obj = {}
	 obj['pid'] = pid
	 obj['mode'] = mode
	 obj['tid'] = tid
	 SocketCtrol.socketFilter(WS_STRADDLE_MODE_CHANGE, obj, response)
end
--下一局straddle操作 1051
function SocketCtrol.sendIsStraddle(pid, callback)
	local function response(data)
		if data['code'] ~= 0 then print("Error:1051 出问题了") end
	end
	local obj = {}
	obj['pid'] = pid
	SocketCtrol.socketFilter(WS_STRADDLE_CONFIRM, obj, response)
end
--出错不提示的
-- 104： 大版本不同
-- 105：小版本不同
local _noPromptCode = {}
_noPromptCode[ 322 ] = true 	--此玩家没有手牌
_noPromptCode[ 501 ] = true 	--没有可供查看的牌
local function updatePrompt(isBig)
	--7小版本、6大版本
	local version = 7
	if isBig then
		version = 6
	end

	local runScene = cc.Director:getInstance():getRunningScene()
	local dlg = require("main/HelpDlg"):create(version)
	runScene:addChild(dlg, StringUtils.getMaxZOrder(runScene))
end

--弹窗提示
local _proWindows = {}
_proWindows[ 701 ] = true
local function windowPrompt(msg)
	if not msg then return end

    ViewCtrol.showTip({content = msg, listener = function()
    end, fontSize = 33})
end

function SocketCtrol.socketFilter(pnum, tabstr, funcBack, isbg, errBack)
	_isBuyIng = false

	if GData.isGameOver() then 
		--游戏已经结束
		if pnum == WS_EXIT_GAME then
			DiffType.exitGameScene()
		end
		return 
	end

	local function goMain()
		DZSchedule.schedulerOnce(1, function()
		    DiffType.exitGameScene()
		end)
	end

	local function response(data)
		-- print_f(data)
		local rcode = data['result']
		if rcode ~= StatusCode.SUCCESS then
			local errMsg = data['errMsg']

			if _noPromptCode[ rcode ] then
				if errBack ~= nil then
					errBack(data)
					return
				end
				return
			end

			--弹窗提示
			if _proWindows[ rcode ] then
				windowPrompt(errMsg)
				return
			end

			--mtt比赛玩家,玩家不在此房间，重新请求 1025
			if rcode == 103 then
				Single:closeWSUpdateData()
				return
			end

			--版本更新提示
			if rcode == 104 then
				updatePrompt(true)
				return
			end
			if rcode == 105 then
				updatePrompt(false)
				return
			end

			--飘窗提示
			if errMsg ~= '此玩家没有手牌' then
				ViewCtrol.showMsg(errMsg)
			end
			
			if errBack ~= nil then
				errBack(data)
				return
			end

			if rcode == 301 or rcode == 202 or rcode == 204 then
				print('跳转到 main')
				goMain()
			end

			return
		end

		if Single:gameModel():isNoPushEnd() then return end
		funcBack(data)
	end

	Network.request(pnum, tabstr, response, isbg)
end

return SocketCtrol