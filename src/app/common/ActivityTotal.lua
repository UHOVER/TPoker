local ViewBase = require("ui.ViewBase")
local ActivityTotal = class("ActivityTotal", ViewBase)
local ActivityCtorl = require("common.ActivityCtorl")

local ClubCtrol = require("club.ClubCtrol")
local _activityTotal = nil

local color = {}

local clubActData = {}

local actData = {}
local curData = {}
local curTableView = nil

local ActivityType = nil

local function Callback(  )
	_activityTotal:removeTransitAction()
end

function ActivityTotal:buildLayer(  )

	color["YELLOW"] = cc.c3b(218, 222, 110)
	color["GREY1"] = cc.c3b(74, 74, 74)
	color["GREY2"] = cc.c3b(143, 143, 153)

	-- addTopBar
	UIUtil.addTopBar({backFunc = Callback, title = "活跃统计", parent = self})

	-- tableview
	if ActivityType then
		self:buildClubData()
	else
		self:buildUnionData()
	end
end

function ActivityTotal:buildClubData(  )
	actData = ActivityCtorl.getClubActData()
	dump(actData)

	curData = actData.clubAct

	dump(curData)
	self:addTotalNode(actData.club_info)
	curTableView = self:createTableView()
end

function ActivityTotal:buildUnionData(  )
	actData = ActivityCtorl.getUnionActData()
	dump(actData)

	curData = actData.unionAct
	dump(curData)

	self:addTotalNode(actData.union_info)
	curTableView = self:createTableView()
end

