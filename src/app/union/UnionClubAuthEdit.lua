--
-- Author: Taylor
-- Date: 2017-08-02 15:17:46
-- 俱乐部权限&设置编辑
--
local ViewBase = require("ui.ViewBase")
local ClubAuthEdit = class("ClubAuthEdit", ViewBase)
local UnionCtrol = require("union.UnionCtrol")

local thisView = nil
local _clubdata = {}

local _selectBlind = {}



local _size = cc.size(display.width, display.height - 130)
local _pageSize = cc.size(750, 291)
local iSize = cc.size(display.width, 1407)
local _scrollView = nil


local _isMineUnion = false
local _isPermitEdit, _isPermitDel = false, false


local function getTextColor(isSelect)
	local isSelectAndEdit = isSelect and _isPermitEdit
	local isSelectAndNotEdit = isSelect and not _isPermitEdit
	local isNotSelectAndEdit = not isSelect and _isPermitEdit
	local isNotSelectAndNotEdit = not isSelect and not _isPermitEdit
	if isSelectAndEdit then return cc.c3b(51, 146, 250) end
	if isSelectAndNotEdit then return ResLib.COLOR_BLUE3 end
	if isNotSelectAndEdit then return ResLib.COLOR_WHITE end
	if isNotSelectAndNotEdit then return ResLib.COLOR_GREY end
end

local function updateAuthValue()
	local from = UnionCtrol.getVisitFrom()
	print("from" .. tostring(from))
	_isMineUnion =(from == UnionCtrol.mine_union)
	_isPermitEdit, _isPermitDel = false, false--是否允许编辑
	print("updateAuthValue _isMineUnion" .. tostring(_isMineUnion))
	if not _isMineUnion then
	else
		_isPermitEdit, _isPermitDel = UnionCtrol.isHasAuth(UnionCtrol.Auth_Club_Edit), UnionCtrol.isHasAuth(UnionCtrol.Auth_REV_MEM)
	end
	
end

local function updatePercentSymobal(value)
	if not thisView or not  thisView.editInsure then 
		return 
	end 
	local charlen, offsetx = string.len(tostring(value)), 8
	if charlen > 4 then
		offsetx = 12
	end 
	local tempLabel = cc.Label:createWithSystemFont(value, "Arial", 28)
	local textSize = tempLabel:getContentSize()
	thisView.editInsure.percentSym:setPositionX(486 + textSize.width + offsetx)
end

local function iconCallback()
end

function ClubAuthEdit:ctor()
	local bg = display.newLayer(cc.c3b(0, 0, 0), display.width, display.height):addTo(self)
	bg._isSwallowImg = true
	TouchBack.registerImg(bg)
	self:enableNodeEvents()
	self:initData()
	self:initUI()
	
	local function deleteHandler()
		local sureFunc = function()
			UnionCtrol.requestDelUnionClub({_clubdata.club_id}, function(data)
				self.action = "delete" --标记行为，用于告知后面显示的界面
				UnionCtrol.requestDetailUnion(function()
					thisView:removeFromParent()
				end)
			end)
		end
		
		ClubAuthEdit.showAlertDialog(sureFunc, function() end)
		
	end
	local function backHandler()
		print("从本联盟中返回俱乐部")
		self:removeFromParent()
	end
	
	print("联盟编辑_isMineUnion..", tostring(_isMineUnion))
	if _isMineUnion then
		print("创建 tbbar")
		local tbData = {["backFunc"] = backHandler, title = "俱乐部信息编辑", parent = self}
		if _isPermitDel then
			tbData['menuFont'] = "删除"
			tbData['menuFunc'] = deleteHandler
		end
		local tabBar = UIUtil.addTopBar(tbData)
	end
end

function ClubAuthEdit:onEnter()
end

function ClubAuthEdit:onExit()
	thisView = nil
	_scrollView = nil
end


function ClubAuthEdit:initData()
	updateAuthValue()
	
	self.pageViewIndicators = {}
	_clubdata = {}
end

