local ClubCtrol = {}

local club_ui 	= {}		
local club_info = {} 		-- 俱乐部详细信息
local club_list = {}		-- 俱乐部列表

local invite_user = {}
	
-- 俱乐部管理员权限操作
-- 111：发起牌局；112：审核带入；113查看战绩；114查看活跃统计；
-- 121：删除成员；122：修改俱乐部资料；123审核俱乐部；124：添加推广员；
-- 212：审核带入；211：历史牌局；213：结算牌局；221查看联盟
ClubCtrol.PERMIT = {
	111,
	121,
	112,
	124,
	122,
	114,
	123,
	113,
	212,
	221,
	211,
	213,
}

local cmana_list = {} 	-- 俱乐部管理员列表

local cmember_list = {} -- 俱乐部成员列表

local permit = {}


-- 判断俱乐部是否为自己创建的
local is_create = true

function ClubCtrol.setPermit( tab )
	permit = {}
	permit = tab
end

function ClubCtrol.getPermit(  )
	return permit
end

-- 判断是否有俱乐部 新建、加入俱乐部
function ClubCtrol.isHaveClub( funback )
	local function response( data )
		dump(data)
		if data.code == 0 then
			if tonumber(data.data) == 0 then
				funback("no")
			else
				ClubCtrol.dataStatClub( funback )
			end
		end
	end
	XMLHttp.requestHttp("isJoinClub", {}, response, PHP_POST)
end

-- 请求俱乐部列表
function ClubCtrol.dataStatClub( funback )
	local function response( data )
		if data.code == 0 then
			local curClubData = ClubCtrol.buildClubList( data )
			dump(curClubData)
			funback("yes")
		end
	end
	local tabData = {}
	XMLHttp.requestHttp( PHP_CLUB_LIST, tabData, response, PHP_POST )
end

function ClubCtrol.getAreaTable(  )
	local _cityLayer = require("main.CityLayer")
	return _cityLayer.getCityData(  )
end

-- 根据地区编号获取地区名称
function ClubCtrol.getNumberOfSite( number )
	local site = nil
	local _cityLayer = require("main.CityLayer")
	site = _cityLayer.getCodeOfSite(number)
	return site
end

-- 根据地区名称获取地区编号
function ClubCtrol.getSiteOfNumber( site )
	local number = nil
	local _cityLayer = require("main.CityLayer")
	number = _cityLayer.getSiteOfCode(site)
	return number
end

-- 判断俱乐部是否为自己创建
function ClubCtrol.setClubIsCreate( isCreate )
	is_create = isCreate
end

function ClubCtrol.getClubIsCreate(  )
	return is_create
end


---@@@@@@@@ 俱乐部列表相关
-- 缓存俱乐部列表
function ClubCtrol.setClubList( data )
	club_list = {}
	club_list = data
end

-- 获取俱乐部列表
function ClubCtrol.getClubList(  )
	return club_list
end

function ClubCtrol.editClubList( params )
	local list = ClubCtrol.getClubList()
	for k,v in pairs(list) do
		if tonumber(v.id) == tonumber(params.club_id) then
			if params.name then
				list[k].club_name 	= params.name
			end
			if params.summary then
				list[k].summary 	= params.summary
			end
			if params.P then
				list[k].users_P = params.P
			end
			
			-- 编辑头像地址
			if params.avatar then
				if v.avatar ~= params.avatar then
					local path = device.writablePath .. v.avatar
					if cc.FileUtils:getInstance():isFileExist(path) then
						cc.FileUtils:getInstance():removeFile(path)
					end
					list[k].avatar = params.avatar
				end
			end
			
			break
		end
	end
	-- dump(list)
	ClubCtrol.setClubList( list )
end

-- 设置俱乐部列表
function ClubCtrol.buildClubList( data )
	local clubList = {}
	local my_club = {}
	if data.myclub then
		my_club = data.myclub
		my_club["firstSite"] = 1
	end
	
	for key,val in pairs(data.clublist) do
		for k,v in pairs(val) do
			local tmpTab = {}
			tmpTab = v
			if k == 1 then
				tmpTab["firstSite"] = 1
			else
				tmpTab["firstSite"] = 0
			end
			table.insert(clubList, tmpTab)
		end
	end
	if next(my_club) ~= nil then
		table.insert(clubList, 1, my_club)
	end
	-- dump(clubList)
	ClubCtrol.setClubList( clubList )
	return clubList
