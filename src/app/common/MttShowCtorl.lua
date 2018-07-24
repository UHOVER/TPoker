local MttShowCtorl = {}

MttShowCtorl.MTT_STATUS = 1
MttShowCtorl.MTT_PLAYER = 2
MttShowCtorl.MTT_TABLE 	= 3
MttShowCtorl.MTT_AWARD	= 4
MttShowCtorl.MTT_MANAGE	= 5

local statusData = {}
local playerData = {}
local tableData  = {}
local awardData  = {}
local manageData = {}

local baseData = {}

local buildPlayer = {}

local isMttShow = false

function MttShowCtorl.setMttShow( isShow )
	isMttShow = isShow
end

function MttShowCtorl.isMttShow(  )
	return isMttShow
end

function MttShowCtorl.setBaseData( data )
	baseData = {}
	baseData = data
end

function MttShowCtorl.getBaseData(  )
	return baseData
end

function MttShowCtorl.getCurBind( bindTag, level )
	local bind = {}
	-- print("&&&&&&&&&&&&&  bindTag   " .. bindTag)
	bind = require("common.bindsArr")[bindTag]
	-- dump(bind)
	if bind == nil then
		return
	end
	for i,v in ipairs(bind) do
		if i == level then
			if level == #bind then
				return bind[i], bind[i]
			end
			return bind[i], bind[i+1]
		end
	end
end

function MttShowCtorl.getMttBlind( blindType, blindLevel, curLevel )
	local blindTab = DZConfig.getMttBlindTab()
	local curTab = {}
	curTab = blindTab[tostring(blindType)]["blind_"..tostring(blindLevel)]

	if next(curTab) == nil then
		return
	end
	for i,v in ipairs(curTab) do
		if i == curLevel then
			return curTab[curLevel]
		end
	end
end

-- MTT报名点击调用
function MttShowCtorl.MttSignUp( Tab, mttTag )
	dump(Tab)
	local currScene = cc.Director:getInstance():getRunningScene()
	local MttShowLayer = require("common.MttShowLayer"):create()
	local function onNodeEvent(event)
		if event == "enter" then
			MttShowCtorl.setMttShow( true )
			MttShowCtorl.setBaseData( Tab )
			print("%%%%%%%%%%%%:MTT展示界面 进入")
		elseif event == "exit" then
			print("%%%%%%%%%%%%:MTT展示界面 退出")
			NoticeCtrol.removeNoticeById( 40001 )
			MttShowCtorl.setBaseData( {} )
			MttShowLayer.clearSchedule()
			MttShowCtorl.setMttShow( false )
		end
	end
	MttShowLayer:registerScriptHandler(onNodeEvent)
	MttShowLayer:setName("MttShow")
	if currScene:getChildByName("MttShow") then
		print("MttShowLayer已经存在，不能添加")
		return
	end
	currScene:addChild(MttShowLayer, StringUtils.getMaxZOrder(currScene))
	MttShowLayer:createLayer(Tab, mttTag)
end

-- MTT牌局状态界面数据
function MttShowCtorl.dataStatStatus( funBack, Tab )
	local function response( data )
		dump(data)
		if data.code == 0 then
			MttShowCtorl.setStatusData( data.data )
			funBack()
		end
	end
	local tabData = {}
	tabData["mtt_id"] = Tab.pokerId
	XMLHttp.requestHttp("mttStatus", tabData, response, PHP_POST)
end

-- MTT牌局玩家界面数据
function MttShowCtorl.dataStatPlayer( funBack, Tab )
	local function response( data )
		dump(data)
		if data.code == 0 then
			MttShowCtorl.setPlayerData( data.data )
			funBack()
		end
	end
	local tabData = {}
	tabData["mtt_id"] = Tab.pokerId
	XMLHttp.requestHttp("mttPlayers", tabData, response, PHP_POST)
end

-- MTT牌局牌桌界面数据
function MttShowCtorl.dataStatTable( funBack, Tab)
	local function response( data )
		dump(data)
		if data.code == 0 then
			MttShowCtorl.setTableData( data.data )
			funBack()
		end
	end
	local tabData = {}
	tabData["mtt_id"] = Tab.pokerId
	XMLHttp.requestHttp("mttTables", tabData, response, PHP_POST)
end

-- MTT牌局奖励界面数据
function MttShowCtorl.dataStatAward( funBack, Tab )
	local function response( data )
		dump(data)
		if data.code == 0 then
			MttShowCtorl.setAwardData( data.data )
			funBack()
		end
	end
	local tabData = {}
	tabData["mtt_id"] = Tab.pokerId
	XMLHttp.requestHttp("mttAwards", tabData, response, PHP_POST)
