local GameCtrol = {}
local _users = {}			--游戏中的玩家

local function getUserById(uid)
	return UserCtrol.getSeatUserById(uid)
end

local function getUserByPos(pos)
	return UserCtrol.getSeatUserByPos(pos)
end

local function removeUserByPos(pos)
	for i=1,#_users do
		if _users[i]:getSeatNum() == pos then
			table.remove(_users, i)
			return 
		end
	end
end

--进入游戏、广播有玩家坐下
function GameCtrol.addUser(ouser)
	local otherModel = require ('model.OtherModel')
	local tobj = otherModel:create()

	tobj:setUserId(ouser['userId'])
	tobj:setUserRYId(ouser['rongyunId'])
	tobj:setUserName(ouser['userName'])
	tobj:setHeadUrl(ouser['headUrl'])
	tobj:setSeatNum(ouser['seatNum'])
	tobj:setStatus(ouser['status'])
	tobj:setTeamBool(ouser['hasTeam'])

	tobj:setSurplusNum(ouser['surplusNum'])
	local tBetNum = ouser['betNum']
	if not tBetNum then
		tBetNum = 0
	end
	tobj:setAllSurplusNum(ouser['surplusNum'] + tBetNum)

	--游戏中
	tobj:setDealerTag(ouser['isDealer'])
	tobj:setBetNum(ouser['betNum'])

	--general:申请补充记分牌倒计
	tobj:setApplayTime(ouser['surplusRefuseTime'])
	
	--sng
	tobj:setTrusteeship(ouser['isAuto'])
	tobj:setSngLastRank(ouser['sngGameRank'])

	table.insert(_users, tobj)
	return tobj
end

--玩家坐下 2000
function GameCtrol.handlePlayerSeat(data, broNum)
	removeUserByPos(data['seatNum'])

	local user = GameCtrol.addUser(data)
	user:setStatus(StatusCode.GAME_WAIT_ING)
	
	UserCtrol.userLinkPlayer(user)

	BroAnimation.disPlayerSeat(user)
	BroAnimation.updatePrompt()

	--显示托管
	local function disAuto()
		if not data['isAuto'] then 
			BroAnimation.playerTeamMark(user)
			return 
		end
		user:setTrusteeship(data['isAuto'])
		BroAnimation.playerTrusteeship(user)
	end
	
	--自己坐下动画
	local function aniEndBack()
    	GAnimation.endRun2000()

		local mePlayer = GSelfData.getMePlayer()
		--坐下又站起
		if mePlayer then
			mePlayer:disSelfLayer(user)
			disAuto()
		end
	end
	if user:isSelf() then
		GAnimation.startRun2000()

		local runPos = GSelfData.getMeRunPos()
		--0.5
		BroAnimation.aniMeSeat(runPos, aniEndBack, false)
	else
		disAuto()
	end	

	UserCtrol.seatDo(data['userId'])
	local userStr = UserCtrol.getUserDetailed()
	GameCtrol.handlerUpdateStraddle(data)
end

