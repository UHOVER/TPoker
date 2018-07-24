local ViewBase = require("ui.ViewBase")
local CManaUpdate = class("CManaUpdate", ViewBase)
local ClubCtrol = require("club.ClubCtrol")

local _cManaUpdate = nil
local curTarget = nil
local imageView = nil
local manaTab = {}
local curData = {}
local curTableView = nil
local selectTab = {}

local function Callback(  )
	_cManaUpdate:removeFromParent()
end

local function sureCallback(  )
	local clubData = ClubCtrol.getClubInfo()
	local tipStr = ''
	if (#selectTab) <= 0 then
		ViewCtrol.showTick({content = "请选择管理员！"})
		return
	end
	local manaNum = nil
	if curTarget == 1 then
		tipStr = "成功添加管理员!"
		manaNum = clubData.manager_count + (#selectTab)
	else
		tipStr = "成功删除管理员!"
		manaNum = clubData.manager_count - (#selectTab)
	end
	local function response( data )
		-- dump(data)
		if data.code == 0 then
			ClubCtrol.editClubInfo({ club_id = clubData.id, manager_count = manaNum})
			ClubCtrol.dataStatMana(function ()
				ViewCtrol.showTick({content = tipStr})
				Callback()
				local clubMana = require("club.ClubManage")
				clubMana:updateMana()
			end )
		end
	end
	local tabData = {}
	tabData['club_id']  = clubData.id
	tabData['action'] 	= curTarget
	tabData['user_ids'] = selectTab
	XMLHttp.requestHttp('clubManagerAction', tabData, response, PHP_POST)
end

-- 全选/取消全选
local function selectAll( isAll )
	selectTab = {}
	if isAll then
		if #curData == 0 then
			selectTab = {}
			-- updateDelbtn()
			return 0
		end
		local myId = Single:playerModel():getId()
		for k,v in pairs(curData) do
			-- 添加管理员
			if curTarget == 1 then
				if tonumber(v.flag) == 0 then
					table.insert(selectTab, v.id)
					curData[k].check = 1
				end
			-- 删除管理员
			elseif curTarget == 2 then
				table.insert(selectTab, v.id)
				curData[k].check = 1
			end
			if k == #curData then
				-- updateDelbtn()
				curTableView:reloadData()
			end
		end
	else
		for k,v in pairs(curData) do
			curData[k].check = 0
			if k == #curData then
				selectTab = {}
				-- updateDelbtn()
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
				-- updateDelbtn()
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
						-- updateDelbtn()
						-- curTableView:reloadData()
						curTableView:updateCellAtIndex(key-1)
						break
					end
				end
			end
		end
	end
end

function CManaUpdate:buildLayer(  )
	local title = ''
	local tmpTab = {}
	if curTarget == 1 then
		title = '添加管理员'
		tmpTab = ClubCtrol.getMemberList()
	elseif curTarget == 2 then
		title = '删除管理员'
		tmpTab = ClubCtrol.getManaList()
	end
	for i=1,#tmpTab do
		local tmp = {}
		tmp = tmpTab[i]
		tmp['check'] = 0
		manaTab[#manaTab+1] = tmp
	end
	-- dump(manaTab)
	curData = manaTab

	UIUtil.addTopBar({backFunc = Callback, title = title, menuFont = "确定", menuFunc = sureCallback, parent = self})
	imageView = UIUtil.addImageView({image = ResLib.TABLEVIEW_BG, touch=false, scale=true, size=cc.size(display.width, display.height-390), pos=cc.p(0,0), parent=self})

	self:addDeleteBar()

	curTableView = self:createTableView()
	curTableView:reloadData()
end

function CManaUpdate:addDeleteBar(  )
	local imageBg = UIUtil.addImageView({image = ResLib.TABLEVIEW_CELL_BG, touch=false, scale=true, size=cc.size(display.width, 260), pos=cc.p(0, display.height-130), ah=cc.p(0,1), parent=self})

	-- 搜索框
	local searchBg = UIUtil.addImageView({image = "club/team_edit_name_bg.png", touch=false, scale=true, size=cc.size(display.width-50, 60), pos=cc.p(display.width/2, 260-20), ah =cc.p(0.5, 1), parent=imageBg})

	local searchEdit = UIUtil.addEditBox( nil, cc.size(display.width-50-120, 60), cc.p(10,searchBg:getContentSize().height/2), "请输入玩家ID/昵称", searchBg )
	searchEdit:setMaxLength(18)
	searchEdit:setReturnType(cc.KEYBOARD_RETURNTYPE_SEARCH)
	searchEdit:setAnchorPoint(cc.p(0, 0.5))
	local SEARCH_TEXT = ""
	local function callback( eventType, sender )
		if eventType == "began" then
		elseif eventType == "return" then
			local str = StringUtils.trim(sender:getText())
			sender:setText(str)
			SEARCH_TEXT = str
			if SEARCH_TEXT == "" then
				curData = manaTab
				curTableView:reloadData()
			end
		end
	end
	searchEdit:registerScriptEditBoxHandler( callback )

	-- 搜索按钮
	local function ssFunc(  )
		if SEARCH_TEXT ~= "" then
			local tmpTab = self:addSearchPlayer(SEARCH_TEXT)
			if next(tmpTab) ~= nil then
				curData = tmpTab
				curTableView:reloadData()
			else
				ViewCtrol.popHint({popType = 1, bgSize = cc.size(display.width-100, 300), content = "没有找到对应玩家，请更换搜索条件再试。"})
			end
		end
	end
	UIUtil.addImageBtn({norImg = "common/s_ss_icon.png", selImg = "common/s_ss_icon.png", disImg = "common/s_ss_icon.png", ah = cc.p(1, 0.5), pos = cc.p(searchBg:getContentSize().width-1, searchBg:getContentSize().height/2), touch = true, listener = ssFunc, parent = searchBg})
	
	local siteBg = UIUtil.addImageView({image = ResLib.TABLEVIEW_TEXT_LINE, touch=false, scale=true, size=cc.size(display.width, 40),pos=cc.p(0, 120), ah=cc.p(0,0), parent=imageBg})

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
end

function CManaUpdate:addSearchPlayer( text )
	local player = manaTab
	local tab = {}
	local str = tostring(text)
	for k,v in pairs(player) do
		if str == v.user_name or str == v.username then
			tab = {}
			tab[#tab+1] = v
			break
		elseif k == #player then
			for key,val in pairs(player) do
				if str == val.u_no then
					tab ={}
					tab[#tab+1] = val
					break
				end
			end
		end
	end
	return tab
end


function CManaUpdate:createTableView(  )
	local function tableCellTouched( tableViewSender, tableCell )
		-- local idx = tableCell:getIdx() + 1
		-- local data = curData[idx]
	end

	local function cellSizeForTable( tableViewSender, cellIndex )
		return 0, 140
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

function CManaUpdate:buildCellTmpl( cellItem )
	local girdNodes = {}
	girdNodes = cellItem

	local cellBg = UIUtil.addImageView({image = ResLib.TABLEVIEW_CELL_BG_LINE_2, touch=false, scale=true, size=cc.size(display.width, 140),pos=cc.p(0,0), ah=cc.p(0,0), parent=cellItem})
	girdNodes.cellBg = cellBg
	local width = cellBg:getContentSize().width
	local height = cellBg:getContentSize().height

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

	local noSp = UIUtil.addPosSprite('common/s_xzjBtn.png', cc.p(20,height/2), cellBg, cc.p(0, 0.5))
	girdNodes.noSp = noSp

	-- 头像
	local stencil, Icon = UIUtil.createCircle(ResLib.USER_HEAD, cc.p(130,height/2), cellBg, ResLib.CLUB_HEAD_STENCIL_200)
	girdNodes.stencil = stencil
	girdNodes.Icon = Icon

	-- 名称
	local Name = UIUtil.addLabelArial('名称', 30, cc.p(200, height/2+20), cc.p(0, 0.5), cellBg)
	girdNodes.Name = Name

	-- id
	local strId = UIUtil.addLabelArial('ID', 30, cc.p(200, height/2-20), cc.p(0, 0.5), cellBg)
	girdNodes.strId = strId
end

function CManaUpdate:updateCellTmpl(cellItem, cellIndex)
	local girdNodes = cellItem
	local data = curData[cellIndex]

	girdNodes.checkBox:setTag(data.id)
	if data.check == 0 then
		girdNodes.checkBox:setSelected(false)
	else
		girdNodes.checkBox:setSelected(true)
	end
	if curTarget == 1 then
		-- flag : 0-->普通成员，1-->创始人，3-->管理员
		if tonumber(data.flag) == 1 or tonumber(data.flag) == 3 then
			girdNodes.noSp:setVisible(true)
			girdNodes.checkBox:setTouchEnabled(false)
		elseif tonumber(data.flag) == 0 then
			girdNodes.noSp:setVisible(false)
			girdNodes.checkBox:setTouchEnabled(true)
		end
	else
		girdNodes.noSp:setVisible(false)
	end
	
	girdNodes.Name:setString(data.user_name or data.username)
	girdNodes.strId:setString("ID:"..data.u_no)
	local url = data.headimg
	local function funcBack( path )
		girdNodes.Icon:setTexture(path)
	end
	if url ~= "" then
		ClubModel.downloadPhoto(funcBack, url, true)
	else
		girdNodes.Icon:setTexture(ResLib.USER_HEAD)
	end

end

function CManaUpdate:createLayer( target )
	self:setSwallowTouches()
	UIUtil.setBgScale(ResLib.MAIN_BG, display.center, self)
	_cManaUpdate = self
	curTarget = target
	imageView = nil
	manaTab = {}
	curData = {}
	curTableView = nil
	selectTab = {}

	self:buildLayer()
end

return CManaUpdate