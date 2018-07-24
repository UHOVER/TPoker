--
-- Author: Taylor
-- Date: 2017-08-03 13:43:24
--

local ViewBase = require("ui.ViewBase")
local AdminOptLayer = class("AdminOptLayer", ViewBase)
local UnionCtrol = require("union.UnionCtrol")

local thisOpt = nil

local MAX_NUM_PRE = 50

local _loadIndex = 1--加载的标记索引
local _totalNum = 0 --数据总数

local _vSize = cc.size(display.width, display.height-130)
local _sSize = cc.size(display.width, 40)
local _cSize = cc.size(display.width+62, 98)

local _setTopBar = nil --设置管理员
local _delTopBar = nil --删除管理员

local _scrollView = nil --北京scrollView

local _primarySection = nil --初级section
local _middleSection = nil --中级section
local _highSection = nil --高级UIsection

local _pContent = nil --初级内容
local _mContent = nil --中级内容
local _hContent = nil --高级内容

local _pAddButton = nil --初级按钮
local _mAddButton = nil --中级按钮
local _hAddButton = nil --高级按钮

local _datasouce = nil --管理员名单
local loadDataPreframe = nil --函数
local refreshUIHandle = nil --刷新UI
local del_admins = nil
local function resetDelData()
	del_admins = {["1"]={},["2"]={},["3"]={}} -- *note key = “1”
end
local function clickSettingHandler(sender, eventType)
	if eventType ~= ccui.TouchEventType.ended then 
		return 
	end
	require("union.AdminSetLayer").show(nil, {lev = sender:getTag()})
