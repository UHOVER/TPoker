--
-- Author: Taylor
-- Date: 2017-08-04 11:45:29
-- 设置管理员

local ViewBase = require("ui.ViewBase")
local AdminSetLayer = class("AdminSetLayer", ViewBase)
local UnionCtl = require("union.UnionCtrol")
local thisView = nil


local tabTitles = {"初级管理员",100, "中级管理员", 200, "高级管理员", 300}
local resLibs = {ResLib.P_ADMIN_BTN_U, ResLib.P_ADMIN_BTN_L, ResLib.M_ADMIN_BTN_U,ResLib.M_ADMIN_BTN_L,ResLib.H_ADMIN_BTN_U,ResLib.H_ADMIN_BTN_L}
local auth_title = {"创建牌局", "牌局结算", "添加成员", "移除成员", "俱乐部信息编辑", "历史牌局查询"}
local auth_const = {UnionCtl.Auth_CREATE, UnionCtl.Auth_SETTLE, UnionCtl.Auth_ADD_MEM, UnionCtl.Auth_REV_MEM, UnionCtl.Auth_Club_Edit ,UnionCtl.Auth_URace_Ago}
local sizeBtn = cc.size(248, 87)
local ckpos = {56, 501}
local _topy = display.height - 130


local _contents = nil
local _tabBars = nil
local _selectAuths = nil
local refreshCurAuthState = nil 


function AdminSetLayer:ctor()
	-- self:enableNodeEvents()
	self:initData()
	self:initUI()
	local function backHandler()

		self:removeFromParent()
	end
	UIUtil.addTopBar({["backFunc"]=backHandler,title = "设置管理员", parent = self})
end

function AdminSetLayer:onEnter()
end

function AdminSetLayer:onExit()
end

function AdminSetLayer:initData()
	_tabBars = {}
	_contents = {}
	_selectAuths = 
	{
		[1] = {},
		[2] = {},
		[3] = {}
	}
	self.selectIndex = 0
end

function AdminSetLayer:createContent(pos, size, parent)
	local content = display.newLayer(ResLib.COLOR_BLACK, cc.size(display.width, _topy - sizeBtn.height))
	content:setPosition(pos)
	parent:addChild(content, 9)
	local row = 2
	local ckposy = _topy - sizeBtn.height - 75
	for i = 1, #auth_title/row do 
		for j = 1, row do 
			local index = (i - 1)*2+j
			local text = auth_title[index]
			local checkbtn = UIUtil.addCheckBox({checkBg = "common/com_checkBox_3.png", checkBtn = "common/com_checkBox_2_1.png", ah = cc.p(0.5,.5), pos = cc.p(ckpos[j] + 100, ckposy - 102*(i-1)), checkboxFunc = handler(self,self.clickTakeInHandler), parent = content, touchSize = cc.size(200,39)})
			local label = UIUtil.addLabelArial(text, 30, cc.p(48, checkbtn:getContentSize().height/2-3), cc.p(0, .5), checkbtn, display.COLOR_WHITE)
			checkbtn.text = label
			checkbtn:setTag(index)
		end
	end
	return content
end

