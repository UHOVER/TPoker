local ViewBase = require("ui.ViewBase")
local ActivityDetail = class("ActivityDetail", ViewBase)
local ActivityCtorl = require("common.ActivityCtorl")


local _actDetail = nil
local curData = {}
local curTableView = nil

local ActivityType = nil

local month = nil

local function Callback(  )
	_actDetail:removeFromParent()
end

function ActivityDetail:buildLayer(  )
	
	local titleStr = ""
	local _month = ActivityCtorl.getYearMonth( month )
	if ActivityType then
		curData = ActivityCtorl.getClubMonthMember()
		titleStr = _month.."月份个人活跃统计"
	else
		curData = ActivityCtorl.getUnionMonthMember()
		titleStr = _month.."月份俱乐部活跃统计"
	end

	-- addTopBar
	UIUtil.addTopBar({backFunc = Callback, title = titleStr, parent = self})

	
	dump(curData)
	if #curData ~= 0 then
		curTableView = self:createTableView()
		curTableView:reloadData()
	end
end

function ActivityDetail:createTableView(  )
	local offset = nil
	local unfold = nil
	-- local unfoldSize = 0
	local function tableCellTouched( tableViewSender, tableCell )
		local idx = tableCell:getIdx()+1
		local data = curData[idx]
		if data.infoType == 1 then
			local tmpTab = {}
			if ActivityType then
				tmpTab = ActivityCtorl.getClubMonthMember_d( data.key )
			else
				tmpTab = ActivityCtorl.getUnionMonthMember_d( data.key )
			end
			-- dump(tmpTab)
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

function ActivityDetail:buildCellTmpl( cellItem )
	local girdNodes = {}
	girdNodes = cellItem

	local cellBg1 = UIUtil.addImageView({image=ResLib.TABLEVIEW_CELL_BG, touch=false, scale=true, size=cc.size(display.width, 250), pos=cc.p(0,0), ah=cc.p(0,0), parent=cellItem})
	girdNodes.cellBg1 = cellBg1
	local width1 = cellBg1:getContentSize().width
	local height1 = cellBg1:getContentSize().height

	local cellBg = UIUtil.addImageView({image=ResLib.TABLEVIEW_CELL_BG, touch=false, scale=true, size=cc.size(display.width, 250), pos=cc.p(0, 0), ah=cc.p(0,0), parent=cellItem})
	girdNodes.cellBg = cellBg
	local width = cellBg:getContentSize().width
	local height = cellBg:getContentSize().height

	-- 头像
	local stencil, Icon = UIUtil.createCircle(ResLib.CLUB_HEAD_GENERAL, cc.p(75,height1-60), cellBg1, ResLib.CLUB_HEAD_STENCIL_200)
	girdNodes.stencil = stencil
	girdNodes.Icon = Icon

	local name = UIUtil.addLabelArial('name', 30, cc.p(150, height1-60), cc.p(0, 0.5), cellBg1)
	girdNodes.name = name

	local clubName, club_icon = UIUtil.addNameByType({nameType = 1, nameStr = "俱乐部", fontSize = 30, pos = cc.p(150, height1-60), parent = cellBg1})
	girdNodes.clubName = clubName
	girdNodes.club_icon = club_icon

	local distance = 45

	-- 牌局时长
	local timeLabel = UIUtil.addLabelArial('总牌局时长', 30, cc.p(25, height1-3*distance), cc.p(0, 0.5), cellBg1):setColor(cc.c3b(170, 170, 170))
	local timeCount = UIUtil.addLabelArial("1111", 25, cc.p(width-130, height1-3*distance), cc.p(0.5, 0.5), cellBg1)
	girdNodes.timeCount = timeCount
	UIUtil.addLabelArial('(该成员参加牌局的总累计时长)', 18, cc.p(timeLabel:getPositionX()+timeLabel:getContentSize().width+10, height1-3*distance), cc.p(0, 0.5), cellBg1):setColor(ResLib.COLOR_GREY)

	-- 牌局数
	local cardLabel = UIUtil.addLabelArial('总牌局数', 30, cc.p(25, height1-4*distance), cc.p(0, 0.5), cellBg1):setColor(cc.c3b(170, 170, 170))
	local cardCount = UIUtil.addLabelArial("1000", 25, cc.p(width-130, height1-4*distance), cc.p(0.5, 0.5), cellBg1)
	girdNodes.cardCount = cardCount
	UIUtil.addLabelArial('(该成员累计参加的总牌局数)', 18, cc.p(cardLabel:getPositionX()+cardLabel:getContentSize().width+10, height1-4*distance), cc.p(0, 0.5), cellBg1):setColor(ResLib.COLOR_GREY)

	-- 总记分牌带入
	local scoreLabel = UIUtil.addLabelArial('非赛场带入量总计', 30, cc.p(25, height1-5*distance), cc.p(0, 0.5), cellBg1):setColor(cc.c3b(170, 170, 170))
	local scoreCount = UIUtil.addLabelArial("1000", 25, cc.p(width-130, height1-5*distance), cc.p(0.5, 0.5), cellBg1)
	girdNodes.scoreCount = scoreCount

	local textBg = UIUtil.addImageView({image = ResLib.TABLEVIEW_TEXT_LINE, touch=false, scale=true, size=cc.size(display.width, 64),pos=cc.p(display.width/2, 255), ah=cc.p(0.5,0), parent=cellItem})
	girdNodes.textBg = textBg

	local textFrom = UIUtil.addLabelArial('俱乐部内', 30, cc.p(textBg:getContentSize().width/2, textBg:getContentSize().height/2), cc.p(0.5, 0.5), textBg)
	girdNodes.textFrom = textFrom

	----------------------
	local sheetNode = UIUtil.addImageView({image=ResLib.COM_OPACITY0, touch=false, scale=true, size=cc.size(display.width, 600), pos=cc.p(0, 0), ah=cc.p(0,0), parent=cellBg})
	girdNodes.sheetNode = sheetNode
	
	----------------------
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

