--
-- Author: Taylor
-- Date: 2017-08-01 14:23:48
--
-- 查看联盟的面板界面


local ViewBase = require("ui.ViewBase")
local DashBoardLayer = class("DashBoardLayer", ViewBase)
local UnionCtrol = require("union.UnionCtrol")
local _topy = display.height - 130
local _view = nil
--class数组
function DashBoardLayer:ctor()
	self:enableNodeEvents()
	self:initData()
	self:initUI()
end

--邀请回调
local  function inviteHandler ()
	local curScene = cc.Director:getInstance():getRunningScene()
	AddCtrol.setAddTarget( AddCtrol.UNION_CLUB )
	local _cityLayer = require("main.CityLayer"):create("add")
	curScene:addChild(_cityLayer,StringUtils.getMaxZOrder(curScene))
end

local function dismissHandler(sender, evt)
	if evt ~= ccui.TouchEventType.ended then 
		return
	end
	print("解散")
	local unionMember = UnionCtrol.getUnionCMember()
	if #unionMember == 0 then 
		UnionCtrol.requestDissolveUnion(function() 
				_view:removeFromParent()

				ViewCtrol.showTip({content = "删除联盟成功!"})
			end)
	else 
		ViewCtrol.showTip({content = "解散联盟前请先删除所有俱乐部!"})
	end
end

-------------------------创建TopBar--------------------------------
------------------------------------------------------------------
--俱乐部访问消息统计topbar
local function createTopBarForClub(container, index)
	local refreshHandle = function() 
		local club_id = UnionCtrol.getUnionCMember()[1].club_id
		local ClubCtrol = require("club.ClubCtrol")
		ClubCtrol.dataStatClubInfo( club_id, function ()
			container:removeFromParent()
			local myEvent = cc.EventCustom:new("C_Event_update_ClubInfo")
			local customEventDispatch = cc.Director:getInstance():getEventDispatcher()
			customEventDispatch:dispatchEvent(myEvent)
		end )
		ClubCtrol = nil
	end
	
	local quitUnionHandler = function()
		local function callback() 
			local unionMember = UnionCtrol.getUnionCMember()
			if not unionMember or #unionMember <= 0 then 
				return 
			end
			local club_id = unionMember[1].club_id
			UnionCtrol.requestDelUnionClub({club_id}, refreshHandle)
		end
		ViewCtrol.popHint({content = "是否退出本联盟?", sureFunBack = callback,bgSize = cc.size(display.width-100, 300)})
	end

	local backHandler = function()
		container:removeSelf() 
	end

	local tbData = {["backFunc"] = backHandler, title = container._title, parent = container}
	if UnionCtrol.isStatus(UnionCtrol.STATUS_C_HEAD) then 
		tbData['menuFont']="退出" 
		tbData['menuFunc']=quitUnionHandler
	end
	return UIUtil.addTopBar(tbData)
end

local function createTopBarForUnion(container, index)
	local backHandler = function() container:removeSelf() end
	local isHeader = UnionCtrol.isStatus(UnionCtrol.STATUS_HEAD)
	local tbData = {["backFunc"]= backHandler,title = container._title, parent = container}
	if isHeader then 
		tbData['menuFont'] = "邀请"
		tbData['menuFunc'] = inviteHandler
	end
	local topBar = UIUtil.addTopBar(tbData)

	if isHeader then 
		local btn = UIUtil.addUIButton({"","",""}, cc.p(display.width-168,topBar:getContentSize().height/2-22),topBar,dismissHandler)
		btn:setTitleText("解散")
		btn:setTitleFontSize(34)
		btn:setTitleColor(cc.c3b(152, 152, 152))
	end
	return topBar
end

--联盟信息topbar
local function createUnionInfoBar(container, index)
	if UnionCtrol.getVisitFrom() == UnionCtrol.club_union then 
		return createTopBarForClub(container, index)
	else 
		return createTopBarForUnion(container, index)
	end
end

--牌局列表topbar
local function createGameListBar(parent, index)
	return createUnionInfoBar(parent, index)
end
--战绩列表topbar
local function createRecordBar(parent, index)
	return createUnionInfoBar(parent, index)
end
--静态统计topbar
local function createStatisticBar(parent, index)
	return createUnionInfoBar(parent, index)
end


local topBarHandleList = {
							[100] = createUnionInfoBar,
							[200] = createGameListBar,
							[300] = createRecordBar,
							[400] = createStatisticBar,
							[500] = createTopBarForClub
						}
-----------------------------------------------------------------------------

function DashBoardLayer:onEnter()
end

function DashBoardLayer:onExit()
	_view = nil
end


function DashBoardLayer:initData()
	self._title = "我的联盟"

	self.selectIndex = 0
	--tabBar 
	self.tabBars = {}
	--tabBar对应的内容
	self.contents = {}
	--tobar
	self.titleBar = {}
end

