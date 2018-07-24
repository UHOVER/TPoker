local ViewBase = require('ui.ViewBase')
local ClubInfoPlus = class('ClubInfoPlus', ViewBase)

local ClubCtrol = require("club.ClubCtrol")
local UnionCtrol = require("union.UnionCtrol")

local _clubInfoPlus = nil

local message = {}
local title = nil
local viewSize = nil

local tab = {}
	tab['font'] = 'Arial'
	tab['size'] = 30
local club_id = nil
local Is_create = nil

-- 权限
local PERMIT = {}

local chatClubMsg = {}

-- 俱乐部消息
local clubMsg = nil
local redPoint_bg = nil

local function Callback(  )
	_clubInfoPlus:removeTransitAction()

	-- 初始化俱乐部详细数据
	ClubCtrol.setClubInfo( {} )

	DZChat.checkChat(club_id, StatusCode.CHAT_CLUB)
end

-- 编辑
local function editCallback( tag, sender )
	local clubEditInfo = require('club.ClubEditInfo')
	local layer = clubEditInfo:create()
	_clubInfoPlus:addChild(layer)
	layer:createLayer()
end

-- 消息
local function msgCallBack(  )
	local messageLayer = require('club.ClubMsg')
	local layer = messageLayer:create()
	_clubInfoPlus:addChild(layer)
	layer:createLayer( "club" )
end

-- 任务
local function taskCallback(  )
	print("俱乐部任务")
	local clubTask = require("club.ClubTask")
	local layer = clubTask:create()
	_clubInfoPlus:addChild(layer)
	layer:createLayer(club_id)
end

-- 成员
local function memberCallBack(  )
	ClubCtrol.dataStatMember( function (  )
		local memberList = require('club.MemberList')
		local layer = memberList:create()
		_clubInfoPlus:addChild(layer)
		layer:createLayer()
	end )
end

-- 战队
local function teamCallBack(  )
	-- 无战队
	local MineCtrol = require("mine.MineCtrol")
	if tonumber(message.exist_team) == 0 then
		if Is_create == 2 then 	-- 俱头
			MineCtrol.judgeTeam(function ( data )
				if data == 0 then
					local TeamNew = require("club.TeamNew")
					local layer = TeamNew:create()
					_clubInfoPlus:addChild(layer)
					layer:createLayer("new")
				else
					local MineTeam = require("mine.MineTeam")
					local layer = MineTeam:create()
					layer:setName("MineTeam")
					_clubInfoPlus:addChild(layer)
					layer:createLayer( 1, data )
				end
			end)
		elseif Is_create == 1 or Is_create == 3 then -- 非俱头
			return
		end
	-- 有战队
	else
		if Is_create == 2 then 	-- 俱头
			MineCtrol.dataStatTeam( message.exist_team, function ( data )
			    local MineTeam = require("mine.MineTeam")
			    local layer = MineTeam:create()
			    layer:setName("MineTeam")
			    _clubInfoPlus:addChild(layer)
			    layer:createLayer( 2, data )
			end )
		elseif Is_create == 1 or Is_create == 3 then -- 非俱头
			MineCtrol.judgeTeam(function ( data )
				if data == 0 then
					local function response( tab )
						dump(tab)
						if tab.code == 0 then
							local TeamList = require("club.TeamList")
							local layer = TeamList:create()
							_clubInfoPlus:addChild(layer)
							layer:createLayer(tab.data, data)
						end
					end
					local tabData = {}
					tabData["club_id"] = club_id
					XMLHttp.requestHttp("get_clubteam", tabData, response, PHP_POST)
				else
					if tonumber(data[1].team_id) == message.exist_team then
						MineCtrol.dataStatTeam( message.exist_team, function ( tab )
						    local MineTeam = require("mine.MineTeam")
						    local layer = MineTeam:create()
						    layer:setName("MineTeam")
						    _clubInfoPlus:addChild(layer)
						    layer:createLayer( 2, tab )
						end )
					else
						local function response( tab )
							dump(tab)
							if tab.code == 0 then
								local TeamList = require("club.TeamList")
								local layer = TeamList:create()
								_clubInfoPlus:addChild(layer)
								layer:createLayer(tab.data, data )
							end
						end
						local tabData = {}
						tabData["club_id"] = club_id
						XMLHttp.requestHttp("get_clubteam", tabData, response, PHP_POST)
					end
				end
			end)
		end
	end
end

