 -- YDWX_DZ_LIJIANBO_BUG_20160629 _001  

local UnionCtrol = {}

local unionInfo = {} 	--- 10.6.0 piror 联盟详情
local unionMember = {}

local unionDetail = {}  -- 10.6.0 联盟详情
local unionClubMember = {}

----------------------------
--牌局类型 10.6.0 later
----------------------------
UnionCtrol.game = {
    stand = 41,
    sng = 42,
    mtt = 43,
    --标记标题文字  字符串Key
    ["41"] = "标准牌局",
    ["42"] = "SNG牌局",
    ["43"] = "MTT牌局",
    --标记字符串转换 int key
    [41] = "general",
    [42] = "sng",
    [43] = "mtt"
}
----------------------------
--入口10.6.0 later
----------------------------
UnionCtrol.mine_union = 1
UnionCtrol.club_union = 2

local _union_from = 0
function UnionCtrol.setVisitFrom(from)
	_union_from = from
    print("_union_from:".._union_from)
end

function UnionCtrol.getVisitFrom()
	return _union_from
end

------------------------------
-- 用户创建 10.6.0 later
-----------------------------
UnionCtrol.access_mine_nothing = 0 --无法创建
UnionCtrol.access_mine_create = 1  --可以创建联盟
UnionCtrol.access_mine_lookup = 2  --可以查看（已创建）
--匹配对应的权限
function UnionCtrol.isMatchAccess(_access)
	print("_visit_access", unionDetail.unionflag,"_access", _access, tostring("0" == 0))
	if not unionDetail then
     return false 
    end
    if tonumber(unionDetail.unionflag) == _access then 
        return true
    end
end

------------------------------
-- 用户身份 & 权限 10.6.0 later
------------------------------
-- 设置联盟权限


-- 联盟最多32个管理员
UnionCtrol.LIMIT_ADMIN_COUNT = 32 


--[[身份]]
UnionCtrol.STATUS_HEAD  = 1 -- 盟主
UnionCtrol.STATUS_U_ADMIN = 2 --联盟管理员 [理论上这里应该分为初级，中级，高级]
UnionCtrol.STATUS_C_HEAD = 3  --俱头
UnionCtrol.STATUS_C_ADMIN = 4 --俱乐部管理员
UnionCtrol.STATUS_MEMBER = 5--普通成员
local _status = UnionCtrol.STATUS_MEMBER
function UnionCtrol.isStatus(_userStatus)
    return _status == _userStatus
end

--[[权限]]
UnionCtrol.Auth_CREATE = 100 		--创建权限
UnionCtrol.Auth_SETTLE = 200 		--结算权限
UnionCtrol.Auth_ADD_MEM= 300 		--添加成员权限
UnionCtrol.Auth_REV_MEM= 400 		--删除权限
UnionCtrol.Auth_Club_Edit = 500		 --俱乐部编辑权限
UnionCtrol.Auth_URace_Ago = 600   --查看历史牌局
--[[俱乐部权限判断]]
-- 212：历史牌局；213：结算牌局
UnionCtrol.Auth_Club_Race = 212   --历史牌局
UnionCtrol.Auth_Club_Settle = 213  --结算牌局

--联盟与俱乐部各自只有一套权限表，_status is identity and auths is Array
function UnionCtrol.isHasAuth(_iAuth) 
    if _status == UnionCtrol.STATUS_HEAD then 
        return true --盟主拥有所有权限
    end

    if _status == UnionCtrol.STATUS_C_HEAD then 
        return true --
    end
    local auths = unionDetail.manager_auth
    if not auths or not _iAuth then 
        print("您没有任何权限")
        return false
    end
    local idx = table.indexof(auths, tostring(_iAuth))
    print(idx)
    if idx then 
        return true
    end
    return false
end

----------------------------
-- 联盟是否创建 10.6.0 piror
----------------------------
local is_create = true
function UnionCtrol.setUnionIsCreate( isCreate )
	is_create = isCreate
