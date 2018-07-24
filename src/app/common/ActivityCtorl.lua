local ActivityCtorl = {}
local ClubCtrol = require("club.ClubCtrol")
local UnionCtrol = require("union.UnionCtrol")

local groupId = nil
local groupType = nil
local YearMonth = nil

ActivityCtorl.ACT_UNION = 1
ActivityCtorl.ACT_CLUB = 2


local clubActData = {}
local clubAct_Month = {}
-- 个人月份详情
local clubMonthMember = {}
local clubMonthList = {}

local unionActData = {}
local unionAct_Month = {}

local unionMonthMember = {}
local unionMonthList = {}

local clubActDetail = {}
local clubActTotal = {}

local isClub = true

-- 组织类型俱乐部、联盟
function ActivityCtorl.setActOfGroupType( group_type )
	print("-----------------group_type: "..group_type)
	groupType = group_type
end

function ActivityCtorl.getActOfGroupType(  )
	print("-----------------groupType: "..groupType)
	return groupType
end

-- 组织id
function ActivityCtorl.setActOfGroupId( group_id )
	print("-----------------group_id: "..group_id)
	groupId = group_id
end

function ActivityCtorl.getActOfGroupId(  )
	print("-----------------groupId: "..groupId)
	return groupId
end

function ActivityCtorl.getYearMonth( year_month )
	local month = nil
	-- month = string.sub(year_month, 6, 7)
	month = string.gsub(year_month, "-", "年")
	return month
end

