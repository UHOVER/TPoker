local ViewBase = require('ui.ViewBase')
local MessageLayer = class('MessageLayer', ViewBase)
local MineCtrol = require("mine.MineCtrol")
local MessageCtorl = require("message.MessageCtorl")

local ClubCtrol = require("club.ClubCtrol")
local WaitServer = require('ui.WaitServer')

local _message = nil
local tab = {}
	tab['font'] = 'Arial'
	tab['size'] = 30

local imageView = nil
local curData = {}
local curTableView = nil
local sysData = {}
local cardsData = {}
local is_cards = false

local IS_EXIT = nil

local function friendBack(  )
	local addFriend = require("friend.addFriend")
	local layer = addFriend:create()
	_message:addChild(layer)
	layer:createLayer("new")

end

local function circleBack(  )

	MineCtrol.createCircleWay("message")

	local newCircle = require("message.NewCircle")
	local layer = newCircle:create()
	_message:addChild(layer)
	layer:createLayer("new")
end

function MessageLayer:buildLayer(  )

	-- topBar
    -- UIUtil.addTopBar({title = "消息", menuFont = "添加朋友", menuFunc = friendBack, parent = self})
    -- UIUtil.addTopBar({leftMenu = "添加朋友", leftMenuFunc = friendBack, title = "消息", parent = self})
    UIUtil.addTopBar({title = "消息", parent = self})
    imageView = UIUtil.addImageView({touch=true, scale=true, size=cc.size(display.width, display.height-230), pos=cc.p(0,100), parent=self})

   
    MessageLayer.updateSystemMsg(false)
    MessageLayer.updateCardsMsg(false)
end

function MessageLayer.updateSystemMsg( isUpdate )
	local sys_count = Notice.getMessagePushCount( 4 ).count or 0
	local sysTab = MessageCtorl.getSysData()
	sysData = {msg_icon = "common/com_icon_notice.png", msg_number = sys_count, msg_title = "系统消息", msg_content = sysTab.text, msg_time = sysTab.time}
	if isUpdate then
		if not IS_EXIT then
			print("aaaaaaaaaaaaaaaaaaaaa false")
			return
		end
		if next(sysData) ~= nil then
			curData[1] = sysData
		end
		if curTableView then
			curTableView:reloadData()
		else
			curTableView = _message:createTableView()
			curTableView:reloadData()
		end
	end
end

function MessageLayer.updateCardsMsg( isUpdate )
	local card_count = (Notice.getMessagePushCount( 5 ).count or 0) + (Notice.getMessagePushCount( 6 ).count or 0)
	local cardTab = MessageCtorl.buildCardsNotice()
	-- dump(cardTab)
	if next(cardTab) == nil then
		cardsData = {}
		is_cards = false
	else
		-- 核查是否有新消息提示
		NewMsgMgr.setNewMsgTrue()
		cardsData = {msg_icon = "common/com_icon_notice_card.png", msg_number = card_count, msg_title = "牌局请求消息", msg_content = cardTab.msg .."请求带入。", msg_time = cardTab.time, msg_type = true}
		is_cards = true
		-- dump(cardsData)
	end
	if isUpdate then
		if not IS_EXIT then
			print("aaaaaaaaaaaaaaaaaaaaa false")
			return
		end
		if next(cardsData) == nil then
			if curData[2] and curData[2].msg_type then
				table.remove(curData, 2)
				if curTableView then
					curTableView:reloadData()
				else
					curTableView = _message:createTableView()
					curTableView:reloadData()
				end
				-- curTableView:reloadData()
			end
		else
			if curData[2] then
				if curData[2].msg_type then
					curData[2] = cardsData
				else
					table.insert(curData, 2, cardsData)
				end
			else
				table.insert(curData, 2, cardsData)
			end
			
			if curTableView then
				curTableView:reloadData()
			else
				curTableView = _message:createTableView()
				curTableView:reloadData()
			end
			-- curTableView:reloadData()
		end
	end
	
end

