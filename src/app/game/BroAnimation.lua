local BroAnimation = {}

local function gameLayer()
	local GameLayer = require 'game.GameLayer'
	local instance = GameLayer:getInstance()
	return instance
end

local function insuraceObj()
-- 	local InsuranceView = require('game.InsuranceView')
-- 	local insure_instance = InsuranceView:getInstance()
-- 	return insure_instance
	local insuranceNode = gameLayer():getInsurancePanel()
	if not insuranceNode then 
		local InsuranceView = require('game.InsuranceView')
		insuranceNode = InsuranceView.new()
		gameLayer():showInsurancePanel(insuranceNode)
	end
	return insuranceNode
end


--自己点击坐下有动画、断网重连、一进来自己已经坐下 没有动画
function BroAnimation.aniMeSeat(runPos, aniEndBack, noAni)
	local pm = Single:playerManager()
	pm:changePos(runPos, noAni, aniEndBack)
end

--弃牌动画
--1. 2002
function BroAnimation.giveupPoker(user, aniEndBack)
	local player = UserCtrol.getOnePlayerByOneUser(user)	
	player:runGiveUpFather(user, aniEndBack)
end

--清除回合界面
function BroAnimation.clearRoundLayer(users)
	UserCtrol.resetUsers(users)
	UserCtrol.resetGameModel()

	local players = UserCtrol.getPlayerByUser(users)	
	for i=1,#players do
		local user = players[ i ]:getUserData()
		players[ i ]:resetRoundLayerFather(user)
	end
	gameLayer():clearRoundGameLayer()
end


--player界面
--

--剩余筹码移动到当前押注的筹码
--1. 2001发牌时候大小盲
function BroAnimation.surplusBetToNow(users, aniEndBack)
	local players = UserCtrol.getPlayerByUser(users)
	for i=1,#players do
		local player = players[ i ]

		if player:isSeat() then
			local user = player:getUserData()
			player:moveToNowBetObj(function()
				player:disNowBetObj(user)
				end)
		end
	end

	local moveTime = GUI.getMoveBetToNowTime1() + 0.1
	local interval = GUI.getMoveBetIntervalTime1()
	local betNum = GUI.getMoveBetNum()
	local delay = betNum * interval + moveTime

	DZAction.delateTime(GameHelp.getDelaySprite(), delay, function()
		if aniEndBack then
			aniEndBack()
		end
	end)
end
 
--当前押注的筹码到底池筹码
--1. 2003
function BroAnimation.nowBetToPool(users, aniEndBack)
	local players = UserCtrol.getPlayerByUser(users)
	local tBack = aniEndBack

	local isHaveMove = false
	for i=1,#players do
		local player = players[ i ]
		local tuser = player:getUserData()
		if tuser:getBetNum() ~= 0 then
			--展示当前押、坐下了
			if player:isDisNowBetObj() and player:isSeat() then
				player:moveToPoolBetObj(tBack)
				isHaveMove = true
				tBack = nil
			end
		end

		tuser:setBetNum(0)
	end

	--玩家都看牌
	if not isHaveMove then
		aniEndBack()
	end
end

--底池的筹码移动到赢家
--2007
function BroAnimation.poolBetToWin(users, aniEndBack)
	local players = UserCtrol.getPlayerByUser(users)

	local isHaveMove = false
	for i=1,#players do
		local player = players[ i ]
		local tuser = player:getUserData()

		if tuser:getWinBet() ~= 0 then
			isHaveMove = true
			player:moveToWinBetObj(aniEndBack)
		end

		tuser:setBetNum(0)
	end

	if not isHaveMove then
		aniEndBack()
	end
end


--展示赢家
--2007
function BroAnimation.displayWinner(users, aniEndBack)
	local players = UserCtrol.getPlayerByUser(users)

	local isHaveWin = false
	for i=1,#players do
		local player = players[ i ]
		local tuser = player:getUserData()

		if tuser:getWinBet() ~= 0 and tuser:isWinnerTag() then
			player:disWinnerFather(aniEndBack)
			isHaveWin = true
		end
	end

	if not isHaveWin then
		DZAction.delateTime(GameHelp.getDelaySprite(), 3.5, function()
			aniEndBack()
		end)
	end
