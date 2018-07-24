--
-- author: Taylor
-- date: 2016-11-20
--

local Week_CN = {" 周日"," 周一"," 周二"," 周三"," 周四"," 周五"," 周六"}
local function secondsConvertToTime(seconds)
	if seconds < 0 then
		seconds = 0
	end
	local dayUnit,hourUnit,minuteUnit = 86400,3600,60
	local dayValue,hourValue,minuteValue,secondValue = 0,0,0

	dayValue = math.floor( seconds / dayUnit )
	hourValue = math.floor( (seconds - dayValue * dayUnit ) / hourUnit )
	minuteValue = math.floor( ( seconds - hourValue * hourUnit - dayValue * dayUnit ) / minuteUnit )
	secondValue = seconds % 60

	local rtab = {}
	rtab['day'] = dayValue
	rtab['hour'] = hourValue
	rtab['minute'] = minuteValue
	rtab['seconds'] = secondValue
	return rtab
end

local function localeMonthOfDayFormat(timeTb)
	dump(timeTb)
	local month = timeTb.month
	local day = timeTb.day
	local week = timeTb.wday
	if month < 10 then 
		month = "0"..month
	end
	
	if day < 10 then 
		day = "0"..day
	end


	return  month.."/"..day.. " "..Week_CN[week]
end

local UIDatePicker = class("UIDatePicker", function()
				-- return cc.Layer:create()
				return cc.LayerColor:create(cc.c4b(0, 0, 0, 120))
	end)

UIDatePicker.UIDatePickerModeTime = 1
UIDatePicker.UIDatePickerModeDate = 2
UIDatePicker.UIDatePickerModeDateAndTime = 3
UIDatePicker.UIDatePickerModeCountDownTimer = 4

function UIDatePicker:ctor(_options)
	local options = _options
	if (not options) then 
		options = {minimumDate = os.time(), maxDate = os.time() + 24*60*60*7,datePickerMode = 3}
	end


	self.datePickerMode = options.datePickerMode or UIDatePicker.UIDatePickerModeDateAndTime -- 显示模式
	self.minimumDate = options.minimumDate or os.time() --最小时间日期
	self.maxDate = options.maxDate or self.minimumDate + 24*60*60*7
	self.locale = nil     --显示本地化    
	self.timeZone = nil   -- 当前时间
	self.minuteInterval = 1 --默认时间间隔
	self.calendar = nil     --当前日期时间
	
	self.minutes = {}  --分钟数组
	self.hours = {} 		--小时数组
	self.days  = {} 		--时间天数数组

	self.notifyValueHnadler = nil --通知值
	self:initData()
	self:initView()
	self:onUpdate(handler(self, self.update))
end

