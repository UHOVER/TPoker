local MineCtrol = {}

local mineInfo = {}

local friendList = {}

local friendData = {}

local letterTab = {}

local circleList = {}

local circle_id = nil

local circleInfo = {}

-- 标示新建圈子、查看已有圈子
-- true 新建圈子
local circleFlag = true

-- 进入圈子的方式
-- message, circlelist
local circle_way = nil

-- 战队-------
local teamData = {}
-- 战队-------

-- 用户个人信息

function MineCtrol.dataStatMine( funback )
	local function xmlResponse(data)
		if data.code == 0 then
			--获取个人信息请求
			local mdata = data.data
			local spm = Single:playerModel()
			local headurl = mdata['headimg']

			--设置用户数据
			spm:setPName(mdata['username'])
			spm:setId(mdata['id'])
			spm:setRYId(mdata['rongyun_id'])
			-- spm:setPBetNum(mdata['scores'])
			spm:setPSex(mdata['sex'])
			spm:setPHeadUrl(headurl)
			spm:setPNumber(mdata['u_no'])
			MineCtrol.setMineInfo(data.data)

			--storage
			Storage.setStorageImgHeadUrl(DZConfig.getImgHeadUrl())
			Storage.setStorageUserName(mdata['username'])
			Storage.setStorageUserId(mdata['id'])
			Storage.setStorageUserHeadUrl(headurl)
			if funback then
				funback()
			end
		end
	end
	local tabData = ''
	XMLHttp.requestHttp(PHP_GET_MSG, tabData, xmlResponse, PHP_GET)
end

function MineCtrol.setMineInfo( data )
	mineInfo = data
end

-- 获取用户个人信息

function MineCtrol.getMineInfo(  )
	return mineInfo
end

function MineCtrol.dataStatUnion( funback )
	local function response( data )
		dump(data)
		funback(data.data)
	end
	XMLHttp.requestHttp("refreshUnion", {}, response, PHP_POST)
end

--[[
**************************************************************************
* NAME OF THE BUG : YDWX_DZ_ZHANGXINMIN_BUG _20160629 _004 
* DESCRIPTION OF THE BUG : Name is not updated  
* MODIFIED BY : 王礼宁
* DATE :2016-7-15
*************************************************************************/
]]

-- 编辑个人信息

function MineCtrol.editInfo( params )
	local mineData = MineCtrol.getMineInfo()
	local spm = Single:playerModel()

	-- 修改钻石
	if params.diamonds then
		mineData.diamonds = params.diamonds
	end

	-- 修改积分
	if params.scores then
		mineData.scores = params.scores
	end

	-- 修改名称
	if params.name then
		mineData.username = params.name

		-- mineData.username_flag = tonumber(mineData.username_flag) + 1
		
		spm:setPName(params.name)
		--storage
		Storage.setStorageUserName(params.name)
	end
	-- 修改个性签名
	if params.personsign then
		mineData.personsign = params.personsign
	end
	-- 修改性别
	if params.sex then
		mineData.sex = params.sex
	end
	-- 修改国家、地区
	if params.countryid then
		mineData.countryid = params.countryid
	end
	-- 修改头像
	if params.headimg then
		local url = params.headimg
		mineData.headimg = url


		spm:setPHeadUrl(url)
		--storage
		Storage.setStorageUserHeadUrl(url)
	end
	-- 添加背景相册
	if params.imgs then
		local tab = {}
		tab["id"] = params.id
		tab["background"] = params.imgs
		table.insert(mineData.players_imgs, tab)
	end
	-- 删除背景相册
	if params.imgs_d then
		for k,v in pairs(mineData.players_imgs) do
			if v.id == params.imgs_d.id then
				table.remove(mineData.players_imgs, k)
				break
			end
		end
	end
	if params.exist_team then
		mineData.exist_team = params.exist_team
		local ClubCtrol = require("club.ClubCtrol")
		local tmp = ClubCtrol.getClubInfo()
		ClubCtrol.editClubInfo({club_id = tmp.id, exist_team = params.exist_team})
	end

	MineCtrol.setMineInfo( mineData )
end

-- 替换个人背景相册
function MineCtrol.replaceImg( new_img, old_img )
	local data = MineCtrol.getMineInfo()
	
	for k,v in ipairs(data.players_imgs) do
		if v.id == old_img.id then
			data.players_imgs[k].background = new_img
			local path = device.writablePath ..old_img.background
			if cc.FileUtils:getInstance():isFileExist(path) then
				cc.FileUtils:getInstance():removeFile(path)
			end
			break
		end
	end
	-- dump(data.imgs)
	MineCtrol.setMineInfo(data)
