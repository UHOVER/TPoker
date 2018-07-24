local GSelfData = {}

--延迟需要花费砖石
local _delayDiamond = 0
local _insureDelayDiamond = 0
local _cuoPaiDelayDiamond = 0
function GSelfData.setDelayDiamond(diamond)
	_delayDiamond = diamond
end
function GSelfData.getDelayDiamond()
	return _delayDiamond
end
--delayType default --喊注  1-喊注  2-保险  3-搓牌
function GSelfData.getDelayDiamondSet(delayType)
	--显示文字、按钮是否可用、字颜色
	local color = cc.c3b(166,254,255)
	local rets = {'免费', true}
	local diamond = Single:playerModel():getPDiaNum()
	local needDiamond = GSelfData.getDelayDiamond()
	if delayType == 1 then 
	elseif  delayType == 2 then 
		needDiamond = GSelfData.getInsureDelayDiamond()
	elseif  delayType == 3 then 
		needDiamond = GSelfData.setCuopaiDelayDiamond()
	end

	if needDiamond == 0 then
		--免费
	elseif needDiamond > diamond then 
		--不足
		color = cc.c3b(167,167,167)
		rets = {'不足', false}
	else
		--花费
		color = cc.c3b(166,254,255)
		rets = {needDiamond, true}
	end
	return rets,color
end

--设置保险延迟时间所需钻石
function GSelfData.setInsureDelayDiamond(diamond)
	_insureDelayDiamond = diamond
end
--获取保险延迟时间所需钻石
function GSelfData.getInsureDelayDiamond()
	return _insureDelayDiamond
end

--设置搓牌延迟时间所需钻石
function GSelfData.setCuopaiDelayDiamond(diamond)
	_cuoPaiDelayDiamond = diamond
end

--获取搓牌延迟时间所需钻石
function GSelfData.getCuopaiDelayDiamond(diamond)
	return _cuoPaiDelayDiamond
end


--自己没有坐下返回nil
function GSelfData.getMeRunPos()
	local mePlayer = GSelfData.getMePlayer()
	if mePlayer then
		print("mePos：",mePlayer:getRunPos())
		return mePlayer:getRunPos()
	end
	return nil
end


--自己没有坐下返回nil
function GSelfData.getMePlayer()
	local mePlayer = nil
	local players = Single:playerManager():getAllPlayers()
	for i=1,#players do
		if players[i]:isSelf() then
			mePlayer = players[ i ]
			break
		end
	end

	return mePlayer
end


--得到自己
function GSelfData.getSelfModel()
	local users = GameCtrol.getAllUsers()
	for i=1,#users do
		if users[ i ]:isSelf() then
			return users[i]
		end
	end
	return nil
end

--是否弃牌 以及 是否坐下
function GSelfData.isNotInGame()
	local user = GSelfData.getSelfModel()

	if not user  then 
		return false, false
	end
	local status = user:getStatus()
	local isSeat = user:isSeat()
	local isGiveStatus = (status == StatusCode.GAME_GIVEUP or status == StatusCode.GAME_WAIT_ING)
	
	return  isGiveStatus, isSeat
end
--自己是否坐下,没有坐下返回nil
function GSelfData.isHavedSeat()
	if GSelfData.getMePlayer() then
		return true
	end
	return false
end

return GSelfData