end
local function clickSelectDelHandler(sender,evt)
	local lev = tostring(sender:getParent().lev)
	local datas = del_admins[lev]
	if ccui.CheckBoxEventType.selected == evt then 
		datas[#datas + 1] = sender:getParent().userId
	else
		table.removebyvalue(datas, sender:getParent().userId, true)
	end
end


local function clickAddAdminHandler(sender, evt)
	if evt ~= ccui.TouchEventType.ended then 
		return
	end
	local adminCount =  #_datasouce[1] + #_datasouce[2] + #_datasouce[3]
	local params = {lev = sender:getTag(), admin_count = adminCount, delegate = thisOpt}
	require("union.SearchAdminLayer").show(nil, params)
end
----------------------------------------
--切换删除按钮等动画
----------------------------------------
local function entryDelMode()
	if not _delTopBar:isVisible() then 
		do return end
	end
	resetDelData()
	_middleSection:setPositionY(_middleSection:getPositionY() + _cSize.height)
	_highSection:setPositionY(_highSection:getPositionY() + _cSize.height * 2)
	_pAddButton:setVisible(false)
	_mAddButton:setVisible(false)
	_hAddButton:setVisible(false)
	DZAction.easeInMove(_pContent, cc.p(0, _pContent:getPositionY()), 0.1, nil, nil)
	DZAction.easeInMove(_mContent, cc.p(0, _mContent:getPositionY()), 0.1, nil, nil)
	DZAction.easeInMove(_hContent, cc.p(0, _hContent:getPositionY()), 0.1, nil, nil)
end

local function entryAddMode()
	if not _setTopBar:isVisible() then
		do return end 
	end
	resetDelData()
	_middleSection:setPositionY(_middleSection:getPositionY() - _cSize.height)
	_highSection:setPositionY(_highSection:getPositionY() - _cSize.height*2)
	_pAddButton:setVisible(true)
	_mAddButton:setVisible(true)
	_hAddButton:setVisible(true)
	DZAction.easeInMove(_pContent, cc.p(display.width - _cSize.width, _pContent:getPositionY()), 0.1, nil, nil)
	DZAction.easeInMove(_mContent, cc.p(display.width - _cSize.width, _mContent:getPositionY()), 0.1, nil, nil)
	DZAction.easeInMove(_hContent, cc.p(display.width - _cSize.width, _hContent:getPositionY()), 0.1, nil, nil)
end

local function showTopBar(obj)
	if not _setTopBar or not _delTopBar then  return end

	_setTopBar:setVisible(obj == _setTopBar)
	_delTopBar:setVisible(obj == _delTopBar)

end

------------------------------------------------------------------------------------
function AdminOptLayer:ctor()
	self:enableNodeEvents()
	self:initData()
	self:initUI()
	self:initTopbar()

	self._isSwallowImg = true
	TouchBack.registerImg(self)
end


local function attachData(data, lev)
	if data == nil or (data[#data] and data[#data].add) then 
		return 
	end
	data[#data + 1] = {add = true, lev = lev}
end

function AdminOptLayer:initData()
	resetDelData()
	_datasouce = {
						[1] = {
							-- {username = "海亭"..math.random(100), headUrl = "", userId = math.random(100)},
						},
						[2] = {
							-- {username = "海亭"..math.random(100), headUrl = "", userId = math.random(100)},
						},
						[3] = {
							-- {username = "海亭"..math.random(100), headUrl = "", userId = math.random(100)},
						},
				}

    attachData(_datasouce[1])
	attachData(_datasouce[2])
	attachData(_datasouce[3])
end



function AdminOptLayer:initTopbar()
	local function confirmHandler()
		if table.nums(del_admins) <= 0 then 
			showTopBar(_setTopBar)
			entryAddMode()
			return 
		end

		local function resultHandler(data)
			--删除数据
			-- for i = 1, #del_admins do 
			-- 	for j = 1, #del_admins[i] do 
			-- 		table.removebyvalue(_datasouce[i], del_admins[i][j])
			-- 	end
			-- end
			
			-- loadDataPreframe()
			showTopBar(_setTopBar)
			entryAddMode()
			refreshUIHandle()
		end
		UnionCtrol.requestDelAdmins(del_admins, resultHandler)
	end

	local function delHandler()
		showTopBar(_delTopBar)
		entryDelMode()
	end

	local function backHandler()
		self:removeFromParent()
	end

	local function restoreHandler()
		showTopBar(_setTopBar)
		entryAddMode()
	end
	_setTopBar = UIUtil.addTopBar({["backFunc"]=backHandler,title = "设置管理员", parent = self, menuFont="删除", menuFunc=delHandler})
	_delTopBar = UIUtil.addTopBar({["backFunc"]=restoreHandler,title = "删除管理员", parent = self, menuFont="确定", menuFunc=confirmHandler})
	showTopBar(_setTopBar)
end

local function addCell(data, csize, pos, parent, lev)
	local username = tostring(data["user_name"])
	local headUrl = tostring(data["head_img"])
	local pid = tostring(data["pid"])
	local bgColor = display.newLayer(ResLib.COLOR_BLACK, csize)
	local line = display.newLayer(cc.c3b(21,24,31), cc.size(display.width, 2))
	bgColor:addChild(line)
	bgColor:setPosition(pos)
	parent:addChild(bgColor)

	local stencil,head = UIUtil.addUserHead(cc.p(57+62,csize.height/2), headUrl, bgColor, true)
	stencil:setScale(0.76)
	head:setScale(0.76)

	-- local function success( path )
	-- 	head:loadTextures(path, path, path)
	-- end
	-- CppPlat.downResFile(headUrl , success, function()end, ResLib.USER_HEAD, "LoadUserPhoto")
	UIUtil.addLabelArial(username, 34, cc.p(114+62,csize.height/2), cc.p(0,0.5), bgColor)
	bgColor.userId = pid
	bgColor.lev = lev
	local ckbox = UIUtil.addCheckBox( {pos=cc.p(41, csize.height/2), checkboxFunc = clickSelectDelHandler, parent = bgColor})
	return bgColor
end

local function addCellButton(tag, parent, func)
	local bgColor = display.newLayer(ResLib.COLOR_BLACK, cc.size(display.width, _cSize.height))
	parent:addChild(bgColor)
	local btn = UIUtil.addUIButton({ResLib.COM_OPACITY0, ResLib.COM_OPACITY0, ResLib.COM_OPACITY0}, cc.p(display.cx, _cSize.height/2), bgColor, func)
	btn:setScale9Enabled(true)
	btn:setContentSize(cc.size(display.width, _cSize.height))
	btn:setTag(tag)
	UIUtil.addPosSprite("club/add_member_btn.png", cc.p(57, _cSize.height/2), bgColor)
	UIUtil.addLabelArial("添加管理员", 34, cc.p(114, _cSize.height/2), cc.p(0, .5), bgColor)
	return bgColor
end

local function createCardNode(tag, text, pos, parent, func)
	local node = cc.Node:create()
	node:setPosition(pos)
	node:setTag(tag)
	parent:addChild(node)

	local section = UIUtil.addSection({text = text ,tcolor = ResLib.COLOR_GREY1, fsize = 26, pos=cc.p(0, -42), parent = node})
	local btn = UIUtil.addUIButton({ResLib.COM_OPACITY0, ResLib.COM_OPACITY0, ResLib.COM_OPACITY0}, cc.p(display.width-47, 20), section, func)
	btn:setScale9Enabled(true)
	btn:setContentSize(cc.size(94, 42))
	btn:setTitleColor(cc.c3b(91,146,255))
	btn:setTitleText("设置")
	btn:setTitleFontSize(26)
	btn:setTag(tag)

	node.size = cc.size(_cSize.width, 42) -- 初始对象的宽高
	node.basey = -42--最小坐标
	return node
end

loadDataPreframe = function()
	local pData = _datasouce[1]
	local mData = _datasouce[2]
	local hData = _datasouce[3]

	_pContent:removeAllChildren()
	for i = 1, #pData do 
		local data = pData[i]
		if data.add then 
		   _pAddButton = addCellButton(1, _pContent, clickAddAdminHandler)
		   _pAddButton:setPosition(cc.p(_cSize.width - display.width, 0-i*_cSize.height))
		else
		   addCell(data, _cSize, cc.p(0, 0-i*_cSize.height), _pContent, 1)
		end
	end

	_mContent:removeAllChildren()
	for i = 1, #mData do 
		local data = mData[i]
		if data.add then 
			_mAddButton = addCellButton(2, _mContent, clickAddAdminHandler)
		    _mAddButton:setPosition(cc.p(_cSize.width - display.width, 0-i*_cSize.height))
		else 
			addCell(data, _cSize, cc.p(0, 0-i*_cSize.height), _mContent, 2)
		end
	end
	
	_hContent:removeAllChildren()
	for i = 1, #hData do 
		local data = hData[i]
		if data.add then 
			_hAddButton = addCellButton(3, _hContent, clickAddAdminHandler)
		    _hAddButton:setPosition(cc.p(_cSize.width - display.width, 0-i*_cSize.height))
		else 
			addCell(data, _cSize, cc.p(0, 0-i*_cSize.height), _hContent, 3)
		end
	end
	local viewSizeH = (#pData + #mData + #hData)*_cSize.height + 40*3
	viewSizeH = math.max(viewSizeH, _vSize.height)
	_primarySection:setPositionY(viewSizeH)
	_middleSection:setPositionY(viewSizeH - #pData * _cSize.height - 40)
	_highSection:setPositionY(_middleSection:getPositionY() - #mData * _cSize.height - 40)
	_scrollView:setInnerContainerSize(cc.size(display.width, viewSizeH))
end

function AdminOptLayer:initUI()
	self:enableNodeEvents()
	_scrollView = UIUtil.addScrollView( {showSize=_vSize, innerSize=_vSize, dir=cc.SCROLLVIEW_DIRECTION_VERTICAL, colorType=ccui.LayoutBackGroundColorType.solid, color=cc.c3b(0, 0, 10), bounce=true, pos=cc.p(0,0), parent=self} )
	_primarySection = createCardNode(1, "初级管理员", cc.p(0, _vSize.height), _scrollView, clickSettingHandler)
	_middleSection = createCardNode(2, "中级管理员", cc.p(0, _vSize.height-_sSize.height),_scrollView,clickSettingHandler)
	_highSection = createCardNode(3, "高级管理员", cc.p(0, _vSize.height-_sSize.height*2),_scrollView,clickSettingHandler)

	_pContent = cc.Node:create()
	_pContent:setPosition(display.width-_cSize.width, -40)
	_pContent.basey = 0
	_primarySection:addChild(_pContent)

	_mContent = cc.Node:create()
	_mContent:setPosition(display.width-_cSize.width, -40)
	_mContent.basey = 0
	_middleSection:addChild(_mContent)

	_hContent = cc.Node:create()
	_hContent:setPosition(display.width-_cSize.width, -40)
	_hContent.basey = 0
	_highSection:addChild(_hContent)

	-- _pAddButton = addCellButton(1, _pContent, clickAddAdminHandler)
	-- _mAddButton = addCellButton(2, _mContent, clickAddAdminHandler)
	-- _hAddButton = addCellButton(3, _hContent, clickAddAdminHandler)
	
	loadDataPreframe()
end

function AdminOptLayer:onExit()
	_pContent:removeFromParent()
	_mContent:removeFromParent()
	_hContent:removeFromParent()

	_pContent = nil
	_mContent = nil
	_hContent = nil
	
	del_admins = nil
    _datasouce = nil
	_setTopBar = nil
	_delTopBar = nil

end


refreshUIHandle = function()
		local function response(data)
			local admin_num = #data[1] + #data[2]+ #data[3]
			UnionCtrol.editUnionInfo({union_managers = admin_num.."/32"})
			_datasouce = data
			attachData(_datasouce[1])
			attachData(_datasouce[2])
			attachData(_datasouce[3])
			loadDataPreframe()

		end
		UnionCtrol.requestUnionAdmin(response)
end

function AdminOptLayer.show(parent)
	parent = parent or cc.Director:getInstance():getRunningScene()
	thisOpt = AdminOptLayer.new()

	parent:addChild(thisOpt)
	refreshUIHandle()
	return thisOpt
end

function AdminOptLayer.addAdmin(adminList, lev)
	refreshUIHandle()
end

return AdminOptLayer