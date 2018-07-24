local ViewBase = require("ui.ViewBase")
local ClubManage = class("ClubManage", ViewBase)
local ClubCtrol = require("club.ClubCtrol")

local _clubManage = nil
local imageView = nil
local curData = {}
local curTableView = nil

local function Callback(  )
	_clubManage:removeFromParent()
	local myEvent = cc.EventCustom:new("C_Event_update_ClubInfo")
	local customEventDispatch = cc.Director:getInstance():getEventDispatcher()
	customEventDispatch:dispatchEvent(myEvent)
end

local function delCallback(  )
	local manageUpate = require("club.CManaUpdate")
	local layer = manageUpate:create()
	_clubManage:addChild(layer, 10)
	layer:createLayer(2)
end

function ClubManage:buildLayer(  )
	local manaList = ClubCtrol.getManaList()
	local addMana = {text='添加管理员', cellType=1}
	for i=1,#manaList do
		local tmp = {}
		tmp = manaList[i]
		tmp['cellType'] = 0
		tmp['create'] = 0
		if ClubCtrol.getClubIsCreate() then
			tmp['create'] = 1
		end
		curData[#curData+1] = tmp
	end
	local menuStr = nil
	if ClubCtrol.getClubIsCreate() then
		curData[#curData+1] = addMana
		menuStr = '删除'
	end

	UIUtil.addTopBar({backFunc = Callback, title = "设置管理员", menuFont = menuStr, menuFunc = delCallback, parent = self})
	imageView = UIUtil.addImageView({image = ResLib.TABLEVIEW_BG, touch=false, scale=true, size=cc.size(display.width, display.height-130), pos=cc.p(0,0), parent=self})

	local siteBg = UIUtil.addImageView({image = ResLib.TABLEVIEW_TEXT_LINE, touch=false, scale=true, size=cc.size(display.width, 40),pos=cc.p(display.width/2, display.height-130), ah=cc.p(0.5,1), parent=imageView})
	local site = UIUtil.addLabelArial('管理员', 26, cc.p(20, siteBg:getContentSize().height/2), cc.p(0, 0.5), siteBg):setColor(ResLib.COLOR_GREY1)
	local num = UIUtil.addLabelArial(#manaList, 26, cc.p(display.width-20, siteBg:getContentSize().height/2), cc.p(1, 0.5), siteBg):setColor(ResLib.COLOR_GREY1)
	
	-- dump(curData)
	curTableView = self:createTableView()
	curTableView:reloadData()
end

function ClubManage:updateMana(  )
	curData = {}
	local manaList = ClubCtrol.getManaList()
	local addMana = {text='添加管理员', cellType=1}
	for i=1,#manaList do
		local tmp = {}
		tmp = manaList[i]
		tmp['cellType'] = 0
		curData[#curData+1] = tmp
	end
	
	curData[#curData+1] = addMana
	curTableView:reloadData()
end

function ClubManage:createTableView(  )
	local function tableCellTouched( tableViewSender, tableCell )
		local idx = tableCell:getIdx() + 1
		local data = curData[idx]
		if data.cellType == 1 then
			ClubCtrol.dataStatMember( function (  )
				local manageUpate = require("club.CManaUpdate")
				local layer = manageUpate:create()
				_clubManage:addChild(layer, 10)
				layer:createLayer(1)
			end )
		else
			if not data then
				return
			end
			local cmanaLook = require("club.CManaLook")
			local layer = cmanaLook:create()
			_clubManage:addChild(layer, 10)
			layer:createLayer(data.permis)
		end
	end

	local function cellSizeForTable( tableViewSender, cellIndex )
		return 0, 100
	end

	local function numberOfCellsInTableView( tableViewSender )
		return #curData
	end

	local function tableCellAtIndex( tableViewSender, cellIndex )
		local index = cellIndex+1
		local cellItem = tableViewSender:dequeueCell()
		if cellItem == nil then
			cellItem = cc.TableViewCell:new()
			self:buildCellTmpl(cellItem)
		end

		self:updateCellTmpl(cellItem, index )

		return cellItem
	end

	local tableView = cc.TableView:create(cc.size(display.width, imageView:getContentSize().height-40))
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

function ClubManage:buildCellTmpl( cellItem )
	local girdNodes = {}
	girdNodes = cellItem

	local cellBg = UIUtil.addImageView({image = ResLib.TABLEVIEW_CELL_BG_LINE_2, touch=false, scale=true, size=cc.size(display.width, 100),pos=cc.p(0,0), ah=cc.p(0,0), parent=cellItem})
	girdNodes.cellBg = cellBg
	local width = cellBg:getContentSize().width
	local height = cellBg:getContentSize().height

	local node1 = cc.Node:create()
	node1:setPosition(cc.p(0,0))
	cellBg:addChild(node1)
	girdNodes.node1 = node1

	-- 头像
	local stencil, Icon = UIUtil.createCircle(ResLib.USER_HEAD, cc.p(60,height/2), node1, ResLib.CLUB_HEAD_STENCIL_200, 0.4)
	girdNodes.stencil = stencil
	girdNodes.Icon = Icon

	local iconMark = UIUtil.addPosSprite("common/com_icon_manager.png", cc.p(60+20,height/2-25), node1, cc.p(0.5, 0.5))
	girdNodes.iconMark = iconMark

	-- 名称
	local Name = UIUtil.addLabelArial('名称', 30, cc.p(140, height/2), cc.p(0, 0.5), node1)
	girdNodes.Name = Name

	-- 编辑
	local function editFunc( sender )
		local tag = sender:getTag()
		if not curData[tag] then
			return
		end
		local cmanaEdit = require("club.CManaEdit")
		local layer = cmanaEdit:create()
		_clubManage:addChild(layer, 10)
		layer:createLayer(curData[tag])
	end
	local label = cc.Label:createWithSystemFont("编辑", "Marker Felt", 34):setColor(ResLib.COLOR_BLUE)
	local editBtn = UIUtil.controlBtn(ResLib.COM_OPACITY0, ResLib.COM_OPACITY0, ResLib.COM_OPACITY0, label, cc.p(width-10, height/2), cc.size(label:getContentSize().width+40,80), editFunc, node1):setAnchorPoint(cc.p(1,0.5))
	girdNodes.editBtn = editBtn

	local node2 = cc.Node:create()
	node2:setPosition(cc.p(0,0))
	cellBg:addChild(node2)
	girdNodes.node2 = node2

	UIUtil.addPosSprite("club/manage_add.png", cc.p(20,height/2), node2, cc.p(0, 0.5))

	local addManage = UIUtil.addLabelArial('添加管理员', 30, cc.p(130, height/2), cc.p(0, 0.5), node2)
	girdNodes.addManage = addManage
end

function ClubManage:updateCellTmpl(cellItem, cellIndex)
	local girdNodes = cellItem
	local data = curData[cellIndex]

	if data.cellType == 1 then
		girdNodes.node1:setVisible(false)
		girdNodes.node2:setVisible(true)
	else
		girdNodes.node1:setVisible(true)
		girdNodes.node2:setVisible(false)

		if data.create == 0 then
			girdNodes.editBtn:setVisible(false)
		else
			girdNodes.editBtn:setVisible(true)
		end
		girdNodes.editBtn:setTag(cellIndex)

		girdNodes.Name:setString(data.username)
		local url = data.headimg
		local function funcBack( path )
			-- local rect = girdNodes.stencil:getContentSize()
			girdNodes.Icon:setTexture(path)
			-- girdNodes.Icon:setTextureRect(rect)
		end
		if url ~= "" then
			ClubModel.downloadPhoto(funcBack, url, true)
		else
			girdNodes.Icon:setTexture(ResLib.USER_HEAD)
		end
	end
end

function ClubManage:createLayer(  )
	self:setSwallowTouches()
	UIUtil.setBgScale(ResLib.MAIN_BG, display.center, self)
	_clubManage = self
	imageView = nil
	curData = {}
	curTableView = nil

	self:buildLayer()
end

return ClubManage