end

function UnionCtrol.getUnionIsCreate(  )
	return is_create
end

-- 查看联盟详情 10.6.0 piror
function UnionCtrol.dataStatUnionTab( funback )
	local function response( data )
		if data.code == 0 then
			UnionCtrol.setUnionInfo( data.data)
			funback()
		end
	end
	local tabData = {}
	tabData['union_id'] = UnionCtrol.getUnionInfo()["union_id"]
	XMLHttp.requestHttp( "detail_union", tabData, response, PHP_POST )
end

function UnionCtrol.setUnionInfo( data )
	-- unionInfo = {}
	unionInfo = data or {}
	-- unionInfo["count_cur"] = data.clubs_num or 1
	-- unionInfo["count_limit"] = ""
end

function UnionCtrol.getUnionInfo(  )
	return unionInfo
end

function UnionCtrol.editUnionInfo( params )
	local unionInfo = UnionCtrol.getUnionDetail()
	if type(params) ~= "table" then
		return
	end
    local imgArrs = unionInfo.imgs or unionInfo.union_background_img
	-- 插入
	if params.imgs then
		table.insert(imgArrs, params.imgs)
	end
	-- 删除
	if params.imgs_d then
		local path = device.writablePath .. params.imgs_d
		local big_path = device.writablePath .. "big_" .. params.imgs_d
		for k,v in pairs(imgArrs) do
			if v == params.imgs_d then
				table.remove(imgArrs, k)
				break
			end
		end
	end

    if unionInfo.imgs then 
        unionInfo.imgs = imgArrs
    end
    unionInfo.union_background_img = imgArrs

	if params.unionName then
		unionInfo.union_name = params.unionName
	end
	if params.discribe then
		unionInfo.describe = params.discribe
	end
	if params.avatar then
		unionInfo.union_avatar = params.avatar
	end
    if params.union_managers then 
        unionInfo.union_managers = params.union_managers
    end
end


function UnionCtrol.setUnionDetail( data )
	unionDetail = data or {}
    unionInfo = data or {}
end

function UnionCtrol.getUnionDetail( )
	return unionDetail
end

function UnionCtrol.setUnionClubMember(data)
	unionClubMember = data or {}
    unionMember = data or {}
end
function UnionCtrol.getUnionCMember(funback)
	return unionClubMember
end

--TODO:tanhaiting need fix 10.6.0 later 新旧联盟信息数据问题 getUnionInfo & getUnionDetail
function UnionCtrol.replaceImgs( newImgs, oldImgs )
	local data = UnionCtrol.getUnionInfo()
    local imgArrs = data.imgs or data.union_background_img
	for k,v in pairs(imgArrs) do
		if v == oldImgs then
			imgArrs[k] = newImgs
			local path = device.writablePath .. oldImgs
			local big_path = device.writablePath .. "big_" .. oldImgs
			if cc.FileUtils:getInstance():isFileExist(path) then
				cc.FileUtils:getInstance():removeFile(path)
				cc.FileUtils:getInstance():removeFile(big_path)
			end
			break
		end
	end
    if data.imgs then data.imgs = imgArrs end
    if data.union_background_img then data.union_background_img = imgArrs end

	UnionCtrol.setUnionDetail(data)
end

-- 联盟成员
function UnionCtrol.dataStatUnionMember( funback )
	local function response( data )
		if data.data then
			UnionCtrol.setUnionMember( data.data )
			funback(data.clubs_num)
		end
	end
	local tabData = {}
	tabData["union_id"] = UnionCtrol.getUnionInfo()["union_id"]
	XMLHttp.requestHttp("union_club_list", tabData, response, PHP_POST)
end

function UnionCtrol.setUnionMember( data )
	unionMember = data
end

function UnionCtrol.getUnionMember(  )
	return unionMember
end

