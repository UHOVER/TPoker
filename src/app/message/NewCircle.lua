--[[
**************************************************************************
* NAME OF THE BUG :  YDWX_DZ_ZHANGMENG_BUG _20160608 _019
* DESCRIPTION OF THE BUG :【UE Integrity】Function not implemented 
* MODIFIED BY : 王礼宁
* DATE :2016-7-16
*************************************************************************/
]]



local ViewBase = require("ui.ViewBase")
local NewCircle = class("NewCircle", ViewBase)
local MineCtrol = require("mine.MineCtrol")


local _newCircle = nil

local tab = {font = "Arial", size = 30}
local imageView = nil
local curData = {}
local curTableView = nil

local selectTab = {}
local circle_name = nil

local CIRCLE_TARGET = nil

local function Callback(  )
	_newCircle:removeTransitAction()
end

local function newCircleFunc(  )
	if CIRCLE_TARGET == "new" then
		_newCircle:createCircle()
	else
		_newCircle:inviteCircle()
	end
end

local function letterFunc(  )
	
end

function NewCircle:buildLayer(  )

	local title = nil
	local labelStr = nil
	if CIRCLE_TARGET == "new" then
		title = "新建圈子"
		labelStr = "创建圈子"
	else
		title = "邀请好友加入圈子"
		labelStr = "确认"
	end
	
	-- topBar
    UIUtil.addTopBar({backFunc = Callback, title = title, parent = self})

   	imageView = UIUtil.addImageView({touch=false, scale=true, size=cc.size(display.width, display.height-130), pos=cc.p(0,0), parent=self})


	local label = cc.Label:createWithSystemFont(labelStr, "Marker Felt", 30):setColor(ResLib.COLOR_BLUE)
	local button = UIUtil.controlBtn(ResLib.BTN_BLUE_BORDER, ResLib.BTN_BLUE_BORDER, ResLib.BTN_BLUE_BORDER, label, cc.p(display.cx, 50), cc.size(700,80), newCircleFunc, self)

	self:buildData()

end

function NewCircle:buildData(  )
	local function response( data )
		dump(data.data)
		if data.code == 0 then
			MineCtrol.buildFriendlist(data.data)
			self:addTableView()
		end
	end
	local tabData = {}
	XMLHttp.requestHttp(PHP_FRIEND_LIST, tabData, response, PHP_POST)
end

function NewCircle:addTableView(  )
	local friendData = MineCtrol.getFriendList()
	
	if CIRCLE_TARGET == "new" then
		for k,v in pairs(friendData) do
			local tmpTab = {}
			tmpTab = v
			tmpTab["check"] = 0
			table.insert(curData, tmpTab)
		end
	else
		local circlePlayer = MineCtrol.getCircleInfo()["playerInfo"]
		-- dump(circlePlayer)
		for k,v in pairs(friendData) do
			local tmpTab = {}
			tmpTab = v
			for key,val in pairs(circlePlayer) do
				if tonumber(v.id) == val.player_id then
					tmpTab["check"] = 1
					tmpTab["touch"] = 0
					table.insert(curData, tmpTab)
					break
				else
					if key == #circlePlayer then
						tmpTab["check"] = 0
						tmpTab["touch"] = 1
						table.insert(curData, tmpTab)
					end
				end
			end
		end
	end
	-- dump(friendData)
	dump(curData)
	if next(curData) ~= nil then
		curTableView = self:createTableView()
		curTableView:reloadData()
		self:buildLetterBtn()
	else
		UIUtil.addPosSprite("club/card_icon_face.png", cc.p(display.cx, display.height*0.65), imageView, cc.p(0.5, 0.5))
	end
end

function NewCircle:buildLetterBtn(  )
	local letterTab = MineCtrol.getLetter()

	local count = #letterTab
	local letterBtn = {}

	local letter_sp = UIUtil.addImageView({image="common/com_opacity0.png", touch=false, scale=true, size=cc.size(30, count*40), pos=cc.p(display.width-10, display.cy), ah=cc.p(1,0.5), parent=imageView})
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

function NewCircle:createTableView(  )
	local function tableCellTouched( tableViewSender, tableCell )
		local idx = tableCell:getIdx()+1
		local data = curData[idx]
		-- dump(data)
		local personInfo = require("friend.PersonInfo")
		local layer = personInfo:create()
		_newCircle:addChild(layer)
		layer:createLayer( data )
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

function NewCircle:buildCellTmpl( cellItem, cellIndex )
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
			self:updateCheckBox(true, tag)
			self:updateSelectedTab(true, tag)
		else
			self:updateCheckBox(false, tag)
			self:updateSelectedTab(false, tag)
		end
		curTableView:updateCellAtIndex(cellIndex)
	end
	local checkBox = UIUtil.addCheckBox({pos = cc.p(20,height/2), checkboxFunc = checkBoxFunc, parent = cellBg})
	checkBox:setAnchorPoint(cc.p(0,0.5))
	girdNodes.checkBox = checkBox

	local stencil, icon = UIUtil.createCircle(ResLib.USER_HEAD, cc.p(130,height/2), cellBg, ResLib.CLUB_HEAD_STENCIL_200, 0.5)
	girdNodes.icon = icon
	girdNodes.stencil = stencil

	local name = UIUtil.addLabelArial('name', 30, cc.p(200, height/2), cc.p(0,0.5), cellBg)
	girdNodes.name = name
	
