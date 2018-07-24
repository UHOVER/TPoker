--
-- Author: Taylor
-- Date: 2017-05-11 10:06:33
-- 查看统计界面

--重构增购标记
local function createSmallFlag(text,number, resPath, color)
	local imageViewA = ccui.ImageView:create()
	imageViewA:loadTexture(resPath)
    imageViewA:setAnchorPoint(cc.p(0,1))
    imageViewA:setColor(color or cc.c3b(26,255,150))
    if number and number > 0 then 
      local node = cc.Node:create()
      local left_label = UIUtil.addLabelArial(text, 30, cc.p(0,0), cc.p(0, 0), node, cc.c3b(25,25,25))
      local leftSize = left_label:getContentSize()
      local right_label = UIUtil.addLabelArial(number,10, cc.p(leftSize.width,0), cc.p(0, 0), node,cc.c3b(25,25,25))
      local rightSize = right_label:getContentSize()
      node:setContentSize(cc.size(leftSize.width+rightSize.width, leftSize.height))
      node:setAnchorPoint(cc.p(.5,.5))
      node:setPosition(cc.p(imageViewA:getContentSize().width/2, imageViewA:getContentSize().height/2))
      imageViewA:addChild(node)
      local tmpW = node:getContentSize().width
      if tmpW > imageViewA:getContentSize().width then 
      	node:setScale(imageViewA:getContentSize().width/tmpW-0.1)
      end
    else 
      UIUtil.addLabelArial(text, 30, cc.p(imageViewA:getContentSize().width/2, imageViewA:getContentSize().height/2), cc.p(0.5, 0.5), imageViewA, cc.c3b(25,25,25))
    end
    return imageViewA
end

local function setContextAndPos(panel, posx,text,color)
	color = color or cc.c3b(255,255,255)
	panel:setString(text)
	panel:setPositionX(posx)
	panel:setTextColor(color)
end

--排序
local function sortHandler(mod, data)
	-- data = data or {}
	do return end
	if not data then 
		return 
	end 
	dump(data, "排序前")
	local isMtt, isSng, isStandard = ResultCtrol.isMtt(mod), ResultCtrol.isSNG(mod), ResultCtrol.isStandard(mod)
	if isMtt or isSng then 
		table.sort(data, function(a, b) 
				return a['user_rank'] < b['user_rank']
			end)
	elseif isStandard then 
		table.sort(data, function(a, b)
				return a['bet_num'] > b['bet_num']
			end)
	end
	dump(data, "排序后")
	return data
end


local ViewBase = require("ui.ViewBase")
local LookStatisticsLayer = class("LookStatisticsLayer", ViewBase)

local _topx = 0 --topbar posx
local _topy = 0 --topbar posy

local stateHandler = nil
local LOAD_IDEL = 0
local LOAD_PREPARE = 1
local LOAD_START = 2
local LOAD_ING = 3
local LOAD_EXIT = 4
local LOAD_END = 5



function LookStatisticsLayer.show(parent, params)
	params.title = "统计"
	params['itemsData'] = checktable(params['itemsData'])
	params['itemsData']['list'] = checktable(params['itemsData']['list'])
	sortHandler(params['pData']['mod'] , params['itemsData']['list'])
	local lookStatisticsLayer = LookStatisticsLayer.new(params)
	if parent then 
		parent:addChild(lookStatisticsLayer)
	else
		local runScene= cc.Director:getInstance():getRunningScene()
		runScene:addChild(lookStatisticsLayer,StringUtils.getMaxZOrder(runScene))
	end
	lookStatisticsLayer:setPosition(cc.p(0,0))
end

function LookStatisticsLayer.getTitle(ctlsrc)
end

function LookStatisticsLayer:ctor(params)
	self.itemData = params['itemsData'] or {}
	self.pData  = params['pData'] or {}

	dump(self.itemData, "描述")
	dump(self.pData, "旧数据")

	self.clubName = self.pData['clubname'] or "俱乐部的名字" --none 俱乐部名字
	self.tablev = nil    --
	self.tableViewPosY=0 --中间区域的最低坐标
	self.curPage = 1
	self._title = params and params.title
	
	self:init()
	self._isSwallowImg = true 
	TouchBack.registerImg(self)
end

