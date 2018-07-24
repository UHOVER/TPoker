local ViewBase = require('ui.ViewBase')
local CardList = class('CardList', ViewBase)

local CardCtrol = require("cards.CardCtrol")

local _cardList = nil
local tab = {}
	tab['font'] = 'Arial'
	tab['size'] = 30

local imageView = nil
local curData = {}
local curTableView = nil

local function detailFunc(  )
	print("详情")
	local clubInfo = require('club.ClubInfo')
	local layer = clubInfo:create()
	_cardList:addChild(layer, 10)
	layer:createLayer( "club" )
end

function CardList:buildLayer(  )
	local clubInfo = CardCtrol.getClubInfo()
	
	-- topBar
    UIUtil.addTopBar({title = clubInfo.name, menuFont = "详情", menuFunc = detailFunc, parent = self})

	imageView = UIUtil.addImageView({touch=false, scale=true, size=cc.size(display.width, display.height-230), pos=cc.p(0,100), parent=self})

	if #curData ~= 0 then

		curTableView = self:createTableView()
		curTableView:reloadData()
	else
		local noticeTab = Notice.getMessagePushCount( 5 )
		if next(noticeTab) ~= nil then
			Notice.deleteCardMsg( noticeTab.count )
		end
		self:addNoCardsbyFace()
	end

end

