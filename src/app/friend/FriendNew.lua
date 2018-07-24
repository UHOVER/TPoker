local ViewBase = require("ui.ViewBase")
local FriendNew = class("FriendNew", ViewBase)

local MineCtrol = require("mine.MineCtrol")

local FriendList = require("friend.FriendList")

local _friendNew = nil
local tab = {}
	tab['font'] = 'Arial'
	tab['size'] = 30

local imageView = nil
local curData = {}
local curTableView = nil
local agree = nil

local deleteButton = nil
local selectTab = {}

local function Callback(  )
	_friendNew:removeTransitAction()

	Notice.deleteMessage( 1 )
	
	if agree then
		MineCtrol.dataStatFriendList(function (  )
			FriendList:addTableView()
		end)
	end
end

local function updateDelbtn(  )
	if #selectTab == 0 then
		deleteButton:setEnabled(false)
		deleteButton:setBright(false)
	else
		deleteButton:setEnabled(true)
		deleteButton:setBright(true)
	end
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
			table.insert(selectTab, v.id)
			curData[k].check = 1
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
			if v.id == id then
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
					if val.id == id then
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

local function deleteMessage(  )
	local function response( data )
		dump(data)
		if data.code == 0 then
			for k,v in pairs(selectTab) do
				for key,val in pairs(curData) do
					if v == val.id then
						table.remove(curData, key)
					end
				end
				if k == #selectTab then
					selectTab = {}
					updateDelbtn()
					curTableView:reloadData()
				end
			end
		end
	end
	local tabData = {}
	tabData["message_id"] = selectTab
	XMLHttp.requestHttp("delMessage", tabData, response, PHP_POST)
end

