local ViewBase = require("ui.ViewBase")
local SelectClub = class("SelectClub", ViewBase)
local SelectCtrol = require("common.SelectCtrol")

local _selectClub = nil

local curTableView = nil
local curListView = nil
local curData = {}
local selectTab = {}

local tableViewH = 0

local selectCallBack = nil

local function Callback(  )
	_selectClub:removeFromParent()
end

local function sureCallback(  )
	SelectCtrol.setSelectClub(selectTab)
	if selectCallBack then
		selectCallBack()
	end
	_selectClub:removeFromParent()
end

local function selectAll( isAll )
	if isAll then
		selectTab = {}
		for k,v in pairs(curData) do
			curData[k].check = 1
			table.insert(selectTab, curData[k].club_id)
			if k == #curData then
				-- curTableView:reloadData()
			end
		end
	else
		for k,v in pairs(curData) do
			curData[k].check = 0
			if k == #curData then
				selectTab = {}
				-- curTableView:reloadData()
			end
		end
	end
	_selectClub:updateListView()
end

local function selectOne( isSelect, id, funcBack )
	if isSelect then
		for k,v in pairs(curData) do
			if tonumber(v.club_id) == tonumber(id) then
				curData[k].check = 1
				table.insert(selectTab, id)
				-- curTableView:updateCellAtIndex(k-1)
				funcBack()
				break
			end
		end
	else
		for k,v in pairs(selectTab) do
			if tonumber(v) == tonumber(id) then
				for key,val in pairs(curData) do
					if tonumber(val.club_id) == tonumber(id) then
						curData[key].check = 0
						table.remove(selectTab, k)
						-- curTableView:updateCellAtIndex(key-1)
						funcBack()
						break
					end
				end
			end
		end
	end
end

function SelectClub:buildLayer(  )
	UIUtil.addTopBar({backFunc = Callback, title = "俱乐部列表", menuFont = "确定", menuFunc = sureCallback, parent = self})

	local posH = display.height-130
	local nameBg = UIUtil.addImageView({image="club/team_edit_name_bg.png", touch=false, scale=true, size=cc.size(600, 70), ah=cc.p(0, 0.5), pos=cc.p(20, posH-55), parent=self})
	local width = nameBg:getContentSize().width
	local height = nameBg:getContentSize().height

	local searchText = nil
	local function searchFunc(  )
		self:searchClub(searchText)
	end
	UIUtil.addImageBtn({norImg = "bg/zd_ss.png", selImg = "bg/zd_ssG.png", disImg ="bg/zd_ss.png", ah =cc.p(0, 0.5), pos = cc.p(nameBg:getPositionX()+nameBg:getContentSize().width+20, nameBg:getPositionY()), touch = true, listener = searchFunc, parent = self})

	local searchEdit = UIUtil.addEditBox( nil, cc.size(580, 70), cc.p(width/2, height/2), '请输入俱乐部名片ID', nameBg ):setFontColor(display.COLOR_WHITE)
	searchEdit:setPlaceholderFontColor(ResLib.COLOR_GREY)
	searchEdit:setMaxLength(8)
	
	local function nameFunc( eventType, sender )
		if eventType == "began" then
			print("began")
		elseif eventType == "changed" then
			print("changed")
		elseif eventType == "return" then
			local str = StringUtils.trim(sender:getText())
			if str ~= "" then
				searchText = str
			end
			
		end
	end
	searchEdit:registerScriptEditBoxHandler(nameFunc)

	local line = UIUtil.addImageView({image = ResLib.IMG_LINE_BG, touch=false, scale=true, size=cc.size(display.width, 36),pos=cc.p(0, nameBg:getPositionY()-nameBg:getContentSize().height/2-20), ah=cc.p(0,1), parent=self})

	local imageBg = UIUtil.addImageView({image = ResLib.TABLEVIEW_CELL_BG, touch=false, scale=true, size=cc.size(display.width, 100),pos=cc.p(0, line:getPositionY()-line:getContentSize().height), ah=cc.p(0,1), parent=self})


	local function checkBoxFunc( sender, eventType )
		local tag = sender:getTag()
		if eventType == 0 then
			selectAll(true)
		else
			selectAll(false)
		end
	end
	local allCheck = UIUtil.addCheckBox({pos = cc.p(20,imageBg:getContentSize().height/2), checkboxFunc = checkBoxFunc, parent = imageBg})
	allCheck:setAnchorPoint(cc.p(0, 0.5))
	UIUtil.addLabelArial("全部选择", 30, cc.p(70, imageBg:getContentSize().height/2), cc.p(0,0.5), imageBg)

	curData = SelectCtrol.getUnionMem()
	local data = SelectCtrol.getSelectClub()
	if next(data) ~= nil then
		selectTab = data
	end
	dump(selectTab)
	-- dump(curData)
	tableViewH = imageBg:getPositionY()-imageBg:getContentSize().height
	-- print("-------------- " ..tableViewH)
	-- curTableView = self:createTableView(tableViewH)
	self:addListView(tableViewH)
