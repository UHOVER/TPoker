local PokerType = {}
local DZSort = require 'utils.DZSort'

local POKER_TYPE_0 		= '空'
local POKER_TYPE_1 		= '皇家同花顺'
local POKER_TYPE_2 		= '同花顺'
local POKER_TYPE_3 		= '四条'
local POKER_TYPE_4 		= '葫芦'
local POKER_TYPE_5 		= '同花'
local POKER_TYPE_6 		= '顺子'
local POKER_TYPE_7 		= '三条'
local POKER_TYPE_8 		= '两对'
local POKER_TYPE_9 		= '一对'
local POKER_TYPE_10 	= '高牌'

local function convertPokerToInt(ptype)
	if ptype == POKER_TYPE_0 then return -1 end
	if ptype == POKER_TYPE_1 then return 1 end
	if ptype == POKER_TYPE_2 then return 2 end
	if ptype == POKER_TYPE_3 then return 3 end
	if ptype == POKER_TYPE_4 then return 4 end
	if ptype == POKER_TYPE_5 then return 5 end
	if ptype == POKER_TYPE_6 then return 6 end
	if ptype == POKER_TYPE_7 then return 7 end
	if ptype == POKER_TYPE_8 then return 8 end
	if ptype == POKER_TYPE_9 then return 9 end
	if ptype == POKER_TYPE_10 then return 10 end
end
--转换
local function change_array(array)
	local temps = {}
	for i=1,#array do
		local temp = {}
		temp['pos'] = i
		temp['eleNum'] = array[ i ]
		temp['changeNum'] = array[ i ]
		table.insert(temps, temp)
	end

	for i=1,#temps do
		local eleNum = temps[ i ]['eleNum'] % 13
		if eleNum == 0 then
			eleNum = 13
		end

		--1~13
		temps[ i ]['changeNum'] = eleNum

		--A 2~14
		if eleNum == 1 then
			eleNum = 14
		end
		temps[ i ]['ANum'] = eleNum
	end
	return temps
end

--位置数组
local function get_pos_array(array, changes)
	local temps = {}
	for i=1,#array do
		for j=1,#changes do
			if changes[ j ]['pos'] == i then
				table.insert(temps, array[ i ])
				break
			end
		end
	end

	return temps
end

--核查数组
local function check_array(array)
	if #array < 2 or #array > 7 then
		local str = ''
		for i=1,#array do
			str = str..'--'..array[i]
		end
		ViewCtrol.showMsg(str, 5)

		if #array == 0 then
			assert(nil, 'check_array 0')
		elseif #array < 2 then
			Single:requestGameDataAgain()
			assert(nil, 'check_array array < 2  ||'..str..'||')
		elseif #array > 7 then
			Single:requestGameDataAgain()
			assert(nil, 'check_array array > 7    '..str)
		end
	end

	for i=1,#array do
		if array[i] < 1 or array[i] > 52 then
			assert(nil, 'check_array1 1 52')
		end

		if i == #array then break end

		for j=i+1,#array do
			if array[i] == array[j] then
				assert(nil, 'check_array1 repeat')
			end
		end
	end
end


--对子1~3个 确保没有三条
--tag: one 返回一对如果有多个返回较大一个、two 返回两队 如有多个返回较大两个
local function get_num_pairs(array, tag)
	local rets = {}
	if #array < 2 then return POKER_TYPE_0,rets end

	local temps = change_array(array)
	DZSort.sortTables(temps, StatusCode.SORT, 'changeNum')

	local results = {}
	for i=1,#temps do
		if i > #temps - 1 then
			break
		end

		if temps[ i ]['changeNum'] == temps[ i+1 ]['changeNum'] then
			table.insert(results, temps[ i ])
			table.insert(results, temps[ i+1 ])
		end
	end

	--对子是双数
	if #results % 2 ~= 0 then
		assert(nil, 'get_num_pairs1')
	end

	--没有对子
	if #results == 0 then
		return POKER_TYPE_0,rets
	end

	--一个对子
	if #results == 2 then
		return POKER_TYPE_9,get_pos_array(array, results)
	end

	--有两个或三个对子:只取大的两个对
	DZSort.sortTables(results, StatusCode.UN_SORT, 'ANum')
	local len = 4
	if tag == 'one' then
		len = 2	
	elseif tag == 'two' then
		len = 4
	end

	local changes = {}
	for i=1,len do
		table.insert(changes, results[i]['eleNum'])
	end

	return POKER_TYPE_8,changes
