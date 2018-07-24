--
-- Author: Taylor
-- Date: 2017-05-10 14:23:49
-- List效果竖直的选择
local UIBasePicker = class("UIBasePicker", cc.Node)

local _size = cc.size(200, 239)
local _itemMargin = 25
local _magneticType = 1
local _gravity = ccui.ListViewGravity.centerVertical
local _bounce = true

local function isCircle(this)
	if this._circle and (this._items and #this._items >= 10) then 
		return true
	end
	return false
end

function UIBasePicker:ctor(params)
	self._items = params['items'] or {}
	self.confirmFunc = params['callfunc'] or function(index) end
	self.generateCellFunc = params['createCellFunc']
	self.cellAniFunc = params["cellAniFunc"]

	_size = params['size'] or cc.size(200, 239)
	_itemMargin = params['margin'] or 25
	_gravity = params['gravity'] or ccui.ListViewGravity.centerVertical
	_bounce = params['bounce'] or true
	self._circle = params['circle'] or false
	_defaultIndex = params['defaultIndex'] or 0
	self:initView()
	self:initCell()
	self:onUpdate(handler(self, self.update))
end

function UIBasePicker:initView()
	local listNode = ccui.ListView:create()
	listNode:setDirection(ccui.ScrollViewDir.vertical)
	listNode:setBounceEnabled(true)
	listNode:setScrollBarEnabled(false)
	listNode:setItemsMargin(_itemMargin)
	listNode:setGravity(_gravity)
	listNode:setMagneticType(_magneticType)
	listNode:addEventListener(handler(self, self.selectHandler))
	listNode:setPosition(cc.p(0,0))
	listNode:setContentSize(_size)
	-- listNode:setClippingEnabled(false)
	self:addChild(listNode)
	-- if isCircle(self) then 
	-- listNode:setInertiaScrollEnabled(false)
	-- end
	listNode:onScroll(handler(self, self.scrollViewHandler))
	-- else 
		-- listNode:addScrollViewEventListener(handler(self, self.scrollHandler))
	-- end
	self.listView = listNode
end

function UIBasePicker:defaultCell(data,index,size)
	local name = data.name or data.clubname or data.username or data or "nil"
	local item = ccui.Layout:create()
	item:setTouchEnabled(true)
	item:setContentSize(size)
	item:setTag(index)

	-- local layer = cc.LayerColor:create(cc.c3b(255,0,0))
	-- layer:setContentSize(cc.size(_size.width, item:getContentSize().height))
	-- layer:setPosition(cc.p(0,0))
	-- item:addChild(layer)

	local label = cc.LabelTTF:create(name, "Arial", 38)
	label:setPosition(cc.p(item:getContentSize().width/2, item:getContentSize().height/2))
	label:setName("Text")
	label:setFontFillColor(cc.c3b(108, 125, 150))
	item:addChild(label)
	return item 
end

function UIBasePicker:initCell()
	local count = 1
	if isCircle(self) then --只有数量大于10的数据才循环显示
		count = 3
	end
	local cellMinNum = 5
	local size = cc.size(_size.width, (_size.height-_itemMargin*(cellMinNum-1))/cellMinNum)

	-- if #self._items > 2 then 
	-- 	local obj = {name = "全部", id = 0}
	-- 	local cell = self:defaultCell(obj, 0, size)
	-- 	cell.index = 0
	-- 	self.listView:pushBackCustomItem(cell)
	-- end

	for j = 1, count do 
		for i = 1, #self._items do
			local data = self._items[i]
			local cell = nil
			if self.generateCellFunc then 
				cell = self.generateCellFunc(data, i,size)
			else 
				cell = self:defaultCell(data, i,size)
			end
			cell.index = i
			self.listView:pushBackCustomItem(cell)
		end
	end

	self.listView:jumpToItem(_defaultIndex, cc.p(.5, .5), cc.p(.5,.5))
end

function UIBasePicker:selectHandler(sender, eType)
	local index = sender:getCurSelectedIndex()
	print("index", index, eType)
	if (eType == 1) then 
		sender:scrollToItem(index, cc.p(0.5, 0.5), cc.p(0.5, 0.5))
		if self.confirmFunc then 
			self.confirmFunc(index)
		end
	else 
	end
end

function UIBasePicker:scrollHandler(sender, eType)
	local index = sender:getCurSelectedIndex()	
	if eType == 10 then 
		print("selectIndex:",index)	
		
		-- print("sender:height:", self.listView:getContentSize().height, "getInnerContainerH=", self.listView:getInnerContainer():getContentSize().height)
	end
end

function UIBasePicker:scrollViewHandler(event)
	if event.name == nil then 
		do return end
	end
	print("event.name"..event.name, "circle", tostring(isCircle(self)))
	local target = event.target
	local name = event.name
	local innerPoint = target:getInnerContainerPosition()
	local targetSize = target:getContentSize()
	local containerSize = target:getInnerContainerSize()
	local itemsCount = #self.listView:getItems()
	if isCircle(self) and (event.name == "BOUNCE_TOP" or event.name == "SCROLL_TO_TOP")then 
		-- print(name.."  innerPoint.y = "..innerPoint.y, "target Y = "..(target:getContentSize().height*3/2 + 25 - containerSize.height))
		if innerPoint.y <= (targetSize.height*3/2 - containerSize.height) then 
			innerPoint.y = innerPoint.y + containerSize.height/3*2
			target:getInnerContainer():setPositionY(innerPoint.y)
			local item = target:getTopmostItemInCurrentView()
			local index = target:getIndex(item)
			target:scrollToItem(index, cc.p(.5, .5), cc.p(.5, .5))
		end
	elseif isCircle(self) and (event.name == "BOUNCE_BOTTOM" or event.name == "SCROLL_TO_BOTTOM") then 
		-- print(name.."  innerPoint.y = "..innerPoint.y, "target Y = "..(-50))
		if  innerPoint.y >= -50 then 
			innerPoint.y = innerPoint.y - containerSize.height/3*2
			target:getInnerContainer():setPositionY(innerPoint.y)
			local item = target:getBottommostItemInCurrentView()
			local index = target:getIndex(item)
			target:scrollToItem(index, cc.p(.5, .5), cc.p(.5, .5))
		end
	elseif not isCircle(self) and itemsCount < 5 then --不是循环显示，并且item的数量不大于5，一般来说大于5就一定大于listView的宽度了
		local item = target:getBottommostItemInCurrentView()
		local posy = self:getItemPositionYInView(self.listView, item)
		local centerY = targetSize.height/2
		if not item then 
			print("原来如此 原来如此")
		end
		-- print("posy:",posy,"centerY",centerY+item:getContentSize().height/2,"inner.y",innerPoint.y)
		if posy > centerY  then 
			if event.name ==  "AUTOSCROLL_ENDED" or event.name == "BOUNCE_BOTTOM" then 
				target:scrollToItem(target:getIndex(item), cc.p(.5, .5), cc.p(.5, .5))
				event.name = "AUTOSCROLL_ING"
			else 
				-- target:stopAutoScroll()
				local offsety = posy - centerY -- item:getContentSize().height/2
				target:setInnerContainerPosition(cc.p(innerPoint.x, innerPoint.y - offsety))
				event.name = "AUTOSCROLL_ENDED"
			end
		end 
	end

	if event.name == "AUTOSCROLL_ENDED" then 
		if self.confirmFunc then 
			print("自动选中:", self:getSelectIndex())
			self.confirmFunc(self:getSelectIndex())
		end
	end
	
end

function UIBasePicker:getItemPositionYInView(curListView ,item)
	local worldPos = item:getParent():convertToWorldSpaceAR(cc.p(item:getPosition()))
	local viewPos = curListView:convertToNodeSpaceAR(worldPos)
	return viewPos.y
end

function UIBasePicker:update(dt)
	if not self.listView then 
		do return end
	end
	local topItem = self.listView:getTopmostItemInCurrentView()
	if topItem then 
		local topIndex = self.listView:getIndex(topItem)		
		-- print("topIndex:",topIndex)
		for j = topIndex, topIndex + 5 do 
			local curItem = self.listView:getItem(j)
			if curItem then 
				local posCenterY = self:getItemPositionYInView(self.listView, curItem) + curItem:getContentSize().height/2
				local mid  =  self.listView:getContentSize().height/2
				local miny = mid - curItem:getContentSize().height/2
				local maxy = mid + curItem:getContentSize().height/2
				local length = math.abs(mid - posCenterY)
				local isCross = length < curItem:getContentSize().height 
			
	 			local op = math.abs(length - mid)/mid
	 			op = math.pow(op, 2)
	 			op = math.max(op, 0.1)

	 			if self.cellAniFunc then
	 				curItem.posCenterY = posCenterY
					self.cellAniFunc (curItem, isCross, op) 
				else
					self:updateCellAni(curItem, isCross, op)
				end
			end
		end
	end
end

function UIBasePicker:updateCellAni(target, isCross, ator)
	local label = target:getChildByName("Text")
	local sp = target:getChildByName("country")
	if isCross then 
		label:setFontFillColor(cc.c3b(255, 255, 255))
		if sp then
			sp:setScale(1.2)
		end
	else 
		label:setFontFillColor(cc.c3b(108, 125, 150))
		if sp then
			sp:setScale(1)
		end
	end
	-- label:setScale((ator*6 + 38)/42)
end

function UIBasePicker:getSelectIndex()
	if self.listView then 
		local item =  self.listView:getCenterItemInCurrentView()
		if (item) then 

		return item.index
		end
	end
	return -1
end

function UIBasePicker:onEnter()
	UIBasePicker.super.onEnter()
end

function UIBasePicker:onExit()
	UIBasePicker.super.onExit()
	self.listView = nil
	self._items = nil
	self.confirmFunc = nil
	_size = nil
	_itemMargin = nil
	_magneticType = nil
end




return UIBasePicker