local function unionCallback(  )
	--[[
		 "union_state": {
            "md": 1,
            "union_id": 482,
            "union_avatar": "0.770356001502850017956890.jpg",
            "union_name": "中天",
            "address": "110000",
            "show": "2",
            "fid": "0"
        }
	--]]
	--@@ union_state 有无联盟存在 	show：1 申请加入联盟 2 已有联盟可查看联盟详情 3 创建联盟
	if Is_create == 2 then
		if message.union_state.show == "2" then
			print("查看联盟")
			local DashBoardLayer = require("union.DashBoardLayer")
			DashBoardLayer.show(_clubInfoPlus, { clubId = club_id, unionId = message.union_state.union_id, from = UnionCtrol.club_union})
		else
			AddCtrol.setAddTarget( AddCtrol.UNION )
			local _cityLayer = require("main.CityLayer"):create("add")
			_clubInfoPlus:addChild(_cityLayer)
		end
	elseif Is_create == 3 then
		if PERMIT.PER_UNION then
			if message.union_state.show == "2" then
				print("查看联盟")
				local DashBoardLayer = require("union.DashBoardLayer")
				DashBoardLayer.show(_clubInfoPlus, { clubId = club_id, unionId = message.union_state.union_id, from = UnionCtrol.club_union})
			else
				ViewCtrol.showTip({content = "该俱乐部尚未加入任何联盟"})
			end
		end
	end
end

-- 分享
local function shareCallback(  )
	--[[if Is_create == 2 then
		print("邀请")
		ClubCtrol.dataSataInvite( function (  )
			local inviteFriend = require("club.InviteFriend")
			local layer = inviteFriend:create()
			_clubInfoPlus:addChild(layer)
			layer:createLayer()
		end )
	else
	end--]]
	print("分享")
	local _url = SHARE_URL
	local contentStr = Single:playerModel():getPName()..'邀请您加入“'..message.name..'”'.."俱乐部,ID号为:"..message.club_number
	DZWindow.shareDialog(DZWindow.SHARE_URL, {title = "欢迎来到"..DISPLAY_G_NAME, content = contentStr, url = _url})
end

local function cardCallback( isOk )
	local function response( data )
		-- dump(data)
		-- if data.code == 0 then
		-- end
	end
	local tabData = {}
	tabData["club_id"] = club_id
	tabData["club_key"] = "table_create_right"
	tabData["club_val"] = isOk
	XMLHttp.requestHttp("setClubSomeInfo", tabData, response, PHP_POST)
end

-- 新消息通知
local function newsCallback( isOk )
	local myId = Single:playerModel():getId()
	local key = myId .. chatClubMsg.ryid
	print("%%%%%% " .. isOk .." %%%%%%% " .. key)
	local value = isOk
	Storage.setStringForKey(key, value)
end

-- 活跃统计
local function activityFunc(  )
	local ActivityCtorl = require("common.ActivityCtorl")
	ActivityCtorl.setActFlag(true)
	
	ActivityCtorl.dataStatGroupActivity( ActivityCtorl.ACT_CLUB, club_id, function ( )
		local actTotal = require("common.ActivityTotal")
		local layer = actTotal:create()
		_clubInfoPlus:addChild(layer)
		layer:createLayer() 
	end)
end

-- 俱乐部升级
local function levelCallback(  )
	local clubUpgrade = require("club.ClubUpgrade")
	local layer = clubUpgrade:create()
	_clubInfoPlus:addChild(layer, 10)
	layer:createLayer()
end

-- 管理员
local function manageCallback(  )
	if Is_create == 2 then
		ClubCtrol.dataStatMana( function (  )
			local manage = require("club.ClubManage")
			local layer = manage:create()
			_clubInfoPlus:addChild(layer, 10)
			layer:createLayer()
		end )
	elseif Is_create == 3 then
		local cmanaLook = require("club.CManaLook")
		local layer = cmanaLook:create()
		_clubInfoPlus:addChild(layer, 10)
		layer:createLayer(message.manager_permis)
	end
end

-- 清除聊天记录
local function deleteMsg(  )
	local layer = nil
	local function clearMsg(  )
		DZChat.clickClearRecord(chatClubMsg["ryid"], chatClubMsg["chatType"])
		layer:removeFromParent()
	end
	layer = UIUtil.clearChatMsg( {sureFunc = clearMsg, parent = _clubInfoPlus} )
end

