local ResultCtrol = {}
--游戏模式类型1-标准 2-SNG 3-HEADUP 4-MTT
ResultCtrol.STARNDARD_TAG = 1
ResultCtrol.SNG_TAG = 2
ResultCtrol.HEADSUP_TAG = 3
ResultCtrol.MTT_TAG = 4

ResultCtrol.UNION_CREATE = 3
ResultCtrol.CLUB_CREATE = 1
ResultCtrol.PERSON_CREATE = 0
ResultCtrol.CIRCLE_CREATE = 2
ResultCtrol.SERVER_CREATE = 4

local function numberString(num)
	if num < 0 then
		return '-'..num
	end
	return '+'..num
end

--转换游戏模式为int类型
--TODO:这里的mod比较多余，应该使用 “DZConfig.changePokerType() ”转化,改动较多
local function convertGameModToInt(modString)
	local modInt = nil
	if modString == "general" then
		modInt = ResultCtrol.STARNDARD_TAG
	elseif modString == "sng" then
		modInt = ResultCtrol.SNG_TAG
	elseif modString == "headup" then
		modInt = ResultCtrol.HEADSUP_TAG
	elseif modString == "mtt" then
		modInt = ResultCtrol.MTT_TAG
	end
	if modInt == nil then 
		modInt = convertGameModToInt(DZConfig.changePokerType(modString))
	end
	return modInt
end

----------------------------------------------------
----
---- 牌局类型
----------------------------------------------------
--是否mtt比赛
function ResultCtrol.isMtt(mod)
	return mod == ResultCtrol.MTT_TAG;
end
--是否SNG比赛
function ResultCtrol.isSNG(mod)
	return mod == ResultCtrol.SNG_TAG
end

--是否HEADUP比赛
function ResultCtrol.isStandard(mod)
	return mod == ResultCtrol.STARNDARD_TAG
end

----------------------------------------------------
----
---- 牌局创建来源
----------------------------------------------------
function ResultCtrol.isPersonCreate(way)
	return way == ResultCtrol.PERSON_CREATE
end

function ResultCtrol.isClubCreate(way)
	return way == ResultCtrol.CLUB_CREATE
end

function ResultCtrol.isUnionCreate(way)
	return way == ResultCtrol.UNION_CREATE
end

function ResultCtrol.isOtherCreate(way)
	return way == ResultCtrol.CIRCLE_CREATE or way == ResultCtrol.SERVER_CREATE
end
----------------------------------------------------
----
---- present view addition conditions
----------------------------------------------------
--是否显示审核
--return  是否显示审核按钮， 是否是联盟管理员，是否mtt管理员
function ResultCtrol.isPresentAuthorize(createWay, gameMode, isAccess, isManager)
	local isUnion = ResultCtrol.isUnionCreate(createWay)
	local isClub = ResultCtrol.isClubCreate(createWay)
	local isMtt = ResultCtrol.isMtt(gameMode)
	local is_Access, isManager = isAccess, isManager
  
	local isGroupManager = (isUnion or isClub) and isManager
	local isMttManager = isMtt and isManager

	print("isUnion:",isUnion)
	print("isMtt:",isMtt)
	print("is_Access:",is_Access)
	print("isManager:",isManager)
	print("isGroupManager:",isGroupManager)
	print("isMttManager:",isMttManager)
	--授权赛且 （联盟的比赛管理员 or mtt比赛的管理员）
 	return is_Access and (isGroupManager or isMttManager), isGroupManager, isMttManager
end

--是否显示俱乐部统计
function ResultCtrol.isPresentClubStatistic(createWay, isManager, managerType)
	local isUnion = ResultCtrol.isUnionCreate(createWay)
	--联盟的比赛 并且 是管理员
	return isUnion and isManager
end

