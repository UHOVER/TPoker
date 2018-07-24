--
-- Author: Taylor
-- Date: 2016-12-07 22:52:12
-- 保险界面的主UI
local scheduler = cc.Director:getInstance():getScheduler()

--文字
local TEXT_GIVE_UP 		= "放弃"
local TEXT_PURCHASE_1   = "请选择分池"
local TEXT_PURCHASE_2   = "购买保险"
local TEXT_SAVE_BASE    = "保本"
local TEXT_CLICK_HERE   = "请点击此处"
local TEXT_SUM_INSURED  = "投保额"
local TEXT_TOTAL_BET    = "全底池"
local TEXT_EQUAL_PROFIT = "等利"
local TEXT_LOSS_RATIO   = "赔付额"
local TEXT_OUTS         = "OUTS"
local TEXT_PAY 			= "支付"
local TEXT_ODDS 		= "赔率"
local TEXT_CONPENSAGE   = "赔付"
local TEXT_SELECT_ALL   = "全选"
local TEXT_INVESTING 	= "投入%d"

local TEXT_NOTICE_SELECT= "已选：%s张"
local TEXT_MAX_POOL = "底池"
local TEXT_PUBLIC_CARDS = "公共牌"
local TEXT_WO_CUOPAI = "我要搓牌"
local TEXT_GREATHER_THAN = "您的投保额大于了底池的1/3,不能投保"
local TEXT_MUST_BUY      = "当前牌局必须购买所有outs值"
local TEXT_COUNT_DOWN 	 = "倒计时：%ds"
local TEXT_DIAMOND_LESS  = "您的钻石不足！"
--TAG 值
local TAG_BTN_GIVE_UP      = 11  
local TAG_BTN_PURCHASE     = 12
local TAG_BTN_SAVEBTN      = 13
local TAG_BTN_EQUAL_PROFIT = 14
local TAG_BTN_TWRIST  = 15

local TAG_LABEL_GIVE_UP    = 100
local TAG_LABEL_PURCHASE   = 101
local TAG_LABEL_SAVEBTN    = 103
local TAG_LABEL_EQUAL_PROFIT = 104

local TAG_PUBLIC_CARD 	= 110

local TAG_TIPS 			= 150
local TAG_ICON 			= 151
local TAG_CHIP_POOL     = 152
local TAG_CHIP_POOL2 	= 153

local TAG_ODDS_CK		= 133
local TAG_OUTS 			= 134
local TAG_ODDS_VAL 		= 135
local TAG_OUTS_VAL 		= 136


local TAG_PLAYER_NAME   = 180
local TAG_PLAYER_STATE  = 181
local TAG_PLAYER        = 190

local ITEM_COUNT 		= 4

-- 不同的模式
local SHOW_MODE = {
					insures_mode = 1, --购买保险
					cuopai_mode  = 2, --搓牌模式
					none_mode    = 3, --其他模式
				  }
-- 局
local CARD_PART = {
					Turn_over  	 = 1, -- 转牌局
					River		 = 2, -- 河牌局	
				  }
--是否购买模式
local function isPurchaseMode(curMode)
	return curMode == SHOW_MODE.insures_mode
end
--是否搓牌模式
local function isCuopaiMode(curMode)
	return curMode == SHOW_MODE.cuopai_mode
end
--是否观察模式
local function isLookerMode(curMode)
	return curMode == SHOW_MODE.none_mode
end

