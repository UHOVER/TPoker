local ViewBase = require("ui.ViewBase")
local ActivityMonthTotal = class("ActivityMonthTotal", ViewBase)
local ActivityCtorl = require("common.ActivityCtorl")


local _actMonthTotal = nil

local monthData = {}

local curData = {}
local curTableView = nil

local ActivityType = nil

local function Callback(  )
	_actMonthTotal:removeFromParent()
end

local function monthTotalFunc(  )
	ActivityCtorl.dataStatGroupMonthDetail(monthData, function (  )
		local ActivityMonthDetail = require("common.ActivityMonthDetail")
		local layer = ActivityMonthDetail:create()
		_actMonthTotal:addChild(layer)
		layer:createLayer(monthData.month)
	end)
end

function ActivityMonthTotal:buildLayer(  )

	local titleStr = ""
	local actType = ""
	if ActivityType then
		titleStr = "俱乐部活跃统计"
		actType = "所有成员"
	else
		titleStr = "联盟活跃统计"
		actType = "所有俱乐部"
	end

	-- addTopBar
	UIUtil.addTopBar({backFunc = Callback, title = titleStr, parent = self})

	local imageBg = UIUtil.addImageView({image = ResLib.TABLEVIEW_BG, touch=false, scale=true, size=cc.size(display.width, 170), ah = cc.p(0, 0), pos=cc.p(0,display.height-300), parent=self})

	local width = imageBg:getContentSize().width
	local height = imageBg:getContentSize().height
	local month = ActivityCtorl.getYearMonth( monthData.month )
	local monthLabel = UIUtil.addLabelArial(month.."月份"..actType.."整体活跃统计", 30, cc.p(50, height-50), cc.p(0, 0.5), imageBg)
	-- local scoreStr = UIUtil.addLabelArial(monthData.scoressum, 30, cc.p(monthLabel:getPositionX()+monthLabel:getContentSize().width+10, height-50), cc.p(0, 0.5), imageBg)

	local rightBtn = UIUtil.addImageBtn({norImg = ResLib.COM_OPACITY0, selImg = ResLib.COM_OPACITY0, disImg = ResLib.COM_OPACITY0, ah = cc.p(0,0), pos = cc.p(0, 70), touch = true, swalTouch = false, scale9 = true, size = cc.size(display.width, 100), listener = monthTotalFunc, parent = imageBg})
	UIUtil.addPosSprite(ResLib.BTN_BACK_RIGHT, cc.p(rightBtn:getContentSize().width-180, rightBtn:getContentSize().height/2), rightBtn, cc.p(0, 0.5))

	local textBg = UIUtil.addImageView({image = ResLib.TABLEVIEW_TEXT_LINE, touch=false, scale=true, size=cc.size(display.width, 70),pos=cc.p(display.width/2, 0), ah=cc.p(0.5,0), parent=imageBg})

	local text = UIUtil.addLabelArial('成员列表', 30, cc.p(100, textBg:getContentSize().height/2), cc.p(0.5, 0.5), textBg):setColor(ResLib.COLOR_GREY)

	-- local text = UIUtil.addLabelArial('带入量', 30, cc.p(width-180, textBg:getContentSize().height/2), cc.p(0, 0.5), textBg):setColor(ResLib.COLOR_GREY)

	if #curData ~= 0 then
		curTableView = self:createTableView(  )
		curTableView:reloadData()
	end

end

function ActivityMonthTotal:createTableView(  )
	local function tableCellTouched( tableViewSender, tableCell )
		local idx = tableCell:getIdx()+1
		local tmpTab = {}
		tmpTab["month"] = monthData.month
		tmpTab["group_member_id"] = curData[idx].group_member_id
		tmpTab["headimg"] = curData[idx].headimg
		tmpTab["group_member_name"] = curData[idx].group_member_name
		if curData[idx].union then
			tmpTab["union"] = curData[idx].union
		end
		ActivityCtorl.dataStatGroupMonthDet( tmpTab, function (  )
			local ActivityDetail = require("common.ActivityDetail")
			local layer = ActivityDetail:create()
			_actMonthTotal:addChild(layer)
			layer:createLayer(monthData.month)
		end )		
	end

	local function cellSizeForTable( tableViewSender, cellIndex )
		return 0, 120
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

	local imageView = UIUtil.addImageView({image = ResLib.TABLEVIEW_BG, touch=false, scale=true, size=cc.size(display.width, display.height-300), pos=cc.p(0,0), parent=self})

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