function ClubAuthEdit:initUI()
	display.newLayer(cc.c3b(0, 0, 0), _size.width, _size.height):addTo(self)
	
	local sSize, sPos = _size, cc.p(0, 0)
	if not _isMineUnion then
		sPos = cc.p(0, 130)
	end
	
	_scrollView = UIUtil.addScrollView({showSize = sSize, innerSize = iSize, dir = ccui.ScrollViewDir.vertical, pos = sPos, bounce = true, parent = self})
	
	--top
	self:initGalleryPanel()
	
	--center 
	self:initEditZonePanel()
	
	--bottom
	self:initBlindScope()
	
	--游戏btn
	self:initGameBtn()
end

function ClubAuthEdit:initGalleryPanel()
	local unionDetailEditNode = cc.CSLoader:createNodeWithVisibleSize("scene/UnionDetailEdit.csb")
	unionDetailEditNode:setPosition(cc.p(0, iSize.height - _pageSize.height))
	_scrollView:addChild(unionDetailEditNode, 10)
	
	local unionHeadUrl = _clubdata.club_avatar
	unionDetailEditNode:getChildByName("sharebtn"):setVisible(false)
	unionDetailEditNode:getChildByName("tfAdminTitle"):setVisible(false)
	unionDetailEditNode:getChildByName("tfAdmin"):setVisible(false)
	self.pageView = unionDetailEditNode:getChildByName("BgPageView")
	self.unionIcon = unionDetailEditNode:getChildByName("unionicon")
	self.createTimeTf = unionDetailEditNode:getChildByName("tfdate")
	self.createUserTf = unionDetailEditNode:getChildByName("tfuser")
	self.unionNameTf = unionDetailEditNode:getChildByName("unionName")
	self.unionIdTf = unionDetailEditNode:getChildByName("tfId")
	self.clubnumTf = unionDetailEditNode:getChildByName("clubnum")
	self.clubPeople = unionDetailEditNode:getChildByName("clubicon")
	self.clubPeople:setTexture("club/card_list_icon_user1.png")
	
	local posx =(display.width -(self.clubPeople:getContentSize().width + self.clubnumTf:getContentSize().width + 10)) / 2
	self.clubPeople:setPositionX(posx)
	self.clubPeople:setAnchorPoint(cc.p(0, 0.5))
	self.clubnumTf:setPositionX(10 + posx + self.clubPeople:getContentSize().width)
	self.clubnumTf:setAnchorPoint(cc.p(0, 0.5))
	
	self.unionNameTf:setTextColor(ResLib.COLOR_BLUE)
	
	local headNode = display.newNode():addTo(unionDetailEditNode):move(self.unionIcon:getPositionX(), self.unionIcon:getPositionY())
	local stencil, clubIcon = UIUtil.addCircleHead({shape = ResLib.CLUB_HEAD_STENCIL_200, scale = 0.5, pos = cc.p(0, 0), parent = headNode, nor = ResLib.CLUB_HEAD_GENERAL, sel = unionHeadUrl, listener = function() end})
	clubIcon:setTouchEnabled(false)
	self.unionIcon:removeFromParent()
	self.unionIcon = clubIcon
	local function callback(respath)
		self.unionIcon:loadTextureNormal(respath)
		self.unionIcon:loadTexturePressed(respath)
		self.unionIcon:loadTextureDisabled(respath)
	end
	CppPlat.downResFile(unionHeadUrl, callback, function(resPath) end, ResLib.CLUB_HEAD_GENERAL, 100)
	
	self.createTimeTf:setString(os.date("%Y/%m/%d", _clubdata.create_time or 0))
	self.createUserTf:setString(_clubdata.create_host or "")
	-- self.adminNumTf:setString(_clubdata.union_managers or "0/0")
	self.unionNameTf:setString(_clubdata.club_name or "")
	self.unionIdTf:setString("名片ID:" ..(_clubdata.club_no or ""))
	self.clubnumTf:setString(string.format("%s/%s", _clubdata.club_current_user_num or 0, _clubdata.club_limit))
	--初始化pageView
	self.pageView:setClippingEnabled(false)
	self.pageView:removeBackGroundImage()
	local psize = self.pageView:getContentSize()
	local layout = ccui.Layout:create()
	layout:setContentSize(psize)
	ccui.ImageView:create(ResLib.COM_DEFUALT_PHOTO):addTo(layout):align(cc.p(0.5, 0), display.cx, 0):setContentSize(psize)
	self.pageView:addPage(layout)
	self.pageView:onEvent(function(evt)
		if evt.name == "TURNING" then
			local imgs = _clubdata.club_bg_list
			for i = 1, #imgs do
				local index = evt.target:getCurrentPageIndex()
				print("index:" .. index)
				if i == index + 1 then
					self.pageViewIndicators[i]:setTexture("bg/circle_point_show.png")
				else
					self.pageViewIndicators[i]:setTexture("bg/circle_point_bg.png")
				end
			end
		end
	end)
	