end


----@@@@@@@ 俱乐部详情

-- 请求俱乐部详情
function ClubCtrol.dataStatClubInfo( club_id, funback )
	local function response( data )
		-- dump(data)
		if tonumber( data.code ) == 0 then
			ClubCtrol.setClubInfo(data.data)
			funback()
		end
	end
	local tabData = {}
	tabData['club_id'] = club_id
	XMLHttp.requestHttp( PHP_CLUB_DETAIL, tabData, response, PHP_POST )
end

-- 缓存俱乐部详情
function ClubCtrol.setClubInfo( data )
	club_info = {}
	club_info = data
end

-- 获取俱乐部详情
function ClubCtrol.getClubInfo(  )
	return club_info
end

-- 删除俱乐部成员
function ClubCtrol.deleteClub_User( img )
	local clubData = ClubCtrol.getClubInfo()
	local imgs = clubData.user_part
	-- dump(imgs)
	for k,v in pairs(imgs) do
		if v == img then
			table.remove(imgs, k)
			clubData.user_part = imgs
			clubData.users_count = clubData.users_count - 1
			ClubCtrol.setClubInfo( clubData )
			break
		end
	end
end

-- 添加俱乐部成员
function ClubCtrol.addClub_User( img )
	local clubData = ClubCtrol.getClubInfo()
	table.insert(clubData.user_imgs, img)
	clubData.users_count = clubData.users_count + 1
	ClubCtrol.setClubInfo( clubData )
end

-- @@@ params
-- name 俱乐部名称
-- summary 俱乐部简介
-- avatar 俱乐部头像地址
function ClubCtrol.editClubInfo( params )
	
	local clubData = ClubCtrol.getClubInfo()
	if next(clubData) == nil then
		return
	end
	if clubData.id ~= params.club_id then
		return
	end
	-- 名称
	if params.name then
		clubData.name = params.name
	end
	-- 简介
	if params.summary then
		clubData.summary = params.summary
	end
	-- 
	if params.P then
		clubData.users_P = params.P
	end

	-- 等级
	if params.level then
		clubData.level = params.level
	end

	-- 人数上限
	if params.users_limit then
		clubData.users_limit = params.users_limit
	end

	-- 编辑头像地址
	if params.avatar then
		local path = device.writablePath .. clubData.avatar
		if cc.FileUtils:getInstance():isFileExist(path) then
			cc.FileUtils:getInstance():removeFile(path)
		end
		clubData.avatar = params.avatar
	end

	-- 战队
	if params.exist_team then
		clubData.exist_team = params.exist_team
	end

	-- 俱乐部管理员
	if params.manager_count then
		clubData.manager_count = params.manager_count
	end

	ClubCtrol.setClubInfo( clubData )
end

-- 添加俱乐部相册
function ClubCtrol.addClubPhotos( img )
	local clubData = ClubCtrol.getClubInfo()

	table.insert(clubData.club_bg, img)
	ClubCtrol.setClubInfo( clubData )
end

-- 删除俱乐部相册
function ClubCtrol.deleteClubPhotos( img )
	local clubData = ClubCtrol.getClubInfo()
	for k,v in pairs(clubData.club_bg) do
		if v == img then
			table.remove(clubData.club_bg, k)
			break
		end
	end
	ClubCtrol.setClubInfo( clubData )
end

-- 修改俱乐部相册
function ClubCtrol.replaceClubPhotos( newImgs, oldImgs )
	local data = ClubCtrol.getClubInfo()
	for k,v in pairs(data.club_bg) do
		if v == oldImgs then
			local path = device.writablePath .. oldImgs
			local big_path = device.writablePath .. "big_" .. oldImgs
			data.club_bg[k] = newImgs
			if cc.FileUtils:getInstance():isFileExist(path) then
				cc.FileUtils:getInstance():removeFile(path)
				cc.FileUtils:getInstance():removeFile(big_path)
			end
			break
		end
	end
	ClubCtrol.setClubInfo( data )
end

-- 俱乐部任务
function ClubCtrol.getTaskData(  )
	local taskData = require("club.taskTable")
	return taskData
end

