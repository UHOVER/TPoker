local GameModel = class("GameModel")
local _gameInstance = nil

function GameModel:changeTab(ret)
	if not ret then return {} end
	return ret
end

function GameModel:changeZero(value)
	if not value then return 0 end
	return value
end


function GameModel:setGameName(name)
	self._gameName = name
end
function GameModel:getGameName()
	if self._gameName == nil then return '没有名字' end
	return self._gameName
end

function GameModel:setShareCode(scode)
	self._shareCode = scode
end
function GameModel:getShareCode()
	return self:changeZero(self._shareCode)
end

function GameModel:isStarting()
	return self._start
end

function GameModel:setStarting(start)
	self._start = start
end

function GameModel:isManager()
	return self._manager
end
--一进游戏、房主发开始广播
function GameModel:setManager(manager)
	self._manager = manager
end


--只有游戏开始才有
function GameModel:setRoundPoolBet(pool)
	self._poolBet = pool
end
function GameModel:getRoundPoolBet()
	if not self._poolBet then
		self._poolBet = {}
	end
	return self._poolBet
end
function GameModel:clearRoundPoolBet()
	self._poolBet = {}
end

function GameModel:setPoolNowBet(bet)
	self._poolNowBet = bet
end
function GameModel:getPoolNowBet()
	return self:changeZero(self._poolNowBet)
end

--1000、2003、2032发发看
--0翻牌前、1翻牌、2转牌、3河牌
function GameModel:setRoundNum(round)
	if not round then
		round = StatusCode.GAME_ROUND0
	end
	self._roundNum = round
end
function GameModel:getRoundNum()
	return self._roundNum
end

--卡牌管理
function GameModel:clearPoolCard()
	self._poolCard = {}
	self._poolNewCard = {}
end
--一进来时候
function GameModel:setPoolCard(cards)
	--testcard
	-- cards = {4, 46, 32, 48, 21}

	self._poolNewCard = cards
	self._poolCard = cards
end

local _idx = 1
function GameModel:addPoolCard(cards)
	--testcard
	-- if _idx == 1 then
	-- 	cards = {49, 23, 30}
	-- 	_idx = 2
	-- elseif _idx == 2 then
	-- 	cards = {36}
	-- 	_idx = 3
	-- elseif _idx == 3 then
	-- 	cards = {4}
	-- 	_idx = 1
	-- end

	dump(cards, "添加的卡牌")
	dump(self._poolCard, "cards测试")
	for i=1,#cards do
		table.insert(self._poolCard, cards[ i ])
	end
	self._poolNewCard = cards
end
function GameModel:getPoolCard()
	local pools = self:changeTab(self._poolCard)
	
	return pools
end
function GameModel:getNewPoolCard()
	return self:changeTab(self._poolNewCard)
end

function GameModel:getMeAllCards()
	local tcards = {}

	table.insert(tcards, self:getCardOne())
	table.insert(tcards, self:getCardTwo())

	if self._poolCard then
		for i=1,#self._poolCard do
			table.insert(tcards, self._poolCard[ i ])
		end
	end
	return tcards
end

function GameModel:getCardsType()
	local PokerType = require 'game.PokerType'
	local allPokers = self:getMeAllCards()
	local typeText,typePokers = PokerType.get_poker_type(allPokers)

	return typeText,typePokers
end

