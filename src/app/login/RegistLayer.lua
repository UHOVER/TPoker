--[[
**************************************************************************
* NAME OF THE BUG : YDWX_DZ_CHENTAO_BUG _20160629 _001
* DESCRIPTION OF THE BUG : Registration password is not confirmed
* MODIFIED BY : 王礼宁
* DATE :2016-7-11
*************************************************************************/
]]

local ViewBase = require("ui.ViewBase")
local RegistLayer = class("RegistLayer", ViewBase)
local LoginCtrol = require("login.LoginCtrol")

local REGIST_TARGET = nil
local phoneNumber = nil
local areaLabel = nil
local areaNum = nil

function RegistLayer:buildLayer(  )

	local title = nil
	local tipStr = nil
	local agreeTag = 1
	local nextBtn = nil
	
	if REGIST_TARGET then
		title = "注册"
		tipStr = "1200"
	else
		title = "忘记密码"
		tipStr = nil
	end

	-- YDWX_DZ_ZHANGMENG_BUG _20160608 _005
	local function Callback(  )
		phoneNumber = nil
		local login = require("login.LoginScene")
		login.startScene()
	end

	-- addTopBar
	UIUtil.addTopBar({backFunc = Callback, title = title, parent = self})

	--背景图片
	UIUtil.addImageView({image = "user/login_bg.png", touch=false, scale=true, size=cc.size(display.width, display.height-130), pos=cc.p(0,0), parent=self})
	if tipStr then
		local tip1 = UIUtil.addLabelArial("现在注册可获得", 30, cc.p(104, display.height-176), cc.p(0,0.5), self)
		local tip2 = UIUtil.addLabelArial(tipStr, 30, cc.p(tip1:getPositionX()+tip1:getContentSize().width, display.height-176), cc.p(0,0.5), self):setColor(ResLib.COLOR_BLUE)
		local tip3 = UIUtil.addLabelArial("记分牌", 30, cc.p(tip2:getPositionX()+tip2:getContentSize().width, display.height-176), cc.p(0,0.5), self)
	end
	
	areaNum = "86"
	local function addAreaNum(  )
		local function callBack( code )
			areaNum = code
			areaLabel:setString("+"..code)
		end
		local currScene = cc.Director:getInstance():getRunningScene()
		local area = require('login.AreaNum')
		local layer = area:create()
		layer:setName("AreaNum")
		currScene:addChild(layer, StringUtils.getMaxZOrder(currScene))
		layer:createLayer(callBack)
	end
	local bg = UIUtil.addImageBtn({norImg = ResLib.COM_OPACITY0, selImg = ResLib.COM_OPACITY0, scale9 = true, size = cc.size(100, 65), ah = cc.p(0,0.5), pos = cc.p(104, display.height-315), touch = true, swalTouch = false, listener = addAreaNum, parent = self})
	areaLabel =  UIUtil.addLabelArial("+"..areaNum, 30, cc.p(5, 30), cc.p(0, 0.5), bg)
	UIUtil.addPosSprite("user/icon_sanjiao.png", cc.p(80, 30), bg, cc.p(0, 0.5))

	local phoneEditBox = UIUtil.addEditBox(nil, cc.size(500, 65), cc.p(204, display.height-315), "请输入手机号", self)
	phoneEditBox:setAnchorPoint(cc.p(0, 0.5))
	phoneEditBox:setFontColor(cc.c3b(255, 255, 255))
	phoneEditBox:setInputMode(cc.EDITBOX_INPUT_MODE_PHONENUMBER)
	local function phoneEditBoxEvent( eventType,sender )
		if eventType == "began" then
		elseif eventType == "changed" then
		elseif eventType == "return" then
			local str = StringUtils.trim(sender:getText())
			sender:setText(str)
			phoneNumber = str
			if phoneNumber ~= "" and agreeTag == 1 then
				nextBtn:setEnabled(true)
			else
				nextBtn:setEnabled(false)
			end
		end
	end
	phoneEditBox:registerScriptEditBoxHandler(phoneEditBoxEvent)
	local phone = LoginCtrol.getPhoneNumber()
	if REGIST_TARGET then
		if phone then
			phoneNumber = phone
			phoneEditBox:setText(phone)
		end
	end

	UIUtil.addPosSprite("user/user_loginOrLine.png", cc.p(display.cx,  display.height-350), self, cc.p(0.5, 0))


	if REGIST_TARGET then
		local function checkBoxFunc( sender, eventType )
			if eventType == 0 then
				agreeTag = 1
				if agreeTag == 1 then
					if phoneNumber ~= nil and phoneNumber ~= "" then
						nextBtn:setEnabled(true)
					end
				end
			else
				agreeTag = 0
				if agreeTag == 0 then
					nextBtn:setEnabled(false)
				end
			end
		end
		local checkBox = UIUtil.addCheckBox({checkBg='user/check_box_1.png', checkBtn='user/check_box_2.png', pos = cc.p(150, display.height-400), checkboxFunc = checkBoxFunc, parent = self})
		checkBox:setAnchorPoint(cc.p(0,0.5))
		checkBox:setSelected(true)

		--底部许可label
		local function protocolFunc(  )
			local protocol = require("login.protocol")
			local layer = protocol:create()
			self:addChild(layer, 10)
			layer:createLayer()
		end
		local bg = UIUtil.addImageBtn({norImg = ResLib.COM_OPACITY0, selImg = ResLib.COM_OPACITY0, scale9 = true, size = cc.size(300, 60), ah = cc.p(0,0.5), pos = cc.p(210, display.height-400), touch = true, swalTouch = false, listener = protocolFunc, parent = self})
		UIUtil.addLabelArial('同意《超级扑克软件许可及服务协议》', 28, cc.p(0, 27), cc.p(0,0.5), bg, ResLib.COLOR_GREY )
	end

	local function verifyPhoneFunc( ... )
		print("验证手机号")
		if phoneNumber == "" or phoneNumber == nil then
			ViewCtrol.showTip({content = "请输入手机号！"})
			return
		end
		-- if not cc.LuaHelp:IsPhoneNumber(phoneNumber) then
		-- if not StringUtils.isPhoneNumber(phoneNumber) then
		-- 	ViewCtrol.showTip({parent = self, content = "您输入的是一个无效的手机号码!"})
		-- 	return
		-- else
		-- 	self:getVerifyCode()
		-- end
		self:getVerifyCode()
	end

	local label = cc.Label:createWithSystemFont("下一步,验证手机号", "Arial", 32)
	local _img = "common/com_button_img.png"
	-- nextBtn = UIUtil.controlBtn("user/user_commonBarWhite.png", "user/user_commonBarWhite.png", "user/user_commonBarWhite.png", label, cc.p(display.width/2, display.height/2+100), cc.size(514,80), verifyPhoneFunc, self)
	nextBtn = UIUtil.controlBtn(_img, _img, _img, label, cc.p(display.width/2, display.height/2+100), cc.size(514,80), verifyPhoneFunc, self)
	nextBtn:setTitleColorForState(display.COLOR_WHITE, cc.CONTROL_STATE_NORMAL)
	nextBtn:setTitleColorForState(display.COLOR_WHITE, cc.CONTROL_STATE_HIGH_LIGHTED)
	nextBtn:setTitleColorForState(cc.c3b(82, 146, 244), cc.CONTROL_STATE_DISABLED)
	if phoneNumber == nil or phoneNumber == "" then
		nextBtn:setEnabled(false)
	end

	if REGIST_TARGET then
		UIUtil.addLabelArial('您的手机号码将作为登录账号', 28, cc.p(display.width/2, nextBtn:getPositionY()-80), cc.p(0.5, 0.5), self):setColor(ResLib.COLOR_GREY)
	end

	local login_logo = cc.Sprite:create("user/login_icon_logo.png")
	login_logo:setAnchorPoint(cc.p(0.5, 0))
	login_logo:setPosition(display.cx+50, 70)
	self:addChild(login_logo)
	