--创建选手
local function createPlayers(name, card1, card2, statusText, isblink, isMe)
	-- local layerColor = cc.LayerColor:create()
	-- layerColor:setContentSize(cc.size(151, 125))
	-- local drawNode = cc.DrawNode:create()
	-- UIUtil.drawNodeRoundRect(drawNode, cc.rect(0, 0, 151, 125), 2, 10, cc.c4f(6/255,40/255,52/255,1),cc.c4f(6/255,40/255,52/255,1))
	-- drawNode:setAnchorPoint(cc.p(.5, .5))
	-- drawNode:setContentSize(cc.size(151,125))
	-- drawNode:setPosition(cc.p(151/2,125*3/2))
	-- layerColor:addChild(drawNode)
	local layerColor = cc.Scale9Sprite:create(ResLib.PLAYER_BG)
	layerColor:setContentSize(cc.size(146, 120))
	layerColor:setAnchorPoint(cc.p(0, 0))
	local card1 = UIUtil.addPosSprite(DZConfig.cardName(card1), cc.p(41, 65), layerColor,cc.p(.5, .5))
	local card2 = UIUtil.addPosSprite(DZConfig.cardName(card2), cc.p(95, 65), layerColor,cc.p(.5, .5))

	local scaleX, scaleY = 44/card1:getContentSize().width, 57/card1:getContentSize().height
	card1:setScaleX(scaleX)
	card1:setScaleY(scaleY)
	card2:setScaleX(scaleX)
	card2:setScaleY(scaleY)
	card1:setLocalZOrder(1)
	card2:setLocalZOrder(1)
	local label = nil 
	if isblink then 
		label = UIUtil.addLabelBold(name, 22, cc.p(74.5, 106), cc.p(.5, .5), layerColor)
		label:setTextColor(cc.c3b(238, 186, 85))
	else
		label = UIUtil.addLabelArial(name, 22, cc.p(74.5, 106), cc.p(.5, .5), layerColor)
		label:setTextColor(cc.c3b(27, 100, 126))
	end
	label:setTag(TAG_PLAYER_NAME)
	label:setLocalZOrder(1)

	local color = cc.c4b(142, 179, 191, 255)
	if isblink then 
		local blinkSp = cc.Scale9Sprite:create(ResLib.PLAYER_BLINK)
		blinkSp:setContentSize(cc.size(148,122))
		blinkSp:setPosition(cc.p(73,60))
		blinkSp:setLocalZOrder(10)
		layerColor:addChild(blinkSp)
		DZAction.blinkActionForever(blinkSp)
	end

	local statuText = cc.Label:createWithSystemFont(statusText, "Arial", 22)
	statuText:setAnchorPoint(cc.p(.5, .5))
	statuText:setAlignment(cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
	statuText:setTextColor(cc.c3b(238, 186, 85))
	statuText:setPosition(cc.p(74.5, 18))
	statuText:setTag(TAG_PLAYER_STATE)
	layerColor:addChild(statuText, 1)
	return layerColor
end

local InsuranceView = class("InsuranceView", function()
		return cc.Layer:create()
	end)

-- local _instanceBX = nil
-- function InsuranceView:getInstance()
-- 	if (_instanceBX == nil) then 
-- 		print("初始化问题 InsuranceView")
-- 		_instanceBX = InsuranceView.new()
-- 	end
-- 	return _instanceBX
-- end

function InsuranceView:clearView()
	_instanceBX = nil
end

function InsuranceView:ctor()
	-- print("初始化 购买保险的界面 ")
	self.insureLabel = nil    --提示投保额
	self.compenLabel = nil    --提示赔付率
	self.oddsLabel 	 = nil    --提示赔率
	self.iconText  	 = nil    --左上面的icon内容显示	

	self._imgTime    = nil 	  --img进度条控制
	self.slider 	 = nil 	  --选择滑动条
	self.maxPollText = nil  -- slider 显示的最大底池
	self.outsLabel   = nil  --out值显示
	self.pCardsNode  = nil  --公共牌容器
	self.listView 	 = nil  -- outs牌视图
	self.playerlistView = nil --选手ListView】
	self.twristBtn   = nil   --搓牌Btn
	self.saveBaseBtn = nil   --保本
	self.equalProfitBtn = nil --等利
	self.iconText 	 = nil    --底池显示
	self.equalProfitLabel    = nil  --等利的label提示
	self.saveBaseLabel = nil --保本label提示	
	--值

	self.tagInvestingNum = 0 --标记发送同步时的投保额
	self.tagOutsNum 	 = 0 --标记发送同步时的out值
	
	self.oddsVal = 0
	self.poodVal = 0
	self.selectCards = {}
	self.investingNum = 0
	self.outsAmount = 0

	self.mode = SHOW_MODE.none_mode
	self.cardPart = CARD_PART.Turn_over	
	self.mustBuy  = false
	self:initUI()

	self:enableNodeEvents()
end

function InsuranceView:initUI()
	local selfW, selfH = 750, 1165
	self:setAnchorPoint(cc.p(0.5,0))
	self:setContentSize(selfW, selfH)
	self:setPosition(cc.p(display.cx, 0))

	self._isSwallowImg = true 
	TouchBack.registerImg(self)
	
	local markBg = cc.LayerColor:create(cc.c4b(0, 0, 0, 255*0.7))
	markBg:ignoreAnchorPointForPosition(false)
	markBg:setContentSize(cc.size(selfW, 300))
	markBg:setAnchorPoint(cc.p(.5, 0))
	markBg:setPosition(cc.p(selfW/2,0))
	self:addChild(markBg)

	-- --初始化背景
	-- local bgSprite = cc.Scale9Sprite:create(ResLib.INSURANCE_BG)
	-- bgSprite:setContentSize(cc.size(selfW, 907))
	-- bgSprite:setAnchorPoint(cc.p(0, 0))
	-- bgSprite:setPosition(cc.p(0, 299))
	-- bgSprite:setInsetLeft(0)
	-- bgSprite:setInsetRight(0)
	-- bgSprite:setInsetTop(99/2)
	-- bgSprite:setInsetBottom(99/2)
	-- self:addChild(bgSprite)

	local operationBg = cc.Scale9Sprite:create(ResLib.OPERATION_BG)
	operationBg:setContentSize(cc.size(selfW, 890))
	operationBg:setAnchorPoint(cc.p(.5, 0))
	operationBg:setPosition(cc.p(selfW/2, 300))
	self:addChild(operationBg)

	self:initButton()
	self:initOutsCardView()
	self:initSliderView()
	self:initPoolCardsView()
	self:initPlayersView()
	self:initOperationView()

	local fszie = cc.Director:getInstance():getOpenGLView():getFrameSize()
	local ratio = fszie.width / fszie.height
	if ratio >= 320/480 then
		local frameszie = display.sizeInPixels
		local scalex, scaley = frameszie.width/ display.width, (frameszie.height)/selfH
		self:setScaleX(scaley)
		self:setScaleY(scaley)
		
		markBg:setScaleX(4)
		markBg:setScaleY((849+341-31)/341)
		operationBg:setScaleX(operationBg:getContentSize().width/scaley)
	end

	-- local frameszie = display.sizeInPixels
	-- if frameszie.width/frameszie.height <= 320/480 and display.height > frameszie.height then --320/480
	-- 	print("heheheh")
	-- 	local scalex, scaley = frameszie.width/ display.width, (frameszie.height)/selfH
	-- 	self:setScaleX(scaley)
	-- 	self:setScaleY(scaley)
		
	-- 	markBg:setScaleX(4)
	-- 	markBg:setScaleY((849+341-31)/341)
	-- 	operationBg:setScaleX(operationBg:getContentSize().width/scaley)
	-- end
end

---初始化购买按钮
function InsuranceView:initButton()
	local function giveUpHandler(sender, eventType)
		-- print("giveUpHandler")
		if eventType == ccui.TouchEventType.ended then 
			local selectCards = self.selectCards
			local selectType = 0
			local investNum = self.investingNum
			SocketCtrol.insuranPurchase(selectType, selectCards, investNum, handler(self, self.purchaseResult)) 
		end
	end
	local function purchaseHandler(sender, eventType)
		-- print("purchaseHandler")
		if eventType == ccui.TouchEventType.ended  then
			local selectCards = self.selectCards
			local selectType = 1
			local investNum = self.investingNum
			SocketCtrol.insuranPurchase(selectType, selectCards, investNum, handler(self, self.purchaseResult))
		end
	end
	local function getTimeConsume()
		local diamond = GSelfData.getInsureDelayDiamond()
		if diamond <= 0 then 
			return "免费", cc.c3b(166,254,255)
		else 
			return tostring(diamond).."钻", cc.c3b(166,254,255)
		end
	end
	local function addTimeHandler(sender, eventType)
		if eventType == ccui.TouchEventType.began  then 
		elseif eventType == ccui.TouchEventType.ended  then
			local label = sender:getChildByTag(18100)
			local response =  function() 
				local str, color = getTimeConsume()
				label:setString(str)
				label:setColor(color)
			end
			local rets = GSelfData.getDelayDiamondSet(2)
			if not rets[2] then 
				-- 出现一个弹出框 提示没有足够的钻石
				ViewCtrol.popHint({popType = 1, bgSize = cc.size(display.width-100, 300), 
							content = TEXT_DIAMOND_LESS, sureFunBack = function() end})
				print("钻石不足")
				do return end
			end
			print("购买保险思考时间")
			self.purchaseTick = os.time()
			sender:setTouchEnabled(false)
			SocketCtrol.requestDelayOther(2, response)			
		end
	end
	self.purchase_btn = UIUtil.addUIButton({ResLib.BUY, ResLib.BUY_PRESS, ResLib.BUY_DIS}, cc.p(display.width - 254, 213), self, purchaseHandler)
	self.give_btn = UIUtil.addUIButton({ResLib.GIVE_UP, ResLib.GIVE_UP_PRESS, ResLib.GIVE_UP_DIS}, cc.p(254, 213), self, giveUpHandler)
	self.addTime_btn = UIUtil.addUIButton({ResLib.GAME_DELAY, ResLib.GAME_DELAY,ResLib.GAME_DELAY_GRAY}, cc.p(141, 53), self, addTimeHandler)
	local str, color = getTimeConsume()
	local timeMoney = UIUtil.addLabelArial(str, 18, cc.p(54,100),cc.p(.5,.5),self.addTime_btn,color)
	timeMoney:setTag(18100)
	
	self._imgTime = UIUtil.progressReverse(ResLib.PROGRESS_BAR, cc.p(254,219), self)
	self._imgTime:setRotation(180)
	self._imgTime:setReverseDirection(false)
	-- UIUtil.addPosSprite(ResLib.PROGRESS_BAR, cc.p(254, 260), self, cc.p(.5,.5))
	-- self._imgTime:setPercentage(50)
	self._particle = GUI.particleSelfUI(ResLib.PROGRESS_BAR, cc.p(254, 219), self, cc.p(84, 17))
	-- self._particle:setLocalZOrder(2)
	
	self._timerLabel = UIUtil.addLabelArial(TEXT_COUNT_DOWN, 22,cc.p(603, 1127), cc.p(0, 0), self, cc.c3b(27, 100, 126))
	self._timerLabel:setVisible(false)

	local size = self:getContentSize()
	UIUtil.addPosSprite(ResLib.CHIP_BG, cc.p(10, 1127), self, cc.p(0, 0))
	local iconSp = UIUtil.addPosSprite(ResLib.ICON_TAG, cc.p(4, 1125), self, cc.p(0, 0))
	local iconText = UIUtil.addLabelArial("", 26, cc.p(49, 1127), cc.p(0, 0), self)
	iconText:setAlignment(cc.TEXT_ALIGNMENT_LEFT, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
	self.iconText = iconText


	local investLabel = UIUtil.addLabelArial(string.format(TEXT_INVESTING, self.investingNum), 22, 
			cc.p(138, 1127), cc.p(0,0), self, cc.c3b(142, 179, 191))
	investLabel:setLocalZOrder(11)
	self.investLabel = investLabel

	self.equalProfitLabel = UIUtil.addLabelArial(TEXT_EQUAL_PROFIT.." -", 20, cc.p(-1, -1), cc.p(0, .5), self, cc.c3b(238,186,85))
	self.saveBaseLabel = UIUtil.addLabelArial("- "..TEXT_SAVE_BASE, 20, cc.p(-1, -1), cc.p(0, .5), self, cc.c3b(238,186,85))

	local tipsLabel = UIUtil.addLabelArial(TEXT_GREATHER_THAN, 22, cc.p(475, 438), cc.p(0, 0), self, cc.c3b(255,0,0))
	tipsLabel:setDimensions(273,168)
	tipsLabel:setTag(TAG_TIPS)
end

--初始化其他可操作按钮
function InsuranceView:initOperationView()
	local function equalProfitHandler(sender, eventType)
		if eventType == ccui.TouchEventType.ended then 
			do return end
		end
		local tag = sender:getTag()
		local needInput = nil
		if (tag == TAG_BTN_EQUAL_PROFIT) then
			-- print("点击等力")
			needInput = GMath.getNeedCostByEP(#self.selectCards, self.poodVal)
		elseif (tag == TAG_BTN_SAVEBTN) then
			-- print("点击保本")
			needInput = GMath.getNeetCostByBE(#self.selectCards, self.betNum)
		end 
  		local slider = self.slider
  		slider:setValue(needInput)
  	end
  	local function cuopaiHandler(sender, event)
  		-- print("点击")
  		-- local 
	end
  	--等利按钮
  	local equalProfitBtn = UIUtil.addUIButton({ResLib.INSURAN_BTN, ResLib.INSURAN_BTN_PRESS, nil},cc.p(481, 314), self, equalProfitHandler)
  	equalProfitBtn:setAnchorPoint(cc.p(0,0))
  	equalProfitBtn:setTitleFontName("Helvetica-Bold")
  	equalProfitBtn:setTitleText(TEXT_EQUAL_PROFIT)
  	equalProfitBtn:setTitleFontSize(26)
  	equalProfitBtn:setTitleColor(cc.c3b(8,27,41))
  	equalProfitBtn:setTag(TAG_BTN_EQUAL_PROFIT)
  	self.equalProfitBtn = equalProfitBtn

  	--保本按钮
  	local saveBaseBtn = UIUtil.addUIButton({ResLib.INSURAN_BTN, ResLib.INSURAN_BTN_PRESS, nil},cc.p(618, 314), self, equalProfitHandler)
  	saveBaseBtn:setAnchorPoint(cc.p(0,0))
  	saveBaseBtn:setTitleFontName("Helvetica-Bold")
  	saveBaseBtn:setTitleFontSize(26)
  	saveBaseBtn:setTitleColor(cc.c3b(8,27,41))
	saveBaseBtn:setTitleText(TEXT_SAVE_BASE)
	saveBaseBtn:setTag(TAG_BTN_SAVEBTN)
	self.saveBaseBtn = saveBaseBtn

	--搓牌选项
	-- local twristBtn = UIUtil.addUIButton({ResLib.INSURAN_BTN, ResLib.INSURAN_BTN_PRESS, nil},cc.p(159, 1080), self, cuopaiHandler)
	-- twristBtn:setScale9Enabled(true)
	-- twristBtn:setContentSize(cc.size(238, 46))
	-- twristBtn:setTitleText(TEXT_WO_CUOPAI)
	-- twristBtn:setTitleColor(cc.c3b(0,0,0))
	-- twristBtn:setTag(TAG_BTN_TWRIST)
	-- self.twristBtn = twristBtn
	-- twristBtn:setVisible(false)
	-- --关闭按钮
	-- UIUtil.addUIButton({ResLib.BX_CLOSE, ResLib.BX_CLOSE_PRESS, nil}, cc.p(667, self:getContentSize().height),self,function() 
	-- 			  self:removeFromParent()
	-- 			end)
end

function InsuranceView:initOutsCardView()
	--total outs
	-- local outsName = UIUtil.addLabelArial(TEXT_OUTS, 26, cc.p(17, 852), cc.p(0, 0), self)
	-- local size = outsName:getContentSize()
	-- local totalOutsLabel = UIUtil.addLabelArial("0",36,cc.p(17 + size.width, 852), cc.p(0, 0), self,cc.c3b(238, 186, 85))
	-- totalOutsLabel:setTag(TAG_OUTS)
	--another outs
	self.outsLabel = UIUtil.addLabelArial(string.format(TEXT_NOTICE_SELECT, 0), 26, cc.p(143, 758), cc.p(0, 0), self, cc.c3b(238, 186, 85))
	--outs牌
	local listView = ccui.ListView:create()
	listView:setDirection(ccui.ScrollViewDir.vertical)
	listView:setBounceEnabled(true)
	listView:setScrollBarEnabled(true)
	listView:setBackGroundImage(ResLib.PLAYER_BG)
    listView:setBackGroundImageScale9Enabled(true)
	listView:setContentSize(cc.size(278, 420))
	listView:setItemsMargin(10.0)
	listView:setGravity(ccui.ListViewGravity.centerHorizontal)
	listView:setMagneticType(2)
	listView:setPosition(cc.p(13, 314))
	
	local default_item = ccui.Layout:create()
	default_item:setTouchEnabled(true)
	default_item:setContentSize(269,81)
	listView:setItemModel(default_item)
	self:addChild(listView)
	self.listView = listView
	local function selectAllEvent(sender, eventType)
		print("---===selectAllEvent")
		local items = self.listView:getItems()
		local setAllItemsSelectFuc = function(isSelect)
			local selectIndexs = {}
			for i,v in ipairs(items) do
				for i = 0, ITEM_COUNT -1 do 
					local ckbox = v:getChildByTag(i)
					if ckbox then 
						ckbox:setSelected(isSelect)
						selectIndexs[#selectIndexs + 1] = ckbox.cardIndex
					end
				end
			end
			return selectIndexs
		end
		if ccui.CheckBoxEventType.selected == eventType then 
			self.selectCards = setAllItemsSelectFuc(true)
		elseif ccui.CheckBoxEventType.unselected == eventType then 
			setAllItemsSelectFuc(false)
			self.selectCards = {}
		end
		 self:updateSelectOutsLabel()
         self:updateInuraceBar()
         self:updateButtonStatus()
         -- self:sendSynchroniztionUI()
	end
	-- UIUtil.addUIButton({ResLib.SELECT_ALL_NORMAL, ResLib.SELECT_ALL_SELECTED}, cc.p(32, 802), self, selectAllEvent)
	UIUtil.addLabelArial(TEXT_SELECT_ALL, 26, cc.p(53 ,758), cc.p(0, 0), self,cc.c3b(238, 186, 85))
	local checkBox = UIUtil.addCheckBox({checkBg = ResLib.SELECT_ALL_NORMAL, 
						checkBtn = ResLib.DUI_GOU,
						pos = cc.p(13, 758),
					    parent = self,
					    checkboxFunc = selectAllEvent})
	checkBox:setAnchorPoint(cc.p(0,0))
	-- checkBox:ignoreContentAdaptWithSize(false)
	-- checkBox:setContentSize(cc.size(36,36))
	checkBox:setTag(TAG_ODDS_CK)

	UIUtil.addPosSprite(ResLib.OUTS_BORDER, cc.p(11, 754), self, cc.p(0, .5))
	local border = UIUtil.addPosSprite(ResLib.OUTS_BORDER, cc.p(11 + 139, 318), self, cc.p(0.5, .5))
	border:setRotation(180)
end

function InsuranceView:initSliderView()
	local function percentChangeHandler(pSender)
		local value = math.floor(pSender:getValue())
		print("投保额变化:"..value)
		
		local outsNum = #self.selectCards
		if outsNum > 0 then 
			self.investingNum = value
		else 
			self.investingNum = 0
		end
		self:updateRelatedLabel()
		self:updateButtonStatus()
		if not pSender.isUpdate then 
			pSender.isUpdate = true
			do return end
		end
		-- self:sendSynchroniztionUI()
	end
 
	local tslider = cc.ControlSlider:create(ResLib.SLIDER_TRUCK, ResLib.SLIDER_TRUCK, ResLib.SLIDER_THUMB, ResLib.SLIDER_THUMB_2)
    tslider:setAnchorPoint(cc.p(0.5, 0.5))
    tslider:setContentSize(tslider:getContentSize().width, tslider:getContentSize().height)
    tslider:setPosition(cc.p(display.cx, 560))
    tslider:setMinimumValue(0) 
    tslider:setMaximumValue(100) 
	tslider:registerControlEventHandler(percentChangeHandler, cc.CONTROL_EVENTTYPE_VALUE_CHANGED)
 	tslider:setRotation(-90)
 	-- local thumbSize = tslider:getThumbSprite():getContentSize()
  --   tslider:getThumbSprite():setContentSize(thumbSize.height, thumbSize.width)
  --   tslider:getSelectedThumbSprite():setContentSize(thumbSize.height, thumbSize.width)
 	tslider.isUpdate = false

    local sp = UIUtil.addPosSprite(ResLib.SLIDER_MAXS,cc.p(display.cx, 779), self, cc.p(.5,.5))
    local pt = cc.p(sp:getContentSize().width/2, sp:getContentSize().height/2)
  	UIUtil.addLabelArial(TEXT_MAX_POOL, 26, pt,cc.p(.5,0), sp, cc.c4b(238,186,85,255))
  	self.maxPollText = UIUtil.addLabelArial("0", 26, pt,cc.p(.5,1), sp, cc.c4b(238,186,85,255))
  	self:addChild(tslider)
    self.slider = tslider
end

function InsuranceView:initPoolCardsView()
	UIUtil.addLabelArial(TEXT_PUBLIC_CARDS, 26, cc.p(474, 758), cc.p(0, 0), self, cc.c3b(238, 186, 85))

	local public_cards_pos = {cc.p(0, 0), cc.p(52, 0), cc.p(104, 0), cc.p(156, 0), cc.p(208, 0)}
	--public cards
	local pt  = cc.p(481, 672)
	local size = cc.size(258, 67)
	local node = cc.Node:create()
	node:setAnchorPoint(cc.p(0, 0))
	node:setContentSize(size)
	node:setPosition(pt)
	self:addChild(node)

	for i,v in ipairs(public_cards_pos) do
		local p = public_cards_pos[i]
		local cardItem = cc.Node:create()
		cardItem:setContentSize(cc.size(47,67))
		cardItem:setAnchorPoint(cc.p(0,0))
		cardItem:setPosition(p)
		cardItem:setTag(TAG_PUBLIC_CARD + i)
		node:addChild(cardItem)
	end
	self.pCardsNode = node

	UIUtil.addLabelArial(TEXT_SUM_INSURED, 24, cc.p(206, 1048),cc.p(0,0), self, cc.c3b(142, 179, 191))
	UIUtil.addLabelArial(TEXT_LOSS_RATIO, 24, cc.p(351, 1048),cc.p(0,0), self, cc.c3b(142, 179, 191))
	UIUtil.addLabelArial(TEXT_ODDS, 24, cc.p(500, 1048), cc.p(0, 0),self, cc.c3b(142, 179, 191))

	self.insureLabel = UIUtil.addLabelArial("0", 34, cc.p(243, 1084), cc.p(.5, 0), self, cc.c3b(238, 186, 85))
	self.compenLabel = UIUtil.addLabelArial("0", 34, cc.p(382, 1084), cc.p(.5, 0), self, cc.c3b(238, 186, 85))    --提示赔付率
	self.oddsLabel 	 = UIUtil.addLabelArial("0", 34, cc.p(524, 1084), cc.p(.5, 0), self, cc.c3b(238, 186, 85))    --提示赔付率

	local trunConsumeNode = cc.Node:create()
	local size  = UIUtil.addLabelArial("需扣除转牌投保额", 20, cc.p(0, 0), cc.p(0,0), trunConsumeNode, cc.c3b(111,115,117)):getContentSize()
	local consumeNumLabel = UIUtil.addLabelArial("100", 20, cc.p(size.width, 0),cc.p(0,0), trunConsumeNode, cc.c3b(204,198,136))	
	consumeNumLabel:setTag(10)
	trunConsumeNode:setContentSize(size)
	trunConsumeNode:setPosition(display.cx - trunConsumeNode:getContentSize().height/2, 1005)
	self:addChild(trunConsumeNode)
	self.trunConsumeNode = trunConsumeNode
	trunConsumeNode:setVisible(false)
end

function InsuranceView:initPlayersView()
	local playerlistView = ccui.ListView:create()
	playerlistView:setDirection(ccui.ScrollViewDir.horizontal)
	playerlistView:setBounceEnabled(true)
	playerlistView:setScrollBarEnabled(true)
	playerlistView:setContentSize(cc.size(688, 125))
	playerlistView:setItemsMargin(10.0)
	playerlistView:setMagneticType(2)
	playerlistView:setPosition(cc.p(29, 837))
	playerlistView:setBackGroundColor(cc.c4b(255,255,255,255))

	local default_item = ccui.Layout:create()
	default_item:setTouchEnabled(true)
	default_item:setContentSize(122,164)
	playerlistView:setItemModel(default_item)
	self:addChild(playerlistView)
	self.playerlistView = playerlistView

	local lineTop = cc.LayerColor:create(cc.c3b(27,100,126))
	local lineBottom = cc.LayerColor:create(cc.c3b(27,100,126))
	lineTop:setContentSize(cc.size(721, 2))
	lineBottom:setContentSize(cc.size(721, 2))
	lineTop:setPosition(cc.p(14,986))
	lineBottom:setPosition(cc.p(14,817))
	self:addChild(lineBottom)
	self:addChild(lineTop)
end

-----------------------------------------
-- 
-- 更新界面变化
------------------------------------------

--更新显示选手
function InsuranceView:updatePlayer(players)
	if not self.playerlistView then 
		return 
	end
	local listView = self.playerlistView
	listView:removeAllItems()
	-- local isMe = (self.mode == SHOW_MODE.insures_mode)
	local betInPool = 0
	for i, v in ipairs(players) do 
		local user = UserCtrol.getSeatUserByPos(v.seatNum)
		local userName = nil
		if (user) then 
			userName = user:getUserName()
		else 
			userName = "nil"
		end

		local statuText = #v.outs.."个outs"
		if (i==1) then 
			statuText, isBlink = "正在购买中", true
			betInPool = v.betInPool
			if isPurchaseMode(self.mode) then 
				userName = "我"
			end
		end
		-- print("v.seatNum:"..v.seatNum)
		
		
		local playerNode = createPlayers(userName, v.cards[1], v.cards[2], statuText, i==1, isPurchaseMode(self.mode))
		 
		local item = ccui.Layout:create()
		item:setContentSize(cc.size(playerNode:getContentSize().width, playerNode:getContentSize().height))
		playerNode:setPosition(cc.p(0, 0))
		item:addChild(playerNode)
		listView:pushBackCustomItem(item)
	end
	self.investLabel:setString(string.format(TEXT_INVESTING,betInPool))
end

--更新底池公共牌
function InsuranceView:updatePoolCards(poolCards)
	if not self.pCardsNode then 
		return 
	end 

	local node = self.pCardsNode
	for i = 1, 5 do
		local item = node:getChildByTag(TAG_PUBLIC_CARD + i)
	 	item:removeAllChildren()
		if i <= #poolCards + 1 then 
			local v = poolCards[i]
			local name = ResLib.COM_CARD
			if v then 
		 	  name = DZConfig.cardName(v)
		 	end
		 	local sp = display.newSprite(name, 0, 0)
		 	sp:setAnchorPoint(cc.p(0, 0))
		 	local size = item:getContentSize()
		 	-- print("SP:"..type(sp))
		 	sp:setScaleX(size.width / sp:getContentSize().width)
		 	sp:setScaleY(size.height/ sp:getContentSize().height)
		 	item:addChild(sp) 
		end
	end
end

--更新out值牌区域
function InsuranceView:updateOutCards(outcards)
	local listView = self.listView
	listView:removeAllItems()
	if not listView then 
		return
	end
	
	 table.sort(outcards, function(a, b)
            local cardA, cardB = (a-1)%13, (b-1)%13
            if cardA == cardB then
                return a > b
            end
            return cardA > cardB
        end)
	dump(outcards,"outs卡牌")
	local ckSelectAllBtn = self:getChildByTag(TAG_ODDS_CK)
	ckSelectAllBtn:setSelected(true)

	self.selectCards = outcards
	self.outsAmount = #outcards
	local cout_perrow, itemW, itemH = ITEM_COUNT, 269, 81
	local subItemW, subItemH 		= (itemW - 12*3)/cout_perrow, itemH--57, 81
	local count = math.ceil(#outcards / cout_perrow)

	for i = 0, count - 1 do 
		local startIndex = i * cout_perrow + 1
		local endIndex = math.min(startIndex + cout_perrow - 1, #outcards) 
		local layoutItem = ccui.Layout:create()
		layoutItem:setContentSize(cc.size(itemW, itemH))
		layoutItem:setAnchorPoint(cc.p(0, 0))
		layoutItem:setBackGroundColor(cc.c3b(255,0,0))
	
		for j = startIndex, endIndex do 
			local v = outcards[j]
			local subIndex = (j-1) % 4
			local itemPosx, itemPosy = subIndex * (subItemW+12), 0
			local ckbox = UIUtil.addCheckBox({
							checkBg = DZConfig.cardName(v),
							checkBtn = ResLib.BIG_DUI_GOU,
							pos = cc.p(itemPosx + subItemW/2, itemPosy + subItemH/2),
							parent = layoutItem,
							checkboxFunc= handler(self, self.clickOutsHandler)
						})

			ckbox:setScaleX(subItemW/ckbox:getContentSize().width)
			ckbox:setScaleY(subItemH/ckbox:getContentSize().height)
			ckbox:setTouchEnabled(isPurchaseMode(self.mode))
			ckbox:setTag(subIndex)
			ckbox:setSelected(true)
			ckbox.subIndex = subIndex
			ckbox.row  	   = i
			ckbox.cardIndex= v
		end
		listView:pushBackCustomItem(layoutItem)
	end
	-- local totalOutsLabel = self:getChildByTag(TAG_OUTS)
	-- totalOutsLabel:setString(#outcards)
	self:updateSelectOutsLabel()
end

--根据选中的out值发生改变
function InsuranceView:processOutsSelectItems(selectIndexs)
end

function InsuranceView:clickOutsHandler(sender, eventType)
		if not isPurchaseMode(self.mode) then 
			return 
		end
		print("====clickOutsHandler ---"..tostring(self.mustBuy).." cardPart:"..tostring(self.cardPart))
		if self.mustBuy and self.cardPart == CARD_PART.River then 
			self:updateRelatedLabel()
			sender:setSelected(true)
			do return end 
		end
		
		local selectCards = self.selectCards
		-- local preSelectCardsNum = #selectCards
		local cardIndex  =  sender.cardIndex
		local index = table.indexof(selectCards, cardIndex)
	    if eventType == ccui.CheckBoxEventType.selected then
            if (not index or index <= 0 ) then
            	selectCards[#selectCards + 1] = cardIndex
            end
        elseif eventType == ccui.CheckBoxEventType.unselected then
            if (index >= 0) then 
            	table.remove(selectCards,index)
            end
        end

        local ckAllBtn = self:getChildByTag(TAG_ODDS_CK)
     	local isSelect = (#selectCards >= self.outsAmount)
     	ckAllBtn:setSelected(isSelect)

        -- if preSelectCardsNum == #selectCards then 
        -- 	do return end
        -- end
        self.selectCards = selectCards
        self:updateSelectOutsLabel()
        self:updateInuraceBar()
        self:updateButtonStatus()
        -- self:sendSynchroniztionUI()
end
--更新投保额的bar位置
function InsuranceView:updateInuraceBar(tmpVal, minVal, maxVal)
	 local selectCards = self.selectCards
	 if not selectCards then  
	 	return 
	 end
 	 dump(selectCards, "变动了outs卡牌:")
	 local slider = self.slider           --slider
 	 local maxVal = maxVal or slider:getMaximumValue()
 	 local minVal = minVal or slider:getMinimumValue()
 	 local curVal = tmpVal or slider:getValue()
 	 local percent = curVal / (maxVal - minVal)
 	 local poolBet = self.poodVal
	 local outsNum = #selectCards
	 -- print("minVal:"..minVal.." maxVal:"..maxVal.." curVal:"..curVal)
	 -- print("self.investingNum:"..self.investingNum)
	 -- print("outsNum:"..outsNum.."||| poolBet:"..tostring(poolBet))
	 local oddsVal = 0
	 if outsNum > 0 then 
	 	--正常计算最大最小投保额
	 	oddsVal  = DZConfig.getOddsValue(outsNum)
	 	maxVal = poolBet/oddsVal
	 	if maxVal < 1 then 
	 		maxVal = math.ceil(poolBet/oddsVal)
	 	else 
	 		maxVal = math.floor(poolBet/oddsVal) --最大投保额
	 	end
		minVal = 0                           --最小投保额
		--触发必须购买，并且是河牌局时，修正投保额数量
	 	if self.mustBuy and self.cardPart == CARD_PART.River then 
	 		 minVal = math.ceil(self.turnInsured / oddsVal)
	 		 maxVal = math.min(maxVal, poolBet - self.turnInsured)
	 	end
	 else
	 	maxVal , minVal , percent = 1, 0, 0
	 end
	 slider.isUpdate = false
	 slider:setMinimumValue(minVal) 
	 slider.isUpdate = false 
     slider:setMaximumValue(maxVal) 
     slider.isUpdate = false
     slider:setValue((maxVal - minVal) * percent)

     --等利换算
	local equalProfitVal = GMath.getNeedCostByEP(#self.selectCards, self.poodVal)
	local saveBaseVal = GMath.getNeetCostByBE(#self.selectCards, self.betNum)
	local sliderSize = self.slider:getBackgroundSprite():getContentSize()
	local tmpX ,tmpY= self.slider:getPositionX(),self.slider:getPositionY() - sliderSize.width/2
	local equalPosY = math.min(sliderSize.width * (equalProfitVal - minVal)/(maxVal-minVal), sliderSize.width-45)
	local savePosY = math.min(sliderSize.width * (saveBaseVal - minVal)/ (maxVal - minVal), sliderSize.width-45)
	print("minVal:"..minVal.."maxVal:"..maxVal)
	print("poolbet:"..self.poodVal, "等利:"..equalProfitVal.." 保本:"..saveBaseVal)
	print("等利Y坐标"..(tmpY + equalPosY), "保本Y坐标:"..(tmpY + savePosY))
	-- local offset = cc.p(0, 0)
	-- local eRect, sRect = cc.rect(tmpX+10, tmpY+equalPosY, 60, 20), cc.rect(tmpX + 10, tmpY + savePosY, 60, 20)
	-- local isIntersect = cc.rectIntersectsRect(eRect, sRect)
	-- if isIntersect then 
	-- 	offset.x = 60
	-- end
	self.equalProfitLabel:setPosition(cc.p(tmpX - 60, tmpY + equalPosY))
	self.saveBaseLabel:setPosition(cc.p(tmpX + 10, tmpY + savePosY))
    self:updateRelatedLabel()

    --提示上一次没有买中所花费了的投保额
    if isPurchaseMode(self.mode) and self.turnInsured and self.turnInsured > 0 then
    	local size = self.trunConsumeNode:getContentSize()
    	local label = self.trunConsumeNode:getChildByTag(10)
    	label:setString(tostring(self.turnInsured))
    	self.trunConsumeNode:setPositionX(display.cx - size.width/2-label:getContentSize().width/2)
    	self.trunConsumeNode:setVisible(true)
    else 
    	self.trunConsumeNode:setVisible(false)
    end
end 

--更新按钮状态
function InsuranceView:updateButtonStatus()
	local equalProfitBtn = self.equalProfitBtn
	local saveBaseBtn = self.saveBaseBtn
	-- local twristBtn = self.twristBtn
	local timeBtn  = self.addTime_btn
	local buyBtn  = self.purchase_btn
	local giveBtn = self.give_btn
	local imgTime = self._imgTime
	local isPurchase = isPurchaseMode(self.mode)
--  local isCuopai  = isCuopaiMode(self.mode)
	local investNum = self.investingNum
	local outsNum  = #self.selectCards
	local ckSelectAllBtn = self:getChildByTag(TAG_ODDS_CK)
--  print("investNum:"..investNum, "outsNum"..outsNum.."  isPurchase:"..tostring(isPurchase))
	local isTouch = (isPurchase and outsNum > 0)
--  print("isTouch:"..tostring(isTouch))
	equalProfitBtn:setTouchEnabled(isTouch)
	saveBaseBtn:setTouchEnabled(isTouch)
--  twristBtn:setTouchEnabled(isCuopai)
	equalProfitBtn:setBright(isTouch)
	saveBaseBtn:setBright(isTouch)
	timeBtn:setTouchEnabled(isPurchase)
	ckSelectAllBtn:setTouchEnabled(isPurchase and (not self.mustBuy))

	timeBtn:setVisible(isPurchase)
	equalProfitBtn:setVisible(isPurchase)
	saveBaseBtn:setVisible(isPurchase)
	buyBtn:setVisible(isPurchase)
	giveBtn:setVisible(isPurchase)
	imgTime:setVisible(isPurchase)
	self._particle:setVisible(isPurchase)

	local max = nil
	if (self.cardPart == CARD_PART.Turn_over) then 
		max = self.poodVal / 3
	else 
		max = self.poodVal
	end
    local isBuy = (isPurchase and investNum > 0 and investNum <= max)
    local isGiveUp = (isPurchase and not self.mustBuy)
	buyBtn:setTouchEnabled(isBuy)
	buyBtn:setBright(isBuy)
	giveBtn:setTouchEnabled(isGiveUp)
	giveBtn:setBright(isGiveUp)

	local thumbSp = self.slider:getThumbSprite()
	local selectThumbSp = self.slider:getSelectedThumbSprite()
	if not isPurchase then 
		UIUtil.setGLProgramStateToNode(thumbSp, "ShaderUIGrayScale")
		UIUtil.setGLProgramStateToNode(selectThumbSp, "ShaderUIGrayScale")
	else 
		UIUtil.setGLProgramStateToNode(thumbSp, nil)
		UIUtil.setGLProgramStateToNode(selectThumbSp, nil)
	end
	self.slider:setEnabled(isPurchase)
end
--更新选中的out值
function InsuranceView:updateSelectOutsLabel()
    self.outsLabel:setString(string.format(TEXT_NOTICE_SELECT, #self.selectCards))
end
--更新out值，投保额变化相关信息
function InsuranceView:updateRelatedLabel()
	if self.investingNum >= 0 then
		self.insureLabel:setString(self.investingNum)
	end

	--初始化提示
	local tipsLabel = self:getChildByTag(TAG_TIPS)
	if self.investingNum >= math.max(self.poodVal/3) and self.cardPart == CARD_PART.Turn_over then 
		tipsLabel:setString(TEXT_GREATHER_THAN)
	elseif self.mustBuy and self.cardPart == CARD_PART.River then 
		tipsLabel:setString(TEXT_MUST_BUY)
	else 
		tipsLabel:setString("")
	end
	local outsNum = #self.selectCards
	local oddsVal = 0
	if outsNum > 0 then 
		 oddsVal = DZConfig.getOddsValue(outsNum)
	end
	self.compenLabel:setString(math.ceil(oddsVal * self.investingNum))
	self.oddsLabel:setString(oddsVal)
end

--设置状态，这里控制一些UI的隐藏与显示，以及一些按钮按钮
function InsuranceView:setInsuranceStatus(cardPart, mode, mustBuy)
	self.mode = mode
	self.cardPart = cardPart
	self.mustBuy = mustBuy
	-- print("设置模式: self.mode"..self.mode .." self.cardPart"..self.cardPart .. " self.mustBuy"..tostring(self.mustBuy))
	if self.mustBuy then 
		self._particle:setPosition(cc.p(display.width - 254, 219))
		self._imgTime:setPosition(cc.p(display.width - 254, 219))
	else
		self._particle:setPosition(cc.p(254, 219))
		self._imgTime:setPosition(cc.p(254, 219))
	end
end
--设置底池
function InsuranceView:setPoolBet(poolbet)
	self.poodVal = poolbet
	self.iconText:setString(self.poodVal)
	self.maxPollText:setString(self.poodVal)
	print("poolBet"..self.poodVal)
end

--显示或隐藏相关的时间信息
function InsuranceView:disTime()
	if true or not isPurchaseMode(self.mode) then 
		self._timerLabel:setVisible(true)
		self._timerLabel:stopAllActions()
	else 
		self._timerLabel:setVisible(false)
	end
end

--添加运行时间
function InsuranceView:runTime(rtime)
	local percent,delayTime = DZConfig.getRunPercentAndTime(rtime, 2)
	print("self.purchaseType:"..tostring(self.mode))
	if self.purchaseTick ~= nil and self.purchaseTick  > 0 then 
	   self.purchaseTick = os.time() - self.purchaseTick --做一个同步处理
	   delayTime = math.max(delayTime - self.purchaseTick, 0)
	   self.purchaseTick = nil
	   self.addTime_btn:setTouchEnabled(true)
	end

	print("时间进度:percent:"..percent, "delayTime:"..delayTime.. "  rttime:"..tostring(rtime))
	self:disTime()
	local startV, endV = 10, 90
	if percent > endV then 
		percent = endV
	end

	local particle = self._particle
	local rotateV = GMath.particleSelfValue(endV, startV, percent, 350, 10)
    particle:setRotation(rotateV)
 	
 	particle:stopAllActions()
    self._imgTime:stopAllActions()
    DZAction.progressBack(self._imgTime, startV, delayTime, function() end, percent)
	local rotate = cc.RotateTo:create(delayTime, -305)
    particle:runAction(rotate)

    if true or not isPurchaseMode(self.mode) then 
    	self._timerLabel:stopAllActions()
    	local count = 0
    	local delay = cc.DelayTime:create(1)
    	local callback = cc.CallFunc:create(function() 
    			 if count > delayTime then 
    			 	self._timerLabel:stopAllActions()
    			 	do return end
    			 end
    			 self._timerLabel:setString(string.format(TEXT_COUNT_DOWN, delayTime - count))
    			 local limitCount = delayTime - 7
    			 if count >= limitCount and count%2 == 1 and isPurchaseMode(self.mode) then
				    DZAction.shakeWithTime(self.addTime_btn, 0.8)
				    Single:paltform():shakePhone()
				 end
    			 count = count + 1
    		end)
		local scheduler = cc.RepeatForever:create(cc.Sequence:create(callback,delay))
		self._timerLabel:runAction(scheduler)
	end
end

function InsuranceView:showView(parent)
	if not self:getParent() then 
		parent:addChild(self)
	end
	self:getEventDispatcher():resumeEventListenersForTarget(self)
	self:setVisible(true)
	self:setPosition(cc.p(0, 0))
	print("showView")
	if isPurchaseMode(self.mode) then 
		self.schedulerUI = scheduler:scheduleScriptFunc(handler(self, self.sendSynchroniztionUI), 0.1, false)
	end
end

function InsuranceView:hideView()
	if self:getParent() then 
		self:setVisible(false)
		self:setPosition(cc.p(-2000, -2000))
		self:getEventDispatcher():pauseEventListenersForTarget(self)
		--注意需要停止的action
		self._timerLabel:stopAllActions()
		self:stopAllActions()
	end
	print("hideView")
	self:unscheduleUpdate()
	if self.schedulerUI then 
		scheduler:unscheduleScriptEntry(self.schedulerUI)
		self.schedulerUI = nil
	end
end

function InsuranceView:onExit()
	self:unscheduleUpdate()
	if self.schedulerUI then 
		scheduler:unscheduleScriptEntry(self.schedulerUI)
		self.schedulerUI = nil
	end
end
------------------------------------------------------------
---------------------------------------------------------------------------
--UI Synchronization
function InsuranceView:synchronizationUI(data)
	-- pri nt("self="..tostring(self))
	dump("isPurchase:"..tostring(isPurchaseMode(self.mode)).." isVisible:"..tostring(self:isVisible()), "测试同步2013")
	if isPurchaseMode(self.mode) or not self:isVisible() or self.poodVal <= 0 then 
		do return end
	end
	print("《《《《《《《《《同步 2013synchronizationUI")
	local listView = self.listView
	local message = data['message']
	local investingNum = message['investNum']
	local minimumVal,maximumVal = message['minimumVal'], message['maximumVal']
	local tmpSelectCards = message['selectCards']

	if #self.selectCards ~= #tmpSelectCards then 
		local ckAllbtn = self:getChildByTag(TAG_ODDS_CK)
		local isSelect = #tmpSelectCards >= self.outsAmount
		ckAllbtn:setSelected(isSelect)
		local items = self.listView:getItems()
		for i = 1, #items do 
			local cLayoutNode = items[i]
			for j = 0, 3 do 
				local cbox = cLayoutNode:getChildByTag(j)
				if cbox then 
					local cardindex = cbox.cardIndex
					local index = table.indexof(tmpSelectCards, cardindex)
					if index  and index > 0 then 
						cbox:setSelected(true)
					else 
						cbox:setSelected(false)
					end
				end
			end
		end
		self.selectCards = tmpSelectCards
	end

	self:updateSelectOutsLabel()
    self:updateInuraceBar(investingNum, minimumVal, maximumVal)
    -- self:updateButtonStatus()
end

function InsuranceView:sendSynchroniztionUI()
	local isPurchase = isPurchaseMode(self.mode)
	if not isPurchase then 
		do return end
	end
	--检查有一定的差距才发送
	local isDValue = math.abs(self.investingNum - self.tagInvestingNum) >= 1
	local isOutsChange = (#self.selectCards ~= self.tagOutsNum)
	if not isDValue and not isOutsChange then 
		do return end
	end
	print("》》》》》》》》发送 2013 同步UI"..tostring(isPurchase))
	local obj, message = {} , {}
	message['investNum'] = self.investingNum
	message['minimumVal'] = self.slider:getMinimumValue()
	message['maximumVal'] = self.slider:getMaximumValue()
	message['selectCards'] = self.selectCards
	obj.message = message
	SocketCtrol.sendInsuranUIChange(obj, function(data)
			-- print("同步回复")
		end)

	self.tagInvestingNum = self.investingNum
	self.tagOutsNum      = #self.selectCards
end

function InsuranceView:purchaseResult(data)
	local result = data.result
	if result then 
		self:hideView()
	else 
		-- print("购买异常")
	end
end
-----------------------------------------------------------------
-----------------------------------------------------------------
---
--- 数据更新
---
-----------------------------------------------------------------
local function updateSetMode(obj, poolCardsNum , mustBuy, turnInsured, isPurchase, isCuouser)
	local cardPart , mode= nil, nil
	if poolCardsNum == 3 then 
		cardPart = CARD_PART.Turn_over
	elseif poolCardsNum == 4 then 
		cardPart = CARD_PART.River
	end 

	if isPurchase then  --如果是购买保险的人
		mode = SHOW_MODE.insures_mode
	elseif isCuouser then  --如果是购买搓牌的人
		mode = SHOW_MODE.cuopai_mode
	else              --如果只是一个看客
		mode = SHOW_MODE.none_mode
	end	
	
	obj:setInsuranceStatus(cardPart, mode, mustBuy)
	obj.turnInsured = turnInsured
end

local function updateSetValue(obj, outsCards, poolCards, poolBet, surplusThinkTime, mustBuy, players)
	--更新UI   -底池 -允许投保 -
	obj:setPoolBet(poolBet)
	obj:updatePlayer(players)
	obj:updatePoolCards(poolCards)
	obj:updateOutCards(outsCards)
	obj:updateInuraceBar(0)
	obj:runTime(surplusThinkTime)
end

function InsuranceView:initData(data)
	--初始化玩家数据
	local isCuouser = data.isCuouser
	local isPurchase = data.isPurchaser	
	local poolBet = data.poolBet             --底池
	local poolCards = data.poolCards 		 --公共牌
	local outsCards = data.outsCards 		 --outs牌
	local mustBuy = data.mustBuy             --必须够买
	local turnRoundInsured = data.turnRoundInsured -- 转牌圈保额
	local players = data.players
	local surplusThinkTime = data.surplusThinkTime --剩余思考时间
	self.betNum = data.betNum
	updateSetMode(self, #poolCards, mustBuy, turnRoundInsured, isPurchase, isCuouser)
	updateSetValue(self, outsCards, poolCards, poolBet, surplusThinkTime, mustBuy, players)
end

return InsuranceView