function ResultCtrol.getDataResult(data)
	local ret1 = {}
	local pokersNum = {123, 32}
	local probability1s = {40, 50}
	local probability2s = {40, 96}
	local allNums = {123, 342}

	-- local titles = {'标准局', 'SNG'}
	local title1s = {'个牌局', '场比赛', '场比赛'}
	local title2s = {'入池率', '入圈率', '入圈率'}
	local title3s = {'其中胜率', '投资回报率', '投资回报率'}
	local title4s = {'总手数', '参赛数', '参赛数'}
	local text11 = '入池率是扑克牌中一项重要的基础数据，通过玩家入'
	local text12 = '入圈率是扑克牌比赛中一项重要的基础数据，通过玩家'
	local text13 = '入圈率是扑克牌比赛中一项重要的基础数据，通过玩家'
	local text1s = {text11, text12, text13}
	local text21 = '局的频率，反映其打牌的松紧度。'
	local text22 = '进入奖励圈的频率，反映其比赛时的竞技程度。'
	local text23 = '进入奖励圈的频率，反映其比赛时的竞技程度。'
	local text2s = {text21, text22, text23}
	local feeStatus = {'参加标准牌局 总花费的记分牌。', '参加比赛总花费的记分牌。', '参加比赛总花费的记分牌。'}
	local feeText = {'总带入', '总报名费', '总报名费'}


	local function handleData(mtab, tdata, idx, tag)
		mtab['pokerNum'] = tdata['poker_num']

		mtab['probability1'] = tdata['into_rate'] * 100
		mtab['probability2'] = tdata['win_rate'] * 100

		--只有标准局用到--胜率进度条=胜率x入池率
		mtab['probability3'] = tdata['win_rate'] * tdata['into_rate'] * 100

		local maxLine = 600
		local minLine = 10
		local widthRate = 0
		if tag == ResultCtrol.STARNDARD_TAG then
			--(入池率-胜率)/2 + 胜率
			widthRate = (tdata['into_rate'] - tdata['win_rate']) / 2 + tdata['win_rate']
			--入池率==胜率
			if tdata['into_rate'] == tdata['win_rate'] then
				widthRate = tdata['into_rate'] / 2
			end
		elseif tag == ResultCtrol.SNG_TAG then
			--入圈率/2
			widthRate = tdata['into_rate'] / 2
		elseif tag == ResultCtrol.MTT_TAG then
			--入圈率/2
			widthRate = tdata['into_rate'] / 2
		end
		mtab['lineWidth'] = widthRate * maxLine		
		if mtab['lineWidth'] < 10 then
			mtab['lineWidth'] = 10
		end

		mtab['allNum'] = tdata['all_num']

		mtab['feeVal'] = tdata['all_bet']
		mtab['array1'] = tdata['max_cards']

		local pfr = tdata['PFR'] * 100
		local wtsd = tdata['WTSD'] * 100
		local af = tdata['AF'] * 100
		local c_bet = tdata['C_bet'] * 100
		local t_bet = tdata['Three_Bet'] * 100
		local steal = tdata['Steal'] * 100
		mtab['array2'] = {pfr, wtsd, af, c_bet, t_bet, steal}

		mtab['tag'] = tag
		mtab['text1'] = text1s[ idx ]
		mtab['text2'] = text2s[ idx ]
		-- mtab['title'] = titles[ idx ]
		mtab['title1'] = title1s[ idx ]
		mtab['title2'] = title2s[ idx ]
		mtab['title3'] = title3s[ idx ]
		mtab['title4'] = title4s[ idx ]
		mtab['feeText'] = feeText[ idx ]
		mtab['feeStatus'] = feeStatus[ idx ]
	end

	local sng = {}
	local general = {}
	local mtt = {}
	local statistics = data['statistics']

	for i=1,#statistics do
		if statistics[i]['poker_tag'] == 'sng' then
			handleData(sng, statistics[i], 2, ResultCtrol.SNG_TAG)
		elseif statistics[i]['poker_tag'] == 'general' then
			handleData(general, statistics[i], 1, ResultCtrol.STARNDARD_TAG)
		elseif statistics[i]['poker_tag'] == 'mtt' then
			handleData(mtt, statistics[i], 3, ResultCtrol.MTT_TAG)
		end
	end

	table.insert(ret1, general)	
	table.insert(ret1, sng)
	table.insert(ret1, mtt)

	local ret2 = {}
	ret2['AllBonus'] = data['sng_reward_all']
	ret2['first'] = data['first_num']
	ret2['second'] = data['second_num']
	ret2['third'] = data['third_num']
	ret2['mttRewardAll'] = data['mtt_reward_all']
	ret2['mttFinalNum'] = data['final_num']

	return ret1,ret2