function LookStatisticsLayer:init()
	local function  backHandler(evt)
		self:removeFromParent()
	end
	--bg
	UIUtil.addPosSprite(ResLib.MTT_BG, cc.p(0,0),self,cc.p(0,0))
	--tabBar
	local tabBar = UIUtil.addTopBar({["backFunc"]=backHandler,title = self._title, parent = self})
	tabBar:setLocalZOrder(100)
	--clubName
	local topSize = tabBar:getContentSize()
	_topx,_topy,self._topy = tabBar:getPositionX(),display.height-topSize.height,display.height-topSize.height
	local clubName = UIUtil.addLabelArial(self.clubName,30,cc.p(display.cx, _topy-36),cc.p(.5,1),self)
	local point1 = UIUtil.addPosSprite("common/icon_point.png", cc.p(clubName:getPositionX()-clubName:getContentSize().width/2-10, clubName:getPositionY()-clubName:getContentSize().height/2), self, cc.p(1, 0.5))
	local line1 = UIUtil.addPosSprite("common/icon_line.png", cc.p(point1:getPositionX()-point1:getContentSize().width-10, clubName:getPositionY()-clubName:getContentSize().height/2), self, cc.p(1, 0.5))
	local scaleX = (point1:getPositionX()-point1:getContentSize().width-10-10)/line1:getContentSize().width
	line1:setScaleX(scaleX)
	line1:setScaleY(0.4)
	local point2 = UIUtil.addPosSprite("common/icon_point.png", cc.p(clubName:getPositionX()+clubName:getContentSize().width/2+10, clubName:getPositionY()-clubName:getContentSize().height/2), self, cc.p(1, 0.5))
	point2:setRotation(180)
	local line2 = UIUtil.addPosSprite("common/icon_line.png", cc.p(point2:getPositionX()+point1:getContentSize().width+10, clubName:getPositionY()-clubName:getContentSize().height/2), self, cc.p(0, 0.5))
	line2:setScaleX(scaleX)
	line2:setScaleY(0.4)
	self._basey = _topy - 95
	self:initMidView()
	self:initTable()
	-- self:refreshData()
end
--------------------------------------------------------------------
--中间部分的显示
------------------------------------------------------------------------

function LookStatisticsLayer:initMidView()
	local midNode = cc.Node:create()
	midNode:setPosition(cc.p(20, self._basey))
	self:addChild(midNode)
	self.midNode = midNode
	self:updateMidText()
end
--mtt合计
local function updateMttTotal(node, is_access,itemData)
	local sizeH = nil
	dump(itemData, "itemData")
	local people = itemData['p_num'] or 0 
	local people_count = itemData['access_times_r'] or 0
	local access_add_num = itemData['access_times_a'] or 0
	local people_baoming = "总报名费:"..(itemData['spends_num'] or 0)
	local award, color  = StringUtils.getSymbolNumColor(itemData['total_award'] or 0)
	award = '总奖励:'..award
	if is_access then  
		people = "总人数:"..people
		people_count = "总人次:"..people_count
	else
		people = "总人数:"..people
		people_count = "总人次:"..people_count
	end
	local label = UIUtil.addLabelArial(people, 32 , cc.p(0, 0), cc.p(0, 1), node)
	sizeH = label:getContentSize().height
	local offsetx = UIUtil.addLabelArial(people_count, 32, cc.p(0,0-sizeH-22),cc.p(0,1),node):getContentSize().width
	UIUtil.addLabelArial(people_baoming,32, cc.p(0,0-(sizeH+22)*2),cc.p(0,1),node)
	UIUtil.addLabelArial(award,32, cc.p(0,0-(sizeH+22)*3),cc.p(0,1),node)

	if access_add_num and access_add_num > 0 then
		offsetx = offsetx + UIUtil.addLabelArial("+"..access_add_num,32,cc.p(offsetx+2,0-sizeH-22),cc.p(0,1),node):getContentSize().width
		UIUtil.addPosSprite("common/card_mtt_bind_addbuy_icon.png",cc.p(offsetx+8,0-sizeH-22), node,cc.p(0,1)) 
	end
	return node:getPositionY() - sizeH*4 - 22*3 - 25
end

