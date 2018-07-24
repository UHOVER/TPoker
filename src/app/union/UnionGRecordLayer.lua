--
-- Author: Taylor
-- Date: 2017-08-01 14:35:45
-- 联盟战绩
local ViewBase = require("ui.ViewBase")
local UnionGRecordLayer = class("UnionGRecordLayer", ViewBase)
local UnionCtrl = require("union.UnionCtrol")

local _size = cc.size(display.width, display.height-130-90)
local _csize = cc.size(display.width, 200)

local SearchWay = {
	settled = 1,
	history = 2
}
--模式
local _display_model = 0  -- 0 普通模式，1 删除模式
--数据与按钮
local _dropIndex = 1 -- 选择的是否结算牌局
local _dropDownTexts = {"未结算", 100, "历史牌局", 200}
local _uiDateQueryBtn = nil --日期查询
local _uiDelAndSureBtn =nil, nil --删除按钮， 确认按钮
local _uiDropDownBtn = nil
local _droplabel = nil 
local _uiTextDialog = nil --下拉框
--tab选择框
local _tabIndex = 100 -- 选择的标题index
local _tab_title = {"标准牌局", 100, "SNG牌局", 200, "MTT比赛", 300}
local _title_colors = {cc.c3b(255, 255, 255), cc.c3b(0, 0, 255)}
local _uiTabBars = {}
local _uiSelectLine = nil

local _uiFooterView = nil
local _uiFooterAct = nil

local _uiTableView = nil

local _uiMark = nil
local _nothingSp = nil

local _datasource = {[100] = {page = 1}, [200] = {page = 1}, [300] = {page = 1}}
local _resetDataFunc = nil

local _isSelectAll = false
local _delSelect = {}

local isTimeSearch = false --是否时间查询
local _sTime ,_eTime = -1, -1
local game_num = 0

--权限
local isLookHistory = false
local isLookSettled = false
local function updateAuthVal()
	isLookHistory = UnionCtrl.isHasAuth(UnionCtrl.Auth_Club_Settle) or UnionCtrl.isHasAuth(UnionCtrl.Auth_SETTLE)
	isLookSettled = UnionCtrl.isHasAuth(UnionCtrl.Auth_URace_Ago) or UnionCtrl.isHasAuth(UnionCtrl.Auth_Club_Settle)
end



local function convert_tag_to_mod(tag)
	if tag == 100 then return 41 end 
	if tag == 200 then return 42 end
    if tag == 300 then return 43 end
end

--转化牌局类型到索引tag
local function getTagByMod(mod)
	mod = tonumber(mod)
	if mod == "sng" or mod == 42 then return 200 end
	if mod == "general" or mod == 41 then return 100 end
	if mod == "mtt" or mod == 43 then return 300 end
	return 100
end

--添加时间确认模式的遮罩
local function addMarkLayer(container)
	if _uiMark then 
		return _uiMark
	end
	local function cancelHandle(sender, evt )
		if evt ~= ccui.TouchEventType.ended then return end
		if _uiMark and _uiMark:getParent() then
		   _uiMark:removeSelf()
		   _uiMark = nil
		end 
		isTimeSearch = false
	end
	local function sureHandle(sender, evt)
		if evt ~= ccui.TouchEventType.ended then return end
		if _uiMark and _uiMark:getParent() then
		   _uiMark:removeSelf()
		   _uiMark = nil
		end 
		
		local settlemode = _dropIndex - 1
		local gdata = {gmod = convert_tag_to_mod(_tabIndex), select_type = settlemode}
		local timeDic = {stime = _sTime, etime = _eTime, gtime = 0}
		local UnionClubResult = require("union.UnionClubResult")
		UnionClubResult.show(nil,{ settled = settlemode, times = timeDic, gamedata = gdata, isTimemode = isTimeSearch}) --timemode = {startTime = xx, endTime = xx}
		isTimeSearch = false
	end

	--几个北京
	_uiMark = display.newLayer(cc.c4b(255,255,255,0), _size):addTo(container)
	local mark = display.newLayer(cc.c4b(57, 77, 74, 255*0.6), _uiTableView:getViewSize()):addTo(_uiMark)
	mark._isSwallowImg = true
	TouchBack.registerImg(mark)
	mark.noEndedBack = function(touch, event)
		cancelHandle(nil, ccui.TouchEventType.ended)
	end

	local timeStr = os.date("%m/%d %H:%M", _sTime).." - ".. os.date("%m/%d %H:%M", _eTime)
	local gameStr = "共"..tostring(game_num).."局"
	display.newLayer(cc.c3b(33, 38, 50), _size.width, 167):addTo(_uiMark)
	UIUtil.addLabelArial(timeStr, 26, cc.p(20, 133), cc.p(0, .5), _uiMark)
	UIUtil.addLabelArial(gameStr, 26, cc.p(_size.width-20, 133), cc.p(1, .5), _uiMark)

	local leftBtn = display.newLayer(cc.c3b(134,135,136), _size.width/2-1, 100):addTo(_uiMark)
	local rightBtn = display.newLayer(cc.c3b(71,102,201), _size.width/2-1, 100):addTo(_uiMark):move(_size.width/2+1, 0)
	local imgArr = {ResLib.COM_OPACITY0, ResLib.COM_OPACITY0, ResLib.COM_OPACITY0}
	UIUtil.addUITextButton({imgs = imgArr, size = cc.size(_size.width/2-1, 100), scale = true, ah = cc.p(0,0), pos=cc.p(0,0), text = "取消", fsize = 44, funcBack = cancelHandle, parent = leftBtn})
	UIUtil.addUITextButton({imgs = imgArr, size = cc.size(_size.width/2-1, 100), scale = true, ah = cc.p(0,0), pos=cc.p(0,0), text = "确定", fsize = 44, funcBack = sureHandle, parent = rightBtn})
	_uiMark:setLocalZOrder(StringUtils.getMaxZOrder(container))
	return _uiMark