function MessageLayer.buildData(  )

	-- print("-------------- IS_EXIT -------- ")
	if not IS_EXIT then
		print("aaaaaaaaaaaaaaaaaaaaa false")
		return
	end

	curData = MessageCtorl.getChatList()
	if curData == nil then
		curData = {}
	end
	table.insert(curData, 1, sysData)
	if next(cardsData) ~= nil then
		table.insert(curData, 2, cardsData)
	end

	dump(curData)
	print("--------------历史消息-----------------")

	if not curTableView then
		print("--------------------------tableView不存在")
		-- DZAction.delateTime(_message, 0.2, function()
			curTableView = _message:createTableView()
			curTableView:reloadData()
			WaitServer.removeForeverWait()
		-- end)
	else
		print("--------------------------tableView已经存在、刷新")
		-- DZAction.delateTime(_message, 0.2, function()
			curTableView:reloadData()
			WaitServer.removeForeverWait()
		-- end)
	end--]]

end

function MessageLayer:createTableView(  )

	local function tableCellTouched( tableViewSender, tableCell )
		-- print('tableCell: ' ..tableCell:getIdx() )
		local idx = tableCell:getIdx()+1
		if idx == 1 then
			self:intoSysNotice()
		else
			if is_cards then
				if idx == 2 then
					self:intoCardsNotice()
				else
					self:intoChat(idx)
				end
			else
				self:intoChat(idx)
			end
		end
	end
	local function cellSizeForTable( tableViewSender, cellIndex )
		return 0, 144
	end
	local function numberOfCellsInTableView( tableViewSender )
		return #curData
	end
	local function tableCellAtIndex( tableViewSender, cellIndex )
		local cellItem = tableViewSender:dequeueCell()
		if cellItem == nil then
			cellItem = cc.TableViewCell:new()

			self:buildCellTmpl(cellItem)
		end
		self:updateCellTmpl(cellItem, cellIndex)

		return cellItem
	end
	
	local tableView = cc.TableView:create(cc.size(display.width, display.height - 230))
	tableView:setPosition(cc.p(0, 0))
	tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
	imageView:addChild(tableView)
	tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
	tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
	tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
	tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
	tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
	tableView:setBounceable(true)
	tableView:setDelegate()
	tableView:reloadData()

	return tableView
end

function MessageLayer:buildCellTmpl(cellItem)
	local girdNodes = {}
	girdNodes = cellItem

	--[[local function callback( sender )
		local tag = sender:getTag()
		print("touchFun : " .. tag)
	end
	local clickBtn = UIUtil.addImageBtn({norImg = ResLib.TABLEVIEW_CELL_BG, selImg = ResLib.TABLEVIEW_CELL_BG, ah = cc.p(0,0), pos = cc.p(0, 0), swalTouch = false, touch = true, scale9 = true, size = cc.size(display.width, 120), parent = cellItem})
	girdNodes.clickBtn = clickBtn--]]

	--[[local cellBg1 = UIUtil.addImageView({image=ResLib.TABLEVIEW_CELL_BG, touch=false, scale=true, size=cc.size(display.width, 120), pos=cc.p(0,0), ah=cc.p(0,0), parent=cellItem})
	girdNodes.cellBg1 = cellBg1--]]

	local cellBg = UIUtil.addImageView({image=ResLib.TABLEVIEW_CELL_BG, touch=false, scale=true, size=cc.size(display.width, 144), pos=cc.p(0,0), ah=cc.p(0,0), parent=cellItem})
	girdNodes.cellBg = cellBg

	local width = cellBg:getContentSize().width
	local height = cellBg:getContentSize().height

	local stencil, Icon = UIUtil.createCircle(ResLib.CLUB_HEAD_GENERAL, cc.p(70,height/2), cellBg, ResLib.CLUB_HEAD_STENCIL_200)
	girdNodes.stencil = stencil
	girdNodes.Icon = Icon

	local redPoint_bg = UIUtil.addPosSprite(ResLib.COM_POINT_RED, cc.p(110,height/2+45), cellBg, cc.p(0.5, 0.5))
	girdNodes.redPoint_bg = redPoint_bg
	local red_count = UIUtil.addLabelArial("", 25, cc.p(redPoint_bg:getContentSize().width/2, redPoint_bg:getContentSize().height/2), cc.p(0.5, 0.5), redPoint_bg)
	girdNodes.red_count = red_count

	local game_iocn = UIUtil.addPosSprite("common/com_icon_biao.png", cc.p(90, height/2-50), cellBg, cc.p(0.5, 0))
	girdNodes.game_iocn = game_iocn

	local msgTitle = UIUtil.addLabelArial('消息标题', 34, cc.p(140, height/2+9), cc.p(0, 0), cellBg)
	girdNodes.msgTitle = msgTitle

	local icon_small = UIUtil.addPosSprite(ResLib.CLUB_HEAD_GENERAL_SMALL, cc.p(msgTitle:getPositionX()+msgTitle:getContentSize().width+10, height/2+15), cellBg, cc.p(0, 0))
	girdNodes.icon_small = icon_small

	local msgDate = UIUtil.addLabelArial('2016-5-8', 25, cc.p(width-20, msgTitle:getPositionY()), cc.p(1, 0), cellBg):setColor(cc.c3b(102, 102, 102))
	girdNodes.msgDate = msgDate

	local msgDes = UIUtil.addLabelArial('消息类容', 28, cc.p(140, height/2-9), cc.p(0, 1), cellBg)
	msgDes:setColor(ResLib.COLOR_GREY1)
	girdNodes.msgDes = msgDes

	local sound_icon = UIUtil.addPosSprite("common/com_icon_sound_on.png", cc.p(width-20, msgDes:getPositionY()), cellBg, cc.p(1, 1))
	girdNodes.sound_icon = sound_icon

	--[[local function delFuncback( sender )
		print("删除")
		local tag = sender:getTag()
		-- self:deleteChatMsg(tag)
	end
	local delBtn = UIUtil.addImageBtn({norImg = ResLib.COM_BTN_BG_2_RED, selImg = ResLib.COM_BTN_BG_2_RED, text = "删除", pos = cc.p(width-70, 60), swalTouch = true, touch = true, scale9 = true, size = cc.size(140, 120), listener = delFuncback, parent = clickBtn})
	girdNodes.delBtn = delBtn--]]

