local ViewBase = require("ui.ViewBase")
local ShopLayer = class('ShopLayer', ViewBase)
local MineCtrol = require("mine.MineCtrol")

local _ShopLayer = nil
local tab = {}
	tab['font'] = 'Arial'
	tab['size'] = 30
local SHOP_TAG = nil

local curData = {}
local curTableView = nil
local imageView = nil

local mineMsg = {}
local shopImg = {}

local function Callback(  )
	_ShopLayer:removeTransitAction()

	if SHOP_TAG == "mine" then
		local MineLayer = require("mine.MineLayer")
		MineLayer.updateShop(  )
	end	

	local myEvent = cc.EventCustom:new("C_Event_reset_Screen")
    local customEventDispatch = cc.Director:getInstance():getEventDispatcher()
    customEventDispatch:dispatchEvent(myEvent) 
end

function ShopLayer:buildLayer(  )
	
	-- addTopBar
	UIUtil.addTopBar({backFunc = Callback, title = "游戏商城", parent = self})

	imageView = UIUtil.addImageView({image = ResLib.TABLEVIEW_BG, touch=false, scale=true, size=cc.size(display.width, display.height-130), pos=cc.p(0,0), parent=self})

	mineMsg = MineCtrol.getMineInfo(  )

	shopImg = {}
	for i,v in ipairs(curData) do
		shopImg[v.id] = "user/shop_item_"..i..".png"
	end

	curTableView = self:createTableView()
	curTableView:reloadData()

end

function ShopLayer:createTableView(  )
	local function tableCellTouched( tableViewSender, tableCell )
		local index = tableCell:getIdx()
		if index > 0 then
			local diamond = Single:playerModel():getPDiaNum()
			if tonumber(curData[index].diamonds) > tonumber(diamond) then
				ViewCtrol.popHint({popType = 1, bgSize = cc.size(display.width-100, 300), content = "钻石数量不足,请先充值！"})
			else
				self:sureShop( index )
			end
		else
			if VISITOR_LOGIN then
				local callBack = {}
				callBack[1] = function (  )
					print("登录购买")
					local LoginCtrol = require("login.LoginCtrol")
					LoginCtrol.changeUser()
					DZChat.breakRYConnect()
					NoticeCtrol.removeNoticeNode()
					local loginScene = require("login.LoginScene")
					loginScene.startScene()
				end
				callBack[2] = function (  )
					print("游客购买")
					MineCtrol.dataStatPay( function ( data )
						local payLayer = require("shop.PayLayer")
						local layer = payLayer:create()
						self:addChild(layer)
						layer:createLayer(data)
					end )
				end
				callBack[3] = function (  )
					print("取消")
				end
				ViewCtrol.popHint({popType = 3, text={"登录购买", "游客购买", "取消"}, bgSize = cc.size(display.width-100, 300), content = "游客模式购买仅限当前设备使用所购买的权限，推荐您登录购买", sureFunBack = callBack})
				return
			end

			MineCtrol.dataStatPay( function ( data )
				local payLayer = require("shop.PayLayer")
				local layer = payLayer:create()
				self:addChild(layer)
				layer:createLayer(data)
			end )
		end
	end
	local function cellSizeForTable( tableViewSender, cellIndex )
		if cellIndex == 0 then
			return 0, 150
		else
			return 0, 150
		end
	end
	local function numberOfCellsInTableView( tableViewSender )
		return #curData + 1
	end
	local function tableCellAtIndex( tableViewSender, cellIndex )
		local index = cellIndex
		local cellItem = tableViewSender:dequeueCell()
		if cellItem == nil then
			cellItem = cc.TableViewCell:new()
			self:buildCellTmpl(cellItem)
		end
		self:updateCellTmpl(cellItem, index)
		return cellItem
	end
	local tableView = cc.TableView:create(cc.size(display.width, display.height-130))
	tableView:setPosition(cc.p(0,0))
	imageView:addChild(tableView)
	tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
	tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
	tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
	tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
	tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
	tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
	tableView:reloadData()
	tableView:setDelegate()
	return tableView
end

function ShopLayer.updateTableView(  )
	
	mineMsg = MineCtrol.getMineInfo(  )

	curTableView:reloadData()
end

