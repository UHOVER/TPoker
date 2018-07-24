local ViewBase = require('ui.ViewBase')
local MemberList = class('MemberList', ViewBase)

local ClubCtrol = require("club.ClubCtrol")

local _memberList = nil
local tab = {font='Arial',size=30}

local curData = {}
local imageView = nil
local curTableView = nil

local function Callback(  )
	local clubInfo = ClubCtrol.getClubInfo()
	ClubCtrol.dataStatClubInfo( clubInfo.id, function ()
		_memberList:removeFromParent()
		local myEvent = cc.EventCustom:new("C_Event_update_ClubInfo")
		local customEventDispatch = cc.Director:getInstance():getEventDispatcher()
		customEventDispatch:dispatchEvent(myEvent)
	end )
end

local function delCallback(  )
	local memberDel = require("club.MemberDel")
	local layer = memberDel:create()
	_memberList:addChild(layer)
	layer:createLayer()
end

function MemberList:buildLayer(  )
	local menuStr = nil
	if ClubCtrol.getClubIsCreate() then
		menuStr = '删除'
	else
		menuStr = nil
		if ClubCtrol.getPermit().PER_DELM then
			menuStr = '删除'
		end
	end
	UIUtil.addTopBar({backFunc = Callback, title = "成员列表", menuFont = menuStr, menuFunc = delCallback, parent = self})

	imageView = UIUtil.addImageView({image = ResLib.TABLEVIEW_BG, touch=false, scale=true, size=cc.size(display.width, display.height-130), pos=cc.p(0,0), parent=self})
	
	local tmpTab = ClubCtrol.getMemberList()
	for i=1,#tmpTab do
		local tmp = tmpTab[i]
		tmp['check'] = 0
		curData[#curData+1] = tmp
	end
	-- dump(curData)

	curTableView = self:createTableView()
	curTableView:reloadData()
end

function MemberList:updateMember(  )
	curData = {}
	ClubCtrol.dataStatMember( function (  )
		local tmpTab = ClubCtrol.getMemberList()
		for i=1,#tmpTab do
			local tmp = tmpTab[i]
			tmp['check'] = 0
			curData[#curData+1] = tmp
		end
		-- dump(curData)
		if curTableView then
			curTableView:reloadData()
		end
	end )
end

function MemberList:createTableView(  )
	local function tableCellTouched( tableViewSender, tableCell )
		local idx = tableCell:getIdx() + 1
		local data = curData[idx]
		if data.state == 2 or data.state == 3 then
			self:intoUsernfo(data)
		end
	end

	local function cellSizeForTable( tableViewSender, cellIndex )
		local data = curData[cellIndex+1]
		if data.frist == 1 then
			return 0, 140
		else
			return 0, 100
		end
	end

	local function numberOfCellsInTableView( tableViewSender )
		return #curData
	end

	local function tableCellAtIndex( tableViewSender, cellIndex )
		local index = cellIndex
		local cellItem = tableViewSender:dequeueCell()
		if cellItem == nil then
			cellItem = cc.TableViewCell:new()
			self:buildCellTmpl(cellItem)
		end
		self:updateCellTmpl(cellItem, index )

		return cellItem
	end

	local tableView = cc.TableView:create(cc.size(display.width, imageView:getContentSize().height))
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

-- 俱乐部成员 --
function MemberList:buildCellTmpl( cellItem )
	local girdNodes = {}
	girdNodes = cellItem

	local cellBg = UIUtil.addImageView({image = ResLib.TABLEVIEW_CELL_BG_LINE_2, touch=false, scale=true, size=cc.size(display.width, 100),pos=cc.p(0,0), ah=cc.p(0,0), parent=cellItem})
	girdNodes.cellBg = cellBg
	local width = cellBg:getContentSize().width
	local height = cellBg:getContentSize().height

	local siteBg = UIUtil.addImageView({image = ResLib.TABLEVIEW_TEXT_LINE, touch=false, scale=true, size=cc.size(display.width, 40),pos=cc.p(width/2, 100), ah=cc.p(0.5,0), parent=cellItem})
	girdNodes.siteBg = siteBg

	local site = UIUtil.addLabelArial('', 26, cc.p(20, siteBg:getContentSize().height/2), cc.p(0, 0.5), siteBg):setColor(ResLib.COLOR_GREY1)
	girdNodes.site = site

	local count = UIUtil.addLabelArial('', 26, cc.p(display.width-20, siteBg:getContentSize().height/2), cc.p(1, 0.5), siteBg):setColor(ResLib.COLOR_GREY1)
	girdNodes.count = count

	-- 头像
	local stencil, Icon = UIUtil.createCircle(ResLib.USER_HEAD, cc.p(60,height/2), cellBg, ResLib.CLUB_HEAD_STENCIL_200, 0.4)
	girdNodes.stencil = stencil
	girdNodes.Icon = Icon

	local iconMark = UIUtil.addPosSprite("common/com_icon_manager.png", cc.p(60+20,height/2-25), cellBg, cc.p(0.5, 0.5))
	girdNodes.iconMark = iconMark

	-- 名称
	local Name = UIUtil.addLabelArial('名称', 30, cc.p(140, height/2), cc.p(0, 0.5), cellBg)
	girdNodes.Name = Name

	local team_icon = UIUtil.addPosSprite("bg/zd_flag.png", cc.p(display.width-20, height/2), cellBg, cc.p(1, 0.5))
	local team_name = UIUtil.addLabelArial('name', 26, cc.p(team_icon:getPositionX()-team_icon:getContentSize().width-10, height/2), cc.p(1,0.5), cellBg):setColor(cc.c3b(9, 183, 66))
	girdNodes.team_icon = team_icon
	girdNodes.team_name = team_name

end

function MemberList:updateCellTmpl(cellItem, cellIndex )
	local girdNodes = cellItem

	local data = curData[cellIndex+1]
	if data.frist == 1 then
		girdNodes.siteBg:setVisible(true)
		if data.state == 1 then
			girdNodes.site:setString("创始人")
		elseif data.state == 2 then
			girdNodes.site:setString("管理员")
		else
			girdNodes.site:setString("成员")
		end
		girdNodes.count:setString(data.count)
	else
		girdNodes.siteBg:setVisible(false)
	end
	if data.state == 1 then
		girdNodes.iconMark:setVisible(true)
		girdNodes.iconMark:setTexture('common/com_icon_founder.png')
	elseif data.state == 2 then
		girdNodes.iconMark:setVisible(true)
		girdNodes.iconMark:setTexture('common/com_icon_manager.png')
	else
		girdNodes.iconMark:setVisible(false)
	end

	girdNodes.Name:setString(data.username)
	local url = data.headimg or ''
	local function funcBack( path )
		local rect = girdNodes.stencil:getContentSize()
		girdNodes.Icon:setTexture(path)
		girdNodes.Icon:setTextureRect(rect)
	end
	if url ~= "" then
		ClubModel.downloadPhoto(funcBack, url, true)
	else
		girdNodes.Icon:setTexture(ResLib.USER_HEAD)
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

function MemberList:intoUsernfo( tab )
	print(">>>>>>>>>>---------" .. tab.id)
	local personInfo = require("friend.PersonInfo")
	local layer = personInfo:create()
	self:addChild(layer)
	layer:createLayer( tab )
end

function MemberList:createLayer(  )
	_memberList = self
	_memberList:setSwallowTouches()
	_memberList:addTransitAction()
	
	selectTab = {}

	curData = {}
	imageView = nil
	curTableView = nil

	UIUtil.setBgScale(ResLib.MAIN_BG, display.center, self)
	
	self:buildLayer()
end

return MemberList