local ViewBase = require('ui.ViewBase')
local ClubMsg = class('ClubMsg', ViewBase)

local ClubCtrol = require("club.ClubCtrol")
local UnionCtrol = require("union.UnionCtrol")

local _clubMsg = nil
local tab = {}
	tab['font'] = 'Arial'
	tab['size'] = 30

local clubTab = {}
local curData = {}
local curTableView = nil
local imageView = nil

local MSG_TARGET = nil

local selectTab = {}
local deleteButton = nil

local function callBack(  )
	
	if MSG_TARGET == "club" or MSG_TARGET == "club_list" then
		Notice.deleteMessage( 2 )
		_clubMsg:removeFromParent()
		if MSG_TARGET == "club" then
			local clubInfo = ClubCtrol.getClubInfo()
			ClubCtrol.dataStatClubInfo( clubInfo.id, function ()
				local myEvent = cc.EventCustom:new("C_Event_update_ClubInfo")
				local customEventDispatch = cc.Director:getInstance():getEventDispatcher()
				customEventDispatch:dispatchEvent(myEvent)
			end )
		end
	elseif MSG_TARGET == "union" then
		Notice.deleteMessage( 3 )
		UnionCtrol.requestDetailUnion(function() 
			_clubMsg:removeFromParent()
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
			if MSG_TARGET == "club" or MSG_TARGET == "club_list" then
				table.insert(selectTab, v.message_id)
				curData[k].check = 1
			elseif MSG_TARGET == "union" then
				table.insert(selectTab, v.cid)
				curData[k].check = 1
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
			if MSG_TARGET == "club" or MSG_TARGET == "club_list" then
				if tonumber(v.message_id) == tonumber(id) then
					curData[k].check = 1
					table.insert(selectTab, id)
					updateDelbtn()
					-- curTableView:reloadData()
					curTableView:updateCellAtIndex(k-1)
					break
				end
			elseif MSG_TARGET == "union" then
				if tonumber(v.cid) == tonumber(id) then
					curData[k].check = 1
					table.insert(selectTab, id)
					updateDelbtn()
					-- curTableView:reloadData()
					curTableView:updateCellAtIndex(k-1)
					break
				end
			end
		end
	else
		for k,v in pairs(selectTab) do
			if v == id then
				for key,val in pairs(curData) do
					if MSG_TARGET == "club" or MSG_TARGET == "club_list" then
						if tonumber(val.message_id) == tonumber(id) then
							curData[key].check = 0
							table.remove(selectTab, k)
							updateDelbtn()
							-- curTableView:reloadData()
							curTableView:updateCellAtIndex(key-1)
							break
						end
					elseif MSG_TARGET == "union" then
						if tonumber(val.cid) == tonumber(id) then
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
end

local function deleteClubMessage(  )
	local cmsg_tab = {}
	local umsg_tab = {}
	local tmsg_tab = {}
	local msg_tab = {}
	for k,v in pairs(selectTab) do
		for key,val in pairs(curData) do
			if tonumber(v) == tonumber(val.message_id) then
				if val.mod == "person" then
					cmsg_tab[#cmsg_tab+1] = val.message_id
				elseif val.mod == "union" then
					umsg_tab[#umsg_tab+1] = val.message_id
				elseif val.mod == "team" then
					tmsg_tab[#tmsg_tab+1] = val.message_id
				end
			end
			if k == #selectTab then
				msg_tab["cmessage_id"] = cmsg_tab
				msg_tab["umessage_id"] = umsg_tab
				msg_tab["tmessage_id"] = tmsg_tab
			end
		end
	end
	local function response( data )
		dump(data)
		if data.code == 0 then
			for k,v in pairs(selectTab) do
				for key,val in pairs(curData) do
					if tonumber(v) == tonumber(val.message_id) then
						table.remove(curData, key)
					end
					if k == #selectTab then
						-- dump(curData)
						selectTab = {}
						updateDelbtn()
						curTableView:reloadData()
					end
				end
			end
		end
	end
	local tabData = {}
	tabData["message_id"] = msg_tab
	-- dump(tabData)
	XMLHttp.requestHttp("delete_club_union_message", tabData, response, PHP_POST)
end

local function deleteUnionMessage(  )
	local function response( data )
		dump(data)
		if data.code == 0 then
			for k,v in pairs(selectTab) do
				for key,val in pairs(curData) do
					if tonumber(v) == tonumber(val.cid) then
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
	tabData['club_ids'] = selectTab
	tabData["union_id"] = UnionCtrol.getUnionInfo()["union_id"]
	XMLHttp.requestHttp('deleteUnionMessage', tabData, response, PHP_POST)
end

function ClubMsg:buildLayer(  )
	
	-- addTopBar
	UIUtil.addTopBar({backFunc = callBack, title = "消息", parent = self})

	imageView = UIUtil.addImageView({image = ResLib.TABLEVIEW_BG, touch=false, scale=true, size=cc.size(display.width, display.height-260), pos=cc.p(0,0), parent=self})

	self:addDeleteBar()

	curTableView = nil
	if MSG_TARGET == "club" or MSG_TARGET == "club_list" then
		Notice.deleteMessage( 2 )
		self:buildClubData()
	elseif MSG_TARGET == "union" then
		Notice.deleteMessage( 3 )
		self:buildUnionData()
	end
	
end

function ClubMsg:addDeleteBar(  )
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
	allCheck:setAnchorPoint(cc.p(0, 0.5))
	UIUtil.addLabelArial("全部选择", 30, cc.p(70, 130/2), cc.p(0,0.5), imageBg)

	local function delFuncback( sender )
		print("删除")
		dump(selectTab)
		local layer = nil
		local function deleteFunc(  )
			if MSG_TARGET == "club" or MSG_TARGET == "club_list" then
				deleteClubMessage()
			elseif MSG_TARGET == "union" then
				deleteUnionMessage()
			end
			allCheck:setSelected(false)
			layer:removeFromParent()
		end
		layer = UIUtil.deleteList({content = "你确定要删除选中的"..#selectTab.."位成员消息吗？", sureFunc = deleteFunc, parent = self})
	end
	deleteButton = UIUtil.addImageBtn({text = "删除", norImg = "common/com_btn_delete_img.png", selImg = "common/com_btn_delete_img.png", disImg = "common/com_btn_delete_img.png", scale9 = true, size = cc.size(102, 50), pos = cc.p(display.width-20, 130/2), ah = cc.p(1, 0.5), swalTouch = true, touch = true,  listener = delFuncback, parent = imageBg})
	updateDelbtn()
end

--[[
**************************************************************************
* NAME OF THE BUG :   YDWX_DZ_ZHANGXINMIN_BUG _20160722 _013 
* DESCRIPTION OF THE BUG :prompt error 
* MODIFIED BY : 王礼宁
* DATE :2016-8-2
*************************************************************************/
]]


function ClubMsg:buildClubData(  )
	local function response( data )
		dump(data)
		if data.code == 0 then
			
			curData = self:buildCheck(data.data)
			if next(curData) ~= nil then
				curTableView = self:createTableView()
				curTableView:reloadData()
			end
		end
	end
	local tabData = {}
	tabData['club_id'] = clubTab.id
	XMLHttp.requestHttp( PHP_CLUB_MSG, tabData, response, PHP_POST )
end

--[[
**************************************************************************
* NAME OF THE BUG :   YDWX_DZ_ZHANGXINMIN_BUG _20160722 _013 
* DESCRIPTION OF THE BUG :prompt error 
* MODIFIED BY : 王礼宁
* DATE :2016-8-2
*************************************************************************/
]]

function ClubMsg:buildUnionData(  )
	local function response( data )
		dump(data)
		if data.code == 0 then
			curData = self:buildCheck(data.data)
			if next(curData) ~= nil then
				curTableView = self:createTableView()
				curTableView:reloadData()
			end
		end
	end
	local tabData = {}
	tabData['union_id'] = clubTab.union_id
	XMLHttp.requestHttp( "union_messages", tabData, response, PHP_POST )
end

function ClubMsg:buildCheck( data )
	local tmpData = {}
	for k,v in pairs(data) do
		local tmpTab = {}
		tmpTab = v
		tmpTab["check"] = 0
		tmpData[#tmpData+1] = tmpTab
	end
	dump(tmpData)
	return tmpData
end

function ClubMsg:createTableView(  )

	local function tableCellTouched( tableViewSender, tableCell )
		
	end
	local function cellSizeForTable( tableViewSender, cellIndex )
		return 0, 240
	end
	local function numberOfCellsInTableView( tableViewSender )
		return #curData
	end
	local function tableCellAtIndex( tableViewSender, cellIndex )
		local index = cellIndex + 1

		local cellItem = tableViewSender:dequeueCell()
		if cellItem == nil then
			cellItem = cc.TableViewCell:new()

			self:buildCellTmpl(cellItem)
		end
		self:updateCellTmpl(cellItem, curData[index])

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
	return tableView
end

function ClubMsg:buildCellTmpl(cellItem)
	local girdNodes = {}
	girdNodes = cellItem

	local cellBg = UIUtil.addImageView({image = ResLib.TABLEVIEW_CELL_BG_LINE_2, touch=false, scale=true, size=cc.size(display.width, 240),pos=cc.p(0,0), ah=cc.p(0,0), parent=cellItem})
	girdNodes.cellBg = cellBg
	local width = cellBg:getContentSize().width
	local height = cellBg:getContentSize().height

	local head_icon = nil
	if MSG_TARGET == "club" or MSG_TARGET == "club_list" then
		head_icon = ResLib.USER_HEAD
	elseif MSG_TARGET == "union" then
		head_icon = ResLib.UNION_HEAD
	end

	local stencil, Icon = UIUtil.createCircle(head_icon, cc.p(130, (height-90)/2+90), cellBg, ResLib.CLUB_HEAD_STENCIL_200)
	girdNodes.Icon = Icon

	local msgTitle = UIUtil.addLabelArial('消息标题', 36, cc.p(200, (height-90)*3/4-10+90), cc.p(0,0.5), cellBg)
	girdNodes.msgTitle = msgTitle

	local msgDes = UIUtil.addLabelArial('消息类容', 24, cc.p(200, (height-90)/4+100), cc.p(0,0.5), cellBg)
	msgDes:setColor(cc.c3b(165, 157, 157))
	girdNodes.msgDes = msgDes

	local teamName, team_icon = UIUtil.addNameByType({nameType = 5, nameStr = "战队", fontSize = 34, pos = cc.p(msgDes:getPositionX(), (height-90)/4+100), parent = cellBg})
	girdNodes.teamName = teamName
	girdNodes.team_icon = team_icon


	local msgStatus = UIUtil.addLabelArial('消息状态', 24, cc.p(width/2, 32), cc.p(0.5,0), cellBg)
	girdNodes.msgStatus = msgStatus

	local function checkBoxFunc( sender, eventType )
		local tag = sender:getTag()
		if eventType == 0 then
			print("选中")
			selectOne(true, tag)
		else
			selectOne(false, tag)
		end
	end
	local checkBox = UIUtil.addCheckBox({pos = cc.p(20,(height-90)/2+90), checkboxFunc = checkBoxFunc, parent = cellBg})
	checkBox:setAnchorPoint(cc.p(0,0.5))
	girdNodes.checkBox = checkBox

	local function okFuncback( sender )
		if MSG_TARGET == "club" or MSG_TARGET == "club_list" then
			local tag = sender:getTag()
			self:setClubMessage({message_id = tag, status = 1})

		elseif MSG_TARGET == "union" then
			local tag = sender:getTag()
			self:setUnionMessage({club_id = tag, status = 1})
		end
	end
	local agreeBtn = UIUtil.addImageBtn({norImg = ResLib.BTN_CELL_AGREE, pos = cc.p(width/2-81, 20), ah = cc.p(0.5, 0), touch = true, listener = okFuncback, parent = cellBg})
	girdNodes.agreeBtn = agreeBtn
	
	local function noFuncback( sender )
		if MSG_TARGET == "club" or MSG_TARGET == "club_list" then
			print('拒绝')
			local tag = sender:getTag()
			self:setClubMessage({message_id = tag, status = 2})

		elseif MSG_TARGET == "union" then
			local tag = sender:getTag()
			self:setUnionMessage({club_id = tag, status = 2})
		end
	end
	local refuseBtn = UIUtil.addImageBtn({norImg = ResLib.BTN_CELL_REFUSE, pos = cc.p(width/2+81, 20), ah = cc.p(0.5, 0), touch = true, listener = noFuncback, parent = cellBg})
	girdNodes.refuseBtn = refuseBtn
end

function ClubMsg:updateCellTmpl(cellItem, cellData)
	local girdNodes = cellItem
	local data = {}
	data = cellData

	-- UIUtil.addTouchMoved(girdNodes.cellBg, girdNodes.cell_Bg, girdNodes.delBtn)

	local name = nil
	local url = nil

	if MSG_TARGET == "club" or MSG_TARGET == "club_list" then

		if data.mod == "person" then

			name = StringUtils.getShortStr( data.username, LEN_NAME)

			girdNodes.Icon:setTexture(ResLib.USER_HEAD)

			url = data.headimg
		elseif data.mod == "union" then
			
			name = StringUtils.getShortStr( data.union_name, LEN_NAME)

			girdNodes.Icon:setTexture(ResLib.UNION_HEAD)

			url = data.union_avatar
		elseif data.mod == "team" then
			name = StringUtils.getShortStr( data.username, LEN_NAME)

			girdNodes.Icon:setTexture(ResLib.USER_HEAD)

			url = data.headimg
		end
		if data.mod == "team" then
			girdNodes.teamName:setVisible(true)
			girdNodes.team_icon:setVisible(true)
			girdNodes.msgDes:setString("申请加入战队")
			girdNodes.teamName:setString(data.content.."战队")
			girdNodes.teamName:setPositionX(girdNodes.msgDes:getPositionX()+girdNodes.msgDes:getContentSize().width+10)
			UIUtil.updateNameByType( 5, girdNodes.teamName, girdNodes.team_icon )
		else
			girdNodes.teamName:setVisible(false)
			girdNodes.team_icon:setVisible(false)
			local content = StringUtils.getShortStr( data.content, 40)
			girdNodes.msgDes:setString(content)
		end
		
		girdNodes.msgTitle:setString(name)

		girdNodes.agreeBtn:setTag(data.message_id)

		girdNodes.refuseBtn:setTag(data.message_id)

		girdNodes.checkBox:setTag(data.message_id)

	elseif MSG_TARGET == "union" then

		girdNodes.teamName:setVisible(false)
		girdNodes.team_icon:setVisible(false)

		local name = StringUtils.getShortStr( data.name, LEN_NAME)
		girdNodes.msgTitle:setString(data.name)

		local content = StringUtils.getShortStr( data.content, 40)
		girdNodes.msgDes:setString(content)

		girdNodes.Icon:setTexture(ResLib.CLUB_HEAD_GENERAL)

		girdNodes.agreeBtn:setTag(data.cid)

		girdNodes.refuseBtn:setTag(data.cid)

		girdNodes.checkBox:setTag(data.cid)

		url = data.avatar
	end
	local function funcBack( path )
		local rect = girdNodes.Icon:getContentSize()
		girdNodes.Icon:setTexture(path)
		girdNodes.Icon:setTextureRect(rect)
	end
	if url ~= nil or url ~= "" then
		ClubModel.downloadPhoto(funcBack, url, true)
	end

	if data.check == 0 then
		girdNodes.checkBox:setSelected(false)
	else
		girdNodes.checkBox:setSelected(true)
	end

	-- 消息状态处理
	if tonumber(data.status) == 0 then
		girdNodes.agreeBtn:setVisible(true)
		girdNodes.refuseBtn:setVisible(true)
		girdNodes.msgStatus:setString('')
	elseif tonumber(data.status) == 1 then 			-- 已同意
		girdNodes.agreeBtn:setVisible(false)
		girdNodes.refuseBtn:setVisible(false)
		girdNodes.msgStatus:setString('已同意')
		girdNodes.msgStatus:setColor(ResLib.COLOR_BLUE)
	elseif tonumber(data.status) == 2 then 			-- 已拒绝
		girdNodes.agreeBtn:setVisible(false)
		girdNodes.refuseBtn:setVisible(false)
		girdNodes.msgStatus:setString('已拒绝')
		girdNodes.msgStatus:setColor(ResLib.COLOR_GREY)
	end

end

-- 俱乐部同意、拒绝、删除 联盟邀请消息
-- message_id / status
function ClubMsg:setClubMessage( sender )

	local message_id = tonumber(sender.message_id)
	local mod = nil
	local user_id = nil
	local union_id = nil
	local httpUrl = nil
	local sendData = {}
	local status = sender.status
	local team_id = nil

	for k,v in pairs(curData) do
		if tonumber(v.message_id) == message_id then
			mod = v.mod
			if v.mod == "person" then
				user_id = v.user_id
			elseif v.mod == "union" then
				union_id = v.union_id
			elseif v.mod == "team" then
				user_id = v.user_id
				team_id = v.team_id
			end
			break
		end
	end

	if mod == "person" then
		print("玩家申请消息")
		local function response( data )
			dump(data)
			if data.code == 0 then
				for k,v in pairs(curData) do
					if tonumber(v.message_id) == message_id then
						curData[k].status = status
						curTableView:reloadData()
						-- dump(curData[k])
						break
					end
				end
			end
		end
		local tabData = {}
		if status == 1 then
			tabData['club_id'] 		= clubTab.id
			tabData['user_id'] 		= user_id
			tabData['message_id'] 	= message_id

			httpUrl = PHP_CLUB_JOIN
		elseif status == 2 then
			tabData['message_id'] 	= message_id

			httpUrl = "refuse_join"
		end
		XMLHttp.requestHttp(httpUrl, tabData, response, PHP_POST)
	elseif mod == "union" then
		-- 联盟邀请消息
		print("联盟邀请消息")
		local function response( data )
			if data.code == 0 then
				for k,v in pairs(curData) do
					if tonumber(v.message_id) == message_id then
						curData[k].status = status
						curTableView:reloadData()
						break
					end
				end
			end
		end
		local tabData = {}
		tabData["union_id"] = union_id
		tabData['club_id'] 	= clubTab.id
		tabData["status"] 	= status
		XMLHttp.requestHttp("agree_request", tabData, response, PHP_POST)
	elseif mod == "team" then
		local function response( data )
			if data.code == 0 then
				for k,v in pairs(curData) do
					if tonumber(v.message_id) == message_id then
						curData[k].status = status
						curTableView:reloadData()
						break
					end
				end
			end
		end
		local tabData = {}
		tabData["team_id"] 		= team_id
		tabData['club_id'] 		= clubTab.id
		tabData['user_id'] 		= user_id
		tabData['message_id'] 	= message_id
		tabData["flag"] 		= status
		XMLHttp.requestHttp("joinTeamHandle", tabData, response, PHP_POST)
	end
end

-- 处理联盟消息
function ClubMsg:setUnionMessage( sender )

	local club_id = sender.club_id
	local status = sender.status 

	local function response( data )
		-- dump(data)
		if data.code == 0 then
			for k,v in pairs(curData) do
				if tonumber(v.cid) == club_id then
					curData[k].status = status
					curTableView:reloadData()	
					break
				end
			end
		end
	end
	local tabData = {}
	tabData['club_id'] = club_id
	tabData["union_id"] = UnionCtrol.getUnionInfo()["union_id"]
	tabData["status"] = status
	XMLHttp.requestHttp('union_agree_request', tabData, response, PHP_POST)
end

function ClubMsg:createLayer( target )

	_clubMsg = self
	_clubMsg:setSwallowTouches()

	MSG_TARGET = target
	clubTab = {}
	curTableView = nil
	imageView = nil
	curData = {}

	selectTab = {}
	deleteButton = nil

	if MSG_TARGET == "club" then
		_clubMsg:addTransitAction()
		clubTab = ClubCtrol.getClubInfo()
	elseif MSG_TARGET == "club_list" then
		_clubMsg:addTransitAction()
		local tmpTab = ClubCtrol.getClubList(  )
		-- dump(tmpTab)
		for k,v in pairs(tmpTab) do
			if v.is_create == "1" then
				clubTab = tmpTab[k]
				break
			end
		end	
	elseif MSG_TARGET == "union" then
		clubTab = UnionCtrol.getUnionInfo()
	end
	dump(clubTab)
	
	UIUtil.setBgScale(ResLib.MAIN_BG, display.center, self)
	curData = {}
	self:buildLayer(  )

end

return ClubMsg