--
-- Author: Taylor
-- Date: 2017-05-11 10:02:31
-- 查看授权用户的界面

local LookAuthorizeUserLayer = class("LookAuthorizeUserLayer", require("result.LookStatisticsLayer"))

local function createSmallFlag(text,number, resPath, color)
	local imageViewA = ccui.ImageView:create()
	imageViewA:loadTexture(resPath)
    imageViewA:setAnchorPoint(cc.p(0,1))
    imageViewA:setColor(color or cc.c3b(26,255,150))
    if number and number > 0 then 
      local node = cc.Node:create()
      local left_label = UIUtil.addLabelArial(text, 24, cc.p(0,0), cc.p(0, 0), node, cc.c3b(25,25,25))
      local leftSize = left_label:getContentSize()
      local right_label = UIUtil.addLabelArial(number,14, cc.p(leftSize.width,0), cc.p(0, 0), node,cc.c3b(25,25,25))
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

local function sortHandler(mod, data)
	do return end
	table.sort(data, function(a, b) 
			return a['spends'] > b['spends']
		end)
end

function LookAuthorizeUserLayer.show(parent , data)
	data.title = "授权通过"
	local lookAthUser = LookAuthorizeUserLayer.new(data)
	lookAthUser:setPosition(cc.p(0,0))
	if parent then 
		parent:addChild(lookAthUser)
	else
		local runScene = cc.Director:getInstance():getRunningScene()
		runScene:addChild(lookAthUser,StringUtils.getMaxZOrder(runScene))
	end
end

function LookAuthorizeUserLayer:ctor(params)
	-- dump(params,"审核用数据")
	self.selectClubLabel = nil
	-- self._title = "授权通过"
	self.modelData = params.modelData or {} --cell数据 self.itemData 俱乐部数据   self.pData 上一页的数据
	self.totalData = params.totalData or {} --中部合计的数据
	LookAuthorizeUserLayer.super.ctor(self,params)

	self:initData()
end

function LookAuthorizeUserLayer:initData()
	self.curPage = 1
	self.managerId = nil
	-- self.manageId = 0-- 0默认选中全部 如果管理员 > 1时
	local items = self.itemData['u_nos']
	local number = #items
	for i = 1, number do 
		self.modelData[items[i]] = {}
	end

	if #items > 1 then
		table.insert(items, 1, "全部")
	end
	self.itemData = items
	
	self:updateManagerIdAndPage(1)
	---请求第一页数据
	self:sendSearchAuthorize()
end

function LookAuthorizeUserLayer:initMidView()
	self._basey = self._topy - 216
	--按钮
	local imgs = {"common/m_glytxt.png","common/m_glytxt.png","common/m_glytxt.png"}
	local button = UIUtil.addUIButton(imgs, cc.p(display.cx, self._topy-94), self, handler(self,self.searchClubHandler))
	button:setAnchorPoint(.5,1)
	self.selectClubLabel = UIUtil.addLabelArial("皇家妈的", 32, 
			cc.p(display.cx-button:getContentSize().width/2+20, button:getPositionY()-button:getContentSize().height/2), cc.p(0,0.5), self, cc.c3b(255,255,255))
	
	LookAuthorizeUserLayer.super.initMidView(self)
end

function LookAuthorizeUserLayer:updateMidText()
	-- self.selectClubLabel:setString("")
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
	--set middle view
	local function addTips(count,size,space)
		for i = 1, count do 
			UIUtil.addLabelArial("(根据选择的管理员ID随之变化)", 22, cc.p(display.width - 40,0-(size.height+space)*(i-1)),cc.p(1,1),self.midNode, cc.c3b(170,170,170))
		end
	end
	local tempY = self.midNode:getPositionY() - 25
	local tsize,offsetx = nil,0
	if isMtt then 
		local access_add_num = self.totalData['access_times_a']
		tsize = UIUtil.addLabelArial("授权总人数:"..tostring(self.totalData['p_num'] or 0), 32, cc.p(0,0),cc.p(0,1),self.midNode):getContentSize()
		offsetx = UIUtil.addLabelArial("授权总人次:"..tostring(self.totalData['access_times_r'] or 0), 32, cc.p(0,0-tsize.height-22),cc.p(0,1),self.midNode):getContentSize().width
		UIUtil.addLabelArial("总报名费:"..tostring(self.totalData['spends_num'] or 0), 32, cc.p(0,0-(tsize.height+22)*2),cc.p(0,1),self.midNode)
		if access_add_num and access_add_num > 0 then 
			offsetx = offsetx + UIUtil.addLabelArial("+"..access_add_num,32,cc.p(offsetx+2,0-tsize.height-22),cc.p(0,1),self.midNode):getContentSize().width
			UIUtil.addPosSprite("common/card_mtt_bind_addbuy_icon.png",cc.p(offsetx+8,0-tsize.height-22), self.midNode,cc.p(0,1))
		end 
		tempY = self.midNode:getPositionY() - tsize.height * 3 - 22*2 - 25
		addTips(3,tsize,22)
	elseif isSng then 
		tsize = UIUtil.addLabelArial("人数:"..tostring(self.totalData['p_num'] or 0), 32, cc.p(0,0),cc.p(0,1),self.midNode):getContentSize()
		UIUtil.addLabelArial("总报名费:"..tostring(self.totalData['spends_num'] or 0), 32, cc.p(0,0-tsize.height-22),cc.p(0,1),self.midNode)
		tempY = self.midNode:getPositionY() - tsize.height * 2 - 22*1- 25
		addTips(2,tsize,22)
	elseif isStandard then 
		tsize = UIUtil.addLabelArial("人数:"..tostring(self.totalData['p_num'] or 0), 32, cc.p(0,0),cc.p(0,1),self.midNode):getContentSize()
		UIUtil.addLabelArial("总带入量:"..tostring(self.totalData['spends_num'] or 0), 32, cc.p(0,0-tsize.height-22),cc.p(0,1),self.midNode)
		tempY = self.midNode:getPositionY() - tsize.height * 2 - 22*1- 25
		addTips(2,tsize,22)
	end

	--变更Tableview的坐标 宽高
	local offsety = tempY - self.tableViewPosY
	self:setTableOffsetY(offsety)