end

--添加drop text
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
	uText:setPosition(160/2, 68/2)
	uText:setTextColor(cc.c3b(0,0,0))
	uText:setAnchorPoint(cc.p(0.5,0.5))
	widget:addChild(uText)

	display.newLayer(cc.c3b(171,171,171), 147, 1)
	:addTo(widget)
	:align(cc.p(.5,.5), 160/2, -5)
	:ignoreAnchorPointForPosition(false)
	return widget
end

local function addDropTextAlertDialog(container)
	local startPos  = cc.p(20, _size.height-83 )
	local bgImgV = UIUtil.addImageView({
										touch = false, scale = false,
										 pos = startPos, size = cc.size(198,196),
										image = "common/com_suspend_bg.png", parent = container,
										ah = cc.p(0,1)})
	bgImgV:setCapInsets(cc.rect(10,24,10,24))
	local function selectHandle(target)
		local tag = target:getTag()
		print("tag"..tag)
		_droplabel:setString(_dropDownTexts[tag * 2 - 1])
		_droplabel:setTag(tag)
		_dropIndex = tag 

		_uiDropDownBtn.fold()
		_uiTextDialog:removeSelf()
		_uiTextDialog = nil
		
		_uiDateQueryBtn:setVisible(tag == 2)
		-- 10.7.0 才开放
		-- _uiDelAndSureBtn:setVisible(tag == 2)
		-- _display_model = 0
		-- _uiDelAndSureBtn.state = 1
		_resetDataFunc()
		UnionGRecordLayer.refreshLoadFunc(1)
	end

	for i = 1, #_dropDownTexts/2 do
		local btn =  btnGroup(_dropDownTexts[i*2-1], bgImgV, 200/2, 182 - 90 * (i-1)-20, selectHandle)
		btn:setAnchorPoint(0.5, 1)
		btn:setTag(i)
	end
	bgImgV:setScaleY(0)
	_uiTextDialog = bgImgV
	_uiTextDialog:scaleTo({time = 0.2, scaleY = 1})

	bgImgV.noEndedBack = function() 
		_uiDropDownBtn.fold()
		_uiTextDialog:removeSelf()
		_uiTextDialog.noEndedBack = nil
		_uiTextDialog = nil
		bgImgV = nil
	end
	TouchBack.registerImg(bgImgV)

	return _uiTextDialog
end

--添加按钮
local function addTopButtonSectionUI(container)

	local queryhandle = function(startTime, endTime) 
		_resetDataFunc()
		isTimeSearch = true
		UnionGRecordLayer.refreshLoadFunc(1, startTime, endTime)
	end

	local dateQueryHandle = function(sender, evt)
		if evt ~= ccui.TouchEventType.ended then 
			return
		end
		local scene = cc.Director:getInstance():getRunningScene()
		local datePicker = require("union.UIDateRangePicker")
		datePicker.show(scene, {confirmFuc = queryhandle, endtime = os.time(), spantime = 2*24*60*60})
	end

	local delHandle = function(sender, evt)
		if (_uiDelAndSureBtn.state == 1) then 
			_delSelect = {}
			_display_model = 1
			_uiDelAndSureBtn:setTitleText("确认")
			_uiDelAndSureBtn.state = 2
			_uiTableView:reloadData()

			return
		end

		if (_uiDelAndSureBtn.state == 2) then 
			UnionCtrl.deleteUnionGameRaces(convert_tag_to_mod(_tabIndex), _delSelect, function(data) 
						_display_model = 0
						_delSelect = {}
						_uiDelAndSureBtn:setTitleText("删除")
						_uiDelAndSureBtn.state = 1
						_uiTableView:reloadData()
				end)
		end
	end

	local params1 = {parent = container, ah = cc.p(1, 0.5), pos = cc.p(_size.width - 14, _size.height-50),
					igAsize = false, size = cc.size(137,61), text = "日期查询", tcolor = ResLib.COLOR_BLUE,
					funcBack = dateQueryHandle, fsize = 24}
	_uiDateQueryBtn = UIUtil.addUITextButton(params1)
	_uiDateQueryBtn:setVisible(_dropIndex == 2)

	 params1 = {parent = container, ah = cc.p(1, 0.5), pos = cc.p(_size.width - 14, _size.height-50),
					igAsize = false, size = cc.size(137,61), text = "删除", tcolor = ResLib.COLOR_BLUE,
					funcBack = delHandle, fsize = 24}
	_uiDelAndSureBtn = UIUtil.addUITextButton(params1)
	_uiDelAndSureBtn.state = 1
	_uiDelAndSureBtn:setVisible(false)
