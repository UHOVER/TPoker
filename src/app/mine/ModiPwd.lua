local ViewBase = require("ui.ViewBase")
local ModiPwd = class("ModiPwd", ViewBase)

local _modiPwd = nil
local curNode = nil
local old_pwd = nil
local new_pwd = nil

-- 原密码
function ModiPwd:buildCurPwd(  )

	local node = cc.Node:create()
	node:setPosition(cc.p(0,0))
	self:addChild(node, 10)

	-- topBar
	local function Callback(  )
		_modiPwd:removeFromParent()
	end
    UIUtil.addTopBar({backFunc = Callback, title = "验证密码", parent = node})

    local nextBtn = nil
    local password = ''

    UIUtil.addLabelArial("原密码", 30, cc.p(104, display.height-250), cc.p(0, 0.5), node):setColor(ResLib.COLOR_GREY1)
    local phoneEditBox = UIUtil.addEditBox(nil, cc.size(500, 65), cc.p(250, display.height-250), "6-12位大小写或数字", node)
	phoneEditBox:setAnchorPoint(cc.p(0, 0.5))
	phoneEditBox:setFontColor(cc.c3b(255, 255, 255))
	phoneEditBox:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
	local function phoneEditBoxEvent( eventType,sender )
		if eventType == "began" then
		elseif eventType == "changed" then
		elseif eventType == "return" then
			local str = StringUtils.trim(sender:getText())
			sender:setText(str)
			password = str
			if password ~= "" then
				nextBtn:setEnabled(true)
			else
				nextBtn:setEnabled(false)
			end
		end
	end
	phoneEditBox:registerScriptEditBoxHandler(phoneEditBoxEvent)

	UIUtil.addPosSprite("user/user_loginOrLine.png", cc.p(display.cx,  display.height-285), node, cc.p(0.5, 0))

	local function verifyPwdFunc(  )
		old_pwd = password
		local function response( data )
			if data.code == 0 then
				if curNode then
					curNode:removeFromParent()
					curNode = nil
				end
				curNode = self:buildNewPwd()
			end
		end
		local tabData = {}
		tabData['id'] = Single:playerModel():getId()
		tabData['old_password'] = old_pwd
		XMLHttp.requestHttp("user/update", tabData, response, PHP_POST)
	end
	local label = cc.Label:createWithSystemFont("下一步", "Arial", 32)
	local _img = "common/com_button_img.png"
	nextBtn = UIUtil.controlBtn(_img, _img, _img, label, cc.p(display.width/2, phoneEditBox:getPositionY()-150), cc.size(514,80), verifyPwdFunc, node)
	nextBtn:setTitleColorForState(display.COLOR_BLACK, cc.CONTROL_STATE_NORMAL)
	nextBtn:setTitleColorForState(display.COLOR_BLACK, cc.CONTROL_STATE_HIGH_LIGHTED)
	nextBtn:setTitleColorForState(cc.c3b(160, 160, 160), cc.CONTROL_STATE_DISABLED)
	if password == nil or password == "" then
		nextBtn:setEnabled(false)
	end

	return node
end