end


function LookAuthorizeUserLayer:refreshData()
	--重写refreshData方法
	--组织加载时刷新tableview
end 

function LookAuthorizeUserLayer:onExit()
	self.modelData = nil
	self.totalData = nil
	self.pData = nil
	self.itemData = nil
end
--确定选中
function LookAuthorizeUserLayer:searchClubHandler(sender, eType)
	if eType == ccui.TouchEventType.ended then 
		   local confirmFunc = function(index)

		   	    self:updateManagerIdAndPage(index)
		   		self:sendSearchAuthorize()
		   end
		   local obj = {
                 ['items'] = self.itemData, 
                 ['confirmFuc'] = confirmFunc
                }
 		   require("ui.UITextPicker").show(self, obj)
	end
end
------------------------------------------------------------------------------
function LookAuthorizeUserLayer:updateCell(cell, data, index)
	local ctlsrc = self.pData['ctlsrc'] --1.审核 2.统计 3.保险
	local mod = self.pData['mod']
	local isInsure = self.pData['isInsure']
	local _, posArr = self.getTableTexts( mod, isInsure, ctlsrc)
	local tRoot = cell:getChildByName("Panel_root")
	local namePanel = ccui.Helper:seekWidgetByName(tRoot, "Text_name")
	local pzPanel = ccui.Helper:seekWidgetByName(tRoot, "Text_pz")
	local tgrnoPanel = ccui.Helper:seekWidgetByName(tRoot, "Text_tgrno")
	local jfpPanel = ccui.Helper:seekWidgetByName(tRoot, "Text_jfp")
	tgrnoPanel:setVisible(false)

	namePanel:setString(data['username'])
	namePanel:setPositionX(posArr[1])
	pzPanel:setString(data['u_no'])
	pzPanel:setPositionX(posArr[2])
	jfpPanel:setString(tostring(data['spends']))
	jfpPanel:setPositionX(posArr[3])

	if ResultCtrol.isMtt(mod) then 
		local imgNode = tRoot:getChildByName('r_a_num')
		if imgNode then 
			imgNode:removeFromParent()
		end
		imgNode = cc.Node:create()
		imgNode:setName('r_a_num')
		tRoot:addChild(imgNode)
		local ptx,pty= namePanel:getPosition()
		local size = namePanel:getContentSize() 
		local tempPx,tempPy,offsetx = ptx+size.width/2+8, pty,0
		imgNode:setPosition(cc.p(tempPx, tempPy))
		local r_num, a_num = tonumber(data['r_num']), tonumber(data['a_num'])
		if a_num and a_num > 0 then 
			offsetx =UIUtil.addPosSprite("common/card_mtt_bind_addbuy_icon.png", cc.p(0,0),imgNode,cc.p(0, .5)):getContentSize().width
		end
		if r_num and r_num > 0 then 
			local image = createSmallFlag("R",r_num,"result/r_s9.png",cc.c3b(252,215,54))
			imgNode:addChild(image)
			image:setAnchorPoint(cc.p(0, .5))
			image:setPosition(cc.p(offsetx+6, 0))
		end
	end
end

function LookAuthorizeUserLayer:tableCellAtIndex(table, idx)
    local userData = self:getCellData(idx+1)
    local cell = table:dequeueCell()
  	if cell == nil then 
  		cell = self:generateCell(userData, idx, cc.size(display.width, 90))
  	else 
  		self:updateCell(cell, userData, idx)
  	end
    return cell
end