function DashBoardLayer:initUI()
	local bg =display.newLayer(cc.c3b(0,0,0), display.width, display.height):addTo(self)
	bg._isSwallowImg = true
	TouchBack.registerImg(bg)

	-- 初始化tabbar按钮
	local from = UnionCtrol.getVisitFrom()
	local textAndTag ,textImgs, classArray, topBar = nil, nil, nil, nil
	if from == UnionCtrol.mine_union then 
		 textAndTag = {"联盟",  100,  "牌局", 200, "战绩", 300, "统计", 400}
	 	 textImgs = {ResLib.TAB_UNION_BTN_S, ResLib.TAB_UNION_BTN_U, ResLib.TAB_GAME_BTN_S, ResLib.TAB_GAME_BTN_U, ResLib.TAB_RECORD_BTN_S, ResLib.TAB_RECORD_BTN_U, ResLib.TAB_TOTAL_BTN_S, ResLib.TAB_TOTAL_BTN_U}
		 classArray = {
					[1] = require("union.UnionDetailLayer"),
					[2] = require("union.UnionGameLayer"),
					[3] = require("union.UnionGRecordLayer"),
					[4] =  require("union.UnionStatisticsLayer")
				  }
	else 
		textAndTag = {"联盟",  100,  "信息", 500, "战绩", 300, "统计", 400}
		textImgs = {ResLib.TAB_UNION_BTN_S, ResLib.TAB_UNION_BTN_U, ResLib.TAB_MSG_BTN_S, ResLib.TAB_MSG_BTN_U, ResLib.TAB_RECORD_BTN_S, ResLib.TAB_RECORD_BTN_U, ResLib.TAB_TOTAL_BTN_S, ResLib.TAB_TOTAL_BTN_U}
		classArray = {
						[1] = require("union.UnionDetailLayer"),
						[2] = require("union.UnionClubAuthEdit"),
						[3] = require("union.UnionGRecordLayer"),
						[4] =  require("union.UnionStatisticsLayer")
					  }
	
	end
	
	local sizeBtn = cc.size(186, 90)
	local len = #textAndTag / 2
	for i = 1, len do
		local tmpx = (i - 1)* (sizeBtn.width + 1)
		-- local label1 = cc.Label:createWithSystemFont(textAndTag[i*2-1], "Marker Felt", 36)
		local btn = UIUtil.controlBtn(textImgs[i*2], textImgs[i*2-1], textImgs[i*2-1], nil, cc.p(tmpx, _topy), sizeBtn,handler(self,self.clickTabBarHandler), self)
		btn:setTag(textAndTag[i*2])
		btn.tabIndex = i
		btn:setAnchorPoint(cc.p(0, 1))
		btn:setLocalZOrder(20)
			
		local createHandle = topBarHandleList[textAndTag[i*2]]
		local topbar = createHandle(self, i)
		topbar:setLocalZOrder(100)
		--创建对应的content
		local content = cc.LayerColor:create()
		content:setContentSize(cc.size(display.width, _topy - 90))
		content.contentIndex = i
		self:addChild(content, 9)
		if self.selectIndex ~= i then 
			content:setPositionX(10000)
		end
		local classNode = classArray[i]
		local subLayer = classNode:create()
		subLayer:ignoreAnchorPointForPosition(false)
		subLayer:setAnchorPoint(cc.p(0, 1))
		subLayer:setPosition(cc.p(0,_topy-90))
		subLayer:setTag(1)
		content:addChild(subLayer)

		self.tabBars[#self.tabBars + 1] = btn
		self.contents[#self.contents + 1] = content
		self.titleBar[#self.titleBar + 1] = topbar
	end

	self:switchTab(1)
end

--切换显示
function DashBoardLayer:switchTab(index)
	if self.tabBars == nil or #self.tabBars <= 0  then 
		print("错误")
		return
	end

	if index <= 0 or index > #self.tabBars then 
		print("边界错误")
		return 
	end

	if self.selectIndex == index then 
		print("重复点击"..self.selectIndex)
		local v = self.tabBars[self.selectIndex]
		v:setSelected(true)
		v:setHighlighted(true)
		local content = self.contents[self.selectIndex]:getChildByTag(1)
		if content.refreshContent then  
			content:refreshContent()
		end
		return
	end

	local oldIndex = self.selectIndex
	self.selectIndex = index
	
	for i,v in ipairs(self.tabBars) do
		print(i)
		local content = self.contents[i]
		local topbar = self.titleBar[i]
		local isSelect = (index == i)
		v:setSelected(isSelect)
		-- v:setEnabled(not isSelect)
		v:setHighlighted(isSelect)
		content:setVisible(isSelect)

		if isSelect then  --放置事件触摸问题
			content:setLocalZOrder(10)
			content:setPosition(0, 0)
			topbar:setPositionX(0)
		else 
			content:setLocalZOrder(9)
			content:setPosition(10000, 0)
			topbar:setPositionX(10000)
			content:pause()
		end

		local container = content:getChildByTag(1)
		if i == oldIndex then 
			container:hideContent() --告知隐藏
		elseif i == index then 
			container:showContent() --告知显示
		end
	end
end
------------------------------------
--监听函数
------------------------------------
function DashBoardLayer:clickTabBarHandler( sender, event)
	--点击tabbar
	self:switchTab(sender.tabIndex)
end

----------------------------------
function DashBoardLayer.show(parent, params)
	parent = parent or cc.Director:getInstance():getRunningScene()
	local from = params.from
	local function showFunc(data)
		UnionCtrol.setVisitFrom(from)
		print("进来联盟啦"..from)
		local unionDashView = DashBoardLayer.new()
		parent:addChild(unionDashView,StringUtils.getMaxZOrder(parent))
		_view = unionDashView
	end

	if from == UnionCtrol.mine_union then 
		showFunc()
	elseif from == UnionCtrol.club_union then 
		local clubId, unionId = params.clubId, params.unionId
		if not clubId  or not unionId then
			 print("必须有俱乐部ID") 
			 return 
		 end
		UnionCtrol.requestDetailUnionForClub(clubId , unionId, showFunc)
	end
end


return DashBoardLayer
