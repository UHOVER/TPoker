local ViewBase = require('ui.ViewBase')
local SearchList = class('SearchList', ViewBase)

local ClubCtrol = require("club.ClubCtrol")
local _searchList = nil

local areaTable 	= {}
local curData 		= {}
local tab = {}
	tab['font'] = 'Arial'
	tab['size'] = 30
local curTarget = nil
local sizeX, sizeY = nil, nil
local CLUB_TAG = nil
local FRIEND_TAG = nil
local UNION_TAG = nil
local imageView = nil

local USER_ID = nil

local function Callback( tag, sender )
	-- _searchList:removeFromParent()
	_searchList:removeTransitAction()
end

function SearchList:buildLayer(  )

	imageView = UIUtil.addImageView({image = ResLib.TABLEVIEW_BG, touch=false, scale=true, size=cc.size(display.width, display.height-130), pos=cc.p(0,0), parent=self})

	-- addTopBar
	UIUtil.addTopBar({backFunc = Callback, title = "搜索结果", parent = self})

	-- dump(curData)
	if next(curData) ~= nil then
		self:createTableView( )
	else
		UIUtil.addPosSprite("club/card_icon_face.png", cc.p(display.cx, display.cy), imageView, cc.p(0.5, 0.5))
	end

end

function SearchList:createTableView(  )
	print('tableView')
	local function tableCellTouched( tableViewSender, tableCell )
		print('  tableCellTouched  ' ..tableCell:getIdx())
		local idx = tableCell:getIdx()+1
		local data = curData[idx]
		if data.target == CLUB_TAG or data.target == "union_club" then
			ClubCtrol.dataStatClubInfo( data.id, function (  )
				local clubInfo = require('club.ClubInfo')
				local layer = clubInfo:create()
				_searchList:addChild(layer)
				layer:createLayer( curTarget )
			end )
		elseif data.target == FRIEND_TAG then
			local personInfo = require("friend.PersonInfo")
			local layer = personInfo:create()
			_searchList:addChild(layer)
			layer:createLayer(curData[idx])
		end
	end

	local function cellSizeForTable( tableViewSender, cellIndex )
		--print('cellSizeForTable')
		local data = curData[cellIndex+1]
		if data.target == CLUB_TAG or data.target == UNION_TAG or data.target == "union_club" then
			-- return 0, 168
			return 0, 200
		elseif data.target == FRIEND_TAG then
			return 0, 130
		end
	end

	local function numberOfCellsInTableView( tableViewSender )
		return #curData
	end

	local function tableCellAtIndex( tableViewSender, cellIndex )
		local index = cellIndex + 1
		local cellItem = tableViewSender:dequeueCell()
		if cellItem == nil then
			cellItem = cc.TableViewCell:new()
			-- 创建函数
			self:buildCellTmpl( cellItem )

		end
		self:updateCellTmpl( cellItem, curData[index] )
		-- 修改函数
		return cellItem
	end

	local tableView = cc.TableView:create( cc.size(display.width, display.height-130))
	tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
	tableView:setPosition(cc.p(0,0))
	imageView:addChild(tableView)
	tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
	tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
	tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
	tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
	tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
	tableView:setDelegate()
	tableView:reloadData()
	return tableView
end

