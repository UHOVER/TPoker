local ViewBase = require("ui.ViewBase")
local CircleList = class("CircleList", ViewBase)

local MineCtrol = require("mine.MineCtrol")

local _circleList = nil
local tab = {font = "Arial", size = 30}
local curData = {}
local curTableView = nil
local imageView = nil

local function Callback(  )
	_circleList:removeTransitAction()
end

local function newCircle(  )

	MineCtrol.createCircleWay("circlelist")

	local newCircle = require("message.NewCircle")
	local layer = newCircle:create()
	_circleList:addChild(layer)
	layer:createLayer("new")
end

function CircleList:buildLayer(  )
	
	-- topBar
    UIUtil.addTopBar({backFunc = Callback, title = "我的圈子", menuFont = "新建圈子", menuFunc = newCircle, parent = self})

	imageView = UIUtil.addImageView({touch=true, scale=true, size=cc.size(display.width, display.height-130), pos=cc.p(0,0), parent=self})
	curTableView = nil
	curData = MineCtrol.getCircleList()

	if next(curData) ~= nil then
		curTableView = self:createTableView()
		curTableView:reloadData()
	else
		UIUtil.addPosSprite("club/card_icon_face.png", cc.p(display.cx, display.height*0.65), imageView, cc.p(0.5, 0.5))
	end
end

-- 刷新
function CircleList.updateTableView(  )
	curData = MineCtrol.getCircleList()

	if curTableView then
		curTableView:removeFromParent()
		curTableView = nil

		if #curData ~= 0 then
			curTableView = _circleList:createTableView()
			curTableView:reloadData()
		end
	end
end

function CircleList:createTableView(  )
	local function tableCellTouched( tableViewSender, tableCell )
		-- body
		local idx = tableCell:getIdx() + 1
		print('tableCell: ' ..tableCell:getIdx() )
		if idx < #curData+1 then
			
			local MessageCtorl = require("message.MessageCtorl")
			MessageCtorl.setChatData(curData[idx]['id'])
			MessageCtorl.setChatType(MessageCtorl.CHAT_CIRCLE)

			local Message = require('message.MessageScene')
			Message.startScene()
		end

	end
	local function cellSizeForTable( tableViewSender, cellIndex )
		return 0, 130
	end
	local function numberOfCellsInTableView( tableViewSender )
		return #curData+1
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
	tableView:setBounceable(true)
	tableView:setDelegate()
	tableView:reloadData()
	return tableView
end

function CircleList:buildCellTmpl(cellItem, cellIndex)
	local girdNodes = {}
	girdNodes = cellItem

	local cellBg = UIUtil.addImageView({image = ResLib.TABLEVIEW_CELL_BG, touch=false, scale=true, size=cc.size(display.width, 120),pos=cc.p(0,0), ah=cc.p(0,0), parent=cellItem})
	girdNodes.cellBg = cellBg
	local width = cellBg:getContentSize().width
	local sizeH = cellBg:getContentSize().height

	local stencil, icon = UIUtil.createCircle(ResLib.CIRCLE_HEAD, cc.p(70,sizeH/2), cellBg, ResLib.CLUB_HEAD_STENCIL_200)
	girdNodes.stencil = stencil
	girdNodes.icon = icon

	-- local name = UIUtil.addLabelArial('name', 30, cc.p(155, sizeH/2), cc.p(0,0.5), cellBg)
	-- girdNodes.name = name
	local name, circle_icon = UIUtil.addNameByType({nameType = 4, nameStr = "", fontSize = 35, pos = cc.p(140, sizeH/2), parent = cellBg})
	girdNodes.name = name
	girdNodes.circle_icon = circle_icon

	local node = cc.Node:create()
			:addTo(cellBg)
	node:setPosition(cc.p(0,0))
	girdNodes.node = node
	local str = "共"..#curData .. "个圈子"
	UIUtil.addLabelArial(str, 30, cc.p(display.cx, 60), cc.p(0.5, 0.5), node):setColor(ResLib.COLOR_GREY)

end

function CircleList:updateCellTmpl(cellItem, cellIndex)
	local girdNodes = cellItem
	local data = {}

	if cellIndex == #curData then
		girdNodes.node:setVisible(true)
		girdNodes.icon:setVisible(false)
		girdNodes.name:setVisible(false)
		girdNodes.circle_icon:setVisible(false)
		girdNodes.cellBg:loadTexture(ResLib.TABLEVIEW_CELL_BG_NOLINE, 0)
	else
		girdNodes.node:setVisible(false)
		girdNodes.icon:setVisible(true)
		girdNodes.name:setVisible(true)
		girdNodes.circle_icon:setVisible(true)

		data = curData[cellIndex+1]

		local url = data.avatar
		local function funcBack( path )
			local rect = girdNodes.stencil:getContentSize()
			girdNodes.icon:setTexture(path)
			girdNodes.icon:setTextureRect(rect)
		end
		if data.avatar ~= "" then
			ClubModel.downloadPhoto(funcBack, url, true)
		end

		-- 圈子名称
		local nameStr = data.circle_nickname
		local name = ""
		if nameStr == "" or nameStr == nil then
			for k,v in pairs(data.players) do
				name = name..v.."、"
			end
		else
			name = nameStr
		end

		girdNodes.name:setString( StringUtils.getShortStr( name, LEN_NAME) )
		UIUtil.updateNameByType( 4, girdNodes.name, girdNodes.circle_icon )
	end
end

function CircleList:createLayer(  )
	_circleList = self
	_circleList:setSwallowTouches()
	_circleList:addTransitAction()
	UIUtil.setBgScale(ResLib.MAIN_BG, display.center, self)

	self:buildLayer()

end

return CircleList