function ShopLayer:buildCellTmpl( cellItem )
	local girdNodes = {}
	girdNodes = cellItem

	local cellBg = UIUtil.addImageView({image = ResLib.TABLEVIEW_CELL_BG, touch=false, scale=true, size=cc.size(display.width, 150),pos=cc.p(0,0), ah=cc.p(0,0), parent=cellItem})
	girdNodes.cellBg = cellBg
	local width = cellBg:getContentSize().width
	local height = cellBg:getContentSize().height

	local node1 = cc.Node:create()
	node1:setPosition(cc.p(0,0))
	cellBg:addChild(node1)
	girdNodes.node1 = node1

	local color = cc.c3b(230, 95, 44)

	-- 钻石
	local diamond_sp = UIUtil.addPosSprite("user/icon_zhuanshi.png", cc.p(50, height/2), node1, cc.p(0,0.5))
	local diamond = UIUtil.addLabelArial("0", 34, cc.p(110, height/2), cc.p(0, 0.5), node1)
	girdNodes.diamond = diamond

	local scores_sp = UIUtil.addPosSprite("user/icon_spades.png", cc.p(diamond:getPositionX()+diamond:getContentSize().width+20, height/2), node1, cc.p(0,0.5))
	girdNodes.scores_sp = scores_sp
	local scores = UIUtil.addLabelArial("", 34, cc.p(scores_sp:getPositionX()+scores_sp:getContentSize().width+20, height/2), cc.p(0, 0.5), node1)
	girdNodes.scores = scores
		
	UIUtil.addLabelArial('充值', 36,	cc.p(width-150, height/2), cc.p(0,0.5), node1)
		:setColor(ResLib.COLOR_BLUE)
	UIUtil.addPosSprite(ResLib.BTN_BACK_RIGHT, cc.p(width-20, height/2), node1, cc.p(1, 0.5))

	local node2 = cc.Node:create()
	node2:setPosition(cc.p(0,0))
	cellBg:addChild(node2)
	girdNodes.node2 = node2

	local icon = UIUtil.addPosSprite('user/shop_diamond_1.png', cc.p(20, height/2), node2, cc.p(0, 0.5))
	girdNodes.icon = icon

	-- local presentIcon = UIUtil.addPosSprite('user/icon_present.png', cc.p(85, height-25), node2, cc.p(0, 0.5))
	-- local present = UIUtil.addLabelArial('111', 17, cc.p(110, height-35), cc.p(0.5,0), node2)
	-- girdNodes.present = present

	local name = UIUtil.addLabelArial('香水礼包', 36, cc.p(150, height*3/4-40), cc.p(0,0), node2)
	-- name:setColor(ResLib.COLOR_BLUE)
	girdNodes.name = name

	local des = UIUtil.addLabelArial('含钻石300颗', 28, cc.p(150, height/4-10), cc.p(0,0), node2):setColor(ResLib.COLOR_GREY)
	girdNodes.des = des

	local spBg = UIUtil.addPosSprite('user/shop_icon_blue_border.png', cc.p(width-20, height/2), node2, cc.p(1, 0.5))
	UIUtil.addPosSprite('user/icon_zhuanshi.png', cc.p(16, spBg:getContentSize().height/2), spBg, cc.p(0, 0.5))

	local price = UIUtil.addLabelArial('', 35, cc.p(spBg:getContentSize().width/2+20, spBg:getContentSize().height/2), cc.p(0.5,0.5), spBg)
	girdNodes.price = price

end

function ShopLayer:updateCellTmpl( cellItem, cellIndex )
	local girdNodes = cellItem

	if cellIndex == 0 then
		girdNodes.node1:setVisible(true)
		girdNodes.node2:setVisible(false)

		girdNodes.cellBg:setContentSize(cc.size(display.width, 150))
		girdNodes.cellBg:loadTexture("user/grey_bg.png", 0)

		local diamonds = mineMsg.diamonds
		girdNodes.diamond:setString(diamonds)

		girdNodes.scores_sp:setPositionX(girdNodes.diamond:getPositionX()+girdNodes.diamond:getContentSize().width+20)
		local scores = mineMsg.scores
		girdNodes.scores:setPositionX(girdNodes.scores_sp:getPositionX()+girdNodes.scores_sp:getContentSize().width+20)
		girdNodes.scores:setString(scores)

	else
		local data = curData[cellIndex]

		girdNodes.node1:setVisible(false)
		girdNodes.node2:setVisible(true)

		girdNodes.cellBg:setContentSize(cc.size(display.width, 110))

		girdNodes.icon:setTexture(shopImg[data.id])

		-- local num = nil
		-- if tonumber(data.extra) >= 1000 then
		-- 	num = data.extra/1000
		-- 	girdNodes.present:setString("送" .. num.."千")
		-- else
		-- 	num = data.extra
		-- 	girdNodes.present:setString("送" .. num)
		-- end

		girdNodes.name:setString(data.name)
		girdNodes.des:setString('送'.. data.scores.."记分牌，额外赠送"..data.extra)
		girdNodes.price:setString(data.diamonds)
	end

end

function ShopLayer:sureShop( index )

	local shopData = curData[index]
	dump(shopData)
	local layer = nil

	local diamond = tonumber(mineMsg.diamonds)
	local score = tonumber(mineMsg.scores)

	local function sureBuyFunc(  )
		layer:removeFromParent()
		local function response( data )
			dump(data)
			if data.code == 0 then

				diamond = diamond - shopData.diamonds
				score = score + shopData.scores + shopData.extra

				Single:playerModel():setPBetNum( score )
				Single:playerModel():setPDiaNum( diamond )

				mineMsg = MineCtrol.getMineInfo(  )

				ViewCtrol.showTick({content = "购买成功！"})

				curTableView:reloadData()
			end
		end
		local tabData = {}
		tabData["exchange_id"] = shopData.id
		XMLHttp.requestHttp("doDiamondsToScores", tabData, response, PHP_POST)
	end

	layer = ViewCtrol.showTips({title = "购买确认", content = "即将购买" .. shopData.name, rightListener = sureBuyFunc})

end

function ShopLayer:createLayer( data, target )
	_ShopLayer = self
	_ShopLayer:setSwallowTouches()
	_ShopLayer:addTransitAction()

	UIUtil.setBgScale(ResLib.MAIN_BG, display.center, self)

	SHOP_TAG = target
	mineMsg = {}
	curData = {}
	curData = data

	self:buildLayer(  )
	
end

return ShopLayer