function ActivityTotal:addTotalNode( actInfo )
	local imageBg = UIUtil.addImageView({image = ResLib.TABLEVIEW_BG, touch=false, scale=true, size=cc.size(display.width, 300), ah = cc.p(0, 1), pos=cc.p(0,display.height-130), parent=self})

	local width = imageBg:getContentSize().width
	local height = imageBg:getContentSize().height
	
	-- 头像
	local head_url = nil
	local name_type = 1
	local small_icon = nil
	if ActivityType then
		if tonumber(actInfo.union) == 0 then
			head_url = ResLib.CLUB_HEAD_GENERAL
			name_type = 1
		else
			head_url = ResLib.CLUB_HEAD_ORIGIN
			name_type = 2
		end
		
		small_icon = "club/icon_user_blue.png"
	else
		head_url = ResLib.UNION_HEAD
		name_type = 3
		small_icon = ResLib.CLUB_HEAD_GENERAL_SMALL
	end
	local stencil, Icon = UIUtil.createCircle(head_url, cc.p(75,height-80), imageBg, ResLib.CLUB_HEAD_STENCIL_200)
	local url = actInfo.headimg
	local function funcBack( path )
		local rect = stencil:getContentSize()
		Icon:setTexture(path)
		Icon:setTextureRect(rect)
	end
	ClubModel.downloadPhoto(funcBack, url, true)

	local name = UIUtil.addNameByType({nameType = name_type, nameStr = actInfo.name, fontSize = 40, pos = cc.p(150, height-60), parent = imageBg})

	-- 俱乐部总人数/当前人数
	UIUtil.addPosSprite(small_icon, cc.p(150, height-100), imageBg, cc.p(0, 0.5))
	
	local clubCount = UIUtil.addLabelArial("", 25, cc.p(190, height-100), cc.p(0, 0.5), imageBg)
	-- 地区
	local place = ClubCtrol.getNumberOfSite(actInfo.address)
	local clubPlace = UIUtil.addLabelArial(place, 25, cc.p(350, height-100), cc.p(0, 0.5), imageBg)

	local level = UIUtil.addLabelArial("", 30, cc.p(width-160, height-70), cc.p(1, 0.5), imageBg)
	if ActivityType then
		if tonumber(actInfo.union) == 0 then
			level:setString("普通俱乐部")
			level:setColor(cc.c3b(204, 204, 204))
			local count = actInfo.users_count.. "/" .. actInfo.users_limit
			clubCount:setString(count)
			-- local levels = UIUtil.addLabelArial(actInfo["level"].."级", 40, cc.p(level:getPositionX()+5, height-70), cc.p(0, 0.5), imageBg):setColor(ResLib.COLOR_BLUE)
			-- self:buildProgress( actInfo.exp, cc.p(levels:getPositionX()+levels:getContentSize().width+10, height-75), imageBg )
		else
			level:setString("创始")
			level:setSystemFontSize(40)
			level:setColor(ResLib.COLOR_YELLOW)
			local count = actInfo.users_count.. "/无限制"
			clubCount:setString(count)
			local levels = UIUtil.addLabelArial("俱乐部", 30, cc.p(level:getPositionX()+5, height-70), cc.p(0, 0.5), imageBg):setColor(cc.c3b(204, 204, 204))
		end
	else
		level:setString("联盟")
		level:setPositionX(width-25)
		level:setSystemFontSize(40)
		level:setColor(ResLib.COLOR_ORANGE)
		local count = actInfo.card_cout.. "/" .. actInfo.users_limit
		clubCount:setString(count)
	end
	
	local timeLabel = UIUtil.addLabelArial('总牌局时长', 30, cc.p(25, height-150), cc.p(0, 0.5), imageBg):setColor(cc.c3b(170, 170, 170))
	local time = ActivityCtorl.transTime(actInfo.existtimesum)
	local timeCount = UIUtil.addLabelArial(time, 25, cc.p(width-130, height-150), cc.p(0.5, 0.5), imageBg):setColor(color.YELLOW)
	UIUtil.addLabelArial('(俱乐部内部成员参加牌局的总累计时长)', 15, cc.p(timeLabel:getPositionX()+timeLabel:getContentSize().width+10, height-150), cc.p(0, 0.5), imageBg):setColor(color.GREY2)

	local cardLabel = UIUtil.addLabelArial('总牌局数', 30, cc.p(25, height-200), cc.p(0, 0.5), imageBg):setColor(cc.c3b(170, 170, 170))
	local cards = actInfo.card_cout
	local cardCount = UIUtil.addLabelArial(cards, 25, cc.p(width-130, height-200), cc.p(0.5, 0.5), imageBg)
	UIUtil.addLabelArial('(俱乐部内部成员累计参加的总牌局数)', 15, cc.p(cardLabel:getPositionX()+cardLabel:getContentSize().width+10, height-200), cc.p(0, 0.5), imageBg):setColor(color.GREY2)

	local scoreLabel = UIUtil.addLabelArial('非赛场带入量总计', 30, cc.p(25, height-250), cc.p(0, 0.5), imageBg):setColor(cc.c3b(170, 170, 170))
	local scores = actInfo.no_hall_scoressum
	local scoreCount = UIUtil.addLabelArial(scores, 25, cc.p(width-130, height-250), cc.p(0.5, 0.5), imageBg)

end

function ActivityTotal:buildProgress( exp, pos, parent )
	local bg = cc.Scale9Sprite:create(ResLib.LOAD_BAR_BG)
	bg:setAnchorPoint(cc.p(0,0.5))
	bg:setPosition(pos)
	parent:addChild(bg)

	local sprite = cc.Sprite:create(ResLib.LOAD_BAR)

	local progress = cc.ProgressTimer:create(sprite)
	progress:setType(cc.PROGRESS_TIMER_TYPE_BAR)
	progress:setMidpoint(cc.p(0,0))
	progress:setBarChangeRate(cc.p(1,0))
	progress:setAnchorPoint(cc.p(0,0.5))
	progress:setPosition(cc.p(0,bg:getContentSize().height/2))
	local value = (exp.current_score/exp.total_score)*100
	progress:setPercentage(value)
	bg:addChild(progress)
	return progress
end

