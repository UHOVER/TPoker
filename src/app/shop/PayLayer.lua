local ViewBase = require("ui.ViewBase")
local PayLayer = class('PayLayer', ViewBase)
local MineCtrol = require("mine.MineCtrol")

local _PayLayer = nil
local tab = {}
	tab['font'] = 'Arial'
	tab['size'] = 30

local imageView = nil
local curData = {}

local payImg = {}

local isWeChatPay = nil

local function Callback(  )
	_PayLayer:removeTransitAction()
	local ShopLayer = require("shop.ShopLayer")
	ShopLayer.updateTableView(  )

end

local function buyMasonry(tdata)
	local function response(data)
		data = data['data']
		Single:paltform():buyShopMasonry(data['transid'])
	end
	local tab = {}
	tab['appuserid'] = Single:playerModel():getId()
	tab['waresid'] = tdata['id']
	tab['price'] = tdata['money']
	XMLHttp.requestHttp(PHP_SHOP_TRADE, tab, response, PHP_POST)
end

local function buyShopOfApplePay( tdata )
	local str = "com.allbetspace."..tdata['money'].."."..tdata['id']
	local tab = {purchase = str, diamonds = tdata["diamonds"], id = tdata['id'], money = tdata['money'] }
	Single:paltform():buyShopOfApplePay(tab)
end

local function buyClickCall( tab )
	local _platform = cc.Application:getInstance():getTargetPlatform()
	if (cc.PLATFORM_OS_IPHONE == _platform) or (cc.PLATFORM_OS_IPAD == _platform) or (cc.PLATFORM_OS_MAC == _platform)  then
		PAY_ICON = IOS_PAY

		buyShopOfApplePay(tab)
	elseif _platform == cc.PLATFORM_OS_ANDROID then
		
		local payPop = require("shop.PayPop").new(tab)
		_PayLayer:addChild(payPop)
	else
		assert(nil, 'platform.getInstance')
	end
end

function PayLayer:buildLayer(  )

	-- addTopBar
	UIUtil.addTopBar({backFunc = Callback, title = "充值中心", parent = self})
	
	imageView = UIUtil.addImageView({image = ResLib.TABLEVIEW_BG, touch=false, scale=true, size=cc.size(display.width, display.height-130), pos=cc.p(0,0), parent=self})

	for i=1,6 do
		payImg[i] = "user/shop_diamond_"..i..".png"
	end
	
	self:createTableView()
end

-- YDWX_DZ_ZHANGMENG_BUG _20160630_001【UE Integrity】BUG

function PayLayer:addTopBar(  )
	local topBar = UIUtil.addImageView({image = ResLib.MAIN_BG, touch=false, scale=true, size=cc.size(display.width, 130), pos=cc.p(0,display.height-130), parent=self})
	local width = topBar:getContentSize().width
	local height = topBar:getContentSize().height
	
	-- back
	UIUtil.addMenuBtn(ResLib.BTN_BACK, ResLib.BTN_BACK, Callback, cc.p(50, height/2-20), topBar)
	
	-- title
	UIUtil.addLabelArial("充值中心", 30, cc.p(width/2, height/2-20), cc.p(0.5, 0.5), topBar)

end

-- YDWX_DZ_ZHANGMENG_BUG _20160630_001【UE Integrity】BUG

function PayLayer:createTableView(  )
	local function tableCellTouched( tableViewSender, tableCell )
		-- body
		local idx = tableCell:getIdx() + 1
		local tdata = curData[ idx ]

		if isWeChatPay == 0 then
			buyClickCall(tdata)
		elseif isWeChatPay == 1 then
			local payPop = require("shop.PayPop").new(tdata)
			_PayLayer:addChild(payPop)
		end
	end
	local function cellSizeForTable( tableViewSender, cellIndex )
		return 0, 150
	end
	local function numberOfCellsInTableView( tableViewSender )
		return 6
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

function PayLayer:buildCellTmpl( cellItem )
	local girdNodes = {}
	girdNodes = cellItem
	local cellBg = UIUtil.addImageView({image = ResLib.TABLEVIEW_CELL_BG, touch=false, scale=true, size=cc.size(display.width, 150),pos=cc.p(0,0), ah=cc.p(0,0), parent=cellItem})
	local width = cellBg:getContentSize().width
	local height = cellBg:getContentSize().height

	local icon = UIUtil.addPosSprite('user/shop_diamond_1.png', cc.p(20, height/2), cellBg, cc.p(0, 0.5))
	girdNodes.icon = icon

	local name = UIUtil.addLabelArial('', 36, cc.p(150, height/2), cc.p(0,0.5), cellBg)
	-- name:setColor(cc.c3b(204, 204, 204))
	girdNodes.name = name

	-- local des = UIUtil.addLabelArial('含钻石300颗', 20, cc.p(150, height/4-10), cc.p(0,0), cellBg)
	-- girdNodes.des = des

	-- local spBg = UIUtil.addPosSprite('user/shop_icon_blue_border.png', cc.p(width-25, height/2), cellBg, cc.p(1, 0.5))

	local price = UIUtil.addLabelArial('￥60', 36, cc.p(width-20, height/2), cc.p(1,0.5), cellBg)
	-- price:setColor(cc.c3b(102, 102, 102))
	girdNodes.price = price
end

function PayLayer:updateCellTmpl( cellItem, cellIndex )
	local girdNodes = cellItem
	local data = curData[cellIndex]

	girdNodes.icon:setTexture(payImg[cellIndex])

	girdNodes.name:setString(data.diamonds .. "颗钻石")
	-- girdNodes.des:setString("含钻石"..data.diamonds.."颗")
	girdNodes.price:setString("￥"..data.money)
end

function PayLayer:createLayer( data )
	_PayLayer = self
	_PayLayer:setSwallowTouches()
	_PayLayer:addTransitAction()

	UIUtil.setBgScale(ResLib.MAIN_BG, display.center, self)
	curData = {}
	isWeChatPay = 0
	curData = data.data
	isWeChatPay = data.is_show_pay or 0
	self:buildLayer()

end

--爱贝下单接口广播
function PayLayer.buySuccess(data)
end

--核查砖石数
function PayLayer.checkDiamond()
	local function response(data)
		-- print('checkDiamond  checkDiamond')
		-- print_f(data)
		-- ViewCtrol.showMsg('支付成功')

		data = data['data']
		Single:playerModel():setPDiaNum( data['all_diamond'] )
	end
	local tab = {}
	XMLHttp.requestHttp(PHP_ALL_DIAMOND, tab, response, PHP_POST)
end


return PayLayer
