--
-- Author: Taylor
-- Date: 2017-08-21 09:35
-- 时间 Picker


local UIDateRangePicker = class("UIDateRangePicker", function()
				return cc.LayerColor:create(cc.c4b(255, 255, 255, 0))
	end)

local _title = nil
local _confirmFunc = nil
local _items = nil
local _basePicker = nil

function UIDateRangePicker:ctor(params)
	self:enableNodeEvents()
	_confirmFunc = params.confirmFuc 
	-- _items = params.items or nil

	self:initView(params)

	self._isSwallowImg = true 
	TouchBack.registerImg(self)
end

function UIDateRangePicker:initView(params)
	local endtime = params.endtime 
	local spantime = params.spantime 
	local starttime = endtime - spantime
	if starttime < 0 then 
		starttime = 0
	end

	local dateArray  = {}
	dateArray[1] = tonumber(os.date("%m", starttime)).."月"..os.date("%d",starttime).."日"
	dateArray[2] = tonumber(os.date("%m", starttime+24*60*60)).."月"..os.date("%d",starttime + 24*60*60).."日"
	dateArray[3] = tonumber(os.date("%m",  endtime)).."月"..os.date("%d",endtime).."日"

	local curHour=  os.date("%H", endtime)
	local hourArray = {}
	for i = 0,23 do
		hourArray[#hourArray + 1] = string.format("%2d:00", i)
	end

	local bg = UIUtil.addPosSprite("mtt/timeBg.png", cc.p(0,0),self,cc.p(0,0)) 
	local w, h = bg:getContentSize().width, bg:getContentSize().height
	self:setContentSize(w,h)
    local bg_bottom = UIUtil.addPosSprite("mtt/shadow_bottom.png", cc.p(0, 0), self,cc.p(0,0))
    local bg_top = UIUtil.addPosSprite("mtt/shadow_top.png", cc.p(0, h-6-46), self, cc.p(0,1))
   	bg_top:setLocalZOrder(10)
   	bg_bottom:setLocalZOrder(10) 
   	bg_top:setScaleY(160/185)
    local fontsize  = 38
    local left_title = cc.LabelTTF:create("起始时间", "Helvetica-Bold", fontsize)
        :move(212, h - 34)
        :addTo(self)
     left_title:setAnchorPoint(cc.p(0.5, 1))
     left_title:setLocalZOrder(11);
    local right_title = cc.LabelTTF:create("结束时间", "Helvetica-Bold", fontsize)
        :move(535, h - 34)
        :addTo(self)
     right_title:setAnchorPoint(cc.p(0.5, 1))
     right_title:setLocalZOrder(11);

    self.left_label = UIUtil.addLabelArial(os.date("%m/%d", starttime), 30, cc.p(212, h-34-left_title:getContentSize().height - 9), cc.p(0.5, 1), self)
    self.left_label:setLocalZOrder(50)
    self.right_label = UIUtil.addLabelArial(os.date("%m/%d", endtime), 30, cc.p(535,h-34-left_title:getContentSize().height - 9), cc.p(0.5, 1), self)
    self.right_label:setLocalZOrder(50)
   local function touchEvent(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            -- local index = _basePicker:getSelectIndex()
            local leftDateIndex = self.leftDate:getSelectIndex()
            local rightDateIndex = self.rightDate:getSelectIndex()
            local leftHourIndex = self.leftHour:getSelectIndex()
            local rightHourIndex = self.rightHour:getSelectIndex()
            print("leftDateIndex:"..leftDateIndex, "rightDateIndex:"..rightDateIndex, "leftHourIndex:"..leftHourIndex, "rightHourIndex:"..rightHourIndex)
			local stime = starttime + 24*60*60*(leftDateIndex - 1)
			local etime = starttime + 24*60*60*(rightDateIndex - 1)
			local syear , smonth, sday =  os.date("%Y", stime), os.date("%m", stime), os.date("%d", stime)
			local eyear, emonth,eday = os.date("%Y", etime), os.date("%m", etime), os.date("%d", etime)
			print("syear",syear, "smonth", smonth, "sday", sday, "hour", leftHourIndex)
			print("eyear",eyear, "emonth", emonth, "eday", eday, "hour", rightHourIndex)
			local startTime = os.time({year = syear, month = smonth, day = sday, hour = leftHourIndex-1})
			local endTime  = os.time({year = eyear, month = emonth, day = eday, hour = rightHourIndex-1})
			
			if startTime >= endTime then 
				ViewCtrol.showTick({content = "起始时间不得大于结束时间!",delay = 1})
				return
			end
			
			if _confirmFunc then 
                _confirmFunc(startTime, endTime)
				self:removeFromParent()
			end
        end
    end
    local button = ccui.Button:create()
    button:setScale9Enabled(true)
    button:setTouchEnabled(true)
    button:setAnchorPoint(cc.p(1, 1))
    button:setPosition(cc.p(w-25, h-32))
    button:addTouchEventListener(touchEvent)
    button:ignoreContentAdaptWithSize(false)
    button:setTitleText("确定")
    button:setTitleFontName("Helvetica-Bold")
    button:setTitleFontSize(30)
    button:setTitleColor(cc.c3b(255, 255, 255))
    button:setContentSize(cc.size(100, 50))
    self:addChild(button,100)


    local function leftback(index)
    	local index = self.leftDate:getSelectIndex()
    	local time = starttime + 24*60*60*(index - 1)
    	self.left_label:setString(os.date("%m/%d", time))
    end
    self.leftDate, self.leftHour = self:createListView(cc.p(46, 210-119.5), cc.p(205, 210-119.5), dateArray, hourArray, leftback, 0, tonumber(curHour))

    local function rightback(index)
    	local index = self.rightDate:getSelectIndex()
   		local time = starttime + 24*60*60*(index - 1)
    	self.right_label:setString(os.date("%m/%d", time))
    end
    self.rightDate, self.rightHour = self:createListView(cc.p(353, 210-119.5), cc.p(512, 210-119.5), dateArray, hourArray, rightback, 2, tonumber(curHour))
end


function UIDateRangePicker:createListView(leftPos, rightPos, leftItems, rightItems, callback, defaultIndex, defaultHour)

	-- local function leftCellAni(target, iscross, ator)
	-- end
	local params = {['items'] = leftItems, ['callfunc'] = callback, ['circle'] = false, ['size'] = cc.size(173, 220), 
					['gravity'] = ccui.ListViewGravity.centerHorizontal, ['margin'] = 29, ['defaultIndex'] = defaultIndex} 
	
	local UIBasePicker = require("ui.UIBasePicker")
	local datePicker = UIBasePicker.new(params)
	self:addChild(datePicker)
	datePicker:setPosition(leftPos)

	local function rightCellAni(target, iscross, ator)
		-- print("vivivivi")
		local label = target:getChildByName("Text")
		label:setScale((ator*6 + 38)/42)
	
		local midScale = target:getContentSize().height*2+35*3/2
		local lenScale = math.abs(midScale - target.posCenterY)
		local offsetx = (label:getAnchorPoint().x - 0.5) * label:getContentSize().width 
		if iscross then 
			label:setFontFillColor(cc.c3b(255, 255, 255))
		else 
			label:setFontFillColor(cc.c3b(108, 125, 150))
		end
  		label:setPositionX(target:getContentSize().width/2 + offsetx - (lenScale - midScale)/midScale*12)
	end
	params2 = {['items'] = rightItems, ['callback'] = callback, ['circle'] = true, ['size'] = cc.size(127, 220), ['margin'] = 29, ['defaultIndex'] = defaultHour + 24, ['cellAniFunc'] = rightCellAni}
	local hourPicker = UIBasePicker.new(params2)
	self:addChild(hourPicker)
	hourPicker:setPosition(rightPos)
	return datePicker, hourPicker
end

function UIDateRangePicker.noEndedBack(touch, event)
	local target = event:getCurrentTarget()
	target:removeFromParent()
end

function UIDateRangePicker:onEnter()
end
function UIDateRangePicker:onExit()
	_items = nil
	_title = nil
	_confirmFunc = nil
	_basePicker = nil
end

--------------------------------------
-- parent 父容器
-- params = {
---	   ["title"] = "请选择管理员ID"
---	   ["confirmFuc"] =  xx --点击确定的回调 
---	   ['items'] = nil --listView显示的资源
---
---		 items = {name = "", id = "",}
--------------------------------------
function UIDateRangePicker.show(parent, params)
	local textPicker = UIDateRangePicker.new(params)
	textPicker:setPosition(cc.p(0,0))
	parent:addChild(textPicker)
end


return UIDateRangePicker