function ActivityCtorl.gameModel()
	local gameType = {}
	
	local gameMod = { "21", "22", "23", "21_secure", "general", "sng", "mtt_general", "general_secure", "63", "hall_general_standard", "hall_general_standard_secure", "hall_general_headsup", "hall_general_headsup_secure", "hall_sng", "53", "31", "32", "33", "31_secure", "41", "42", "43", "41_secure" }

	local gameDes = { "本俱乐部的标准", "本俱乐部的SNG", "本俱乐部的MTT", "本俱乐部的保险", "组建牌局的标准", "组建牌局的SNG", "组建牌局的MTT", "组建牌局的保险", "本地化的MTT", "赛场的标准", "赛场的保险", "赛场的单挑标准", "赛场的单挑保险", "赛场的SNG",  "赛场的MTT", "圈子的标准", "圈子的SNG", "圈子的MTT", "圈子的保险", "本联盟的标准", "本联盟的SNG", "本联盟的MTT", "本联盟的保险" }
	for i,mod_v in ipairs(gameMod) do
		for j,des_v in ipairs(gameDes) do
			if i == j then
				local tmp = {}
				tmp["mod"] = mod_v
				tmp["title"] = des_v
				-- 俱乐部内
				if mod_v == "21" or mod_v == "22" or mod_v == "23" or mod_v == "21_secure" then
					tmp["top_title"] = "俱乐部"
					tmp["out_in"] = 1
					tmp["order"] = i
				-- 组局
				elseif mod_v == "general" or mod_v == "sng" or  mod_v == "mtt_general" or  mod_v == "general_secure" then
					tmp["top_title"] = "组局"
					tmp["out_in"] = 2
					tmp["order"] = i-4
				-- 赛场
				-- 自由单桌
				elseif mod_v == "hall_general_standard" or mod_v == "hall_general_standard_secure" then
					tmp["top_title"] = "赛场"
					tmp["out_in"] = 3
					tmp["order"] = i-9
				-- 单挑
				elseif mod_v == "hall_general_headsup" or mod_v == "hall_general_headsup_secure" then
					tmp["top_title"] = "赛场"
					tmp["out_in"] = 4
					tmp["order"] = i-11
				-- sng/mtt
				elseif mod_v == "hall_sng" or mod_v == "53" or mod_v == "63" then
					tmp["top_title"] = "赛场"
					tmp["out_in"] = 5
					tmp["order"] = i-13
				-- 圈子
				elseif mod_v == "31" or mod_v == "32" or mod_v == "33" or mod_v == "31_secure" then
					tmp["top_title"] = "圈子"
					tmp["out_in"] = 6
					tmp["order"] = i-15
				-- 联盟内
				elseif mod_v == "41" or mod_v == "42" or mod_v == "43" or mod_v == "41_secure" then
					tmp["top_title"] = "联盟"
					tmp["out_in"] = 7
					tmp["order"] = i-19
				end
				gameType[#gameType+1] = tmp
			end
		end
	end
	-- dump(gameType)
	-- print(json.encode(gameType))
	return gameType
end

-- 俱乐部总活跃统计
function ActivityCtorl.dataStatGroupActivity( groupType, groupId, funback )
	ActivityCtorl.setActOfGroupType( groupType )
	ActivityCtorl.setActOfGroupId( groupId )
	local function response( data )
		dump(data)
		if data.code == 0 then
			if ActivityCtorl.getActOfGroupType() == 1 then
				ActivityCtorl.buildUnionActData( data.data )
			else
				ActivityCtorl.buildClubActData( data.data )
			end
			funback()
		end
	end
	local tabData = {}
	tabData["stat_type"] = ActivityCtorl.getActOfGroupType(  )
	tabData["group_id"] = ActivityCtorl.getActOfGroupId(  )
	tabData["type"] = 1
	XMLHttp.requestHttp("groupActive", tabData, response, PHP_POST)
end

function ActivityCtorl.buildClubActData( data )
	clubActData = {}
	local clubTab = {}

	local ClubCtrol = require("club.ClubCtrol")
	local clubInfo = ClubCtrol.getClubInfo()

	-- 俱乐部基础信息
	clubTab["headimg"] = clubInfo.avatar
	clubTab["name"] = clubInfo.name
	clubTab["union"] = clubInfo.union
	clubTab["exp"] = clubInfo.exp
	clubTab["address"] = clubInfo.address
	clubTab["users_count"] = clubInfo.users_count
	clubTab["users_limit"] = clubInfo.users_limit

	-- 牌局信息
	clubTab["card_cout"] = data.club_cout or 0
	clubTab["existtimesum"] = data.existtimesum or 0
	clubTab["no_hall_scoressum"] = data.no_hall_scoressum or 0
	-- clubTab["diamondsum"] = data.diamondsum or 0

	-- 俱乐部基础信息、统计总数
	clubActData["club_info"] = clubTab
	clubActData["clubAct"] = {}
	local actType = {"club_starts", "organize_starts", "hall_general_standard", "hall_general_headsup", "hall_sngmtt_starts", "circle_starts", "union_starts"}
	for i,v in ipairs(actType) do
		if data[v] then
			local tmpTab = {}
			tmpTab = data[v]
			tmpTab["infoType"] = 1
			if i ~= 5 then
				local insurance = tonumber(tmpTab.insurance_scores) or 0
				if insurance > 0 then
					tmpTab["insurance_scores"] = "+"..insurance
				else
					tmpTab["insurance_scores"] = insurance
				end
			end
			tmpTab["actType"] = i
			tmpTab["first"] = 1
			tmpTab["cellHeight"] = 230
			if i == 1 then
				tmpTab["topTitle"] = "俱乐部"
				tmpTab["color"] = ResLib.COLOR_BLUE
			elseif i == 2 then
				tmpTab["topTitle"] = "组局"
				tmpTab["color"] = ResLib.COLOR_PURPLE
			elseif i == 3 then
				tmpTab["topTitle"] = "赛场"
				tmpTab["title"] = "赛场自由单桌牌局"
				tmpTab["color"] = ResLib.COLOR_RED
			elseif i == 4 then
				tmpTab["first"] = 0
				tmpTab["topTitle"] = "赛场"
				tmpTab["title"] = "赛场单挑牌局"
				tmpTab["color"] = ResLib.COLOR_RED
			elseif i == 5 then
				tmpTab["first"] = 0
				tmpTab["cellHeight"] = 140
				tmpTab["topTitle"] = "赛场"
				tmpTab["title"] = "赛场SNG/MTT牌局"
				tmpTab["color"] = ResLib.COLOR_RED
			elseif i == 6 then
				tmpTab["topTitle"] = "圈子"
				tmpTab["color"] = ResLib.COLOR_GREEN
			elseif i == 7 then
				tmpTab["topTitle"] = "联盟"
				tmpTab["color"] = ResLib.COLOR_ORANGE
			end
			clubActData["clubAct"][#clubActData["clubAct"]+1] = tmpTab
		end
	end
	local monthTop = {infoType = 0, menuType = 1, unfold = 0, title = "每月详情"}
	clubActData["clubAct"][#clubActData["clubAct"]+1] = monthTop

	-- 月份统计
	clubAct_Month = {}
	for i,v in ipairs(data.monthdata) do
		local tmpTab = {}
		tmpTab = v
		tmpTab["infoType"] = 0
		tmpTab["menuType"] = 2
		clubAct_Month[#clubAct_Month+1] = tmpTab
	end
end

function ActivityCtorl.getClubActData(  )
	return clubActData
end

function ActivityCtorl.getClubAct_Month(  )
	return clubAct_Month
end

-- 俱乐部本月份所有成员的统计
function ActivityCtorl.dataStatGroupMonthTot( month, funback )
	local function response( data )
		dump(data)
		funback(data.data)
	end
	local tabData = {}
	tabData["stat_type"] = ActivityCtorl.getActOfGroupType()
	tabData["group_id"] = ActivityCtorl.getActOfGroupId()
	tabData["year_month"] = month
	tabData["type"] = 2
	XMLHttp.requestHttp("groupActive", tabData, response, PHP_POST)
end

-- 俱乐部本月统计详情
function ActivityCtorl.dataStatGroupMonthDet( info, funback )
	local function response( data )
		dump(data)
		ActivityCtorl.buildGroupMonthDet( "member", info, data.data )
		funback()
	end
	local tabData = {}
	tabData["stat_type"] = ActivityCtorl.getActOfGroupType()
	tabData["group_id"] = ActivityCtorl.getActOfGroupId()
	tabData["year_month"] = info.month
	tabData["group_members"] = info.group_member_id
	tabData["type"] = 3
	XMLHttp.requestHttp("groupActive", tabData, response, PHP_POST)
end

-- 俱乐部成员本月统计详情
function ActivityCtorl.dataStatGroupMonthDetail( info, funback )
	local function response( data )
		dump(data)
		ActivityCtorl.buildGroupMonthDet( "month", info, data.data )
		funback()
	end
	local tabData = {}
	tabData["stat_type"] = ActivityCtorl.getActOfGroupType()
	tabData["group_id"] = ActivityCtorl.getActOfGroupId()
	tabData["year_month"] = info.month
	tabData["type"] = 4
	XMLHttp.requestHttp("groupActive", tabData, response, PHP_POST)
end

function ActivityCtorl.buildGroupMonthDet( tabFlag, info, actTab )
	clubMonthMember = {}
	clubMonthList = {}

	unionMonthMember = {}
	unionMonthList = {}

	local unionOrClub = ActivityCtorl.getActOfGroupType()

	clubActDetail["act_club"] 			= {}
	clubActDetail["act_build"] 			= {}
	clubActDetail["act_hall_free"] 		= {}
	clubActDetail["act_hall_headsup"] 	= {}
	clubActDetail["act_hall_sngmtt"] 	= {}
	clubActDetail["act_circle"] 		= {}
	clubActDetail["act_union"] 			= {}

	clubActTotal["act_club"] 			= {}
	clubActTotal["act_build"] 			= {}
	clubActTotal["act_hall_free"] 		= {}
	clubActTotal["act_hall_headsup"] 	= {}
	clubActTotal["act_hall_sngmtt"] 	= {}
	clubActTotal["act_circle"] 			= {}
	clubActTotal["act_union"] 			= {}
	for k,v in pairs(clubActTotal) do
		v["score_total"] = 0
		v["face_total"] = 0
		v["look_total"] = 0
		v["diamond_total"] = 0
		v["secure_total"] = 0
	end

	-- 127 带入量 -- 120 重购 -- 128 增构 （相加为该类型总带入量）
	-- 125 发发看
	-- 124 表情
	-- 222 钻石
	-- secure 保险
	-- 发发看消耗 类型
	local lookMod = {"general", "general_secure", "hall_general_standard", "hall_general_standard_secure", "hall_general_headsup", "hall_general_headsup_secure", "21", "21_secure", "31", "31_secure", "41", "41_secure"}
	-- 保险金 类型
	local secureMod = {"general_secure", "hall_general_standard_secure", "hall_general_headsup_secure", "21_secure", "31_secure", "41_secure"}

	local member_tab = {}
	local data = actTab.member_gameinfo
	local gameModel = ActivityCtorl.gameModel()
	for i,v in ipairs(gameModel) do
		if data[v.mod] then
			local tmpTab = {}
			
			tmpTab["title"] = v.title
			tmpTab["mod"] = v.mod
			tmpTab["score"] = (tonumber(data[v.mod]["127"]) or 0)+(tonumber(data[v.mod]["128"]) or 0)+(tonumber(data[v.mod]["120"]) or 0)
			tmpTab["face_use"] = data[v.mod]["124"] or 0
			tmpTab["diamond_use"] = data[v.mod]["222"] or 0

			-- cell高度
			local cellHeight = 140
			-- 0无 发发看、保险，1有发发看，2有发发看和保险
			local look_secure = 0
			-- 发发看
			for look_i,look_v in ipairs(lookMod) do
				if v.mod == look_v then
					tmpTab["look_use"] = data[v.mod]["125"] or 0
					look_secure = 1
					cellHeight = 180
					break
				end
			end
			-- 保险
			for secure_i,secure_v in ipairs(secureMod) do
				if v.mod == secure_v then
					tmpTab["secure_use"] = data[v.mod]["secure"] or 0
					look_secure = 2
					cellHeight = 230
					break
				end
			end

			tmpTab["look_secure"] = look_secure
			tmpTab["cellHeight"] = cellHeight
			if v.mod == "hall_general_standard" or v.mod == "hall_general_standard_secure" then
				tmpTab["hand_score"] = data[v.mod]["hand_score"]
				tmpTab["cellHeight"] = tmpTab["cellHeight"]+600
			end
			
			-- tmpTab["out_in"] = v.out_in
			tmpTab["order"] = v.order
			tmpTab["infoType"] = 2
			-- 俱乐部
			if v.out_in == 1 then
				local key = "act_club"
				tmpTab["key"] = key
				table.insert(clubActDetail[key], tmpTab)
				clubActTotal[key].score_total = clubActTotal[key].score_total + tonumber(tmpTab["score"])
				clubActTotal[key].face_total = clubActTotal[key].face_total + tonumber(tmpTab["face_use"] or 0)
				clubActTotal[key].look_total = clubActTotal[key].look_total + tonumber(tmpTab["look_use"] or 0)
				clubActTotal[key].diamond_total = clubActTotal[key].diamond_total + tonumber(tmpTab["diamond_use"])
				clubActTotal[key].secure_total = clubActTotal[key].secure_total + tonumber(tmpTab["secure_use"] or 0)
			-- 组局
			elseif v.out_in == 2 then
				local key = "act_build"
				tmpTab["key"] = key
				table.insert(clubActDetail[key], tmpTab)
				clubActTotal[key].score_total = clubActTotal[key].score_total + tonumber(tmpTab["score"])
				clubActTotal[key].face_total = clubActTotal[key].face_total + tonumber(tmpTab["face_use"] or 0)
				clubActTotal[key].look_total = clubActTotal[key].look_total + tonumber(tmpTab["look_use"] or 0)
				clubActTotal[key].diamond_total = clubActTotal[key].diamond_total + tonumber(tmpTab["diamond_use"])
				clubActTotal[key].secure_total = clubActTotal[key].secure_total + tonumber(tmpTab["secure_use"] or 0)
			-- 赛场自由
			elseif v.out_in == 3 then
				local key = "act_hall_free"
				tmpTab["key"] = key
				table.insert(clubActDetail[key], tmpTab)
				clubActTotal[key].score_total = clubActTotal[key].score_total + tonumber(tmpTab["score"])
				clubActTotal[key].face_total = clubActTotal[key].face_total + tonumber(tmpTab["face_use"] or 0)
				clubActTotal[key].look_total = clubActTotal[key].look_total + tonumber(tmpTab["look_use"] or 0)
				clubActTotal[key].diamond_total = clubActTotal[key].diamond_total + tonumber(tmpTab["diamond_use"])
				clubActTotal[key].secure_total = clubActTotal[key].secure_total + tonumber(tmpTab["secure_use"] or 0)
			-- 赛场单挑
			elseif v.out_in == 4 then
				local key = "act_hall_headsup"
				tmpTab["key"] = key
				table.insert(clubActDetail[key], tmpTab)
				clubActTotal[key].score_total = clubActTotal[key].score_total + tonumber(tmpTab["score"])
				clubActTotal[key].face_total = clubActTotal[key].face_total + tonumber(tmpTab["face_use"] or 0)
				clubActTotal[key].look_total = clubActTotal[key].look_total + tonumber(tmpTab["look_use"] or 0)
				clubActTotal[key].diamond_total = clubActTotal[key].diamond_total + tonumber(tmpTab["diamond_use"])
				clubActTotal[key].secure_total = clubActTotal[key].secure_total + tonumber(tmpTab["secure_use"] or 0)
			-- 赛场sng/mtt
			elseif v.out_in == 5 then
				local key = "act_hall_sngmtt"
				tmpTab["key"] = key
				table.insert(clubActDetail[key], tmpTab)
				clubActTotal[key].score_total = clubActTotal[key].score_total + tonumber(tmpTab["score"])
				clubActTotal[key].face_total = clubActTotal[key].face_total + tonumber(tmpTab["face_use"] or 0)
				clubActTotal[key].look_total = clubActTotal[key].look_total + tonumber(tmpTab["look_use"] or 0)
				clubActTotal[key].diamond_total = clubActTotal[key].diamond_total + tonumber(tmpTab["diamond_use"])
				clubActTotal[key].secure_total = clubActTotal[key].secure_total + tonumber(tmpTab["secure_use"] or 0)
			-- 圈子
			elseif v.out_in == 6 then
				local key = "act_circle"
				tmpTab["key"] = key
				table.insert(clubActDetail[key], tmpTab)
				clubActTotal[key].score_total = clubActTotal[key].score_total + tonumber(tmpTab["score"])
				clubActTotal[key].face_total = clubActTotal[key].face_total + tonumber(tmpTab["face_use"] or 0)
				clubActTotal[key].look_total = clubActTotal[key].look_total + tonumber(tmpTab["look_use"] or 0)
				clubActTotal[key].diamond_total = clubActTotal[key].diamond_total + tonumber(tmpTab["diamond_use"])
				clubActTotal[key].secure_total = clubActTotal[key].secure_total + tonumber(tmpTab["secure_use"] or 0)
			-- 联盟
			elseif v.out_in == 7 then
				local key = "act_union"
				tmpTab["key"] = key
				table.insert(clubActDetail[key], tmpTab)
				clubActTotal[key].score_total = clubActTotal[key].score_total + tonumber(tmpTab["score"])
				clubActTotal[key].face_total = clubActTotal[key].face_total + tonumber(tmpTab["face_use"] or 0)
				clubActTotal[key].look_total = clubActTotal[key].look_total + tonumber(tmpTab["look_use"] or 0)
				clubActTotal[key].diamond_total = clubActTotal[key].diamond_total + tonumber(tmpTab["diamond_use"])
				clubActTotal[key].secure_total = clubActTotal[key].secure_total + tonumber(tmpTab["secure_use"] or 0)
			end
		end
	end

	if tabFlag == "member" then
		if info["union"] then
			member_tab["union"] = info["union"]
		end
		member_tab["order"] = 1
		member_tab["cellHeight"] = 240
		member_tab["infoType"] = 0
		member_tab["key"] = "info"
		member_tab["headimg"] = info.headimg
		member_tab["group_member_name"] = info.group_member_name
		member_tab["p_time"] = actTab["p_time"] or 0
		member_tab["p_count"] = actTab["p_count"] or 0
		member_tab["no_hall_scoressum"] = actTab["no_hall_scoressum"] or 0
		member_tab["group_member_id"] = actTab["group_member_id"] or 0
	else
		member_tab["order"] = 1
		member_tab["cellHeight"] = 100
		member_tab["infoType"] = 0
		member_tab["key"] = "info"
		member_tab["month"] = info.month
		member_tab["month_total"] = actTab["no_hall_scoressum"] or 0
	end
	
	-- dump(clubActDetail)
	-- dump(clubActTotal)
	for k,v in pairs(clubActTotal) do
		local tmpTab = {}
		tmpTab = v
		tmpTab["unfold"] = 0
		tmpTab["infoType"] = 1
		local insurance = tonumber(tmpTab.secure_total) or 0
		if insurance > 0 then
			tmpTab["secure_total"] = "+"..insurance
		else
			tmpTab["secure_total"] = insurance
		end
		tmpTab["first"] = 1
		tmpTab["cellHeight"] = 230
		tmpTab["key"] = k
		if k == "act_club" then
			tmpTab["order"] = 2
			tmpTab["actType"] = 1
			tmpTab["topTitle"] = "俱乐部"
			tmpTab["color"] = ResLib.COLOR_BLUE
		elseif k == "act_build" then
			tmpTab["order"] = 3
			tmpTab["actType"] = 2
			tmpTab["topTitle"] = "组局"
			tmpTab["color"] = ResLib.COLOR_PURPLE
		elseif k == "act_hall_free" then
			tmpTab["order"] = 4
			tmpTab["actType"] = 3
			tmpTab["topTitle"] = "赛场"
			tmpTab["title"] = "赛场标准模式/保险模式点击查看"
			tmpTab["color"] = ResLib.COLOR_RED
		elseif k == "act_hall_headsup" then
			tmpTab["order"] = 5
			tmpTab["first"] = 0
			tmpTab["actType"] = 4
			tmpTab["topTitle"] = "赛场"
			tmpTab["title"] = "赛场单挑牌局"
			tmpTab["color"] = ResLib.COLOR_RED
		elseif k == "act_hall_sngmtt" then
			tmpTab["order"] = 6
			tmpTab["first"] = 0
			tmpTab["cellHeight"] = 140
			tmpTab["actType"] = 5
			tmpTab["topTitle"] = "赛场"
			tmpTab["title"] = "赛场SNG/MTT牌局总"
			tmpTab["color"] = ResLib.COLOR_RED
		elseif k == "act_circle" then
			tmpTab["order"] = 7
			tmpTab["actType"] = 6
			tmpTab["topTitle"] = "圈子"
			tmpTab["color"] = ResLib.COLOR_GREEN
		elseif k == "act_union" then
			tmpTab["order"] = 8
			tmpTab["actType"] = 7
			tmpTab["topTitle"] = "联盟"
			tmpTab["color"] = ResLib.COLOR_ORANGE
		end

		-- 联盟
			if unionOrClub == ActivityCtorl.ACT_UNION then
				if tabFlag == "member" then
					table.insert(unionMonthMember, tmpTab)
				else
					table.insert(unionMonthList, tmpTab)
				end
			else
				if tabFlag == "member" then
					table.insert(clubMonthMember, tmpTab)
				else
					table.insert(clubMonthList, tmpTab)
				end
			end
	end

	-- 联盟
	if unionOrClub == ActivityCtorl.ACT_UNION then
		if tabFlag == "member" then
			table.insert(unionMonthMember, 1, member_tab)
			dump(unionMonthMember)
		else
			table.insert(unionMonthList, 1, member_tab)
			dump(unionMonthList)
		end
	else
		if tabFlag == "member" then
			table.insert(clubMonthMember, 1, member_tab)
			dump(clubMonthMember)
		else
			table.insert(clubMonthList, 1, member_tab)
			dump(clubMonthList)
		end
	end--]]
	
end

function ActivityCtorl.getClubMonthMember(  )
	table.sort(clubMonthMember,function ( a, b )
		return a.order < b.order
	end)
	return clubMonthMember
end

function ActivityCtorl.getClubMonthMember_d( key )
	print(key)
	local tmpTab = clubActDetail[key]
	if next(tmpTab) == nil then
		return {}
	end
	table.sort(tmpTab,function ( a, b )
		return a.order < b.order
	end)
	-- dump(tmpTab)
	return tmpTab
end

function ActivityCtorl.getClubMonthList(  )
	table.sort(clubMonthList,function ( a, b )
		return a.order < b.order
	end)
	return clubMonthList
end

function ActivityCtorl.getClubMonthList_d( key )
	print(key)
	local tmpTab = clubActDetail[key]
	if next(tmpTab) == nil then
		return {}
	end
	table.sort(tmpTab,function ( a, b )
		return a.order < b.order
	end)
	-- dump(tmpTab)
	return tmpTab
end

function ActivityCtorl.buildUnionActData( data )
	unionActData = {}
	local unionTab = {}

	local UnionCtrol = require("union.UnionCtrol")
	local unionInfo = UnionCtrol.getUnionDetail(  )

	unionTab["headimg"] = unionInfo.union_avatar
	unionTab["name"] = unionInfo.union_name
	unionTab["address"] = unionInfo.city or "北京北"
	unionTab["users_count"] = unionInfo.count_cur or ""
	unionTab["users_limit"] = unionInfo.count_limit or "无限制"

	unionTab["card_cout"] = data.club_cout or 0
	unionTab["existtimesum"] = data.existtimesum or 0
	unionTab["no_hall_scoressum"] = data.no_hall_scoressum or 0
	-- unionTab["diamondsum"] = data.diamondsum or 0

	-- 俱乐部基础信息、统计总数
	unionActData["union_info"] = unionTab
	unionActData["unionAct"] = {}
	local actType = {"club_starts", "organize_starts", "hall_general_standard", "hall_general_headsup", "hall_sngmtt_starts", "circle_starts", "union_starts"}
	for i,v in ipairs(actType) do
		if data[v] then
			local tmpTab = {}
			tmpTab = data[v]
			tmpTab["infoType"] = 1
			if i ~= 5 then
				local insurance = tonumber(tmpTab.insurance_scores) or 0
				if insurance > 0 then
					tmpTab["insurance_scores"] = "+"..insurance
				else
					tmpTab["insurance_scores"] = insurance
				end
			end
			tmpTab["actType"] = i
			tmpTab["first"] = 1
			tmpTab["cellHeight"] = 230
			if i == 1 then
				tmpTab["topTitle"] = "俱乐部"
				tmpTab["color"] = ResLib.COLOR_BLUE
			elseif i == 2 then
				tmpTab["topTitle"] = "组局"
				tmpTab["color"] = ResLib.COLOR_PURPLE
			elseif i == 3 then
				tmpTab["topTitle"] = "赛场"
				tmpTab["title"] = "赛场自由单桌牌局"
				tmpTab["color"] = ResLib.COLOR_RED
			elseif i == 4 then
				tmpTab["first"] = 0
				tmpTab["topTitle"] = "赛场"
				tmpTab["title"] = "赛场单挑牌局"
				tmpTab["color"] = ResLib.COLOR_RED
			elseif i == 5 then
				tmpTab["first"] = 0
				tmpTab["cellHeight"] = 140
				tmpTab["topTitle"] = "赛场"
				tmpTab["title"] = "赛场SNG/MTT牌局"
				tmpTab["color"] = ResLib.COLOR_RED
			elseif i == 6 then
				tmpTab["topTitle"] = "圈子"
				tmpTab["color"] = ResLib.COLOR_GREEN
			elseif i == 7 then
				tmpTab["topTitle"] = "联盟"
				tmpTab["color"] = ResLib.COLOR_ORANGE
			end
			unionActData["unionAct"][#unionActData["unionAct"]+1] = tmpTab
		end
	end
	local monthTop = {infoType = 0, menuType = 1, unfold = 0, title = "每月详情"}
	unionActData["unionAct"][#unionActData["unionAct"]+1] = monthTop

	-- 月份统计
	unionAct_Month = {}
	for i,v in ipairs(data.monthdata) do
		local tmpTab = {}
		tmpTab = v
		tmpTab["infoType"] = 0
		tmpTab["menuType"] = 2
		unionAct_Month[#unionAct_Month+1] = tmpTab
	end
end

function ActivityCtorl.getUnionActData(  )
	return unionActData
end

function ActivityCtorl.getUnionAct_Month(  )
	return unionAct_Month
end

function ActivityCtorl.getUnionMonthMember(  )
	table.sort(unionMonthMember,function ( a, b )
		return a.order < b.order
	end)
	return unionMonthMember
end

function ActivityCtorl.getUnionMonthMember_d( key )
	print(key)
	local tmpTab = clubActDetail[key]
	if next(tmpTab) == nil then
		return {}
	end
	table.sort(tmpTab,function ( a, b )
		return a.order < b.order
	end)
	dump(tmpTab)
	return tmpTab
end

function ActivityCtorl.getUnionMonthList(  )
	table.sort(unionMonthList,function ( a, b )
		return a.order < b.order
	end)
	return unionMonthList
end

function ActivityCtorl.getUnionMonthList_d( key )
	print(key)
	local tmpTab = clubActDetail[key]
	if next(tmpTab) == nil then
		return {}
	end
	table.sort(tmpTab,function ( a, b )
		return a.order < b.order
	end)
	dump(tmpTab)
	return tmpTab
end

function ActivityCtorl.transTime( time )
	local T_second = nil
	local T_minute = nil
	local T_hour = nil
	local T_str = nil

	local time = tonumber(time)

	if time >= 60 then
		T_minute = time/60
		if T_minute >= 60 then
			T_hour = T_minute/60
			local n1, n2 = math.modf(T_hour)
			print(string.format("%d, %f", n1, n2))

			if n2 ~= 0 then
				T_str = n1.."小时" .. tostring(math.floor(n2*60)) .. "分钟"
			else
				T_str = n1.."小时"
			end
		else
			local n1, n2 = math.modf(T_minute)
			print(string.format("%d, %f", n1, n2))
			if n2 ~= 0 then
				T_str = n1.."分钟" .. tostring(math.floor(n2*60)) .. "秒"
			else
				T_str = n1.."分钟"
			end
		end
	else
		T_str = time .. "秒"
	end
	
	return T_str
end

function ActivityCtorl.setActFlag( isFlag )
	isClub = isFlag
end

function ActivityCtorl.isActFlag(  )
	return isClub
end

return ActivityCtorl