end


--展示两张玩家的手牌
--2007
function BroAnimation.displayHandCard(users)
	local players = UserCtrol.getPlayerByUser(users)
	for i=1,#players do
		players[ i ]:flipTwoPoker()
	end
end


--展示两张玩家的手牌一直显示知道牌局结束
--2003
function BroAnimation.showAllTimeTwoPokerAni(users, aniEndBack, time)
	local players = UserCtrol.getPlayerByUser(users)

	for i=1,#players do
		players[ i ]:showAllTimeTwoPoker(function()end, function()end)
	end	

	--翻牌动画执行0.4秒
	DZAction.delateTime(GameHelp.getDelaySprite(), time or 0.4, aniEndBack)
end

function BroAnimation.removeAllTimeTwoPokerAni(users)
	local players = UserCtrol.getPlayerByUser(users)

	for i=1,#players do
		players[ i ]:removeAllTimeTwoPoker()
	end
end


--显示当前的说话者
--1. 2001、2002、2003
function BroAnimation.disSaidPlayer(users)
	for i=1,#users do
		local tuser = users[ i ]
		if tuser:isSaid() then
			local player = UserCtrol.getOnePlayerByOneUser(tuser)	
			player:disSaidFather()

			tuser:setStatus(StatusCode.GAME_THINK)
			break
		end
	end
end

--隐藏所有的说话者
--1. 2001
function BroAnimation.hideAllSaid(users)
	local players = UserCtrol.getPlayerByUser(users)	
	for i=1,#players do
		if players[ i ]:isSeat() then
			players[ i ]:hideSaidFather()
		end
	end
end


--更新玩家显示：剩余筹码、当前押注、状态
--2002
function BroAnimation.updateDisPlayer(users)
	local players = UserCtrol.getPlayerByUser(users)	
	for i=1,#players do
		local player = players[ i ]

		if player:isSeat() then
			local user = player:getUserData()
			player:disStatusObj(user)
			player:disSurplusBetObj(user)
			player:disNowBetObj(user)
		end
	end
end


--只更新玩家剩余筹码
--2007
function BroAnimation.updateSurplusBet(users)
	local players = UserCtrol.getPlayerByUser(users)	
	for i=1,#players do
		local user = players[ i ]:getUserData()
		players[ i ]:disSurplusBetObj(user)
	end
end

--隐藏玩家状态
--2003
function BroAnimation.hidePlayerStatus(users)
	local players = UserCtrol.getPlayerByUser(users)	

	for i=1,#players do
		local player = players[ i ]
		local user = player:getUserData()
		player:hideStatusObj(user)
		player:hideNowBetObj()
		player:hideSaidFather()
	end
end

--申请补充记分牌
function BroAnimation.applyAddScores(user)
	local player = UserCtrol.getOnePlayerByOneUser(user)
	player:applayTimeFather(user:getApplyTime())
end

--只显示头像、名字、剩余筹码
function BroAnimation.disPlayerSeat(user)
	local player = UserCtrol.getOnePlayerByOneUser(user)
	if player:isSeat() then
		local user = player:getUserData()
		player:hideAll()
		player:getDObj():disSurplusBet(user)
	end
end

--发两张牌
function BroAnimation.disDealerFlag(users)
	local players = UserCtrol.getPlayerByUser(users)

	for i=1,#players do
		local player = players[ i ]
		local user = player:getUserData()
		player:hideAllFather()

		if user then
			--庄
			if user:isDealer() then
				player:disDObj()
			end
			--大盲、小盲
			player:disSurplusBetObj(user)
		else
			local logs = 'user is nil '.. UserCtrol.getUserDetailed()
			Single:appLogs(logs, 'BroAnimation.disDealerFlag')	
			print('stack BroAnimation.disDealerFlag')
		end
		-- player:disTwoPokerTagFather()
	end
end