function ActivityTotal:createTableView(  )
	local offset = nil
	local unfold = nil
	local function tableCellTouched( tableViewSender, tableCell )
		local idx = tableCell:getIdx()+1
		local data = curData[idx]
		if data.menuType == 1 then
			local tmpTab = {}
			if ActivityType then
				tmpTab = ActivityCtorl.getClubAct_Month(  )
			else
				tmpTab = ActivityCtorl.getUnionAct_Month(  )
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
					if v.menuType ~= 2 then
						curData[#curData+1] = v
					end
				end
			end
			curTableView:reloadData()
			if unfold then
				curTableView:setContentOffset(offset)
			end
		elseif data.menuType == 2 then
			ActivityCtorl.dataStatGroupMonthTot( curData[idx].month, function ( memberData )
				local actMonthTotal = require("common.ActivityMonthTotal")
				local layer = actMonthTotal:create()
				_activityTotal:addChild(layer)
				layer:createLayer(curData[idx], memberData )
			end )
		end		
	end

	local function cellSizeForTable( tableViewSender, cellIndex )
		local data = curData[cellIndex+1]
		if data.infoType == 1 then
			if data.first == 1 then
				return 0, data.cellHeight+67
			else
				return 0, data.cellHeight
			end
		else
			return 0, 100
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

	local imageView = UIUtil.addImageView({image = ResLib.TABLEVIEW_BG, touch=false, scale=true, size=cc.size(display.width, display.height-430), pos=cc.p(0,0), parent=self})

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

function ActivityTotal:buildCellTmpl( cellItem )
	local girdNodes = {}
	girdNodes = cellItem

	local cellBg = UIUtil.addImageView({image=ResLib.TABLEVIEW_CELL_BG, touch=false, scale=true, size=cc.size(display.width, 250), pos=cc.p(0,0), ah=cc.p(0,0), parent=cellItem})
	girdNodes.cellBg = cellBg
	local width = cellBg:getContentSize().width
	local height = cellBg:getContentSize().height

	local textBg = UIUtil.addImageView({image = ResLib.TABLEVIEW_TEXT_LINE, touch=false, scale=true, size=cc.size(display.width, 64),pos=cc.p(display.width/2, 255), ah=cc.p(0.5,0), parent=cellItem})
	girdNodes.textBg = textBg

	local textFrom = UIUtil.addLabelArial('俱乐部', 30, cc.p(textBg:getContentSize().width/2, textBg:getContentSize().height/2), cc.p(0.5, 0.5), textBg)
	girdNodes.textFrom = textFrom

	local title = {"总带入量", "总表情消耗", "总发发看消耗", "总钻石消耗", "总保险记分牌统计"}
	girdNodes.titleLabel = {}
	girdNodes.scoreStr = {}
	for i=1,5 do
		girdNodes.titleLabel[i] = UIUtil.addLabelArial(title[i], 30, cc.p(25, height-i*44), cc.p(0, 0), cellBg):setColor(cc.c3b(170, 170, 170))
		
		girdNodes.scoreStr[i] = UIUtil.addLabelArial('122334', 30, cc.p(width-150, height-i*44), cc.p(0.5, 0), cellBg):setColor(ResLib.COLOR_GREY)
	end

	local cellBg1 = UIUtil.addImageView({image=ResLib.TABLEVIEW_CELL_BG, touch=false, scale=true, size=cc.size(display.width, 100), pos=cc.p(0,0), ah=cc.p(0,0), parent=cellItem})
	girdNodes.cellBg1 = cellBg1
	local width1 = cellBg1:getContentSize().width
	local height1 = cellBg1:getContentSize().height

	local text = UIUtil.addLabelArial('', 40, cc.p(width1/2-40, height1/2), cc.p(0.5, 0.5), cellBg1):setColor(display.COLOR_BLACK)
	girdNodes.text = text

	local iconTop = UIUtil.addPosSprite(ResLib.BTN_BACK_RIGHT, cc.p(width1/2, height1), cellBg1, cc.p(0.5, 1))
	girdNodes.iconTop = iconTop

	local textMonth = UIUtil.addLabelArial('', 30, cc.p(30, height1/2), cc.p(0, 0.5), cellBg1)
	girdNodes.textMonth = textMonth

	local iconRight = UIUtil.addPosSprite(ResLib.BTN_BACK_RIGHT, cc.p(width1-150, height1/2), cellBg1, cc.p(0.5, 0.5))
	girdNodes.iconRight = iconRight

end

function ActivityTotal:updateCellTmpl( cellItem, cellIndex )
	local girdNodes = cellItem
	local data = curData[cellIndex]
	if data.infoType == 1 then
		girdNodes.cellBg:setVisible(true)
		girdNodes.cellBg1:setVisible(false)
		girdNodes.cellBg:setContentSize(cc.size(display.width, data.cellHeight))
		if data.first == 1 then
			girdNodes.textBg:setVisible(true)
			girdNodes.textBg:setPositionY(data.cellHeight+5)
			girdNodes.textFrom:setString(data.topTitle)
			girdNodes.textFrom:setColor(data.color)
		else
			girdNodes.textBg:setVisible(false)
		end
		if data.title then
			girdNodes.titleLabel[1]:setString(data.title.."总带入量")
		else
			girdNodes.titleLabel[1]:setString("总带入量")
		end
		if data.actType == 5 then
			girdNodes.titleLabel[2]:setString("总表情消耗")
			girdNodes.titleLabel[3]:setString("总钻石消耗")
			girdNodes.titleLabel[4]:setString("")
			girdNodes.titleLabel[5]:setString("")
			girdNodes.scoreStr[1]:setString(data.chipssum)
			girdNodes.scoreStr[2]:setString(data.phizsum)
			girdNodes.scoreStr[3]:setString(data.diamondsum)
			girdNodes.scoreStr[4]:setString("")
			girdNodes.scoreStr[5]:setString("")
			for i=1,3 do
				girdNodes.titleLabel[i]:setPositionY(data.cellHeight-i*44)
				girdNodes.scoreStr[i]:setPositionY(data.cellHeight-i*44)
			end
		else
			girdNodes.titleLabel[2]:setString("总表情消耗")
			girdNodes.titleLabel[3]:setString("总发发看消耗")
			girdNodes.titleLabel[4]:setString("总钻石消耗")
			girdNodes.titleLabel[5]:setString("总保险记分牌统计")
			girdNodes.scoreStr[1]:setString(data.chipssum)
			girdNodes.scoreStr[2]:setString(data.phizsum)
			girdNodes.scoreStr[3]:setString(data.cheatsum)
			girdNodes.scoreStr[4]:setString(data.diamondsum)
			girdNodes.scoreStr[5]:setString(data.insurance_scores)
			for i=1,5 do
				girdNodes.titleLabel[i]:setPositionY(data.cellHeight-i*44)
				girdNodes.scoreStr[i]:setPositionY(data.cellHeight-i*44)
			end
		end
	else
		girdNodes.cellBg:setVisible(false)
		girdNodes.cellBg1:setVisible(true)
		girdNodes.textBg:setVisible(false)
		if data.menuType == 1 then
			girdNodes.textMonth:setString("")
			girdNodes.iconTop:setVisible(true)
			girdNodes.iconRight:setVisible(false)
			girdNodes.text:setString("")
			-- girdNodes.cellBg1:loadTexture("bg/img_cell_bg3_1.png")
			if data.unfold == 0 then
				girdNodes.iconTop:setTexture("club/activity_cell_bg_down.png")
			elseif data.unfold ==1 then
				girdNodes.iconTop:setTexture("club/activity_cell_bg_up.png")
			end
		elseif data.menuType == 2 then
			girdNodes.text:setString("")
			girdNodes.cellBg1:loadTexture(ResLib.TABLEVIEW_CELL_BG)
			local month = ActivityCtorl.getYearMonth( data.month )
			girdNodes.textMonth:setString(month.."月份活跃统计")
			girdNodes.iconTop:setVisible(false)
			girdNodes.iconRight:setVisible(true)
		end
	end
end

function ActivityTotal:createLayer(  )
	_activityTotal = self
	_activityTotal:setSwallowTouches()
	_activityTotal:addTransitAction()
	UIUtil.setBgScale(ResLib.MAIN_BG, display.center, self)

	curTableView = nil

	clubActData = {}

	actData = {}
	curData = {}
	ActivityType = nil
	ActivityType = ActivityCtorl.isActFlag()

	self:buildLayer()
end

return ActivityTotal