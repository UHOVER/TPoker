local ViewBase = require('ui.ViewBase')
local FriendList = class('FriendList', ViewBase)
local MineCtrol = require('mine.MineCtrol')


local MineLayer = require("mine.MineLayer")

local _friendList = nil

local tab = {}
	tab['font'] = 'Arial'
	tab['size'] = 30

local imageView = nil
local curTableView = nil
local friendData = {}
local curData = {}

local redPoint_bg = nil

local letter_sp = nil

local function Callback(  )
	_friendList:removeTransitAction()
	NoticeCtrol.removeNoticeById(10003)
end

local function addCallback(  )
	local addFriend = require("friend.addFriend")
	local layer = addFriend:create()
	_friendList:addChild(layer, 100)
	layer:createLayer()
end

local function letterFunc(  )
	
end

function FriendList:buildLayer(  )
	
	-- topBar
    UIUtil.addTopBar({backFunc = Callback, title = "我的好友", menuFont = "添加好友", menuFunc = addCallback, parent = self})

	imageView = UIUtil.addImageView({touch=false, scale=true, size=cc.size(display.width, display.height-130), parent=self})

	self:addTableView()

	-- self:buildLetterBtn()
	
end

function FriendList:buildLetterBtn(  )
	local letterTab = MineCtrol.getLetter()

	local count = #letterTab
	local letterBtn = {}
	if letter_sp then
		letter_sp:removeFromParent()
		letter_sp = nil
	end
	letter_sp = UIUtil.addImageView({image="common/com_opacity0.png", touch=false, scale=true, size=cc.size(30, count*40), pos=cc.p(display.width-10, display.cy), ah=cc.p(1,0.5), parent=imageView})
	letter_sp:setLocalZOrder(50)
	local width = letter_sp:getContentSize().width
	local height = letter_sp:getContentSize().height

	local tmp = {}
	tmp['font'] = 'Arial'
	tmp['size'] = 26

	for i=1,count do
		local posY = (2*i-1)/(count*2)
		letterBtn[i] = UIUtil.addMenuFont(tmp, letterTab[i], cc.p(width/2, height*posY), letterFunc, letter_sp):setColor(display.COLOR_WHITE)
		letterBtn[i]:setTag(i)
	end

end