end

function MessageLayer:updateCellTmpl(cellItem, cellIndex)
	local girdNodes = cellItem

	local data = {}
	local index = cellIndex + 1
	data = curData[index]
	
	local function updateCellIndex_once(  )
		-- local rect = girdNodes.stencil:getContentSize()
		girdNodes.Icon:setTexture(data.msg_icon)
		-- girdNodes.Icon:setTextureRect(rect)

		girdNodes.msgTitle:setString(data.msg_title)
		girdNodes.msgTitle:setColor(display.COLOR_WHITE)

		local msg = StringUtils.getShortStr( data.msg_content, 40)
		girdNodes.msgDes:setString(msg)

		local time = os.date("%Y-%m-%d", data.msg_time)
		girdNodes.msgDate:setString(time)

		if data.msg_number == 0 then
			girdNodes.redPoint_bg:setVisible(false)
			girdNodes.red_count:setString("")
		else
			girdNodes.redPoint_bg:setVisible(true)
			if data.msg_number > 99 then
				girdNodes.redPoint_bg:setTexture(ResLib.COM_POINT_RED1)
				girdNodes.red_count:setString("99+")
				girdNodes.red_count:setPosition(cc.p(girdNodes.redPoint_bg:getContentSize().width/2, girdNodes.redPoint_bg:getContentSize().height/2))
			else
				girdNodes.redPoint_bg:setTexture(ResLib.COM_POINT_RED)
				girdNodes.red_count:setString(data.msg_number)
				girdNodes.red_count:setPosition(cc.p(girdNodes.redPoint_bg:getContentSize().width/2, girdNodes.redPoint_bg:getContentSize().height/2))
			end
		end
		
		girdNodes.sound_icon:setVisible(false)
		girdNodes.game_iocn:setVisible(false)
		girdNodes.icon_small:setVisible(false)
	end

	local function updateCellIndex_other(  )
		local tmpTab = {}

		local msg = StringUtils.getShortStr( data.msgContent, 40)
		girdNodes.msgDes:setString(msg)

		girdNodes.msgDate:setString(data.msgReceiveTime)

		if tonumber(data.unlookNum) == 0 then
			girdNodes.redPoint_bg:setVisible(false)
			girdNodes.red_count:setString("")
		else
			girdNodes.redPoint_bg:setVisible(true)
			if tonumber(data.unlookNum) > 99 then
				girdNodes.redPoint_bg:setTexture(ResLib.COM_POINT_RED1)
				girdNodes.red_count:setString("99+")
				girdNodes.red_count:setPosition(cc.p(girdNodes.redPoint_bg:getContentSize().width/2, girdNodes.redPoint_bg:getContentSize().height/2))
			else
				girdNodes.redPoint_bg:setTexture(ResLib.COM_POINT_RED)
				girdNodes.red_count:setString(data.unlookNum)
				girdNodes.red_count:setPosition(cc.p(girdNodes.redPoint_bg:getContentSize().width/2, girdNodes.redPoint_bg:getContentSize().height/2))
			end
		end

		if data.isSound == 0 then
			girdNodes.sound_icon:setVisible(true)
			girdNodes.sound_icon:setTexture("common/com_icon_sound_off.png")
		elseif data.isSound == 1 then
			girdNodes.sound_icon:setVisible(true)
			girdNodes.sound_icon:setTexture("common/com_icon_sound_on.png")
		elseif data.isSound == 2 then
			girdNodes.sound_icon:setVisible(false)
		end