--成员
function UnionCtrol.buildMemberData(  )
	local unionList = UnionCtrol.getUnionMember()
	local tmpTab = {}
	for k,v in pairs(unionList) do
		v["check"] = 0
		table.insert(tmpTab, v)
	end
	return tmpTab
end

---------------------------network for union-------------------------------------------------------------------------
--请求联盟详情 10.6.0 later
function UnionCtrol.requestDetailUnion(funback)
    local function response( data)
        if  data.code ~= 0 then  return end
        local unionData = data.data
        _status = tonumber(unionData.user_identity)
        UnionCtrol.setUnionClubMember(unionData.clubs or {})
        unionData.clubs = nil
        UnionCtrol.setUnionDetail(unionData)
        funback()
    end 
    local tabData = {}
    XMLHttp.requestHttp( PHP_UNION_DETAIL, tabData, response, PHP_POST )
end
--请求联盟详情 --俱乐部入口
function UnionCtrol.requestDetailUnionForClub(clubId, unionId, funcback)
    local function response( data)
        if  data.code ~= 0 then  return end
        local unionData = data.data
        _status = tonumber(unionData.user_identity)
        local unionMember = {}
        unionMember[1] = unionData['club_info']
        UnionCtrol.setUnionClubMember(unionMember)
        
        unionData.club_info = nil
        UnionCtrol.setUnionDetail(unionData)
        funcback()
    end 
    local tabData = {}
    tabData['club_id'] = clubId
    tabData['union_id']= unionId
    XMLHttp.requestHttp( PHP_UNION_DETAIL_FROM_CLUB, tabData, response, PHP_POST )
end

--请求联盟牌局 10.6.0 later
function UnionCtrol.requestUnionRaces(fucback)
    local function response(data)
        if data.code == 0 then
            fucback(data.data)
        end
    end
    local tabData = {}
    XMLHttp.requestHttp( PHP_UNION_RACES, tabData, response, PHP_POST )
end

--请求联盟统计
--开始时间
--结束时间
function UnionCtrol.requestUnionStatictis(pre_span_day, fuc)
     local function response(data)
        if data.code == 0 then 
            fuc(data.data)
        end
    end
    if not unionDetail  then 
       print("咩有联盟数据")
       return
    end
    local tabData = {}
    -- tabData["startTime"] = startTime
    -- tabData["endTime"] = endTime
    if _union_from == UnionCtrol.club_union then 
        tabData['clubId'] = unionClubMember[1] and unionClubMember[1].club_id
    end
    -- 
    tabData['pre_span_day'] = pre_span_day
    tabData["unionId"] = unionDetail.union_id
    XMLHttp.requestHttp( PHP_UNION_STATICTIS, tabData, response, PHP_POST )
end

--请求联盟管理员
function UnionCtrol.requestUnionAdmin(funback)
    local function response(data)
        if data.code == 0 then 
            funback(data.data)
        end
    end

     if not unionDetail  then 
       print("咩有联盟数据")
       return
    end
    local tabData = {}
    
    XMLHttp.requestHttp( PHP_UNION_ADMIN_LIST, tabData, response, PHP_POST )
end
--union delete admin
function UnionCtrol.requestDelAdmins(admins, func)
    local function response(data)
        if data.code == 0 then 
            func(data.data)
        end
    end
    local tabData = {}
    tabData["managers"] = admins
    XMLHttp.requestHttp(php_UNION_DEL_ADMIN , tabData, response, PHP_POST )
end
--union search user
function UnionCtrol.requestSearchUser(userName, func)
    local function response(data)
        if data.code == 0 then 
            func(data.data)
        end
    end
    local tabData = {}
    tabData["user_name"] = userName
    XMLHttp.requestHttp(PHP_UNION_SEARCH_USER , tabData, response, PHP_POST )