function LookAuthorizeUserLayer:numberOfCellsInTableView(table)
	if self.managerId == nil then 
		return 0
	end

	local len = 0
	if self.managerId == 0 then 
		--1 = 全部， 从2为管理员的数据
		for i = 2, #self.itemData do
			local items = self.modelData[self.itemData[i]]
			len = len + #items
		end
	else  
		local items = self.modelData[self.managerId]
		len = len + #items
	end
	print(len)
	return len
end

------------------------------------------------------------------------------
------------------------------------------------------------------------------
--数据刷新
------------------------------------------------------------------------------
function LookAuthorizeUserLayer:loadMoreData()
	local tmpPage = self.curPage + 1
	-- tmpPage = 0
	self:sendSearchAuthorize(nil, tmpPage, true) 
end
function LookAuthorizeUserLayer:getCellData(idx)
	local number = #self.itemData
	local data = nil
	if number > 1 and self.managerId == 0 then --选择全部
		print("选择全部"..idx)
		local index = idx
		for i = 2, number do 
			local models = self.modelData[self.itemData[i]]
			if (index > 0 and index <= #models) then 
				data = models[index]
				break
			else 
				index = index - #models
			end
		end
	else 
		local items = self.modelData[self.managerId]
		data = items[idx]
	end
	-- dump(data, "拿到的数据对不对")
	return data
end
function LookAuthorizeUserLayer:updateManagerIdAndPage(index)
	local number = #self.itemData
	local tmpManagerId ,text= self.itemData[index], self.itemData[index]
	if index == 1 and number > 1 then 
		tmpManagerId = 0
	end

	if tmpManagerId == self.managerId then 
		do return end
	end

	if tmpManagerId == 0 then --如果全选中，重置所有
		for i = 2, number do 
			self.modelData[self.itemData[i]] = {}
		end
	else 	--重置对应的
		self.modelData[tmpManagerId] = {}
	end

	self.selectClubLabel:setString(tostring(text))
	--维护页码
	self.managerId = tmpManagerId
	self.curPage = 1
end
function LookAuthorizeUserLayer:sendSearchAuthorize( u_no, page, noWait)
	-- print("发送: u_no:",tostring(u_no), self.managerId," page:"..tostring(page), self.curPage)
	local tid = self.pData['pid']
	local game_mod = self.pData['game_mod']
	local club_id = self.pData['selectClubId']
	local src = self.pData['ctlsrc']

	ResultCtrol.sendSearchAuthorizeDetails(tid, game_mod, club_id, src, u_no or self.managerId, page or self.curPage, handler(self,self.refreshDataHandler), noWait)
end

function LookAuthorizeUserLayer:refreshDataHandler(data)
	--更新CELL 并且更新loading图标的位置
	local function refreshUI()
		self.isLoading = false 
		self.tablev:reloadData()
		--TODO:tanhaiting更新actionLDNode坐标，这里待研究，感觉有点问题
		local baseOffsety = self.tablev:getViewSize().height - self.tablev:getContentSize().height
		if baseOffsety >= 0 then 
			baseOffsety = 0 - baseOffsety - 70
		else 
			baseOffsety = -70
		end
		self.actionLDNode:setPosition(cc.p(display.cx,baseOffsety))
	end
	if not data or #data.list <= 0 then 
		-- print("数量",self:numberOfCellsInTableView(self.tablev))
		--TODO:无奈之举-如果数据为0的时候，移除掉
		if self:numberOfCellsInTableView(self.tablev) == 0 then 
			self:scheduleUpdate(handler(self, self.update))
		end
		DZAction.delateTime(self, 0.5, refreshUI)
		do return end
	end
	self:unscheduleUpdate()

	local mod = self.pData['mod']
	sortHandler(mod, data.list)
	local isMtt = ResultCtrol.isMtt(mod)
	local isSng = ResultCtrol.isSNG(mod)
	local isStandard = ResultCtrol.isStandard(mod)
	self.totalData = {}
	if isMtt then 
		self.totalData['p_num'] = data['p_num']
		self.totalData['access_times_r'] = data['access_times_r']
		self.totalData['spends_num'] = data['spends_num']
		self.totalData['access_times_a'] = data['access_times_a']
	elseif isSng then 
		self.totalData['p_num'] = data['p_num']
		self.totalData['spends_num'] = data['spends_num']
	elseif isStandard then 
		self.totalData['p_num'] = data['p_num']
		self.totalData['spends_num'] = data['spends_num']
	end

	local list = data.list
	for i = 1, #list do -- 找到对应的管理员，然后存储到相应的table
		local item = list[i]
		local items = self.modelData[item['u_no']]
		if items == nil then
			items = {}
		end
		items[#items + 1] = item
	end
	
	local time = 0.5
	if #list > 0 then 
		if self.curPage == 1 or self.curPage == 0 then 
			time = 0.1
		end
		self.curPage = self.curPage + 1
	end
	-- dump(self.modelData, "合并玩的数据")
	DZAction.delateTime(self, time, function() 
				self:updateMidText()
				refreshUI()
		end)
end

return LookAuthorizeUserLayer
