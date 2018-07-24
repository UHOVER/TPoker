local ViewBase = require("ui.ViewBase")
local InviteFriend = class("InviteFriend", ViewBase)
local ClubCtrol = require("club.ClubCtrol")


local _inviteFriend = nil
local imageView = nil
local curData = {}
local curTableView = nil

local selectTab = {}

local function Callback(  )
	_inviteFriend:removeFromParent()
end

local function inviteFunc(  )
	if next(selectTab) == nil then
		ViewCtrol.showTip({content = "请选择将要邀请的好友！"})
		return
	end
	dump(selectTab)
	local function response( data )
		dump(data)
		if data.code == 0 then
			ViewCtrol.showTick({content = "邀请消息已发送！"})
		end
	end
	local tabData = {}
	tabData["user_id"] = selectTab
	tabData["club_id"] = ClubCtrol.getClubInfo().id
	XMLHttp.requestHttp("club_invite_friend", tabData, response, PHP_POST)
end

function InviteFriend:buildLayer(  )
	
	-- topBar
	UIUtil.addTopBar({backFunc = Callback, title = "我的好友", parent = self})

	imageView = UIUtil.addImageView({touch=false, scale=true, size=cc.size(display.width, display.height-130), pos=cc.p(0,0), parent=self})

	local btn_normal, btn_select = "common/com_btn_blue.png",  "common/com_btn_blue_height.png"
	local label = cc.Label:createWithSystemFont("发送邀请", "Marker Felt", 36):setColor(display.COLOR_WHITE)
	local button = UIUtil.controlBtn(btn_normal, btn_select, btn_normal, label, cc.p(display.cx, 50), cc.size(710,80), inviteFunc, self)

	curData = ClubCtrol.getFriendList()
	-- dump(curData)
	if next(curData) ~= nil then
		curTableView = self:createTableView()
		curTableView:reloadData()
	end
end

function InviteFriend:createTableView(  )
	local function tableCellTouched( tableViewSender, tableCell )
		
	end
	local function cellSizeForTable( tableViewSender, cellIndex )
		if curData[cellIndex+1].first == 1 then
			return 0, 174
		else
			return 0, 138
		end
	end
	local function numberOfCellsInTableView( tableViewSender )
		return #curData
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
	
	local tableView = cc.TableView:create(cc.size(display.width, display.height-230))
	tableView:setPosition(cc.p(0,100))
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

function InviteFriend:buildCellTmpl( cellItem )
	local girdNodes = {}
	girdNodes = cellItem

	local cellBg = UIUtil.addImageView({image=ResLib.TABLEVIEW_CELL_BG, touch=false, scale=true, size=cc.size(display.width, 138),pos=cc.p(0,0), ah=cc.p(0,0), parent=cellItem})
	local width = cellBg:getContentSize().width
	local height = cellBg:getContentSize().height

	local textBg = UIUtil.addPosSprite(ResLib.TABLEVIEW_TEXT_LINE, cc.p(width/2, 174), cellBg, cc.p(0.5, 1))
	girdNodes.textBg = textBg

	local text = UIUtil.addLabelArial('', 25, cc.p(20, textBg:getContentSize().height/2), cc.p(0, 0.5), textBg)
	girdNodes.text = text

	local function checkBoxFunc( sender, eventType )
		local tag = sender:getTag()
		if eventType == 0 then
			print("选中")
			self:updateSelectTab( true, tag )
		else
			self:updateSelectTab( false, tag )
		end
	end
	local checkBox = UIUtil.addCheckBox({pos = cc.p(20,height/2), checkboxFunc = checkBoxFunc, parent = cellBg})
	checkBox:setAnchorPoint(cc.p(0, 0.5))
	girdNodes.checkBox = checkBox

	local stencil, icon = UIUtil.createCircle(ResLib.USER_HEAD, cc.p(130,height/2), cellBg, ResLib.CLUB_HEAD_STENCIL_200, 0.5)
	girdNodes.icon = icon
	girdNodes.stencil = stencil

	local name = UIUtil.addLabelArial('name', 30, cc.p(200, height/2), cc.p(0,0.5), cellBg)
	girdNodes.name = name
	
end

function InviteFriend:updateCellTmpl( cellItem, cellIndex )
	local girdNodes = cellItem
	local data = curData[cellIndex+1]

	if data.first == 1 then
		girdNodes.textBg:setVisible(true)
		girdNodes.text:setString(data.key)
	else
		girdNodes.textBg:setVisible(false)
	end

	girdNodes.name:setString(data.user_name)

	if data.check == 0 then
		girdNodes.checkBox:setSelected(false)
	else
		girdNodes.checkBox:setSelected(true)
	end
	girdNodes.checkBox:setTag(data.id)

	local url = data.headimg
	local function funcBack( path )
		local rect = girdNodes.stencil:getContentSize()
		girdNodes.icon:setTexture(path)
		girdNodes.icon:setTextureRect(rect)
	end
	if url ~= "" then
		ClubModel.downloadPhoto(funcBack, url, true)
	end

end

function InviteFriend:updateSelectTab( isSelect, id )
	if isSelect then
		for k,v in pairs(curData) do
			if tonumber(v.id) == tonumber(id) then
				curData[k].check = 1
				table.insert(selectTab, id)
				curTableView:updateCellAtIndex(k-1)
				break
			end
		end
	else
		for k,v in pairs(selectTab) do
			if tonumber(v) == tonumber(id) then
				for key,val in pairs(curData) do
					if tonumber(val.id) == tonumber(id) then
						curData[key].check = 0
						table.remove(selectTab, k)
						curTableView:updateCellAtIndex(key-1)
						break
					end
				end
			end
		end
	end
end

function InviteFriend:createLayer(  )
	_inviteFriend = self
	_inviteFriend:setSwallowTouches()

	UIUtil.setBgScale(ResLib.MAIN_BG, display.center, self)

	imageView = nil
	curData = {}
	selectTab = {}
	curTableView = nil

	self:buildLayer()
end

return InviteFriend