-- DZChat.TYPE_CLUB = 1
-- DZChat.TYPE_GROUP = 2
-- DZChat.TYPE_FRIEND = 3
-- DZChat.TYPE_GAME_STANDARD = 4
-- DZChat.TYPE_GAME_SNG = 5
-- DZChat.TYPE_GAME_MTT = 6
		local chatType = tonumber(data.chatType)

		if chatType == DZChat.TYPE_CLUB then
			
			girdNodes.icon_small:setVisible(true)
			if data.isHost == "true" or data.isHost == "1" then
				girdNodes.Icon:setTexture(ResLib.CLUB_HEAD_ORIGIN)
				girdNodes.icon_small:setTexture(ResLib.CLUB_HEAD_ORIGIN_SMALL)
				girdNodes.msgTitle:setColor(ResLib.COLOR_YELLOW)
			else
				girdNodes.Icon:setTexture(ResLib.CLUB_HEAD_GENERAL)
				girdNodes.icon_small:setTexture(ResLib.CLUB_HEAD_GENERAL_SMALL)
				girdNodes.msgTitle:setColor(ResLib.COLOR_BLUE)
			end

			tmpTab["title"] = data.msgTitle
			tmpTab["icon"] = data.msgUrl
			
			girdNodes.game_iocn:setVisible(false)
		elseif chatType == DZChat.TYPE_GROUP then
			girdNodes.Icon:setTexture(ResLib.CIRCLE_HEAD)
			girdNodes.icon_small:setVisible(true)
			girdNodes.icon_small:setTexture(ResLib.CIRCLE_HEAD_SMALL)

			tmpTab["title"] = data.msgTitle
			tmpTab["icon"] = data.msgUrl

			girdNodes.msgTitle:setColor(ResLib.COLOR_GREEN)

			girdNodes.game_iocn:setVisible(false)
		elseif chatType == DZChat.TYPE_FRIEND then
			girdNodes.Icon:setTexture(ResLib.USER_HEAD)
			girdNodes.icon_small:setVisible(false)

			local siadId = tonumber(data["siadId"])
			local msgId = tonumber(data["msgId"])
			local userId = tonumber(Single:playerModel():getId())
			if userId == siadId then
				tmpTab["title"] = data.msgTitle
				tmpTab["icon"] = data.msgUrl
			else
				tmpTab["title"] = data.saidName
				tmpTab["icon"] = data.saidUrl
			end

			girdNodes.msgTitle:setColor(display.COLOR_WHITE)

			girdNodes.game_iocn:setVisible(false)

		else
			girdNodes.Icon:setTexture(ResLib.USER_HEAD)
			if tonumber(data.secure) == 1 then
				girdNodes.icon_small:setVisible(true)
				girdNodes.icon_small:setTexture("common/com_safe_icon.png")
			else
				girdNodes.icon_small:setVisible(false)
			end
			
			tmpTab["title"] = data.msgTitle
			tmpTab["icon"] = data.msgUrl

			girdNodes.msgTitle:setColor(display.COLOR_WHITE)

			girdNodes.game_iocn:setVisible(true)
			if chatType == DZChat.TYPE_GAME_STANDARD then
				girdNodes.game_iocn:setTexture("common/com_icon_biao.png")
			elseif chatType == DZChat.TYPE_GAME_SNG then
				girdNodes.game_iocn:setTexture("common/com_icon_sng.png")
			elseif chatType == DZChat.TYPE_GAME_MTT then
				girdNodes.game_iocn:setTexture("common/com_icon_mtt.png")
			end
		end

		local title = StringUtils.getShortStr( tmpTab.title, 18)
		girdNodes.msgTitle:setString(title)

		girdNodes.icon_small:setPositionX(girdNodes.msgTitle:getPositionX()+girdNodes.msgTitle:getContentSize().width+10)

		local url = tmpTab.icon or ""
		local function funcBack( path )
			-- local rect = girdNodes.stencil:getContentSize()
			girdNodes.Icon:setTexture(path)
			-- girdNodes.Icon:setTextureRect(rect)
		end
		if url ~= "" then
			ClubModel.downloadPhoto(funcBack, url, true)
		end
	end

	if index == 1 then		
		updateCellIndex_once()
	else
		if is_cards then
			if index == 2 then
				updateCellIndex_once()
			else
				updateCellIndex_other()
			end
		else
			updateCellIndex_other()
		end

		-- girdNodes.clickBtn:setTag(cellIndex)
		-- girdNodes.delBtn:setTag(cellIndex)
		-- if data.isTouch == 0 then
		-- 	girdNodes.cellBg:setPositionX(0)
		-- 	girdNodes.delBtn:setVisible(false)
		-- else
		-- 	girdNodes.cellBg:setPositionX(-160)
		-- 	girdNodes.delBtn:setVisible(true)
		-- end
		-- self:addTouchEvent( girdNodes.cellBg, girdNodes.clickBtn, girdNodes.delBtn )
	end