end
--union add admin
function UnionCtrol.requestAddAdmin(userIds, lev, func)
    local function response(data)
        if data.code == 0 then 
            func(data.data)
        end
    end
    local tabData = {}
    tabData["grade"] = lev
    tabData['uids'] = userIds
    XMLHttp.requestHttp(PHP_UNION_ADD_ADMIN , tabData, response, PHP_POST )
end
--union set admin auth
function UnionCtrol.requestSetAdminAuth(lev, authlist, func)
    local function response(data)
        if data.code == 0 then 
            func(data.data)
        end
    end

    local tabData = {}
    tabData["manager_grade"] = lev
    tabData['manager_auth'] = authlist
    XMLHttp.requestHttp(PHP_UNION_SET_ADMIN_AUTH , tabData, response, PHP_POST )
end

--union get admin have auth
function UnionCtrol.requestGetAdminAuth(lev, func)
    local function response(data)
        if data.code == 0 then 
            func(data.data)
        end
    end
    local tabData = {}
    tabData['grade'] = lev
     XMLHttp.requestHttp(PHP_UNION_GET_ADMIN_AUTH , tabData, response, PHP_POST )
end

--union club info get 
function UnionCtrol.requestGetClubInfo(club_id, func)
     local function response(data)
        if data.code == 0 then 
            func(data.data)
        end
    end
    local tabData = {}
    tabData['club_id'] = club_id
    XMLHttp.requestHttp(PHP_UNION_GET_CLUB_INFO , tabData, response, PHP_POST )
end

--union club info set
function UnionCtrol.requestSetClubInfo(data, func)
     local function response(data)
        if data.code == 0 then 
            func(data.data)
        end
    end
    local tabData = data
    XMLHttp.requestHttp(PHP_UNION_SET_CLUB_INFO , tabData, response, PHP_POST )
end

-- del union club
function UnionCtrol.requestDelUnionClub(clubs, func)
    local function response(data)
        if data.code == 0 then 
            func(data.data)
        end
    end
    local tabData = {}
    tabData['club_ids'] = clubs
    tabData['union_id'] = unionDetail.union_id
    XMLHttp.requestHttp(PHP_UNION_DEL_CLUB , tabData, response, PHP_POST )
end

-- compel current club user leaved game 
-- next round go into effect 
function UnionCtrol.requestUnionFoceStandup(clubID, unionid, game_state, func)
    local function response(data)
        if data.code == 0 then 
            func(data.data)
        end
    end
    local tabData = {}
    tabData['club_id'] = clubID
    tabData['game_state'] = game_state
    tabData['union_id'] = unionid
    XMLHttp.requestHttp(PHP_UNION_FOCE_STANDUP , tabData, response, PHP_POST )
end

--dissolve union by 
function UnionCtrol.requestDissolveUnion(func)
    local function response(data)
        if data.code == 0 then 
            func(data.data)
        end
    end
    local tabData = {}
    tabData['union_id'] = unionDetail.union_id
    XMLHttp.requestHttp(PHP_UNION_DISSOVE , tabData, response, PHP_POST )
end

--require union game races
function UnionCtrol.requestUnionGameRaces(raceModel, game_mod, startPage, sTime, eTime, fuc, noWait)
    local function response(data)
        if data.code == 0 then 
            fuc(data.data)
        end
    end
    local tabData = {}
    tabData['select_type'] = raceModel
    tabData['game_list_type'] = game_mod
    tabData['page'] = startPage
    tabData['every_page'] = 15
    tabData['startTime'] = sTime
    tabData['endTime'] = eTime
    tabData['union_id'] = unionDetail['union_id']
    local suffix = nil
    if _union_from == UnionCtrol.club_union then 
        suffix = PHP_CLUB_RACE_RECORD
        tabData['club_id'] = unionClubMember[1] and unionClubMember[1].club_id
    else 
        suffix = PHP_UNION_RACE_RECORD
    end
    XMLHttp.requestHttp(suffix, tabData, response, PHP_POST, noWait)
end