--给用户轮播发牌
--seatNums 座位号码数组--排序好的, 
--发完牌的回调
function BroAnimation.dealToUsers(seatNums, callback)
	if #seatNums <= 0 then return end
	local function showCard(player, round)
		if not player then return end--如果player不存在返回
		player:showApokerFather(round)
	end
	gameLayer():setDealGroupVisible(true) --显示牌堆
	local interval = 0
	local len =  #seatNums
	--按照顺序发牌
	for i = 1, 2 do  --2
		for j = 1, len do 
			local tmpSeatNum = seatNums[j]
			local user = UserCtrol.getSeatUserByPos(tmpSeatNum)
			local player = UserCtrol.getOnePlayerByOneUser(user)
			local pos = player:getCardPos()
			gameLayer():dealPokerToUser(pos, interval, function() 
					DZPlaySound.playGameSound("sound/game/dealcard.mp3", false)
					showCard(player, i)
					if i*j == 2*len then 
						callback()
						gameLayer():setDealGroupVisible(false)
					end
				end)
			interval = interval + 0.1
		end
	end
	-- DZAction.delateTime(nil, interval + len*2*0.2, function() 
	-- 			callback()
	-- 			gameLayer():setDealGroupVisible(false)
	-- 		end)
end

--更新记分牌
function BroAnimation.updateScores(user)
	local player = UserCtrol.getOnePlayerByOneUser(user)
	player:updateSurplusBetFather(user)
end

--补充记分牌申请结果
function BroAnimation.applyScoresResult(user)
	local player = UserCtrol.getOnePlayerByOneUser(user)
	player:removeApplayTimeFather()
end

--延迟思考时间
function BroAnimation.delayThinkTime(user)
	local player = UserCtrol.getOnePlayerByOneUser(user)
	player:disSaidTimeFather(user:getRTime())
	player:disStatusObj(user)
end

--sng托管 -- 更新战队图标
function BroAnimation.playerTrusteeship(user)
	local player = UserCtrol.getOnePlayerByOneUser(user)
	player:setPresentTeamMark(user)
	player:setUITrusteeshipFather(user)
end

function BroAnimation.playerTeamMark(user)
	local player = UserCtrol.getOnePlayerByOneUser(user)
	player:setPresentTeamMark(user)
end

--sng玩家玩家最终名次
function BroAnimation.displayGrayHeadRank(users)
	local players = UserCtrol.getPlayerByUser(users)
	for i=1,#players do
		local player = players[i]
		local user = player:getUserData()
		player:disGrayHeadRankFather( user:getSngLastRank() )
	end
end


--发送表情
function BroAnimation.sendEmoji(user, emojiStr)
	local player = UserCtrol.getOnePlayerByOneUser(user)
	player:runShowEmoji(emojiStr)
end



----GameLayer相关的更新
--

--显示底牌，翻牌动画
--2003
function BroAnimation.displayPoolCards(aniEndBack, opacityVal)
	local poolCards = Single:gameModel():getNewPoolCard()
	gameLayer():disPoolCards(poolCards, aniEndBack, opacityVal)
end

--回合底池
function BroAnimation.updateRoundPoolBet(isDis)
	if isDis then
		gameLayer():disRoundPoolBet()
	else
		gameLayer():hideRoundPoolBet()
	end
end

--当前押注总和
function BroAnimation.updateNowPoolBet()
	gameLayer():disNowPoolBet()
end

--更新提示
function BroAnimation.updatePrompt()
	gameLayer():updteLayerPrompt()
end

--牌型提示、牌型高亮、
function BroAnimation.updatePoker()
	local text,pokers = Single:gameModel():getCardsType()
	gameLayer():disPokerType(text)
	gameLayer():disPokerHighlight(pokers)
end

--暂停游戏
function BroAnimation.stopGameLayer()
	gameLayer():stopGameLayer()
end

--继续游戏
function BroAnimation.goOnGameLayer()
	gameLayer():goOnGameLayer()
end

--是房主显示申请按钮
function BroAnimation.displayApply()
	gameLayer():disMsgPrompt()
end

--标准牌局中没有申请带入记分牌的
function BroAnimation.disappearNewMsg()
	gameLayer():hideMsgPrompt()
end

function BroAnimation.updateGameLayerText()
	gameLayer():promptChangeAuthorize()
end

function BroAnimation.promptChangeANTELayer(ante)
	gameLayer():promptChangeANTE(ante)
end

