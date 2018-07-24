local ViewBase = require("ui.ViewBase")
local mttAward = class("mttAward", ViewBase)
local SetModel = require("common.SetModel")
local SetCards = require("common.SetCards")

function mttAward:ctor( player, awardNum, entryFee, funBack )

	self.curData = {}
	self.tableView = nil
	self.tableBg = nil

	-- 人数上限
	self.player = player
	-- 奖励范围
	self.awardNum = awardNum
	-- 报名费
	self.entryFee = entryFee
	-- 回调
	self.funBack = funBack
	-- 当前奖励表
	self.scaleTab = SetModel.getMttAward( player )

	-- 奖励数据
	self.awardTab = {}

	for i,v in ipairs(self.scaleTab) do
		if v.num == self.awardNum then
			self.awardTab = v
			break
		end
	end

	self.curData = self:buildTab()
	self:init()
end

function mttAward:buildTab(  )
	local tab = SetModel.getAwardTab( self.player )
	local str = "num_"..tostring(self.awardNum)
	-- dump(tab[str])
	local awardTab = {}
	for i,v in ipairs(tab[str]) do
		local tmpTab = {}
		tmpTab = v
		tmpTab["score"] = (self.entryFee*self.player*v.awardScale)/100
		awardTab[#awardTab+1] = tmpTab
	end
	return awardTab
end

function mttAward:init(  )
	self:setSwallowTouches()
	local layer = cc.LayerColor:create(cc.c4b(10, 10, 10, 200))
	layer:setPosition(cc.p(0,0))
	self:addChild(layer)

	local color_yellow = cc.c3b(204, 204, 204)

	local sp_w = display.width-40
	local sp_h = display.height-150
	local bgSp1 = UIUtil.addImageView({image = "common/common_notify_bg.png", touch=false, scale=true, size=cc.size(sp_w, sp_h), pos=cc.p(display.cx, display.cy-50), ah =cc.p(0.5, 0.5), parent=self})
	-- local bgSp2 = UIUtil.addImageView({image = "common/common_notify_bg1.png", touch=false, scale=true, size=cc.size(sp_w, sp_h), pos=cc.p(sp_w/2, sp_h/2), ah =cc.p(0.5, 0.5), parent=bgSp1})
	local bgSp3 = UIUtil.addImageView({image = "common/common_notify_bg2.png", touch=false, scale=true, size=cc.size(sp_w, sp_h), pos=cc.p(sp_w/2, sp_h/2), ah =cc.p(0.5, 0.5), parent=bgSp1})
	bgSp3:setLocalZOrder(10)
	-- 关闭
	local function closeLayer(  )
		if self.funBack then
			self.funBack(self.awardTab)
		end
		self:removeFromParent()
	end
	UIUtil.addImageBtn({norImg = "common/set_card_MTT_close.png", selImg = "common/set_card_MTT_close_height.png", ah = cc.p(0.5, 0.5), pos = cc.p(sp_w-20, sp_h-20), touch = true, listener = closeLayer, parent = bgSp3})

	local title = UIUtil.addLabelArial('奖励表', 36, cc.p(sp_w/2, sp_h-50), cc.p(0.5, 1), bgSp3)
		
	self.tableBg = UIUtil.addImageView({image = "common/common_sngpop_little_bg.png", touch=false, scale=true, size=cc.size(sp_w-60, sp_h-150), pos=cc.p(sp_w/2, 30), ah =cc.p(0.5, 0), parent=bgSp3})
	local bgWidth = self.tableBg:getContentSize().width
	local bgHeight = self.tableBg:getContentSize().height

	local awardLabel = {}
	local awardStr = {}
	local text = {"参赛人数", "奖励范围"}
	local value = {self.player, tostring(self.awardTab["num"])..'人('..tostring(self.awardTab["scaleNum"])..'%)'}
	for i=1,#text do
		awardLabel[i] = UIUtil.addLabelArial(text[i].."：", 30, cc.p(38, bgHeight-60-(i-1)*60), cc.p(0, 0.5), self.tableBg):setColor(ResLib.COLOR_GREY)
		awardStr[i] = UIUtil.addLabelArial(value[i], 30, cc.p(awardLabel[i]:getPositionX()+awardLabel[i]:getContentSize().width+10, bgHeight-60-(i-1)*60), cc.p(0, 0.5), self.tableBg)
	end

	local function sliderChange( sender )
		local idx = math.floor(sender:getValue())
		self.awardTab = self.scaleTab[idx]
		-- dump(self.awardTab)
		local str = tostring(self.awardTab["num"])..'人('..tostring(self.awardTab["scaleNum"])..'%)'
		self.awardNum = self.awardTab["num"]
		awardStr[2]:setString(str)

		if self.tableView ~= nil then
			self.curData = self:buildTab()
			self.tableView:reloadData()
		end
	end
	local imgs = {"common/com_progress_img_blue_1.png", "common/com_progress_img_blue.png", 'main/main_thumb.png'}
	local maxLen = #self.scaleTab+0.9
	local tslider = UIUtil.addSlider(imgs, cc.p(bgWidth/2, bgHeight-180), self.tableBg, sliderChange, 1.1, maxLen)
	tslider:setAnchorPoint(0.5,0.5)
	local value = 1.1
	for i,v in ipairs(self.scaleTab) do
		if v.num == self.awardNum then
			value = i+0.9
			break
		end
	end
	tslider:setValue(value)

	local blindBg = UIUtil.addImageView({image = "common/set_card_MTT_bind_bg.png", touch=false, scale=true, size=cc.size(bgWidth, 50), pos=cc.p(bgWidth/2, bgHeight-220), ah =cc.p(0.5, 1), parent=self.tableBg})
	local titleStr = {"排名", "奖励比例", "获得记分牌"}
	for i=1,#titleStr do
		UIUtil.addLabelArial(titleStr[i], 30, cc.p(blindBg:getContentSize().width*(2*i-1)/(2*(#titleStr)), blindBg:getContentSize().height/2), cc.p(0.5, 0.5), blindBg):setColor(cc.c3b(142, 199, 223)):enableBold()
	end

	self.tableView = self:createTableView()
	self.tableView:reloadData()
end

function mttAward:createTableView()
	-- dump(self.curData)
	local tableView_w = self.tableBg:getContentSize().width-20
	local tableView_h = self.tableBg:getContentSize().height-280

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
		if cellItem == nil then
			cellItem = cc.TableViewCell:new()
			-- 创建函数
			for i=1,3 do
				label[i] = UIUtil.addLabelArial("", 30, cc.p(tableView_w*(2*i-1)/(2*3), 30), cc.p(0.5, 0.5), cellItem)
				label[i]:setTag(i)
			end
		else
			-- 修改函数
			local tmp = self.curData[index]
			local data = {tmp["awardNum"], tostring(tmp["awardScale"]).."%", tmp["score"]}
			for i=1,3 do
				label[i] = cellItem:getChildByTag(i)
				if label[i] ~= nil then
					label[i]:setString(data[i])
				end
			end
		end
		return cellItem
	end

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

return mttAward