local ViewBase = require('ui.ViewBase')
local SetPwd = class('SetPwd', ViewBase)
local LoginCtrol = require("login.LoginCtrol")

local _setPwd = nil

local passWord = nil
local conPassWord = nil
local nextBtn = nil

function SetPwd:buildLayer(  )
	-- addTopBar
	UIUtil.addTopBar({title = "请重新设置密码", parent = self})

	local pwdUI = {	{text = "新登录密码", placeholder = "6-12位大小写字母或数字", tag = 1},
					{text = "确认登录密码", placeholder = "6-12位大小写字母或数字", tag = 2}
				}

	local function phoneEditBoxEvent( eventType,sender )
		if eventType == "began" then
		elseif eventType == "changed" then
		elseif eventType == "return" then
			local str = StringUtils.trim(sender:getText())
			sender:setText(str)
			local tag = sender:getTag()
			print('tag: '..tag)
			if tag == 1 then
				passWord = str
			elseif tag == 2 then
				conPassWord = str
			end
			if passWord ~= "" and conPassWord ~= "" then
				nextBtn:setEnabled(true)
			else
				nextBtn:setEnabled(false)
			end
		end
	end
	local pwdEdit = {}
	for i=1,#pwdUI do
		UIUtil.addLabelArial(pwdUI[i].text, 30, cc.p(104, display.height-130-i*110), cc.p(0, 0.5), self):setColor(ResLib.COLOR_YELLOW1)
		pwdEdit[i] = UIUtil.addEditBox(nil, cc.size(500, 65), cc.p(300, display.height-130-i*110), pwdUI[i].placeholder, self)
		pwdEdit[i]:setTag(pwdUI[i].tag)
		pwdEdit[i]:setAnchorPoint(cc.p(0, 0.5))
		pwdEdit[i]:setFontColor(cc.c3b(255, 255, 255))
		pwdEdit[i]:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
		pwdEdit[i]:registerScriptEditBoxHandler(phoneEditBoxEvent)

		local drawNode = cc.DrawNode:create()
		self:addChild(drawNode)
		local posX = 100
		local posY = display.height-130-i*130
		drawNode:drawSegment(cc.p(posX, posY), cc.p(display.width-posX, posY), 1, cc.c4f(39/255, 39/255, 39/255, 1))
	end

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
		local function response( data )
			if data.code == 0 then
				LoginCtrol.getUserMsg(false)
			end
		end
		local tabData = {}
		tabData['password'] = passWord
		XMLHttp.requestHttp("firstlogin", tabData, response, PHP_POST)
	end
	local label = cc.Label:createWithSystemFont("确定", "Arial", 32)
	local _img = "common/com_button_img.png"
	nextBtn = UIUtil.controlBtn(_img, _img, _img, label, cc.p(display.width/2, pwdEdit[2]:getPositionY()-150), cc.size(514,80), verifyPwdFunc, self)
	nextBtn:setTitleColorForState(display.COLOR_BLACK, cc.CONTROL_STATE_NORMAL)
	nextBtn:setTitleColorForState(display.COLOR_BLACK, cc.CONTROL_STATE_HIGH_LIGHTED)
	nextBtn:setTitleColorForState(cc.c3b(160, 160, 160), cc.CONTROL_STATE_DISABLED)
	if passWord == nil or conPassWord == nil then
		nextBtn:setEnabled(false)
	end

end

function SetPwd:createLayer(  )
	_setPwd = self
	self:setSwallowTouches()
	UIUtil.setBgScale(ResLib.MAIN_BG, display.center, self)

	passWord = ''
	conPassWord = ''
	nextBtn = nil

	self:buildLayer()
end

return SetPwd