--升盲提示
function BroAnimation.upBlindPrompt(smallBlind)
	-- gameLayer():promptUPBlind(smallBlind)
	--升盲提示动画
	DZAction.sngUPBlind(smallBlind)
	--重置升盲时间
	DiffType.resetUpBlindTime()
end

--显示或隐藏增购标示
function BroAnimation.displayAddOn()
	gameLayer():disAddOn()
end
function BroAnimation.removeAddOn()
	gameLayer():hideAddOn()
end

--桌上面的盲注提示文字
function BroAnimation.blindPromptText()
	local bigBlind = Single:gameModel():getBigBlind()
	gameLayer():promptUPBlind(bigBlind)
end

--拆桌合桌提示
function BroAnimation.disDeskPromptLayer(deskTag)
	if deskTag == 1 then
		gameLayer():disDeskPrompt('请等待，合桌中...')
	elseif deskTag == 0 then
		gameLayer():disDeskPrompt('请等待，拆桌中...')
	end
end

function BroAnimation.removeStartGameLayer()
	gameLayer():removeStartGame()
end

--mtt倒计时
function BroAnimation.mttCountDownLayer(time)
	if time > 0 then
		gameLayer():mttCountDown(time)
	end
end

--mtt中场或决赛休息
function BroAnimation.disMttRestLayer(restTime, restType)
	if restType == 1 then
		gameLayer():disMttRest(restTime, '中场休息')
	elseif restType == 2 then
		gameLayer():disMttRest(restTime, '决赛前休息')
	elseif restType == 0 then
		ViewCtrol.showMsg('中场时间已到', 1.5)
	elseif restType == 3 then
		ViewCtrol.showMsg('决赛开始', 1.5)
	end
end

--mtt玩家排名
function BroAnimation.disMttRankLayer(rankNum)
	if not rankNum or rankNum < 1 then return end
	gameLayer():disMttRank(rankNum)
end
function BroAnimation.removeMttRankLayer()
	gameLayer():removeMttRank()
end

--发发看提示
function BroAnimation.lookPokerLayer(name, roundNum)
	gameLayer():lookPoker(name, roundNum)
end

--显示发发看按钮
function BroAnimation.disLookPoolPokerLayer()
	gameLayer():disLookPoolPoker()
end

--移除mtt中场或决赛休息
function BroAnimation.removeMttRestLayer()
	gameLayer():removeMttRest()
end



----只有me才有的动画
--

--更新跟注默认值
function BroAnimation.updateFollowValue()
	SelfLayer:disAutoFollow()
end


------------------------------
--更新straddle
--控制是否显示按钮且使其可以
------------------------------
function BroAnimation.updateStraddleUI(isDis, hasStraddle)
	if isDis then 
		gameLayer():disStraddleOpt(hasStraddle)
	else 
		gameLayer():hideStraddleOpt()
	end
end
--修改牌桌上面关于straddle的显示
function BroAnimation.promptUIStraddle(text)
	if not Single:gameModel():isManager() then 
		ViewCtrol.showMsg(text or "straddle切换为....", 2)
	end
	gameLayer():promptStraddle()
end
--进入游戏或断网重连
--

--处理玩家界面显示 player
function BroAnimation.intoGameHandlePlayer(users)
	local players = UserCtrol.getPlayerByUser(users)

	local function handleSng(player, user)
		--sng托管
		player:setUITrusteeshipFather(user)
		if user:getSngLastRank() ~= StatusCode.SNG_HAVE_BET then
			--sng最终排名
			BroAnimation.displayGrayHeadRank({user})
		end
	end

	for i=1,#players do
		local player = players[ i ]
		local user = player:getUserData()

		player:disWaitFather(user)

		local status = user:getStatus()
		if GJust.isHaveSendTag(status) then
			--庄
			if user:isDealer() then
				player:disDObj()
			end

			--当前押注
			if user:getBetNum() ~= 0 then
				player:disNowBetObj(user)
			end

			--发牌标示、状态
			player:disTwoPokerTagFather()
			player:disStatusObj(user)	
			player:initDisStatusFather(status)

			--显示说话
			if status == StatusCode.GAME_THINK or status == StatusCode.GAME_DELAY then
				player:disSaidFather(user:getRTime())
			end
		end

		--补充记分牌申请计时
		player:applayTimeFather(user:getApplyTime())
		
		local bigType = Single:gameModel():getGameBigType()
		player:setPresentTeamMark(user)
		if bigType == GAME_BIG_TYPE_SNG then
			handleSng(player, user)
		elseif bigType == GAME_BIG_TYPE_MTT then
			player:setUITrusteeshipFather(user)
		end
	end
