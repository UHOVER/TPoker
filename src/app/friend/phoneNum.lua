local ViewBase = require("ui.ViewBase")
local phoneNum = class("phoneNum", ViewBase)


local _phoneNum = nil
local imageView = nil

local phoneNumber = {}

local curData = {}
local curTableView = nil

local function Callback(  )
	_phoneNum:removeTransitAction()
end

function phoneNum:buildLayer(  )
	
	-- topBar
    UIUtil.addTopBar({backFunc = Callback, title = "手机联系人", parent = self})

	imageView = UIUtil.addImageView({touch=true, scale=true, size=cc.size(display.width, display.height-130), pos=cc.p(0,0), parent=self})

	-- 获取手机联系人
	Single:paltform():requestMobilePhoneNumber()

end

function phoneNum:createTableView(  )
	local function tableCellTouched( tableViewSender, tableCell )
		-- local idx = tableCell:getIdx()
		-- print(curData[idx+1])
	end
	local function cellSizeForTable( tableViewSender, cellIndex )
		return 0, 110
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

	local tableView = cc.TableView:create(cc.size(display.width, display.height - 130))
	tableView:setPosition(cc.p(0, 0))
	tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
	imageView:addChild(tableView)
	tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
	tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
	tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
	tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
	tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
	tableView:reloadData()
	-- tableView:setDelegate()
	return tableView
	
end

function phoneNum:buildCellTmpl( cellItem )
	local girdNodes = {}
	girdNodes = cellItem

	local cellBg = UIUtil.addImageView({image=ResLib.TABLEVIEW_CELL_BG, touch=false, scale=true, size=cc.size(display.width, 100),pos=cc.p(0,0), ah=cc.p(0,0), parent=cellItem})
	local width = cellBg:getContentSize().width
	local height = cellBg:getContentSize().height

	local stencil, Icon = UIUtil.createCircle(ResLib.USER_HEAD, cc.p(55,height/2), cellBg, ResLib.CLUB_HEAD_STENCIL_200, 0.35)
	girdNodes.stencil = stencil
	girdNodes.Icon = Icon

	local name = UIUtil.addLabelArial('', 30, cc.p(110, height/2), cc.p(0,0.5), cellBg)
	girdNodes.name = name

	local status = UIUtil.addLabelArial('', 30, cc.p(width-34, height/2), cc.p(1,0.5), cellBg):setColor(cc.c3b(11, 47, 96))
	girdNodes.status = status

	local function inviteBack( sender )
		local tag = sender:getTag()
		self:InvityFun( tag )
	end
	local inviteBtn = UIUtil.addImageBtn({norImg = "club/club_yaoq_1.png", selImg = "club/club_yaoq_2.png", disImg = "club/club_yaoq_2.png", pos = cc.p(width-20, height/2), ah = cc.p(1, 0.5), touch = true, listener = inviteBack, parent = cellBg})
	girdNodes.inviteBtn = inviteBtn

end

function phoneNum:updateCellTmpl( cellItem, cellIndex )
	local girdNodes = cellItem
	local data = {}
	local url = nil
	data = curData[cellIndex+1]
	-- dump(data)

	girdNodes.name:setString(data.name)

	if data.status == 0 then
		girdNodes.inviteBtn:setVisible(false)
		girdNodes.status:setString("已添加")
	elseif data.status == 1 then
		girdNodes.inviteBtn:setVisible(true)
		girdNodes.status:setString("")
		girdNodes.inviteBtn:loadTextures("user/user_tianj_1.png", "user/user_tianj_2.png", "user/user_tianj_2.png")
	elseif data.status == 2 then
		girdNodes.inviteBtn:setVisible(true)
		girdNodes.status:setString("")
		girdNodes.inviteBtn:loadTextures("club/club_yaoq_1.png", "club/club_yaoq_2.png", "club/club_yaoq_2.png")
	end

	url = data["headimg"]
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

	girdNodes.inviteBtn:setTag(data.user_id)
end

function phoneNum:InvityFun( user_id )
	local name = nil
	local phone = nil
	local content = nil
	for k,v in pairs(curData) do
		if v.user_id == user_id then
			if v.status == 1 then
				print("添加好友")
				local test = require("club.ClubTest")
				local layer = test:create()
				_phoneNum:addChild(layer)
				layer:createLayer(curData[k], "friend")
			elseif v.status == 2 then
				name = v.name
				phone = v.number
				content = DZ_SMS
				Single:paltform():sendMessage(name, phone, content)
			end
			break
		end
	end
end

function phoneNum:buildData( phoneData )
	local function response( data )
		dump(data)
		if data.code == 0 then
			local numData = data.data
			for k,v in pairs(numData) do
				local tmpTab = {}
				tmpTab = v
				tmpTab["user_id"] = k
				curData[#curData+1] = tmpTab
				if k == #numData then
					-- dump(curData)
					curTableView = _phoneNum:createTableView()
				end
			end
		end
	end
	local tabData = {}
	tabData["contacts"] = phoneData
	XMLHttp.requestHttp("addContacts", tabData, response, PHP_POST)
end

function phoneNum:createLayer(  )
	_phoneNum = self
	_phoneNum:setSwallowTouches()
	_phoneNum:addTransitAction()

	phoneNumber = {}
	curData = {}

	curTableView = nil

	self:buildLayer()

end

function phoneNum:getPhoneNumber( table )
	-- dump(table)
	DZAction.delateTime(nil, 0, function()
		if #table ~= 0 then
			_phoneNum:buildData( table )
		end
	end)
	
end

return phoneNum