function FriendNew:buildLayer(  )
	
	-- topBar
    UIUtil.addTopBar({backFunc = Callback, title = "好友请求", parent = self})

	imageView = UIUtil.addImageView({touch=true, scale=true, size=cc.size(display.width, display.height-260), pos=cc.p(0,0), parent=self})
	local imageBg = UIUtil.addImageView({image = ResLib.TABLEVIEW_CELL_BG, touch=false, scale=true, size=cc.size(display.width, 130),pos=cc.p(0, display.height-260), ah=cc.p(0,0), parent=self})

	local function checkBoxFunc( sender, eventType )
		local tag = sender:getTag()
		if eventType == 0 then
			selectAll(true)
		else
			selectAll(false)
		end
	end
	local allCheck = UIUtil.addCheckBox({pos = cc.p(20,130/2), checkboxFunc = checkBoxFunc, parent = imageBg})
	allCheck:setAnchorPoint(cc.p(0,0.5))
	UIUtil.addLabelArial("全部选择", 30, cc.p(90, 130/2), cc.p(0,0.5), imageBg)

	local function delFuncback( sender )
		print("删除")
		dump(selectTab)
		local layer = nil
		local function deleteFunc(  )
			deleteMessage()
			allCheck:setSelected(false)
			layer:removeFromParent()
		end
		layer = UIUtil.deleteList({content = "你确定要删除选中的"..#selectTab.."位好友消息吗？", sureFunc = deleteFunc, parent = self})
	end
	deleteButton = UIUtil.addImageBtn({text = "删除", norImg = "common/com_btn_delete_img.png", selImg = "common/com_btn_delete_img.png", disImg = "common/com_btn_delete_img.png", scale9 = true, size = cc.size(102, 50), pos = cc.p(display.width-20, 130/2), ah = cc.p(1, 0.5), swalTouch = true, touch = true,  listener = delFuncback, parent = imageBg})
	updateDelbtn()
	if #curData ~= 0 then
		curTableView = self:createTableView()
		curTableView:reloadData()
	end
end

function FriendNew:createTableView(  )

	local function tableCellTouched( tableViewSender, tableCell )
		
	end
	local function cellSizeForTable( tableViewSender, cellIndex )
		return 0, 130
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

	local tableView = cc.TableView:create(cc.size(display.width, display.height - 260))
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

function FriendNew:buildCellTmpl(cellItem)
	local girdNodes = {}
	girdNodes = cellItem

	local cellBg = UIUtil.addImageView({image=ResLib.TABLEVIEW_CELL_BG_LINE_2, touch=false, scale=true, size=cc.size(display.width, 130),pos=cc.p(0,0), ah=cc.p(0,0), parent=cellItem})
	girdNodes.cellBg = cellBg
	local width = cellBg:getContentSize().width
	local height = cellBg:getContentSize().height

	local stencil, Icon = UIUtil.createCircle(ResLib.USER_HEAD, cc.p(130,height/2), cellBg, ResLib.CLUB_HEAD_STENCIL_200)
	girdNodes.stencil = stencil
	girdNodes.Icon = Icon

	local msgTitle = UIUtil.addLabelArial('消息标题', 36, cc.p(200, height*3/4-20), cc.p(0,0), cellBg)
	girdNodes.msgTitle = msgTitle

	local color = cc.c3b(165, 157, 157)
	local MsgDes = UIUtil.addLabelArial('消息类容', 28, cc.p(200, height/4), cc.p(0,0), cellBg)
	MsgDes:setColor(color)
	girdNodes.MsgDes = MsgDes

	local Msginfo = UIUtil.addLabelArial('消息状态', 26, cc.p(width-34, height/2), cc.p(1,0.5), cellBg):setColor(ResLib.COLOR_GREY1)
	girdNodes.Msginfo = Msginfo

	local function checkBoxFunc( sender, eventType )
		local tag = sender:getTag()
		if eventType == 0 then
			print("选中")
			selectOne(true, tag)
		else
			selectOne(false, tag)
		end
	end
	local checkBox = UIUtil.addCheckBox({pos = cc.p(20,height/2), checkboxFunc = checkBoxFunc, parent = cellBg})
	checkBox:setAnchorPoint(cc.p(0,0.5))
	girdNodes.checkBox = checkBox

	local function callfunc( sender )
		local tag = sender:getTag()
		print("aaa : " .. tag)
		self:acceptFriend( tag )
	end
	local agreeBtn = UIUtil.addImageBtn({norImg = ResLib.BTN_CELL_AGREE, pos = cc.p(width-142, height/2), ah = cc.p(1, 0.5), touch = true, listener = callfunc, parent = cellBg})
	girdNodes.agreeBtn = agreeBtn

	local function nocallfunc( sender )
		local tag = sender:getTag()
		print("aaa : " .. tag)
		self:refuseFriend( tag )
	end
	local refuseBtn = UIUtil.addImageBtn({norImg = ResLib.BTN_CELL_REFUSE, pos = cc.p(width-20, height/2), ah = cc.p(1, 0.5), touch = true, listener = nocallfunc, parent = cellBg})
	girdNodes.refuseBtn = refuseBtn

end

function FriendNew:updateCellTmpl(cellItem, cellIndex)
	local girdNodes = cellItem
	local data = curData[cellIndex+1]

	if data.check == 0 then
		girdNodes.checkBox:setSelected(false)
	else
		girdNodes.checkBox:setSelected(true)
	end
	girdNodes.checkBox:setTag(data.id)

	if data.img ~= "" then
		local url = data.img
		local function funcBack( path )
			local rect = girdNodes.stencil:getContentSize()
			girdNodes.Icon:setTexture(path)
			girdNodes.Icon:setTextureRect(rect)
		end
		ClubModel.downloadPhoto(funcBack, url, true)
	end

	local name = StringUtils.getShortStr( data.username , LEN_NAME)
	girdNodes.msgTitle:setString(name)

	local content = StringUtils.getShortStr( data.contents , 40)
	girdNodes.MsgDes:setString(content)

	girdNodes.agreeBtn:setTag(data.sid)
	girdNodes.refuseBtn:setTag(data.sid)

	local flag = tonumber(data.flag)
	if flag == 1 then
		girdNodes.agreeBtn:setVisible(false)
		girdNodes.refuseBtn:setVisible(false)
		girdNodes.Msginfo:setString('已同意')

	elseif flag == 2 then
		girdNodes.agreeBtn:setVisible(false)
		girdNodes.refuseBtn:setVisible(false)
		girdNodes.Msginfo:setString('已拒绝')

	else
		girdNodes.agreeBtn:setVisible(true)
		girdNodes.refuseBtn:setVisible(true)
		girdNodes.Msginfo:setString('')
	end

end

-- 接受好友请求
function FriendNew:acceptFriend( tag )
	local function response( data )
		dump(data)
		if data.code == 0 then
			for k,v in pairs(curData) do
				if tonumber(v.sid) == tonumber(tag) then
					curData[k].flag = 1
					curTableView:reloadData()
					dump(curData[k])

					agree = true
					break
				end
			end
		end
	end
	local tabData = {}
	tabData['sid'] = tag
	tabData['flag'] = 1
	XMLHttp.requestHttp(PHP_FRIEND_AGREE, tabData, response, PHP_POST)
end

-- 拒绝好友请求
function FriendNew:refuseFriend( tag )
	local function response( data )
		dump(data)
		if data.code == 0 then
			for k,v in pairs(curData) do
				if tonumber(v.sid) == tonumber(tag) then
					curData[k].flag = 2
					curTableView:reloadData()
					break
				end
			end
		end
	end
	local tabData = {}
	tabData['sid'] = tag
	tabData['flag'] = 2
	XMLHttp.requestHttp(PHP_FRIEND_AGREE, tabData, response, PHP_POST)
end

function FriendNew:createLayer( data )
	
	_friendNew = self
	_friendNew:setSwallowTouches()
	_friendNew:addTransitAction()

	UIUtil.setBgScale(ResLib.MAIN_BG, display.center, self)
	self:init()
	dump(data)
	curData = data
	self:buildLayer()
	
end

function FriendNew:init(  )
	curData = {}
	agree = nil
	deleteButton = nil
	selectTab = {}

end

return FriendNew