--处理广播 2001
function GameCtrol.handleSendCards(data, broNum)
	if #_users < 2 then
		Single:checkGameData('GameCtrol.handleSendCards  ')
		return
	end

	DZPlaySound.playDeal()
	SelfLayer:resetAutoValue()

	Single:gameModel():setPokerStartTag(true)
	--移除游戏开始后的提示
	BroAnimation.removeStartGameLayer()
	-- GSelfData.setDelayDiamond(data['addThinkTimePrice'])
	local timePrice = data['addTimePrice']
	if timePrice then 
		GSelfData.setDelayDiamond(timePrice['thinking'])
		GSelfData.setInsureDelayDiamond(timePrice['insuranceThinking'])
		GSelfData.setCuopaiDelayDiamond(timePrice['cuo'])
	end

	local intoGameNums = data['inGameSeatNums']
	local bbSN = data['bigBlindSeatNum']
	local sbSN = data['smallBlindSeatNum']
	local dSN = data['dealerSeatNum']
	local gunSN = -1
	
	local pokerUsers = {}
	local function gamingUser(pos, cuser)--
		for j=1,#intoGameNums do
			if intoGameNums[j] == pos then
				cuser:setStatus(StatusCode.GAME_GAME_ING)
				table.insert(pokerUsers, cuser)
			end
		end
	end
	--straddle
	local straddleTag = Single:gameModel():getStraddle()
	local bigUser = nil
	local smallUser = nil
	local gunUser = nil
	local logstr = ''
	-- local bFollowBet, curSeatUser = 0,nil
	for i=1,#_users do
		local tuser = _users[i]
		local tpos = tuser:getSeatNum()
		--游戏中标示
		gamingUser(tpos, tuser)
		--D
		if data['dealerSeatNum'] == tpos then
			tuser:setDealerTag(true)
		end

		--大小盲、其他玩家
		if bbSN == tpos then
			tuser:setSurplusNum(data['bigBlindsurplusNum'])
			tuser:setBetNum(data['bigBlindBetNum'])
			tuser:setBigBlind(true)

			bigUser = tuser
			logstr = logstr..' big blind '
		elseif sbSN == tpos then
			tuser:setSurplusNum(data['smallBlindsurplusNum'])
			tuser:setBetNum(data['smallBlindBetNum'])
			tuser:setSmallBlind(true)

			smallUser = tuser
			logstr = logstr..' small blind '
		end
		--straddle 更新枪口位置
		if straddleTag ~= NO_STRADDLE then 
			if data['underTheGunSeatNum'] == tpos then 
				tuser:setSurplusNum(data['underTheGunSurplusNum'])
				tuser:setBetNum(data['underTheGunBetNum'])
				tuser:setStatus(StatusCode.GAME_STRADDLE1)
				gunUser = tuser
			end 
		end
	end
	if bigUser == nil or smallUser == nil then
		local logs = '找不到大忙或小忙位置  '..logstr
		local explain = 'GameCtrol.handleSendCards '..UserCtrol.getUserDetailed()
		Single:appLogs(logs, explain)
	end
	
	Single:playerManager():updateBlindBet(bbSN, sbSN, dSN)
	local gameModel = Single:gameModel()
	gameModel:setBigBlindSeatNo(bbSN,sbSN, dSN)
	gameModel:setSmallBlindSeatNo(sbSN)
	gameModel:setDealerSeatNo(dSN)

	--更新最小加注，以及跟注
	if data['maxBet'] then 
		GData.setMaxBetNum(data['maxBet'])
	else 
		local maxBet = math.max(data['underTheGunBetNum'] or 0, gameModel:getBigBlind())
		GData.setMaxBetNum(maxBet)
	end
	if data['miniRaise'] then 
		GData.setAvailableRaiseVal(data['miniRaise'])
	end

	GAnimation.startRun2001()
	--获取发牌顺序
	local seatOrder = GMath.getDealOrder(dSN, intoGameNums)
	--大小盲 0.62
	local tusers = {bigUser, smallUser}
	--抢手位Straddle存在，需要直接下注
	if gunUser then
		tusers[#tusers + 1] = gunUser
	end
	
	--这里之后需要等待发牌完毕才显示
	local function dealFinshFunc()
		--然后更新用户状态开始牌局
		BroAnimation.updatePrompt() --提取
		BroAnimation.updateDisPlayer(tusers)--更新用户状态
		BroAnimation.blindPromptText()
		GameCtrol.handlerUpdateStraddle(data)
		if not data['isRoundEnd'] then
			BroAnimation.disSaidPlayer(_users)
		end
		GAnimation.endRun2001()
	end

	local function aniEndBack()
		--其次发牌
		BroAnimation.dealToUsers(seatOrder, dealFinshFunc)
	end
	--优先发筹码
	BroAnimation.disDealerFlag(pokerUsers)
	BroAnimation.hideAllSaid(_users)
	BroAnimation.updateNowPoolBet()
	BroAnimation.surplusBetToNow(tusers, aniEndBack)
end

--处理广播 2002
function GameCtrol.handlePlayerSelect(data, broNum)
	DZPlaySound.stopClock()
	if data['miniRaise'] then 
		GData.setAvailableRaiseVal(data['miniRaise'])
	end
	if data['maxBet'] then
		GData.setMaxBetNum(data['maxBet'])
	else 
		GData.setMaxBetNum(math.max(GData.getMaxBetNum(), data['betNum']))
	end     

	GAnimation.startRun2002()
	local function aniEndBack()
		GAnimation.endRun2002()

		--回合结束
		if data['isGameEnd'] or data['isRoundEnd'] then
			return
		end

		BroAnimation.disSaidPlayer(_users)
	end

	local befThinku = getUserByPos(data['selectSeatNum'])
	if not befThinku then
		aniEndBack()
		return
	end
	befThinku:setStatus(data['selectType'])
	befThinku:setBetNum(data['betNum'])
	befThinku:setSurplusNum(data['surplusBetNum'])

	BroAnimation.hideAllSaid(_users)
	--前一个思考者状态更新
	BroAnimation.updateDisPlayer({befThinku})
	BroAnimation.updatePoker()
	BroAnimation.updateNowPoolBet()

	local befStatus = befThinku:getStatus()
	--弃牌、跟注 加注 all in、看牌 (没有其他状态)
	if befStatus == StatusCode.GAME_GIVEUP then
		--0.5
		BroAnimation.giveupPoker(befThinku, aniEndBack)
	elseif befStatus == StatusCode.GAME_LOOK then
		DZPlaySound.playCheck()	
		aniEndBack()
	elseif GJust.isMoveBetByStauts(befStatus) then
		--0.62
		BroAnimation.surplusBetToNow({befThinku}, aniEndBack)
	else
		aniEndBack()
	end

	--别人加注、all in更新自己自动跟注value
	if not befThinku:isSelf() and GJust.isUpdateFollowValueByStatus(befStatus) then
		BroAnimation.updateFollowValue()
	end
end



--服务器发牌2003
function GameCtrol.handleSendPool(data, broNum)
	GAnimation.startRun2003()
	--====test
	-- local playerCards = {}
	-- for i=1, 2 do
	-- 	local pc = {}
	-- 	pc['seatNum'] = i
	-- 	pc['cards'] = {2, 3}
	-- 	pc['cardsType'] = i
	-- 	table.insert(playerCards, pc)
	-- end
	-- data['playerCards'] = playerCards
	--更新跟注值
	if data['miniRaise'] then 
		GData.setAvailableRaiseVal(data['miniRaise'])
	else 
		GData.setAvailableRaiseVal(Single:gameModel():getBigBlind())
	end

	if data['maxBet'] then 
		GData.setMaxBetNum(data['maxBet'])
	else
		GData.setMaxBetNum(0)
	end

	local players = data['playerCards']
	--Fixme: tanhaiting 这里处理有待商榷，应为disPoker2003中同样进行了一次players的遍历
	if players then 
		for i = 1, #players do 
			local pok = players[i]
			local typetext, maxCards, typeInt = Single:gameModel():getUserCardsType(pok['cards'])
			pok['cardsType'] = typeInt
		end
	end
	local disUsers = UserCtrol.disPoker2003(data['playerCards'])

	local function aniEndBack2()
		BroAnimation.updatePoker()

		if data['isRoundEnd'] then
			GAnimation.endRun2003()
			return
		end
		
		BroAnimation.hidePlayerStatus(_users)
		BroAnimation.disSaidPlayer(_users)
		GAnimation.endRun2003()
	end

	local function flipPokerEndBack()
		BroAnimation.displayPoolCards(aniEndBack2)
	end

	local function aniEndBack1()
		BroAnimation.updateRoundPoolBet(true)
		if #disUsers > 0 then
			BroAnimation.showAllTimeTwoPokerAni(disUsers, flipPokerEndBack)
		else
			flipPokerEndBack()
		end
	end

	BroAnimation.nowBetToPool(_users, aniEndBack1)
end

--玩家站起围观 2005
function GameCtrol.handleStandLook(data, broNum)
	local otherm = getUserByPos(data['seatNum'])
	if not otherm then return end
	
	GAnimation.startRun2005()

	--站起来的是自己
	if Single:playerModel():getId() == otherm:getUserId() then
		--清空自己手里两张牌
		Single:gameModel():clearSelfCard()
		GWindow.removeBuy()
	end

	local player = UserCtrol.getOnePlayerByOneUser(otherm)
	player:standCall()

	local tab = {}
	tab['userId'] = otherm:getUserId()
	tab['headUrl'] = otherm:getHeadUrl()
	tab['userName'] = otherm:getUserName()
	tab['surplusNum'] = otherm:getSurplusNum()
	tab['rongyunId'] = otherm:getUserRYId()
	UserCtrol.standDo(tab)
	GameCtrol.handlerUpdateStraddle(data)
	removeUserByPos(data['seatNum'])
	--用户离开，确保大盲，小盲标记正确
	-- local model = Single:gameModel()
	-- local dealer, sb, bb = model:getDealerSeatNo(), model:getSmallBlindSeatNo(), model:getBigBlindSeatNo()
	-- Single:playerManager():updateBlindBet(bb, sb, dealer)
	GAnimation.endRun2005()
end


--处理广播 2007
function GameCtrol.handleRoundResult(data, broNum)
	DZPlaySound.stopClock()
	DZPlaySound.playWin()
	
	local winUsers = data['winners']
	local dispokers = data['playerCards']
	-- local totherms = {}

	for i=1,#winUsers do
		local tuser = winUsers[ i ]
		local otherm = getUserByPos(tuser['seatNum'])
		if otherm then
			otherm:setSurplusNum(otherm:getSurplusNum() + tuser['bet'])
			otherm:setWinBet(tuser['winBet'])
			otherm:setWinnerTag(tuser['isWin'])
		else
			print('stack GameCtrol.handleRoundResult  位置  '..tuser['seatNum'])
			local explain = '出错玩家位置 '..tuser['seatNum']..UserCtrol.getUserDetailed()
			Single:checkGameData('GameCtrol.handleRoundResult  '..explain)
		end
		-- table.insert(totherms, otherm)
	end

	--玩家翻牌动画：站起先发2007之后再发2005
	local resultUsers,disUsers = UserCtrol.disPoker2007(dispokers)
	GAnimation.startRun2007()
	local function aniEndBack3()
		BroAnimation.updateRoundPoolBet(false)
		BroAnimation.removeAllTimeTwoPokerAni(_users)
		GAnimation.endRun2007()
		GData.setTouchTwoCard(false)
	end

	local function aniEndBack2()
		--可能会调用好多次，aniEndBack3
		--displayWinner一定会执行，确保动画时间更displayHandCard相等
		BroAnimation.displayWinner(resultUsers, aniEndBack3)
		-- BroAnimation.displayHandCard(disUsers)
	end

	local function aniEndBack1()
		BroAnimation.poolBetToWin(resultUsers, aniEndBack2)
	end

	local function aniEndBack0()
		BroAnimation.updateSurplusBet(_users)
		BroAnimation.hideAllSaid(_users) 
		BroAnimation.updateRoundPoolBet(true)
		BroAnimation.nowBetToPool(_users, aniEndBack1)
		BroAnimation.hidePlayerStatus(_users)
	end

	--发发看
	local cards = Single:gameModel():getPoolCard()
	if #cards < 5 then
	-- if data['isHavePoolPoker'] then
		BroAnimation.disLookPoolPokerLayer()
	end
	BroAnimation.showAllTimeTwoPokerAni(disUsers, aniEndBack0, 0.6)
end

--处理广播 2008
function GameCtrol.handleSendEmoji(data, broNum)
	local otherm = getUserByPos(data['seatNum'])
	if not otherm then return end
	if otherm:isSelf() then return end
	BroAnimation.sendEmoji(otherm, data['emoji'])
end

--处理广播 2009
function GameCtrol.handleCloseHome(data, broNum)
	ViewCtrol.showMsg('房间已经关闭', 1.5)
	GData.setGameOverStatus(true)

	DZAction.delateTime(nil, 1, function()
		local GResult = require 'game.GResult'
    	GResult.showResult(data)
	end)
end

--处理广播 2010，有人进入游戏
function GameCtrol.handleInto(data, broNum)
	--不是自己
	if Single:playerModel():getId() ~= data['userId'] then
		UserCtrol.oneInto(data)
	end
end

--处理广播 2011，有人退出游戏
function GameCtrol.handleExit(data, broNum)
	UserCtrol.leaveGame(data['userId'])
end

--房主暂停游戏2012
function GameCtrol.handleStopGame(data, broNum)
    Single:gameModel():setPause(true)
    Single:gameModel():setPauseTime(data['pauseTime'])
	BroAnimation.stopGameLayer()
end

--暂停后继续游戏2013
function GameCtrol.handleGoOnGame(data, broNum)
	print("heihei  goOnGameLayer")
    Single:gameModel():setPause(false)
	BroAnimation.goOnGameLayer()
end

--有玩家申请补充记分牌2014
function GameCtrol.handleApplayAddScores(data, broNum)
	local um = getUserById(data['playerId'])
	if um then
		um:setApplayTime(data['surplusTime'])
		BroAnimation.applyAddScores(um)
	end
end

--有玩家补充记分牌2015
function GameCtrol.handleAddScores(data, broNum)
	local um = getUserById(data['playerId'])
	if um then
		um:setSurplusNum(data['surplusNum'])
		BroAnimation.updateScores(um)
	else
		-- local logs = '注意是否是授权牌局  出错玩家id 啊啊啊  '..data['playerId']
		-- Single:appLogs(logs, 'GameCtrol.handleAddScores : '..data['playerId']..UserCtrol.getUserDetailed())
	end
end

--申请补充记分牌被拒2016
function GameCtrol.handleApplayRefused(data, broNum)
	local um = getUserById(data['playerId'])
	if um then
		um:setApplayTime(0)
		BroAnimation.applyScoresResult(um)
	end

	if data['playerId'] == Single:playerModel():getId() then
		ViewCtrol.showMsg('申请被拒绝')
	end
end

--申请补充记分牌通过2017
function GameCtrol.handleApplayAgree(data, broNum)
	local um = getUserById(data['playerId'])
	if um then
		um:setApplayTime(0)
		BroAnimation.applyScoresResult(um)
	end
	if data['playerId'] == Single:playerModel():getId() then
		ViewCtrol.showMsg('申请通过')
	end	
end

--改变授权带入状态2019
function GameCtrol.handleChangeApplay(data, broNum)
	Single:gameModel():setOpenApplay(data['controlBuyin'])
	BroAnimation.updateGameLayerText()
end

--核查记分牌2020
function GameCtrol.handleCheckBet(data, broNum)
	--1.剩余记分牌0、2.我剩余为0、3.不在申请中、4.开启了授权带入、5.标准牌局
	local function standardPoker(sbn, tuser)
		if sbn == 0 and tuser:isSelf() then
			if tuser:getApplyTime() == 0 and Single:gameModel():isOpenApplay() then
				GWindow.showBuy(function()end, GWindow.STAND)
			end
		end
	end

	local sortUsers = {}
	local function sngPoker(sbn, tuser)
		table.insert(sortUsers, tuser)		

		--sng输光的玩家排名
		local rankUsers = {}
		for i=1,#_users do
			local tuser = _users[ i ]
			local rankNum = tuser:getSngLastRank()
			if rankNum ~= StatusCode.SNG_HAVE_BET then
				tuser:setSngLastRank(rankNum)
				table.insert(rankUsers, tuser)
			end
		end

		BroAnimation.displayGrayHeadRank(rankUsers)
	end

	local function mttPoker()
	end


	local users = data['players']
	for i=1,#users do
		local udata = users[i]
		print("额外金钱："..tostring(udata['surplusBetNum'])..'  玩家位置 '..udata['seatNum'])
		local sbn = udata['surplusBetNum']
		local tuser = getUserByPos(udata['seatNum'])

		if tuser then
			tuser:setSurplusNum(sbn)

			local gtype = Single:gameModel():getGameBigType()
			if gtype == GAME_BIG_TYPE_STANDARD then
				standardPoker(sbn, tuser)
			elseif gtype == GAME_BIG_TYPE_SNG then
				tuser:setSngLastRank(udata['sngGameRank'])
				sngPoker(sbn, tuser)
			elseif gtype == GAME_BIG_TYPE_MTT then
				mttPoker()
			end
		else
			print("stack GameCtrol.handleCheckBet: 玩家位置："..udata['seatNum'])
		end
	end


	DZSort.sortObject(sortUsers, StatusCode.UN_SORT, StatusCode.KEY_BET)

	for i=1,#sortUsers do
		sortUsers[ i ]:setRank( i )
	end

	Single:gameModel():setPokerStartTag(false)
end

--升盲2021
function GameCtrol.handleUpBlind(data, broNum)
	local smallBlind = tonumber(data['bigBlind']) / 2
	-- Single:gameModel():setSmallBlind(bigBlind/ 2)
	
	local blevel = data['blindLevel']
	if blevel then
		GData.setNowBlindLevel(blevel)
		-- if GData.getMaxAddTimes() > 0 and GData.getOverBlindLevel() == blevel then
		if GData.isAddOn() then
			DZAction.delateTime(nil, 1.5, function()
				ViewCtrol.showMsg('当前可以增购', 2.5)
			end)
		end
	end

	BroAnimation.upBlindPrompt(smallBlind)
	BroAnimation.displayAddOn()
end

--托管2022
function GameCtrol.handleTrusteeship(data, broNum)
	local otherm = getUserByPos(data['seatNum'])
	if not otherm then return end

	--自己取消托管不走此
	if not data['isAuto'] then
		if otherm:isSelf() then return end
	end

	otherm:setTrusteeship(data['isAuto'])
	BroAnimation.playerTrusteeship(otherm)
end

--取消托管成功
--1016模拟此消息了
function GameCtrol.meCancelTrusteeship()
	local meUser = GSelfData.getSelfModel()
	if not meUser then return end
	meUser:setTrusteeship(false)
	BroAnimation.playerTrusteeship(meUser)
end

--增加思考时间2023
function GameCtrol.handleAddThinkTime(data, broNum)
	dump(data, '广播2023')
	local addType = data['addType']
	if addType == 2 then 
		BroAnimation.handlerInsuranceDelayTime(data)
	elseif addType == 3 then 
		
	else --喊注的时间
		local otherm = getUserByPos(data['seatNum'])
		otherm:setRTime(data['surplusThinkingTime'])
		otherm:setStatus(StatusCode.GAME_DELAY)
		BroAnimation.delayThinkTime(otherm)
	end
end

--发送动画2024
function GameCtrol.handleSendAnimation(data, broNum)
	local fromUser = getUserByPos(data['fromSeatNum'])
	local toUser = getUserByPos(data['toSeatNum'])
	if not fromUser or not toUser then
		return
	end
	toUser:setAniTag(data['emoji'])

	local function moveBack()
		local player = UserCtrol.getOnePlayerByOneUser(toUser)
		player:disAnimationFather(toUser)
	end

	Single:playerManager():moveAnimation(fromUser, toUser, data['emoji'], moveBack)
end

--重置倒计时时间2025
function GameCtrol.handleResetGameTime(data, broNum)
	Single:gameModel():setGameTime(data['surplusTime'])	
end

--玩家主动显示两张手牌2026
function GameCtrol.handleDisTwoCard(data, broNum)
	if not GAnimation.isRun2007() then return end
	local seatUser = getUserByPos(data['seatNum'])
	if not seatUser then return end

	local card1 = data['cards'][1]
	local card2 = data['cards'][2]

	--还没有播放翻牌动画
	local pokers = seatUser:getDisPokers()
	if pokers then
		local new1 = pokers[1]
		local new2 = pokers[2]

		if new1 == StatusCode.POKER_BACK then
			new1 = card1
		end
		if new2 == StatusCode.POKER_BACK then
			new2 = card2
		end
		seatUser:setDisPokers({new1, new2})
	end

	local player = UserCtrol.getOnePlayerByOneUser(seatUser)
	player:showdownFather(card1, card2)
end

--mtt决赛或中场休息2027
function GameCtrol.handleMttRest(data, broNum)
	local restTime = data['restTime']
	if not restTime then
		restTime = 100
	end
	if data['client_os_time'] then
		local ostime = os.time() - data['client_os_time']
		restTime = restTime - ostime
	end
	if restTime < 0 then restTime = 0 end

	--不是大厅----
	local smallType = Single:gameModel():getGameType()
    if not DZConfig.isHallMTT(smallType) then
    	GData.setUpblindSurplusTime(0)
		DiffType.setSurplusUpBlindTime(0)
    end

	--先设置剩余时间、在显示倒计时
	Single:gameModel():setGameRest(data['restType'], restTime)
	BroAnimation.disMttRestLayer(restTime, data['restType'])
end

--玩家重购提示2028
function GameCtrol.handlePromptRevive(data, broNum)
	-- GMttBuy.reviveAgainBuy()
	local tcode = GData.getMttCode()
	local unionClubId = GData.getUnionClubId()
	if tcode == 0 then 
		local logs = 'tcode  是 0 了啊啊 '
		local explain = 'GameCtrol.handlePromptRevive'
		Single:appLogs(logs, explain)
		return 
	end
	local CardCtrol = require("cards.CardCtrol")
	CardCtrol.enterMtt(tcode, unionClubId)
end


--mtt奖励alert
function GameCtrol.handleMttAward(data)
	local imageName = data['img']
	-- dump(data, "我的奖励")
	if imageName and #imageName ~= 0 then
		DZAction.delateTime(nil, 1, function()
			GUI.mttAwardHint(imageName)
		end)
	end
end

--mtt我参与的比赛结束2029
function GameCtrol.handlMttOver(data, broNum)
	--==== test
	-- local data = {}
	-- data['isReward'] = true
	-- data['isFinalTable'] = true
	-- data['num'] = 1
	-- data['pokerTime'] = 2323
	-- data['joinNum'] = 190
	-- data['blindLevel'] = 10
	-- data['allNum'] = 1024
	-- data['rewardNum'] = 3
	-- data['img'] = 'https://ss1.bdstatic.com/70cFvXSh_Q1YnxGkpoWK1HF6hhy/it/u=932713434,914955553&fm=23&gp=0.jpg'
	-- local ranks = {}
	-- for i=1,10 do
	-- 	local rank = {}
	-- 	rank['name'] = '玩家名'..i
	-- 	rank['scores'] = i * 10
	-- 	table.insert(ranks, rank)
	-- end
	-- data['ranks'] = ranks
	-- data['participatedNum'] = 10000
	-- data['rebyNum'] = 3
	-- data['addNum'] = 300
	
	local function closeBack()
		if GData.isGameOver() then
			DiffType.exitGameScene()
		end
	end

	--当前还是提示重购界面移除
	GWindow.removeWindowOne()

	local num = data['num']
	local rewardText = '未进入奖励圈下次继续努力'
	local numText = '获得第'..num..'名'
	if data['isReward'] then
		rewardText = '已进入奖励圈'
	end

	data['rewardText'] = rewardText
	data['numText'] = numText

	--没有排名、进入决赛桌、没有进入决赛桌
	--2031弹窗不能展示，否则重合
	if num == -1 then
		GWindow.getWindowTwo('您已被淘汰', '比赛排名计算中...请等待')
	elseif data['isFinalTable'] then
		GWindow.showMTTOver(data, num, closeBack)
	else
		GWindow.getWindowTwo(numText, rewardText, closeBack)
	end

	BroAnimation.removeMttRankLayer()

	GameCtrol.handleMttAward(data)
end


---拆桌合桌提示2030
function GameCtrol.handlePromptDesk(data, broNum)
	BroAnimation.disDeskPromptLayer(data['deskTag'])
	if GJust.isMttChangeDesk(data) then
		local GameScene = require 'game.GameScene'
		GameScene.mttChangeDesk(data['pokerId'])
	end
end

--处理关闭游戏房间2031
function GameCtrol.handleCloseGameRoom(data, broNum)
	GData.setGameOverStatus(true)

	--避免更2029弹窗重合
	local isShowOver1 = GWindow.isShowMTTOver()
	local isShowOver2 = GWindow.isShowGetWindowTwo()
	if isShowOver1 or isShowOver2 then return end

	local function sureBack()
		DiffType.exitGameScene()
	end
	DZWindow.prompt('提示', '房间已关闭请退出', '确定', sureBack)
end

--发发看广播2032
function GameCtrol.handleLookPoolPoker(data, broNum)
	if not GAnimation.isRun2007() then return end
	local function aniEndBack()
	end
	BroAnimation.displayPoolCards(aniEndBack, 140)
	BroAnimation.lookPokerLayer(data['name'], data['round'])
end

--玩家排名mtt2033
function GameCtrol.handlePlayerRank(rankNum)
	BroAnimation.disMttRankLayer(rankNum)
end

--移除mtt中场或决赛休息提示2034
function GameCtrol.handleRemoveRest(data, broNum)
	--大厅----
	local smallType = Single:gameModel():getGameType()
    if DZConfig.isHallMTT(smallType) then
    	GData.setUpblindSurplusTime(data['raiseBlindSurplusTime'])
		DiffType.setSurplusUpBlindTime(data['raiseBlindSurplusTime'])
    end
	
	Single:gameModel():setIsResting(false)
	BroAnimation.removeMttRestLayer()	
end

--mtt牌局更新玩家重构和增购次数
function GameCtrol.handleUpdateBuyTimes(data)
	GData.setAgainTimes(data['repurchaseNum'])
	GData.setAddTimes(data['addNum'])
end

--更新prompt 2050
function GameCtrol.handlerStraddlePrompt(data)
	local originMode = Single:gameModel():getStraddle()
	local newMode = data['straddleMode']
	print("originMode:", tostring(originMode), " newMode:", tostring(newMode))
	Single:gameModel():setStraddle(newMode)
	if originMode ~= newMode and originMode ~= nil and newMode ~= nil then 
		local text = GText.getStraddleModeAlia(originMode, newMode)
		BroAnimation.promptUIStraddle(text)
	end
	GameCtrol.handlerUpdateStraddle(data)
end
--更新straddle 
function GameCtrol.handlerUpdateStraddle(data)
	
	if not data then return end
	
	local isDis = false
	local starddleMode = Single:gameModel():getStraddle()
	if starddleMode == NO_STRADDLE then  -- 没有选择straddle
		BroAnimation.updateStraddleUI(false)
	elseif starddleMode == FREE_STRADDLE then --自由straddle
	
		local straddleSeat = data['straddleSeatNum'] 
		local hasStraddle = data['hasStraddle']
	
		local userObj = getUserByPos(straddleSeat)
		if userObj then 
			isDis = userObj:isSelf()
		else 
			isDis = false
		end
		BroAnimation.updateStraddleUI(isDis, hasStraddle)
		
	elseif starddleMode == MUST_STRADDLE then --强制straddle
		BroAnimation.updateStraddleUI(false)
	end
end
--模拟广播10000:玩家刚进入游戏，数据已经处理完
function GameCtrol.broUsersBaseMsg(data, susers, broNum)
	local bigSeat = data['bigBlindSeatNum'] --大盲
	local smallSeat = data['smallBlindSeatNum'] --小盲
	local dealerSeat = data['dealerSeatNum']  -- 庄家

	local playManager = Single:playerManager()
	local users = susers
	for i=1,#users do
		local tuser = users[ i ]
		local obj = GameCtrol.addUser(tuser)

		UserCtrol.userLinkPlayer(obj)

		local status = obj:getStatus()

		if obj:isSelf() then
			local runPos = GSelfData.getMeRunPos()
			BroAnimation.aniMeSeat(runPos, function()end, true)
		end	

		if status == StatusCode.GAME_THINK then
			obj:setRTime(tuser['surplusThinkingTime'])
		end

		if obj:getSeatNum() == bigSeat then
			obj:setBigBlind(true)
		elseif obj:getSeatNum() == smallSeat then
			obj:setSmallBlind(true)
		end

		if tuser['miniRaise'] then
			GData.setAvailableRaiseVal(tuser['miniRaise']) 
		end
		if tuser['maxBet'] then
		 	GData.setMaxBetNum(tuser['maxBet']) 
		end
	end
	-- --移除购买记分牌界面
	if not GSelfData.isHavedSeat() then
		GWindow.removeBuy()
	end

	BroAnimation.intoGameHandlePlayer(_users)
	BroAnimation.intoGameHandleGameLayer()
	playManager:updateBlindBet(bigSeat, smallSeat, dealerSeat)
	
	local bigType = Single:gameModel():getGameBigType()
	if bigType == GAME_BIG_TYPE_MTT then
		local mtt = data['mtt']
		BroAnimation.disMttRankLayer(mtt['mttRank'])
		BroAnimation.disDeskPromptLayer(mtt['deskTag'])
		-- BroAnimation.mttCountDownLayer(mtt['countDown'])
		BroAnimation.disMttRestLayer(mtt['restTime'], mtt['restType'])
		
		BroAnimation.displayAddOn()
	end
	--更新 straddle
	GameCtrol.handlerUpdateStraddle(data)
	--处理1000消息之保险
	GameCtrol.handlerInsureFor1000(data, broNum)
end
--


---3000广播

--移除新消息标示
function GameCtrol.removeNewMsgSignUp()
	BroAnimation.disappearNewMsg()
end


--显示新消息
function GameCtrol.displayNewMsgSignUp()
	BroAnimation.displayApply()
end


function GameCtrol.handlerInsureFor1000(data, broNum)
	local isInsure = data['isInsure']
	local insureData = data['insure']
	
	if not isInsure or not insureData then 
		do return end
	end
	
	local state = insureData['state']
	if state == StatusCode.INSURE_DURING_PURCHASE then 
		local poolCards = data['poolCard']
		insureData['poolCards'] = poolCards
		insureData['needSelect'] = true
		insureData['reason'] = ""
		dump(insureData, "显示数据")
		local isGiveup, isSeat = GSelfData.isNotInGame()
		-- print("isGiveUp:"..tostring(isGiveup), "isSeat:"..tostring(isSeat))
		if not isGiveup and isSeat then --不是弃牌用户，并且是坐下的用户
			GData.setInsureBuying(true)
		end
		GameCtrol.handlerInsurePanel(insureData,false, BRO_INSURE_PURCHASE)
 	elseif state == StatusCode.INSURE_DURING_CUOPAI then 
 		-- GSelfData.setCuopaiDelayDiamond(xxxx['addThinkTimePrice'])
	end
end

--2101进入保险模式，播放动画
function GameCtrol.handlerIntoInsureModeAnim(data, protocolNum)
	--隐藏一些状态界面，以及下注的那些界面
	GAnimation.startRun2101()
	local users = GameCtrol.getAllUsers()
	BroAnimation.hidePlayerStatus(users)
	--不是弃牌用户，并且是坐下的用户
	local isGiveup, isSeat = GSelfData.isNotInGame()
	if not isGiveup and isSeat then 
		GData.setInsureBuying(true)
	end
	--播放保险界面
	BroAnimation.displayInsureAnim(function() 
			GAnimation.endRun2101()
		end)
end


--2102进入保险模式，展现保险界面
function GameCtrol.handlerInsurePanel(_data, _isNeedAnim, _protocolNum)
	local needSelect = _data['needSelect']
	local reason = _data['reason']
	local players = _data['players']
	-- print("2012 进栈<<< SCENE_NAME:"..tostring(cc.Director:getInstance():getRunningScene():getName()))
	GAnimation.startRun2102()
	--展示手牌的回调
	-- print("needSelect:"..tostring(needSelect))
	local function displayHandsCardCallback()
		if needSelect then 
			print("2102 出栈>>>")
			GAnimation.endRun2102()
			--展现保险界面
			BroAnimation.intoGameHandlerInsure(_data,_protocolNum)
		else 	
			-- local user = UserCtrol.getSeatUserByPos(data.insureSeatNum)
			-- local name = user:getUserName()
			--展示不能购买的提示
			GUI.showHorizontalHint({reason}, function() 
												print("2102出债！")
												 GAnimation.endRun2102()
												  end)
		end
	end

	displayHandsCardCallback()
end

--2103同步ui
function GameCtrol.sycInsureUIPanel(data, _protocolNum)
	BroAnimation.sycInsureUI(data)
end

--2104通知有人购买保险
function GameCtrol.notifiyPurchase(data, _protocolNum)
    GAnimation.startRun2104()
    BroAnimation.notifiyPurchase(data, function()
   		GAnimation.endRun2104()
   	end)
end
--2107执行保险结算
function GameCtrol.handlerInsureFlopCards(data, protocolNum)
	GAnimation.startRun2107()
	local function aniEndBack2()
		-- BroAnimation.updatePoker()
		BroAnimation.displayInsureSettlement(data,
			function()
				print("2017 出债！")
				GAnimation.endRun2107()
			end)
		-- end
	end
	
	local function delayCallBack()
		DZAction.delateTime(nil, 0.3, aniEndBack2)
	end
	BroAnimation.displayPoolCards(delayCallBack)
end

--2108执行亮牌操作
function GameCtrol.handlerPresentCards(data)
	GAnimation.startRun2108()
	local function callback()
		GAnimation.endRun2108()
	end
	local players = data["playerCards"]
	local users = UserCtrol.disPoker2108(players)
	BroAnimation.showAllTimeTwoPokerAni(users, callback,0.8)
end
-- 搓牌
function GameCtrol.handlerCuoPaiPanel(_data)
	dump({}, "搓牌", nesting)
end

--ante 2200
function GameCtrol.handleGameAnte(data)
	local players = data['players']
	local tusers = {}

	local allAnte = 0
	for i=1,#players do
		allAnte = allAnte + players[ i ]['bet']
	end

	BroAnimation.promptChangeANTELayer(data['ante'])

	for i=1,#_users do
		local tuser = _users[i]
		local tpos = tuser:getSeatNum()

		for j=1,#players do
			local player = players[j]
			if tpos == player['seatNum'] then
				tuser:setSurplusNum(player['surplus'])
				tuser:setBetNum(player['bet'])
				table.insert(tusers, tuser)
				break
			end
		end
	end

	local function anteAniEndBack2()
		BroAnimation.updateRoundPoolBet(true)
		GAnimation.endRun2200()
	end
	local function anteAniEndBack1()
		BroAnimation.nowBetToPool(tusers, anteAniEndBack2)
	end

	GAnimation.startRun2200()
	BroAnimation.surplusBetToNow(tusers, anteAniEndBack1)
end

--其他
--一手牌结束
function GameCtrol.resetLayerData()
	GData.setInsureBuying(false)
	BroAnimation.clearRoundLayer(_users)
	Single:playerManager():updateBlindBet(-1, -1, -1)
end

--得到所有用户
function GameCtrol.getAllUsers()
	return _users
end


--进其他界面清除数据
function GameCtrol.clearData()
	_users = {}
	-- Single:gameModel():clearData()
end


return GameCtrol