end

local function editTextHandle(eType, sender)
	if eType == "began" then
		local numStr = string.match(sender:getText(), '^[0-9]+%.?[0-9]*')
		if numStr and(tonumber(numStr) <= 0 or numStr == "") then sender:setText("")end
		if sender.percentSym then sender.percentSym:setVisible(false) end
	elseif eType == "changed" then
	elseif eType == "ended" then
	elseif eType == "return" then
		local checkTextFunc = sender:getCheckTextFunc() -- WARNING 检查函数，需要设置 
		if checkTextFunc then
			local str = string.trim(sender:getText())
			local isValid, info, defaultStr = checkTextFunc(str)
			if not isValid then
				ViewCtrol.showTip({content = info})
				sender:setText(defaultStr or "")
			end
			local str, _ = string.trim(defaultStr or sender:getText())
			sender:setText(str)
			if sender.percentSym then 
				updatePercentSymobal(str)
				sender.percentSym:setVisible(true)
			end
		end
	end
end

function ClubAuthEdit:initEditZonePanel()
	local posy = iSize.height - _pageSize.height - 40
	UIUtil.addSection({text = "信用额度（上限5000000）", tcolor = cc.c3b(131, 131, 131), fsize = 22, bcolor = cc.c3b(33, 37, 49), pos = cc.p(0, posy), parent = _scrollView})
	local editCredit = UIUtil.addPlatEdit("", cc.p(display.cx, posy - 60), cc.size(710, 30), _scrollView, editTextHandle)
	editCredit:setFontColor(cc.c3b(223, 109, 26))
	editCredit:setPlaceholderFontColor(cc.c3b(223, 109, 26))
	editCredit:setFontSize(30)
	editCredit:setPlaceholderFontSize(30)
	editCredit:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
	editCredit:setCheckTextFunc(function(str)
		local isOk, resultStr, number = checkIsNumber(str)
		if not isOk then
			return isOk, resultStr, tonumber(number)
		end

		local intVal, isDot = math.modf(number)
		if isDot > 0 then 
			return false, "请填写整数", intVal
		end
		
		if tonumber(str) > 5000000 or tonumber(str) < 0 then
			return false, "请填写正确范围，不得大于5000000"
		end
		return true, "", number
	end)
	editCredit:setAnchorPoint(cc.p(0.5, 0))
	editCredit:setTouchEnabled(_isPermitEdit)
	self.editCredit = editCredit
	
	if _isMineUnion then
		local line = cc.LayerColor:create(cc.c3b(61, 68, 86))
		line:setContentSize(cc.size(710, 1))
		line:setPosition(cc.p(display.cx - 710 / 2, posy - 60))
		_scrollView:addChild(line)
	end
	
	-- UIUtil.addLabelArial("剩余额度:", 28, cc.p(20, posy-92), cc.p(0,.5), _scrollView, cc.c3b(131,131,131))
	-- self.leftCredit = UIUtil.addLabelArial("97000", 28, cc.p(152, posy-92), cc.p(0,.5), _scrollView, cc.c3b(223,109,26))
	local usingTf = UIUtil.addLabelArial("已使用:", 28, cc.p(20, posy - 92), cc.p(0, 0.5), _scrollView, cc.c3b(131, 131, 131))
	self.usedCredit = UIUtil.addLabelArial("2000", 28, cc.p(152, posy - 92), cc.p(0, 0.5), _scrollView, cc.c3b(110, 146, 255))
	
	--牌局管理部分
	UIUtil.addSection({text = "牌局管理", tcolor = cc.c3b(131, 131, 131), fsize = 22, bcolor = cc.c3b(33, 37, 49), pos = cc.p(0, posy - 167), parent = _scrollView})
	
	UIUtil.addLabelArial("控制带入", 28, cc.p(20, posy - 210), cc.p(0, 0.5), _scrollView, cc.c3b(131, 131, 131))
	local takeCtlCk = UIUtil.addCheckBox({checkBg = "common/com_checkBox_2.png", checkBtn = "common/com_checkBox_2_1.png", ah = cc.p(0, 0.5), pos = cc.p(353, posy - 210), checkboxFunc = handler(self, self.clickTakeInHandler), parent = _scrollView, touchSize = cc.size(392, 40)})
	local takeinLabel = UIUtil.addLabelArial("必须同意带入,才可加入", 28, cc.p(48, takeCtlCk:getContentSize().height / 2 - 3), cc.p(0, 0.5), takeCtlCk, ResLib.COLOR_WHITE)
	takeCtlCk.text = takeinLabel
	takeinLabel:setTag(100)
	takeCtlCk:loadTextureBackGroundDisabled("common/com_checkBox_2.png")
	takeCtlCk:loadTextureFrontCrossDisabled("common/com_checkBox_2_2.png")
	takeCtlCk:getRendererBackgroundDisabled():setContentSize(cc.size(392, 40))
	takeCtlCk:getRendererFrontCrossDisabled():setContentSize(cc.size(392, 40))
	self.takeCtlCk = takeCtlCk
	takeCtlCk:setEnabled(_isPermitEdit)
	takeCtlCk:setTouchEnabled(_isPermitEdit)
	
	if not _isMineUnion then
		return
	end
	--只有我的联盟下才有
	UIUtil.addLabelArial("保险占比", 28, cc.p(20, posy - 298), cc.p(0, 0.5), _scrollView, cc.c3b(168, 168, 171))
	
	local editInsure = UIUtil.addPlatEdit("", cc.p(486, posy - 298), cc.size(250, 30), _scrollView, editTextHandle)
	editInsure:setFontColor(cc.c3b(255, 255, 255))
	editInsure:setPlaceholderFontColor(cc.c3b(255, 255, 255))
	editInsure:setAnchorPoint(cc.p(0, 0.5))
	editInsure:setCheckTextFunc(function(str)
		local isValid, reason, default_text = checkIsNumber(str)
		if default_text >= 100 or default_text < 0 then
			isValid, reason, default_text = false, "请输入数值0-100以内的值", 0
		end
		local _, isDot = math.modf(tonumber(default_text))
		if isDot < 1 and isDot > 0 then 
			default_text = string.format( "%.2f",default_text )
		end  
		return isValid, reason, default_text
	end)
	editInsure:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
	editInsure:setFontSize(30)
	editInsure:setPlaceholderFontSize(30)
	editInsure:setTouchEnabled(_isPermitEdit)
	editInsure.percentSym = UIUtil.addLabelArial("%", 28, cc.p(486+225, posy - 298), cc.p(0,0.5), _scrollView)
	updatePercentSymobal(0)
	self.editInsure = editInsure
	
	local line1 = cc.LayerColor:create(cc.c3b(61, 68, 86))
	line1:setContentSize(cc.size(250, 1))
	line1:setPosition(cc.p(486, posy - 314))
	_scrollView:addChild(line1)