-- 删除俱乐部
local function deleteCallback(  )
	print("delete")
	-- 0 当前用户和俱乐部没有关系，1加入的俱乐部，2创建的俱乐部, 3管理员
	print(Is_create)
	local function closeClubFunc(  )
		local function response( data )
			-- dump(data)
			if data.code == 0 then

				ViewCtrol.showTick({content = "您已成功解散俱乐部!"})

				NoticeCtrol.removeNoticeById(20004)

				_clubInfoPlus:removeFromParent()
				
				Notice.deleteMessage( 2 )

				DZChat.clickClearRecord(chatClubMsg["ryid"], chatClubMsg["chatType"])
				DZChat.getChatList()
			end
		end
		local tabData = {}
		tabData['club_id'] = club_id
		XMLHttp.requestHttp( "delete_myClub", tabData, response, PHP_POST )
	end
	local function exitClubFunc(  )
		local function response( data )
			-- dump(data)
			if data.code == 0 then
					
				ViewCtrol.showTick({content = "您已成功退出俱乐部!"})

				NoticeCtrol.removeNoticeById(20004)
				
				_clubInfoPlus:removeFromParent()
				
				DZChat.clickClearRecord(chatClubMsg["ryid"], chatClubMsg["chatType"])
				DZChat.getChatList()
			end
		end
		local tabData = {}
		tabData['club_id'] = club_id
		XMLHttp.requestHttp( "user_quit_club", tabData, response, PHP_POST )
	end
	
	if Is_create == 2 then
		if tonumber(message.exist_team) == 0 then
			ViewCtrol.popHint({bgSize = cc.size(display.width-100, 300), content = "您确定要解散俱乐部吗?", sureFunBack = closeClubFunc})
		else
			ViewCtrol.popHint({bgSize = cc.size(display.width-100, 300), content = "解散俱乐部时自动解散战队,确定要解散俱乐部吗?", sureFunBack = closeClubFunc})
		end
	elseif Is_create == 1 or Is_create == 3 then
		ViewCtrol.popHint({bgSize = cc.size(display.width-100, 300), content = "您确定要退出俱乐部吗?", sureFunBack = exitClubFunc})
	end
end

local function btnCallBack( sender )
	print("tag: "..sender:getTag())
	local tag = sender:getTag()
	if tag == 2 then
		print("管理权转让")
	elseif tag == 3 then
		print("俱乐部等级")
		if Is_create == 2 then
			levelCallback()
		end
	elseif tag == 4 then
		print("管理员")
		manageCallback()
	elseif tag == 5 then
		print("俱乐部推广员")
	elseif tag == 6 then
		print("成员")
		memberCallBack()
	elseif tag == 9 then
		print("战队")
		teamCallBack()
	elseif tag == 10 then
		print("联盟")
		unionCallback()
	elseif tag == 14 then
		print("清空聊天记录")
		deleteMsg()
	end
end

-- 刷新俱乐部数据
local function updateClubInfo(  )
	_clubInfoPlus:init()
	_clubInfoPlus:buildLayer()
end