function ModiPwd:buildNewPwd(  )

	local node = cc.Node:create()
	node:setPosition(cc.p(0,0))
	self:addChild(node, 10)

	-- topBar
	local function Callback(  )
		if curNode then
			curNode:removeFromParent()
			curNode = nil
		end
		curNode = self:buildCurPwd()
	end
	UIUtil.addTopBar({backFunc = Callback, title = "重设密码", parent = node})

    local nextBtn = nil
    local passWord = ''
    local conPassWord = ''

    UIUtil.addLabelArial("新密码", 30, cc.p(104, display.height-205), cc.p(0, 0.5), node):setColor(cc.c3b(88, 94, 105))
	local PassWEditBox1 = UIUtil.addEditBox(nil, cc.size(500, 65), cc.p(250, display.height-205), "6-12位大小写字母跟数字组合", node)
	PassWEditBox1:setAnchorPoint(cc.p(0, 0.5))
	PassWEditBox1:setFontColor(cc.c3b(255, 255, 255))
	PassWEditBox1:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
	local function phoneEditBoxEvent( eventType,sender )
		if eventType == "began" then
		elseif eventType == "changed" then
		elseif eventType == "return" then
			local str = StringUtils.trim(sender:getText())
			sender:setText(str)
			passWord = str
			if passWord ~= "" and conPassWord ~= "" then
				nextBtn:setEnabled(true)
			else
				nextBtn:setEnabled(false)
			end
		end
	end
	PassWEditBox1:registerScriptEditBoxHandler(phoneEditBoxEvent)

	UIUtil.addPosSprite("user/user_loginOrLine.png", cc.p(display.cx,  display.height-240), node, cc.p(0.5, 0))

	-- 确认密码
	UIUtil.addLabelArial("确认密码", 30, cc.p(104, display.height-315), cc.p(0, 0.5), node):setColor(cc.c3b(88, 94, 105))
	local PassWEditBox2 = UIUtil.addEditBox(nil, cc.size(500, 65), cc.p(250, display.height-315), "请再输入一次密码", node)
	PassWEditBox2:setAnchorPoint(cc.p(0, 0.5))
	PassWEditBox2:setFontColor(cc.c3b(255, 255, 255))
	PassWEditBox2:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
	local function phoneEditBoxEvent( eventType,sender )
		if eventType == "began" then
		elseif eventType == "changed" then
		elseif eventType == "return" then
			local str = StringUtils.trim(sender:getText())
			sender:setText(str)
			conPassWord = str
			if passWord ~= "" and conPassWord ~= "" then
				nextBtn:setEnabled(true)
			else
				nextBtn:setEnabled(false)
			end
		end
	end
	PassWEditBox2:registerScriptEditBoxHandler(phoneEditBoxEvent)

	UIUtil.addPosSprite("user/user_loginOrLine.png", cc.p(display.cx,  display.height-350), node, cc.p(0.5, 0))

	local function verifyPwdFunc(  )
		if passWord == "" or passWord == nil then
			ViewCtrol.showTip({content = "请输入密码"})
			return
		end
		if conPassWord == "" or conPassWord == nil then
			ViewCtrol.showTip({content = "请再输入一次密码"})
			return
		end
		if passWord ~= conPassWord then
			ViewCtrol.showTip({content = "两次输入的密码不一致！"})
			return
		end

		new_pwd = conPassWord
		local function response( data )
			if data.code == 0 then
				if curNode then
					curNode:removeFromParent()
					curNode = nil
				end
				curNode = self:buildFinish()
				Storage.setStringForKey(Storage.PWD_KEY, passWord)
			end
		end
		local tabData = {}
		tabData['id'] = Single:playerModel():getId()
		tabData['password'] = new_pwd
		tabData['old_password'] = old_pwd
		XMLHttp.requestHttp("user/update", tabData, response, PHP_POST)
	end
	local label = cc.Label:createWithSystemFont("确定", "Arial", 32)
	local _img = "common/com_button_img.png"
	nextBtn = UIUtil.controlBtn(_img, _img, _img, label, cc.p(display.width/2, PassWEditBox2:getPositionY()-150), cc.size(514,80), verifyPwdFunc, node)
	nextBtn:setTitleColorForState(display.COLOR_BLACK, cc.CONTROL_STATE_NORMAL)
	nextBtn:setTitleColorForState(display.COLOR_BLACK, cc.CONTROL_STATE_HIGH_LIGHTED)
	nextBtn:setTitleColorForState(cc.c3b(160, 160, 160), cc.CONTROL_STATE_DISABLED)
	if passWord == nil or conPassWord == nil then
		nextBtn:setEnabled(false)
	end

	return node
end

function ModiPwd:buildFinish(  )
	local node = cc.Node:create()
	node:setPosition(cc.p(0,0))
	self:addChild(node, 10)

	-- topBar
	local function Callback(  )
		_modiPwd:removeFromParent()
	end
	UIUtil.addTopBar({backFunc = Callback, title = "重设成功", parent = node})

	local tick = UIUtil.addImageView({image = "common/com_tip_tick.png", touch = false, ah = cc.p(0.5,1), pos = cc.p(display.width/2, display.height-130-204), parent = node})

	UIUtil.addLabelArial("修改成功", 30, cc.p(display.width/2, tick:getPositionY()-tick:getContentSize().height-84), cc.p(0.5, 0.5), node)


	local function verifyPwdFunc(  )
		_modiPwd:removeFromParent()
	end
	local label = cc.Label:createWithSystemFont("返回设置", "Arial", 32)
	local _img = "common/com_button_img.png"
	local nextBtn = UIUtil.controlBtn(_img, _img, _img, label, cc.p(display.width/2, display.height/2-100), cc.size(514,80), verifyPwdFunc, node)
	nextBtn:setTitleColorForState(display.COLOR_BLACK, cc.CONTROL_STATE_NORMAL)
	nextBtn:setTitleColorForState(display.COLOR_BLACK, cc.CONTROL_STATE_HIGH_LIGHTED)
	nextBtn:setTitleColorForState(cc.c3b(160, 160, 160), cc.CONTROL_STATE_DISABLED)

	return node
end

function ModiPwd:ctor(  )
	_modiPwd = self
	self:setSwallowTouches()
	UIUtil.setBgScale(ResLib.MAIN_BG, display.center, self)
	
	curNode = nil
	old_pwd = nil
	new_pwd = nil

	curNode = self:buildCurPwd()
end

function ModiPwd:create(  )
	local modiPwd = ModiPwd.new()
	return modiPwd
end

return ModiPwd