end
--添加可选类型按钮UI
local function addTopDropSectionUI(container)
	_uiDropDownBtn = UIUtil.addImageView({touch = true, scale = false, size = cc.size(198,54),
						 image = "club/drop_bg.png", pos = cc.p(18, _size.height - 76),
						 ah = cc.p(0, 0), parent = container})

	local offsetx = (198-144)*0.5 + 144+2
	local drop_arrow = UIUtil.addPosSprite("club/upward.png",cc.p(offsetx, 60/2), _uiDropDownBtn)
	drop_arrow:setTag(100)
	_droplabel = UIUtil.addLabelArial(_dropDownTexts[_dropIndex*2-1], 26, cc.p(144/2, 54/2), cc.p(0.5,.5), _uiDropDownBtn)
	_droplabel:setTag(_dropIndex)
	--点击下拉显示选择
	local function clickSelectHandler(evt)
		if _uiTextDialog then 
			_uiDropDownBtn.fold()
			_uiTextDialog:removeSelf()
			_uiTextDialog = nil
		else 
			_uiDropDownBtn.reveal()
			_uiTextDialog = addDropTextAlertDialog(container)
		end
	end
	_uiDropDownBtn:touchEnded(clickSelectHandler)

	local function setCusEnabled(isTouch, color , shader)
		_droplabel:setColor(ResLib.COLOR_WHITE)
		UIUtil.setGLProgramStateToNode(_uiDropDownBtn:getVirtualRenderer(), shader)
		-- UIUtil.setGLProgramStateToNode(drop_bg:getVirtualRenderer(), shader)
		_uiDropDownBtn:setTouchEnabled(isTouch)
	end
	if isLookHistory and isLookSettled then 
		setCusEnabled(true,display.COLOR_WHITE,nil)
	else 
		setCusEnabled(false,ResLib.COLOR_GREY, "ShaderUIGrayScale")
	end 

	_uiDropDownBtn.fold = function() drop_arrow:setTexture("club/upward.png") end
	_uiDropDownBtn.reveal = function() drop_arrow:setTexture("club/downward.png") end
end


--添加tabbar滚动UI & listener
local function switchTab(sender)
	local index = sender.index
	if not _uiTabBars or #_uiTabBars <= 0 then 
		return 
	end
	local oldTabIndex = _tabIndex
	_tabIndex = sender:getTag()
	print("_tabIndex:".._tabIndex)
	if oldTabIndex == _tabIndex then 
		print("重复点击")
		return 
	end

	for i = 1, #_uiTabBars do 
		local tabBar = _uiTabBars[i]
		local isSelect = (i == index)
		tabBar:setSelected(isSelect)
		tabBar:setEnabled(not isSelect)
	end
	
	if _uiSelectLine then 
		_uiSelectLine:moveTo({time = 0.2, x = sender:getPositionX()})
	end

	if _display_model == 1 then 
		_delSelect = {}
		_isSelectAll = false
	end

	if _uiTableView then 
	   -- _uiTableView:reloadData()
	   local datalist = _datasource[_tabIndex]
	   UnionGRecordLayer.refreshLoadFunc(datalist.page, _sTime, _eTime, true)
	end
end