-- YDWX_DZ_ZHANGXINMIN_BUG _20160630 _003 Page drop-down error
function ClubInfoPlus:buildLayer(  )
	
	local ClubNode = self:getChildByName('ClubInfo')
	if ClubNode then
		ClubNode:removeAllChildren()
	end

	message = ClubCtrol.getClubInfo()
	dump(message)

	-- 俱乐部管理员权限操作
	-- 111：发起牌局；112：审核带入；113查看战绩；114查看活跃统计；
	-- 121：删除成员；122：修改俱乐部资料；123审核俱乐部；124：添加推广员；
	-- 211：审核带入；212：历史牌局；213：结算牌局；221查看联盟
	PERMIT = {PER_ACT = false, PER_DELM = false, PER_EDIT = false, PER_MSG = false, PER_AGENT = false, PER_UNION = false}
	local curPermit = message.manager_permis
	for i,v in ipairs(curPermit) do
		if tostring(v) == tostring(114) then
			PERMIT.PER_ACT = true
		end
		if tostring(v) == tostring(121) then
			PERMIT.PER_DELM = true
		end
		if tostring(v) == tostring(122) then
			PERMIT.PER_EDIT = true
		end
		if tostring(v) == tostring(123) then
			PERMIT.PER_MSG = true
		end
		if tostring(v) == tostring(124) then
			PERMIT.PER_AGENT = true
		end
		if tostring(v) == tostring(221) then
			PERMIT.PER_UNION = true
		end
	end
	-- dump(PERMIT)
	ClubCtrol.setPermit( PERMIT )
	-- Is_create: 0 当前用户和俱乐部没有关系，1加入的俱乐部，2创建的俱乐部
	Is_create = tonumber(message.flag)

	-- 俱乐部id
	club_id = message.id

	local menuStr = nil
	if Is_create == 2 then
		ClubCtrol.setClubIsCreate( true )
		menuStr = "编辑"
	else
		ClubCtrol.setClubIsCreate( false )
		menuStr = nil
		if PERMIT.PER_EDIT then
			menuStr = "编辑"
		end
	end

	local name = StringUtils.getShortStr( message.name, 18)
	
	UIUtil.addTopBar({backFunc = Callback, title = name or "", menuFont = menuStr, menuFunc = editCallback, parent = ClubNode})

	local clubUI = {
				{text="俱乐部昵称", sizeH=130, tag=1, stype=1}, 
				{text="创始人", sizeH=132, tag=2, stype=1}, 
				{text="俱乐部等级", sizeH=100, tag=3, stype=2}, 
				{text="管理员", sizeH=100, tag=4, stype=2}, 
				{text="俱乐部推广员", sizeH=0, tag=5, stype=2}, 
				{text="成员", sizeH=100, tag=6, stype=3}, 
				{text="名片", sizeH=132, tag=7, stype=1}, 
				{text="简介", sizeH=100, tag=8, stype=3}, 
				{text="战队", sizeH=132, tag=9, stype=1}, 
				{text="联盟", sizeH=100, tag=10, stype=3}, 
				{text="活跃度统计", sizeH=132, tag=11, stype=4}, 
				{text="只允许创始人和管理员开局", sizeH=132, tag=12, stype=1}, 
				{text="新消息通知", sizeH=100, tag=13, stype=3}, 
				{text="清空聊天记录", sizeH=132, tag=14, stype=4}
			}

	local photoShow_H = 466
	local color = cc.c3b(165, 157, 157)
	local sizeH = {}
	local scrollH = 0
	-- Is_create: 0 当前用户和俱乐部没有关系，1加入的俱乐部，2创建的俱乐部, 3管理员
	for i=1, #clubUI do
		if Is_create == 3 then
			if not PERMIT.PER_ACT then
				clubUI[11].sizeH = 0
			end
			clubUI[13].sizeH = 132
		elseif Is_create == 1 then
			clubUI[4].sizeH = 0
			clubUI[11].sizeH = 0
			clubUI[13].sizeH = 132
		end
		scrollH = clubUI[i].sizeH + scrollH
	end
	viewSize = {width = display.width, height = scrollH + photoShow_H}

	-- 大背景scrollView
	local scrollView = UIUtil.addScrollView( {showSize=cc.size(display.width, display.height-130), innerSize=cc.size(viewSize.width, viewSize.height), dir=cc.SCROLLVIEW_DIRECTION_VERTICAL, colorType=ccui.LayoutBackGroundColorType.none, color=cc.c3b(0, 0, 10), bounce=true, pos=cc.p(0,0), parent=ClubNode} )
	scrollView:setScrollBarEnabled(false)

	local layer = UIUtil.addImageView({image = ResLib.IMG_BG, touch=false, scale=true, size=cc.size(viewSize.width, viewSize.height), pos=cc.p(0,0), parent=scrollView})
	
	-- 相册
	local params = {bgArray=message.club_bg or {}, pos=cc.p(0,viewSize.height-photoShow_H), parent=layer, view=scrollView, rangeH=466-250, viewH=display.height-130}
	ClubModel.buildPageView( params )

	local infoBg = {}
	local infoNode = {}
	local infoBgH = 0
	local infoW = 20 -- 左边距
	for i=1,#clubUI do
		if Is_create == 3 then
			if not PERMIT.PER_ACT then
				clubUI[11].sizeH = 0
			end
			clubUI[13].sizeH = 132
			clubUI[13].stype = 4
		elseif Is_create == 1 then
			clubUI[4].sizeH = 0
			clubUI[11].sizeH = 0
			clubUI[13].sizeH = 132
			clubUI[13].stype = 4
		end
		infoBgH = clubUI[i].sizeH + infoBgH
		infoNode[i] = UIUtil.addImageView({image = ResLib.COM_OPACITY0, touch=true, scale=true, size=cc.size(display.width, sizeH[i]), pos=cc.p(0, (viewSize.height-(photoShow_H-250)) - infoBgH), parent=layer})

		local imageBg = ResLib.IMG_CELL_BG1
		if i == 1 then
			imageBg = ResLib.COM_OPACITY0
		else
			-- 不同显示类型确定不同bg分割线
			if clubUI[i].stype == 1 then
				imageBg = ResLib.IMG_CELL_BG3
			elseif clubUI[i].stype == 2 then
				imageBg = ResLib.IMG_CELL_BG2_1
			elseif clubUI[i].stype == 3 then
				imageBg = ResLib.IMG_CELL_BG2
			elseif clubUI[i].stype == 4 then
				imageBg = ResLib.IMG_CELL_BG1
			end
		end
		local infoH = 0
		if clubUI[i].sizeH == 132 then
			infoH = clubUI[i].sizeH-32
			clubUI[i].sizeH = infoH
			UIUtil.addImageView({image = ResLib.IMG_LINE_BG, touch=false, scale=true, size=cc.size(display.width, 32),pos=cc.p(0, 100), ah=cc.p(0,0), parent=infoNode[i]})
		else
			infoH = clubUI[i].sizeH
		end
		sizeH[i] = infoH
		infoBg[i] = UIUtil.addImageView({image = imageBg, touch=true, scale=true, size=cc.size(display.width, infoH), pos=cc.p(0, 0), parent=infoNode[i]})
		infoBg[i]:setSwallowTouches(true)
		local rightBtn = UIUtil.addImageBtn({norImg = ResLib.COM_OPACITY0, selImg = ResLib.COM_OPACITY0, disImg = ResLib.COM_OPACITY0, ah = cc.p(0,0.5), pos = cc.p(0, infoH/2), touch = true, swalTouch = false, scale9 = true, size = cc.size(display.width, infoH), listener = btnCallBack, parent = infoBg[i]})
		rightBtn:setTag(clubUI[i].tag)
		if clubUI[i].tag == 1 or clubUI[i].tag == 8 or clubUI[i].tag == 11 or clubUI[i].tag == 12 or clubUI[i].tag == 13 then
			rightBtn:setTouchEnabled(false)
		end

		if i > 1 then
			UIUtil.addLabelArial(clubUI[i].text, 34, cc.p(infoW, infoH/2), cc.p(0, 0.5), infoBg[i])
		end
		if clubUI[i].sizeH == 0 then
			infoBg[i]:setVisible(false)
		end
	end

	
	-- 俱乐部头像
	local headUrl = ResLib.CLUB_HEAD_ORIGIN
	if tonumber(message.union) == 0 then
		headUrl = ResLib.CLUB_HEAD_GENERAL
	end
	local stencil, clubIcon = UIUtil.createCircle(headUrl, cc.p(70,  sizeH[1]-50), infoBg[1], ResLib.CLUB_HEAD_STENCIL_200)

	local url = message.avatar
	local function funcBack( path )
		clubIcon:setTexture(path)
	end
	if url ~= "" then
		ClubModel.downloadPhoto(funcBack, url, true)
	end

	-- 俱乐部名称
	local clubName, club_icon = UIUtil.addNameByType({nameType = 1, nameStr = name, fontSize = 36, pos = cc.p(140, sizeH[1]-20), parent = infoBg[1]})
	
	-- 俱乐部总人数/当前人数
	UIUtil.addPosSprite("club/icon_user_blue.png", cc.p(140, clubName:getPositionY()-36), infoBg[1], cc.p(0, 1))
	local clubCount = UIUtil.addLabelArial("", 25, cc.p(180, clubName:getPositionY()-36), cc.p(0, 1), infoBg[1]):setColor(ResLib.COLOR_GREY1)
	clubCount:setString(message.users_count..'/'..message.users_limit)
	-- 地区
	local place = ClubCtrol.getNumberOfSite(message.address)
	local clubPlace = UIUtil.addLabelArial(place, 25, cc.p(340, clubName:getPositionY()-36), cc.p(0, 1), infoBg[1]):setColor(ResLib.COLOR_GREY1)

	-- 俱乐部消息
	clubMsg = UIUtil.addImageBtn({norImg = "common/com_icon_message.png", selImg = "common/com_icon_message.png", ah = cc.p(1,0.5), pos = cc.p(viewSize.width-20, clubName:getPositionY()), touch = true, swalTouch = false, listener = msgCallBack, parent = infoBg[1]})
	redPoint_bg = UIUtil.addImageView({image = ResLib.COM_OPACITY0, touch=false, scale=true, size=clubMsg:getContentSize(), pos=cc.p(viewSize.width-20, clubMsg:getPositionY()), ah=cc.p(1,0.5), parent=infoBg[1]})
	if Is_create == 2 then
		ClubInfoPlus.buildRedPoint(  )
	else
		clubMsg:setVisible(false)
		redPoint_bg:setVisible(false)
		if PERMIT.PER_MSG then
			clubMsg:setVisible(true)
			redPoint_bg:setVisible(true)
			ClubInfoPlus.buildRedPoint(  )
		end
	end

	-- 创始人
	local user_stencil, user_Icon = UIUtil.createCircle(ResLib.USER_HEAD, cc.p(180, sizeH[2]/2), infoBg[2], ResLib.CLUB_HEAD_STENCIL_200, 0.4)
	local url = message.creator_imgs
	local function funcBack( path )
		local rect = user_Icon:getContentSize()
		user_Icon:setTexture(path)
		user_Icon:setTextureRect(rect)
	end
	ClubModel.downloadPhoto(funcBack, url, true)
	local clubManName = UIUtil.addLabelArial(message.creator_info or '', 34, cc.p(230, sizeH[2]/2), cc.p(0, 0.5), infoBg[2])
	-- UIUtil.addLabelArial("管理权转让", 30, cc.p(display.width-40, sizeH[2]/2), cc.p(1, 0.5), infoBg[2]):setColor(ResLib.COLOR_BLUE)
	-- UIUtil.addPosSprite(ResLib.BTN_BACK_RIGHT, cc.p(display.width-20, sizeH[2]/2), infoBg[2], cc.p(1, 0.5))

	-- 俱乐部等级
	UIUtil.addLabelArial("Lv."..message.level, 30, cc.p(230, sizeH[3]/2), cc.p(0, 0.5), infoBg[3])
	local level_r = UIUtil.addPosSprite(ResLib.BTN_BACK_RIGHT, cc.p(display.width-20, sizeH[3]/2), infoBg[3], cc.p(1, 0.5))
	if Is_create == 1 or Is_create == 3 then
		level_r:setVisible(false)
	end

	-- 管理员
	local mangaStr = "("..message.manager_count.."个)"
	if Is_create == 3 then
		mangaStr = ""
	end
	UIUtil.addLabelArial(mangaStr, 28, cc.p(display.width-51, sizeH[4]/2), cc.p(1, 0.5), infoBg[4]):setColor(ResLib.COLOR_GREY1)
	UIUtil.addPosSprite(ResLib.BTN_BACK_RIGHT, cc.p(display.width-20, sizeH[4]/2), infoBg[4], cc.p(1, 0.5))

	-- 推广员
	UIUtil.addPosSprite(ResLib.BTN_BACK_RIGHT, cc.p(display.width-20, sizeH[5]/2), infoBg[5], cc.p(1, 0.5))

	-- 成员
	self:addUserIcon(message.user_part, sizeH[6]/2, infoBg[6])
	UIUtil.addPosSprite(ResLib.BTN_BACK_RIGHT, cc.p(display.width-20, sizeH[6]/2), infoBg[6], cc.p(1, 0.5))

	-- 名片
	local clubCard = UIUtil.addLabelArial(message.club_number, 30, cc.p(140, sizeH[7]/2), cc.p(0, 0.5), infoBg[7])
	local cardBtn = UIUtil.addImageBtn({norImg = ResLib.BTN_BLUE_NOR_NEW, selImg = ResLib.BTN_BLUE_NOR_NEW, ah = cc.p(1,0.5), pos = cc.p(viewSize.width-20, sizeH[7]/2), touch = true, swalTouch = false, listener = shareCallback, parent = infoBg[7]}):setTitleFontSize(30):setTitleColor(display.COLOR_WHITE)
	cardBtn:setTitleText("分享")
	
	-- 简介
	local str = StringUtils.getShortStr( message.summary, LEN_DES)
	local clubDesText = cc.Label:createWithSystemFont(str, "Arial", 28, cc.size(500, 80), cc.TEXT_ALIGNMENT_LEFT, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
	clubDesText:setColor(ResLib.COLOR_GREY1)
	clubDesText:setPosition(cc.p(140, sizeH[8]/2))
	clubDesText:setAnchorPoint(cc.p(0, 0.5))
	infoBg[8]:addChild(clubDesText)

	-- 战队
	UIUtil.addPosSprite(ResLib.BTN_BACK_RIGHT, cc.p(display.width-20, sizeH[9]/2), infoBg[9], cc.p(1, 0.5))

	-- 联盟
	local union_stencil, union_Icon = UIUtil.createCircle(ResLib.UNION_HEAD, cc.p(180, sizeH[10]/2), infoBg[10], ResLib.CLUB_HEAD_STENCIL_200, 0.4)
	local url = message.union_state.union_avatar or ""
	local function funcBack( path )
		local rect = union_Icon:getContentSize()
		union_Icon:setTexture(path)
		union_Icon:setTextureRect(rect)
	end
	ClubModel.downloadPhoto(funcBack, url, true)

	local unionDes = UIUtil.addLabelArial('', 30, cc.p(140, sizeH[10]/2), cc.p(0, 0.5), infoBg[10]):setColor(ResLib.COLOR_GREY)

	local unionName = message.union_state.union_name or ""
	if unionName ~= "" then
		local union_name = UIUtil.addNameByType({nameType = 3, nameStr = unionName, fontSize = 25, pos = cc.p(220+20, sizeH[10]/2), parent = infoBg[10]})
	end
	local union_r = UIUtil.addPosSprite(ResLib.BTN_BACK_RIGHT, cc.p(display.width-20, sizeH[10]/2), infoBg[10], cc.p(1, 0.5))
	--------------------------------------------------------------------------------------
	--@@ 加入、创建俱乐部判断    普通、创世俱乐部判断
	--@@ Is_create:1 普通成员、2俱头、3管理员
	--@@ union: 0 普通俱乐部、1创始俱乐部
	--@@ union_state 有无联盟存在 	show：1 申请加入联盟 2 已有联盟可查看联盟详情 3 创建联盟
	if message.union_state.show == "2" then
		print("展示联盟")
		if Is_create == 1 then
			union_r:setVisible(false)
		elseif Is_create == 3 then
			if not PERMIT.PER_UNION then
				union_r:setVisible(false)
			end
		end
	else
		if Is_create == 1 then
			union_r:setVisible(false)
		elseif Is_create == 3 then
			if not PERMIT.PER_UNION then
				union_r:setVisible(false)
			end
		end
		unionDes:setString("尚未加入任何联盟")
		union_stencil:setVisible(false)
		union_Icon:setVisible(false)
	end

	-- 活跃统计
	UIUtil.addImageBtn({norImg = ResLib.BTN_BLUE_NOR_NEW, selImg = ResLib.BTN_BLUE_NOR_NEW, text = "查看", ah = cc.p(1,0.5), pos = cc.p(viewSize.width-20, sizeH[11]/2), touch = true, swalTouch = false, listener = activityFunc, parent = infoBg[11]}):setTitleFontSize(30):setTitleColor(display.COLOR_WHITE)

	-- 只允许创始人和管理员开局
	local function cValueChanged( tag, sender )
		if sender:getSelectedIndex() == 0 then
			print("on")
			cardCallback( 1 )
		else
			print("off")
			cardCallback( 2 )
		end
	end
	local cardTog = UIUtil.addTogMenu({pos = cc.p(display.width-20, sizeH[12]/2), listener = cValueChanged, parent = infoBg[12]})
	cardTog:setAnchorPoint(cc.p(1, 0.5))
	local isC = tonumber(message.table_create_right) or 2
	-- isC 1:开启， 2：关闭
	if tonumber(isC) == 2 then
		cardTog:setSelectedIndex(1)
	else
		cardTog:setSelectedIndex(0)
	end
	local mask = UIUtil.addImageView({image="common/com_grey_block.png", touch=true, scale=true, size=cc.size(display.width, sizeH[12]), pos = cc.p(0,0), ah = cc.p(0,0), parent=infoBg[12]})
	-- 只能俱头设置
	if Is_create == 2 then
		mask:setVisible(false)
	else
		mask:setVisible(true)
	end

	-- 新消息通知
	local function valueChanged( tag, sender )
		if sender:getSelectedIndex() == 0 then
			print("on")
			newsCallback( 1 )
		else
			print("off")
			newsCallback( 0 )
		end
	end
	local newsTog = UIUtil.addTogMenu({pos = cc.p(display.width-20, sizeH[13]/2), listener = valueChanged, parent = infoBg[13]})
	newsTog:setAnchorPoint(cc.p(1, 0.5))
	local myId = Single:playerModel():getId()
	local key = myId .. chatClubMsg.ryid
	local isOk = Storage.getStringForKey(key) or 1
	if tonumber(isOk) == 0 then
		newsTog:setSelectedIndex(1)
	else
		newsTog:setSelectedIndex(0)
	end

	-- 时间
	local time = os.date("%Y-%m-%d",message.create_time)
	local clubDate = UIUtil.addLabelArial('创建于'..time, 24, cc.p(viewSize.width/2, 200), cc.p(0.5, 0.5), layer):setColor(cc.c3b(102,102,102))

	-- 删除退出
	local btn_normal, btn_select = "common/com_btn_blue.png",  "common/com_btn_blue_height.png"
	local label = cc.Label:createWithSystemFont("删除并退出", "Marker Felt", 36)
	label:setColor(cc.c3b(255,255,255))
	local btn = UIUtil.controlBtn(btn_normal, btn_select, btn_normal, label, cc.p(viewSize.width/2, 60), cc.size(710,80), deleteCallback, ClubNode)

end

function ClubInfoPlus.loadBtnImg( btn, img )
	btn:loadTextureNormal(img)
	btn:loadTexturePressed(img)
	btn:loadTextureDisabled(img)
end

function ClubInfoPlus.buildRedPoint(  )
	NoticeCtrol.setNoticeNode( POS_ID.POS_20004, redPoint_bg )

	Notice.registRedPoint( 2 )

end

function ClubInfoPlus:addUserIcon( tab, posH, parent )
	local count = nil
	local markIcon = {}
	local imgs = {}
	-- dump(tab)
	for i=1,#tab do
		local tmp = {}
		tmp = tab[i]
		if tonumber(tmp.flag) == 1 then
			tmp['state'] = 1
		elseif tonumber(tmp.flag) == 3 then
			tmp['state'] = 2
		elseif tonumber(tmp.flag) == 0 then
			tmp['state'] = 3
		end
		imgs[#imgs+1] = tmp
	end
	table.sort(imgs, function(a, b)
		return a.state < b.state
	end)
	-- dump(imgs)
	
	if #imgs > 6 then
		count = 6
	else
		count = #imgs
	end
	for i=1,count do
		local user_stencil, user_Icon = UIUtil.createCircle(ResLib.USER_HEAD, cc.p(180+(i-1)*90, posH), parent, ResLib.CLUB_HEAD_STENCIL_200, 0.4)

		local url = imgs[i].headimg
		local function funcBack( path )
			local rect = user_stencil:getContentSize()
			user_Icon:setTexture(path)
			user_Icon:setTextureRect(rect)
		end
		if imgs[i] ~= "" then
			ClubModel.downloadPhoto(funcBack, url, true)
		end

		markIcon[i] = UIUtil.addPosSprite("common/com_icon_founder.png", cc.p(180+(i-1)*90+20, posH-25), parent, cc.p(0.5, 0.5))
		if tonumber(imgs[i].flag) == 0 then
			markIcon[i]:setVisible(false)
		elseif tonumber(imgs[i].flag) == 1 then
			markIcon[i]:setTexture('common/com_icon_founder.png')
		elseif tonumber(imgs[i].flag) == 3 then
			markIcon[i]:setTexture('common/com_icon_manager.png')
		end
	end
end

-- 俱乐部经验条
function ClubInfoPlus:buildProgress( exp, pos, parent )
	local bg = cc.Scale9Sprite:create("club/club_level_bg.png")
	bg:setAnchorPoint(cc.p(0,0))
	bg:setPosition(pos)
	parent:addChild(bg)

	local len = bg:getContentSize().width

	local sprite = cc.Sprite:create("club/club_level_load.png")

	local progress = cc.ProgressTimer:create(sprite)
	progress:setType(cc.PROGRESS_TIMER_TYPE_BAR)
	progress:setMidpoint(cc.p(0,0))
	progress:setBarChangeRate(cc.p(1,0))
	progress:setAnchorPoint(cc.p(0,0.5))
	progress:setPosition(cc.p(0,bg:getContentSize().height/2))
	local value1 = exp.current_score or 0
	local value2 = exp.total_score or 0
	local value = (value1/value2)*(1/10)+(1/10)
	progress:setPercentage(value*100)
	bg:addChild(progress)
	return progress
end

function ClubInfoPlus:createLayer( msg )
	_clubInfoPlus = self
	_clubInfoPlus:setSwallowTouches()
	_clubInfoPlus:addTransitAction()
	
	UIUtil.setBgScale(ResLib.MAIN_BG, display.center, self)

	local node = cc.Node:create()
	node:setPosition(cc.p(0,0))
	node:setName('ClubInfo')
	self:addChild(node)

	self:init()

	local listenerCustom = cc.EventListenerCustom:create("C_Event_update_ClubInfo", updateClubInfo)  
    local customEventDispatch = cc.Director:getInstance():getEventDispatcher()
    customEventDispatch:addEventListenerWithFixedPriority(listenerCustom, 1)
    self.listener = listenerCustom

    --退出后移除注册的事件
	local function onNodeEvent(event)
		if event == "enter" then
		elseif event == "exit" then
			if(self.listener ~= nil) then
				local customEventDispatch = cc.Director:getInstance():getEventDispatcher()
				customEventDispatch:removeEventListener(self.listener)
			end
			NoticeCtrol.removeNoticeById(20004)
		end
	end
	self:registerScriptHandler(onNodeEvent)

	chatClubMsg = {}
	chatClubMsg = msg

	self:buildLayer()

end

function ClubInfoPlus:init(  )
	title = nil
	Is_create = nil
	clubMsg = nil
	redPoint_bg = nil
	PERMIT = {}
end

return ClubInfoPlus