local ViewBase = require("ui.ViewBase")
local mttBlinds = class("mttBlinds", ViewBase)

local SetCards = require("common.SetCards")

function mttBlinds:ctor( blindLevel, blindType, mttType )
	self.blindTab = DZConfig.getMttBlindTab()

	self.curData = {}
	self.tableView = nil
	self.tableBg = nil

	local blind_type = {general=1, quick=2}

	self.orgBlind = blindLevel
	self.blindType = blind_type[tostring(blindType)]

	self.mttType = mttType

	print("blindLevel: ".. blindLevel)
	print("blindType: ".. blindType)
	self.curData = self.blindTab[tostring(blindType)]["blind_"..tostring(blindLevel)]

	self:init()
end

function mttBlinds:init(  )
	self:setSwallowTouches()
	local layer = cc.LayerColor:create(cc.c4b(10, 10, 10, 200))
	layer:setPosition(cc.p(0,0))
	self:addChild(layer)

	local color_yellow = cc.c3b(204, 204, 204)

	local blind_type = {"general", "quick"}

	local sp_w = display.width-40
	local sp_h = display.height-150
	local bgSp1 = UIUtil.addImageView({image = "common/common_notify_bg.png", touch=false, scale=true, size=cc.size(sp_w, sp_h), pos=cc.p(display.cx, display.cy-50), ah =cc.p(0.5, 0.5), parent=self})
	-- local bgSp2 = UIUtil.addImageView({image = "common/common_notify_bg1.png", touch=false, scale=true, size=cc.size(sp_w, sp_h), pos=cc.p(sp_w/2, sp_h/2), ah =cc.p(0.5, 0.5), parent=bgSp1})
	local bgSp3 = UIUtil.addImageView({image = "common/common_notify_bg2.png", touch=false, scale=true, size=cc.size(sp_w, sp_h), pos=cc.p(sp_w/2, sp_h/2), ah =cc.p(0.5, 0.5), parent=bgSp1})
	bgSp3:setLocalZOrder(10)
	-- 关闭
	local function closeLayer(  )
		if self.mttType == 0 then
			SetCards.updateOrgBlind({blindLevel = self.orgBlind, blindType = self.blindType})
		end
		self:removeFromParent()
	end
	UIUtil.addImageBtn({norImg = "common/set_card_MTT_close.png", selImg = "common/set_card_MTT_close_height.png", ah = cc.p(0.5, 0.5), pos = cc.p(sp_w-20, sp_h-20), touch = true, listener = closeLayer, parent = bgSp3})

	local title = UIUtil.addLabelArial('MTT盲注级别', 36, cc.p(sp_w/2, sp_h-50), cc.p(0.5, 1), bgSp3)
		
	self.tableBg = UIUtil.addImageView({image = "common/common_sngpop_little_bg.png", touch=false, scale=true, size=cc.size(sp_w-60, sp_h-150), pos=cc.p(sp_w/2, 30), ah =cc.p(0.5, 0), parent=bgSp3})
	local bgWidth = self.tableBg:getContentSize().width
	local bgHeight = self.tableBg:getContentSize().height

	if self.mttType == 0 then
		self:buildSetMtt( bgWidth, bgHeight )
	elseif self.mttType == 1 then
		self:buildShowMtt( bgWidth, bgHeight )
	end
end