end

--处理 GameLayer 显示
function BroAnimation.intoGameHandleGameLayer()
	gameLayer():handleDisplay()
end

--2101进入保险模式的动画
function BroAnimation.displayInsureAnim(back)
	gameLayer():showInsuranceMode(back)
end


-- 2102处理 保险界面 显示
function BroAnimation.intoGameHandlerInsure(_data, _protocolNum)
	-- GUI.showHorizontalHint("Outs值 <= 14 或者 Outs值不等于0")
	local data = _data 
	local curUserpos = -1
	if GSelfData.isHavedSeat() then 
		local selfUser = GSelfData.getSelfModel()
		curUserpos  = selfUser:getSeatNum()
	end
	table.sort(data.players, function(a, b)
			if a.seatNum == data.insureSeatNum then 
				return true
			end
			if b.seatNum == data.insureSeatNum then 
				return false
			end
			return a.seatNum < b.seatNum
		end)
	local betPlayer = data.players[1]
	data['isPurchaser'] = (curUserpos == data.insureSeatNum)--补充数据带入
	data['isCuouser'] 	= (curUserpos == data.cuoSeatNum)
	data['betNum']   = betPlayer.betInPool
	local parent = gameLayer():getParent()
	local insurance = insuraceObj()
	insurance:initData(data)
	insurance:showView(parent)
end

-- 2103同步保险ui
function BroAnimation.sycInsureUI(_data)
	local data = _data 
	local insurance = insuraceObj()
	insurance:synchronizationUI(data)
end

--2104通知有人购买保险
function BroAnimation.notifiyPurchase(_data, back)
	-- print("insuraceObj.visible:"..tostring(insuraceObj().setVisible))
	-- print("insuraceObj.visible:"..tostring(insuraceObj().initOperationView))
	-- print("hideview:"..tostring(insuraceObj().hideView))
	insuraceObj():hideView()
	gameLayer():showPurchaseResult(_data, back)
end

--2107展示保险结算
function BroAnimation.displayInsureSettlement(data, back)
	if not data['hasBuy'] then
		back()
		do return end 
	end
	
	local function callback()
		back()
		--隐藏玩家状态
		-- player:hideStatusObj(player:getUserData())
		-- player:hideNowBetObj()
		-- player:hideSaidFather()
		--显示为当前的说话者
		-- if user:isSaid() then 
		-- 	  player:disSaidFather()
		-- 	  user:setStatus(StatusCode.GAME_THINK)
		-- end
	end

	gameLayer():showInsureSetltement(data, callback)

	if data['isHit'] then 
		local user = UserCtrol.getSeatUserByPos(data['insureSeatNum'])
		if user then
			user:setSurplusNum(user:getSurplusNum() + data['compensation'])
			local player = UserCtrol.getOnePlayerByOneUser(user)
			--播放一个钱币动画
			player:moveToWinBetObj(function() 
				player:disSurplusBetObj(player:getUserData())
			end)
		else
			Single:appLogs('玩家位置没有 '..data['insureSeatNum'], 'BroAnimation.displayInsureSettlement')
		end
	end
end

--保险思考时间的增加
function BroAnimation.handlerInsuranceDelayTime(data)
	local thinkingTime = data['surplusThinkingTime']
	insuraceObj():runTime(thinkingTime)
end


--换桌面
function BroAnimation.changeDeskColor(selDesk)
	local tdeskImg = GData.getDeskImg()
	local tmenuImg = GData.getMenuBtnImg()
	local theadImg = GData.getHeadImg()
	local headFontColor = GData.getHeadFontColor()
	local timeColor = GData.getCountTimeColor()

	if tdeskImg then
		gameLayer():changeDeskImg(tdeskImg, tmenuImg, timeColor)
		local pm = Single:playerManager()
		pm:changeNullHeadImg(theadImg, headFontColor)
	end
end


return BroAnimation