function FriendList:addTableView(  )
	curData = MineCtrol.getFriendList()
	dump(curData)
	-- print(#curData)
	if curTableView then
		curTableView:removeFromParent()
		curTableView = nil
	end
	if #curData+2 >= 2 then
		curTableView = self:createTableView()
		curTableView:reloadData()

		self:buildLetterBtn()
	end
end

function FriendList:createTableView( )
	local function tableCellTouched( tableViewSender, tableCell )
		local idx = tableCell:getIdx()
		if idx == 0 then
			MineCtrol.dataStatFriendMsg(function ( data )
				local friendNew = require("friend.FriendNew")
				local layer = friendNew:create()
				_friendList:addChild(layer, 100)
				layer:createLayer(data)
			end)
		elseif idx > 0 and idx < #curData+1 then
			_friendList:touchTableCell(idx)
		end
	end
	local function cellSizeForTable( tableViewSender, cellIndex )
		if cellIndex == 0 or cellIndex == #curData+1 then
			return 0, 98
		else
			if curData[cellIndex].first == 2 then
				return 0, 174
			else
				return 0, 138
			end
		end
	end
	local function numberOfCellsInTableView( tableViewSender )
		return #curData+2
	end
	local function tableCellAtindex( tableViewSender, cellIndex )
		local index = cellIndex
		local cellItem = tableViewSender:dequeueCell()
		if cellItem == nil then
			cellItem = cc.TableViewCell:new()
			self:buildCellTmpl(cellItem, index)
		end

		self:updateCellTmpl(cellItem, index)
		return cellItem
	end
	
	local tableView = cc.TableView:create(cc.size(display.width, display.height-130))
	tableView:setPosition(cc.p(0,0))
	imageView:addChild(tableView)
	tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
	tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
	tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
	tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
	tableView:registerScriptHandler(tableCellAtindex, cc.TABLECELL_SIZE_AT_INDEX)
	tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
	tableView:setDelegate()
	return tableView
end

function FriendList:buildCellTmpl(cellItem, cellIndex )
	local girdNodes = {}
	girdNodes = cellItem

	local sizeH = nil
	local color = cc.c3b(169, 170, 171)
	-- if cellIndex == 0 or cellIndex == #curData+1 then
	-- 	sizeH = 110
	-- else
	-- 	sizeH = 120
	-- end


	local cellBg = UIUtil.addImageView({image = ResLib.TABLEVIEW_CELL_BG, touch=false, scale=true, size=cc.size(display.width, 98),pos=cc.p(0,0), ah=cc.p(0,0), parent=cellItem})
	girdNodes.cellBg = cellBg
	sizeH = 138

	--------------
	local node1 = cc.Node:create()
	node1:setPosition(cc.p(0,0))
	cellBg:addChild(node1)
	girdNodes.node1 = node1

	local textBg = UIUtil.addPosSprite(ResLib.TABLEVIEW_TEXT_LINE, cc.p(display.width/2, 174), node1, cc.p(0.5, 1))
	girdNodes.textBg = textBg

	local text = UIUtil.addLabelArial('', 26, cc.p(20, textBg:getContentSize().height/2), cc.p(0, 0.5), textBg)
	girdNodes.text = text

	local stencil, icon = UIUtil.createCircle(ResLib.USER_HEAD, cc.p(70,sizeH/2), node1, ResLib.CLUB_HEAD_STENCIL_200)
	girdNodes.icon = icon
	girdNodes.stencil = stencil

	local name = UIUtil.addLabelArial('name', 36, cc.p(140, sizeH/2), cc.p(0,0.5), node1)
	girdNodes.name = name

	local team_icon = UIUtil.addPosSprite("bg/zd_flag.png", cc.p(display.width-31, sizeH/2), node1, cc.p(1, 0.5))
	local team_name = UIUtil.addLabelArial('name', 26, cc.p(team_icon:getPositionX()-team_icon:getContentSize().width-10, sizeH/2), cc.p(1,0.5), node1):setColor(cc.c3b(9, 183, 66))
	girdNodes.team_icon = team_icon
	girdNodes.team_name = team_name

	--------------
	local node2 = cc.Node:create()
			:addTo(cellBg)
	node2:setPosition(cc.p(0,0))
	girdNodes.node2 = node2

	local redPoint_bg = UIUtil.addImageView({image = ResLib.COM_OPACITY0, touch=false, scale=true, size=cc.size(display.width, 98), pos=cc.p(0, 0), ah=cc.p(0, 0), parent= node2})
	girdNodes.redPoint_bg = redPoint_bg

	local sp = UIUtil.addPosSprite("common/icon_add_friend.png", cc.p(20, 98/2), node2, cc.p(0, 0.5))
	UIUtil.addLabelArial('好友请求', 30, cc.p(sp:getPositionX()+sp:getContentSize().width+18, 98/2), cc.p(0,0.5), node2)
	UIUtil.addPosSprite(ResLib.BTN_BACK_RIGHT, cc.p(display.width-20, 98/2), node2, cc.p(1, 0.5))
	
	-------------
	local node3 = cc.Node:create()
			:addTo(cellBg)
	node3:setPosition(cc.p(0,0))
	girdNodes.node3 = node3
	local str = "共"..#curData .. "位好友"
	UIUtil.addLabelArial(str, 30, cc.p(display.width/2, 98-36), cc.p(0.5, 1), node3):setColor(cc.c3b(152, 152, 152))
	
end

function FriendList:updateCellTmpl(cellItem, cellIndex )
	local girdNodes = cellItem
	if cellIndex == 0 then
		girdNodes.cellBg:setContentSize(cc.size(display.width, 98))
		girdNodes.cellBg:loadTexture(ResLib.TABLEVIEW_CELL_BG_NOLINE)
		redPoint_bg = girdNodes.redPoint_bg
		_friendList.buildRedPoint(  )
		
		girdNodes.node1:setVisible(false)
		girdNodes.node2:setVisible(true)
		girdNodes.node3:setVisible(false)
		girdNodes.textBg:setVisible(false)
	elseif cellIndex == #curData+1 then
		girdNodes.cellBg:setContentSize(cc.size(display.width, 98))
		girdNodes.node1:setVisible(false)
		girdNodes.node2:setVisible(false)
		girdNodes.node3:setVisible(true)
		girdNodes.textBg:setVisible(false)

		girdNodes.cellBg:loadTexture(ResLib.TABLEVIEW_CELL_BG_NOLINE, 0)
	else
		girdNodes.cellBg:setContentSize(cc.size(display.width, 138))
		
		girdNodes.node1:setVisible(true)
		girdNodes.node2:setVisible(false)
		girdNodes.node3:setVisible(false)
		local data = curData[cellIndex]
		-- dump(data)
		girdNodes.name:setString(data.user_name)

		girdNodes.text:setString(data.key)
		if data.first == 2 then
			girdNodes.textBg:setVisible(true)
			girdNodes.cellBg:loadTexture(ResLib.IMG_CELL_BG3)
		elseif data.first == 1 then
			girdNodes.textBg:setVisible(false)
			girdNodes.cellBg:loadTexture(ResLib.IMG_CELL_BG2_1)
		else
			girdNodes.textBg:setVisible(false)
			girdNodes.cellBg:loadTexture(ResLib.IMG_CELL_BG2)
		end

		-- girdNodes.delBtn:setTag(data.id)

		if data.headimg ~= "" then
			local url = data.headimg
			local function funcBack( path )
				if girdNodes.stencil ~= nil and girdNodes.icon ~= nil then
					local rect = girdNodes.stencil:getContentSize()
					girdNodes.icon:setTexture(path)
					girdNodes.icon:setTextureRect(rect)
				end
			end
			ClubModel.downloadPhoto(funcBack, url, true)
		end

		-- team
		if data.team_name and data.team_name ~= "" then
			girdNodes.team_name:setString(data.team_name)
			girdNodes.team_icon:setVisible(true)
		else
			girdNodes.team_name:setString("")
			girdNodes.team_icon:setVisible(false)
		end
	end
end

function FriendList.buildRedPoint(  )
	-- Notice.removeRedPoint(  )

	NoticeCtrol.setNoticeNode( POS_ID.POS_10003, redPoint_bg )

	Notice.registRedPoint( 1 )

end

function FriendList:deleteFriend( id )
	local layer = nil
	local function deleteFriend(  )
		local function response( data )
			dump(data)
			if data.code == 0 then
				for k,v in pairs(curData) do
					if id == v.id then
						
						layer:removeFromParent()

						table.remove(curData, k)
						curTableView:reloadData()
						break
					end
				end
			end
		end
		local tabData = {}
		tabData["user_id"] = id
		XMLHttp.requestHttp("delFriend", tabData, response, PHP_POST)
	end
	layer = ViewCtrol.showTips({title = "删除好友", content = "你确定要删除吗？", rightListener = deleteFriend})
end

function FriendList:touchTableCell( idx )
	-- data
	local data = curData[idx]
	-- dump(data)
	local personInfo = require("friend.PersonInfo")
	local layer = personInfo:create()
	_friendList:addChild(layer, 100)
	layer:createLayer( data )

end

function FriendList:createLayer(  )
	_friendList = self
	_friendList:setSwallowTouches()
	_friendList:addTransitAction()

	UIUtil.setBgScale(ResLib.MAIN_BG, display.center, self)
	local function onNodeEvent(event)
		if event == "enter" then
		elseif event == "exit" then
			NoticeCtrol.removeNoticeById(10003)
		end
	end
	self:registerScriptHandler(onNodeEvent)

	self:init()
	self:buildLayer()

end

function FriendList:init(  )
	curTableView = nil
	curData = {}
	letter_sp = nil
end

return FriendList