function SearchList:buildCellTmpl( cellItem )
	local girdNodes = {}
	girdNodes = cellItem

	local cellBg = UIUtil.addImageView({image=ResLib.TABLEVIEW_CELL_BG, touch=false, scale=true, size=cc.size(display.width, sizeY), pos=cc.p(0,0), ah=cc.p(0,0), parent=cellItem})
	girdNodes.cellBg = cellBg

	local width = cellBg:getContentSize().width
	local height = cellBg:getContentSize().height

	-- 玩家搜索俱乐部、联盟搜索俱乐部、搜索联盟
	local node1 = cc.Node:create()
	node1:setContentSize(cc.size(width, height))
	node1:setPosition(cc.p(0,0))
	cellBg:addChild(node1)
	girdNodes.node1 = node1

	-- 头像
	local stencil1, Icon1 = UIUtil.createCircle(ResLib.CLUB_HEAD_GENERAL, cc.p(70,height/2), node1, ResLib.CLUB_HEAD_STENCIL_200)
	girdNodes.stencil1 = stencil1
	girdNodes.Icon1 = Icon1

	local clubName, club_icon = UIUtil.addNameByType({nameType = 1, nameStr = "俱乐部", fontSize = 34, pos = cc.p(140, height/2+40), parent = node1})
	clubName:enableBold()
	girdNodes.clubName = clubName
	girdNodes.club_icon = club_icon

	-- 俱乐部等级
	local clubLevel = UIUtil.addLabelArial('', 25, cc.p(club_icon:getPositionX()+club_icon:getContentSize().width+10, club_icon:getPositionY()), cc.p(0, 0.5), node1):setColor(ResLib.COLOR_GREEN)
	girdNodes.clubLevel = clubLevel
		
	-- 俱乐部总人数/当前人数
	girdNodes.countIcon = UIUtil.addPosSprite("club/icon_user_blue.png", cc.p(140, height/2), node1, cc.p(0, 0.5))
	local clubCount = UIUtil.addLabelArial('', 22, cc.p(180, height/2), cc.p(0, 0.5), node1):setColor(ResLib.COLOR_GREY1)
	girdNodes.clubCount = clubCount

	-- 俱乐部所在地区
	local clubPlace = UIUtil.addLabelArial('', 22, cc.p(350, height/2), cc.p(0, 0.5), node1):setColor(ResLib.COLOR_GREY1)
	girdNodes.clubPlace = clubPlace

	local clubDes = UIUtil.addLabelArial('快来加入我们吧！', 24, cc.p(140, height/2-35), cc.p(0, 0.5), node1):setColor(ResLib.COLOR_GREY)
	girdNodes.clubDes = clubDes

	local function clubBtnClick( sender )
		local tag = sender:getTag()
		self:btnClick(tag)
	end
	-- local label = cc.Label:createWithSystemFont("", "Marker Felt", 24):setColor(ResLib.COLOR_BLUE)
	-- local button1 = UIUtil.controlBtn(ResLib.BTN_BLUE_BORDER_SMALL, ResLib.BTN_BLUE_BORDER_SMALL, ResLib.BTN_BLUE_BORDER_SMALL, label, cc.p(width-79, height/2), cc.size(117,39), clubBtnClick, cellBg)

	local button1 = UIUtil.addImageBtn({norImg = "club/club_jiaru_1.png", selImg = "club/club_jiaru_2.png", disImg = "club/club_jiaru_2.png", pos = cc.p(width-79, height/2), ah = cc.p(0.5, 0.5), swalTouch = true, touch = true,  listener = clubBtnClick, parent = node1})
	girdNodes.button1 = button1
	local btnState = UIUtil.addLabelArial('', 28, cc.p(width-25, height/2), cc.p(1, 0.5), node1):setColor(ResLib.COLOR_GREY)
	girdNodes.btnState = btnState


	-- 好友
	local node2 = cc.Node:create()
	node2:setContentSize(cc.size(width, height))
	node2:setPosition(cc.p(0,0))
	cellBg:addChild(node2)
	girdNodes.node2 = node2

	-- 头像
	local stencil2, Icon2 = UIUtil.createCircle(default_head, cc.p(70,height/2), node2, ResLib.CLUB_HEAD_STENCIL_200)
	girdNodes.stencil2 = stencil2
	girdNodes.Icon2 = Icon2

	local userName = UIUtil.addLabelArial('name', 36, cc.p(140, height/2), cc.p(0, 0.5), node2)
	girdNodes.userName = userName

	local function friendFunc( sender )
		local tag = sender:getTag()
		print(tag)
		for k,v in pairs(curData) do
			if tonumber(v.id) == tonumber(tag) then
				local test = require("club.ClubTest")
				local layer = test:create()
				_searchList:addChild(layer)
				layer:createLayer(curData[k], "friend")
				break
			end
		end
	end

	local label = cc.Label:createWithSystemFont("", "Marker Felt", 24):setColor(ResLib.COLOR_BLUE)
	local button2 = UIUtil.controlBtn(ResLib.BTN_BLUE_BORDER_SMALL, ResLib.BTN_BLUE_BORDER_SMALL, ResLib.BTN_BLUE_BORDER_SMALL, label, cc.p(width-79, height/2), cc.size(117,39), friendFunc, node2)
	girdNodes.button2 = button2
end

