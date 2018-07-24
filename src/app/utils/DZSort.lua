local DZSort = {}

local function sortFunc(key)
	local func = nil

	local function funcPos(obj)
		return obj:getDate()
	end
	local function funcArray(num)
		return num
	end
	local function funcSurplusBet(obj)
		return obj:getSurplusNum()
	end

	if key == StatusCode.KEY_PM then
		func = funcPos
	elseif key == StatusCode.KEY_ARRAY then
		func = funcArray
	elseif key == StatusCode.KEY_BET then
		func = funcSurplusBet
	end

	if func == nil then
		assert(nil, '排序 出错 DZSort.sortFunc')
	end

	return func
end


function DZSort.sortObject(objs, sortMethod, key)
	local func = nil
	if type(key) == 'function' then
		func = key
	else
		func = sortFunc(key)
	end

	local function sortCard(a, b)
		if sortMethod == StatusCode.SORT then
			return func(a) < func(b)
		else
			return func(a) > func(b)
		end
	end
	table.sort(objs, sortCard)

	return objs
end


function DZSort.sortTables(tabs, sortMethod, key)
	
	local function quickSort(hIdx, lIdx)
		local i = hIdx
		local j = lIdx
		local tmp = tabs[i] 

		repeat
			if sortMethod == StatusCode.SORT then
				while tabs[j][key] >= tmp[key] and i < j do
					j = j - 1
				end
			else
				while tabs[j][key] <= tmp[key] and i < j do
					j = j - 1
				end
			end

			if i < j then 
				tabs[i] = tabs[j] 
				i = i +  1
			end

			
			if sortMethod == StatusCode.SORT then
				while tabs[i][key] <= tmp[key] and i < j do
					i = i + 1
				end
			else
				while tabs[i][key] >= tmp[key] and i < j do
					i = i + 1
				end
			end
			
			if i < j then 
				tabs[j] = tabs[i] 
				j = j -  1
			end
		until i == j

		tabs[i] = tmp

		return i
	end


	local function partitionFunc(hIdx, lIdx)
		local tIdx = 0
		if hIdx < lIdx then
			tIdx = quickSort(hIdx, lIdx)
			partitionFunc(hIdx, tIdx-1)
			partitionFunc(tIdx+1, lIdx)
		end
	end

	partitionFunc(1, #tabs)

	return tabs
end

return DZSort