function GameModel:getUserCardsType(userCards)
	local PokerType = require 'game.PokerType'
	if not userCards or #userCards ~= 2 or userCards[1] == 0 or userCards[2] == 0 or 
		#self._poolCard > 5 then 
		return "", {}, -1
	end

	
	local tcards = {}
	table.insertto(tcards, userCards, 1)
	table.insertto(tcards, self._poolCard, #tcards)
	local typeText, typePokers, typeInt = PokerType.get_poker_type(tcards)
	return typeText, typePokers, typeInt
end

--玩家个人信息
function GameModel:setCardOne(one)
	self._cardOne = one
	--testcard
	-- self._cardOne = 43
end
function GameModel:getCardOne()
	return self._cardOne
end

function GameModel:setCardTwo(two)
	self._cardTwo = two
	--testcard
	-- self._cardTwo = 45
end
function GameModel:getCardTwo()
	return self._cardTwo
end

function GameModel:clearSelfCard()
	self._cardOne = nil
	self._cardTwo = nil
end

function GameModel:setSayUserPos(saypos)
	self._sayUserPos = saypos
end
function GameModel:getSayUserPos()
	return self._sayUserPos
end



--一定在设置是否开始牌局之后
--true:1000底池有值并且大于0、2001
--false:2020、1000底池其他情况(无值)
function GameModel:setPokerStartTag(isGaming)
	self._pokerStart = isGaming
end
function GameModel:isPokerStarting()
	return self._pokerStart
end


function GameModel:setGameNum(gnum)
	if not gnum then
		print('stack GameModel:setGameNum  gnum is nil')
		-- self._gameNum = GAME_NUM_NINE
		-- return
	end	
	self._gameNum = gnum
end
function GameModel:getGameNum()
	return self._gameNum
end


function GameModel:isPause()
	return self._pause
end
function GameModel:setPause(pause)
	self._pause = pause
end

function GameModel:setOpenApplay(isOApplay)
	self._isOpenApplay = isOApplay
end
function GameModel:isOpenApplay()
	return self._isOpenApplay
end

function GameModel:setNoPushEnd(pushEnd)
	self._isNoPushEnd = pushEnd
end
function GameModel:isNoPushEnd()
	return self._isNoPushEnd
end

function GameModel:getPauseTime()
	return self._pauseTime
end
function GameModel:setPauseTime(ptime)
	self._pauseTime = self:changeZero(ptime)
end

function GameModel:setGameTime(gtime)
	self._gameTime = gtime
end
function GameModel:getGameTime()
	if not self._gameTime then return 0 end
	return self._gameTime
end

function GameModel:setSmallBlind(bsmall)
	self._smallBlind = bsmall
end
function GameModel:getSmallBlind()
	return self:changeZero(self._smallBlind)
end
function GameModel:getBigBlind()
	return self:getSmallBlind() * 2
end

function GameModel:setSmallBlindSeatNo(seatNum)
	self._smallBlindSeatNum = seatNum
end

function GameModel:getSmallBlindSeatNo()
	return self._smallBlindSeatNum
end

function GameModel:setBigBlindSeatNo(seatNum)
	self._bigBlindSeatNum = seatNum
end

function GameModel:getBigBlindSeatNo()
	return self._bigBlindSeatNum
end

function GameModel:setDealerSeatNo(seatNum)
	self._dealerSeatNum = seatNum
end

function GameModel:getDealerSeatNo()
	return self._dealerSeatNum
end


function GameModel:setThinkTime(think)
	self._thinkTime = think
end
function GameModel:getThinkTime()
	return self._thinkTime
end

function GameModel:setInsuranceTime(insuranceTime)
	self._insuraceTime = insuranceTime
end
function GameModel:getInsuranceTime()
	return self._insuraceTime
end

function GameModel:setCuoTime(cuoTime)
	self._cuoTime = cuoTime
end
function GameModel:getCuoTime()
	return self._cuoTime
end

function GameModel:setIsInsurance(insurance)
	if not insurance then insurance = false end
	self._isInsurace = insurance
end
function GameModel:isInsuranceGame(insurance)
	return self._isInsurace
end

function GameModel:setGameType(gtype)
	self._gameType = gtype
	self:setGameBigType(gtype)
end
function GameModel:getGameType()
	return self._gameType
end

--补充记分牌时大类型区分
function GameModel:setGameBigType(gtype)
	local gameType = DZConfig.changePokerType(gtype)

	if gameType == StatusCode.POKER_GENERAL then
		self._gameBigType = GAME_BIG_TYPE_STANDARD
	elseif gameType == StatusCode.POKER_SNG then
		self._gameBigType = GAME_BIG_TYPE_SNG
	elseif gameType == StatusCode.POKER_MTT then
		self._gameBigType = GAME_BIG_TYPE_MTT
	else
		assert(nil, 'setGameBigType '..gtype)
	end
end
function GameModel:getGameBigType()
	return self._gameBigType
end


function GameModel:setGamePRYId(ryid)
	self._gameRYId = ryid
end
function GameModel:getGamePRYId()
	assert(self._gameRYId, 'getGamePRYId  is nil')
	return self._gameRYId
end


function GameModel:setBeforeTalkBet(beforeTalkBet)
	if not beforeTalkBet then beforeTalkBet = 0 end
	self._beforeTalkBet = beforeTalkBet
end
function GameModel:getBeforeTalkBet()
	return self._beforeTalkBet
end


--straddle、gps、ip
function GameModel:setStraddle(starddle)
	if starddle then
		self._straddleTag = starddle
	end
end
function GameModel:getStraddle()
	return self._straddleTag
end

function GameModel:setStraddleSeatNum(seatNum)
	self._straddleSeatNum = seatNum
end

function GameModel:getStraddleSeatNum()
	return self._straddleSeatNum
end

function GameModel:setGPS(gps)
	self._isGPS = gps
end
function GameModel:isLimitGPS()
	return self._isGPS
end
function GameModel:setIP(ip)
	self._isIP = ip
end
function GameModel:isLimitIP()
	return self._isIP
end


--mtt
function GameModel:setGameRest(restType, restTime)
	if restType ~= -1 then
		self._isRest = true
		self._restTime = restTime
	else
		self._isRest = false
		self._restTime = 0
	end

	DiffType.resetRestTime(self._restTime)
end
function GameModel:isResting()
	return self._isRest
end
function GameModel:getRestTime()
	return self._restTime
end
function GameModel:setIsResting(isResting)
	self._isRest = isResting
end


function GameModel:clearData()
	-- 底池、底池当前押注、分享码、回合数、牌局名
	self._poolBet = nil
	self._poolNowBet = nil
	self._shareCode = nil
	self._roundNum = nil
	self._gameName = nil

	--说话用户pos
	self._sayUserPos = nil

	-- 游戏是否已经开始、房主、底池里的牌、牌池里新增的牌
	self._start = nil
	self._manager = nil
	self._poolCard = {}
	self._poolNewCard = nil

	--卡牌1、卡牌2
	self._cardOne =  nil
	self._cardTwo = nil

	--是否在玩牌：1 牌局开始、坐下的玩家至少有两个
	self._pokerStart = nil

	--牌桌坐了多少人、牌局释放暂停、暂停时间、游戏倒计时
	self._gameNum = nil
	self._pause = nil
	self._pauseTime = nil
	self._gameTime = nil

	--小盲、思考时间、游戏类型、大的类型sng或general
	self._smallBlind = nil
	self._thinkTime = nil
	self._gameType = nil
	self._gameBigType = nil


	--游戏融云id、是否开启授权带入
	self._gameRYId = '00000'
	self._isOpenApplay = false

	--保险、、是否是保险局
	self._insuraceTime = nil
	self._cuoTime = nil
	self._isInsurace = false

	--2009没有进栈游戏结束了、此回合一共下前注数
	self._isNoPushEnd = false
	self._beforeTalkBet = 0

	--mtt
	--是否中场或决赛休息、中场或决赛休息倒计时
	self._isRest = false
	self._restTime = 0


	self._smallBlindSeatNum = -1
	self._bigBlindSeatNum = -1
	self._dealerSeatNum = -1

	-- 0没有开启、1自由straddle、2强制straddle
	self._straddleTag = NO_STRADDLE
	self._straddleSeatNum = -1 --straddle btn 位置 只有强制straddle才有效
	--gps、ip
	self._isGPS = false
	self._isIP = false
end


function GameModel:ctor()
	self:clearData()
end

function GameModel:getInstance()
	if not _gameInstance then
		_gameInstance = GameModel:create()
	end
	return _gameInstance
end

return GameModel