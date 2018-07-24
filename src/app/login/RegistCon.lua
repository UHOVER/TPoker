local ViewBase = require("ui.ViewBase")
local RegistCon = class("RegistCon", ViewBase)
local LoginCtrol = require("login.LoginCtrol")

local CON_TARGET = nil
local phone = nil
local verifyCode = nil
local verifyCodeStr = nil
local areaNum = nil

local verifyEditBox = nil
local refreshBtn = nil 	-- 重新获取
local schedule, myupdate = nil, nil

function RegistCon:buildLayer(  )

	local function Callback(  )
		ViewCtrol.popHint({bgSize = cc.size(display.width-100, 300), content = "验证码短信可能略有延迟,确定返回并重新开始?", sureFunBack = function()
			if schedule then
				schedule:unscheduleScriptEntry(myupdate)
			end
			local register = require("login.RegistScene")
			register.startScene()
		end})
	end

	-- addTopBar
	UIUtil.addTopBar({backFunc = Callback, title = "请输入验证码", parent = self})

	--背景图片
	UIUtil.addImageView({image = "user/login_bg.png", touch=false, scale=true, size=cc.size(display.width, display.height-130), pos=cc.p(0,0), parent=self})

	local tipStr = "验证码短信发送至".. phone
	UIUtil.addLabelArial(tipStr, 25, cc.p(104, display.height-176), cc.p(0,0.5), self, cc.c3b(88, 94, 105))

	verifyEditBox = UIUtil.addEditBox(nil, cc.size(350, 65), cc.p(104, display.height-315), "4位数字", self)
	verifyEditBox:setAnchorPoint(cc.p(0, 0.5))
	verifyEditBox:setFontColor(cc.c3b(255, 255, 255))
	verifyEditBox:setInputMode(cc.EDITBOX_INPUT_MODE_PHONENUMBER)
	local function phoneEditBoxEvent( eventType,sender )
		verifyCodeStr = sender:getText()
	end
	verifyEditBox:registerScriptEditBoxHandler(phoneEditBoxEvent)

	UIUtil.addPosSprite("user/user_loginOrLine.png", cc.p(display.cx,  display.height-350), self, cc.p(0.5, 0))

	-- 验证码提示（暂时）
	local tipsLabel = nil
	if not DZ_MASTER_VERSION then
		tipsLabel = UIUtil.addLabelArial(verifyCode, 25, cc.p(display.cx, display.height*0.6), cc.p(0.5,0.5), self)
	end

	-- 重新获取验证码
	local function refreshCodeFunc(  )
		local HTTP_URL = nil
		if CON_TARGET then
			HTTP_URL = PHP_REGISTER
		else
			HTTP_URL = PHP_FORGET_PWD
		end

		local function response( data )
			-- dump(data)
			if data.code == 0 then
				local code = data.data.reg_code or data.data.pwd_code
				if not DZ_MASTER_VERSION then
					tipsLabel:setString(code)
				end
				self:countdown()
			end
		end
		local tabData = {}
		tabData["tel"] = phone
		tabData["internatCode"] = areaNum
		XMLHttp.requestHttp(HTTP_URL, tabData, response, PHP_POST)
	end
	local label = cc.Label:createWithSystemFont("重新获取", "Arial", 25)
	refreshBtn = UIUtil.controlBtn("user/user_commonBarWhite.png", "user/user_commonBarWhite.png", "user/user_commonBarWhite.png", label, cc.p(display.width-104, display.height-315), cc.size(190,50), refreshCodeFunc, self)
	refreshBtn:setAnchorPoint(cc.p(1, 0.5))



	-- 倒计时
	self:countdown()

	-- 确认验证码
	local function verifyCodeFunc(  )
		print("验证手机号")
		if verifyCodeStr == "" or verifyCodeStr == nil then
			ViewCtrol.showTip({content = "验证码不能为空！"})
			return
		else
			self:conVerifyCode()
		end
	end

	local label = cc.Label:createWithSystemFont("下一步,设置密码", "Arial", 30)
	local btn = UIUtil.controlBtn("user/user_commonBarWhite.png", "user/user_commonBarWhite.png", "user/user_commonBarWhite.png", label, cc.p(display.width/2, display.height-446), cc.size(514,80), verifyCodeFunc, self)

	local login_logo = cc.Sprite:create("user/login_icon_logo.png")
	login_logo:setAnchorPoint(cc.p(0.5, 0))
	login_logo:setPosition(display.cx+50, 70)
	self:addChild(login_logo)

end

function RegistCon:countdown(  )
	
	refreshBtn:setEnabled(false)
	local timer = 59
	refreshBtn:setTitleForState(timer.."S 后可重发", cc.CONTROL_STATE_DISABLED)
	
	local function update( dt )
		timer = timer - dt

		local time = string.format("%02d", timer)
		refreshBtn:setTitleForState(time.."S 后可重发", cc.CONTROL_STATE_DISABLED)
		-- print('ppppp aa')
		if timer < 0 then
			refreshBtn:setTitleForState("重新获取", cc.CONTROL_STATE_NORMAL)
			refreshBtn:setEnabled(true)
			schedule:unscheduleScriptEntry(myupdate)
			schedule = nil
			myupdate = nil
		end
	end
	schedule = cc.Director:getInstance():getScheduler()
	myupdate = schedule:scheduleScriptFunc(update, 1, false)
end

function RegistCon:conVerifyCode(  )
	local HTTP_URL = nil
	if CON_TARGET then
		HTTP_URL = PHP_REGISTER_SURE
	else
		HTTP_URL = PHP_FORGET_SURE_PWD
	end
	local function response( data )
		if data.code == 0 then
			verifyEditBox:setText("")
			verifyCodeStr = nil
			local registPass = require("login.RegistPass")
			local layer = registPass:create()
			self:addChild(layer)
			layer:createLayer(CON_TARGET)
		end
	end
	local tabData = {}
	tabData["code"] = verifyCodeStr
	XMLHttp.requestHttp(HTTP_URL, tabData, response, PHP_POST)
end

function RegistCon:createLayer( phoneNumber, verify, areaCode )
	self:setSwallowTouches()
	--背景图片
	UIUtil.setBgScale(ResLib.MAIN_BG, display.center, self)

	CON_TARGET  = LoginCtrol.getIsRegist()

	phone = nil
	verifyCode = nil
	verifyCodeStr = nil
	areaNum = nil

	verifyEditBox = nil
	refreshBtn = nil 	-- 重新获取
	schedule, myupdate = nil, nil

	phone = phoneNumber
	verifyCode = verify
	areaNum = areaCode

	self:buildLayer()
end

function RegistCon.initSchedule(  )
	refreshBtn:setTitleForState("重新获取", cc.CONTROL_STATE_NORMAL)
	refreshBtn:setEnabled(true)
	if schedule then
		schedule:unscheduleScriptEntry(myupdate)
		schedule = nil
		myupdate = nil
	end
end

return RegistCon