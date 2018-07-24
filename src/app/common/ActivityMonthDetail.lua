local ViewBase = require("ui.ViewBase")
local ActivityMonthDetail = class("ActivityMonthDetail", ViewBase)
local ActivityCtorl = require("common.ActivityCtorl")


local _actMonthDetail = nil

local curData = {}
local curTableView = nil
local ActivityType = nil

local month = nil

local function Callback(  )
	_actMonthDetail:removeFromParent()
end

function ActivityMonthDetail:buildLayer(  )

	local titleStr = ""

	if ActivityType then
		titleStr = "俱乐部"
		curData = ActivityCtorl.getClubMonthList()
	else
		titleStr = "联盟"
		curData = ActivityCtorl.getUnionMonthList(  )
	end
	
	local _month = ActivityCtorl.getYearMonth( month )
	-- addTopBar
	UIUtil.addTopBar({backFunc = Callback, title = _month.."月份"..titleStr.."活跃统计", parent = self})

	dump(curData)
	if #curData ~= 0 then
		curTableView = self:createTableView()
		curTableView:reloadData()
	end
end

function ActivityMonthDetail:createTableView(  )
	local offset = nil
	local unfold = nil
	local function tableCellTouched( tableViewSender, tableCell )
		local idx = tableCell:getIdx()+1
		local data = curData[idx]
		if data.infoType == 1 then
			local tmpTab = {}
			if ActivityType then
			 	tmpTab = ActivityCtorl.getClubMonthList_d( data.key )
			 else
			 	tmpTab = ActivityCtorl.getUnionMonthList_d( data.key )
			 end 
	
			dump(tmpTab)
			if next(tmpTab) == nil then
				return
			end
			-- 展开
			if data.unfold == 0 then
				curData[idx].unfold = 1
				unfold = true
				offset = curTableView:getContentOffset()
				for i,v in ipairs(tmpTab) do
					table.insert(curData, idx+i, v)
				end
			-- 收缩
			elseif data.unfold == 1 then
				curData[idx].unfold = 0
				unfold = true
				offset = curTableView:getContentOffset()
				local tmpTab = curData
				curData = {}
				for k,v in pairs(tmpTab) do
					if v.infoType ~= 2 then
						v.unfold = 0
						curData[#curData+1] = v
					end
				end
			end
			curTableView:reloadData()
			dump(curData)
			-- dump(offset)
			if idx > 4 then
				if unfold then
					curTableView:setContentOffset(offset)
				end
			end
		end
	end

	local function cellSizeForTable( tableViewSender, cellIndex )
		local idx = cellIndex+1
		local data = curData[idx]
		if data.infoType == 1 then
			if data.first == 1 then
				return 0, data.cellHeight+67
			else
				return 0, data.cellHeight
			end
		elseif data.infoType == 0 or data.infoType == 2 then
			return 0, data.cellHeight
		end
	end

	local function numberOfCellsInTableView( tableViewSender )
		--print('numberOfCellsInTableView')
		return #curData
	end

	local function tableCellAtIndex( tableViewSender, cellIndex )
		--print('tableCellAtIndex')
		local index = cellIndex + 1
		local cellItem = tableViewSender:dequeueCell()
		if cellItem == nil then
			cellItem = cc.TableViewCell:new()
			-- 创建函数
			self:buildCellTmpl( cellItem )

		end
		self:updateCellTmpl( cellItem, index )
		-- 修改函数
		return cellItem
	end

	local imageView = UIUtil.addImageView({image = ResLib.TABLEVIEW_BG, touch=false, scale=true, size=cc.size(display.width, display.height-130), pos=cc.p(0,0), parent=self})

	local tableView = cc.TableView:create( cc.size(display.width, imageView:getContentSize().height))
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

function ActivityMonthDetail:buildCellTmpl( cellItem )
	local girdNodes = {}
	girdNodes = cellItem

	local cellBg1 = UIUtil.addImageView({image=ResLib.TABLEVIEW_CELL_BG, touch=false, scale=true, size=cc.size(display.width, 130), pos=cc.p(0,0), ah=cc.p(0,0), parent=cellItem})
	local width1 = cellBg1:getContentSize().width
	local height1 = cellBg1:getContentSize().height
	girdNodes.cellBg1 = cellBg1

	local cellBg = UIUtil.addImageView({image=ResLib.TABLEVIEW_CELL_BG, touch=false, scale=true, size=cc.size(display.width, 250), pos=cc.p(0,0), ah=cc.p(0,0), parent=cellItem})
	local width = cellBg:getContentSize().width
	local height = cellBg:getContentSize().height
	girdNodes.cellBg = cellBg

	local monthLabel = UIUtil.addLabelArial('9月份', 30, cc.p(25, height1/2), cc.p(0, 0.5), cellBg1):setColor(ResLib.COLOR_GREY)
	girdNodes.monthLabel = monthLabel

	local allLabel = UIUtil.addLabelArial('所有成员', 30, cc.p(monthLabel:getPositionX()+monthLabel:getContentSize().width+20, height1/2), cc.p(0, 0.5), cellBg1):setColor(ResLib.COLOR_BLUE)
	girdNodes.allLabel = allLabel

	local totalLabel = UIUtil.addLabelArial('整体非赛场总带入量:', 25, cc.p(allLabel:getPositionX()+allLabel:getContentSize().width+10, height1/2), cc.p(0, 0.5), cellBg1):setColor(ResLib.COLOR_GREY)
	girdNodes.totalLabel = totalLabel

	local textBg = UIUtil.addImageView({image = ResLib.TABLEVIEW_TEXT_LINE, touch=false, scale=true, size=cc.size(display.width, 64),pos=cc.p(display.width/2, 250), ah=cc.p(0.5,0), parent=cellItem})
	girdNodes.textBg = textBg

	local textFrom = UIUtil.addLabelArial('俱乐部内', 30, cc.p(textBg:getContentSize().width/2, textBg:getContentSize().height/2), cc.p(0.5, 0.5), textBg)
	girdNodes.textFrom = textFrom

	------------
	local sheetNode = UIUtil.addImageView({image=ResLib.COM_OPACITY0, touch=false, scale=true, size=cc.size(display.width, 600), pos=cc.p(0, 0), ah=cc.p(0,0), parent=cellBg})
	girdNodes.sheetNode = sheetNode
	------------
	local title = {"总带入量", "总表情消耗", "总发发看消耗", "总钻石消耗", "总保险记分牌统计"}
	girdNodes.titleLabel = {}
	girdNodes.scoreStr = {}
	for i=1,5 do
		girdNodes.titleLabel[i] = UIUtil.addLabelArial(title[i], 25, cc.p(25, height-i*42), cc.p(0, 0), cellBg):setColor(cc.c3b(170, 170, 170))
		
		girdNodes.scoreStr[i] = UIUtil.addLabelArial('122334', 25, cc.p(width-250, height-i*42), cc.p(0.5, 0), cellBg):setColor(ResLib.COLOR_GREY)
	end
	local secureSp = UIUtil.addPosSprite("common/com_safe_icon.png", cc.p(0,0), cellBg, cc.p(0,0))
	girdNodes.secureSp = secureSp

	local diamondSp = UIUtil.addPosSprite("user/icon_zhuanshi.png", cc.p(0,0), cellBg, cc.p(0,0))
	girdNodes.diamondSp = diamondSp

	local iconVertical = UIUtil.addPosSprite("club/activity_icon_vertical.png", cc.p(width-150, height/2), cellBg, cc.p(0, 0.5))
	girdNodes.iconVertical = iconVertical

	local iconArrow = UIUtil.addPosSprite("club/activity_arow_down.png", cc.p(width-100, height/2), cellBg, cc.p(0, 0.5))
	girdNodes.iconArrow = iconArrow

end

function ActivityMonthDetail:updateCellTmpl( cellItem, cellIndex )
	local girdNodes = cellItem
	local data = curData[cellIndex]

	if data.infoType == 0 then
		girdNodes.cellBg1:setVisible(true)
		girdNodes.cellBg:setVisible(false)
		girdNodes.textBg:setVisible(false)
		local month = ActivityCtorl.getYearMonth( data.month )
		girdNodes.monthLabel:setString(month.."月份")
		girdNodes.monthLabel:setPosition(cc.p( 60, data.cellHeight/2))
		if ActivityType then
			girdNodes.allLabel:setString("所有成员")
		else
			girdNodes.allLabel:setString("所有俱乐部")
		end
		girdNodes.allLabel:setPosition(girdNodes.monthLabel:getPositionX()+girdNodes.monthLabel:getContentSize().width+10, data.cellHeight/2)
		girdNodes.totalLabel:setString("整体非赛场总带入量:"..data.month_total)
		girdNodes.totalLabel:setPosition(girdNodes.allLabel:getPositionX()+girdNodes.allLabel:getContentSize().width+10, data.cellHeight/2)
	elseif data.infoType == 1 then
		girdNodes.cellBg1:setVisible(false)
		girdNodes.cellBg:setVisible(true)
		girdNodes.sheetNode:setVisible(false)
		girdNodes.cellBg:setContentSize(cc.size(display.width, data.cellHeight))
		girdNodes.cellBg:loadTexture("club/activity_cell_bg_grey0.png")
		if data.first == 1 then
			girdNodes.textBg:setVisible(true)
			girdNodes.textBg:setPositionY(data.cellHeight+3)
			girdNodes.textFrom:setString(data.topTitle)
			girdNodes.textFrom:setColor(data.color)
		else
			girdNodes.textBg:setVisible(false)
		end
		if data.key == "act_hall_free" then
			girdNodes.titleLabel[1]:setString(data.title)
		else
			if data.title then
				girdNodes.titleLabel[1]:setString(data.title.."总带入量")
			else
				girdNodes.titleLabel[1]:setString("总带入量")
			end
		end
		girdNodes.iconVertical:setVisible(true)
		girdNodes.iconVertical:setPositionY(data.cellHeight/2)
		girdNodes.iconArrow:setVisible(true)
		girdNodes.iconArrow:setPositionY(data.cellHeight/2)
		if data.unfold == 0 then
			girdNodes.iconArrow:setTexture("club/activity_arow_down.png")
		elseif data.unfold == 1 then
			girdNodes.iconArrow:setTexture("club/activity_arow_up.png")
		end
		if data.actType == 5 then
			girdNodes.titleLabel[2]:setString("总表情消耗")
			girdNodes.titleLabel[3]:setString("总钻石消耗")
			girdNodes.titleLabel[4]:setString("")
			girdNodes.titleLabel[5]:setString("")
			girdNodes.scoreStr[1]:setString(data.score_total)
			girdNodes.scoreStr[2]:setString(data.face_total)
			girdNodes.scoreStr[3]:setString(data.diamond_total)
			girdNodes.scoreStr[4]:setString("")
			girdNodes.scoreStr[5]:setString("")
			for i=1,3 do
				girdNodes.titleLabel[i]:setPositionY(data.cellHeight-i*42)
				girdNodes.scoreStr[i]:setPositionY(data.cellHeight-i*42)
			end
			girdNodes.diamondSp:setPosition(girdNodes.titleLabel[3]:getPositionX()+girdNodes.titleLabel[3]:getContentSize().width+10, girdNodes.titleLabel[3]:getPositionY())
		else
			girdNodes.titleLabel[2]:setString("总表情消耗")
			girdNodes.titleLabel[3]:setString("总发发看消耗")
			girdNodes.titleLabel[4]:setString("总钻石消耗")
			girdNodes.titleLabel[5]:setString("总保险记分牌统计")
			-- girdNodes.scoreStr[1]:setString(data.score_total)
			if data.actType ~= 3 then
				girdNodes.scoreStr[1]:setString(data.score_total)
			else
				girdNodes.scoreStr[1]:setString("")
			end
			girdNodes.scoreStr[2]:setString(data.face_total)
			girdNodes.scoreStr[3]:setString(data.look_total)
			girdNodes.scoreStr[4]:setString(data.diamond_total)
			girdNodes.scoreStr[5]:setString(data.secure_total)
			for i=1,5 do
				girdNodes.titleLabel[i]:setPositionY(data.cellHeight-i*42)
				girdNodes.scoreStr[i]:setPositionY(data.cellHeight-i*42)
			end
			girdNodes.diamondSp:setPosition(girdNodes.titleLabel[4]:getPositionX()+girdNodes.titleLabel[4]:getContentSize().width+10, girdNodes.titleLabel[4]:getPositionY())
		end
		girdNodes.secureSp:setVisible(false)
		
	elseif data.infoType == 2 then
		girdNodes.cellBg1:setVisible(false)
		girdNodes.cellBg:setVisible(true)
		girdNodes.cellBg:setContentSize(cc.size(display.width, data.cellHeight))
		girdNodes.cellBg:loadTexture("club/activity_cell_bg_grey1.png")
		girdNodes.textBg:setVisible(false)

		girdNodes.iconVertical:setVisible(false)
		girdNodes.iconArrow:setVisible(false)

		-- girdNodes.titleLabel[1]:setString(data.title.."总带入量")
		-- girdNodes.scoreStr[1]:setString(data.score)
		girdNodes.titleLabel[2]:setString("表情消耗")
		girdNodes.scoreStr[2]:setString(data.face_use)

		if data.mod == "hall_general_standard" or data.mod == "hall_general_standard_secure" then
			girdNodes.sheetNode:setVisible(true)
			girdNodes.sheetNode:setContentSize(cc.size(display.width, 600))
			girdNodes.sheetNode:setPositionY(data.cellHeight-620)
			girdNodes.sheetNode:removeAllChildren()
			self:addSheetNode(600, data.hand_score, data.mod, girdNodes.sheetNode)

			girdNodes.titleLabel[1]:setString("")
			girdNodes.scoreStr[1]:setString("")
			for i=1,5 do
				girdNodes.titleLabel[i]:setPositionY(data.cellHeight-600-i*42)
				girdNodes.scoreStr[i]:setPositionY(data.cellHeight-600-i*42)
			end
		else
			girdNodes.sheetNode:setVisible(false)
			girdNodes.titleLabel[1]:setString(data.title.."总带入量")
			girdNodes.scoreStr[1]:setString(data.score)
			for i=1,5 do
				girdNodes.titleLabel[i]:setPositionY(data.cellHeight-i*42)
				girdNodes.scoreStr[i]:setPositionY(data.cellHeight-i*42)
			end
		end
		
		-- for i=1,5 do
		-- 	girdNodes.titleLabel[i]:setPositionY(data.cellHeight-i*45)
		-- 	girdNodes.scoreStr[i]:setPositionY(data.cellHeight-i*45)
		-- end
		if data.look_secure == 2 then
			girdNodes.titleLabel[3]:setString("发发看消耗")
			girdNodes.titleLabel[4]:setString("钻石消耗")
			girdNodes.titleLabel[5]:setString("保险记分牌统计")
			girdNodes.scoreStr[3]:setString(data.look_use)
			girdNodes.scoreStr[4]:setString(data.diamond_use)
			local secureNum  = tonumber(data["secure_use"]) or 0
			if secureNum > 0 then
				secureNum = "+"..secureNum
			end
			girdNodes.scoreStr[5]:setString(secureNum)
			girdNodes.secureSp:setVisible(true)
			girdNodes.secureSp:setPosition(girdNodes.titleLabel[1]:getContentSize().width+girdNodes.titleLabel[1]:getPositionX()+10, girdNodes.titleLabel[1]:getPositionY())
			if data.mod == "hall_general_standard_secure" then
				girdNodes.secureSp:setVisible(false)
			end

			girdNodes.diamondSp:setPosition(girdNodes.titleLabel[4]:getPositionX()+girdNodes.titleLabel[4]:getContentSize().width+10, girdNodes.titleLabel[4]:getPositionY())
		elseif data.look_secure == 1 then
			girdNodes.titleLabel[3]:setString("发发看消耗")
			girdNodes.titleLabel[4]:setString("钻石消耗")
			girdNodes.titleLabel[5]:setString("")
			girdNodes.scoreStr[3]:setString(data.look_use)
			girdNodes.scoreStr[4]:setString(data.diamond_use)
			girdNodes.scoreStr[5]:setString("")
			girdNodes.secureSp:setVisible(false)
			girdNodes.diamondSp:setPosition(girdNodes.titleLabel[4]:getPositionX()+girdNodes.titleLabel[4]:getContentSize().width+10, girdNodes.titleLabel[4]:getPositionY())
		elseif data.look_secure == 0 then
			girdNodes.titleLabel[3]:setString("钻石消耗")
			girdNodes.titleLabel[4]:setString("")
			girdNodes.titleLabel[5]:setString("")
			girdNodes.scoreStr[3]:setString(data.diamond_use)
			girdNodes.scoreStr[4]:setString("")
			girdNodes.scoreStr[5]:setString("")
			girdNodes.secureSp:setVisible(false)
			girdNodes.diamondSp:setPosition(girdNodes.titleLabel[3]:getPositionX()+girdNodes.titleLabel[3]:getContentSize().width+10, girdNodes.titleLabel[3]:getPositionY())
		end
	end

end

function ActivityMonthDetail:addSheetNode( sheetH, handData, mod, parent )
	local girdNodes = {}
	dump(handData)
	-- 列
	local acrNum = 3
	-- 行
	local verNum = 12

	local width = display.width
	local sheetNode = parent

	girdNodes.verLine = {}
	girdNodes.acrLine = {}

	local title = {}
	if mod == "hall_general_standard" then
		title = {"标准模式", "带入量", "总手数"}
	elseif mod == "hall_general_standard_secure" then
		title = {"保险模式", "带入量", "总手数"}
	end

	for i=1,acrNum+1 do
		girdNodes.verLine[i] = UIUtil.addImageView({image = "club/activity_icon_vertical.png", touch=false, scale=true, size=cc.size(1, verNum*50),pos=cc.p(25+(i-1)*((width-50)/3), 0), ah=cc.p(0,0), parent=sheetNode})
	end
	for i=1,verNum+1 do
		girdNodes.acrLine[i] = UIUtil.addImageView({image = "club/activity_icon_ across.png", touch=false, scale=true, size=cc.size(width-50, 1),pos=cc.p(display.width/2, (i-1)*50), ah=cc.p(0.5,0), parent=sheetNode})
	end
	
	girdNodes.actTitle = {}
	girdNodes.actScore = {}
	girdNodes.actHand  = {}
	local sheetHight = sheetH - 25
	for i=1,acrNum do
		for j=1,verNum do
			if i == 1 then
				if j == 1 then
					girdNodes.actTitle[j] = UIUtil.addLabelArial(title[i], 30, cc.p((width-50)*(2*i-1)/6, sheetHight-(j-1)*50), cc.p(0.5, 0.5), sheetNode):setColor(ResLib.COLOR_GREY)
					if mod == "hall_general_standard_secure" then
						UIUtil.addPosSprite("common/com_safe_icon.png", cc.p(girdNodes.actTitle[j]:getPositionX()+girdNodes.actTitle[1]:getContentSize().width/2+5, girdNodes.actTitle[j]:getPositionY()), sheetNode, cc.p(0,0.5))
					end
				else
					girdNodes.actTitle[j] = UIUtil.addLabelArial(title[i], 25, cc.p((width-50)*(2*i-1)/6, sheetHight-(j-1)*50), cc.p(0.5, 0.5), sheetNode)
				end
			elseif i == 2 then
				if j == 1 then
					girdNodes.actScore[j] = UIUtil.addLabelArial(title[i], 30, cc.p((width-50)*(2*i-1)/6, sheetHight-(j-1)*50), cc.p(0.5, 0.5), sheetNode):setColor(ResLib.COLOR_GREY)
				else
					girdNodes.actScore[j] = UIUtil.addLabelArial(handData[tostring(j-1)].entry_fee, 25, cc.p((width-50)*(2*i-1)/6, sheetHight-(j-1)*50), cc.p(0.5, 0.5), sheetNode)
				end
			elseif i == 3 then
				if j == 1 then
					girdNodes.actHand[j] = UIUtil.addLabelArial(title[i], 30, cc.p((width-50)*(2*i-1)/6, sheetHight-(j-1)*50), cc.p(0.5, 0.5), sheetNode):setColor(ResLib.COLOR_GREY)
				else
					girdNodes.actHand[j] = UIUtil.addLabelArial(handData[tostring(j-1)].hand_num, 25, cc.p((width-50)*(2*i-1)/6, sheetHight-(j-1)*50), cc.p(0.5, 0.5), sheetNode)
				end
			end
		end
	end
end

function ActivityMonthDetail:createLayer( _month )
	_actMonthDetail = self
	_actMonthDetail:setSwallowTouches()
	UIUtil.setBgScale(ResLib.MAIN_BG, display.center, self)

	curData = {}
	curTableView = nil

	month = _month

	ActivityType = nil
	ActivityType = ActivityCtorl.isActFlag()

	self:buildLayer()
end

return ActivityMonthDetail