end

function MttShowCtorl.dataStatManage( funBack, Tab )
	local function response( data )
		dump(data)
		if data.code == 0 then
			MttShowCtorl.setManageData( data.data )
			funBack()
		end
	end
	local tabData = {}
	tabData["mtt_id"] = Tab.pokerId
	XMLHttp.requestHttp("getMttMatchManagersList", tabData, response, PHP_POST)
end

function MttShowCtorl.dataStatManageInfo( funBack, Tab )
	local function response( data )
		dump(data)
		if data.code == 0 then
			-- MttShowCtorl.setManageData( data.data )
			funBack(data.data)
		end
	end
	local tabData = {}
	tabData["mtt_id"] = Tab.pokerId
	tabData["club_id"] = Tab.club_id
	XMLHttp.requestHttp("getUnionMttMatchShareClubInfo", tabData, response, PHP_POST)
end

function MttShowCtorl.setStatusData( data )
	statusData = {}
	statusData = data
end

function MttShowCtorl.getStatusData(  )
	return statusData
end

function MttShowCtorl.setPlayerData( data )
	playerData = {}
	playerData = data
end

function MttShowCtorl.getPlayerData(  )
	return playerData
end

function MttShowCtorl.setTableData( data )
	tableData = {}
	tableData = data
end

function MttShowCtorl.getTableData(  )
	return tableData
end

function MttShowCtorl.setAwardData( data )
	awardData = {}
	awardData = data
end

function MttShowCtorl.getAwardData(  )
	return awardData
end

function MttShowCtorl.setManageData( data )
	manageData = {}
	manageData = data
end

function MttShowCtorl.getManageData(  )
	return manageData
end

-- 牌局名称
function MttShowCtorl.getMttName(  )
	return MttShowCtorl.getStatusData().mtt_name
end
-- 是否房主
function MttShowCtorl.isHost(  )
	if MttShowCtorl.getStatusData().is_host == 1 then
		return true
	else
		return false
	end
end
-- 是否管理员
function MttShowCtorl.isManager(  )
	if MttShowCtorl.getStatusData().is_manager == 1 then
		return true
	else
		return false
	end
end
-- 是否开启授权 true 开启，false 未开启
function MttShowCtorl.isAccess(  )
	if tonumber(MttShowCtorl.getStatusData().is_access) == 1 then
		return true
	else
		return false
	end
end
-- 赛事类型
function MttShowCtorl.getGameMod(  )
	return MttShowCtorl.getStatusData().game_mod
end
-- 盲注级别
function MttShowCtorl.getBlindLevel(  )
	return MttShowCtorl.getStatusData().entry_stop
end

-- 报名费
function MttShowCtorl.getMttEntryFee(  )
	local entryFee = MttShowCtorl.transNum(MttShowCtorl.getStatusData().entry_fee).."+"..MttShowCtorl.transNum(MttShowCtorl.getStatusData().entry_fee/10)
	return entryFee
end

function MttShowCtorl.transNum( num )
	local _num = tonumber(num)
	local str = ""
	if _num >= 10000 then
		str = tostring(_num/1000).."K"
	else
		str = tostring(_num)
	end
	return str
end

-- 搜索玩家
function MttShowCtorl.findPlayerByName( name )
	if name == "" then
		return false
	end
	local data = buildPlayer

	for i,v in ipairs(data) do
		if v.user_name == name then
			return true, v
		else
			if i == #data then
				return false
			end
		end
	end
end