-- 俱乐部邀请好友
function ClubCtrol.dataSataInvite( funback )
	local function response( data )
		dump(data)
		if data.code == 0 then
			if data.data then
				ClubCtrol.buildFriendlist( data.data )
				funback()
			end
		end
	end
	local tabData = {}
	XMLHttp.requestHttp("club_filter_user", tabData, response, PHP_POST)
end

function ClubCtrol.buildFriendlist( data )
	local tmpData = data
	local friendTab = {}
	
	for k,v in pairs(tmpData) do
		for key,val in pairs(v) do
			local tmpTab = {}
			tmpTab = val
			tmpTab["check"] = 0
			tmpTab["key"] = string.upper(k)
			if key == 1 then
				tmpTab["first"] = 1
			else
				tmpTab["first"] = 0
			end
			table.insert(friendTab, 1, tmpTab)
		end
	end
	ClubCtrol.setFriendList( friendTab )
end

function ClubCtrol.setFriendList( data )
	-- dump(data)
	local tmpTab1 = {}
	local tmpTab2 = {}
	invite_user = {}
	table.sort(data, function ( a, b )
		if a.key == b.key then
			return a.first >= b.first
		else
			return string.byte(a.key) < string.byte(b.key)
		end
	end)
	for k,v in pairs(data) do
		if v.key == "#" then
			tmpTab1[#tmpTab1+1] = v
		else
			tmpTab2[#tmpTab2+1] = v
		end
		if k == #data then
			if #tmpTab1 == 0 then
				invite_user = tmpTab2
			else
				for k1,v1 in pairs(tmpTab1) do
					tmpTab2[#tmpTab2+1] = v1
					if k1 == #tmpTab1 then
						invite_user = tmpTab2
					end
				end
			end
		end
	end
	-- dump(invite_user)
end

function ClubCtrol.getFriendList(  )
	return invite_user
end

-- 请求俱乐部成员列表
function ClubCtrol.dataStatMember( funback )
	local clubData = ClubCtrol.getClubInfo()
	local function response( data )
		dump(data)
		if data.code == 0 then
			ClubCtrol.setMemberList( data.data )
			if funback then
				funback()
			end
		end
	end
	local tabData = {}
	tabData['club_id'] = clubData.id
	XMLHttp.requestHttp(PHP_CLUB_MEMBER, tabData, response, PHP_POST)
end

function ClubCtrol.setMemberList( data )
	cmember_list = {}
	local tmpTab = data
	-- 创始、管理员、普通成员
	local tC, tM, tG = {}, {}, {}
	for i=1,#tmpTab do
		local tmp = {}
		tmp = tmpTab[i]
		if tonumber(tmpTab[i].flag) == 1 then
			tmp['state'] = 1
			tC[#tC+1] = tmp
		elseif tonumber(tmpTab[i].flag) == 3 then
			tmp['state'] = 2
			tM[#tM+1] = tmp
		elseif tonumber(tmpTab[i].flag) == 0 then
			tmp['state'] = 3
			tG[#tG+1] = tmp
		end
	end
	local _tab = {tC, tM, tG}
	local function buildTab( tab )
		local tmp = tab
		if not tmp then
			return {}
		end
		for i=1,#tmp do
			tmp[i]['count'] = #tmp
			if i == 1 then
				tmp[i]['frist'] = 1
			else
				tmp[i]['frist'] = 0
			end
		end
		return tmp
	end
	for i=1,#_tab do
		local btab = {}
		btab = buildTab(_tab[i])
		for i,v in ipairs(btab) do
			cmember_list[#cmember_list+1] = v
		end
	end
	table.sort(cmember_list, function ( a, b )
		if a.state == b.state then
			return a.frist > b.frist
		else
			return a.state < b.state
		end
	end)
end

function ClubCtrol.getMemberList(  )
	return cmember_list
end

-- 请求俱乐部管理员
function ClubCtrol.dataStatMana( funback )
	local clubData = ClubCtrol.getClubInfo()
	local function response( data )
		-- dump(data)
		if data.code == 0 then
			ClubCtrol.setManaList( data.data )
			if funback then
				funback()
			end
		end
	end
	local tabData = {}
	tabData['club_id'] = clubData.id
	XMLHttp.requestHttp("clubManagerList", tabData, response, PHP_POST)
end

function ClubCtrol.setManaList( data )
	cmana_list = {}
	cmana_list = data
end

function ClubCtrol.getManaList(  )
	return cmana_list
end

return ClubCtrol