end

function SelectClub:searchClub( num )
	if not num then
		return
	end
	for k,v in pairs(curData) do
		if tostring(v.club_number) == tostring(num) then
			curListView:scrollToItem(k-1, cc.p(.5, .5), cc.p(.5, .5))
			local tPanel = curListView:getItem(k-1)
			tPanel:stopAllActions()
			tPanel:runAction(cc.Sequence:create(
				cc.TintTo:create(0.1, 46, 77, 140),
				cc.TintTo:create(0.1, 1, 7, 24),
				cc.TintTo:create(0.1, 46, 77, 140),
				cc.TintTo:create(0.1, 1, 7, 24)
			))
			
			return
		end
	end
	ViewCtrol.showTip({content = "未查到此名片ID"})
end

function SelectClub:addListView( posH )
	curListView = ccui.ListView:create()
	curListView:setBounceEnabled(true)
	curListView:setScrollBarEnabled(false)
	curListView:setDirection(1)
	curListView:setTouchEnabled(true)
	curListView:setContentSize(cc.size(display.width, posH))
	curListView:setBackGroundImage(ResLib.TABLEVIEW_BG)
  	curListView:setBackGroundImageScale9Enabled(true)
	curListView:setAnchorPoint(0,0)
	curListView:setPosition(cc.p(0, 0))
	self:addChild( curListView )

	for i=1, #curData do
		local panel1 = self:addViewItem(i, curData[i] )
		curListView:pushBackCustomItem(panel1)
	end
end

function SelectClub:updateListView(  )
	curListView:removeAllItems()
	for i=1, #curData do
		local panel1 = self:addViewItem(i, curData[i] )
		curListView:pushBackCustomItem(panel1)
	end
end

function SelectClub:addViewItem( idx, data )
	local cell = cc.CSLoader:createNodeWithVisibleSize("scene/unionClubCell.csb")
	local tRoot = cell:getChildByName("Panel_root")
	tRoot:setColor(cc.c3b(1, 7, 24))
	tRoot:setCascadeColorEnabled(false)
	tRoot:setTouchEnabled(true)
	local name = StringUtils.getShortStr( data.club_name , LEN_NAME)
	local nameStr = ccui.Helper:seekWidgetByName(tRoot, "Text_name"):setVisible(false)
	local club_name, club_icon = UIUtil.addNameByType({nameType = 1, nameStr = name, fontSize = 36, pos = cc.p(nameStr:getPositionX(), nameStr:getPositionY()), parent = tRoot})

	ccui.Helper:seekWidgetByName(tRoot, "Text_ID"):setString("名片ID: "..data.club_number)
	
	local function selectClub(sender)
		--如果是选中状态，重置非选中状态
		local tag = sender:getTag()
		if(sender.isSelect == 1) then
			selectOne(false, tag, function()
				sender.isSelect = 0
				sender:loadTexture("common/s_xzBtn.png")
			end)
		elseif(sender.isSelect == 0) then
			selectOne(true, tag, function()
				sender.isSelect = 1
				sender:loadTexture("common/s_xzsBtn.png")
			end)
		end
	end
	local btn = ccui.Helper:seekWidgetByName(tRoot, "Image_s")
	btn.isSelect = 0--是否被选择
	btn:touchEnded(selectClub)
	btn:setTag(data.club_id)
	if data.check == 0 then
		btn:loadTexture("common/s_xzBtn.png")
	else
		btn:loadTexture("common/s_xzsBtn.png")
	end

	--添加头像
	local hx, hy = ccui.Helper:seekWidgetByName(tRoot, "Image_head"):getPosition()
	ccui.Helper:seekWidgetByName(tRoot, "Image_head"):setVisible(false)
	local stencil1, Icon1 = UIUtil.createCircle(ResLib.CLUB_HEAD_GENERAL, cc.p(hx,hy), tRoot, ResLib.CLUB_HEAD_STENCIL_200, 0.4)

	UIUtil.updateNameByType( 1, club_name, club_icon )
	Icon1:setTexture(ResLib.CLUB_HEAD_GENERAL)

	local url = data.avatar
	local function funcBack( path )
		Icon1:setTexture(path)
	end
	if url ~= "" then
		ClubModel.downloadPhoto(funcBack, url, true)
	end

	tRoot:removeFromParent()
	return tRoot
end

function SelectClub:createLayer( callBack )
	_selectClub = self
	_selectClub:setSwallowTouches()

	UIUtil.setBgScale(ResLib.MAIN_BG, display.center, self)

	selectCallBack = callBack
	curListView = nil
	curTableView = nil
	curData = {}
	selectTab = {}
	tableViewH = 0
	self:buildLayer()
end

return SelectClub