end

function MessageLayer:addTouchEvent( move_node, touch_node, touch_btn )
	local startPos = nil
	local isTouch = false
	local isClick = 0
	local beganClick = 0
	touch_node:addTouchEventListener(function ( sender, state )
		local idx = sender:getTag()
		-- print("----------->>>>>>>>>>>> tag: " .. tag)
		local distance = nil
		if state == 0 then
			print("began")
			startPos = sender:getTouchBeganPosition()
			dump(startPos)
			if isTouch then
				-- move_node:setPositionX(0)
				-- touch_btn:setVisible(false)
				curData[idx].isTouch = 0

				beganClick = 1
			end
		elseif state == 1 then
			print("moved")
			local pos = sender:getTouchMovePosition()
			dump(pos)
			distance = startPos.x - pos.x
			print(">>>>>>>>>>>>>>>>>>> distance: " .. distance)
			if distance >= 50 then
				print("滑动事件")
				-- move_node:setPositionX(-160)
				-- touch_btn:setVisible(true)
				curData[idx].isTouch = 1
				
				isTouch = true
			elseif distance < 50 and distance >= 0 then
				print("点击事件")
				isTouch = false
				isClick = beganClick + 1
			end
		elseif state == 2 then
			print("ended")
			print("&&&&&&&&&&&&&&&&&&&&&&&&-----isClick : " .. isClick)
			if isClick == 1 or isClick == 0 then
				if not isTouch then
					print("<<<<<进入聊天>>>>>>>>>>")
				end
			end
			isClick = 0
			beganClick = 0
			curTableView:reloadData()
		else
			print("canceled")
		end
	end)
end

function MessageLayer:intoSysNotice(  )
	print("系统消息")
	local SysActivity = require("message.SysActivity").new()
	self:addChild(SysActivity)
end

function MessageLayer:intoCardsNotice(  )
	local CardsNotice = require("message.CardsNotice").new()
	self:addChild(CardsNotice)
end

function MessageLayer:intoChat( idx )

	print("---------->>>>>>>>>>>idx : " .. idx)
	local tdata = curData[idx]
	dump(tdata)

	local chatType = tonumber(tdata.chatType)
	if chatType == DZChat.TYPE_CLUB then
		DZChat.checkChat(tdata['msgId'], StatusCode.CHAT_CLUB)
	elseif chatType == DZChat.TYPE_GROUP then
		DZChat.checkChat(tdata['msgId'], StatusCode.CHAT_CIRCLE)
	elseif chatType == DZChat.TYPE_FRIEND then
		local chatId = nil
		local siadId = tonumber(tdata["siadId"])
		local msgId = tonumber(tdata["msgId"])
		local userId = tonumber(Single:playerModel():getId())
		if userId == siadId then
			chatId = msgId
		else
			chatId = siadId
		end
		DZChat.checkChat(chatId, StatusCode.CHAT_FRIEND)
	else
		local ryid = ""
		local tab = {}
		if chatType == DZChat.TYPE_GAME_MTT then
			ryid = "mtt_pre"..tdata["pokerId"]
			tab["mod"] = StatusCode.GLSTATUS_MTT
		else
			ryid = "pre"..tdata["pokerId"]
			tab["mod"] = StatusCode.GLSTATUS_COMMON
		end
		tab['gid'] = tdata['pokerId']
		local function response(data)
			--返回3证明牌局结束
			if tonumber(data['status']) == 3 then
				ViewCtrol.showTip({content = "牌局已结束！"})
				DZChat.clickClearRecord(ryid, tdata["chatType"])
				table.remove(curData, idx)
				curTableView:reloadData()
			else
				DZChat.clickUnreadRecord(ryid, chatType)
				if chatType == DZChat.TYPE_GAME_MTT then
					MainCtrol.enterGame(tdata['pokerId'], MainCtrol.MOD_GID, function()end, nil, true )
				else
					MainCtrol.enterGame(tdata['pokerId'], MainCtrol.MOD_GID, function()end)
				end
			end
			DZChat.getChatList()
			DZChat.getUnlookNum()
		end
		MainCtrol.filterNet("getGlStatus", tab, response, PHP_POST)
	end
