--
-- Author: Taylor
-- Date: 2017-05-10 09:48:16
--
-- 俱乐部列表， 呈现俱乐部  俱乐部统计，保险等等
--
local LIST_MODE_AUTHORIZE = 2--俱乐部审核
local LIST_MODE_STATISTICS = 1 --俱乐部统计
local LIST_MODE_INSURANCE = 3 --俱乐部保险
local LIST_MODE_NONE = 4
local ViewBase = require("ui.ViewBase")
local ClubsListView = class("ClubsListView",ViewBase )

local _tabBar = nil
local _mode = nil
local _data = nil



local function setMode(mode)
	if mode == nil then 
		_mode = LIST_MODE_NONE
	end
	_mode = mode
end

local function getTitle()
	if _mode == LIST_MODE_AUTHORIZE then 
		return '审核记录'
	elseif _mode == LIST_MODE_STATISTICS then 
		return '俱乐部统计'
	elseif _mode == LIST_MODE_INSURANCE then 
		return '保险明细'
	else --if mode == LIST_MODE_NONE
		return  '夜露死苦'
	end
end

function ClubsListView.show(parent, data)
	local view = ClubsListView.new(data)
	if parent then 
		parent:addChild(view) 
	else
		local runScene = cc.Director:getInstance():getRunningScene()
		runScene:addChild(view,StringUtils.getMaxZOrder(runScene))
	end
end
----------------------------------------
--需要参数 
-- _mode 俱乐部统计.俱乐部审核.俱乐部保险
-- title，标题
-- items={
-- 			{ name="", number=""or nil, clubid=int, headimg= string}
--			 ...
-- 		 }
----------------------------------------
function ClubsListView:ctor(params)
	setMode(params['ctlsrc'])
	dump(params, "ClubsListView")
	_data = params or {}
	--Navigation Bar
	local function backHandler(event)
		self:removeFromParent()
	end

	--添加
	local tabParams = {
						backFunc = backHandler,
 						title = getTitle(),
 						parent = self
				   	  }	
	_tabBar = UIUtil.addTopBar(tabParams)
	_tabBar:setLocalZOrder(100)
	--初始化ListView
	self:initListView()
	self._isSwallowImg = true 
	TouchBack.registerImg(self)
end

function ClubsListView:initListView()
	local offsetY = _tabBar:getContentSize().height
	local listViewH = display.height - offsetY
	local bgColor = cc.LayerColor:create(cc.c3b(0,0,0))
	bgColor:setContentSize(cc.size(display.width, display.height))
	self:addChild(bgColor)
	--添加背景
	if _mode ~= LIST_MODE_INSURANCE then 
		UIUtil.addPosSprite(ResLib.MTT_BG, cc.p(display.width/2,0), self, cc.p(0.5,0))
	end
	--添加ListView
	self.listView = ccui.ListView:create()
	self.listView:setDirection(ccui.ScrollViewDir.vertical)
	self.listView:setBounceEnabled(true)
	self.listView:setScrollBarEnabled(false)
	self.listView:setItemsMargin(2.0)
	self.listView:setMagneticType(2)--Both End
	self.listView:setContentSize(cc.size(display.width, listViewH-4))
	self.listView:setPosition(cc.p(0,0))
	self:addChild(self.listView)

	self.listView:addEventListener(handler(self,self.clickHandler))

	local clubsData = _data.clubdata
	for i = 1, #clubsData do
		local cell = self:generateCell(clubsData[i])
		self.listView:pushBackCustomItem(cell)
		-- cell:touchEnded()
	end
end