--sng合计
local function updateSngTotal(node,itemData)
	local sizeH = nil
	local label = UIUtil.addLabelArial("人数:"..(itemData['p_num'] or 0), 32, cc.p(0,0), cc.p(0,1), node)
	sizeH = label:getContentSize().height
	UIUtil.addLabelArial("总报名费:"..(itemData['spends_num'] or 0), 32, cc.p(0,0-sizeH-22),cc.p(0,1),node)
	
	UIUtil.addLabelArial("总奖励:"..StringUtils.getSymbolNumColor(itemData['total_buyin']),32, cc.p(0,0-(sizeH+22)*2),cc.p(0,1),node)
	return node:getPositionY() - sizeH*3 - 22*2 - 25
end

--标准合计
local function updateStandardTotal(node, isInsure, itemData)
	-- print("标准牌局----")
	local sizeH = nil
	local label = UIUtil.addLabelArial("人数:"..(itemData['p_num'] or 0), 32, cc.p(0,0), cc.p(0,1), node)
	sizeH = label:getContentSize().height
	UIUtil.addLabelArial("带入量:"..(itemData['spends_num'] or 0), 32, cc.p(0,0-sizeH-22), cc.p(0,1),node)
	local total_buyin,color = StringUtils.getSymbolNumColor(itemData['total_buyin'])
	UIUtil.addLabelArial("记分牌:"..total_buyin,32, cc.p(0,0-(sizeH+22)*2), cc.p(0,1),node)
	
	if isInsure > 0 then
		local insuranceNum,color = StringUtils.getSymbolNumColor(itemData['insurance_num'] or 0)
		if insuranceNum then 
			UIUtil.addLabelArial("保险总账:"..insuranceNum,32, cc.p(0,0-(sizeH+22)*3), cc.p(0,1),node) 
		end
		return node:getPositionY() - sizeH*4 - 22*3 - 25
	else
		return node:getPositionY() - sizeH*3 - 22*2 - 25
	end
end

function LookStatisticsLayer:updateMidText()
	local ctlsrc = self.pData['ctlsrc'] 
	local is_access = self.pData['isAccess']
	local mod = self.pData['mod']
	local pid = self.pData['pid']
	local isInsure = self.pData['isInsure']
	local createWay = self.pData['createWay']

	local isMtt = ResultCtrol.isMtt(mod)
	local isSng = ResultCtrol.isSNG(mod)
	local isStandard = ResultCtrol.isStandard(mod)
	self.midNode:removeAllChildren() 
	
	if isMtt then 
		self.tableViewPosY =updateMttTotal(self.midNode, is_access, self.itemData)
	elseif isSng then 
		self.tableViewPosY =updateSngTotal(self.midNode, self.itemData)
	elseif isStandard then 
		self.tableViewPosY =updateStandardTotal(self.midNode, isInsure, self.itemData)
	end
end

------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
--table 部分
------------------------------------------------------------------------------------------------

--获得Table的文字
function LookStatisticsLayer.getTableTexts(mod, isInsure, ctrlsrc)
	local isMtt,isSng,isStandard = ResultCtrol.isMtt(mod), ResultCtrol.isSNG(mod), ResultCtrol.isStandard(mod)
	local textArr, posArr= nil,nil
	
	if ctrlsrc ==  1 then 
		if isMtt then 
			textArr, posArr = {"名次", "玩家", "报名费", "奖励"}, {55, 228, 464, 667}
		elseif isSng then 
			textArr,posArr = {"名次", "玩家", "报名费", "奖励"}, {55, 228, 464, 667}
		elseif isStandard then 
			if isInsure > 0 then 
				textArr,posArr = {"玩家", "带入量", "保险", "记分牌"}, {101, 314, 488, 664}
			else
				textArr,posArr = {"玩家","带入量","记分牌"}, {101, display.cx, 636}
			end
		end
	else 
		if isMtt or isSng then 
			textArr, posArr = {"玩家", "管理员ID", "报名费"}, {101, display.cx, 636}
		else 
			textArr, posArr = {"玩家", "管理员ID", "带入量"}, {101, display.cx, 636}
		end
	end
	return textArr,posArr
end


