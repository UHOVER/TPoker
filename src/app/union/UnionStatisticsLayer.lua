--
-- Author: Taylor
-- Date: 2017-08-01 14:36:35
-- 联盟统计
local ViewBase = require("ui.ViewBase")
local UnionStatisticsLayer = class("UnionStatisticsLayer", ViewBase)
local UnionCtrol = require("union.UnionCtrol")
local _size = cc.size(display.width, display.height-130-90)

local _date_tf = nil
local _date_btn = nil
local _date_bg = nil
local _date_arrow = nil

local _tf_arr = nil
local initSevenDays = nil

function UnionStatisticsLayer:ctor()
	self:setContentSize(_size)
	self:enableNodeEvents()
	self:initData()
	self:initUI()
end

function UnionStatisticsLayer:onEnter()
end

function UnionStatisticsLayer:onExit()
end


function UnionStatisticsLayer:initData()
	self.timeArr = {"近7日数据"}

	local time = os.time()
	self.timeArr[#self.timeArr + 1] = time
	for i = 1, 6 do 
		self.timeArr[#self.timeArr + 1] = time - i * 24*60*60
	end
end

--时间选择下拉框中的日期选择
local function btnGroup(text, parent, x, y, func)
	local widget = ccui.Widget:create()
	widget:setContentSize(cc.size(160, 68))
	widget:setPosition(x, y)
	parent:addChild(widget)
	widget:setTouchEnabled(true)
	widget:touchEnded(func)

	local uText = ccui.Text:create()
	uText:setString(text)
	uText:setFontSize(28)
	uText:setPosition(39/2, 68/2)
	uText:setTextColor(cc.c3b(50,53,66))
	uText:setAnchorPoint(cc.p(0,0.5))
	widget:addChild(uText)

	display.newLayer(cc.c3b(215,218,228), 147, 1)
	:addTo(widget)
	:align(cc.p(.5,.5), 160/2, -10)
	:ignoreAnchorPointForPosition(false)
	return widget
end
--刷新对应的UI
local function resfreshUIHandler(data)
	local n_peopleNum = data.n_peopleNum or "-1" -- -1代表有问题
	local s_peopleNum = data.s_peopleNum or "-1"
	local m_peopleNum = data.m_peopleNum or "-1"
	local insure_profit = data.insure_profit or "-1"
	local blind_peopleNum = data.blind_pCount or {} -- 空代表有问题

	_tf_arr[1]:setString(n_peopleNum)
	_tf_arr[2]:setString(s_peopleNum)
	_tf_arr[3]:setString(m_peopleNum)
	if insure_profit > 0 then 
		insure_profit = "+"..insure_profit
		_tf_arr[4]:setTextColor(cc.c3b(255, 0, 0))
	elseif insure_profit < 0 then 
		_tf_arr[4]:setTextColor(cc.c3b(0,255,0))
	else
		_tf_arr[4]:setTextColor(cc.c3b(171,171,171))
	end
	_tf_arr[4]:setString(insure_profit)

	for i = 1, #_tf_blind_arr do 
		local tf = _tf_blind_arr[i]
		tf:setString(blind_peopleNum[tostring(tf:getTag())])
	end
end

local function initDateSelectUI(container)
	display.newLayer(cc.c3b(16,23,41), display.width, 94):addTo(container):move(0,_size.height - 95)
	local date_btn = UIUtil.addImageView({touch = true, scale = false, size = cc.size(198,54),
						 image = "club/drop_bg.png", pos = cc.p(18, _size.height - 76),
						 ah = cc.p(0, 0), parent = container})
	local offsetx = (198-144)*0.5 + 146
	local date_arrow = UIUtil.addPosSprite("club/upward.png",cc.p(offsetx, 58/2), date_btn)
	local label = UIUtil.addLabelArial("近7日数据", 26, cc.p(144/2, 58/2), cc.p(0.5,.5), date_btn)
	
	--点击下拉显示选择
	local function clickDateHandler(evt)

		if container.bgImgV then 
			local isVisible = container.bgImgV:isVisible()
			container.bgImgV:removeFromParent()
			container.bgImgV = nil
			date_btn.fold()
			return 
		end
		container.bgImgV = initSevenDays(container) 
		date_btn.reveal()
	end

	date_btn:touchEnded(clickDateHandler)
	date_btn.fold = function()  date_arrow:setTexture("club/upward.png") end 
	date_btn.reveal = function()  date_arrow:setTexture("club/downward.png") end 
	return date_btn,date_bg,date_arrow,label
end

local function initSmallTitleUI(container)
	local bgLayer = display.newLayer(cc.c3b(0,0,0), display.width, 98):addTo(container)
																	   :align(cc.p(0,1), 0, _size.height-97)
																	   :ignoreAnchorPointForPosition(false)
	local title_data = {"标准人次", 10, "SNG人次", 20, "MTT人次", 30,"保险总盈利", 40}
	local cellW = (display.width-3)/4
	local tf_arr = {}
	for i = 1, #title_data/2 do 
		local cbg = display.newLayer(cc.c3b(26,32,46), cellW, 98):addTo(bgLayer)
													  :move((i-1)*(cellW+1), 0)
		UIUtil.addLabelArial(title_data[i*2-1], 20,cc.p(cellW/2, 78), cc.p(.5,1), cbg, ResLib.COLOR_GREY1)
		local tf_num = UIUtil.addLabelBold('0', 28, ccp(cellW/2, 18), cc.p(.5,0), cbg)
		tf_num:setTag(title_data[i*2])
		tf_arr[#tf_arr + 1] = tf_num
	end
	return tf_arr
end

local function initBlindUI(container)
	local data = DZConfig.buildBlind()
	local blindTfArr = {}
	local s_posx, s_posy = 34, _size.height - 330
	local h_spacing, v_spacing = 442, 68
	local text_spacing = 137 + 46.5
	local line_w = 93
	local row = math.ceil(#data)

	for i = 0, row - 1 do
		for j = 1, 2 do 
			local titleNum, resultStr = data[ i * 2 + j], nil
			if titleNum == nil then 
				break
			end

			if titleNum >= 10000 then 
				resultStr = (titleNum/2000)..'k/'..(titleNum/1000).."k"
			else
				resultStr = (titleNum/2).."/"..titleNum
			end
			
			UIUtil.addLabelArial(resultStr,28, cc.p(s_posx + h_spacing*(j-1), s_posy - v_spacing*i), cc.p(0,.5), container,ResLib.COLOR_GREY1)
			display.newLayer(cc.c3b(255,255,255), line_w, 1):addTo(container):align(cc.p(.5,.5), s_posx + text_spacing + h_spacing*(j - 1), s_posy - 14 - v_spacing*i):ignoreAnchorPointForPosition(false)
			local blindTf = UIUtil.addLabelBold("0", 30, cc.p(s_posx + text_spacing + h_spacing*(j - 1), s_posy - v_spacing*i), cc.p(.5,.5), container)
			blindTf:setTag(titleNum)
			blindTfArr[#blindTfArr + 1] = blindTf
		end
	end
	return blindTfArr
end
--7天可选
initSevenDays = function (container)
	local startPos  = cc.p(20, _size.height - 83 )
	local bgImgV = UIUtil.addImageView({
										touch = false, scale = true,
										 pos = startPos, size = cc.size(198,724),
										image = "common/com_suspend_bg.png", parent = container,
										ah = cc.p(0,1)})
	bgImgV:setVisible(false)
	bgImgV:setScaleY(0)
	-- local tri_arr = UIUtil.addPosSprite("main/main_trangle2.png", cc.p(170, bgImgV:getContentSize().height), bgImgV, cc.p(0.5,0))
	timearr = container.timeArr
	--添加按钮
	local selectTimeHandler = function(target)
		local tag = target:getTag()
		local startTime = nil
		local endTime = nil

		if tag == 1 then 
			startTime = timearr[2]
			endTime = timearr[#timearr]
			_date_tf:setString(timearr[1])
		else 
			local y = os.date("%Y", timearr[tag])
			local m = os.date("%m", timearr[tag])
			local d = os.date("%d", timearr[tag])
			local bhour, ehour = os.date("%H", 0), os.date("%H", 23)
			startTime = os.time({year = y, month = m, day = d, hour = bhour, min = 0})
			endTime = os.time({year = y, month = m, day = d, hour = ehour, min = 0})
			_date_tf:setString(os.date("%m/%d", startTime))
		end
		--调用更新
		UnionCtrol.requestUnionStatictis((tag-1+7)%8, resfreshUIHandler)
		--隐藏
		local scale = cc.ScaleTo:create(0.1, 1, 0)
		local callfunc = cc.CallFunc:create(function() 
					bgImgV:removeFromParent()
					bgImgV = nil
					container.bgImgV = nil
					_date_btn.fold()
			 end)
		bgImgV:runAction(cc.Sequence:create(scale, callfunc))
	end
	for i = 1, #timearr do 
		local str = timearr[i]
		if i > 1 then 
			str = os.date("%m/%d",tostring(timearr[i]))
		end
		local btn = btnGroup(str, bgImgV, 198/2, 704 - 44 - 88*(i - 1), selectTimeHandler)
		btn:setTag(i)--营造 7 0 1 2 3 4 5 6
	end
	
	--显示
	_date_btn.reveal()
	bgImgV:setVisible(true)
	local scale = cc.ScaleTo:create(0.1, 1, 1)
	local callfunc = cc.CallFunc:create(function()  end)
	bgImgV:runAction(cc.Sequence:create(scale, callfunc))
	bgImgV.noEndedBack = function() 
		bgImgV:removeSelf() 
		bgImgV = nil
		container.bgImgV = nil
		_date_btn.fold()
	end
	TouchBack.registerImg(bgImgV)
	return bgImgV
end


function UnionStatisticsLayer:initUI()
	-- self._isSwallowImg = true
	-- TouchBack.registerImg(self)
	-- UIUtil.addLabelArial("这里是统计", 40, cc.p(_size.width/2, _size.height/2), cc.p(.5,.5), self, cc.c3b(255,255,255))
	--选择标题
	_date_btn ,_date_bg,_date_arrow,_date_tf = initDateSelectUI(self)
	--小标题
	_tf_arr = initSmallTitleUI(self)


	local img = UIUtil.addImageView({image = "common/set_card_MTT_toggle_down.png", pos = cc.p(0, _size.height-97- 100), ah = cc.p(0,1), parent = self,scale = false, touch = false})
	local headtf = UIUtil.addLabelBold("详情 (人)", 28, cc.p(display.width/2, img:getContentSize().height - 19), cc.p(.5,1), img)

	--header
	_tf_blind_arr = initBlindUI(self)
end



function UnionStatisticsLayer:showContent()
	if self.bgImgV then 
		self.bgImgV:removeSelf()
	end
	self:initData()
	-- self.bgImgV = initSevenDays(self)

	UnionCtrol.requestUnionStatictis(7, resfreshUIHandler)
end
function UnionStatisticsLayer:hideContent()
	if self.bgImgV and self.bgImgV:getParent() then 
		self.bgImgV:removeSelf()
		self.bgImgV = nil
	end
end
return UnionStatisticsLayer