function ClubsListView:generateCell(item)
	local cell = cc.CSLoader:createNodeWithVisibleSize("scene/CheckClubLayerCell.csb")
	local container = cell:getChildByName("Panel_root")
	container:setTouchEnabled(true)

	local nameNode = ccui.Helper:seekWidgetByName(container, "Text_name")
	nameNode:setString(item['name'])
	-- ccui.Helper:seekWidgetByName(container, "Button_check"):setTouchEnabled(false)
	
	--处理是否是创始俱乐部
	local head_icon = nil
	if item['union'] ==1 then 
		head_icon = ResLib.CLUB_HEAD_ORIGIN
		UIUtil.addPosSprite(ResLib.CLUB_HEAD_ORIGIN_SMALL,cc.p(nameNode:getPositionX()+nameNode:getContentSize().width + 4, nameNode:getPositionY()),container,cc.p(0,.5))
	else 
		head_icon = ResLib.CLUB_HEAD_GENERAL
		UIUtil.addPosSprite(ResLib.CLUB_HEAD_GENERAL_SMALL,cc.p(nameNode:getPositionX()+nameNode:getContentSize().width + 4, nameNode:getPositionY()),container,cc.p(0,.5))
	end

    --添加头像
    local hx, hy = ccui.Helper:seekWidgetByName(container, "Image_head"):getPosition()
    ccui.Helper:seekWidgetByName(container, "Image_head"):setVisible(false)
   	local stencil, clubIcon,mark = UIUtil.addCircleHead({shape = ResLib.CLUB_HEAD_STENCIL_200, pos = cc.p(hx, hy), parent = container, nor = head_icon, sel = head_icon, listener = function()end})
  	mark:setVisible(false)

    if item['avatar'] ~= nil and item['avatar'] ~= "" then 
    	local function callback(respath) 
    		clubIcon:loadTextureNormal(respath)
			clubIcon:loadTexturePressed(respath)
			clubIcon:loadTextureDisabled(respath)
    	end
    	CppPlat.downResFile(item['avatar'], callback, callback, head_icon, 100)
    end

    -- local thead = UIUtil.addShaderHead(cc.p(hx, hy), item['avatar'], container, function(thead)end)
    -- thead:setScale(0.5)
    
    --处理右边的显示
    if _mode == LIST_MODE_AUTHORIZE then 
    	ccui.Helper:seekWidgetByName(container, "Text_yqm"):setString(item['x_num'])
    elseif _mode == LIST_MODE_INSURANCE then 
    	container:setBackGroundImageOpacity(0)
    	container:setBackGroundColor(cc.c3b(0,0,0))
		local line1 = cc.LayerColor:create(cc.c3b(12,31,52))
		line1:setContentSize(cc.size(container:getContentSize().width, 2))
		line1:setPosition(cc.p(0, -2))
		container:addChild(line1)
		nameNode:setTextColor(cc.c3b(70,99,195))
    	local insureVal, color = tonumber(item['x_num']), nil
    	if insureVal > 0 then 
    		insureVal = "+"..insureVal
    		color=cc.c3b(255,0,0)
    	elseif insureVal == 0 then
    		color=cc.c3b(255,255,255) 
    	else 
    		color=cc.c3b(76, 135, 68)
    	end
    	ccui.Helper:seekWidgetByName(container, "Text_m"):removeFromParent()
    	local textNode = ccui.Helper:seekWidgetByName(container, "Text_yqm")
    	textNode:setString(insureVal)
    	textNode:setTextColor(color)
    	textNode:setAnchorPoint(cc.p(1,.5))
    	textNode:setPositionX(682)
    else
    	ccui.Helper:seekWidgetByName(container, "Text_m"):removeFromParent()
    	ccui.Helper:seekWidgetByName(container, 'Text_yqm'):removeFromParent()
    end
    container:removeFromParent()
   	return container
end

function ClubsListView:onEnter()
	--可以在这里添加显示动画
end
function ClubsListView:onExit()
	_data = nil
	_mode = nil
	self.listView = nil
	_tabBar = nil 
end

--处理俱乐部的统计
local function requireClubStatistics(club_id, club_name)
	local callback = function(data)
		_data['clubname'] = club_name
		_data['selectClubId'] = club_id
		require("result.LookStatisticsLayer").show(self, {['itemsData']=data['data'], ['pData'] = _data})
	end
	local tid = _data['pid']
	local isInsure = _data['isInsure']
	if isInsure <= 0 then
		isInsure = 1
	else 
		isInsure = 2
	end
	ResultCtrol.sendRequireStatistic(tid,_data['game_mod'], club_id, isInsure, 1, callback)
end

--处理俱乐部的审核
local function requireClubAuthorize(club_id, club_name)
	local callback = function(data)
		dump(data, "俱乐部审核")
		--test
		-- local TestCase = require('utils.TestCaseMessage')
		-- local data = TestCase.getManagerIds()
		require('result.LookAuthorizeUserLayer').show(self, {['itemsData']=data['data'], ['pData'] = _data})
	end
	
	_data['clubname'] = club_name
	_data['selectClubId'] = club_id
	local tid = _data['pid']
	ResultCtrol.sendRequireAdmins(tid,_data['game_mod'], club_id, callback)
end

--处理俱乐部的保险
local function requireClubInsurance(club_id, club_name, poker_title)
	local tid = _data['pid']
	_data['clubname'] = club_name
	_data['selectClubId'] = club_id

	local callback = function(data)
		dump(data, "俱乐部统计")
		local bxData = {}
		bxData['from'] = club_name
		bxData['clubid'] = club_id
		bxData['name'] = _data['pokerTitle']
		bxData['createWay'] = _data['createWay']
		local allusers = data['data']
		local userData = {}
		for i = 1, #allusers do 
			local user = {}
			user.name = allusers[i]['username']
			user.poolNum =  allusers[i]['insurance_pool']
			user.playerID =  allusers[i]['playerID']
			user.pid = tid
			userData[#userData + 1] = user
		end
		bxData['dataList'] = userData
		require("result.ShowBXListLayer"):create(bxData)
	end
	ResultCtrol.sendPersonInsurance(tid, club_id, callback)


	-- local TestCase = require('utils.TestCaseMessage')
	-- local bxData = TestCase.getClubUserInsure()
	-- bxData['from'] = club_name
	-- bxData['clubid'] = club_id
	-- bxData['name'] = _data['pokerTitle']
	-- bxData['createWay'] = _data['createWay']
	-- require("result.ShowBXListLayer"):create(bxData)
end


function ClubsListView:clickHandler(sender, eType)
	if (eType == 1) then 
		local index = sender:getCurSelectedIndex()
		dump(_data, "测试"..index.."_mode:".._mode)
		local clubdata = _data['clubdata'][index+1]
		local club_id = clubdata['club_id']
		local club_name = clubdata['name']
	
		if _mode == LIST_MODE_STATISTICS then 
			requireClubStatistics(club_id, club_name)
		elseif _mode == LIST_MODE_INSURANCE then 
			requireClubInsurance(club_id, club_name)
		elseif _mode == LIST_MODE_AUTHORIZE then 
			requireClubAuthorize(club_id, club_name)
		end

	end
end


return ClubsListView