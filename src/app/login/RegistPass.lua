local ViewBase = require("ui.ViewBase")
local RegistPass = class("RegistPass", ViewBase)
local LoginCtrol = require("login.LoginCtrol")
local RegistCon = require("login.RegistCon")

local PASS_TARGET = nil
local passWord = nil
local conPassWord = nil

function RegistPass:buildLayer(  )
	
	local function Callback(  )
		self:removeFromParent()
	end
	-- addTopBar
	UIUtil.addTopBar({backFunc = Callback, title = "设置密码", parent = self})

	--背景图片
	UIUtil.addImageView({image = "user/login_bg.png", touch=false, scale=true, size=cc.size(display.width, display.height-130), pos=cc.p(0,0), parent=self})

	-- 背景条
	-- 输入密码
	UIUtil.addLabelArial("密码", 30, cc.p(104, display.height-205), cc.p(0, 0.5), self):setColor(cc.c3b(88, 94, 105))
	local PassWEditBox = UIUtil.addEditBox(nil, cc.size(500, 65), cc.p(250, display.height-205), "6-12位大小写字母跟数字组合", self)
	PassWEditBox:setAnchorPoint(cc.p(0, 0.5))
	PassWEditBox:setFontColor(cc.c3b(255, 255, 255))
	PassWEditBox:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
	local function phoneEditBoxEvent( eventType,sender )
		passWord = sender:getText()
	end
	PassWEditBox:registerScriptEditBoxHandler(phoneEditBoxEvent)

	UIUtil.addPosSprite("user/user_loginOrLine.png", cc.p(display.cx,  display.height-240), self, cc.p(0.5, 0))

	-- 背景条
	-- 确认密码
	UIUtil.addLabelArial("确认密码", 30, cc.p(104, display.height-315), cc.p(0, 0.5), self):setColor(cc.c3b(88, 94, 105))
	local PassWEditBox = UIUtil.addEditBox(nil, cc.size(500, 65), cc.p(250, display.height-315), "请再输入一次密码", self)
	PassWEditBox:setAnchorPoint(cc.p(0, 0.5))
	PassWEditBox:setFontColor(cc.c3b(255, 255, 255))
	PassWEditBox:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
	local function phoneEditBoxEvent( eventType,sender )
		conPassWord = sender:getText()
	end
	PassWEditBox:registerScriptEditBoxHandler(phoneEditBoxEvent)

	UIUtil.addPosSprite("user/user_loginOrLine.png", cc.p(display.cx,  display.height-350), self, cc.p(0.5, 0))

	local function passWordFunc( ... )
		print("密码")
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
		else
			-- 设置密码
			if PASS_TARGET then
				self:setPassWord()
			else
				self:againPassWord()
			end
		end
	end

	local label = cc.Label:createWithSystemFont("确定", "Marker Felt", 30)
	local btn = UIUtil.controlBtn("user/user_commonBarWhite.png", "user/user_commonBarWhite.png", "user/user_commonBarWhite.png", label, cc.p(display.width/2, display.height-446), cc.size(514,80), passWordFunc, self)

	local login_logo = cc.Sprite:create("user/login_icon_logo.png")
	login_logo:setAnchorPoint(cc.p(0.5, 0))
	login_logo:setPosition(display.cx+50, 70)
	self:addChild(login_logo)

end

function RegistPass:setPassWord(  )
	local phoneNumber = LoginCtrol.getPhoneNumber()
	local areaNum = LoginCtrol.getAreaNumber()
	if not cc.LuaHelp:IsPassWord(conPassWord) then
		ViewCtrol.showTip({content = "密码由6-12位大小写字母跟数字组成"})
		return
	else
		local function response( data )
			dump(data)
			if data.code == 0 then
				-- 初始化定时器
				RegistCon.initSchedule(  )
				
				Storage.setStringForKey(Storage.ACCOUNT_KEY, phoneNumber)
				Storage.setStringForKey(Storage.PWD_KEY, conPassWord)
				Storage.setStringForKey(Storage.INTERNAT_KEY, areaNum)

				-- 初始化电话号码
				LoginCtrol.setPhoneNumber(nil)
				
				local editUser = require("login.EditUser")
				local layer = editUser:create()
				self:addChild(layer)
				layer:createLayer()
			end
		end
		local tabData = {}
		tabData["tel"] = phoneNumber
		tabData["pwd"] = conPassWord
		tabData["internatCode"] = areaNum
		tabData["sys"] = LoginCtrol.getPlamfNumber()
		tabData["channel_no"] = Single:paltform():getChannelName()
		tabData["versions_no"] = DZ_VERSION
		XMLHttp.requestHttp(PHP_REGISTER_PWD, tabData, response, PHP_POST)
	end
end

function RegistPass:againPassWord(  )
	local phoneNumber = LoginCtrol.getPhoneNumber()
	local areaNum = LoginCtrol.getAreaNumber()
	if not cc.LuaHelp:IsPassWord(conPassWord) then
		ViewCtrol.showTip({content = "密码由6-12位大小写字母跟数字组成"})
		return
	else
		local function response( data )
			dump(data)
			if data.code == 0 then
				-- 初始化定时器
				RegistCon.initSchedule(  )

				Storage.setStringForKey(Storage.ACCOUNT_KEY, phoneNumber)
				Storage.setStringForKey(Storage.PWD_KEY, conPassWord)
				Storage.setStringForKey(Storage.INTERNAT_KEY, areaNum)

				-- HttpUrl
				Single:paltform():backHttpUrl()
				-- 请求红点数据
				Notice.requestRedData( false )
				LoginCtrol.getAppConfig(function (  )
					LoginCtrol.getUserMsg(true)
				end)
			end
		end
		local tabData = {}
		tabData["pwd"] = conPassWord
		XMLHttp.requestHttp(PHP_FORGET_SET_PWD, tabData, response, PHP_POST)
	end
end

function RegistPass:createLayer( target )
	self:setSwallowTouches()
	--背景图片
	UIUtil.setBgScale(ResLib.MAIN_BG, display.center, self)

	PASS_TARGET = nil
	passWord = nil
	conPassWord = nil

	PASS_TARGET = LoginCtrol.getIsRegist()
	self:buildLayer()
end

return RegistPass