function UIDatePicker:initData()
	local minimumTime = self.minimumDate
	local maxDate = self.maxDate
	local intervalDay = maxDate - minimumTime
	--时间差
	local timeInterval = secondsConvertToTime(intervalDay)
	local day = timeInterval.day

	--初始化间隔时间 -- 日期
	for i = 0, day - 1 do 
		self.days[#self.days + 1] = minimumTime + i * 86400
	end

	--初始化小时时间 -- 小时
	for i = 1, 24 * 3 do
		local hour = i % 24
		if (hour < 10) then 
			hour = "0"..hour
		end
		self.hours[#self.hours + 1] = hour 
	end

	--初始化分钟时间 -- 分钟
	for i = 1, 60 * 3, self.minuteInterval do 
		local minute =  i % 60
		if (minute < 10) then 
			minute = "0"..minute
		end
		self.minutes[#self.minutes + 1] = minute
	end
end

--初始化视图
function UIDatePicker:initView()
	self:enableNodeEvents()

    local bg = UIUtil.addPosSprite("mtt/timeBg.png", cc.p(0,0),self,cc.p(0,0)) 
    local w, h = bg:getContentSize().width, bg:getContentSize().height

    local bg_bottom = UIUtil.addPosSprite("mtt/shadow_bottom.png", cc.p(0, 0), self,cc.p(0,0))
    local bg_top = UIUtil.addPosSprite("mtt/shadow_top.png", cc.p(0, h-26), self, cc.p(0,1))
   	bg_top:setLocalZOrder(10)
   	bg_bottom:setLocalZOrder(10) 
   	bg_top:setScaleY(160/185)
    local fontsize  = 32
    local title = cc.LabelTTF:create("请设置开赛时间", "Helvetica-Bold", fontsize)
        :move(display.cx, h - 48 )
        :addTo(self)
     title:setAnchorPoint(cc.p(0.5, 1))
     title:setLocalZOrder(11);

    local noteLabel = cc.LabelTTF:create("请设置为当前时间之后", "Arial", 24)
    noteLabel:setFontFillColor(cc.c3b(255, 34, 42))
    noteLabel:setPosition(cc.p(display.cx, h - 104))
    noteLabel:setAnchorPoint(cc.p(.5, 1))
    self:addChild(noteLabel,11)
  	self:setContentSize(cc.size(w,h))
    self.alertLabel= noteLabel
    -- self.alertLabel = cc.LayerColor:create(cc.c4b(255, 0, 0, 255))
    -- self.alertLabel:setContentSize(cc.size(noteLabel:getContentSize().width + 10, noteLabel:getContentSize().height + 10))
   	-- self.alertLabel:setAnchorPoint(cc.p(.5, 1))
   	-- self.alertLabel:setPosition(cc.p(display.cx - (noteLabel:getContentSize().width + 10)/2, title:getPositionY() - title:getContentSize().height -30))
   	-- self:addChild(self.alertLabel, 11)
  	-- noteLabel:setPosition(cc.p(self.alertLabel:getContentSize().width/2, self.alertLabel:getContentSize().height/2))
  	-- self.alertLabel:addChild(noteLabel)
  	-- self.alertLabel:setCascadeOpacityEnabled(true)
  	-- self.alertLabel:setOpacity(0)
    
    local function touchEvent(sender,eventType)
            if eventType == ccui.TouchEventType.began then
                
            elseif eventType == ccui.TouchEventType.moved then
                
            elseif eventType == ccui.TouchEventType.ended then
           		
				local result, selectTime = self:checkAndAlert()
				if (result) then 
					if self.notifyValueHnadler then 
						self.notifyValueHnadler(selectTime)
					end
				end
            elseif eventType == ccui.TouchEventType.canceled then
            end
    end

    local button = ccui.Button:create()
    button:setScale9Enabled(true)
    button:setTouchEnabled(true)
    button:setAnchorPoint(cc.p(1, 1))
    button:setPosition(cc.p(w-32, h-20-22))
    button:addTouchEventListener(touchEvent)
    button:ignoreContentAdaptWithSize(false)
    button:setTitleText("确定")
    button:setTitleFontSize(30)
    button:setTitleColor(cc.c3b(255, 255, 255))
    button:setContentSize(cc.size(100, 50))
    self:addChild(button,100)
    -- local buttonImg = UIUtil.addPosSprite("mtt/ok_duigou.png", cc.p(w-45,h-51), self, cc.p(1,1))
    -- buttonImg:setLocalZOrder(10)
    -- local tablePosy = {200, 255, 310}
    -- for i = 1, 3 do 
    -- 	local lineSp = display.newSprite("mtt/line.png")
    -- 	lineSp:setPosition(cc.p(333+lineSp:getContentSize().width/2, tablePosy[i] +lineSp:getContentSize().height/2))
    -- 	self:addChild(lineSp, 10)
    -- end

    if UIDatePicker.UIDatePickerModeDateAndTime == self.datePickerMode then 
    	--TODO: 初始化代码可以精简，减少行数，listView初始化代码比较重复
			--初始day view
			self:initDateView()
			--初始hour view
			self:initHourView()
			--初始min View
			self:initMinuteView()

			local dateListView, hourListView, minuteListView = self.dateListView, self.hourListView, self.minuteListView
			local radin = math.cos(math.rad(5)) 
			self.mapListView = { 
							{circle = true, color = true, listView = dateListView , circleDir = 1},
							{circle = true, color = true, listView = hourListView , circleDir = 2},
							{circle = true, color = true, listView = minuteListView, circleDir = 2}
					   }
	end
	self._isSwallowImg = true 
	TouchBack.registerImg(self)
end

--创建ListView
local function createListView(options)
	local w, h, itemsMargin, magneticType = options.w, options.h, options.itemsMargin, options.magneticType
	local dateListView = ccui.ListView:create()
	dateListView:setDirection(ccui.ScrollViewDir.vertical)
	dateListView:setBounceEnabled(true)
	dateListView:setScrollBarEnabled(false)
	dateListView:setContentSize(cc.size(w, h))
	-- dateListView:setAnchorPoint(cc.p(0, .5))
	-- dateListView:setPosition(cc.p(68, 226))
	dateListView:setItemsMargin(25.0)
	dateListView:setGravity(ccui.ListViewGravity.centerVertical)
	dateListView:setMagneticType(magneticType)

  	local default_item = ccui.Layout:create()
    default_item:setTouchEnabled(true)
    default_item:setContentSize(cc.size(options.w, ((options.h - options.itemsMargin*4)/5)))
    local default_label = cc.LabelTTF:create("", "Arial", 26)
    default_label:setName("Text")
    default_label:setFontFillColor(cc.c3b(108, 125, 150))
    default_label:setPosition(cc.p(default_item:getContentSize().width/2, default_item:getContentSize().height/2))
    default_item:addChild(default_label)
    dateListView:setItemModel(default_item)

    return dateListView
end

function UIDatePicker:initDateView()
	local function listViewEvent(sender, eType)
		local index = sender:getCurSelectedIndex()
		if (eType == 1) then 
			sender:scrollToItem(index, cc.p(0.5, 0.5), cc.p(0.5, 0.5))
		else 
		end
	end

	local function scrollViewEvent(sender, eType)
		if eType == 10 then 
			local result, selectTime = self:checkAndAlert()
		end
	end
	--创建listView
	local options = {}
	options.w, options.h, options.itemsMargin, options.magneticType = 300, 312, 29, 1
	local dateListView = createListView(options)
	dateListView:setPosition(cc.p(31, 210 - options.h/2))
	dateListView:addEventListener(listViewEvent)
    dateListView:addScrollViewEventListener(scrollViewEvent)
    dateListView:setBackGroundColor(cc.c3b(0,255,0))
    self:addChild(dateListView,5)
    for i = 1, #self.days do 
    	local timesNumber = self.days[i]
    	local date = os.date("*t", timesNumber)
    	local dateString = localeMonthOfDayFormat(date)
    	local item = ccui.Layout:create()
    	item:setTouchEnabled(true)
    	item:setContentSize(cc.size(options.w , ((options.h - options.itemsMargin*4)/5)))
    	item:setTag(i)
    	-- local label = cc.LabelTTF:create(dateString, "Arial", 38)
    	-- -- label:setAnchorPoint(cc.p(1, .5))
    	-- item:addChild(label)
    	-- label:setName("Text")
   		-- label:setFontFillColor(cc.c3b(121, 125, 135))
   		-- label:setPosition(cc.p(item:getContentSize().width/2+label:getContentSize().width/2, item:getContentSize().height/2))
    	local label = UIUtil.addLabelArial(dateString, 38,cc.p(item:getContentSize().width/2+108, item:getContentSize().height/2), cc.p(1,.5),item,cc.c3b(121, 125, 135))
    	label:setName("Text")
    	-- label:enableBold()
    	label:enableShadow(cc.c3b(121, 125, 135), cc.size(-0.01, -0.01), 0)
    	dateListView:pushBackCustomItem(item)
    end
 	dateListView:jumpToItem(0, cc.p(0.5, 0.5), cc.p(0.5, 0.5))
    -- dateListView:scrollToItem(#self.days, cc.p(0.5, 0.5), cc.p(0.5, 0.5))
    self.dateListView = dateListView
end

function UIDatePicker:initHourView()
	
	local function listViewEvent(sender, eType)
		local index = sender:getCurSelectedIndex()
		if (eType == 1) then 
			sender:scrollToItem(index, cc.p(0.5, 0.5), cc.p(0.5, 0.5))
		else 
			print("initHourView listViewEvent end")
		end
	end

	--创建listView
	local options = {}
	options.w, options.h, options.itemsMargin, options.magneticType = 158, 312, 29, 1
	local hourListView = createListView(options)
	hourListView:setPosition(cc.p(422, 210 - options.h/2))
	hourListView:addEventListener(listViewEvent)
    hourListView:onScroll(handler(self, self.scrollViewHandler))
    hourListView:setBackGroundColor(cc.c3b(0,0,0))
    hourListView:setScrollBarEnabled(true)
    self:addChild(hourListView,5)
    for i = 1, #self.hours do 
    	local item = ccui.Layout:create()
    	item:setTouchEnabled(true)
    	item:setContentSize(cc.size(options.w, ((options.h - options.itemsMargin*4)/5)))
    	item:setTag(i)

    	local label = UIUtil.addLabelArial(self.hours[i], 38,cc.p(item:getContentSize().width/2, item:getContentSize().height/2), cc.p(.5,.5),item,cc.c3b(121, 125, 135))
    	label:setName('Text')
    	label:enableShadow(cc.c3b(121, 125, 135), cc.size(-0.01, -0.01), 0)
    	hourListView:pushBackCustomItem(item)
    end
    -- hourListView:scrollToItem(0, cc.p(0.5, 0.5), cc.p(0.5, 0.5))
    local hourIndex = os.date("*t", self.minimumTime).hour + 24
    hourListView:jumpToItem(hourIndex-1, cc.p(0.5, 0.5), cc.p(0.5, 0.5))
    self.hourListView = hourListView
end

function UIDatePicker:initMinuteView()
	
	local function listViewEvent(sender, eType)
		local index = sender:getCurSelectedIndex()
		if (eType == 1) then 
			sender:scrollToItem(index, cc.p(0.5, 0.5), cc.p(0.5, 0.5))
		else 
			print("initHourView listViewEvent end")
		end
	end
	--创建listView
	local options = {}
	options.w, options.h, options.itemsMargin, options.magneticType = 158, 312, 29, 1
	local minuteListView = createListView(options)
	minuteListView:setPosition(cc.p(572, 210 - options.h/2))
	minuteListView:addEventListener(listViewEvent)
    minuteListView:onScroll(handler(self, self.scrollViewHandler))
    minuteListView:setBackGroundColor(cc.c3b(0,0,255))
    self:addChild(minuteListView,5)
    for i = 1, #self.minutes do 
    	local item = ccui.Layout:create()
    	item:setTouchEnabled(true)
    	item:setContentSize(cc.size(options.w, ((options.h - options.itemsMargin*4)/5)))
    	item:setTag(i)
    	-- local label = cc.LabelTTF:create(self.minutes[i], "Arial", 38)
    	-- label:setPosition(cc.p(item:getContentSize().width/2, item:getContentSize().height/2))
    	-- label:setName("Text")
   		-- label:setFontFillColor(cc.c3b(121, 125, 135))
   		-- item:addChild(label)
   		local label = UIUtil.addLabelArial(self.minutes[i], 38,cc.p(item:getContentSize().width/2, item:getContentSize().height/2), cc.p(.5,.5),item,cc.c3b(121, 125, 135))
    	label:setName('Text')
    	label:enableShadow(cc.c3b(121, 125, 135), cc.size(-0.01, -0.01), 0)
    	minuteListView:pushBackCustomItem(item)
    end
    local minindex = os.date("*t", self.minimumTime).min + 60

    minuteListView:jumpToItem(minindex, cc.p(0.5, 0.5), cc.p(0.5, 0.5))
    self.minuteListView = minuteListView
end

function UIDatePicker.noEndedBack(touch, event)
	local target = event:getCurrentTarget()
	target:removeFromParent()
end

function UIDatePicker:scrollViewHandler(event)
		if event.name == nil then 
			do return end
		end
		local target = event.target
		local name = event.name
		local innerPoint = target:getInnerContainerPosition()
		local containerSize = target:getInnerContainerSize()
		if event.name == "BOUNCE_TOP" or event.name == "SCROLL_TO_TOP" then 
			-- print(name.."  innerPoint.y = "..innerPoint.y, "target Y = "..(target:getContentSize().height*3/2 + 25 - containerSize.height))
			if innerPoint.y <= (target:getContentSize().height*3/2 - containerSize.height) then 
				innerPoint.y = innerPoint.y + containerSize.height/3*2
				target:getInnerContainer():setPositionY(innerPoint.y)
				local item = target:getTopmostItemInCurrentView()
				local index = target:getIndex(item)
				target:scrollToItem(index, cc.p(.5, .5), cc.p(.5, .5))
			end
		elseif event.name == "BOUNCE_BOTTOM" or event.name == "SCROLL_TO_BOTTOM" then 
			print(name.."  innerPoint.y = "..innerPoint.y, "target Y = "..(-50))
			if  innerPoint.y >= -50 then 
				innerPoint.y = innerPoint.y - containerSize.height/3*2
				target:getInnerContainer():setPositionY(innerPoint.y)
				local item = target:getBottommostItemInCurrentView()
				local index = target:getIndex(item)
				target:scrollToItem(index, cc.p(.5, .5), cc.p(.5, .5))
			end
		end

		if event.name == "AUTOSCROLL_ENDED" then 
			local result = self:checkAndAlert()
		end
end

--检查时间是否符合要求，不符合要求就弹出提示
function UIDatePicker:checkAndAlert()
	local selectTime = self:calculateSelectTime()
	-- print("当前时间:"..os.date("%c",os.time()), "选中的时间"..os.date("%c",selectTime))
	-- print("是否正常：", tostring(selectTime<os.time()))
	local isSmall = selectTime < os.time()
	if isSmall then
		self.alertLabel:runAction(cc.FadeIn:create(0.2))
	else
		self.alertLabel:runAction(cc.FadeOut:create(0))
	end
	return not isSmall, selectTime
end

function UIDatePicker:getItemPositionYInView(curListView ,item)
	local worldPos = item:getParent():convertToWorldSpaceAR(cc.p(item:getPosition()))
	local viewPos = curListView:convertToNodeSpaceAR(worldPos)
	return viewPos.y
end

--计算
function UIDatePicker:update(_dt)
	
	for i = 1, #self.mapListView do 
		local list_view_params = self.mapListView[i]
		local ck_color = list_view_params.color
		local ck_circle = list_view_params.circle
		local ck_circle_dir = list_view_params.circleDir

		local curListView = list_view_params.listView
		if (not curListView) then 
			do return end
		end
		--
		if ck_color then 
			local topItem = curListView:getTopmostItemInCurrentView()
			local posx = topItem:getPositionX()
			if topItem then 
				local topIndex = curListView:getIndex(topItem)
				-- print("topIndex:",topIndex)
				for j = topIndex, topIndex + 5 do 
					local curItem = curListView:getItem(j)
					if curItem then 
						local posCenterY = self:getItemPositionYInView(curListView, curItem) + curItem:getContentSize().height/2
						local height = curListView:getInnerContainerSize().height/2
						local mid  = curListView:getContentSize().height/2
						local miny = mid - curItem:getContentSize().height/2
						local maxy = mid + curItem:getContentSize().height/2
						local length = math.abs(mid - posCenterY)
						local label = curItem:getChildByName("Text")
						local isCross = length < curItem:getContentSize().height
						-- print("isCross:"..tostring(isCross).. "j:"..tostring(j))
						-- print("posCenterY:"..posCenterY.."  mid:"..mid .."  height:"..curItem:getContentSize().height)
						
						if isCross then 
							label:setColor(cc.c3b(255, 255, 255))
							label:enableShadow(cc.c3b(255, 255, 255), cc.size(-0.01, -0.01), 0)
						else 
							label:setColor(cc.c3b(121, 125, 135))
							label:enableShadow(cc.c3b(121, 125, 135), cc.size(-0.01, -0.01), 0)
						end
			 			local op = math.abs(length - mid)/mid
			 			op = math.pow(op, 2)
			 			op = math.max(op, 0.1)
			 			-- print("j op:",j,op)
			 			-- if (isCross) then 
			 			label:setScale((op*6 + 38)/42)
			 			-- else 
			 			-- if label:getScale() ~= 1 then 
			 			-- 	label:setScale(1)
			 			-- end
			 				
			 			-- end
			 			--处理圆形
			 			if ck_circle then 
			 				local midScale = curItem:getContentSize().height*2+35*3/2
			 				local lenScale = math.abs(midScale - posCenterY)
			 				local offsetx = (label:getAnchorPoint().x - 0.5) * label:getContentSize().width 
			 				if ck_circle_dir == 1 then
						  		label:setPositionX(curItem:getContentSize().width/2 + offsetx + (lenScale - midScale)/midScale*12)
						  	else
						  		label:setPositionX(curItem:getContentSize().width/2 + offsetx - (lenScale - midScale)/midScale*12)
							end
						end
					end
				end
			end
		end

	end
end
--设置某个时间，滚动过去
function UIDatePicker:setDate(_date, anime)
end

function UIDatePicker:calculateSelectTime()
	if (not self.dateListView or not self.hourListView or not self.minuteListView) then 
		do return end
	end

	local dayIndex = self.dateListView:getCurSelectedIndex()
	local hourIndex =  self.hourListView:getCurSelectedIndex()
	local minuteIndex = self.minuteListView:getCurSelectedIndex()
	-- if dayIndex < 0 then 
		dayIndex = self.dateListView:getIndex(self.dateListView:getCenterItemInCurrentView())
	-- end

	-- if hourIndex < 0 then 
		hourIndex = self.hourListView:getIndex(self.hourListView:getCenterItemInCurrentView())
	-- end

	-- if minuteIndex < 0 then
		minuteIndex = self.minuteListView:getIndex(self.minuteListView:getCenterItemInCurrentView())
	-- end
	-- print("dayIndex:"..dayIndex)
	-- print("hourIndex:"..hourIndex)
	-- print("minuteIndex:"..minuteIndex)
	local dayTime = self.days[dayIndex + 1]
	local hourTime = self.hours[hourIndex + 1]
	local minuteTime = self.minutes[minuteIndex + 1]	
	local dayDate = os.date("*t", dayTime)

	local time = os.time({year = dayDate.year, month = dayDate.month, day = dayDate.day, hour = hourTime, min = minuteTime, sec = 0})
	return time 
end 

---重新加载
function UIDatePicker:reload()
end

--默认天数间隔   单位：秒
function UIDatePicker:defaultDayCountTime()
	return 24*60*60*7
end

function UIDatePicker:setDatePickerMode(_mode)
	self.datePickerMode = _mode
end

function UIDatePicker:getDatePickerMode()
	return self.datePickerMode
end

function UIDatePicker:getLocale()
	return self.locale
end


function UIDatePicker:getMinimumDate()
	return self.minimumDate
end

function UIDatePicker:setMinimumDate(_minimumDate)
	self.minimumDate = _minimumDate
end

function UIDatePicker:setMaxDate(_maxDate)
	self.maxDate = _maxDate
end

function UIDatePicker:getMaxDate()
	return self.maxDate
end

function UIDatePicker:addValueEventListener(_valueFuc)
	self.notifyValueHnadler = _valueFuc
end


return UIDatePicker