end


--三条1~2 一定不是四条了
local function three_of_a_kind(array)
	local rets = {}
	if #array < 3 then return POKER_TYPE_0,rets end

	local temps = change_array(array)
	DZSort.sortTables(temps, StatusCode.SORT, 'changeNum')

	local results = {}
	for i=1,#temps do
		if i > #temps - 2 then
			break
		end

		local arrs = {}
		local bef = temps[ i ]['changeNum']
		table.insert(arrs, temps[ i ])

		for j=i+1,i+2 do
			if bef == temps[ j ]['changeNum'] then
				table.insert(arrs, temps[ j ])
			end
		end

		--三条
		if #arrs == 3 then
			for k=1,#arrs do
				table.insert(results, arrs[ k ])
			end
		end
	end

	if #results == 0 then
		return POKER_TYPE_0,rets
	end

	rets = get_pos_array(array, results)
	return POKER_TYPE_7,rets
end


--顺子
local function get_straight(array)
	local rets = {}
	if #array < 5 then return rets end

	local temps = change_array(array)

	--去掉重复：黑1 黑2 黑3 黑4 黑5，红1 可能去掉了 黑1
	DZSort.sortTables(temps, StatusCode.SORT, 'changeNum')
	local repeatv = ''
	for i=#temps,1,-1 do
		if repeatv == temps[ i ]['changeNum'] then
			table.remove(temps, i)
		end

		repeatv = temps[ i ]['changeNum']
	end
	if #temps < 5 then return rets end


	local function judgeType(arrs)
		local len = #arrs - 5 + 1

		--5、6、7
		for i=1,len do
			local changes = {}
			local value = arrs[ i ]['changeNum']
			table.insert(changes, arrs[i])

			for j=i+1,#arrs do
				local cnum = arrs[ j ]['changeNum']
				if cnum == value + 1 then
					value = cnum
					table.insert(changes, arrs[j])
				else
					break
				end
			end

			if #changes >= 5 then
				return changes
			end
		end

		return {}
	end


	local results1 = judgeType(temps)

	
	--10 J Q K A、A 2 3 4 5 不能同时成立
	for i=1,#temps do
		if temps[ i ]['changeNum'] == 1 then
			temps[ i ]['changeNum'] = 14
			break
		end
	end
	DZSort.sortTables(temps, StatusCode.SORT, 'changeNum')
	local results2 = judgeType(temps)


	local results = {}
	if #results1 > #results2 then
		results = results1
	elseif #results2 > #results1 then
		results = results2
	elseif #results2 == #results1 then
		results = results1
	else
		assert(nil, 'get_straight results')
	end

	rets = get_pos_array(array, results)

	return rets
end


--同花
local function get_flush_suit(array)
	local rets = {}
	if #array < 5 then return rets end

	local spade = 0
	local heart = 0
	local club = 0
	local diamond = 0

	for i=1,#array do
		local eleNum = array[ i ]

		if eleNum >= 1 and eleNum <= 13 then
			spade = spade + 1
		elseif eleNum <= 26 then
			heart = heart + 1
		elseif eleNum <= 39 then
			club = club + 1
		elseif eleNum <= 52 then
			diamond = diamond + 1
		end
	end

	local function newArray(min, max)
		for i=1,#array do
			if array[i] >= min and array[i] <= max then
				table.insert(rets, array[i])
			end
		end
	end

	if spade >= 5 then
		newArray(1, 13)
	elseif heart >= 5 then
		newArray(14, 26)
	elseif club >= 5 then
		newArray(27, 39)
	elseif diamond >= 5 then
		newArray(40, 52)
	end

	return rets