end


--牌局详细信息
--oldData个人战绩界面穿过来的数据
--data服务器发过来的数据
function ResultCtrol.getResultMsgData(oldData, date)
	dump(oldData, "继承的数据")
	dump(date,"新数据")
	local tType = convertGameModToInt(date.game_mod or date.pokerType)

	local ret1 = {}
	ret1['mod'] = tType --牌局类型
	ret1['game_mod'] = date.game_mod
	ret1['secure'] = oldData.secure  --保险是否开启了
	ret1['title'] = oldData.name     --牌局的名字
	ret1['myName'] = date['create_user_name']--创建者的名字
	ret1['headUrl'] = oldData.headUrl  --用户头像地址
	ret1['time'] = oldData.timeStr      --创建时间
	ret1['pokerText'] = oldData.pokerText --牌局类型
	ret1['insurance_pool_all'] = date.insurance_pool_all --保险池
	ret1['is_manager'] = date['is_manager'] and date['is_manager'] > 0 --是否是管理员 			
	ret1['is_access'] = date['is_access'] and date['is_access'] > 0 --是否授权
	ret1['manager_type'] = date['manager_type'] --管理员类型
	ret1['create_way'] = date['create_way'] 
	--test
	-- ret1['create_way'] =  ResultCtrol.UNION_CREATE
	-- ret1['is_manager'] = true
	-- ret1['is_access'] = true
	-- ret1['manager_type'] = 3
	
	-- ret1['pokerCode'] = '牌局编号:'..oldData.pid
	ret1['pokerFrom'] = '来自'..date['from']

	local tTime = DZTime.secondsConvertToTime(tonumber(date.time))
	local hour = tTime['hour']
	local min = tTime['minute']

	ret1['pokerTime'] = hour.."小时"..min.."分钟"
	if hour <= 0 then
		if(min <= 0) then
			ret1['pokerTime'] = "小于1分钟"
		else
			ret1['pokerTime'] = min.."分钟"
		end
	end

	ret1['allNum'] = date.all_num
	ret1['allBet'] = date.into_bet

	--求出带入最多的key
	local dayuKey = 1
	local maxSpend = -1
	for i=1,#date.players do
		--test
		--local score = i - 5
		if(tonumber(date.players[i].spends) > maxSpend) then
			maxSpend = date.players[i].spends
			dayuKey = i
		end
	end

	local pNum = 1
	--根据模式sng-2判断输出数据
	ret1['resultArr'] = {}
	ret1['urls'] = {}
	if tType == ResultCtrol.SNG_TAG or tType == ResultCtrol.MTT_TAG then
		ret1['betNum'] = oldData.fee
		ret1['bmfee'] = oldData.bmfee
		ret1['entry_fee_sum'] = date.entry_fee_sum
		ret1['add_on'] = date.add_on
		ret1['rebuy_num'] = date.rebuy_num
		ret1['inital_score_sum'] = date.inital_score_sum
		ret1['from'] = oldData.from--来自哪
		
		--如果是sng根据2人赢1 6人赢2 9人赢3的规则分配显示数据
		if #date.players == 2 then
			pNum = 2
			table.insert(ret1['resultArr'], date.players[1].name)
			table.insert(ret1['resultArr'], date.players[2].name)
			table.insert(ret1['resultArr'], date.players[2].name)
			table.insert(ret1['urls'], date.players[1].h_url)
			table.insert(ret1['urls'], date.players[2].h_url)
			table.insert(ret1['urls'], date.players[2].h_url)
		--elseif #date.players == 6 then
		elseif #date.players > 2 and #date.players <= 6 then
			pNum = 6
			table.insert(ret1['resultArr'], date.players[1].name)
			table.insert(ret1['resultArr'], date.players[2].name)
			
			table.insert(ret1['urls'], date.players[1].h_url)
			table.insert(ret1['urls'], date.players[2].h_url)
			if(tType == 4) then
				table.insert(ret1['urls'], date.players[3].h_url)
				table.insert(ret1['resultArr'], date.players[3].name)
			else
				table.insert(ret1['urls'], date.players[#date.players].h_url)
				table.insert(ret1['resultArr'], date.players[#date.players].name)
			end
		--elseif #date.players == 9 then
		elseif #date.players > 6 then
			pNum = 9
			table.insert(ret1['resultArr'], date.players[1].name)
			table.insert(ret1['resultArr'], date.players[2].name)
			table.insert(ret1['resultArr'], date.players[3].name)
			table.insert(ret1['urls'], date.players[1].h_url)
			table.insert(ret1['urls'], date.players[2].h_url)
			table.insert(ret1['urls'], date.players[3].h_url)
		end
	else
		ret1['betNum'] = oldData.betNum

		if #date.players == 1 then
			pNum = 1
			table.insert(ret1['resultArr'], date.players[1].name)
			table.insert(ret1['urls'], date.players[1].h_url)
		elseif #date.players == 2 then
			pNum = 2
			table.insert(ret1['resultArr'], date.players[1].name)
			table.insert(ret1['resultArr'], date.players[dayuKey].name)
			table.insert(ret1['resultArr'], date.players[#date.players].name)
			table.insert(ret1['urls'], date.players[1].h_url)
			table.insert(ret1['urls'], date.players[dayuKey].h_url)
			table.insert(ret1['urls'], date.players[#date.players].h_url)
		elseif #date.players >= 3 then
			pNum = 3
			table.insert(ret1['resultArr'], date.players[1].name)
			table.insert(ret1['resultArr'], date.players[dayuKey].name)
			table.insert(ret1['resultArr'], date.players[#date.players].name)
			table.insert(ret1['urls'], date.players[1].h_url)
			table.insert(ret1['urls'], date.players[dayuKey].h_url)
			table.insert(ret1['urls'], date.players[#date.players].h_url)
		end
	end

	--初始化站台人物数量
	ret1['showPNum'] = pNum
	
	local ret2 = {}
	for i=1,#date.players do
		--test
		--local score = i - 5
		local tab = {}
		tab['pheadUrls'] = date.players[i].h_url
		tab['name'] = date.players[i].name
		tab['insurance_pool'] = date.players[i].insurance_pool
		tab["playerID"] = date.players[i].id
		tab["spends"] = date.players[i].spends
		tab["add_on"] = date.players[i].add_on
 		tab["rebuy_num"] = date.players[i].rebuy_num

 		if(tab["add_on"] == nil) then
 			tab["add_on"] = 0
 		end

 		if(tab["rebuy_num"] == nil) then
 			tab["rebuy_num"] = 0
 		end
 		
		--根据模式sng-2判断输出数据
		if tType == 2 then
			tab['betText'] = ''
		else
			tab['betText'] = '带入 '..date.players[i].spends
		end
		
		tab['scoring'] = date.players[i].bet_num

		table.insert(ret2, tab)
	end

	return ret1,ret2
end


--服务器：年月日、时分
function ResultCtrol.getRecordResult(data)
	local rets = {}
	local times = DZTime.getSystemTime()

	local years = {2016, 2016, 2016, 2012, 2013, 2014, 2015, 2010, 2009, 2010}
	local months = {6, 1, 1, 2, 3, 4, 10, 12, 12, 9}
	local days = {14, 11, 11, 12, 13, 24, 10, 12, 12, 29}
	
	local pokerType = {'标准局', 'SNG', '单挑', 'MTT'}
	local pokerImg = {'result/result_tag1.png', 'result/result_tag2.png', 'result/result_tag3.png', 'result/result_tag4.png'}
	local tagImg1s = {'result/result_bet.png', 'result/result_person.png', 'result/result_bet.png', 'result/result_person.png'}
	local tagImg2s = {'result/result_clock.png', '', 'result/result_person.png', ''}

	local befTime = -1
	local tab = {}
	local allBet = data.all_bet
	if allBet > 0 then
		allBet = '+'..allBet
	end

	tab['allBet'] = allBet
	tab['sortTag'] = times['year'] * 1000 + times['month'] * 100 + times['day'] + 10000
	table.insert(rets, tab)

	--print("m===="..#data.histories)

	for i=1,#data.histories do
		--时间
		local tTime = os.date("*t", data.histories[i].start_time)
		local hour = tTime['hour']
		local min = tTime['min']
		local tYear = tTime['year']
		--排序tag
		local month = data.histories[i].start_month
		local day = data.histories[i].start_day
		local befTime = month * 100 + day 
		local timeStr = string.format("%02d/%02d/%02d:%02d",month,day,hour,min)
		--时间2
		local monthText = month..'月'
		local dayText = day..'日'
		local tYearText = tYear..'年'
		if year == times['year'] and month == times['month'] and day == times['day'] then
			monthText = ''
			dayText = '今天'
			tYearText = ""
		end

		local title = string.format("%02d:%02d    来自%s", hour, min, data.histories[i].from)
		if(string.len(title) >= 26) then
			title = StringUtils.getShortStr(title, 25).."的牌局"
		end

		local ctype = convertGameModToInt(data.histories[i].mod)
		local tab = {}
		--牌局id
		tab['pid'] = data.histories[i].id
		tab['typeMod'] = ctype
		tab['pokerType'] = data.histories[i].mod

		tab['title'] = title
		--tab['sortTag'] = year * 1000 + month * 100 + day
		tab['sortTag'] = befTime
		tab['monthText'] = monthText
		tab['dayText'] = dayText
		tab['yearText'] = tYearText
	-- tab['timeStr'] = monthStr..'/'..dayStr..'/'..hour..':'..min
		tab['timeStr'] = timeStr
		-- tab['pokerText'] = '来自'..data.histories[i].from..'的牌局'
		tab['pokerText'] = ''
	
		tab['name'] = data.histories[i].name
		tab['name'] = StringUtils.getShortStr( tab['name'], 18)
		tab['headUrl'] = data.histories[i].c_hurl

		tab['fromWhere'] = "来自 "..data.histories[i].from
		tab['from'] = data.histories[i].from

		tab['typeText'] = pokerType[ ctype ]
		tab['typeImg'] = pokerImg[ ctype ]

		--num bet
		local numbet = data.histories[i].result_bet
		local imgPath = 'result/result_numbg1.png'
		if numbet > 0 then
			imgPath = 'result/result_numbg3.png'
			numbet = '+'..numbet
		elseif numbet < 0 then
			imgPath = 'result/result_numbg2.png'
		end
		tab['numbetImg'] = imgPath
		tab['numbet'] = numbet

		--标示
		local text1 = i
		local text2 = i


		if ctype == ResultCtrol.STARNDARD_TAG then
			text1 = (data.histories[i].d_blind/2)..'/'..data.histories[i].d_blind
			text2 = string.format("%.1f", (data.histories[i].d_time/3600))..'个小时局'
		elseif ctype == ResultCtrol.SNG_TAG then
			text1 = data.histories[i].d_pnum..'/'..data.histories[i].d_pnum
			local tmp = data.histories[i].d_fee
			text2 = ''..tmp..'+'..tmp/10
		elseif ctype == ResultCtrol.HEADSUP_TAG then
			text1 = (data.histories[i].d_blind/2)..'/'..data.histories[i].d_blind
			text2 = data.histories[i].d_pnum..'/'..data.histories[i].d_pnum
		elseif ctype == 4 then
			text1 = data.histories[i].d_pnum
			local tmp = data.histories[i].d_fee
			text2 = ''..tmp..'+'..tmp/10
		end

		tab['textTag1'] = text1
		tab['textTag2'] = text2
		tab['imgTag1'] = tagImg1s[ctype]
		tab['imgTag2'] = tagImg2s[ctype]

		tab['betNum'] = "盲注: "..(data.histories[i].d_blind/2)..'/'..data.histories[i].d_blind
		
		local tmp = data.histories[i].d_fee
		text2 = '报名费: '..tmp..'+'..tmp/10
		tab['fee'] = text2
		tab['bmfee'] = tmp
		tab['secure'] = data.histories[i].secure
		tab['start_time'] = data.histories[i].start_time
		table.insert(rets, tab)
	end
	--DZSort.sortTables(rets, StatusCode.UN_SORT, 'sortTag')
	return rets
end

--2分页用到
function ResultCtrol.getRecordResult2(data)
	local rets = {}
	local times = DZTime.getSystemTime()

	local years = {2016, 2016, 2016, 2012, 2013, 2014, 2015, 2010, 2009, 2010}
	local months = {6, 1, 1, 2, 3, 4, 10, 12, 12, 9}
	local days = {14, 11, 11, 12, 13, 24, 10, 12, 12, 29}

	local pokerType = {'标准局', 'SNG', '单挑', 'MTT'}
	local pokerImg = {'result/result_tag1.png', 'result/result_tag2.png', 'result/result_tag3.png', 'result/result_tag4.png'}
	local tagImg1s = {'result/result_bet.png', 'result/result_person.png', 'result/result_bet.png', 'result/result_person.png'}
	local tagImg2s = {'result/result_clock.png', '', 'result/result_person.png', ''}

	local befTime = -1
	local tab = {}

	tab['sortTag'] = times['year'] * 1000 + times['month'] * 100 + times['day'] + 10000

	for i=1,#data.histories do
		local tab = {}

		--处理时间搓
		--print("sssssjjjjccccc==="..data.histories[i].start_time)
		--local tTime = DZTime.secondsConvertToTime(data.histories[i].start_time)
		local tTime = os.date("*t", data.histories[i].start_time)
		local hour = tTime['hour']
		local min = tTime['min']
		local tYear = tTime['year']
		tab['yearText'] = tYear.."年"
		local ctype = 1
		--重新设置牌局类型
		if data.histories[i].mod == "general" then
			ctype = 1
		elseif data.histories[i].mod == "sng" then
			ctype = 2
		elseif data.histories[i].mod == "headup" then
			ctype = 3
		elseif data.histories[i].mod == "mtt" then
			ctype = 4
		end

		tab['typeMod'] = ctype

		--print("tttt==="..10.3/3)
		
		local numbet = data.histories[i].result_bet


		if hour < 10 then
			hour = '0'..hour
		end
		if min < 10 then
			min = '0'..min
		end

		local month = data.histories[i].start_month
		local day = data.histories[i].start_day
		--local year = years[ i ]

		--tab['sortTag'] = year * 1000 + month * 100 + day
		tab['sortTag'] = month * 100 + day

		--小于10的月份用0补齐
		local monthStr = nil
		monthStr = tostring(month)

		if month < 10 then
			monthStr = '0'..month
		end

		--小于10的天用0补齐
		local dayStr = nil
		dayStr = tostring(day)

		if day < 10 then
			dayStr = '0'..day
		end

		tab['timeStr'] = monthStr..'/'..dayStr..'/'..hour..':'..min
		local monthText = month..'月'
		local dayText = day..'日'
		if year == times['year'] and month == times['month'] and day == times['day'] then
			monthText = ''
			dayText = '今天'
		end

		--[[
		if befTime == tab['sortTag'] then
			monthText = ''
			dayText = ''
		end
		]]
		befTime = tab['sortTag']
		--牌局id
		tab['pid'] = data.histories[i].id

		tab['monthText'] = monthText
		tab['dayText'] = dayText

		tab['title'] = hour..':'..min..'    '..'来自'..data.histories[i].from
		if(string.len(tab['title']) >= 26) then
			tab['title'] = StringUtils.getShortStr( tab['title'], 25).."的牌局"
		end
		-- tab['pokerText'] = '来自'..data.histories[i].from..'的牌局'
		tab['pokerText'] = ''

		tab['name'] = data.histories[i].name
		tab['name'] = StringUtils.getShortStr( tab['name'], 18)
		tab['pokerType'] = data.histories[i].mod
		tab['headUrl'] = data.histories[i].c_hurl

		tab['fromWhere'] = "来自 "..data.histories[i].from--
		tab['from'] = data.histories[i].from --是什么方式创建的牌局

		tab['typeText'] = pokerType[ ctype ] 
		tab['typeImg'] = pokerImg[ ctype ]

		--num bet
		local img = 'result/result_numbg1.png'
		if numbet > 0 then
			img = 'result/result_numbg3.png'
			numbet = '+'..numbet
		elseif numbet < 0 then
			img = 'result/result_numbg2.png'
		end
		tab['numbetImg'] = img
		tab['numbet'] = numbet

		--标示
		local text1 = i
		local text2 = i


		if ctype == ResultCtrol.STARNDARD_TAG then
			text1 = (data.histories[i].d_blind/2)..'/'..data.histories[i].d_blind
			text2 = string.format("%.1f", (data.histories[i].d_time/3600))..'个小时局'
		elseif ctype == ResultCtrol.SNG_TAG then
			text1 = data.histories[i].d_pnum..'/'..data.histories[i].d_pnum
			local tmp = data.histories[i].d_fee
			text2 = ''..tmp..'+'..tmp/10
		elseif ctype == ResultCtrol.HEADSUP_TAG then
			text1 = (data.histories[i].d_blind/2)..'/'..data.histories[i].d_blind
			text2 = data.histories[i].d_pnum..'/'..data.histories[i].d_pnum
		elseif ctype == 4 then
			text1 = data.histories[i].d_pnum
			local tmp = data.histories[i].d_fee
			text2 = ''..tmp..'+'..tmp/10
		end

		tab['textTag1'] = text1
		tab['textTag2'] = text2
		tab['imgTag1'] = tagImg1s[ctype]
		tab['imgTag2'] = tagImg2s[ctype]

		tab['betNum'] = "盲注: "..(data.histories[i].d_blind/2)..'/'..data.histories[i].d_blind
		
		local tmp = data.histories[i].d_fee
		text2 = '报名费 '..tmp..'+'..tmp/10
		tab['fee'] = text2
		tab['bmfee'] = tmp
		tab['secure'] = data.histories[i].secure
		tab['start_time'] = data.histories[i].start_time
		table.insert(rets, tab)
	end

	--DZSort.sortTables(rets, StatusCode.UN_SORT, 'sortTag')

	return rets
end


function ResultCtrol.dataStatistics(funcBack)
	local function response(data)
		print_f(data)
        funcBack(data)
    end
    local tab = {}
    tab["uid"] = Single:playerModel():getId()
    MainCtrol.filterNet(PHP_PERSONAL_STATS, tab, response, PHP_POST)
end


function ResultCtrol.recordStatistics(funcBack)
	local function response(data)
        funcBack(data)
    end
    local tab = {}
    --分页处理
    tab['page'] = 1 --是int页数(从1开始)
    tab['every_page'] = 15 -- 是	int	每页多少条
    MainCtrol.filterNet(PHP_PERSON_RECORD, tab, response, PHP_POST)
end


function ResultCtrol.recordStatisticsMsg(funcBack, pid)
	local function response(data)
        funcBack(data)
    end
    local tab = {}
    tab['p_id'] = pid
    --tab['p_id'] = 5553 --普通
    --tab['p_id'] = 5816 --sng
    --tab['count'] = 9
    MainCtrol.filterNet(PHP_PERSON_RECORD_DETAIL, tab, response, PHP_POST)
end

--mtt请求详情
function ResultCtrol.recordStatisticsMsgMtt(funcBack, pid)
	local function response(data)
        funcBack(data)
    end
    local tab = {}
    tab['mtt_id'] = pid
    MainCtrol.filterNet("personMttRecordDetail", tab, response, PHP_POST)
end
--------------------------------------------------------------------------------------------------------------------------------------------
--联盟审核 + 俱乐部统计 + 保险
----------------------------------------------------------------------------------------------------------------

--非MTT 战绩审核列表（俱乐部列表）
-- tid --牌局id
-- mType --管理员类型
-- ctrlSource --操作 来 源 	1.club statistic 2.authorize data 3 insurance data
-- funcback --回调
function ResultCtrol.sendRequireClubList(pid,mod,mType,ctrlSource,funcBack)
	local function response(data)
		funcBack(data)
	end
	local tab = {}
	tab['tid'] = pid
	tab['manager_type'] = mType
	tab['from'] = ctrlSource
	tab['game_mod'] = mod
	print("game_mod:"..mod)
	XMLHttp.requestHttp(PHP_AUDIT_RECORD_LIST,tab, response, PHP_POST)
end

--获取所有的管理员
--tid 牌局id
--club_id 俱乐部id
function ResultCtrol.sendRequireAdmins(tid,mod, clubId, funcback)
	local function response(data)
		funcback(data)
	end
	local tab = {}
	tab['tid'] = tid
	tab['club_id'] = clubId
	tab['game_mod'] = mod
	dump(tab, "tab参数")
	XMLHttp.requestHttp(PHP_GET_ALL_ADMIN,tab, response, PHP_POST)
end

--非MTT获取所有的审核详情
--tid 牌局id
--clubid 俱乐部id
--u_no 需要搜索的管理员id号
--page 当前页数
--every_page 每页显示多少
function ResultCtrol.sendSearchAuthorizeDetails(tid, mod, clubId, ctlsrc, u_no, curPage, funcback,noWait)
	local function response(data)
		funcback(data['data'])
	end
	local tab = {}
	tab['tid'] = tid
	tab['club_id'] = clubId
	tab['u_no'] = u_no
	tab['page'] = curPage
	tab['every_page'] = 25
	tab['game_mod'] = mod
	tab['from'] = ctlsrc
	XMLHttp.requestHttp(PHP_AUDIT_RECORD_DETAIL,tab, response, PHP_POST,noWait)
end

--非MTT查看俱乐部统计
--tid 牌局
--clubId俱乐部id
--curPage
function ResultCtrol.sendRequireStatistic(tid,mod, clubId, isInsure,curPage,funcback, noWait)
	local function response(data)
		funcback(data)
	end
	local tab = {}
	tab['tid'] = tid
	tab['club_id'] = clubId
	tab['page'] = curPage
	tab['every_page'] = 25
	tab['game_mod'] = mod
	tab['from'] = isInsure
	XMLHttp.requestHttp(PHP_CLUB_STATSITIC,tab, response, PHP_POST, noWait)
end

--俱乐部查看相关人员的保险情况
--tid
--clubId
function ResultCtrol.sendPersonInsurance(tid, clubId,funcback)
	local function response(data)
		funcback(data)
	end
	local tab = {}
	tab['tid'] = tid
	tab['club_id'] = clubId
	-- tab['page'] = curPage
	-- tab['every_page'] = 25
	XMLHttp.requestHttp(PHP_USER_INSURACE_VAL,tab, response, PHP_POST)
end




return ResultCtrol