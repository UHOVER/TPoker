local GText = {}

--大的类型：sng、standard、mtt
cc.exports.GAME_BIG_TYPE_STANDARD 	= 'game_general'
cc.exports.GAME_BIG_TYPE_SNG 		= 'game_sng'
cc.exports.GAME_BIG_TYPE_MTT 		= 'game_mtt'

cc.exports.GAME_SCENE_NODE 			= 'GAME_SCENE_NODE_NAME'

--游戏人数
cc.exports.GAME_NUM_NINE	= 9			--9人游戏
cc.exports.GAME_NUM_SIX		= 6			--6人游戏
cc.exports.GAME_NUM_TWO		= 2			--2人游戏
cc.exports.GAME_NUM_THREE   = 3			--3人游戏
cc.exports.GAME_NUM_FOUR 	= 4		    --4人
cc.exports.GAME_NUM_FIVE	= 5			--5人
cc.exports.GAME_NUM_SEVEN   = 7         --7人
cc.exports.GAME_NUM_EIGHT   = 8  		--8人

--底池公共牌 y 坐标为基准
cc.exports.POKER_Y_POKER 	= 1			--底池公共牌 y 位置
cc.exports.POKER_Y_MSG	 	= 2			--牌局提示信息(如牌局名) y 位置
cc.exports.POKER_Y_LOOK	 	= 3			--发发看 y 位置提示

--mtt
--最大重构次数(无线)
cc.exports.AGAIN_LIMITLESS 		= 10000		--mtt重构无限

--straddle标示
cc.exports.NO_STRADDLE		= 0 		--无straddle
cc.exports.FREE_STRADDLE	= 2 		--自由straddle
cc.exports.MUST_STRADDLE	= 1 		--强制straddle


function GText.authorizeText()
	local msg = ''
	if Single:gameModel():isOpenApplay() then
		msg = '控制带入已开启'
	end
	return msg
end


--提示玩家信息
function GText.promptMsg()
	local msg = ''
	local isHaveNull = false

	local tusers = GameCtrol.getAllUsers()
	local mdata = GSelfData.getSelfModel()
	local limitNum = Single:gameModel():getGameNum()
	local gamem = Single:gameModel()

	--我没用坐下并且有空座
	if #tusers < limitNum and not mdata then 
		isHaveNull = true
	end

	if isHaveNull then
		msg = '点击坐下'
	elseif not gamem:isStarting() then
		--确保已经坐下了
		msg = '等待房主开始'
		if gamem:isManager() then
			msg = '请开始游戏'
		end
	end

	return msg
end

--牌局信息
local _pokerMsg = {}
function GText.clearPokerMsg()
	_pokerMsg = {}
	local msgtypes = {
		StatusCode.PROMPT_NAME, StatusCode.PROMPT_BLIND, StatusCode.PROMPT_CODE, StatusCode.PROMPT_ANTE,
		StatusCode.PROMPT_INSURE, StatusCode.PROMPT_AUTHOR, StatusCode.PROMPT_UPTIME, StatusCode.PROMPT_GPS_IP,
		StatusCode.PROMPT_STRADDLE
	}
	for i=1,#msgtypes do
		local tab = {}
		tab['msgType'] = msgtypes[ i ]
		tab['msgText'] = ''
		tab['sortTag'] = 100
		table.insert(_pokerMsg, tab)
	end
end
function GText.setPokerMsg(msgType, msgText)
	--注意：false
	if not msgText then
		return
	end

	if msgType == StatusCode.PROMPT_BLIND then
		local small = msgText / 2
		msgText = '盲注：'..small..'/'..msgText
	elseif msgType == StatusCode.PROMPT_CODE then
		msgText = '分享码：'..msgText
	elseif msgType == StatusCode.PROMPT_ANTE then
		msgText = 'ANTE：'..msgText
	elseif msgType == StatusCode.PROMPT_INSURE then
		msgText = '保险模式'
	elseif msgType == StatusCode.PROMPT_AUTHOR then
		if msgText == '' then
			msgText = ''
		else
			msgText = '控制带入已开启'
		end
	elseif msgType == StatusCode.PROMPT_UPTIME then
		local ttext = DZTime.secondsToMinText(msgText)
		msgText = '升盲时间：'..ttext
	elseif msgType == StatusCode.PROMPT_GPS_IP then
		local isIP = Single:gameModel():isLimitIP()
		local isGPS = Single:gameModel():isLimitGPS()
		--都没有开启
		if not isIP and not isGPS then return end

		if isIP and isGPS then
			msgText = 'IP 限制 及 GPS 限制'
		elseif isIP then
			msgText = 'IP 限制'
		elseif isGPS then
			msgText = 'GPS 限制'
		end

	elseif msgType == StatusCode.PROMPT_STRADDLE then
		local straddle = Single:gameModel():getStraddle()
		if straddle == NO_STRADDLE then 
			GText.clearTextByType(msgType)
			return
		elseif straddle == FREE_STRADDLE then 
			msgText = '自由Straddle'
		elseif straddle == MUST_STRADDLE then 
			msgText = '强制Straddle'
		end
	end


	for i=1,#_pokerMsg do
		local msg = _pokerMsg[ i ]
		--有更新
		if msg['msgType'] == msgType then
			msg['msgText'] = msgText
			msg['sortTag'] = msgType
			break
		end
	end
end	

function GText.clearTextByType(textType)
	for i=1,#_pokerMsg do
		if textType == _pokerMsg[i]['msgType'] then
			_pokerMsg[i]['msgText'] = ''
			_pokerMsg[i]['sortTag'] = 100
			break
		end
	end	
end

function GText.getPokerMsg()
	DZSort.sortTables(_pokerMsg, StatusCode.SORT, 'sortTag')
	return _pokerMsg
end


--得到回合名通过回合号
function GText.getRoundNameByNum(num)
	local retName = ''
	if num == StatusCode.GAME_ROUND1 then
		retName = '翻牌圈'
	elseif num == StatusCode.GAME_ROUND2 then
		retName = '转牌圈'
	elseif num == StatusCode.GAME_ROUND3 then
		retName = '河牌圈'
	end
	return retName
end


--得到下一个回合名
function GText.getNextRoundName()
	local num = Single:gameModel():getRoundNum()

	local retName = ''
	if num == StatusCode.GAME_ROUND0 then
		retName = '翻牌'
	elseif num == StatusCode.GAME_ROUND1 then
		retName = '转牌'
	elseif num == StatusCode.GAME_ROUND2 then
		retName = '河牌'
	end
	return retName
end

--得到straddle模式
function GText.getStraddleModeAlia(originMode, destMode)
	-- local straddle = Single:gameModel():getStraddle()
	local staddleName = ""
	if destMode == NO_STRADDLE then 
		-- staddleName = "房主关闭straddle" 
		if originMode == FREE_STRADDLE then  -- free -> nothing
			staddleName = "房主关闭自由straddle" 
		elseif originMode == MUST_STRADDLE then -- must -> nothing
			staddleName = "房主关闭强制straddle"
		end
		
	elseif destMode == FREE_STRADDLE then 
		staddleName = "房主开启自由straddle"
	elseif destMode == MUST_STRADDLE then 
		staddleName = "房主开启强制straddle"
	end
	return staddleName
end

return GText