end

function RegistLayer:getVerifyCode(  )

	local HTTP_URL = nil
	if REGIST_TARGET then
		HTTP_URL = PHP_REGISTER
	else
		HTTP_URL = PHP_FORGET_PWD
	end

	local function response( data )
		if data.code == 0 then

			LoginCtrol.setPhoneNumber(phoneNumber)
			LoginCtrol.setAreaNumber(areaNum)

			local tmpTab = {}
			tmpTab = data.data
			local code = tmpTab.reg_code or tmpTab.pwd_code
			local registCon = require("login.RegistCon")
			local layer = registCon:create()
			self:addChild(layer)
			layer:createLayer( phoneNumber, code, areaNum)
		end
	end
	local tabData = {}
	tabData["tel"] = phoneNumber
	tabData["internatCode"] = areaNum
	XMLHttp.requestHttp(HTTP_URL, tabData, response, PHP_POST)
end

function RegistLayer:createLayer( target )
	self:setSwallowTouches()
	UIUtil.setBgScale(ResLib.MAIN_BG, display.center, self)
	REGIST_TARGET = LoginCtrol.getIsRegist(  )
	phoneNumber = nil
	areaLabel = nil
	areaNum = nil
	self:buildLayer()
end

return RegistLayer

--[[
**************************************************************************
* NAME OF THE BUG : YDWX_DZ_CHENTAO_BUG _20160629 _001
* DESCRIPTION OF THE BUG : Registration password is not confirmed
* MODIFIED BY : 王礼宁
* DATE :2016-7-11
*************************************************************************/
]]