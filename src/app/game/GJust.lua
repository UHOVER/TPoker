local GJust = {}

--根据玩家选择状态判断是否移动剩余筹码到当前押注
--加注、跟注、all in  移动
function GJust.isMoveBetByStauts(status)
	if status==StatusCode.GAME_ADD or status==StatusCode.GAME_ALLIN or status==StatusCode.GAME_FOLLOW then
		return true
	end
	return false
end

--根据其他玩家(包括自己)选择状态判断是否更新默认押注
--其他玩家(包括自己)  加注、all in
function GJust.isUpdateFollowValueByStatus(status)
	if status==StatusCode.GAME_ADD or status==StatusCode.GAME_ALLIN then
		return true
	end
	return false
end


--是否是回合第一次加注
function GJust.isRoundFirstAddBet()
	local poolNum = Single:gameModel():getPoolNowBet()
	local beforeBet = Single:gameModel():getBeforeTalkBet()
	if poolNum == beforeBet then
		return true
	end
	return false
end



--开始游戏按钮:是房主 and 游戏没有开始
function GJust.isDisStart()
	local gamem = Single:gameModel()
	if gamem:isManager() and not gamem:isStarting() then 
		return true
	end
	return false
end


--站起按钮是否可用
function GJust.isMeSeat()
	if GSelfData.getSelfModel() then
		return true
	end
	return false
end


--是否是6人局
function GJust.isSixNum()
	if Single:gameModel():getGameNum() == GAME_NUM_SIX then
		return true
	end
	return false
end

--根据pos算左右并返回分界的pos
function GJust.splitPos()
	local gameNum = Single:gameModel():getGameNum()
	if gameNum <= 1 or gameNum > 9 then 
		return 6  --本质上这里是错误的，未避免报错，返回6
	end

	local splitPos = {[2] = 6, [3] = 3, [4] = 3, [5] = 4, [6] = 4, [7] = 5, [8] = 5, [9] = 6 }
	return splitPos[gameNum]
end

--我是否在游戏中：观看者或刚坐下没有参与是不在游戏中的
function GJust.isMeGaming()
	local mod = GSelfData.getSelfModel()
	if not mod then return false end

	if GJust.isGamingByStatus( mod:getStatus() ) then
		return true
	end

	return false
end


--我是否放弃，没有坐下返回false
function GJust.isMeGiveup()
	local mod = GSelfData.getSelfModel()
	if not mod then return false end

	if mod:getStatus() == StatusCode.GAME_GIVEUP then
		return true
	end

	return false
end


--是否是看牌
function GJust.isLookStatus()
	if GMath.getMeNeedBet() <= 0 then
		return true
	end
	return false
end


--是否有发牌状态
--等待中和站起没有
function GJust.isHaveSendTag(status)
	local isTag = true
	if status == StatusCode.GAME_WAIT_ING then
		isTag = false
	elseif status == StatusCode.GAME_NO_STATUS then
		isTag = false
	end

	return isTag
end

function GJust.isGamingByStatus(status)
	local isGaming = true
	if status == StatusCode.GAME_WAIT_ING then
		isGaming = false
	elseif status == StatusCode.GAME_NO_STATUS then
		isGaming = false
	end

	return isGaming
end


--mtt是否可以拆桌或合桌
function GJust.isMttChangeDesk(data)
	if data['pokerId'] then
		return true
	end
	return false
end


--游戏是否是强制straddle模式
function GJust.isFoceStraddleMode()
	local straddleTag = Single:gameModel():getStraddle()
	return straddleTag == FREE_STRADDLE
end

return GJust