--delete union history game races
function UnionCtrol.deleteUnionGameRaces(game_mod, pokerIds, func)
    local function response(data)
        if data.code == 0 then 
            
        end
    end

    local tabData = {}
    tabData['game_list_type'] = game_mod
    tabData['del_game_ids'] = pokerIds
    tabData['select_type'] = 1
    XMLHttp.requestHttp(PHP_UNION_DELETE_RACES, tabData, response, PHP_POST, noWait)
end

--获取联盟or俱乐部战绩-根据牌局id
function UnionCtrol.getUnionClubRecordByGID(senddata, fucback)
    local function response(data)
        if data.code == 0 then 
            fucback(data.data)
        end
    end

    local suffix = nil
    if _union_from == UnionCtrol.club_union then 
        suffix = PHP_CLUB_RECORD_GID
        senddata['clubid'] = unionClubMember[1] and unionClubMember[1].club_id
        senddata['unionid'] = unionDetail['union_id']
    else 
        suffix = PHP_UNION_RECORD_GID
    end
    XMLHttp.requestHttp(suffix, senddata, response, PHP_POST, true)
end

--获取俱乐部战绩-详情-根据牌局id，俱乐部id
function UnionCtrol.getUnionClubRecordDetailByGID(senddata, fucback)
     local function response(data)
        if data.code == 0 then 
            fucback(data.data)
        end
    end

     local suffix = nil
    if _union_from == UnionCtrol.club_union then 
        suffix = PHP_CLUB_RECORD_DETAIL_GID
        senddata['unionid'] = unionDetail['union_id']
    else 
        suffix = PHP_UNION_RECORD_DETAIL_GID
    end
    XMLHttp.requestHttp(suffix, senddata, response, PHP_POST, true)
end 

--获取一段时间范围内的俱乐部战绩
function UnionCtrol.getUnionClubRecordByTime(senddata, fucback)
    local function response(data)
        if data.code == 0 then 
            fucback(data.data)
        end
    end
    
    local suffix = nil
    if _union_from == UnionCtrol.club_union then 
        suffix = PHP_CLUB_RECORD_TIME
        senddata['club_id'] = unionClubMember[1] and unionClubMember[1].club_id
    else 
        suffix = PHP_UNION_RECORD_TIME
    end
    XMLHttp.requestHttp(suffix, senddata, response, PHP_POST, true)
end
--获取一段时间范围内的俱乐部战绩详情
function UnionCtrol.getUnionClubRecordDetailByTime(senddata, fucback)
    local function response(data)
        if data.code == 0 then 
            fucback(data.data)
        end
    end
    local suffix = nil
    if _union_from == UnionCtrol.club_union then 
        suffix = PHP_CLUB_RECORD_DETAIL_TIME
        senddata['clubid'] = unionClubMember[1] and unionClubMember[1].club_id
    else 
        suffix = PHP_UNION_RECORD_DETAIL_TIME
    end
    XMLHttp.requestHttp(suffix, senddata, response, PHP_POST,true)
end 

--联盟结算
function UnionCtrol.requrestSettleAccountForUnion(gameId, gmod, func)
     local function response(data)
        if data.code == 0 then 
            func(data.data)
        end
    end
    local tabData = {}
    tabData['gId'] = gameId
    tabData['gameType'] = gmod
    XMLHttp.requestHttp(PHP_UNION_SETTLED_UNION, tabData, response, PHP_POST)
end

--联盟结算
function UnionCtrol.requrestSettleAccountForClub(gameId, clubId, gmod, func)
     local function response(data)
        if data.code == 0 then 
            func(data.data)
        end
    end
    local tabData = {}
    tabData['gId'] = gameId
    tabData['clubId'] = clubId
    tabData['gameType'] = gmod
    XMLHttp.requestHttp(PHP_UNION_SETTLED_CLUB, tabData, response, PHP_POST)
end
return UnionCtrol

 -- YDWX_DZ_LIJIANBO_BUG_20160629 _001  