end


--葫芦
local function get_full_house(array)
	local rets = {}
	if #array < 3 then return POKER_TYPE_0,rets end

	local ttype, results = three_of_a_kind(array)

	if #results == 0 then
		--没有三条
		return POKER_TYPE_0,rets
	elseif #results == 6 then
		--两个三条 1~3、4~6一样 一定是葫芦
		--大的两个在前面
		local changes = change_array(results)
		DZSort.sortTables(changes, StatusCode.UN_SORT, 'ANum')
		table.remove(changes, #changes)

		rets = get_pos_array(results, changes)
		return POKER_TYPE_4,rets
	elseif #results == 3 then
	else
		assert(nil, 'get_full_house')
	end

	--一个三条、原数组去掉三条，核查剩下的部分有没有对子
	local temps = {}
	for i=1,#array do
		if array[ i ]%13 ~= results[ 1 ]%13 then
			table.insert(temps, array[ i ])
		end
	end
	local ttype, tpairs = get_num_pairs(temps, 'one')
	
	rets = results

	--三条、葫芦
	if #tpairs == 0 then
		return POKER_TYPE_7,rets
	else
		table.insert(rets, tpairs[1])
		table.insert(rets, tpairs[2])
		return POKER_TYPE_4,rets
	end
end


--四条
--
local function four_of_a_kind(array)
	local rets = {}
	if #array < 4 then return POKER_TYPE_0,rets end

	local temps = change_array(array)
	DZSort.sortTables(temps, StatusCode.SORT, 'changeNum')

	local changes = {}
	for i=1,#temps do
		changes = {}
		table.insert(changes, temps[ i ])
		local bef = temps[ i ]['changeNum']

		for j=i+1,#temps do
			if bef == temps[ j ]['changeNum'] then
				table.insert(changes, temps[ j ])
			else
				break
			end
		end

		if #changes == 4 then
			break
		end

		--后面剩下不到四个
		if #temps - i < 4 then
			changes = {}
			break
		end
	end

	rets = get_pos_array(array, changes)
	if #rets == 0 then
		return POKER_TYPE_0, rets
	end

	if #rets ~= 4 then
		assert(nil, 'four_of_a_kind')
	end

	return POKER_TYPE_3, rets
end


--同花顺
--
local function get_straight_flush(array)
end

local function get_only_five(ttype, results)
	if #results == 5 then
		return ttype, results
	end

	local changes = change_array(results)

	--同花、顺子 同花顺 大同花顺
	local sortName = 'changeNum'
	if ttype == POKER_TYPE_5 then
		sortName = 'ANum'
	else
		for i=1,#changes do
			-- K
			if changes[i]['changeNum'] % 13 == 0 then
				sortName = 'ANum'
				break
			end
		end

	end
	DZSort.sortTables(changes, StatusCode.SORT, sortName)

	for i=1,#changes do
		if #changes == 5 then break end

		table.remove(changes, 1)
	end

	if #changes < 5 then
		assert(nil, 'get_only_five')
	end

	return ttype,get_pos_array(results, changes)
end

--同花、顺子
--
local function get_royal_flush(array)
	local sames = get_flush_suit(array)
	
	--不是同花
	if #sames == 0 then
		local straights = get_straight(array)
		--不是顺子、只是顺子
		if #straights == 0 then
			return POKER_TYPE_0, {}
		else
			return get_only_five(POKER_TYPE_6, straights)
		end
	end

	--是同花,同花的基础上判断是不是顺子
	local flushSuit = get_straight(sames)

	--只是同花
	if #flushSuit == 0 then
		return get_only_five(POKER_TYPE_5, sames)
	end

	--同花顺
	local count = 0
	for i=1,#flushSuit do
		local elem = flushSuit[ i ]
		--K A
		if elem % 13 == 0 or elem % 13 == 1 then
			count = count + 1
		end
	end

	--只是同花顺、同花大顺
	if count < 2 then
		return get_only_five(POKER_TYPE_2, flushSuit)
	else
		return get_only_five(POKER_TYPE_1, flushSuit)
	end
end

--同花、顺子、同花顺 与 四条、葫芦 不能共存
function PokerType.get_poker_type(array)
	if not array or #array == 0 then
		print('空空 array    get_poker_type')
		return '', {}, convertPokerToInt(POKER_TYPE_0)
	end
	check_array(array)

	--大同花顺、同花顺、同花、顺子
	local ttype, results = get_royal_flush(array)
	if #results ~= 0 then
		return ttype, results, convertPokerToInt(ttype)
	end

	--四条
	ttype, results = four_of_a_kind(array)
	if #results ~= 0 then
		return ttype, results, convertPokerToInt(ttype)
	end

	--葫芦
	ttype, results = get_full_house(array)
	--葫芦、三条、不成
	if ttype == POKER_TYPE_4 then
		return ttype, results, convertPokerToInt(ttype)
	elseif ttype == POKER_TYPE_7 then
		return ttype, results, convertPokerToInt(ttype)
	end

	--两对、一对
	ttype, results = get_num_pairs(array, 'two')
	if ttype == POKER_TYPE_0 then
		return POKER_TYPE_10, results, convertPokerToInt(POKER_TYPE_10)
	elseif ttype == POKER_TYPE_9 then
		return POKER_TYPE_9, results, convertPokerToInt(POKER_TYPE_9)
	elseif ttype == POKER_TYPE_8 then
		return POKER_TYPE_8, results, convertPokerToInt(POKER_TYPE_8)
	end

	return POKER_TYPE_10, {}, convertPokerToInt(POKER_TYPE_10)
end

-- Lazy 得到扑克牌类型，并且返回完整的获胜
function PokerType.get_poker_type_full(array)
	local array2 = table.values(array)
	local poker_type, results, typeName = PokerType.get_poker_type(array)
	local poker_count = #results
	local maxPokerCount = math.min(5, #array)
	if poker_count >= maxPokerCount then 
		return poker_type, results, typeName
	end
	print("1%13 13%13",1%13,13%13)
	local otherPokerNum = maxPokerCount - poker_count
	table.sort(array2, function(a, b) 
						local cardA, cardB = (a-1)%13, (b-1)%13
						if cardA == 0 then 
							cardA = 13
						end
						if cardB == 0 then 
							cardB = 13
						end
						return cardA > cardB
					  end)
	for i = 1, #results do 
		table.removebyvalue(array2, results[i], true)
	end
	for i = 1, otherPokerNum do 
		results[#results + 1] = array2[i]
	end
	dump(results, "结束2")
	return poker_type, results, typeName
end


function PokerType.change_china(array)
	local rets = {}
	for i=1,#array do
		local elen = array[ i ]
		local num = elen % 13
		if num == 0 then
			num = 13
		end
		if num == 1 then
			num = 'A'
		elseif num == 11 then
			num = 'J'
		elseif num == 12 then
			num = 'Q'
		elseif num == 13 then
			num = 'K'
		end

		if elen <= 13 then
			table.insert(rets, '黑桃'..num)
		elseif elen <= 26 then
			table.insert(rets, '红桃'..num)
		elseif elen <= 39 then
			table.insert(rets, '花子'..num)
		elseif elen <= 52 then
			table.insert(rets, '片子'..num)
		else
			assert(nil, 'change_china '..num)
		end
	end
	return rets
end


-- 葫芦、四条和同花、顺子不会同时出现
-- 核查是三条时一定不能有4条
-- 核查时对子时一定不能有3条

return PokerType