end


function ClubAuthEdit:initBlindScope()
	
	local posy = iSize.height - _pageSize.height - 40 - 382
	if not _isMineUnion then
		posy = iSize.height - _pageSize.height - 40 - 298
	end
	UIUtil.addLabelArial("开发盲注", 28, cc.p(20, posy), cc.p(0, 0.5), _scrollView, cc.c3b(131, 131, 131))
	
	local ckbposy = posy - 66
	local posxArr = {20, 353}
	local blindLev = DZConfig.buildBlind()
	local blindCount = #blindLev
	local row = math.ceil(blindCount / 2)
	for i = 1, row do
		for j = 1, 2 do
			local index =(i - 1) * 2 + j
			if index <= blindCount then
				local checkbtn = UIUtil.addCheckBox({checkBg = "common/com_checkBox_2.png", checkBtn = "common/com_checkBox_2_1.png", ah = cc.p(0, 0.5), pos = cc.p(posxArr[j], ckbposy - 76 *(i - 1)), checkboxFunc = handler(self, self.clickBlindsHandler), parent = _scrollView, touchSize = cc.size(180, 40)})
				checkbtn:loadTextureBackGroundDisabled("common/com_checkBox_2.png")
				checkbtn:loadTextureFrontCrossDisabled("common/com_checkBox_2_2.png")
				checkbtn:getRendererBackgroundDisabled():setContentSize(cc.size(180, 40))
				checkbtn:getRendererFrontCrossDisabled():setContentSize(cc.size(180, 40))
				local str = ""
				if blindLev[index] < 10000 then
					str =(blindLev[index] / 2) .. "/" .. blindLev[index]
				else
					str = string.format("%dK/%dK", blindLev[index] / 2000, blindLev[index] / 1000)
				end
				local text = UIUtil.addLabelArial(str, 28, cc.p(50, checkbtn:getContentSize().height / 2 - 3), cc.p(0, 0.5), checkbtn, cc.c3b(186, 188, 190))
				checkbtn:setTag(blindLev[index])
				checkbtn.text = text
				checkbtn:setEnabled(_isPermitEdit)
				checkbtn:setTouchEnabled(_isPermitEdit)
			end
		end
	end