function LookStatisticsLayer:initTable()
	local ctlsrc = self.pData['ctlsrc'] --1.统计 2.审核 3.保险
	local mod = self.pData['mod']
	local isInsure = self.pData['isInsure']

	local sectionHeaders, posArr = self.getTableTexts( mod, isInsure, ctlsrc)
	if #posArr ~= #sectionHeaders then 
		-- print("table header不存在","curPosNUm="..#posArr,"  sectionNum="..#sectionHeaders )
		return 
	end
	--table标题头
	-- print(">>>>tableViewPosY",self.tableViewPosY)
	local bSize = cc.size(display.width, self.tableViewPosY)
	local tableNode = cc.LayerColor:create(cc.c4b(0,0,255,0))	
	tableNode:setPosition(cc.p(0,0))
	tableNode:setContentSize(bSize)
	self:addChild(tableNode)

	local titleBg = UIUtil.addPosSprite("common/s_btd.png", cc.p(display.width/2, bSize.height), tableNode, cc.p(0.5,1))
	titleBg:setName("table_titleBg")
	for i = 1, #sectionHeaders do
		UIUtil.addLabelBold(sectionHeaders[i], 32, cc.p(posArr[i], titleBg:getContentSize().height/2), cc.p(.5,.5), titleBg)
	end
	----
	--table 数据
	----
	self.isLoading = false
	self.loadState = LOAD_IDEL
    local tableView = cc.TableView:create(cc.size(display.width,bSize.height-titleBg:getContentSize().height))
   	tableView:initWithViewSize(cc.size(display.width,bSize.height-titleBg:getContentSize().height))
    -- tableView:setContentSize(cc.size(display.width,bSize.height-titleBg:getContentSize().height))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setPosition(cc.p(0, 0))
    tableView:setDelegate()
    tableNode:addChild(tableView)
    --registerScriptHandler functions must be before the reloadData funtion
    tableView:registerScriptHandler(handler(self,self.numberOfCellsInTableView),cc.NUMBER_OF_CELLS_IN_TABLEVIEW)  
    tableView:registerScriptHandler(handler(self,self.scrollViewDidScroll),cc.SCROLLVIEW_SCRIPT_SCROLL)
    tableView:registerScriptHandler(handler(self,self.scrollViewDidZoom),cc.SCROLLVIEW_SCRIPT_ZOOM)
    tableView:registerScriptHandler(handler(self,self.tableCellTouched),cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(handler(self,self.cellSizeForTable),cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(handler(self,self.tableCellAtIndex),cc.TABLECELL_SIZE_AT_INDEX)
    self.tablev = tableView
    -- print("tableView.w=",self.tablev:getContentSize().width, "tableView.h",self.tablev:getContentSize().height)
    self:refreshData()
    self:initFooter()
end

function LookStatisticsLayer:refreshData()
	if self.tablev then 
		self.tablev:reloadData()
	end
end 
--设置table容器的y轴偏移
function LookStatisticsLayer:setTableOffsetY(offsety)
	self.tableViewPosY = self.tableViewPosY + offsety
	-- print("offsety"..offsety,"self.tableViewPosY", self.tableViewPosY, "tableH",tostring(self.tablev))
	-- if self.tablev then print("tableH:",self.tablev:getContentSize().height) end
	if not self.tablev then 
		do return end
	end
	local tableNode = self.tablev:getParent()
	local tableTitle = tableNode:getChildByName("table_titleBg")
	local tableH = self.tablev:getContentSize().height + offsety
	local nodeH = self.tableViewPosY
	tableNode:setContentSize(cc.size(display.width, nodeH))
	tableNode:setPosition(cc.p(0, 0))
	tableTitle:setPosition(cc.p(display.width/2, nodeH))
	self.tablev:setContentSize(cc.size(display.width, tableH))
end

function LookStatisticsLayer:scrollViewDidScroll(view)
	print('self.loadState', self.loadState)
	if stateHandler then 
		local handler = stateHandler[self.loadState]
		handler(self,view)
	end

	-- dump(offset, "tab偏移")
	-- dump(container:getPosition(), "container偏移")
	-- dump(view:getContentSize(), "view contentSize")
	-- dump(container:getContentSize(),"container containerSize")
	-- dump(view:getViewSize(), "viewSize")
	-- dump(view:isDragging(), "是否拖拽")
	-- dump(view:isTouchMoved(), "是否移懂")
	-- dump(view:isBounceable(), "是否回弹")
	
	--[[local viewSize = view:getViewSize()
	local containerSize = container:getContentSize()
	local baseTablePosY = math.max(viewSize.height - containerSize.height, 0) --默认的偏移Y坐标
	local up_offsety = offset.y - baseTablePosY
	--触发加载
	if up_offsety >= 90 and not view:isDragging() and not view:isTouchMoved() then
		if not self.isLoading then
			self.isLoading = true
			self.tablev:setTouchEnabled(false)
			container:stopAllActions()
			self.actionLD:play('load', true)
		  	self:loadMoreData()
		  	 view:getContainer():runAction(cc.Sequence:create(
        		cc.DelayTime:create(1),
            	cc.MoveTo:create(0.1, cc.p(view:getContainer():getPositionX(), baseTablePosY + 70.0 + 35))
            	));
			print("开始刷新,暂停tableview的回弹效果")
		end
	end]]

	-- if self.isLoading then 
	-- 	if container:getPositionY() < baseTablePosY + 70.0 + 35 then 
	-- 		local offsetY =  baseTablePosY + 35 - container:getPositionY()
	-- 		container:setPositionY(offsetY + container:getPositionY())
	-- 	end
	-- end
end

function LookStatisticsLayer:update(dt)
	-- print("self.loadState",self.loadState)
 	if stateHandler then 
		local handler = stateHandler[self.loadState]
		handler(self,self.tablev)
	end
end

function LookStatisticsLayer:scrollViewDidZoom(view)
	-- print("scrollViewDidZoom")
end

function LookStatisticsLayer:tableCellTouched(table,cell)
	-- print("cell touched at index: " .. cell:getIdx())
end

function LookStatisticsLayer:cellSizeForTable(table,idx) 
	-- print("cellSizeForTable - idx",idx)
	return display.width, 90
end

function LookStatisticsLayer:cellUnHightLight(table,cell)
	print("cellUnHightLight")
end

function LookStatisticsLayer:generateCell(cellData, index, csize)
	-- print("创建cell"..index)
	local cell = cc.TableViewCell:new()
	local cs = cc.CSLoader:createNodeWithVisibleSize("scene/CheckManagerLayerCell.csb")
  	local tRoot = cs:getChildByName("Panel_root")
	tRoot:removeFromParent()
	cell:addChild(tRoot)
	tRoot:setName('Panel_root')
	tRoot:setTouchEnabled(false)
	self:updateCell(cell, cellData)
	return cell
end

--更新cell
function LookStatisticsLayer:updateCell(cell, data, index)
	-- print("旧的cell")
	local ctlsrc = self.pData['ctlsrc'] --1.审核 2.统计 3.保险
	local mod = self.pData['mod']
	local isInsure = self.pData['isInsure']
	-- dump(data,"cell:")
	local _, posArr = self.getTableTexts( mod, isInsure, ctlsrc)
	local isMtt, isSng, isStandard = ResultCtrol.isMtt(mod), ResultCtrol.isSNG(mod), ResultCtrol.isStandard(mod)

	local tRoot = cell:getChildByName("Panel_root")
	local namePanel = ccui.Helper:seekWidgetByName(tRoot, "Text_name")
	local pzPanel = ccui.Helper:seekWidgetByName(tRoot, "Text_pz")
	local tgrnoPanel = ccui.Helper:seekWidgetByName(tRoot, "Text_tgrno")
	local jfpPanel = ccui.Helper:seekWidgetByName(tRoot, "Text_jfp")
	if isMtt then  --MTT
		setContextAndPos(namePanel, posArr[2], data['user_name'],nil)
		setContextAndPos(tgrnoPanel, posArr[1],data['user_rank'],nil)
		setContextAndPos(pzPanel,posArr[3], data['spends'], nil)
		setContextAndPos(jfpPanel, posArr[4], StringUtils.getSymbolNumColor(data['bet_num'], cc.c3b(170,170,170)))
		--添加增购 重构标记
		local imgNode = tRoot:getChildByName('r_a_num')
		if imgNode then imgNode:removeFromParent() end
		imgNode = cc.Node:create()
		imgNode:setName('r_a_num')
		imgNode:setPosition(cc.p(namePanel:getPositionX()+namePanel:getContentSize().width/2+8, namePanel:getPositionY()))
		tRoot:addChild(imgNode)
		local r_num, a_num,offsetx = tonumber(data['r_num']), tonumber(data['a_num']),0
		if a_num and a_num > 0 then 
			offsetx =UIUtil.addPosSprite("common/card_mtt_bind_addbuy_icon.png", cc.p(0,0),imgNode,cc.p(0, .5)):getContentSize().width
		end
		if r_num and r_num > 0 then 
			local image = createSmallFlag("R",r_num,"result/r_s9.png",cc.c3b(252,215,54))
			imgNode:addChild(image)
			image:setAnchorPoint(cc.p(0, .5))
			image:setPosition(cc.p(offsetx+6, 0))
		end
	elseif isSng then --SNG
		setContextAndPos(namePanel, posArr[2], data['username'],nil)
		setContextAndPos(tgrnoPanel, posArr[1], data['user_rank'],nil)
		setContextAndPos(pzPanel,posArr[3], data['spends'],nil)
		setContextAndPos(jfpPanel, posArr[4], StringUtils.getSymbolNumColor(data['bet_num'], cc.c3b(170,170,170)))
	elseif isStandard then --标准
		if isInsure > 0 then 
			setContextAndPos(namePanel, posArr[1], data['username'],nil)
			setContextAndPos(tgrnoPanel,posArr[2], data['spends'],nil)
			setContextAndPos(pzPanel,posArr[3],StringUtils.getSymbolNumColor(data['insurance_pool']))
			setContextAndPos(jfpPanel,posArr[4], StringUtils.getSymbolNumColor(data['bet_num']))
		else 
			setContextAndPos(namePanel, posArr[1], data['username'],nil)
			setContextAndPos(tgrnoPanel, posArr[2], data['spends'],nil)
			setContextAndPos(jfpPanel, posArr[3], StringUtils.getSymbolNumColor(data['bet_num']))
			pzPanel:setVisible(false)
		end
	end
end

function LookStatisticsLayer:tableCellAtIndex(table, idx)
	local strValue = string.format("%d",idx)
	-- print("idx:"..idx)
    local clubUserData = self.itemData.list[idx + 1]
    local cell = table:dequeueCell()
  	if cell == nil then 
  		
  		cell = self:generateCell(clubUserData, idx, cc.size(display.width, 90))
  	else 
  		self:updateCell(cell, clubUserData, idx)
  	end
    return cell
end

function LookStatisticsLayer:numberOfCellsInTableView(table)
	return #self.itemData['list']
end

------------------------------------------------------------------------------------------------
--加载新数据
------------------------------------------------------------------------------------------------
local function processLoadingIDEL(self,view)
	local isDragging, isMove = view:isDragging(), view:isTouchMoved()
	if isDragging and isMove then 
		self.loadState = LOAD_PREPARE
	end
end
local function processLoadingPREPARE(self,view)
	-- print("--PREPARE")
	local isDragging, isMove = view:isDragging(), view:isTouchMoved()
	local originY = math.max(view:getViewSize().height - view:getContentSize().height,0)
	local offsetPt = view:getContentOffset()
	local up_offsety = offsetPt.y - originY
	if up_offsety > 120 and not isDragging and not isMove then 
		self.loadState = LOAD_START
	elseif  up_offsety < 30 and isDragging and isMove then 
		self.loadState = LOAD_IDEL
	end
end
local function processLoadingSTART(self,view)
	-- print("--START")
	-- view:getContainer():stopAllActions()
	if self.isLoading then 
		do return end
	end 
	view.OldHiehgt = view:getContainer():getContentSize().height
	local viewHeight = view:getViewSize().height
	local contentHeight = view:getContainer():getContentSize().height
	local curPosy = view:getContentOffset().y
	local waitPosy = 100
	if contentHeight < viewHeight then 
		waitPosy = viewHeight - contentHeight + 100
	end
	view:setTouchEnabled(false)
	self.isLoading = true
	self.loadState = LOAD_ING
	view:stopAnimatedContentOffset()
	local d = curPosy - waitPosy
	local k1,k2,k3 = 1, 0.01, 0.9
	local t = 0.5/(0.5 + d*k2 + d*d*k3)
	print("t=",t)
	-- local delayTime = cc.DelayTime:create(t)
	local moveTo = cc.MoveTo:create(t,cc.p(0, waitPosy))
	local callback = cc.CallFunc:create(function()
			view:stopAnimatedContentOffset()
		end)
	view:getContainer():runAction(cc.Sequence:create(moveTo, callback))
	-- view:setContentOffset(cc.p(0,100), false)
	self.actionLD:play('load',true)
	self:loadMoreData()
end
local function processLoadingING(self,view)
	if not self.isLoading then 
		print("当前位置:", view:getContentOffset().y)
		-- view:getContainer():setPositionY(view:getContentOffset().y - 70 - 30)
		self.loadState = LOAD_EXIT
		return
	end
	-- local originY = math.max(view:getViewSize().height - view:getContentSize().height,0)
	-- local offsetPt = view:getContentOffset()
	-- print("basePosy:",originY, offsetPt.y)
	-- print('viewSize:',view:getViewSize().height, "size:",view:getContentSize().height)
	-- if offsetPt.y < originY + 70 + 30  then 
	-- 	local offsety = originY + 70 + 30 - offsetPt.y
	-- 	print("停留的位置:", offsety, offsetPt.y + offsety, originY)
	-- 	-- view:getContainer():setPositionY(offsety + offsetPt.y)
	-- 	view:setContentOffset(cc.p(0,offsety + offsetPt.y+5), false)
	-- 	view:stopAnimatedContentOffset()
	-- 	self.actionLD:play('load',true)
	-- end
end
local function processLoadingExit(self,view)
	self.loadState = LOAD_END
	local offsetPt = view:getContentOffset()
	local basePosy = view.OldHiehgt - view:getContentSize().height
	local footPosy = -70
	--内容不足一页
	if view.OldHiehgt < view:getViewSize().height then 
		basePosy = view:getViewSize().height - view:getContainer():getContentSize().height
	end
	if view:getContentSize().height < view:getViewSize().height then
		local tempy = view:getViewSize().height - view:getContentSize().height  
		footPosy = 0 - tempy - 70
	end
	-- print(">>>>>>>>>>>>>>>>>>>>>>>>basePosy:",basePosy, footPosy)
	-- print('viewSize:',view:getViewSize().height, "size:",view:getContentSize().height, "view.OldHeight:", view.OldHiehgt)
	view:getContainer():setPositionY(basePosy)
	self.actionLDNode:setPositionY(footPosy)
	view:setTouchEnabled(true)
	self.actionLD:play('stop', true)
end
local function processLoadingEnd(self,view)
	self.loadState = LOAD_IDEL
end

stateHandler = {
	[0] = processLoadingIDEL,
	[1] = processLoadingPREPARE,
	[2] = processLoadingSTART,
	[3] = processLoadingING,
	[4] = processLoadingExit,
	[5] = processLoadingEnd
}
function LookStatisticsLayer:initFooter()
	local actionLDNode = cc.CSLoader:createNode("action/loadingAction.csb")
	local actionLD = cc.CSLoader:createTimeline("action/loadingAction.csb")
	local baseOffsety = self.tablev:getViewSize().height - self.tablev:getContentSize().height
	
	if baseOffsety >= 0 then 
		baseOffsety = 0 - baseOffsety - 70
	else 
		baseOffsety = -70
	end
	actionLDNode:setPosition(cc.p(display.cx,baseOffsety))
	actionLDNode:runAction(actionLD)
	if (self.tablev) then 
		self.tablev:addChild(actionLDNode)
		-- actionLD:play("load", true)
	end
	self.actionLDNode = actionLDNode
	self.actionLD = actionLD
end

function LookStatisticsLayer:loadMoreData()
	local tmpPage = self.curPage + 1
	-- tmpPage = 0
	local tid = self.pData['pid']
	local game_mod = self.pData['game_mod']
	local club_id = self.pData['selectClubId']
	local isInsure = self.pData['isInsure'] + 1
	ResultCtrol.sendRequireStatistic(tid, game_mod, club_id, isInsure, tmpPage, handler(self, self.refreshStatistics), true) 
end


function LookStatisticsLayer:refreshStatistics(data)
	local mod = self.pData['mod']
	local list = data['data']['list']
	sortHandler(mod, list)
	local originList = self.itemData['list']
	local len = #list
	for i = 1, 3 do 
		originList[#originList + 1] = list[i]
	end
	if len > 0 then 
		self.curPage = self.curPage + 1
	end
	-- 	
	local delayTime = cc.DelayTime:create(1)
	local callback = cc.CallFunc:create(function() 
		  -- print("刷新>>>>>>>>>>>>>>>>>")
		  self.isLoading = false
		  self:refreshData()
		end)
	self:runAction(cc.Sequence:create(delayTime, callback))
end



return LookStatisticsLayer