local GMath = {}

--底池公共扑克位置Y百分比
function GMath.getPoolCardPercentY(cType)
	if Single:gameModel():getGameNum() == GAME_NUM_SIX then
		if cType == POKER_Y_POKER then
			return 55
		elseif cType == POKER_Y_MSG then
			return 50
		elseif cType == POKER_Y_LOOK then
			return 55
		end

		return 55
	end
	return 42.58
end

--牌局提示信息y坐标(牌局名，大小忙、等)
function GMath.getPokerMsgPos(num)
	local firsty = GMath.getPoolCardPercentY(POKER_Y_MSG) / 100 * display.height - 78
	local rets = {}
	for i=1,num do
		local msgy = firsty - (i-1)*30
		table.insert(rets, msgy)	
	end

	return rets
end

--适配
function GMath.gameAdaptation(arrs)
	local function setY(changey, arrobjs)
		for i=1,#arrobjs do
			local obj = arrobjs[ i ]
			obj:setPositionY(obj:getPositionY() - changey)
		end
	end

	setY(G_SURPLUS_H * 0.66, arrs[3])
	setY(G_SURPLUS_H * 0.78, arrs[2])	
	setY(G_SURPLUS_H * 0.85, arrs[1])
end


--selflayer -1、暂停window -2
function GMath.getMaxZOrder()
	return 11
end


--自己运行特效值
--startV:90、endV:10、startRotate:325、endRotate:25
--nowV:endV~startV之间
function GMath.particleSelfValue(startV, endV, nowV, startR, endR)
	local startRotate = startR or 325
	local endRotate = endR or 25
	local percent = 1 - (nowV - endV) / (startV - endV)
	local rotate = (1 - percent) * (startRotate - endRotate) + endRotate

	return rotate
end


--别人运行特效值
--startV:100、endV:2、startRotate:360、endRotate:720
--nowV:endV~startV之间
function GMath.particleOtherValue(startV, endV, nowV)
	local percent = 1 - (nowV - endV) / (startV - endV)
	local rotate = 360 * percent + 360
	return rotate
end


function GMath.changeNumKW(num)
	num = tonumber(num)
	local retnum = num
	-- if num < 10000 then--0~万-1
	-- 	retnum = num
	-- elseif num < 10000000 then--万~千万-1
	-- 	local tnum1 = math.floor(num / 100)--10000去掉两个0
	-- 	local tnum2 = tnum1 / 10
	-- 	local tnum3 = tnum1 % 10
	-- 	if tnum3 == 0 then
	-- 		tnum2 = tnum2..'.0'
	-- 	end
	-- 	retnum = tnum2..'k'
	-- else--千万
	-- 	local tnum1 = math.floor(num / 100000)--10000000去掉两个0
	-- 	local tnum2 = tnum1 / 10
	-- 	local tnum3 = tnum1 % 10
	-- 	if tnum3 == 0 then
	-- 		tnum2 = tnum2..'.0'
	-- 	end
	-- 	retnum = tnum2..'w'
	-- end

	return retnum
end


--有可能0
function GMath.getNowMaxBet()
	local tusers = GameCtrol.getAllUsers()
	local maxBet = 0

	for i=1,#tusers do
		local tuser = tusers[ i ]
		if tuser:getBetNum() > maxBet then
			maxBet = tuser:getBetNum()
		end
	end

	--翻牌前
	if Single:gameModel():getRoundNum() == StatusCode.GAME_ROUND0 then
		local bigBlind = Single:gameModel():getBigBlind()
		if bigBlind > maxBet then
			maxBet = bigBlind
		end
	end

	return maxBet
end


--我需要补充的bet
function GMath.getMeNeedBet()
	-- local maxbet = GMath.getNowMaxBet()
	local maxbet = GData.getMaxBetNum()
	local sm = GSelfData.getSelfModel()

	if not sm then
		-- Single:checkGameData('| GMath.getMeNeedBet  sm is nil |')
		Single:appLogs('| GMath.getMeNeedBet  sm is nil |')
		return 0
	end
	local needbet = maxbet - sm:getBetNum()

	print("maxbet:"..maxbet, "sm:getBetNum():"..sm:getBetNum())
	if needbet < 0 then
		-- Single:checkGameData('| needbet is '..needbet..' |')
		Single:appLogs('| needbet is '..needbet..' |')
		return 0
	end
	assert(needbet>=0, 'getMeNeedBet '..needbet)

	return needbet
end


--最小的加注bet
function GMath.getMinAddBet()
	--[[--Fixed by 谭海亭 170412
		local gm = Single:gameModel()
		-- local poolNum = gm:getPoolNowBet()
		local sblind = gm:getSmallBlind()
		local mblind = sblind * 2
		-- local beforeBet = gm:getBeforeTalkBet()
		-- if poolNum == mblind + sblind then
		if GJust.isRoundFirstAddBet() then
			return 3 * sblind
		end
		local needbet = GMath.getMeNeedBet() * 2
		--加注小于大盲，返回大盲
		-- if needbet < sblind then
		if needbet < mblind then
			needbet = mblind
		end
		return needbet
	]]
	local gm = Single:gameModel()
	local bblind = gm:getBigBlind()
	local raiseVal = GData.getAvailableRaiseVal()
	if raiseVal < bblind then 
		print("ERROR: raiseVal 不能够比 大盲小", raiseVal, bblind)
	end

	return raiseVal
end


-- 获取等利的投保额度  EP(equal proflits等利)
-- outsNum out数量
-- poolNum 底池数量
function GMath.getNeedCostByEP(outsNum, poolNum)

	local oddVal = DZConfig.getOddsValue(outsNum)
	local inputVal = math.floor(poolNum / (oddVal + 1))
	return inputVal
end

-- 获取保本需要的投保额 BE(break-even保本） 
function GMath.getNeetCostByBE(outsNum, betNum)
	local oddVal = DZConfig.getOddsValue(outsNum)
	local inputVal = math.floor(betNum / oddVal)
	return inputVal
end




-- 获取发牌顺序  从dealerSeat下位开始发牌
function GMath.getDealOrder(dealSeat, inGameSeats)
	if #inGameSeats <= 0 then 
		print("无人在游戏中")
		return {}
	end

	if dealSeat < 1 or dealSeat > 9 then 
		print("dealerSeat 越界")
		return {}
	end

	local span = 9 - 1
	local startSeat, endSeat = dealSeat+1-1, dealSeat+1-1+span
	local seatOrder = {}
	for i = startSeat, endSeat do 
		local seatNo = i % 9 + 1
		if table.indexof(inGameSeats, seatNo) then 
			seatOrder[#seatOrder + 1] = seatNo
		end
	end
	return seatOrder
end













return GMath