end

function ClubAuthEdit:initGameBtn()
	if not _isMineUnion or not _isPermitEdit then
		return
	end
	local posy = iSize.height - _pageSize.height - 941
	self.playText = UIUtil.addLabelArial("牌局暂停", 28, cc.p(20, posy), cc.p(0, 0.5), _scrollView, cc.c3b(131, 131, 131))
	self.playText:setVisible(false)
	self.playBtn = UIUtil.addCheckBox({checkBg = ResLib.UNION_GAME_STOP, checkBtn = ResLib.UNION_GAME_START, ah = cc.p(0, 0.5), pos = cc.p(20, posy), checkboxFunc = handler(self, self.kickOutHandler), parent = _scrollView})
	
	local btn_normal, btn_select = "common/com_btn_blue.png", "common/com_btn_blue_height.png"
	local label = cc.Label:createWithSystemFont("保存", "Marker Felt", 36)
	label:setColor(cc.c3b(255, 255, 255))
	local btn = UIUtil.controlBtn(btn_normal, btn_select, btn_normal, label, cc.p(display.width / 2, 60), cc.size(710, 80), handler(self, self.saveHandler), self)
end
--是否允许带入
function ClubAuthEdit:clickTakeInHandler(sender, evt)
	if ccui.CheckBoxEventType.selected == evt then
		sender.text:setColor(ResLib.COLOR_BLUE)
	else
		sender.text:setColor(ResLib.COLOR_WHITE)
	end
end

