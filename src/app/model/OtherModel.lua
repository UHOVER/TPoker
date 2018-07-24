local UserModel = require 'model.UserModel'
local OtherModel = class("OtherModel", UserModel)

function OtherModel:getSeatNum()
	return self._seatNum
end
function OtherModel:setSeatNum(seat)
	self._seatNum = seat
end

--游戏中
function OtherModel:getBetNum()
	if not self._betNum then return 0 end
	return self._betNum
end
function OtherModel:setBetNum(betnum)
	self._betNum = betnum	
end

function OtherModel:getStatus()
	return self._status
end
function OtherModel:setStatus(status)
	self._status = status	
end

function OtherModel:setDealerTag(dealer)
	self._dealer = dealer
end
function OtherModel:isDealer()
	return self._dealer
end

function OtherModel:setBigBlind(isBig)
	self._isBigBlind = isBig
end
function OtherModel:isBigBlind()
	return self._isBigBlind
end

function OtherModel:setSmallBlind(isSmall)
	self._isSmallBlind = isSmall
end
function OtherModel:isSmallBlind()
	return self._isSmallBlind
end


function OtherModel:isGaming()
	if GJust.isGamingByStatus( self:getStatus() ) then
		return true
	end
	return false
end



function OtherModel:setApplayTime(atime)
	self._applayTime = atime
end
--0时候：玩家是否在游戏中
function OtherModel:getApplyTime()
	if not self._applayTime then return 0 end
	return self._applayTime
end

--要么有两个值{1,2}、要么 nil
function OtherModel:setDisPokers(pokers)
	self._disPokers = pokers
end
function OtherModel:getDisPokers()
	return self._disPokers
end

--rtime 减去5秒之后的剩余值
function OtherModel:setRTime(rtime)
	local mtime = Single:gameModel():getThinkTime()

	if rtime < 1 then
		rtime = 1
	end
	-- if rtime < 5 then 
	-- 	rtime = 1	
	-- else
	-- 	rtime = rtime - 4
	-- end
	-- if rtime > mtime then
	-- 	rtime = mtime
	-- end
	self._rtime = rtime
end
function OtherModel:getRTime()
	if self._rtime == nil then 
		self._rtime = Single:gameModel():getThinkTime()
	end
	return self._rtime
end


--一轮结果用到数据
function OtherModel:setPokerType(tpoker)
	self._pokerType = tpoker
end
function OtherModel:getPokerType()
	return DZConfig.getTypeName(self._pokerType)
end

function OtherModel:setWinBet(bet)
	self._winBet = bet
end
function OtherModel:getWinBet()
	--不等于0时候，播放收钱动画
	--
	if not self._winBet then
		return 0
	end
	return self._winBet
end

function OtherModel:setWinnerTag(isWin)
	self._isWinner = isWin
end
function OtherModel:isWinnerTag()
	--是否是赢得玩家
	return self._isWinner
end

function OtherModel:setAniTag(aniTag)
	self._aniTag = aniTag
end
function OtherModel:getAniTag()
	return self._aniTag
end



--GameMode
function OtherModel:isSaid()
	if Single:gameModel():getSayUserPos() == self:getSeatNum() then
		return true
	end
	return false
end


--其他
function OtherModel:isSeat()
	return true
end


--sng/mtt
function OtherModel:setTrusteeship(isauto)
	self._isTrusteeship = isauto 
end
function OtherModel:isTrusteeship()
	return self._isTrusteeship
end

function OtherModel:setRank(rank)
	self._rank = rank
end
function OtherModel:getRank()
	return self._rank
end
function OtherModel:setSngLastRank(slrank)
	-- -1还没有输光没有最终的排名
	self._sngLastRank = slrank
end
function OtherModel:getSngLastRank()
	return self._sngLastRank
end

function OtherModel:setAllSurplusNum(allSurplusNum)
	if not allSurplusNum then allSurplusNum = 0 end
	self._allSurplusNum = allSurplusNum
end
function OtherModel:getAllSurplusNum()
	return self._allSurplusNum
end


function OtherModel:ctor()
	self:init()

	--用户状态如弃牌、位置号、当前押注
	self._status = nil
	self._seatNum = nil
	self._betNum = nil

	--庄标示、牌型、一轮结果赢bet
	self._dealer = nil
	self._pokerType = nil
	self._winBet = nil

	--是否是：当前说话者、大盲、小盲
	self._isSaid = nil
	self._isBigBlind = nil
	self._isSmallBlind = nil

	--展示扑克、表情、运行时间
	self._disPokers = nil
	self._emoji = nil
	self._rtime = nil

	--开启授权带入申请时间
	self._applayTime = 0

	--sng托管、排名
	self._isTrusteeship = false
	self._rank = 1

	--是否是赢家、动画标示
	self._isWinner = false
	self._aniTag = nil

	--sng玩家排名：输光筹码的玩家的排名，未输光时为-1
	self._sngLastRank = StatusCode.SNG_HAVE_BET

	--自己剩余的积分+已经投入地池的积分
	self._allSurplusNum = 0
end

return OtherModel