function ActivityDetail:updateCellTmpl( cellItem, cellIndex )
	local girdNodes = cellItem
	local data = curData[cellIndex]

	if data.infoType == 0 then
		if ActivityType then
			girdNodes.clubName:setVisible(false)
			girdNodes.club_icon:setVisible(false)
			girdNodes.name:setVisible(true)
			girdNodes.name:setString(data.group_member_name)
			girdNodes.Icon:setTexture(ResLib.USER_HEAD)
		else
			girdNodes.name:setVisible(false)
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
		end

		girdNodes.cellBg1:setVisible(true)
		girdNodes.cellBg:setVisible(false)
		girdNodes.textBg:setVisible(false)
		local url = data.headimg
		local function funcBack( path )
			local rect = girdNodes.stencil:getContentSize()
			girdNodes.Icon:setTexture(path)
			girdNodes.Icon:setTextureRect(rect)
		end
		if url ~= "" then
			ClubModel.downloadPhoto(funcBack, url, true)
		end
	
		local time = ActivityCtorl.transTime(data.p_time)
		girdNodes.timeCount:setString(time)
		local cards = data.p_count
		girdNodes.cardCount:setString(cards)
		local scores = data.no_hall_scoressum
		girdNodes.scoreCount:setString(scores)
		
		girdNodes.secureSp:setVisible(false)
		girdNodes.iconVertical:setVisible(false)
		girdNodes.iconArrow:setVisible(false)

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

function ActivityDetail:addSheetNode( sheetH, handData, mod, parent )
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

function ActivityDetail:createLayer( _month )
	_actDetail = self
	_actDetail:setSwallowTouches()
	UIUtil.setBgScale(ResLib.MAIN_BG, display.center, self)

	curData = {}
	curTableView = nil

	month = _month

	ActivityType = nil
	ActivityType = ActivityCtorl.isActFlag()
	
	self:buildLayer()
end

return ActivityDetail