function ClubAuthEdit:clickBlindsHandler(sender, evt)
	
	local tag = tonumber(sender:getTag())
	local index = table.indexof(_selectBlind, tostring(tag))
	if ccui.CheckBoxEventType.selected == evt then
		if not index then
			_selectBlind[#_selectBlind + 1] = tostring(tag)
			sender.text:setTextColor(getTextColor(true))
		end
	else
		sender.text:setTextColor(getTextColor(false))
		table.removebyvalue(_selectBlind, tostring(tag), true)
	end
end

function ClubAuthEdit:kickOutHandler(sender, evt)
	print("牌局开始 or 牌局暂停")
	local union_id = UnionCtrol.getUnionDetail().union_id
	if ccui.CheckBoxEventType.selected == evt then
		self.playText:setString("牌局开始")
		UnionCtrol.requestUnionFoceStandup(_clubdata.club_id, union_id, 2, function() end)
	else
		self.playText:setString("牌局暂停")
		UnionCtrol.requestUnionFoceStandup(_clubdata.club_id, union_id, 1, function() end)
	end
end

function ClubAuthEdit:saveHandler()
	-- print("保存", self.editInsure:getText(), string.match(self.editInsure:getText(), "[0-9]*"))
	local takein = 0
	if self.takeCtlCk:isSelected() then
		takein = 1
	end
	
	local function response(data)
		ViewCtrol.showTick({content = "保存成功!"})
	end
	
	local params = {}
	params.club_line_credit = self.editCredit:getText()
	params.control_join = takein
	params.open_blind = _selectBlind
	params.insurance_scale = tonumber(self.editInsure:getText())
	params.club_id = _clubdata.club_id
	UnionCtrol.requestSetClubInfo(params, response)
end




local function refreshAllUI()
	local function callback(respath)
		thisView.unionIcon:loadTextureNormal(respath)
		thisView.unionIcon:loadTexturePressed(respath)
		thisView.unionIcon:loadTextureDisabled(respath)
	end
	CppPlat.downResFile(_clubdata.club_avatar, callback, function(resPath) end, ResLib.UNION_HEAD, 100)
	
	thisView.createTimeTf:setString(os.date("%Y/%m/%d", _clubdata.create_time or 0))
	thisView.createUserTf:setString(_clubdata.create_host or "")
	-- thisView.adminNumTf:setString(unionData.union_managers or "0/0")
	thisView.unionNameTf:setString(_clubdata.club_name or "")
	thisView.unionIdTf:setString("名片ID:" ..(_clubdata.club_no or ""))
	thisView.clubnumTf:setString(string.format("%s/%s", _clubdata.club_current_user_num or 0, _clubdata.club_limit))
	local posx =(display.width -(thisView.clubPeople:getContentSize().width + thisView.clubnumTf:getContentSize().width + 10)) / 2
	thisView.clubPeople:setPositionX(posx)
	thisView.clubPeople:setAnchorPoint(cc.p(0, 0.5))
	thisView.clubnumTf:setPositionX(10 + posx + thisView.clubPeople:getContentSize().width)
	thisView.clubnumTf:setAnchorPoint(cc.p(0, 0.5))
	--刷新画廊
	local bglist = _clubdata.club_bg_list
	if bglist and #bglist > 0 then
		thisView.pageView:removeAllPages()
		for i, v in ipairs(thisView.pageViewIndicators) do
			if v then
				thisView.pageView:removeProtectedChild(v)
			end
		end
		local width = 20 * #bglist
		local posx =(display.width - width) / 2
		for i = 1, #bglist do
			local layout = ccui.Layout:create()
			layout:setContentSize(thisView.pageView:getContentSize())
			
			local widget = ccui.ImageView:create(ResLib.COM_DEFUALT_PHOTO):align(cc.p(0.5, 0), display.cx, 0)
			widget:setContentSize(cc.size(display.width, thisView.pageView:getContentSize().height))
			layout:addChild(widget)
			thisView.pageView:addPage(layout)
			local function funcBack(path)
				widget:loadTexture(path, 0)
			end
			local function ferror()
			end
			ClubModel.downloadPhoto(funcBack, bglist[i], false, ferror)
			local point = display.newSprite("bg/circle_point_bg.png", posx +(i - 1) * 20 + 10, thisView.pageView:getContentSize().height - 21)
			thisView.pageView:addProtectedChild(point, 1000000)
			thisView.pageViewIndicators[i] = point
			if i == 1 then
				point:setTexture("bg/circle_point_show.png")
			end
		end
	end
	--更新其他部位
	thisView.editCredit:setText(_clubdata.club_line_credit or 0)
	thisView.usedCredit:setString(_clubdata.club_used_credit or 0)
	if thisView.editInsure then
		thisView.editInsure:setText(tonumber(_clubdata.insurance_scale) or 0)
		updatePercentSymobal(tonumber(_clubdata.insurance_scale) or 0)
	end
	
	--选择
	thisView.takeCtlCk:setSelected(_clubdata.control_join == 1)
	thisView.takeCtlCk.text:setColor(getTextColor(_clubdata.control_join == 1))
	thisView.takeCtlCk:setEnabled(_isPermitEdit)
	thisView.takeCtlCk:setTouchEnabled(_isPermitEdit)
	--更新盲注
	local all_blind = DZConfig.buildBlind()
	local open_blind = _clubdata.open_blind
	for i = 1, #all_blind do
		local index = table.indexof(open_blind, tostring(all_blind[i]))
		local ckbtn = _scrollView:getChildByTag(all_blind[i])
		ckbtn:setSelected(checkbool(index))
		ckbtn.text:setTextColor(getTextColor(checkbool(index)))
		ckbtn:setEnabled(_isPermitEdit)
		ckbtn:setTouchEnabled(_isPermitEdit)
	end
	_selectBlind = open_blind
	--更新游戏状态
	if thisView.playBtn then
		local isHead = UnionCtrol.isStatus(UnionCtrol.STATUS_HEAD)
		local game_state = _clubdata.game_state or 2
		thisView.playBtn:setSelected(game_state == 2)
		thisView.playBtn:setTouchEnabled(isHead)
		thisView.playBtn:setEnabled(isHead)
	end
end

local function refreshInfoUI()
	if not _clubdata then
		return
	end
	local function response(data)
		table.map(data, function(v, k)
			_clubdata[k] = v
		end)
		refreshAllUI()
	end
	UnionCtrol.requestGetClubInfo(_clubdata.club_id, response)
end

function ClubAuthEdit:showContent()
	--tabbar入口
	updateAuthValue()
	thisView = self
	_clubdata = UnionCtrol.getUnionCMember() [1]
	refreshInfoUI()
end
function ClubAuthEdit:hideContent()
end


function ClubAuthEdit.show(parent, params)
	parent = parent or cc.Director:getInstance():getRunningScene()
	thisView = require("union.UnionClubAuthEdit"):create()
	parent:addChild(thisView)
	
	_clubdata = params
	refreshInfoUI()
	return thisView
end

function ClubAuthEdit.showAlertDialog(sureFunc, cancel)
	local bgColor = display.newLayer(cc.c3b(0, 0, 0), display.size):addTo(thisView)
	bgColor:setOpacity(100)
	bgColor._isSwallowImg = true
	TouchBack.registerImg(bgColor)
	
	local function sureFuncHandler(sender, evt)
		if evt == ccui.TouchEventType.ended then
			if sureFunc then sureFunc() end
			bgColor:removeFromParent()
		end
	end
	local function cancelHandler(sender, evt)
		if evt == ccui.TouchEventType.ended then
			if cancel then cancel() end
			bgColor:removeFromParent()
		end
	end
	local bg = display.newLayer(cc.c3b(230, 230, 237), display.width, 331):move(0, - 331):addTo(bgColor)
	local top = display.newLayer(cc.c3b(255, 255, 255), display.width, 117):move(0, 331 - 117):addTo(bg)
	local middle = display.newLayer(cc.c3b(255, 255, 255), display.width, 100):move(0, 331 - 220):addTo(bg)
	local bottom = display.newLayer(cc.c3b(255, 255, 255), display.width, 103):move(0, 0):addTo(bg)
	
	UIUtil.addLabelArial("你确定要删除此俱乐部吗?", 32, cc.p(display.cx, 117 / 2), cc.p(0.5, 0.5), top, cc.c3b(230, 230, 230))
	
	local sureBtn = UIUtil.addUIButton({ResLib.COM_OPACITY0, ResLib.COM_OPACITY0, ResLib.COM_OPACITY0}, cc.p(display.cx, 117 / 2), middle, sureFuncHandler)
	sureBtn:setTitleText("确定")
	sureBtn:setTitleColor(cc.c3b(255, 0, 0))
	sureBtn:setScale9Enabled(true)
	sureBtn:setTitleFontSize(46)
	sureBtn:setContentSize(display.width, 117)
	sureBtn:setAnchorPoint(cc.p(0.5, 0.5))
	
	local cancelBtn = UIUtil.addUIButton({ResLib.COM_OPACITY0, ResLib.COM_OPACITY0, ResLib.COM_OPACITY0}, cc.p(display.cx, 117 / 2), bottom, cancelHandler)
	cancelBtn:setTitleText("取消")
	cancelBtn:setTitleColor(cc.c3b(0, 0, 0))
	cancelBtn:setScale9Enabled(true)
	cancelBtn:setTitleFontSize(46)
	cancelBtn:setContentSize(display.width, 117)
	cancelBtn:setAnchorPoint(cc.p(0.5, 0.5))
	bg:moveTo({time = 0.1, x = 0, y = 0})
	return bgColor
	
end
return ClubAuthEdit