function ActivityMonthTotal:buildCellTmpl( cellItem )
	local girdNodes = {}
	girdNodes = cellItem

	local cellBg = UIUtil.addImageView({image=ResLib.TABLEVIEW_CELL_BG_NOLINE, touch=false, scale=true, size=cc.size(display.width, 120), pos=cc.p(0,0), ah=cc.p(0,0), parent=cellItem})
	local width = cellBg:getContentSize().width
	local height = cellBg:getContentSize().height

	UIUtil.addImageView({image="club/activity_icon_vertical.png", touch=false, scale=true, size=cc.size(3, height/2-20), pos=cc.p(100, height/2+20), ah=cc.p(0.5,0), parent=cellBg})
	UIUtil.addImageView({image="club/activity_icon_vertical.png", touch=false, scale=true, size=cc.size(3, height/2-20), pos=cc.p(100, height/2-20), ah=cc.p(0.5,1), parent=cellBg})

	local circleIcon = UIUtil.addPosSprite("club/activity_icon_circle.png", cc.p(100, height/2), cellBg, cc.p(0.5, 0.5))

	local num = UIUtil.addLabelArial('1', 20, cc.p(circleIcon:getContentSize().width/2, circleIcon:getContentSize().height/2), cc.p(0.5, 0.5), circleIcon):setColor(display.COLOR_BLACK)
	girdNodes.num = num

	local head_icon = nil
	if ActivityType then
		head_icon = ResLib.USER_HEAD
	else
		head_icon = ResLib.CLUB_HEAD_GENERAL
	end

	-- 头像
	local stencil, Icon = UIUtil.createCircle(head_icon, cc.p(190,height/2), cellBg, ResLib.CLUB_HEAD_STENCIL_200)
	girdNodes.stencil = stencil
	girdNodes.Icon = Icon

	local exitIcon = UIUtil.addPosSprite("club/activity_icon_exit.png", cc.p(190, height/2), cellBg, cc.p(0.5, 0.5))
	girdNodes.exitIcon = exitIcon

	local exitTime = UIUtil.addLabelArial('', 22, cc.p(exitIcon:getContentSize().width/2, exitIcon:getContentSize().height/3-5), cc.p(0.5, 0.5), exitIcon):setColor(ResLib.COLOR_BLUE)
	girdNodes.exitTime = exitTime

	local nameLabel = UIUtil.addLabelArial('姓名', 30, cc.p(260, height/2), cc.p(0, 0.5), cellBg):setColor(ResLib.COLOR_GREY)
	girdNodes.nameLabel = nameLabel

	local clubName, club_icon = UIUtil.addNameByType({nameType = 1, nameStr = "俱乐部", fontSize = 30, pos = cc.p(260, height/2), parent = cellBg})
	girdNodes.clubName = clubName
	girdNodes.club_icon = club_icon

	local actIcon = UIUtil.addPosSprite(ResLib.BTN_BACK_RIGHT, cc.p(width-180, height/2), cellBg, cc.p(0, 0.5))
	
	-- local scoreStr = UIUtil.addLabelArial('60000', 30, cc.p(width-180, height/2), cc.p(0, 0.5), cellBg):setColor(ResLib.COLOR_GREY)
	-- girdNodes.scoreStr = scoreStr

end

function ActivityMonthTotal:updateCellTmpl( cellItem, cellIndex )
	local girdNodes = cellItem
	local data = curData[cellIndex]

	girdNodes.num:setString(cellIndex)

	local url = ""
	if ActivityType then
		girdNodes.clubName:setVisible(false)
		girdNodes.club_icon:setVisible(false)
		girdNodes.nameLabel:setVisible(true)
		girdNodes.nameLabel:setString(data.group_member_name)

		url = data.headimg
	else
		girdNodes.nameLabel:setVisible(false)
		girdNodes.clubName:setVisible(true)
		girdNodes.club_icon:setVisible(true)
		girdNodes.clubName:setString(data.group_member_name)
		if tonumber(data.union) == 0 then
			UIUtil.updateNameByType( 1, girdNodes.clubName, girdNodes.club_icon )
			girdNodes.Icon:setTexture(ResLib.CLUB_HEAD_GENERAL)
		else
			UIUtil.updateNameByType( 2, girdNodes.clubName, girdNodes.club_icon )
			girdNodes.Icon:setTexture(ResLib.CLUB_HEAD_ORIGIN)
		end
		
		url = data.headimg
	end

	-- girdNodes.scoreStr:setString(data.p_scores)
	
	local function funcBack( path )
		local rect = girdNodes.stencil:getContentSize()
		girdNodes.Icon:setTexture(path)
		girdNodes.Icon:setTextureRect(rect)
	end
	if url ~= "" then
		ClubModel.downloadPhoto(funcBack, url, true)
	end

	if data.is_exit then
		girdNodes.exitIcon:setVisible(false)
		girdNodes.exitTime:setString("")
	else
		girdNodes.exitIcon:setVisible(true)
		local time = os.date("%m/%d",data.exittime)
		girdNodes.exitTime:setString(time)
	end
	
end

function ActivityMonthTotal:createLayer( month_tab, mber_tab )
	_actMonthTotal = self
	_actMonthTotal:setSwallowTouches()
	UIUtil.setBgScale(ResLib.MAIN_BG, display.center, self)

	monthData = {}
	monthData = month_tab

	curData = {}
	curData = mber_tab.group_members
	curTableView = nil

	ActivityType = nil
	ActivityType = ActivityCtorl.isActFlag()

	self:buildLayer()

end

return ActivityMonthTotal