function SearchList:btnClick( tag )
	for k,v in pairs(curData) do
		if tonumber(v.id) == tonumber(tag) then
			if v.target == "union_club" then
				if v.is_join_union == 0 then
					local test = require("club.ClubTest")
					local layer = test:create()
					_searchList:addChild(layer)
					layer:createLayer(curData[k], curTarget)
				end
			elseif v.target == UNION_TAG then
				local test = require("club.ClubTest")
				local layer = test:create()
				_searchList:addChild(layer)
				layer:createLayer(curData[k], curTarget)
			else
				if v.flag == 0 then
					local test = require("club.ClubTest")
					local layer = test:create()
					_searchList:addChild(layer)
					layer:createLayer(curData[k], curTarget)
				else
					print("进入俱乐部")
					local MessageCtorl = require("message.MessageCtorl")
					MessageCtorl.setChatData(v.id)
					MessageCtorl.setChatType(MessageCtorl.CHAT_CLUB)

					NoticeCtrol.removeNoticeById(20002)
		
					local Message = require('message.MessageScene')
					Message.startScene()
				end
			end
			break
		end
	end
end

function SearchList:updateCellTmpl( cellItem, cellData )
	local girdNodes = cellItem
	local data = cellData
	local url = ""
	
	if data.target == CLUB_TAG or data.target == "union_club" then
		girdNodes.node1:setVisible(true)
		girdNodes.node2:setVisible(false)

		local name = StringUtils.getShortStr( data.name, LEN_NAME)
		girdNodes.clubName:setString(name)
		url = data.avatar

		girdNodes.countIcon:setTexture("club/icon_user_blue.png")
		if data.union == "1" then
			girdNodes.clubCount:setString(data.users_count .. '/无限制')
			UIUtil.updateNameByType( 2, girdNodes.clubName, girdNodes.club_icon )
			girdNodes.Icon1:setTexture(ResLib.CLUB_HEAD_ORIGIN)
			girdNodes.clubLevel:setString("")
		else
			girdNodes.clubCount:setString(data.users_count .. '/' .. data.users_limit)
			UIUtil.updateNameByType( 1, girdNodes.clubName, girdNodes.club_icon )
			girdNodes.Icon1:setTexture(ResLib.CLUB_HEAD_GENERAL)
			girdNodes.clubLevel:setString(data.level.."级")
		end
		girdNodes.clubLevel:setPositionX(girdNodes.club_icon:getPositionX() + girdNodes.club_icon:getContentSize().width + 10)
		girdNodes.clubPlace:setString(ClubCtrol.getNumberOfSite(data.address))

		girdNodes.button1:setTag(data.id)
		if data.target == CLUB_TAG then
			girdNodes.button1:setVisible(true)
			girdNodes.btnState:setString("")
			if data.flag == 0 then
				girdNodes.button1:setEnabled(true)
				girdNodes.button1:loadTextures("club/club_jiaru_1.png", "club/club_jiaru_2.png", "club/club_jiaru_2.png")
			else
				girdNodes.button1:setEnabled(true)
				girdNodes.button1:loadTextures("club/club_jinru_1.png", "club/club_jinru_2.png", "club/club_jinru_2.png")
			end
		elseif data.target == "union_club" then
			if data.is_join_union == 0 then
				girdNodes.button1:setVisible(true)
				girdNodes.btnState:setString("")

				girdNodes.button1:setEnabled(true)
				girdNodes.button1:loadTextures("club/club_yaoq_1.png", "club/club_yaoq_2.png", "club/club_yaoq_2.png")
			else
				girdNodes.button1:setVisible(false)
				girdNodes.btnState:setString("已加入")
			end
		end
		local function funcBack( path )
			local function onEvent(event)
				if event == "exit" then
					return
				end
			end
			girdNodes.Icon1:registerScriptHandler(onEvent)
			-- local rect = girdNodes.stencil:getContentSize()
			girdNodes.Icon1:setTexture(path)
			-- girdNodes.Icon:setTextureRect(rect)
		end
		if url ~= "" then
			ClubModel.downloadPhoto(funcBack, url, true)
		end

	elseif data.target == UNION_TAG then
		girdNodes.node1:setVisible(true)
		girdNodes.node2:setVisible(false)
		
		url = data.union_avatar
		local name = StringUtils.getShortStr( data.union_name, LEN_NAME)
		girdNodes.clubName:setString(name)

		UIUtil.updateNameByType( 3, girdNodes.clubName, girdNodes.club_icon )
		girdNodes.Icon1:setTexture(ResLib.UNION_HEAD)

		girdNodes.countIcon:setTexture(ResLib.CLUB_HEAD_GENERAL_SMALL)
		girdNodes.clubCount:setString("1/无限制")
		girdNodes.clubPlace:setString(ClubCtrol.getNumberOfSite(data.union_city))
		if data.union_describe ~= "" then
			girdNodes.clubDes:setString(data.union_describe)
		end
		girdNodes.button1:setTag(data.id)
		girdNodes.button1:loadTextures("club/club_jiaru_1.png", "club/club_jiaru_2.png", "club/club_jiaru_2.png")
		local function funcBack( path )
			local function onEvent(event)
				if event == "exit" then
					return
				end
			end
			girdNodes.Icon1:registerScriptHandler(onEvent)
			-- local rect = girdNodes.stencil:getContentSize()
			girdNodes.Icon1:setTexture(path)
			-- girdNodes.Icon:setTextureRect(rect)
		end
		if url ~= "" then
			ClubModel.downloadPhoto(funcBack, url, true)
		end

	elseif data.target == FRIEND_TAG then
		girdNodes.node1:setVisible(false)
		girdNodes.node2:setVisible(true)

		url = data.headimg
		local name = StringUtils.getShortStr( data.username, LEN_NAME)
		girdNodes.userName:setString(name)

		girdNodes.Icon2:setTexture(ResLib.USER_HEAD)

		if data.friends == "no" then
			girdNodes.button2:setVisible(true)
			girdNodes.button2:setTag(data.id)
			girdNodes.button2:setEnabled(true)
			girdNodes.button2:setTitleForState("添加", cc.CONTROL_STATE_NORMAL)
			girdNodes.button2:setTitleForState("添加", cc.CONTROL_STATE_DISABLED)
			if tonumber(data.id) == tonumber(USER_ID) then
				girdNodes.button:setVisible(false)
			end
		else
			girdNodes.button2:setVisible(true)
			girdNodes.button2:setEnabled(false)
			girdNodes.button2:setTitleForState("已添加", cc.CONTROL_STATE_NORMAL)
			girdNodes.button2:setTitleForState("已添加", cc.CONTROL_STATE_DISABLED)
		end
		local function funcBack( path )
			local function onEvent(event)
				if event == "exit" then
					return
				end
			end
			girdNodes.Icon2:registerScriptHandler(onEvent)
			-- local rect = girdNodes.stencil:getContentSize()
			girdNodes.Icon2:setTexture(path)
			-- girdNodes.Icon:setTextureRect(rect)
		end
		if url ~= "" then
			ClubModel.downloadPhoto(funcBack, url, true)
		end
	end
