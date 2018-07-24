--
-- Author: Taylor
-- Date: 2017-08-16 17:25:21
--
local ViewBase = require("ui.ViewBase")
local LineInputLayer = class("LineInputLayer", ViewBase)


local default_text = nil
local funcback = nil
local title = nil
local btnTitle = nil

local vSize = display.size
local topy = vSize.height-130
function LineInputLayer:ctor(params)
	default_text = params.text or ""
	funcback = params.func or function() end
	title = params.title or "修改联盟名称"
	btnTitle = params.btStr or "保存"

	self:initData()
	self:initUI()
end

function LineInputLayer:initData()
end

function LineInputLayer:initUI()
	local bg =display.newLayer(cc.c3b(0,0,0), vSize.width, vSize.height):addTo(self)
	bg._isSwallowImg = true
	TouchBack.registerImg(bg)

	 --放弃保存
	local function backHandler()
		self:removeFromParent()
	end
	local function saveCallback()
		if default_text == "" then
			
			ViewCtrol.showTip({content = "文字不能为null!"})
			return
		else
			if not cc.LuaHelp:IsGameName(default_text) or string.len(default_text) > LEN_NAME then
				ViewCtrol.showTip({content = "名称不能超过"..(LEN_NAME/3).."个汉字或"..LEN_NAME.."个字母、数字！"})
				return
			end
		end

		if funcback then 
			funcback(default_text)
		end
		self:removeFromParent()
	end
    UIUtil.addTopBar({backFunc = backHandler, title = title,  menuFont = btnTitle, menuFunc = saveCallback, parent = self})

    local userName = UIUtil.addEditBox( ResLib.COM_EDIT_WHITE, cc.size(display.width-100, 80), cc.p(display.width/2, display.top-200), '请输入昵称', self )
	userName:setMaxLength(LEN_NAME)
	userName:setFontColor(display.COLOR_WHITE)
	userName:setText(default_text)
	local function nameFunc( eventType, sender )
		UIUtil.checkEditText( eventType, sender, {modLen = LEN_NAME, content ="昵称不能超过"..(LEN_NAME/3).."个汉字或"..LEN_NAME.."个字母、数字！", funcBack = function(str)
			default_text = str
			if str ~= "" then
				-- btn:setEnabled(true)
			else
				-- btn:setEnabled(false)
			end
		end } )
	end
	userName:registerScriptEditBoxHandler(nameFunc)


	-- local label = cc.Label:createWithSystemFont("确定", "Marker Felt", 30):setColor(ResLib.COLOR_BLUE)
	-- btn = UIUtil.controlBtn(ResLib.BTN_BLUE_BORDER, ResLib.BTN_BLUE_BORDER, ResLib.BTN_BLUE_BORDER, label, cc.p(display.cx, display.top-450), cc.size(display.width-100,80), sureFunc, self)
	-- btn:setEnabled(false)
end

function LineInputLayer.show(parent, params)
	parent = parent or cc.Director:getInstance():getRunningScene()
	local lineInput = LineInputLayer.new(params)
	parent:addChild(lineInput,StringUtils.getMaxZOrder(parent))
end
return LineInputLayer