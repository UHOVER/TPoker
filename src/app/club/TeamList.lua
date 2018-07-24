local ViewBase = require("ui.ViewBase")
local TeamList = class("TeamList", ViewBase)
local ClubCtrol = require("club.ClubCtrol")

local _teamList = nil

local curTableView = nil
local curData = {}

local otherTeam = {}

local function callBack(  )
	_teamList:removeFromParent()
end

function TeamList:buildLayer(  )
	UIUtil.addTopBar({backFunc = callBack, title = "我的战队", parent = self})

	curTableView = self:createTableView()
	curTableView:reloadData()
end

function TeamList:createTableView(  )
	local function tableCellTouched( tableViewSender, tableCell )
		print('  tableCellTouched  ' ..tableCell:getIdx())
		local idx = tableCell:getIdx()+1
	end

	local function cellSizeForTable( tableViewSender, cellIndex )
		return 0, 130
	end

	local function numberOfCellsInTableView( tableViewSender )
		return #curData
	end

	local function tableCellAtIndex( tableViewSender, cellIndex )
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
	local tableView = cc.TableView:create( cc.size(display.width, display.height-130))
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

function TeamList:buildCellTmpl( cellItem )
	local girdNodes = {}
	girdNodes = cellItem
	local cellBg = UIUtil.addImageView({image=ResLib.TABLEVIEW_CELL_BG, touch=false, scale=true, size=cc.size(display.width, 130), pos=cc.p(0,0), ah=cc.p(0,0), parent=cellItem})
	girdNodes.cellBg = cellBg

	local width = cellBg:getContentSize().width
	local height = cellBg:getContentSize().height
	-- 头像
	local stencil, Icon = UIUtil.createCircle(ResLib.TEAM_HEAD, cc.p(70,height/2), cellBg, ResLib.CLUB_HEAD_STENCIL_200)
	girdNodes.stencil = stencil
	girdNodes.Icon = Icon

	local teamName, team_icon = UIUtil.addNameByType({nameType = 5, nameStr = "战队", fontSize = 36, pos = cc.p(140, height*3/4+10), parent = cellBg})
	-- teamName:enableBold()
	girdNodes.teamName = teamName
	girdNodes.team_icon = team_icon

	UIUtil.addPosSprite("club/icon_user_blue.png", cc.p(140, height/2), cellBg, cc.p(0, 0.5))
	local teamCount = UIUtil.addLabelArial('30', 28, cc.p(180, height/2), cc.p(0, 0.5), cellBg):setColor(ResLib.COLOR_GREY1)
	girdNodes.teamCount = teamCount

	local teamDes = UIUtil.addLabelArial('', 24, cc.p(140, height/4-10), cc.p(0, 0.5), cellBg):setColor(ResLib.COLOR_GREY)
	girdNodes.teamDes = teamDes

	local function clubBtnClick( sender )
		local tag = sender:getTag()
		self:joinTeam(tag)
	end
	local label = cc.Label:createWithSystemFont("申请加入", "Marker Felt", 24):setColor(ResLib.COLOR_BLUE)
	local button = UIUtil.controlBtn(ResLib.BTN_BLUE_BORDER_SMALL, ResLib.BTN_BLUE_BORDER_SMALL, ResLib.BTN_BLUE_BORDER_SMALL, label, cc.p(width-79, height/2), cc.size(117,39), clubBtnClick, cellBg)
	girdNodes.button = button
end

function TeamList:updateCellTmpl( cellItem, cellIndex )
	local girdNodes = cellItem
	local data = curData[cellIndex]

	local function funcBack( path )
		local function onEvent(event)
			if event == "exit" then
				return
			end
		end
		girdNodes.Icon:registerScriptHandler(onEvent)
		girdNodes.Icon:setTexture(path)
	end
	if data.team_logo ~= "" then
		ClubModel.downloadPhoto(funcBack, data.team_logo, true)
	end

	local name = StringUtils.getShortStr( data.team_name, 12)
	girdNodes.teamName:setString(name.."战队")
	UIUtil.updateNameByType( 5, girdNodes.teamName, girdNodes.team_icon )

	girdNodes.teamCount:setString(data.team_count)

	girdNodes.teamDes:setString("来自"..data.club_name.."俱乐部")

	girdNodes.button:setTag(cellIndex)
end

function TeamList:joinTeam( tag )
	local data = curData[tag]
	if otherTeam == 0 then
		ViewCtrol.popHint({bgSize = cc.size(display.width-100, 300), content = "确定要加入 "..data.team_name.."战队？", sureFunBack = function()
				local function response( data )
					dump(data)
					if data.code == 0 then
						ViewCtrol.showTick({content = "申请已发送!"})
					end
				end
				local tabData = {}
				tabData["team_id"] = data.team_id
				tabData["club_id"] = ClubCtrol.getClubInfo().id
				tabData["message"] = data.team_name
				XMLHttp.requestHttp("joinTeamMsg", tabData, response, PHP_POST)
			end})
	else
		ViewCtrol.showTip({content = "您已创建或加入其它战队,不能再加入此战队！"})
	end
end

function TeamList:createLayer( data, tab )
	_teamList = self
	self:setSwallowTouches()
	UIUtil.setBgScale(ResLib.MAIN_BG, display.center, self)

	curTableView = nil
	curData = {}
	curData = data
	otherTeam = tab

	self:buildLayer()
end

return TeamList