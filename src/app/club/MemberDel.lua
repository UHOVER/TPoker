local ViewBase = require('ui.ViewBase')
local MemberDel = class('MemberDel', ViewBase)

local ClubCtrol = require("club.ClubCtrol")

local _memberDel = nil
local tab = {font='Arial',size=30}

local curData = {}
local clubData = {}
local btnText = nil
local target = nil
local imageView = nil
local curTableView = nil

-- delete
local selectTab = {}

local function Callback(  )
	local member = require('club.MemberList')
	member:updateMember()
	_memberDel:removeFromParent()
end

local function updateDelbtn(  )

end

-- 全选/取消全选
local function selectAll( isAll )
	selectTab = {}
	if isAll then
		if #curData == 0 then
			selectTab = {}
			updateDelbtn()
			return 0
		end
		for k,v in pairs(curData) do
			-- state 1 创始人、2管理员、3普通成员、4全部选择
			if ClubCtrol.getClubIsCreate() then
				-- 俱头
				if v.state == 2 or v.state == 3 then
					table.insert(selectTab, v.id)
					curData[k].check = 1
				elseif v.state == 4 then
					curData[k].check = 1
				end
			else
				-- 管理员
				if ClubCtrol.getPermit().PER_DELM then
					if v.state == 3 then
						table.insert(selectTab, v.id)
						curData[k].check = 1
					elseif v.state == 4 then
						curData[k].check = 1
					end
				end
			end
			if k == #curData then
				updateDelbtn()
				curTableView:reloadData()
			end
		end
	else
		for k,v in pairs(curData) do
			curData[k].check = 0
			if k == #curData then
				selectTab = {}
				updateDelbtn()
				curTableView:reloadData()
			end
		end
	end
end

-- 单选/取消单选
local function selectOne( isSelect, id )
	if isSelect then
		for k,v in pairs(curData) do
			if tonumber(v.id) == tonumber(id) then
				curData[k].check = 1
				table.insert(selectTab, id)
				updateDelbtn()
				-- curTableView:reloadData()
				curTableView:updateCellAtIndex(k-1)
				break
			end
		end
	else
		for k,v in pairs(selectTab) do
			if v == id then
				for key,val in pairs(curData) do
					if tonumber(val.id) == tonumber(id) then
						curData[key].check = 0
						table.remove(selectTab, k)
						updateDelbtn()
						-- curTableView:reloadData()
						curTableView:updateCellAtIndex(key-1)
						break
					end
				end
			end
		end
	end
end

local function deleteClubMemmber( funback )
	local clubData = ClubCtrol.getClubInfo()
	
	local function response( data )
		-- dump(data)
		if data.code == 0 then
			-- for k,v in pairs(selectTab) do
			-- 	for key,val in pairs(curData) do
			-- 		if val.state == 3 then
			-- 			if tonumber(v) == tonumber(val.id) then
			-- 				table.remove(curData, key)
			-- 			end
			-- 		end
			-- 	end
			-- 	if k == #selectTab then
			-- 		selectTab = {}
			-- 		curTableView:reloadData()
			-- 	end
			-- end
			ViewCtrol.showTick({content = "成功删除成员！"})
			Callback()
		end
	end
	local tabData = {}
	tabData['user_id'] = selectTab
	tabData["club_id"] = clubData.id
	XMLHttp.requestHttp(PHP_MEMBER_DELETE, tabData, response, PHP_POST)
end