end

--[[
**************************************************************************
* NAME OF THE BUG : YDWX_DZ_ZHANGXINMIN_BUG _20160629 _004 
* DESCRIPTION OF THE BUG : Name is not updated  
* MODIFIED BY : 王礼宁
* DATE :2016-7-15
*************************************************************************/
]]

-- 好友列表

function MineCtrol.setFriendList( data )
	dump(data)
	local tmpTab1 = {}
	local tmpTab2 = {}
	friendList = {}

	table.sort(data, function ( a, b )
		if a.key_byte == b.key_byte then
			return a.first > b.first
		else
			return a.key_byte < b.key_byte
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
				friendList = tmpTab2
			else
				for k1,v1 in pairs(tmpTab1) do
					tmpTab2[#tmpTab2+1] = v1
					if k1 == #tmpTab1 then
						friendList = tmpTab2
					end
				end
			end
		end
	end
	dump(friendList)
end

-- 获取好友列表

function MineCtrol.getFriendList(  )
	return friendList
end

-- 请求好友数据
function MineCtrol.dataStatFriendList( funback )
	local function response( data )
		dump(data.data)
		if data.code == 0 then
			MineCtrol.buildFriendlist( data.data )
			funback()
		end
	end
	local tabData = {}
	XMLHttp.requestHttp(PHP_FRIEND_LIST, tabData, response, PHP_POST)
end

-- 获取添加好友消息
function MineCtrol.dataStatFriendMsg( funback )
	local msgData = {}
	local function response( data )
		dump(data)
		if data.code == 0 then
			if #data.data == 0 then
				funback(data.data)
			else
				for k,v in pairs(data.data) do
					local tmpTab = {}
					tmpTab = v
					tmpTab["check"] = 0
					msgData[#msgData+1] = tmpTab
					if k == #data.data then
						funback(msgData)
					end
				end
			end
		end
	end
	local tabData = {}
	XMLHttp.requestHttp('message_list', tabData, response, PHP_POST)
end

-- 好友列表数据整理

function MineCtrol.buildFriendlist( data )
	local tmpData = data
	local friendTab = {}
	letterTab = {}
	
	for k,v in pairs(tmpData) do
		MineCtrol.addLetter( string.upper(k) )
		for key,val in ipairs(v) do
			local tmpTab = {}
			tmpTab = val
			tmpTab["key"] = string.upper(k)
			tmpTab["key_byte"] = string.byte(string.upper(k))
			if key == 1 then
				tmpTab["first"] = 2
			elseif key == (#v) then
				tmpTab["first"] = 0
			else
				tmpTab["first"] = 1
			end
			table.insert(friendTab, 1, tmpTab)
		end
	end

	MineCtrol.setFriendList( friendTab )
	return friendTab
end

function MineCtrol.addLetter( letter )
	if #letterTab == 0 then
		table.insert(letterTab, 1, letter)
	else
		for k,v in pairs(letterTab) do
			if v == letter then
				break
			else
				if k == #letterTab then
					table.insert(letterTab, 1, letter)
					break
				end
			end
		end
	end
end

function MineCtrol.getLetter(  )
	-- dump(letterTab)
	table.sort(letterTab, function ( a, b )
		return string.byte(a) > string.byte(b)
	end)
	-- dump(letterTab)
	local tab = {}
	local str = ""
	for i,v in ipairs(letterTab) do
		-- print(">>>>>: "..string.byte(v))
		if v == "#" then
			str = v
		else
			tab[#tab+1] = v
		end
	end
	-- dump(tab)
	if str ~= "" then
		table.insert(tab, 1, str)
	end
	letterTab = tab
	return letterTab
end

function MineCtrol.deleteFriend( id )
	local data = MineCtrol.getFriendList(  )
	for k,v in pairs(data) do
		if v.id == id then
			table.remove(data, k)
			break
		end
	end
	MineCtrol.setFriendList(data)
end

-- 圈子列表

function MineCtrol.dataStatCircleList( funback )
	local function response( data )
		dump(data)
		if data.code == 0 then
			MineCtrol.setCircleList(data.data)
			funback()
		end
	end
	local tabData = {}
	XMLHttp.requestHttp("get_allcircle", tabData, response, PHP_POST)
end

function MineCtrol.setCircleList( data )
	circleList = {}
	circleList = data
end

function MineCtrol.getCircleList(  )
	return circleList
end

function MineCtrol.editCircleList( data )
	local circleTab = MineCtrol.getCircleList()
	for k,v in pairs(circleTab) do
		if v.id == data.id then
			if data.name then
				circleTab[k].circle_nickname = data.name
			end
			if data.img then
				circleTab[k].avatar = data.img
			end
			break
		end
	end
	MineCtrol.setCircleList(circleTab)
end

-- 删除、退出圈子
function MineCtrol.deleteCircleList( id )
	local data = MineCtrol.getCircleList()
	for k,v in pairs(data) do
		if v.id == id then
			table.remove(data, k)
			break
		end
	end
	MineCtrol.setCircleList( data )
end


-- 圈子ID
function MineCtrol.setCircleId( id )
	circle_id = id
end

function MineCtrol.getCircleId(  )
	return circle_id
end

-- 圈子详情请求
function MineCtrol.dataStatCircle( funback )
	local function response( data )
		dump(data.data)
		if data.code then
			MineCtrol.setCircleInfo( data.data )
			funback()
		end
	end
	local tabData = {}
	tabData["circle_id"] = MineCtrol.getCircleId()
	XMLHttp.requestHttp("circleDetail", tabData, response, PHP_POST)
end

-- 圈子详情
function MineCtrol.setCircleInfo( data )
	circleInfo = {}
	circleInfo = data
end

function MineCtrol.getCircleInfo(  )
	return circleInfo
end


-- 新建圈子、 查看已有圈子 flag
function MineCtrol.setCircleFlag( flag )
	circleFlag = flag
end

function MineCtrol.getCircleFlag(  )
	return circleFlag
end


-- 创建圈子方式

function MineCtrol.createCircleWay( way )
	circle_way = way
end

function MineCtrol.getCircleWay(  )
	return circle_way
end

-- 编辑圈子详情
function MineCtrol.editCircleInfo( params )
	local circleTab = MineCtrol.getCircleInfo()
	
	params["id"] = MineCtrol.getCircleId()

	if params.name then
		circleTab.circle_nickname = params.name
		MineCtrol.editCircleList(params)
	end

	if params.img then
		circleTab.avatar = params.img
		MineCtrol.editCircleList(params)
	end

	if params.player then
		for k,v in pairs(params.player) do
			table.insert(circleTab.playerInfo, v)
		end
	end

	if params.playerId then
		print(params.playerId)
		for k,v in pairs(circleTab.playerInfo) do
			dump(v)
			if v.player_id == params.playerId then
				table.remove(circleTab.playerInfo, k)
				break
			end
		end
	end

	
	MineCtrol.setCircleInfo(circleTab)
end

--------------------------------
-- 请求商城数据
function MineCtrol.dataStatShop( funback )
	local function response( data )
		dump(data)
		if data.code == 0 then
			funback(data.data)
		end
	end
	local tabData = {}
	XMLHttp.requestHttp('diamondsToScoresList', tabData, response, PHP_POST)
end

-- 充值数据
function MineCtrol.dataStatPay( funback )
	local function response( data )
		dump(data)
		if data.code == 0 then
			funback(data)
		end
	end
	local tabData = {}
	XMLHttp.requestHttp('moneyToDiaList', tabData, response, PHP_POST)
end

-- 战队详情
function MineCtrol.dataStatTeam( teamId, funback )
	local function response( data )
		dump(data)
		if data.code == 0 then
			funback(data.data)
			MineCtrol.setTeamData(data.data)
		end
	end
	local tabData = {}
	tabData["team_id"] = teamId
	XMLHttp.requestHttp("get_team_detail", tabData, response, PHP_POST)
end

-- 存储team
function MineCtrol.setTeamData(data)
	teamData = {}
	teamData = data
end

-- 获取team
function MineCtrol.getTeamData(  )
	return teamData
end

-- 编辑team
function MineCtrol.editTeamData( tab )
	local tmpTab = MineCtrol.getTeamData()

	if tab.team_name then
		tmpTab.team_name = tab.team_name
	end
	if tab.team_logo then
		tmpTab.team_logo = tab.team_logo
	end
	MineCtrol.setTeamData( tmpTab )
end

-- 判断是否有战队
function MineCtrol.judgeTeam( funback )
	local function response( data )
		dump(data)
		if data.code == 0 then
			funback(data.data)
		end
	end
	local tabData = {}
	XMLHttp.requestHttp("get_allTeam", tabData, response, PHP_POST)
end

return MineCtrol