end

function NewCircle:updateCellTmpl( cellItem, cellIndex )
	local girdNodes = cellItem
	local data = curData[cellIndex+1]

	girdNodes.name:setString(data.user_name)

	if data.first == 1 then
		girdNodes.textBg:setVisible(true)
		girdNodes.text:setString(data.key)
	else
		girdNodes.textBg:setVisible(false)
	end

	if CIRCLE_TARGET == "new" then
		if data.check == 1 then
			girdNodes.checkBox:setSelected(true)
		else
			girdNodes.checkBox:setSelected(false)
		end
	else
		if data.touch == 1 then
			if data.check == 1 then
				girdNodes.checkBox:setSelected(true)
			else
				girdNodes.checkBox:setSelected(false)
			end
			girdNodes.checkBox:setTouchEnabled(true)
		elseif data.touch == 0 then
			girdNodes.checkBox:setSelected(true)
			girdNodes.checkBox:setTouchEnabled(false)
		end
	end

	girdNodes.checkBox:setTag(data.id)

	if data.headimg ~= "" then
		local url = data.headimg
		local function funcBack( path )
			local rect = girdNodes.stencil:getContentSize()
			girdNodes.icon:setTexture(path)
			girdNodes.icon:setTextureRect(rect)
		end
		ClubModel.downloadPhoto(funcBack, url, true)
	end

end

function NewCircle:updateCheckBox( selected, id )
	if selected then
		for k,v in pairs(curData) do
			if tonumber(v.id) == id then
				v.check = 1
			end
		end
	else
		for k,v in pairs(curData) do
			if tonumber(v.id) == id then
				v.check = 0
			end
		end
	end
	-- dump(curData)
end

function NewCircle:updateSelectedTab( selected, id )
	if selected then
		local tmpTab = {}
		table.insert(selectTab, id)
	else
		for k,v in pairs(selectTab) do
			if v == id then
				table.remove(selectTab, k)
			end
		end
	end
	dump(selectTab)
end


--[[
**************************************************************************
* NAME OF THE BUG : YDWX_DZ_WANGXIAOXUE_BUG _20160722_011/YDWX_DZ_ZHANGXINMIN_BUG _201600719 _002 Unable to create
* DESCRIPTION OF THE BUG : You can not create circle
* MODIFIED BY : 王礼宁
* DATE :2016-7-25/8-17
*************************************************************************/
]]


function NewCircle:createCircle(  )
	if #selectTab == 0 then
		ViewCtrol.showTip({content = "请先选择好友！"})
		return
	end
	
	local function response( data )
		dump(data)
		if data.code == 0 then

			local MessageCtorl = require("message.MessageCtorl")
			MessageCtorl.setChatData(data.data['circle_id'])
			MessageCtorl.setChatType(MessageCtorl.CHAT_CIRCLE)

			local Message = require('message.MessageScene')
			Message.startScene()

		end
	end
	local tabData = {}
	tabData["friends"] = selectTab
	XMLHttp.requestHttp("create_circle", tabData, response, PHP_POST)
end

--[[
**************************************************************************
* NAME OF THE BUG : YDWX_DZ_WANGXIAOXUE_BUG _20160722_011
* DESCRIPTION OF THE BUG : You can not create circle
* MODIFIED BY : 王礼宁
* DATE :2016-7-25
*************************************************************************/
]]


function NewCircle:inviteCircle(  )
	if #selectTab == 0 then
		ViewCtrol.showTip({content = "请先选择好友！"})
		return
	end

	local selectData = {}

	for k,v in pairs(curData) do
		local tmpTab = {}
		for key,val in pairs(selectTab) do
			if tonumber(v.id) == val then
				tmpTab["player_avatar"] = v.headimg
				tmpTab["player_id"] 	= tonumber(v.id)
				tmpTab["player_name"] 	= v.user_name
				tmpTab["player_ryid"] 	= v.rongyun_id
				table.insert(selectData, tmpTab)
				break
			end
		end
		if #selectData == #selectTab then
			break
		end
	end

	-- print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
	-- dump(selectData)
	
	local function response( data )
		dump(data)
		if data.code == 0 then
			MineCtrol.editCircleInfo({player = selectData})
			_newCircle:removeTransitAction()
			local CircleInfo = require("mine.CircleInfo")
			CircleInfo.updateCircleInfo( nil )
		end
	end
	local tabData = {}
	tabData["circle_id"] = MineCtrol.getCircleId()
	tabData["friend_ids"] = selectTab
	XMLHttp.requestHttp("inviteUserJoinCircle", tabData, response, PHP_POST)
	
end

function NewCircle:createLayer( target )
	_newCircle = self
	_newCircle:setSwallowTouches()
	_newCircle:addTransitAction()

	UIUtil.setBgScale(ResLib.MAIN_BG, display.center, self)
	self:init()

	CIRCLE_TARGET = target

	self:buildLayer()
end

function NewCircle:init(  )
	curData = {}
	curTableView = nil

	selectTab = {}
	circle_name = ''
	CIRCLE_TARGET = nil
end

return NewCircle

--[[
**************************************************************************
* NAME OF THE BUG :  YDWX_DZ_ZHANGMENG_BUG _20160608 _019
* DESCRIPTION OF THE BUG :【UE Integrity】Function not implemented 
* MODIFIED BY : 王礼宁
* DATE :2016-7-16
*************************************************************************/
]]