function MttShowCtorl.buildPlayerData(  )
	buildPlayer = {}
	local entryData = {} 	-- 报名的玩家
	local playingData = {} 	-- 正在玩的玩家

	local tmpData = MttShowCtorl.getPlayerData(  ).mtt_players
	local cardStatus = tonumber(MttShowCtorl.getPlayerData(  ).status)
	for key,val in pairs(tmpData) do
		if next(val) ~= nil then
			for k,v in pairs(val) do
				local tmpTab = {}
				tmpTab = v
				if key == "accessed_players_data" then
					tmpTab["key"] = "entry"
					tmpTab["isAgree"] = 2
				elseif key == "players_data" then
					tmpTab["key"] = "playing"
					tmpTab["rank"] = k
					tmpTab["cardStatus"] = cardStatus
				end
				buildPlayer[#buildPlayer+1] = tmpTab
			end
		end
	end
	return buildPlayer
end

-- HTTP 报名MTT
function MttShowCtorl.httpEntry( tab, funBack )
	local cardStatus = MttShowCtorl.getStatusData(  )

	local function response( data )
		dump(data)
		if data.code == 0 then
			-- 报名完成核查记分牌
			-- MainCtrol.checkUserScores()
			if data['scores'] then
				Single:playerModel():setPBetNum(data['scores'])
			end
			
			funBack(data.data)
		end
	end
	local tabData = {}
	tabData["mtt_id"] = tab.pokerId
	if cardStatus.game_mod == "43" then
		tabData["group_id"] = tab.groupID or 0
	end
	if cardStatus.game_mod == "mtt_general" then
		if cardStatus.invite_code then
			tabData["invite_code"] = cardStatus.invite_code
		end
	end
	
	local isGPSPoker = false
	if tonumber(cardStatus.open_gps) == 1 then
		isGPSPoker = true
	else
		isGPSPoker = false
	end
	Single:paltform():getLatitudeAndLongitude(function( j, w )
		tabData['longitude'] = j
		tabData['latitude'] = w
		XMLHttp.requestHttp("mttApply", tabData, response, PHP_POST)
	end, isGPSPoker)
end

-- 取消报名
function MttShowCtorl.httpCancelEntry( mtt_id, funBack )
	local function response( data )
		dump(data)
		if data.code == 0 then
			funBack()
		end
	end
	local tabData = {}
	tabData["mtt_id"] = mtt_id
	XMLHttp.requestHttp("mttCancelEntry", tabData, response, PHP_POST)
end

-- MTT回到游戏
function MttShowCtorl.BackMatch( mtt_id, funBack )
	local GameWait = require("game.GameWait")
	local base = MttShowCtorl.getBaseData(  )
	local group_id = base.groupID or nil
	GameWait.intoWaitScene(mtt_id, group_id )
end

-- 授权
function MttShowCtorl.setMttAccess( mtt_id, isAccess, funcBack )
	local function response( data )
		dump(data)
	end
	local tabData = {}
	tabData["mtt_id"] = mtt_id
	tabData["mtt_access"] = isAccess
	XMLHttp.requestHttp("mttAccess", tabData, response, PHP_POST)
end

function MttShowCtorl.getMttStatus( pokerId, funBack )
	-- local tab = MttShowCtorl.getBaseData()
	local function response( data )
		dump(data)
		if data.code == 0 then
			funBack(data.data)
		end
	end
	local tabData = {}
	tabData["mtt_id"] = pokerId
	XMLHttp.requestHttp("getMttCurrentStatus", tabData, response, PHP_POST)
end

-- 赛事开始时广播
function MttShowCtorl.broEnterGame( gid )
	local isMtt = MttShowCtorl.isMttShow()
	local mttId = MttShowCtorl.getStatusData().id
	if isMtt then
		if tonumber(gid) == tonumber(mttId) then
			-- print("%%%%%%%%%%%%:MTT进入游戏 ")
			MttShowCtorl.BackMatch( gid )
		end
	end
end

-- 赛事人数不足解散调用
function MttShowCtorl.broDissolve( gid )
	local mttId = MttShowCtorl.getStatusData().id
	local CardScene = require("cards.CardScene")
	if tonumber(gid) == tonumber(mttId) then
		local MttShowLayer = require("common.MttShowLayer")
		MttShowLayer.clearSchedule(true)
		
		local tip = "比赛开始时参赛人员不足6人,无法正常开赛,系统自动解散并返还全部报名费。"
		ViewCtrol.popHint({popType = 1, bgSize = cc.size(display.width-100, 400), content = tip, sureFunBack = function()
			CardScene:startScene()
		end})
	end
end

-- 后台回来请求刷新
function MttShowCtorl.connectMttStat( data )
	local isMtt = MttShowCtorl.isMttShow()
	if isMtt then
		print("重新请求MTT展示界面数据")
		local MttShowLayer = require("common.MttShowLayer")
		local tab = MttShowCtorl.getBaseData()
		if data then
			if tonumber(data.mtt_id) == tonumber(tab.pokerId) then
				MttShowLayer.updateMttTime( tab )
			end
		else
			MttShowLayer.updateMttTime( tab )
		end
	end
end

-- 更新MTT玩家
function MttShowCtorl.updatePlayer( data )
	local MttShowLayer = require("common.MttShowLayer")
	local tab = MttShowCtorl.getBaseData()
	if tonumber(data.mtt_id) == tonumber(tab.pokerId) then
		MttShowLayer.updatePlayer( tab )
	end
end

return MttShowCtorl