function AdminSetLayer:initUI()
	local bglayer = display.newLayer(ResLib.COLOR_BLACK, display.width,display.height):addTo(self)
	bglayer._isSwallowImg = true
	TouchBack.registerImg(bglayer)
	local len = #tabTitles/2
	for i = 1 , len do 
		local tmpx = (i -1)*(sizeBtn.width+1)
		local btn = UIUtil.controlBtn(resLibs[i*2-1], resLibs[i*2], resLibs[i*2], nil, cc.p(tmpx, _topy), sizeBtn, handler(self,self.clickTabBarHandler), self)
		btn:setTag(tabTitles[i*2])
		btn.tabIndex = i
		btn:setAnchorPoint(cc.p(0, 1))
		btn:setLocalZOrder(10)
		_tabBars[#_tabBars + 1] = btn

		local content = self:createContent(cc.p(0,0), cc.size(display.width,display.height), self)
		content.contentIndex = i
		_contents[#_contents + 1] = content
	end

	local btn_normal, btn_select = "common/com_btn_blue.png",  "common/com_btn_blue_height.png"
	local label = cc.Label:createWithSystemFont("保存", "Marker Felt", 36)
	label:setColor(cc.c3b(255,255,255))
	local btn = UIUtil.controlBtn(btn_normal, btn_select, btn_normal, label, cc.p(display.width/2, 60), cc.size(710,80), handler(self,self.saveHandler), self)
	btn:setLocalZOrder(11)
	-- self:switchTab(1)
end

--切换显示
function AdminSetLayer:switchTab(index)
	if _tabBars == nil or #_tabBars <= 0  then 
		print("错误")
		return
	end

	if index <= 0 or index > #_tabBars then 
		print("边界错误")
		return 
	end

	if self.selectIndex == index then 
		print("重复点击"..self.selectIndex)

		return
	end
	local oldContent = _contents[self.selectIndex]
	local newContent = _contents[index]
	if newContent then 
		newContent:setPosition(0, 0)
		newContent:setVisible(true)
	end
	if oldContent then 
		oldContent:setPosition(10000, 0)
		oldContent:setVisible(false)
	end
	
	self.selectIndex = index
	for i,v in ipairs(_tabBars) do
		local content = _contents[i]
		local isSelect = (index == i)
		content:setVisible(isSelect)
		if isSelect then 
			content:setPosition(0, 0)
		else 
			content:setPosition(10000,0)
		end
		v:setSelected(isSelect)
		v:setHighlighted(isSelect)
		v:setEnabled(not isSelect)
	end
end

function AdminSetLayer:clickTabBarHandler(sender, event)
	self:switchTab(sender.tabIndex)
end

function AdminSetLayer:clickTakeInHandler(sender, evt)
	local auths = _selectAuths[self.selectIndex]
	if ccui.CheckBoxEventType.selected == evt then 
		local index = table.indexof(auths, tostring(auth_const[sender:getTag()]))
		if not index then 
			auths[#auths + 1] = tostring(auth_const[sender:getTag()])
		end
		sender.text:setTextColor(ResLib.COLOR_BLUE4)
	else 
		table.removebyvalue(auths, tostring(auth_const[sender:getTag()]), true)
		sender.text:setTextColor(display.COLOR_WHITE)
	end
end

function AdminSetLayer:saveHandler(sender, evt)
	for i = 1, #_selectAuths do --self.selectIndex
		UnionCtl.requestSetAdminAuth(i, _selectAuths[i], function() 
				if i == 3 then 
					self:removeFromParent()
				end
			end)
	end
end

local function refreshView(lev, authlist)
	if not _contents then 
		return
	end

	local content = _contents[lev]
	if not content or #authlist <= 0 then 
		return
	end

	dump(authlist)
	for i = 1, #auth_title do 
		local index = table.indexof(authlist, tostring(auth_const[i]))
		local checkBtn = content:getChildByTag(i)
		if index then 
			checkBtn:setSelected(true)
			checkBtn.text:setColor(ResLib.COLOR_BLUE)
		else 
			checkBtn:setSelected(false)
			checkBtn.text:setColor(ResLib.COLOR_WHITE)
		end
	end
end
------------------------------------------------------------

refreshCurAuthState = function(lev)
	for i = 1, #_selectAuths do
		local function response(data)
			if thisView then 
				refreshView(i, data)
				_selectAuths[i] = data
			end
		end
		UnionCtl.requestGetAdminAuth(i, response)	
	end
	
end

function AdminSetLayer.show(parent, params)
	parent = parent or cc.Director:getInstance():getRunningScene()
	thisView = AdminSetLayer:create()
	parent:addChild(thisView, StringUtils.getMaxZOrder(parent))
	thisView:switchTab(params.lev or 1)
	refreshCurAuthState(params.lev or 1)
	return thisView
end
return AdminSetLayer