function mttBlinds:buildShowMtt( bgWidth, bgHeight )
	local blindBg = UIUtil.addImageView({image = "common/set_card_MTT_bind_bg.png", touch=false, scale=true, size=cc.size(bgWidth, 50), pos=cc.p(bgWidth/2, bgHeight-5), ah =cc.p(0.5, 1), parent=self.tableBg})
	local bindTitle = {"盲注级别", "小盲注", "大盲注", "前注"}
	for i=1, #bindTitle do
		UIUtil.addLabelArial(bindTitle[i], 30, cc.p(blindBg:getContentSize().width*(2*i-1)/(2*(#bindTitle)), blindBg:getContentSize().height/2), cc.p(0.5, 0.5), blindBg):setColor(cc.c3b(142, 199, 223)):enableBold()
	end

	self.tableView = self:createTableView( 60 )
	self.tableView:reloadData()
end

function mttBlinds:buildSetMtt( bgWidth, bgHeight )
	-- 起始盲注级别
	local blindLevel =  DZConfig.getBlindLevel()
	local blind_type = {"general", "quick"}
	local color_yellow = cc.c3b(204, 204, 204)

	-- self.orgBlind = blindLevel[1]
	local mttLabel4 = UIUtil.addLabelArial("起始盲注级别:", 30, cc.p(20, bgHeight-40), cc.p(0, 0.5), self.tableBg):setColor(ResLib.COLOR_GREY)
	local mttStr4 = UIUtil.addLabelArial(tostring(self.orgBlind).."/"..tostring(self.orgBlind*2), 30, cc.p(mttLabel4:getPositionX()+mttLabel4:getContentSize().width+10, bgHeight-40), cc.p(0, 0.5), self.tableBg):setColor(color_yellow)
	local function sliderChange( sender )
		local idx = math.floor(sender:getValue())
		print(blindLevel[idx])
		self.orgBlind = blindLevel[idx]/2
		mttStr4:setString(tostring(self.orgBlind).."/"..tostring(self.orgBlind*2))

		if self.tableView ~= nil then
			self.curData = self.blindTab[blind_type[self.blindType]]["blind_"..tostring(self.orgBlind)]
			self.tableView:reloadData()
		end
	end
	local imgs = {"common/com_progress_img_blue_1.png", "common/com_progress_img_blue.png", 'main/main_thumb.png'}
	local maxLen = #blindLevel
	local tslider = UIUtil.addSlider(imgs, cc.p(bgWidth/2, bgHeight-100), self.tableBg, sliderChange, 1.1, maxLen)
	tslider:setAnchorPoint(0.5,0.5)
	local value = 1.1
	for i,v in ipairs(blindLevel) do
		if v == self.orgBlind*2 then
			value = i+0.9
			break
		end
	end
	tslider:setValue(value)

	--	盲注表类型
	local mttLabel5 = UIUtil.addLabelArial('盲注表类型:', 30, cc.p(20, bgHeight-170), cc.p(0, 0.5), self.tableBg):setColor(ResLib.COLOR_GREY)
	local blindBox = {}
	local blindLabel = {}
	local function blindBoxFunc( sender, eventType )
		local tag = sender:getTag()
		print("tag: "..tag)
		print("eventType: "..eventType)
		if eventType == 0 then
			blindLabel[tag]:setColor(ResLib.COLOR_BLUE)
			blindBox[tag]:setTouchEnabled(false)
			if tag == 1 then
				self.blindType = 1
				if blindBox[2]:isSelected() then
					blindBox[2]:setSelectedState(false)
					blindBox[2]:setTouchEnabled(true)
					blindLabel[2]:setColor(ResLib.COLOR_GREY)
				end
			elseif tag == 2 then
				self.blindType = 2
				if blindBox[1]:isSelected() then
					blindBox[1]:setSelectedState(false)
					blindBox[1]:setTouchEnabled(true)
					blindLabel[1]:setColor(ResLib.COLOR_GREY)
				end
			end

			if self.tableView ~= nil then
				self.curData = self.blindTab[blind_type[self.blindType]]["blind_"..tostring(self.orgBlind)]
				self.tableView:reloadData()
			end
		else
			blindLabel[tag]:setColor(ResLib.COLOR_GREY)
			-- self.blindType = 0
		end
	end
	local straddleStr = {"盲注表(普通)", "盲注表(快速)"}
	for i=1,2 do
		blindBox[i] = UIUtil.addCheckBox({checkBg = "common/com_checkBox_1.png", checkBtn = "common/com_checkBox_1_1.png", ah = cc.p(0, 0.5), pos = cc.p(20+(i-1)*300, bgHeight-230), checkboxFunc = blindBoxFunc, parent = self.tableBg}):setTag(i)
		blindLabel[i] = UIUtil.addLabelArial(straddleStr[i], 30, cc.p(60+(i-1)*300, bgHeight-230), cc.p(0, 0.5), self.tableBg):setColor(ResLib.COLOR_GREY)
	end

	local blindBg = UIUtil.addImageView({image = "common/set_card_MTT_bind_bg.png", touch=false, scale=true, size=cc.size(bgWidth, 50), pos=cc.p(bgWidth/2, bgHeight-300), ah =cc.p(0.5, 1), parent=self.tableBg})
	local bindTitle = {"盲注级别", "小盲注", "大盲注", "前注"}
	for i=1, #bindTitle do
		UIUtil.addLabelArial(bindTitle[i], 30, cc.p(blindBg:getContentSize().width*(2*i-1)/(2*(#bindTitle)), blindBg:getContentSize().height/2), cc.p(0.5, 0.5), blindBg):setColor(cc.c3b(142, 199, 223)):enableBold()
	end
	
	blindBox[self.blindType]:setSelectedState(true)
	blindLabel[self.blindType]:setColor(ResLib.COLOR_BLUE)
	blindBox[self.blindType]:setTouchEnabled(false)

	self.tableView = self:createTableView( 360 )
	self.tableView:reloadData()
end

function mttBlinds:createTableView( viewH )

	local tableView_w = self.tableBg:getContentSize().width-20
	local tableView_h = self.tableBg:getContentSize().height-viewH

	local function tableCellTouched( tableViewSender, tableCell )
	end

	local function cellSizeForTable( tableViewSender, cellIndex )
		return 0, 60
	end

	local function numberOfCellsInTableView( tableViewSender )
		return #self.curData
	end

	local function tableCellAtIndex( tableViewSender, cellIndex )
		local index = cellIndex + 1
		local cellItem = tableViewSender:dequeueCell()
		local label = {}
		
		local tmp = self.curData[index]
		local data = {tmp["blindLevel"], tmp["blindSmall"], tmp["blindBig"], tmp["ante"]}

		if cellItem == nil then
			cellItem = cc.TableViewCell:new()
			-- local cellBg = UIUtil.addImageView({image = ResLib.TABLEVIEW_CELL_BG, touch=false, scale=true, size=cc.size(tableView_w, 60),pos=cc.p(0,0), ah=cc.p(0,0), parent=cellItem})
			-- 创建函数
			for i=1, 4 do
				label[i] = UIUtil.addLabelArial(data[i], 30, cc.p(tableView_w*(2*i-1)/(2*4), 30), cc.p(0.5, 0.5), cellItem)
				label[i]:setTag(i)
			end
		else
			-- 修改函数
			for i=1,4 do
				label[i] = cellItem:getChildByTag(i)
				if label[i] ~= nil then
					label[i]:setString(data[i])
				end
			end
		end
		return cellItem
	end

	-- local imageView = UIUtil.addImageView({image = ResLib.TABLEVIEW_BG, touch=false, scale=true, size=cc.size(tableView_w, tableView_h), pos=cc.p(10,10), parent=self.tableBg})

	local tableView = cc.TableView:create( cc.size(tableView_w, tableView_h))
	tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
	tableView:setPosition(cc.p(10,10))
	self.tableBg:addChild(tableView)
	tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
	tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
	tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
	tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
	tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
	tableView:setDelegate()
	tableView:reloadData()
	return tableView
end

return mttBlinds