end

function MessageLayer:deleteChatMsg( idx )
	local tdata = curData[idx]
	dump(tdata)
	
	DZChat.clickClearRecord(tdata["msgRYId"], tdata["chatType"])

	table.remove(curData, idx)
	curTableView:reloadData()
end

function MessageLayer:createLayer(  )
	_message = self
	_message:addLayerOfTable()
	
	UIUtil.setBgScale(ResLib.MAIN_BG, display.center, self)
	Bottom:getInstance():addBottom(2, self)

	imageView = nil
	curData = {}
	curTableView = nil
	sysData = {}
	cardsData = {}

	self:buildLayer()
	
	local function onNodeEvent(event)
		if event == "enter" then
			self:onEnter()
			MessageCtorl.setIsMsgLayer( true )
		elseif event == "enterTransitionFinish" then
			WaitServer.showForeverWait()
		elseif event == "exit" then
			self:onExit()
			MessageCtorl.setIsMsgLayer( false )
		end
    end
	self:registerScriptHandler(onNodeEvent)
	
	
	DZAction.delateTime(self, 6, function()
    	WaitServer.removeForeverWait()
	end)

	local chatType = MessageCtorl.getChatType()
	local chat_id = MessageCtorl.getChatData()

	if chatType == 0 then
		-- 历史聊天消息
		--WaitServer.showForeverWait()
		DZAction.delateTime(self, 0.05, function()
			DZChat.getChatList()
		end)
	else
		if chatType == MessageCtorl.CHAT_USER then
		
			DZChat.checkChat(chat_id, StatusCode.CHAT_FRIEND)

		elseif chatType == MessageCtorl.CHAT_CLUB then

			DZChat.checkChat(chat_id, StatusCode.CHAT_CLUB)
			
		elseif chatType == MessageCtorl.CHAT_CIRCLE then

			DZChat.checkChat(chat_id, StatusCode.CHAT_CIRCLE)

		end
	end

end

function MessageLayer.lookClubMsg( chatTab )
	print("######### -------->>>查看俱乐部详情")
	local clubId = nil
	local tmsg = chatTab['typeMsg']
	clubId = tmsg['groupId']

	local curScene = cc.Director:getInstance():getRunningScene()
	ClubCtrol.dataStatClubInfo( clubId, function (  )
		local clubInfo = require('club.ClubInfoPlus')
		local layer = clubInfo:create()
		layer:setName("clubInfoPlus")
		if _message:getChildByName("clubInfoPlus") then
			_message:removeChildByName("clubInfoPlus")
		end
		_message:addChild(layer, 10)
		layer:createLayer( chatTab )
	end )
end

function MessageLayer.lookCircleMsg( chatTab )
	print("######### -------->>>查看圈子详情")
	local circleId = nil
	local tmsg = chatTab['typeMsg']
	circleId = tmsg['groupId']
	
	MineCtrol.setCircleId( circleId )

	MineCtrol.dataStatCircle( function (  )
		local circleInfo = require("mine.CircleInfo")
		local layer = circleInfo:create()
		_message:addChild(layer, 10)
		layer:createLayer( chatTab )
	end )
end

-- 查看好友信息
function MessageLayer.lookFriendMsg( chatTab )
	-- dump(chatTab)
	local UserInfo = require("friend.UserInfo")
	local layer = UserInfo:create()
	_message:addChild(layer, 10)
	layer:createLayer(chatTab)
end

function MessageLayer:onEnter(  )
	print("-------------- IS_EXIT true")
	IS_EXIT = true
end

function MessageLayer:onExit(  )
	print("-------------- IS_EXIT false")
	curTableView = nil
	IS_EXIT = false
end

return MessageLayer