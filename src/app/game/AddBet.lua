local AddBet = class("AddBet", function()
	return cc.LayerColor:create(cc.c4b(255,0,0,0))
end)

local function onTouchBegan(touch, event)
    local target = event:getCurrentTarget()
    if target._isBetBegan then
    	return false
    end

    target._beganY = touch:getLocation().y
    target._isBetBegan = true

    return true
end

local function onTouchMoved(touch, event)
	local location = touch:getLocation()
	local target = event:getCurrentTarget()

	if not target._isDisplay then
     	return
    end

	local posy = location.y - target._beganY
	posy = posy + target._numbg:getPositionY()
	
	target._beganY = location.y
	if posy > target._maxY then
		posy = target._maxY
	end
	if posy < target._minY then 
		posy = target._minY
	end
	target._numbg:setPositionY(posy)
	target:updateNum()
end
local function onTouchEnded(touch, event)
end


function AddBet:regiaterEvent()
	local listener = cc.EventListenerTouchOneByOne:create()
	listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
	listener:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED)
	listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
	local eventDispatcher = self:getEventDispatcher()
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

function AddBet:removeBet()
	self._node:removeFromParent()
	self._node = nil
end

function AddBet:displayBet()
	DZPlaySound.playGear()
	
	self._node = cc.Node:create()
	self:addChild(self._node)

	local pos1 = cc.p(self._center.x, self._size.height)
	local pos2 = cc.p(self._center.x, self._minY)

	UIUtil.addPosSprite(ResLib.GAME_BET_LINE, pos1, self._node, cc.p(0.5,1))
	local imgBetAll = UIUtil.addPosSprite(ResLib.GAME_BET_ALL, pos1, self._node, cc.p(0.5,1))
	local color1 = cc.c3b(252,255,34)
	local ftype = 'Helvetica-Bold'
	UIUtil.addLabelArial(self._allBet, 30, cc.p(60,28.5), cc.p(0.5,0.5), imgBetAll, color1, ftype)

	self._numbg = UIUtil.addPosSprite(ResLib.GAME_BET_THUMB, pos2, self._node, cc.p(0.5,0))
	local bs = self._numbg:getContentSize()
	local tpos = cc.p(bs.width/2,bs.height/2)

	self._ttfNum = UIUtil.addLabelArial(tostring(0), 30, tpos, nil, self._numbg, cc.c3b(255,255,255), ftype)

	self:disValue(self._nowBet)
end


function AddBet:endBack()
	self._isBetBegan = false
	if not self._isDisplay then
     	return 
    end

	self:updateNum()
	self:removeBet()
	self._isDisplay = false

	if self._nowBet ~= 0 then
		self._updateBack(self._nowBet)
		self._nowBet = 0
	end
end

function AddBet:disValue(val)
	if val >= self._allBet then
		val = 'all in'
	end
	self._ttfNum:setString(tostring(val))
end

--0~10 2的倍数
--11~100 5的倍数
--101~1000 100/10的倍数 ...
function AddBet:convertNowBet(nowBet)
	local multiple = 2
	if nowBet <= 10 then
		multiple = 2
	elseif nowBet <= 100 then
		multiple = 5
	elseif nowBet <= 1000 then
		multiple = 10
	elseif nowBet <= 10000 then
		multiple = 100
	elseif nowBet <= 100000 then
		multiple = 1000
	elseif nowBet <= 1000000 then
		multiple = 10000
	else
		multiple = 100000
	end

	local integer,remainder = math.modf(nowBet / multiple)
	local bet = (integer + 1) * multiple
	if remainder == 0 then
		bet = integer * multiple
	end
	return bet,multiple
end

function AddBet:updateNum()
	local interval = self._maxY - self._minY
	local num = 100 / interval * (self._maxY - self._numbg:getPositionY())
	local tpercent = 100 - num

	local realv = #self._betArr

	if realv == 0 then return end

	local nowVal = realv * tpercent / 100
	local idx = math.ceil(nowVal)
	if idx > realv then
		idx = realv
	elseif idx == 0 then
		idx = 1
	end
	local tnowBet = self._betArr[ idx ]
	--不应该有
	if tnowBet > self._allBet then
		tnowBet = self._allBet
	end

	self._nowBet = tnowBet

	self:disValue(self._nowBet)
end


local function touchDown(self)
	self._isBetBegan = false
	self._isDisplay = true
	self:displayBet()
end

function AddBet:updateValue(allBet, min)
	self._betArr = {}

	self._allBet = allBet
	self._minBet = min 
	self._nowBet = 0

	--min不是0插入一个0
	if min > 0 then
		table.insert(self._betArr, 0)		
	end

	--只能all in
	if min >= allBet then
		table.insert(self._betArr, allBet)
		table.insert(self._betArr, allBet)
		table.insert(self._betArr, allBet)
		table.insert(self._betArr, allBet)
		table.insert(self._betArr, allBet)
		return
	end

	table.insert(self._betArr, min)

	local tval = min
	local tbet,mul = self:convertNowBet(tval)
	tval = tbet + mul

	if tbet ~= min and tbet <= allBet then
		table.insert(self._betArr, tbet)
	end

	while true do
		tbet,mul = self:convertNowBet(tval)
		if tbet > allBet then
			break
		end

		table.insert(self._betArr, tbet)
		tval = tbet + mul
	end

	table.insert(self._betArr, allBet)
end

function AddBet:init(funcBack, allBet)
	self._updateBack = funcBack
	self._allBet = allBet
	self._minBet = 0
	self._nowBet = 0

	self._betArr = {}

	self._numbg = nil
	self._ttfNum = nil
	self._betBtn = nil
	self._node = nil
	self._size = cc.size(160,725+28)
	self._maxY = 693.5
	self._minY = 140
	self._isDisplay = false
	self._center = cc.p(self._size.width/2, self._size.height/2)
	self:setContentSize(self._size)

	self:ignoreAnchorPointForPosition(false)
	self:setAnchorPoint(cc.p(0.5,0))
	self:setPosition(display.cx, 310)

	local function btnBack(sender, eventType)
		if eventType == ccui.TouchEventType.began then
			touchDown(self)
		elseif eventType == ccui.TouchEventType.ended then
			self:endBack()
		elseif eventType == ccui.TouchEventType.canceled then
			self:endBack()
		end
	end

	local img = ResLib.GAME_BET_ADD1
	local imgs = {ResLib.GAME_BET_ADD1, ResLib.GAME_BET_ADD2, ResLib.GAME_BET_ADD1}
	local betBtn = UIUtil.addUIButton(imgs, cc.p(self._center.x,10), self, btnBack)
	betBtn:setAnchorPoint(0.5,0)
	betBtn:setLocalZOrder(5)
	betBtn:setSwallowTouches(false)
end


function AddBet.createAddBet(parent, callBack, allBet)
	local bet = AddBet.new()
	bet:init(callBack, allBet)
	parent:addChild(bet)
	return bet
end


return AddBet