local function delCallback( tag, sender )
	if #selectTab == 0 then
		return
	end
	local layer = nil
	local function deleteFunc(  )
		deleteClubMemmber()
		layer:removeFromParent()
	end
	layer = UIUtil.deleteList({content = "你确定要删除选中的"..#selectTab.."位成员吗？", sureFunc = deleteFunc, parent = _memberDel})
end

function MemberDel:buildLayer(  )

	UIUtil.addTopBar({backFunc = Callback, title = "删除成员", menuFont = "确认", menuFunc = delCallback, parent = self})

	imageView = UIUtil.addImageView({image = ResLib.TABLEVIEW_BG, touch=false, scale=true, size=cc.size(display.width, display.height-130), pos=cc.p(0,0), parent=self})
	
	local tab = {frist = 0, state = 4, check = 0}
	curData[1] = tab
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

function MemberDel:createTableView(  )
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

-- 删除 俱乐部成员 --
function MemberDel:buildCellTmpl( cellItem )
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

	local function checkBoxFunc( sender, eventType )
		local tag = sender:getTag()
		if tag == (-10) then
			if eventType == 0 then
				selectAll(true)
			else
				selectAll(false)
			end
		else
			if eventType == 0 then
				print("选中")
				selectOne(true, tag)
			else
				selectOne(false, tag)
			end
		end
	end
	local checkBox = UIUtil.addCheckBox({pos = cc.p(20,height/2), checkboxFunc = checkBoxFunc, parent = cellBg})
	checkBox:setAnchorPoint(cc.p(0,0.5))
	girdNodes.checkBox = checkBox

	local noSp = UIUtil.addPosSprite('common/s_xzjBtn.png', cc.p(20,height/2), cellBg, cc.p(0, 0.5))
	girdNodes.noSp = noSp

	-- 全部选择
	local checkStr = UIUtil.addLabelArial('全部选择', 30, cc.p(70, height/2), cc.p(0, 0.5), cellBg)
	girdNodes.checkStr = checkStr

	-- 头像
	local stencil, Icon = UIUtil.createCircle(ResLib.USER_HEAD, cc.p(110,height/2), cellBg, ResLib.CLUB_HEAD_STENCIL_200, 0.4)
	girdNodes.stencil = stencil
	girdNodes.Icon = Icon

	local iconMark = UIUtil.addPosSprite("common/com_icon_manager.png", cc.p(110+20,height/2-25), cellBg, cc.p(0.5, 0.5))
	girdNodes.iconMark = iconMark

	-- 名称
	local Name = UIUtil.addLabelArial('名称', 30, cc.p(170, height/2), cc.p(0, 0.5), cellBg)
	girdNodes.Name = Name

	local team_icon = UIUtil.addPosSprite("bg/zd_flag.png", cc.p(display.width-20, height/2), cellBg, cc.p(1, 0.5))
	local team_name = UIUtil.addLabelArial('name', 26, cc.p(team_icon:getPositionX()-team_icon:getContentSize().width-10, height/2), cc.p(1,0.5), cellBg):setColor(cc.c3b(9, 183, 66))
	girdNodes.team_icon = team_icon
	girdNodes.team_name = team_name
end

function MemberDel:updateCellTmpl(cellItem, cellIndex )
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
	if data.state == 4 then
		girdNodes.checkStr:setString('选择全部')
		girdNodes.Icon:setVisible(false)
		girdNodes.checkBox:setTag(-10)
		girdNodes.checkBox:setTouchEnabled(true)
		girdNodes.noSp:setVisible(false)
	elseif data.state == 1 then
		girdNodes.checkStr:setString('')
		girdNodes.Icon:setVisible(true)
		girdNodes.checkBox:setTag(data.id)
		girdNodes.checkBox:setTouchEnabled(false)
		girdNodes.noSp:setVisible(true)
	elseif data.state == 2 then
		girdNodes.checkStr:setString('')
		girdNodes.Icon:setVisible(true)
		girdNodes.checkBox:setTag(data.id)
		if ClubCtrol.getClubIsCreate() then
			girdNodes.checkBox:setTouchEnabled(true)
			girdNodes.noSp:setVisible(false)
		else
			girdNodes.checkBox:setTouchEnabled(false)
			girdNodes.noSp:setVisible(true)
		end
	else
		girdNodes.checkStr:setString('')
		girdNodes.Icon:setVisible(true)
		girdNodes.checkBox:setTag(data.id)
		girdNodes.checkBox:setTouchEnabled(true)
		girdNodes.noSp:setVisible(false)
	end
	if data.check == 0 then
		girdNodes.checkBox:setSelected(false)
	else
		girdNodes.checkBox:setSelected(true)
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
		girdNodes.Icon:setTexture(path)
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

function MemberDel:intoUsernfo( tab )
	print(">>>>>>>>>>---------" .. tab.id)
	local personInfo = require("friend.PersonInfo")
	local layer = personInfo:create()
	self:addChild(layer)
	layer:createLayer( tab )
end

function MemberDel:createLayer(  )
	_memberDel = self
	_memberDel:setSwallowTouches()
	
	curData = {}
	selectTab = {}

	curData = {}
	imageView = nil

	UIUtil.setBgScale(ResLib.MAIN_BG, display.center, self)
	
	self:buildLayer()
end

return MemberDel