function CardList:addNoCardsbyFace(  )
	UIUtil.addPosSprite("club/card_icon_face.png", cc.p(display.cx, display.height*0.65), self, cc.p(0.5, 0.5))

	local str = "暂时没有您可以加入的牌局\n\n您可以进入赛场选择快速游戏\n\n体验无需要等待的游戏快感！"
	local label = cc.Label:createWithSystemFont(str, "Arial", 35, cc.size(600, 500), cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
	label:setTextColor(cc.c4b(153, 156, 158, 255))
	label:setPosition(cc.p(display.cx, display.cy-100))
	self:addChild(label)
end

function CardList.updateCardList( id )
	if curData == nil or curData == {} then
		return
	end
	for k,v in pairs(curData) do
		if tonumber(v.gid) == tonumber(id) then
			table.remove(curData, k)
			if #curData == 0 then
				curTableView:removeFromParent()
				curTableView = nil
				_cardList:addNoCardsbyFace()
			else
				curTableView:reloadData()
			end
			break
		end
	end
end

function CardList:createTableView(  )
	
	local function tableCellTouched( tableViewSender, tableCell )
		--print(tableViewSender.. '  tableCellTouched  ' ..tableCell)
		local idx = tableCell:getIdx()
		local tdata = curData[idx + 1]
		local GameScene = require 'game.GameScene'
		if tdata.game_mod == GAME_TYPE_STANDARD or tdata.game_mod == GAME_TYPE_SNG then
			if tdata.status == 0 then
				local function funcBack(  )
				end
				MainCtrol.enterGame(tdata['gid'], MainCtrol.MOD_GID, funcBack)
			elseif tdata.status == 1 then
				GameScene.startScene(tdata['gid'])
			end
		elseif tdata.game_mod == GAME_CLUB_SNG or tdata.game_mod == GAME_CIRCLE_SNG then
			CardCtrol.popData( tdata, nil )
		elseif tdata.game_mod == GAME_TYPE_MTT then
			if tonumber(tdata.status) == 0 then
				MainCtrol.enterGame(tdata['gid'], MainCtrol.MOD_GID, function()end, nil, true )
			elseif tonumber(tdata.status) == 1 then
				local tab = {pokerId = tdata.gid}
				local MttShowCtorl = require("common.MttShowCtorl")
				MttShowCtorl.dataStatStatus( function (  )
					MttShowCtorl.MttSignUp(tab)
				end, tab )
			end
		elseif tdata.game_mod == GAME_CLUB_MTT or tdata.game_mod == GAME_CIRCLE_MTT then
			local tab = {pokerId = tdata.gid}
			local MttShowCtorl = require("common.MttShowCtorl")
			MttShowCtorl.dataStatStatus( function (  )
				MttShowCtorl.MttSignUp(tab)
			end, tab )
		elseif tdata.game_mod == GAME_HALL_MTT or tdata.game_mod == GAME_LOCAL_MTT then
			local tab = {pokerId = tdata.gid}
			local MttShowCtorl = require("common.MttShowCtorl")
			MttShowCtorl.dataStatStatus( function (  )
				MttShowCtorl.MttSignUp(tab, "hallMtt")
			end, tab )
		elseif tdata.game_mod == GAME_UNION_SNG then
			-- if #tdata.choose_clubs >= 2 then
			-- 	CardCtrol.addSNGApply( tdata )
			-- elseif #tdata.choose_clubs == 1 then
				CardCtrol.popData( tdata, CardCtrol.getClubInfo().id )
			-- else
			-- 	ViewCtrol.showTip({content = "您未绑定俱乐部, 不能参加牌局！"})
			-- end
		elseif tdata.game_mod == GAME_UNION_STABDARD then
			-- if #tdata.choose_clubs >= 2 then
			-- 	CardCtrol.addSNGApply( tdata )
			-- else
				-- local clubId = nil
				-- if tdata.choose_clubs[1]then
				-- 	clubId = tdata.choose_clubs[1]["club_id"]
				-- end
				CardCtrol.enterNOR( tdata['gid'], CardCtrol.getClubInfo().id )
			-- end
		elseif tdata.game_mod == GAME_UNION_MTT then
			-- if #tdata.choose_clubs >= 2 then
			-- 	CardCtrol.addSNGApply( tdata )
			-- else
				local tab = {}
				if tdata.choose_clubs then
					tab = {pokerId = tdata.gid, groupID = CardCtrol.getClubInfo().id}
				else
					tab = {pokerId = tdata.gid}
				end
				local MttShowCtorl = require("common.MttShowCtorl")
				MttShowCtorl.dataStatStatus( function (  )
					MttShowCtorl.MttSignUp(tab)
				end, tab )
			-- end
		else
			GameScene.startScene(tdata['gid'])
		end
	end

	local function cellSizeForTable( tableViewSender, cellIndex )
		return 0, 200
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

	local tableView = cc.TableView:create( cc.size(display.width, display.height-230))
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

function CardList:buildCellTmpl( cellItem )
	local girdNodes = {}
	girdNodes = cellItem

	local cellBg = UIUtil.addImageView({image=ResLib.TABLEVIEW_CELL_BG, touch=false, scale=true, size=cc.size(display.width, 199), ah=cc.p(0,0), pos=cc.p(0,0), parent=cellItem})
	girdNodes.cellBg = cellBg

	local width = display.width
	local height = cellBg:getContentSize().height

	local stencil, clubIcon = UIUtil.createCircle(ResLib.CLUB_HEAD_GENERAL, cc.p(80,height/2), cellBg, ResLib.CLUB_HEAD_STENCIL_200, 0.6)
	girdNodes.stencil = stencil
	girdNodes.clubIcon = clubIcon
	
	-- 牌局名称
	local card_name = UIUtil.addLabelArial("我们大家一起玩", 34, cc.p(160,height/2+28), cc.p(0,0), cellBg)
	girdNodes.card_name = card_name

	local card_mod = UIUtil.addLabelArial("", 34, cc.p(160,height/2+28), cc.p(0,0), cellBg):setColor(ResLib.COLOR_YELLOW1)
	girdNodes.card_mod = card_mod

	local safeSp = UIUtil.addPosSprite("common/com_safe_icon.png", cc.p(card_name:getPositionX()+card_name:getContentSize().width+10,card_name:getPositionY()+5), cellBg, cc.p(0,0))
	girdNodes.safeSp = safeSp

	-- 牌局状态
	local card_state = UIUtil.addPosSprite("club/card_list_status_coming.png", cc.p(width-20,height/2+35), cellBg, cc.p(1,0))
	girdNodes.card_state = card_state

	-- 牌局来自
	local card_des = UIUtil.addLabelArial("", 22, cc.p(160,height/2), cc.p(0,0.5), cellBg):setColor(ResLib.COLOR_GREY)
	girdNodes.card_des = card_des

	-- 牌局筹码
	local chipSp = UIUtil.addPosSprite("club/card_list_icon_spades.png", cc.p(160,height/2-30), cellBg, cc.p(0,1))
	girdNodes.chipSp = chipSp

	local card_chip = UIUtil.addLabelArial("", 24, cc.p(190,height/2-28), cc.p(0,1), cellBg):setColor(cc.c3b(85, 85, 85))
	girdNodes.card_chip = card_chip

	-- 牌局人数
	local numSp = UIUtil.addPosSprite("club/card_list_icon_user.png", cc.p(373,height/2-30), cellBg, cc.p(0,1))
	girdNodes.numSp = numSp

	local card_num = UIUtil.addLabelArial("", 24, cc.p(403,height/2-28), cc.p(0,1), cellBg):setColor(cc.c3b(85, 85, 85))
	girdNodes.card_num = card_num

	-- 牌局总时间(sng 牌局奖励)
	local timeSp = UIUtil.addPosSprite("club/card_list_icon_time.png", cc.p(507,height/2-30), cellBg, cc.p(0,1))
	girdNodes.timeSp = timeSp

	-- 牌局剩余时间
	local card_Ttime = UIUtil.addLabelArial("", 24, cc.p(537,height/2-28), cc.p(0,1), cellBg):setColor(cc.c3b(85, 85, 85))
	girdNodes.card_Ttime = card_Ttime

end

function CardList:updateCellTmpl(cellItem, cellIndex)
	local girdNodes = cellItem

	local data = curData[cellIndex]

	girdNodes.card_name:setString(data.name)

	local url = data.avatar or ""
	local function funcBack( path )
		local function onEvent(event)
			if event == "exit" then
				return
			end
		end
		girdNodes.clubIcon:registerScriptHandler(onEvent)
		girdNodes.clubIcon:setTexture(path)
	end
	if url ~= "" then
		ClubModel.downloadPhoto(funcBack, url, true)
	end

	-- 标准牌局、sng
	-- 21 俱乐部标准、22 俱乐部sng
	-- general 个人标准、 sng 个人sng
	-- 31 圈子标准 32 圈子sng
	-- 42 联盟sng

	-- 标准
	if data.game_mod == GAME_CLUB_STABDARD or data.game_mod == GAME_CIRCLE_STABDARD or data.game_mod == GAME_TYPE_STANDARD or data.game_mod == GAME_UNION_STABDARD then

		-- 牌局名称
		-- girdNodes.card_name:setColor(cc.c3b(91, 146, 255))
		girdNodes.card_mod:setString("·标准")
		girdNodes.card_mod:setPositionX(girdNodes.card_name:getPositionX()+girdNodes.card_name:getContentSize().width)
		if tonumber(data.secure) == 1 then
			girdNodes.safeSp:setVisible(true)
			girdNodes.safeSp:setPositionX(girdNodes.card_mod:getPositionX()+girdNodes.card_mod:getContentSize().width+10)
		else
			girdNodes.safeSp:setVisible(false)
		end
		
		-- 牌局人数
		girdNodes.card_num:setString(data.current_players .. "/" .. data.limit_players)
		if tonumber(data.current_players) == tonumber(data.limit_players) then
			-- girdNodes.card_num:setColor(cc.c3b(0, 0, 153))
			girdNodes.numSp:setTexture("club/card_list_icon_user.png")
		else
			-- girdNodes.card_num:setColor(ResLib.COLOR_GREY1)
			girdNodes.numSp:setTexture("club/card_list_icon_user.png")
		end

		-- 状态
		if data.status == 0 then
			girdNodes.card_state:setTexture("club/card_list_status_prepare1.png")
		elseif data.status == 1 then
			girdNodes.card_state:setTexture("club/card_list_status_coming.png")
		end

		-- 盲注
		girdNodes.chipSp:setTexture("club/card_list_icon_spades.png")
		local str = CardCtrol.transNum(data.big_blind/2).."/"..CardCtrol.transNum(data.big_blind).."("..CardCtrol.transNum(data.ante)..")"
		girdNodes.card_chip:setString(str)

		-- 牌局时间限制（ 剩余时间、总时间）
		local timer = CardCtrol.transTime( data.left_time )

		girdNodes.timeSp:setTexture("club/card_list_icon_time.png")
		girdNodes.card_Ttime:setString("还剩 "..timer)

	-- SNG
	elseif data.game_mod == GAME_CLUB_SNG or data.game_mod == GAME_CIRCLE_SNG or data.game_mod == GAME_TYPE_SNG or data.game_mod == GAME_TYPE_HALL_SNG or data.game_mod == GAME_UNION_SNG then

		girdNodes.safeSp:setVisible(false)
		-- 牌局名称
		-- girdNodes.card_name:setColor(ResLib.COLOR_ORANGE1)
		girdNodes.card_mod:setString("")
		-- girdNodes.card_icon:setTexture("club/card_list_img_sng.png")

		-- 牌局人数
		girdNodes.card_num:setString(data.current_players .. "/" .. data.limit_players)
		if tonumber(data.current_players) == tonumber(data.limit_players) then
			-- girdNodes.card_num:setColor(cc.c3b(0, 0, 153))
			girdNodes.numSp:setTexture("club/card_list_icon_user.png")
		else
			-- girdNodes.card_num:setColor(cc.c3b(102, 102, 102))
			girdNodes.numSp:setTexture("club/card_list_icon_user.png")
		end

		-- 牌局状态
		if data.status == 0 then
			girdNodes.card_state:setTexture("club/card_list_status_prepare.png")
		else
			girdNodes.card_state:setTexture("club/card_list_status_coming.png")
		end

		-- 记录费
		girdNodes.chipSp:setTexture("club/card_list_icon_fee.png")
		local fee = data.entry_fee/10
		girdNodes.card_chip:setString(data.entry_fee.."+"..fee)

		girdNodes.timeSp:setTexture("club/card_list_icon_reward.png")
		girdNodes.card_Ttime:setString( data.prize )
	elseif data.game_mod == GAME_CLUB_MTT or data.game_mod == GAME_CIRCLE_MTT or data.game_mod == GAME_TYPE_MTT or data.game_mod == GAME_UNION_MTT or data.game_mod == GAME_HALL_MTT or data.game_mod == GAME_LOCAL_MTT then
		girdNodes.safeSp:setVisible(false)
		-- 牌局名称
		-- girdNodes.card_name:setColor(ResLib.COLOR_PURPLE)
		girdNodes.card_mod:setString("")
		-- girdNodes.card_icon:setTexture("club/card_list_img_mtt.png")

		-- 牌局状态
		if tonumber(data.status) == 0 then
			girdNodes.card_state:setTexture("club/card_list_status_prepare.png")
		else
			girdNodes.card_state:setTexture("club/card_list_status_coming.png")
		end

		-- 记录费
		girdNodes.chipSp:setTexture("club/card_list_icon_fee.png")
		local fee = data.entry_fee/10
		local str = CardCtrol.transNum(data.entry_fee).."+"..CardCtrol.transNum(fee)
		girdNodes.card_chip:setString(str)

		-- 起始记分牌
		girdNodes.numSp:setTexture("club/card_list_icon_initalScore.png")
		local _str = CardCtrol.transNum(data.inital_score)
		girdNodes.card_num:setString(_str)
		-- girdNodes.card_num:setColor(cc.c3b(102, 102, 102))

		-- 升盲时间
		girdNodes.timeSp:setTexture("club/card_list_icon_increaseTime.png")
		local time = data.increase_time/60
		girdNodes.card_Ttime:setString(time.."分钟")
	end
	local name = ""
	if type(data.host_name) == "string" then
		name = StringUtils.getShortStr( data.host_name, LEN_NAME)
	end

	-- 牌局来自
	if data.host_type == "club" then
		girdNodes.card_des:setString("来自"..name.. "俱乐部")

	elseif data.host_type == "person" then
		girdNodes.card_des:setString("来自"..name.. "玩家")

	elseif data.host_type == "circle" then
		girdNodes.card_des:setString("来自"..name.. "圈子")

	elseif data.host_type == "union" then
		girdNodes.card_des:setString("来自联盟的牌局")
	elseif data.host_type == GAME_HALL_MTT or data.host_type == GAME_TYPE_HALL_SNG then
		girdNodes.card_des:setString("来自"..name)
	elseif data.host_type == GAME_LOCAL_MTT then
		girdNodes.card_des:setString("来自本地化"..name)

	end

end

function CardList:createLayer(  )
	_cardList = self
	local function onNodeEvent(event)
		if event == "enter" then
			CardCtrol.setCardScene( true )
		elseif event == "exit" then
			CardCtrol.setCardScene( false )
		end
    end
	_cardList:registerScriptHandler(onNodeEvent)

	_cardList:addLayerOfTable()
	UIUtil.setBgScale(ResLib.MAIN_BG, display.center, self)
	Bottom:getInstance():addBottom(2, self)

	imageView = nil
	curData = {}
	curTableView = nil

	curData = CardCtrol.getCardList()
	dump(curData)
	
	self:buildLayer()
end

return CardList