local function addTabBarSectionUI(container)
	local node = display.newNode():addTo(container):move(0, _size.height-177)
	display.newLayer(cc.c3b(34,39,51),display.width, 2):addTo(node):move(0, 81)
	display.newLayer(cc.c3b(34,39,51),display.width, 2):addTo(node):move(0, 0)
	--初始化tabbar Button

	local function setButtonState(btn, str, color, state)
		local label1 = cc.Label:createWithSystemFont(str, "Arial", 32)
		btn:setTitleLabelForState(label1, state)
		btn:setTitleColorForState(color, state)
	end
	local seqWidth, seqHeight= _size.width / 3, 83
	for i = 1, #_tab_title/2 do 
		local tmpx = (i-1)*seqWidth
		-- local label1 = cc.Label:createWithSystemFont(_tab_title[i*2-1], "Marker Felt", 36)
		local btn = UIUtil.controlBtn(ResLib.COM_OPACITY0, ResLib.COM_OPACITY0, ResLib.COM_OPACITY0, nil, 
									cc.p(tmpx, 0), cc.size(seqWidth, seqHeight), switchTab, node)
		setButtonState(btn, _tab_title[i*2-1], display.COLOR_WHITE, cc.CONTROL_STATE_NORMAL)
		setButtonState(btn, _tab_title[i*2-1], ResLib.COLOR_BLUE4, cc.CONTROL_STATE_HIGH_LIGHTED)
		setButtonState(btn, _tab_title[i*2-1], ResLib.COLOR_BLUE4, cc.CONTROL_STATE_DISABLED)
		setButtonState(btn, _tab_title[i*2-1], ResLib.COLOR_BLUE4, cc.CONTROL_STATE_SELECTED)
		btn:setAnchorPoint(cc.p(0,0))
		btn:setTag(_tab_title[i * 2])
		btn.index = i
		_uiTabBars[#_uiTabBars + 1] = btn
	end
	-- _uiTabBars[1]:setSelected(true)
	_uiTabBars[1]:setHighlighted(true)
	_uiSelectLine = display.newLayer(ResLib.COLOR_BLUE,seqWidth, 4):addTo(node):move(0, -1)
end

----------------------------------------------------------------------------
------------------------------------------------------------------------
--添加footer， 添加刷新检测，添加位置检测
------------------------------------------------------------------------
local refreshState = {
	load_idel = 0,
	load_prepare = 1, 
	load_start = 2,
	load_ing = 3,
	load_exit = 4,
	load_end = 5
}
local _loadState = refreshState.load_idel
local function refreshFooterForIdel(target, table)
	if table:isDragging() and table:isTouchMoved() then 
		_loadState = refreshState.load_prepare
		-- _uiFooterView:setVisible(true)
		_uiFooterView:getChildByName("action"):setOpacity(10)
	end
end

local function refreshFooterForPrepare(target, table)
	local isDragging, isMove = table:isDragging(), table:isTouchMoved()
	local originy = math.max(table:getViewSize().height - table:getContentSize().height, 0)
	local up_offsety = table:getContentOffset().y - originy
	local opacity = math.max(0, (up_offsety - 10) / 120)
	opacity = math.min(1, opacity)
	_uiFooterView:getChildByName("action"):setOpacity(255*opacity)

	if up_offsety > 120 and not isDragging and not isMove then 
		_loadState = refreshState.load_start
		-- print("进入加载")
	elseif up_offsety < 10  then 
		_loadState = refreshState.load_end
		-- _uiFooterView:setVisible(false)
		-- print("不进入加载")
	end
end

local function refreshFooterForStart(target, table)
	local cHeight = table:getContentSize().height
	local vHeight = table:getViewSize().height
	local waitPosy = math.max(vHeight - cHeight, 0) + 100
	table.OldHeight = cHeight
	print("table.OldHeight:"..table.OldHeight)
	_loadState = refreshState.load_ing
	table:stopAnimatedContentOffset()
	table:setTouchEnabled(false)
	local d = table:getContentOffset().y - waitPosy
	local k1, k2, k3 = 1, 0.01, 0.9
	local t = 0.5/(0.5 + d*k2 + d*d*k3)

	local moveTo = cc.MoveTo:create(t, cc.p(0, waitPosy))
	local callback = cc.CallFunc:create(function() 
				_uiFooterView:getChildByName("action"):setOpacity(255)
				table:stopAnimatedContentOffset()

				if refreshLoadFunc or target.refreshLoadFunc then 
				local refresh = refreshLoadFunc or target.refreshLoadFunc or function() end
					local datalist = _datasource[_tabIndex]
					refresh(datalist.page, _sTime, _eTime, true)
				end
		end)
	table:getContainer():runAction(cc.Sequence:create(moveTo, callback))
	_uiFooterAct:play('load', true)
end
local function refreshFooterForLoading(target, table)
	-- print("loading")

end

local function refreshFooterForExit(target, table)

	_loadState = refreshState.load_end
	local basey = table.OldHeight - table:getContentSize().height
	print("table:getContentSize().height",table:getContentSize().height)
	local vHeight = table:getViewSize().height
	if table.OldHeight < table:getViewSize().height then  
		basey = table:getViewSize().height - table:getContentSize().height
		print("lalalla,我是"..basey)
	end
	local footPosy = -70
	if table:getContentSize().height < table:getViewSize().height then 
		local tempy = table:getViewSize().height - table:getContentSize().height  
		footPosy = 0 - tempy - 70
	end

	table:getContainer():setPositionY(basey)
	print("为什么basey", basey)
	table:setTouchEnabled(true)
	_uiFooterView:setPositionY(footPosy)
	_uiFooterAct:play("stop", true)
	_uiFooterView:getChildByName("action"):setOpacity(0)
end

local function refreshFooterForEnd(target, table)
	_loadState = refreshState.load_idel
	-- _uiFooterView:setVisible(false)
end
local function setRefreshEnd()
	 if _loadState == refreshState.load_ing then 
	    _loadState = refreshState.load_exit
	    print("结束啦")
	 end
end

local stateHandler = {
	[0] = refreshFooterForIdel,
	[1] = refreshFooterForPrepare,
	[2] = refreshFooterForStart,
	[3] = refreshFooterForLoading,
	[4] = refreshFooterForExit,
	[5] = refreshFooterForEnd
}

local function checkFooterPos()
	if not _uiFooterView or not _uiFooterAct then 
		return
	end
	local basey = math.max(_uiTableView:getViewSize().height - _uiTableView:getContentSize().height, 0)
	basey = 0 - basey - 70
	print("basey:",basey, "offsety:", _uiTableView:getViewSize().height - _uiTableView:getContentSize().height)
	_uiFooterView:setPosition(display.cx,basey)
end

local function checkRefreshView(target)
	local stateFunc = stateHandler[_loadState]
	stateFunc(target, _uiTableView)
end

local function removeTableCell(gmod, gId)
	print("更新:"..gmod, "gId:"..gId)
	local tag = getTagByMod(gmod)
	local datalist = _datasource[tag]
	if #datalist <= 0 then 
		return 
	end
	local i = #datalist 
	while i > 0 do
		local data = datalist[i]
		-- dump(data)
		if tonumber(data.mod) == gmod and tonumber(data.id) == gId then 
			table.remove(datalist, i)
			print("i:",i)
			break
		end
		i = i - 1
	end
	-- scheme 1 _uiTableView:removeCellAtIndex(i-1)
	-- scheme 2
	datalist.page = math.ceil(#datalist/15)+1
	_uiTableView:reloadData()
	checkFooterPos()
	--scheme 3
	-- UnionGRecordLayer.refreshLoadFunc(1)
end
--------------------------END refresh------------------------------
-------------------------------------------------------------------

local function addFooterForTableView()
	_uiFooterView = cc.CSLoader:createNode("action/loadingAction.csb")
	_uiFooterAct = cc.CSLoader:createTimeline("action/loadingAction.csb")
	_uiFooterView:runAction(_uiFooterAct)
	-- _uiFooterView:setVisible(false)
	if _uiTableView then 
		_uiTableView:addChild(_uiFooterView)
	end
	checkFooterPos()
end

local function tableCellTouched(table, cell)
	if _display_model == 1 then 
		return
	end

	local idx = cell:getIdx()
	local tdata = _datasource[_tabIndex][idx + 1]

	-- tdata['id'] = 31256
	-- _tabIndex = 100
	local settlemode = _dropIndex - 1
	local gdata = {gmod = convert_tag_to_mod(_tabIndex), gId = tdata['id'], select_type = settlemode, title = tdata['name'], insure = tdata['secure']}
	local timeDic = {stime = _sTime, etime = _eTime, gtime = tdata['start_time']}
	local UnionClubResult = require("union.UnionClubResult")
	UnionClubResult.show(nil,{ settled = settlemode, times = timeDic, gamedata = gdata, isTimemode = isTimeSearch}) --timemode = {startTime = xx, endTime = xx}
	UnionClubResult.setCallbackFunc(removeTableCell)
end

local function addCellLayer(idx, layer)
	-- local prevData = _datasouce[_tabIndex][idx - 1]
	if idx == 1 and _display_model == 1 then 
		local function selectAllDelFunc(sender, eType)
			_delSelect = {}
			if eType == 0 then 
				_isSelectAll = true
				table.walk(_datasource[_tabIndex], function(v, k) _delSelect[#_delSelect + 1] = v['id'] end)
			else
				_isSelectAll = false
			end
			_uiTableView:reloadData()
		end
		local bg = display.newLayer(cc.c3b(0, 0, 0), display.width, 100):addTo(layer)
		local checkBox = UIUtil.addCheckBox({pos = cc.p(37,50), checkboxFunc = selectAllDelFunc, parent = bg})
		checkBox:setAnchorPoint(cc.p(0,0.5))
		checkBox:setSelected(_isSelectAll)
		UIUtil.addLabelArial("全部选择", 35, cc.p(79, 50), cc.p(0,.5), layer)
		return
	end
	idx = idx - _display_model
	local tdata = _datasource[_tabIndex][idx]
	local colorM1 = cc.c3b(38,75,161)
	local colorL1 = cc.c3b(255,0,0)
	
	tdata['mod'] = tonumber(tdata['mod'])

	local img = 'result/result_black1.png'
	if idx == 1 then
		img = 'result/result_black2.png'
	end
 
	if(tdata['typeMod'] == 1) then
		colorM1 = cc.c3b(38,75,161)
	elseif(tdata['typeMod'] == 2) then
		colorM1 = cc.c3b(252,96,1)
	elseif(tdata['typeMod'] == 4) then
		colorM1 = cc.c3b(160,110,248)
	end
	local th = _csize.height
	local tw = _csize.width
	local topy = th - 12
	--竖线旁边的日期年月日
	local day, month, year = os.date("%d日", tdata.start_time), os.date("%m月", tdata.start_time), "" --os.date("%Y", tdata.start_time)
	-- if prevData then 
	-- 	local prevDay,prevMonth,prevYear = prevData['dayText'],prevData['monthText'],prevData['yearText']
	-- 	if prevDay == day and prevMonth == month and prevYear == year then 
	-- 		day, month, year = "", "",""
	-- 	end
	-- end
	UIUtil.addLabelArial(day, 34, cc.p(85,th-42), cc.p(1,1), layer, ResLib.COLOR_GREY3, 'Arial-BoldMT')
	UIUtil.addLabelArial(month, 24, cc.p(85,th-81), cc.p(1,1), layer, ResLib.COLOR_GREY3, 'Arial-BoldMT')
	UIUtil.addLabelArial(year, 20, cc.p(85,th-108), cc.p(1,1), layer, ResLib.COLOR_GREY3, 'Arial-BoldMT')
	

	--竖线
	local linex = 110
	display.newLayer(cc.c3b(30,36,50), 1, th):align(cc.p(.5,0), linex, 0):addTo(layer):ignoreAnchorPointForPosition(false)
	--竖线穿过的闹钟图标
	UIUtil.addPosSprite('result/result_time2.png', cc.p(linex,th - 36), layer, cc.p(0.5,1))
	
	--图标
	local typeimg ,imgTag, textTag, text2Tag,imgTag2 = "result/result_tag1.png","result/result_bet2.png",0,0,"result/result_clock2.png"
	if tdata['mod'] == UnionCtrl.game.sng  then
		 typeimg = 'result/small_mark_sng.png'
		 imgTag = "result/result_person.png"
		 textTag = tdata['d_pnum'].."/"..tdata['d_pnum']
		 text2Tag = tdata.d_fee.."+"..tdata.d_fee/10
		 imgTag2 = "result/result_person.png"
    elseif tdata['mod'] == UnionCtrl.game.stand then
    	 typeimg = 'result/small_mark_stand.png'
    	 imgTag = "result/result_bet2.png"
    	 textTag = (tdata.d_blind/2)..'/'..tdata.d_blind
    	 text2Tag =  string.format("%.1f", (tdata.d_time/3600))..'个小时局'
    	 imgTag2 = 'result/result_time2.png'
    elseif tdata['mod'] == UnionCtrl.game.mtt then 
    	 typeimg = 'result/result_mark_mtt.png' 
    	 imgTag = "result/result_person.png"
    	 text2Tag = tdata.d_fee.."/"..tdata.d_fee/10
    	 textTag = tdata['d_pnum'].."/"..tdata['d_pnum']
    	 imgTag2 = ""
    end
	UIUtil.addPosSprite(typeimg, cc.p(linex,th/2- 30), layer, nil)
	
	UIUtil.addLabelArial(os.date("%H:%M",tdata['start_time']), 24, cc.p(linex+47, th - 42), cc.p(0,1), layer, ResLib.COLOR_GREY3)
	--时间 + 来自XXXX
	local txtTitle = UIUtil.addLabelArial("来自联盟", 24, cc.p(266,th - 42), cc.p(0,1), layer, ResLib.COLOR_GREY3)
	--玩家名称
	local nameTf = UIUtil.addLabelArial(tdata['name'], 35, cc.p(266, th/2 + 8), cc.p(0,1), layer, colorM1)
	--头像
	local stencil,head = UIUtil.addUserHead(cc.p(141.5 +55,th/2+15 - 50), tdata['c_hurl'], layer, true)
	stencil:setScale(0.85)
	head:setScale(0.85)

	--增加一条来自
	--UIUtil.addLabelArial(tdata['fromWhere'], 18, cc.p(150,th/2 - 43), cc.p(0,1), layer, clolr2)

	-- 标示:人、bet
	local ty = 24
	local sx = 200
	UIUtil.addPosSprite(imgTag, cc.p(sx + 70,ty + 10), layer, cc.p(0,0.5))
	UIUtil.addLabelArial(textTag, 30, cc.p(sx+105,ty + 10), cc.p(0,0.5), layer, cc.c3b(170,170,170))
	local tag2x = sx+165 + 20

	--闹钟和钱币的图片
	if imgTag2 ~= '' then
		--tag2x = sx+145
		UIUtil.addPosSprite(imgTag2, cc.p(sx+190 + 20,ty+ 10), layer, cc.p(0,0.5))
	else
		UIUtil.addPosSprite("result/rmoney1.png", cc.p(sx+190 + 20,ty+ 10), layer, cc.p(0,0.5))
	end

	--后面跟着的数据
	UIUtil.addLabelArial(text2Tag, 30, cc.p(tag2x + 70,ty+ 10), cc.p(0,0.5), layer, cc.c3b(170,170,170))


	--num bet
	local numbet,img = tdata['result_bet'] ,"result/result_numbg1.png"
	if numbet == "" then 
		img = 'result/result_numbg2.png'
	elseif numbet > 0 then 
		img = 'result/result_numbg3.png'
		numbet = '+'..numbet
	elseif numbet < 0 then 
		img = 'result/result_numbg2.png'
	end
	local label = cc.Label:createWithSystemFont(numbet, 'Arial', 25)
	local ttw = label:getContentSize().width + 20
	if ttw < 60 then
		ttw = 60
	end
	local numbg = UIUtil.scale9Sprite(cc.rect(30,0,30,0),img, cc.size(ttw,48), cc.p(717,20), layer)
	numbg:setAnchorPoint(1,0)
	numbg:setOpacity(0)

	
	if(img == "result/result_numbg3.png") then
		colorL1 = cc.c3b(204,0,1)
	elseif (img == "result/result_numbg2.png")then
		colorL1 = cc.c3b(0,133,60)
	else
		colorL1 = cc.c3b(170,170,170)
	end

	--红色或者绿色的积分
	UIUtil.addLabelArial(numbet, 30, cc.p(ttw/2,122), cc.p(0.5,0.5), numbg, colorL1)
		  :setVisible(false)

	--添加保险标志
	if(tdata['secure'] == 1) then
	 	UIUtil.addPosSprite('result/r_baoxianju.png', cc.p(nameTf:getPositionX() + nameTf:getContentSize().width + 33.5,nameTf:getPositionY()-nameTf:getContentSize().height/2), layer)
	end
--[[
	local th = _csize.height
	local topy = th - 12
	UIUtil.addLabelArial("testidx="..idx, 28, cc.p(51,topy-40), cc.p(0.5,1), layer, clolr1, 'Arial-BoldMT')
]]
	if _display_model == 1 then 
		local function checkBoxFunc( sender, eventType )
			local tag = sender:getTag()
			local pokeid = tdata["id"]
			-- local index = table.indexof(_delSelect, pokeid)
			if eventType == 0 then
				_delSelect[#_delSelect + 1] = pokeid
			else
				table.removebyvalue(_delSelect, pokeid, true)
			end
		end
		local checkBox = UIUtil.addCheckBox({pos = cc.p(37,th/2- 30), checkboxFunc = checkBoxFunc, parent = layer})
		checkBox:setAnchorPoint(cc.p(0,0.5))
		-- girdNodes.checkBox = checkBox
		local index = table.indexof(_delSelect, tdata['id'])
		local isSelect = _isSelectAll or (type(index) == "number")
		checkBox:setSelected(isSelect)
	end
end


local function numberOfCellsInTableView(table)
	local curData = _datasource[_tabIndex]
	local number = #curData
	if _display_model  == 1 then 
		number = number + 1
	end
	return number
end

local function scrollViewDidScroll(view)
	checkRefreshView(view:getParent())
end

local function cellSizeForIndex(table, idx)
	if idx == 0 and _display_model == 1 then 
		return display.width, 100
	else 
		return _csize.width, _csize.height
	end
end
--添加tableView UI
local function addTableViewSectionUI(container)
	local viewSize = cc.size(_size.width, _size.height - 182)
	-- local viewSize = cc.size(_size.width, 935)
	_uiTableView = UIUtil.addTableView(viewSize, cc.p(0,0), cc.SCROLLVIEW_DIRECTION_VERTICAL, container)
	_uiTableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
	DZUi.addTableView(_uiTableView,_csize,nil,addCellLayer,true,nil)
	_uiTableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
	_uiTableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
	_uiTableView:registerScriptHandler(scrollViewDidScroll,cc.SCROLLVIEW_SCRIPT_SCROLL)
	_uiTableView:registerScriptHandler(cellSizeForIndex, cc.TABLECELL_SIZE_FOR_INDEX)
	_uiTableView:setBounceable(true)
	_uiTableView:setTouchEnabled(true)
	addFooterForTableView()
end



function UnionGRecordLayer:ctor()
	-- local layer = display.newLayer(cc.c3b(0,0,0), display.size):addTo(self)
	-- layer._isSwallowImg = true 
	-- TouchBack.registerImg(layer)

	self:setContentSize(_size)
	self:enableNodeEvents()
	self:initData()
	self:initUI()
end

function UnionGRecordLayer:onEnter()
end

function UnionGRecordLayer:onExit()
	_resetDataFunc()
	_uiTableView = nil
	_uiFooterView = nil
	_uiMark = nil
	_uiTabBars = nil
	_uiFooterAct = nil
	_uiTextDialog = nil
	_uiDateQueryBtn = nil 
	_uiDelAndSureBtn = nil
	_uiDropDownBtn = nil 
	_uiSelectLine = nil
	_droplabel = nil
	_tabIndex = nil
	_display_model = nil
	_nothingSp = nil
	_dropIndex = 1
end

_resetDataFunc = function()
	-- dump("", "重置数据-打法")
	_datasource = {[100] = {page = 1}, [200] = {page = 1}, [300] = {page = 1}}
	_delSelect = {}
	_sTime, _eTime = -1, -1
	isTimeSearch = false
	game_num = 0
end

function UnionGRecordLayer:initData()
	_resetDataFunc()
	updateAuthVal()
	_uiTabBars = {}
	_tabIndex = 100
	_display_model = 0
end

function UnionGRecordLayer:initUI()
	if not isLookHistory and not isLookSettled then 
		UIUtil.addPosSprite(ResLib.COM_NO_ANYTHING, cc.p(_size.width/2, _size.height-306), layer)
		UIUtil.addLabelArial("很抱歉！您没有查看战绩的权利",34,cc.p(_size.width/2, _size.height-496), cc.p(.5,1), layer, cc.c3b(170,170,170))
		return
	elseif isLookHistory and not isLookSettled then 
		_dropIndex = 1
	elseif not isLookHistory and isLookSettled then 
		_dropIndex = 2
	end

	addTopDropSectionUI(self)
	addTopButtonSectionUI(self)
	addTabBarSectionUI(self)
	addTableViewSectionUI(self)

	--没权限提示
	_nothingSp = display.newNode():addTo(self):move(display.cx, _size.height - 292)
	local sp = UIUtil.addPosSprite(ResLib.COM_NO_ANYTHING, cc.p(0,0), _nothingSp, cc.p(.5,1))
	local tips = UIUtil.addLabelArial("暂无权限", 34, cc.p(0, sp:getPositionY() - sp:getContentSize().height - 82), cc.p(.5,1), _nothingSp, cc.c3b(170,170,170))
	_nothingSp:setVisible(not isLookHistory and not isLookSettled)
	_nothingSp.tipTf = tips
end



local function attachData(data)
	game_num = data.data_num
	local histories = data.game_data or {}

	if #histories > 0 then 
		local mod = histories[1]['mod']
		local datalist = _datasource[getTagByMod(tonumber(mod))]
		datalist.page = datalist.page + 1
		_nothingSp:setVisible(false)
	elseif #_datasource[_tabIndex] <= 0 then 
		_nothingSp:setPositionY(_size.height - 182 - 92)
		_nothingSp.tipTf:setString("没有查询到任何牌局额。")
		_nothingSp:setVisible(true)
	else 
		_nothingSp:setVisible(false)
	end

	for i = 1, #histories do 
		local celldata = histories[i]
		local tag = getTagByMod(tonumber(celldata['mod']))
		
		local datalist = _datasource[tag]
		datalist[#datalist + 1] = celldata
		if _isSelectAll then 
			_delSelect[#_delSelect + 1] = celldata['id']
		end
	end

	local time = 1/60
	if _loadState == refreshState.load_ing then 
		time = 1
	end
	local delayTime = cc.DelayTime:create(time)
	local callback = cc.CallFunc:create(function() 
		  -- print("刷新>>>>>>>>>>>>>>>>>")
		   	 setRefreshEnd()
			 _uiTableView:reloadData() 
			 checkFooterPos()
			 if isTimeSearch and #histories > 0 then 
			 	addMarkLayer(_uiDateQueryBtn:getParent())
			 else 
			 	isTimeSearch = false
			 end
		end)
	
	_uiTableView:getContainer():runAction(cc.Sequence:create(delayTime, callback))
end

--根据传入的sTime,以及eTime来判断是否是日期查询，历史查询，未结算查询
function UnionGRecordLayer.refreshLoadFunc(pageIndex, sTime, eTime, noWait)
	local game_mod = convert_tag_to_mod(_tabIndex)
	local isNotSearchByTime = (not sTime or sTime == -1) and (not eTime or eTime == -1)
	print(tostring(_dropIndex), tostring(isNotSearchByTime))
	if _dropIndex == 2 and isNotSearchByTime then --历史牌局 & 非时间查询  默认时间查询范围
		eTime = os.time()
		sTime = eTime - 24*2*60*60
	end
	_sTime = sTime or -1
	_eTime = eTime or -1
	local race_model = _dropIndex - 1
	_nothingSp:setVisible(false)
	UnionCtrl.requestUnionGameRaces(race_model, game_mod, pageIndex, _sTime, _eTime, attachData, noWait )
end



function UnionGRecordLayer:hideContent()
	self:unscheduleUpdate()
end

function UnionGRecordLayer:showContent()
	updateAuthVal()
	if not isLookHistory and not isLookSettled then 
		do return end
	end

	local datalist = _datasource[_tabIndex]
	print("页码："..datalist.page)
	if datalist.page == 1 then 
		self.refreshLoadFunc(1)
		self:onUpdate(handler(self, self.update))
	end
end

function UnionGRecordLayer:update(dt)
	checkRefreshView(self)
end
return UnionGRecordLayer
