local ViewBase = require("ui.ViewBase")
local MttCheckList = class("MttCheckList", ViewBase)

local _mttCheckList = nil

local manageInfo = {}
local curTableView = nil
local curData = {}

local function Callback(  )
	_mttCheckList:removeFromParent()
end

function MttCheckList:buildLayer(  )
	UIUtil.addTopBar({backFunc = Callback, title = "授权通过", parent = self})
	local imageView = UIUtil.addImageView({image=ResLib.MTT_BG, touch=false, scale=true, size=cc.size(display.width, display.height-130), pos=cc.p(0,0), parent=self})

	local viewH = display.height-130

	local clubName = UIUtil.addLabelArial(manageInfo.clubName, 36, cc.p(display.width/2, viewH-50), cc.p(0.5, 0.5), self)
	local point1 = UIUtil.addPosSprite("common/icon_point.png", cc.p(clubName:getPositionX()-clubName:getContentSize().width/2-10, clubName:getPositionY()), self, cc.p(1, 0.5))
	local line1 = UIUtil.addPosSprite("common/icon_line.png", cc.p(point1:getPositionX()-point1:getContentSize().width-10, clubName:getPositionY()), self, cc.p(1, 0.5))
	local scaleX = (point1:getPositionX()-point1:getContentSize().width-10-10)/line1:getContentSize().width
	line1:setScaleX(scaleX)

	local point2 = UIUtil.addPosSprite("common/icon_point.png", cc.p(clubName:getPositionX()+clubName:getContentSize().width/2+10, clubName:getPositionY()), self, cc.p(1, 0.5))
	point2:setRotation(180)
	local line2 = UIUtil.addPosSprite("common/icon_line.png", cc.p(point2:getPositionX()+point1:getContentSize().width+10, clubName:getPositionY()), self, cc.p(0, 0.5))
	line2:setScaleX(scaleX)

	local function callFunc( ... )
		local items = {{name=manageInfo.manager_no, id = 1}}
		local obj = {
		                ['title'] = nil, 
		                ['items'] = items, 
		                ['confirmFuc'] = function(index) print("items的索引:"..index) end
		               }
		require("ui.UITextPicker").show(self, obj)
	end
	local playBg = UIUtil.addImageBtn({norImg = "common/com_mttTime_bg.png", selImg = "common/com_mttTime_bg.png", disImg = "common/com_mttTime_bg.png", ah =cc.p(0.5, 0.5), pos = cc.p(display.width/2, viewH-140), listener = callFunc, parent = self})
	UIUtil.addLabelArial(manageInfo.manager_no, 30, cc.p(20, playBg:getContentSize().height/2), cc.p(0, 0.5), playBg)
	local sp_down = UIUtil.addPosSprite("common/set_card_MTT_play_icon.png", cc.p(playBg:getContentSize().width-20, playBg:getContentSize().height/2), playBg, cc.p(1, 0.5))
	UIUtil.addLabelArial("选择管理员ID", 30, cc.p(sp_down:getPositionX()-sp_down:getContentSize().width-20, playBg:getContentSize().height/2), cc.p(1, 0.5), playBg)

	local text = {"授权总人数", "授权总人次", "总报名费"}
	local value = {manageInfo.access_num, manageInfo.access_times_r, manageInfo.sum_entry_fee}
	local textLabel = {}
	for i=1,#text do
		local str = text[i]..": "..value[i]
		-- print("str: ", str)
		textLabel[i] = UIUtil.addLabelArial(text[i]..":"..value[i], 30, cc.p(20, (viewH-190)-(i*40)), cc.p(0, 0.5), self)
		if i == 2 then
			if tonumber(manageInfo.access_times_a) > 0 then
				str = text[i]..": "..value[i].."+"..manageInfo.access_times_a
				textLabel[i]:setString(str)
				local addOnIcon = UIUtil.addPosSprite("common/card_mtt_bind_addbuy_icon.png", cc.p(textLabel[2]:getPositionX()+textLabel[i]:getContentSize().width+10, textLabel[i]:getPositionY()), self, cc.p(0, 0.5))
			end
		end
		UIUtil.addLabelArial("(根据选择的管理员ID随之改变)", 20, cc.p(display.width-20, (viewH-190)-(i*40)), cc.p(1, 0.5), self):setColor(ResLib.COLOR_GREY)
	end

	local spBg = UIUtil.addImageView({image = "common/com_mtt_bind_bg.png", touch=false, scale=true, size=cc.size(display.width, 90), pos=cc.p(display.width/2, viewH-350), ah =cc.p(0.5, 1), parent=self})
	local title = {"玩家", "管理员ID", "报名费"}

	for i=1,#title do
		UIUtil.addLabelArial(title[i], 32, cc.p(spBg:getContentSize().width*(2*i-1)/6, spBg:getContentSize().height/2), cc.p(0.5, 0.5), spBg)
	end

	if manageInfo.players[1] ~= "" then
		for k,v in pairs(manageInfo.players) do
			local tab = {}
			tab = v
			tab["manager_no"] = manageInfo.manager_no
			curData[#curData+1] = tab 
		end
	end
	dump(curData)
	curTableView = self:createTableView(viewH-(350+90))

end

function MttCheckList:createTableView( posH )
	local function tableCellTouched( tableViewSender, tableCell )
		local idx = tableCell:getIdx()+1
	end

	local function cellSizeForTable( tableViewSender, cellIndex )
		return 0, 102
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

		self:updateCellTmpl(cellItem, index)
		return cellItem
	end

	local tableView = cc.TableView:create(cc.size(display.width, posH))
	tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
	tableView:setPosition(cc.p(0,0))
	self:addChild(tableView)
	tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
	tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
	tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
	tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
	tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
	tableView:setDelegate()
	tableView:reloadData()

	return tableView
end

function MttCheckList:buildCellTmpl(cellItem )
	local girdNodes = {}
	girdNodes = cellItem
	local cellBg = UIUtil.addImageView({image = "common/card_mtt_des_bg.png", touch=false, scale=true, size=cc.size(display.width, 100),pos=cc.p(0,0), ah=cc.p(0,0), parent=cellItem})
	local width = cellBg:getContentSize().width
	local height = cellBg:getContentSize().height
	-- 名称
	local label1 = UIUtil.addLabelArial('aaa', 30, cc.p(20, height/2), cc.p(0, 0.5), cellBg)
	girdNodes.label1 = label1

	-- 管理员ID
	local label2 = UIUtil.addLabelArial('10/20', 30, cc.p(width/2, height/2), cc.p(0.5, 0.5), cellBg)
	girdNodes.label2 = label2

	-- 记分牌
	local label3 = UIUtil.addLabelArial('10', 30, cc.p(width*5/6, height/2), cc.p(0.5, 0.5), cellBg)
	girdNodes.label3 = label3

	-- 重购
	local reBuyIcon = UIUtil.addPosSprite("common/card_mtt_rebuy_num.png", cc.p(width/4+30, height/2), cellBg, cc.p(0, 0.5))
	girdNodes.reBuyIcon = reBuyIcon
	local reBuyNum = UIUtil.addLabelArial('1', 15, cc.p(reBuyIcon:getContentSize().width/2+5, reBuyIcon:getContentSize().height/2+3), cc.p(0, 1), reBuyIcon):setColor(display.COLOR_BLACK)
	girdNodes.reBuyNum = reBuyNum

	-- 增购
	local addOnIcon = UIUtil.addPosSprite("common/card_mtt_bind_addbuy_icon.png", cc.p(width/4+30, height/2), cellBg, cc.p(0, 0.5))
	girdNodes.addOnIcon = addOnIcon

end

function MttCheckList:updateCellTmpl(cellItem, cellIndex )
	local girdNodes = cellItem
	local data = curData[cellIndex]
	
	girdNodes.label1:setString(data.user_name)
	girdNodes.label2:setString(data.manager_no)
	girdNodes.label3:setString(data.get_back)

	-- 重购
	if tonumber(data.r_num) ~= 0 then
		girdNodes.reBuyIcon:setVisible(true)
		girdNodes.reBuyNum:setString(data.r_num)
		girdNodes.reBuyNum:setPositionX(girdNodes.reBuyIcon:getContentSize().width/2+5)
		girdNodes.reBuyIcon:setPositionX(girdNodes.label1:getPositionX()+girdNodes.label1:getContentSize().width+10)
	else
		girdNodes.reBuyIcon:setVisible(false)
		girdNodes.reBuyNum:setString("")
	end

	-- 增购
	if tonumber(data.a_num) ~= 0 then
		girdNodes.addOnIcon:setVisible(true)
		if girdNodes.reBuyIcon:isVisible() then
			girdNodes.addOnIcon:setPositionX(girdNodes.reBuyIcon:getPositionX()+girdNodes.reBuyIcon:getContentSize().width+10)
		else
			girdNodes.addOnIcon:setPositionX(girdNodes.label1:getPositionX()+girdNodes.label1:getContentSize().width+10)
		end
	else
		girdNodes.addOnIcon:setVisible(false)
	end
end

function MttCheckList:createLayer( data, clubName )
	_mttCheckList = self
	_mttCheckList:setSwallowTouches()

	UIUtil.setBgScale(ResLib.MAIN_BG, display.center, self)
	manageInfo = data
	manageInfo["clubName"] = clubName

	curTableView = nil
	curData = {}
	self:buildLayer()
end

return MttCheckList