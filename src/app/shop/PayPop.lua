local ViewBase = require("ui.ViewBase")
local PayPop = class("PayPop", ViewBase)

local _payPop = nil

local payData = {}

local IOS_PAY = {}
local ANDROID_PAY = {}
local PAY_ICON = {}
local _plat = nil

local function buyShopOfWeiXin(  )
	local function response( data )
		dump(data)
		if data.code == 0 then
			Single:paltform():buyShopOfWeiXin(data.data)
		end
	end
	local tabData = {}
	tabData['goods_name'] = payData["diamonds"].."颗钻石"
	tabData['waresid'] = payData['id']
	tabData['total_fee'] = payData['money']
	XMLHttp.requestHttp("wechatPay", tabData, response, PHP_POST)
end

local function buyShopOfAliPay(  )
	local function response( data )
		dump(data)
		if data.code == 0 then
			Single:paltform():buyShopOfAliPay(data.data)
		end
	end
	local tabData = {}
	tabData['goods_name'] = payData["diamonds"].."颗钻石"
	tabData['waresid'] = payData['id']
	tabData['total_fee'] = payData['money']
	XMLHttp.requestHttp("aliPay", tabData, response, PHP_POST)
end

local function buyShopOfApplePay(  )
	local str = "com.allbetspace."..payData['money'].."."..payData['id']
	local tab = {purchase = str, diamonds = payData["diamonds"], id = payData['id'], money = payData['money'] }
	Single:paltform():buyShopOfApplePay(tab)
end

function PayPop:ctor( data )
	
	_payPop = self
	_payPop:setSwallowTouches()
	_payPop:addTransitAction()

	payData = {}
	IOS_PAY = {}
	ANDROID_PAY = {}

	payData = data
	-- dump(payData)

	local colorLayer = cc.LayerColor:create(cc.c4b(10, 10, 10, 50))
	colorLayer:setPosition(cc.p(0,0))
	self:addChild(colorLayer)

	-- IOS_PAY = {"user/pay_icon_weixin_", "user/pay_icon_ali_", "user/pay_icon_apple_"}
	IOS_PAY = {"user/pay_icon_weixin_", "user/pay_icon_apple_"}
	ANDROID_PAY = {"user/pay_icon_weixin_", "user/pay_icon_ali_"}

	local _platform = cc.Application:getInstance():getTargetPlatform()
	if (cc.PLATFORM_OS_IPHONE == _platform) or (cc.PLATFORM_OS_IPAD == _platform) or (cc.PLATFORM_OS_MAC == _platform)  then
		PAY_ICON = IOS_PAY
		_plat = "ios"
	elseif _platform == cc.PLATFORM_OS_ANDROID then
		PAY_ICON = ANDROID_PAY
		_plat = "android"
	else
		assert(nil, 'platform.getInstance')
	end

	self:createLayer()

end

function PayPop:createLayer(  )
	
	local width = display.width-80
	local height = 390

	local bgSize = cc.size(width, height)
	local bgSp1 = UIUtil.addImageView({image = "common/common_notify_bg.png", touch=false, scale=true, size=bgSize, pos=cc.p(display.cx, display.cy), ah =cc.p(0.5, 0.5), parent=self})
	local sp_w = bgSp1:getContentSize().width
	local sp_h = bgSp1:getContentSize().height
	-- local bgSp2 = UIUtil.addImageView({image = "common/common_notify_bg1.png", touch=false, scale=true, size=bgSize, pos=cc.p(sp_w/2, sp_h/2), ah =cc.p(0.5, 0.5), parent=bgSp1})
	local bgSp3 = UIUtil.addImageView({image = "common/common_notify_bg2.png", touch=false, scale=true, size=bgSize, pos=cc.p(sp_w/2, sp_h/2), ah =cc.p(0.5, 0.5), parent=bgSp1})
	bgSp3:setLocalZOrder(10)
	
	local font_color = {cc.c3b(208, 193, 104), cc.c3b(202, 203, 205), cc.c3b(184, 117, 88)}

	local contSize = cc.size(bgSize.width-50, bgSize.height-110)
	local bgSp = UIUtil.addImageView({image = "common/common_sngpop_little_bg.png", touch=false, scale=true, size=contSize, pos=cc.p(sp_w/2, 25), ah =cc.p(0.5, 0), parent=bgSp3})

	local payStr = UIUtil.addLabelArial("购买:", 30, cc.p(70, sp_h-45), cc.p(0, 0.5), bgSp3):setColor(cc.c3b(142, 199, 223))
	local payNum = UIUtil.addLabelArial(payData.diamonds.."颗钻石", 40, cc.p(payStr:getPositionX()+payStr:getContentSize().width+15, sp_h-45), cc.p(0, 0.5), bgSp3)
	payStr:setLocalZOrder(15)
	payNum:setLocalZOrder(15)
	local priNum = UIUtil.addLabelArial(payData.money.."元", 40, cc.p(width-70, sp_h-45), cc.p(1, 0.5), bgSp3)
	local priStr = UIUtil.addLabelArial("价格:", 30, cc.p(width-70-priNum:getContentSize().width-15, sp_h-45), cc.p(1, 0.5), bgSp3):setColor(cc.c3b(142, 199, 223))
	priStr:setLocalZOrder(15)
	priNum:setLocalZOrder(15)

	local payBtn = {}
	local function payCallback( sender )
		local tag = sender:getTag()
		for k,v in pairs(payBtn) do
			if tag == v:getTag() then
				v:setTouchEnabled(false)
				v:setBright(false)
			else
				v:setTouchEnabled(true)
				v:setBright(true)
			end
		end
		self:removeFromParent()
		if tag == 1 then
			buyShopOfWeiXin()
		elseif tag == 2 then
			if _plat == "ios" then
				buyShopOfApplePay()
			else
				buyShopOfAliPay()
			end
		end
	end
	local size1, size2 = 0, 0
	size1 = 93
	size2 = 167
	for i=1,#PAY_ICON do
		payBtn[i] = UIUtil.addImageBtn({norImg = PAY_ICON[i].."2.png", selImg = PAY_ICON[i].."1.png", disImg = PAY_ICON[i].."1.png", ah = cc.p(0,0.5), pos = cc.p((i*size1)+(i-1)*size2, bgSp:getContentSize().height/2), touch = true, swalTouch = false,  listener = payCallback, parent = bgSp})
		payBtn[i]:setTag(i)
	end
	-- payBtn[1]:setBright(false)

	local function leftListener(  )
		self:removeFromParent()
	end
	local btn_left = UIUtil.addImageBtn({norImg = "common/set_card_MTT_close.png", selImg = "common/set_card_MTT_close_height.png", ah = cc.p(0.5,0.5), pos = cc.p(width-20, height-20), touch = true, swalTouch = false, listener = leftListener, parent = bgSp1})
	btn_left:setTitleColor(ResLib.COLOR_BLUE)

	bgSp1:setScale(0.5)
	local seq = cc.Sequence:create(cc.ScaleTo:create(0.2, 1.1), cc.ScaleTo:create(0.2, 1))
	bgSp1:runAction(seq)

end

return PayPop