end

function SearchList:buildData( data )
	local tmpData = {}

	-- 个人搜索俱乐部/ 联盟搜索俱乐部数据/ 好友搜索数据
	if curTarget == CLUB_TAG or curTarget == UNION_TAG or curTarget == FRIEND_TAG then
		for k,v in pairs(data) do
			local tmp = {}
			tmp = v
			tmp["target"] = curTarget
			tmpData[#tmpData+1] = tmp
		end
	-- 搜索联盟
	elseif curTarget == "union_club" then
		for k,v in pairs(data) do
			if tonumber(v.union) == 0 then
				local tmp = {}
				tmp = v
				tmp["target"] = curTarget
				tmpData[#tmpData+1] = tmp
			end
		end
	end
	return tmpData
end

function SearchList:createLayer( data, target )
	_searchList = self
	_searchList:setSwallowTouches()
	_searchList:addTransitAction()

	UIUtil.setBgScale(ResLib.MAIN_BG, display.center, self)

	self:init()
	curTarget = target

	curData = self:buildData(data)

	USER_ID = Single:playerModel():getId()

	-- 俱乐部搜索数据
	if curTarget == CLUB_TAG or curTarget == UNION_TAG then
		sizeX, sizeY = 0, 200
	elseif curTarget == "union_club" then
		sizeX, sizeY = 0, 200
	-- 好友搜索数据
	elseif curTarget == FRIEND_TAG then
		sizeX, sizeY = 0, 130
	end
	
	self:buildLayer()
end

function SearchList:init(  )
	curData 	= {}
	curTarget 	= nil
	sizeX, sizeY = nil, nil
	CLUB_TAG = "club"
	FRIEND_TAG = "friend"
	UNION_TAG = "union"
end

return SearchList