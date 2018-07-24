local ViewBase = require("ui.ViewBase")
local ModifyName = class("ModifyName", ViewBase)
local MineCtrol = require("mine.MineCtrol")

local _modifyName = nil
local tab = {}
	tab['font'] = 'Arial'
	tab['size'] = 30

local mineMsg = {}

local diamond = nil
local diamondLabel = nil
local name_text = nil
local btn = nil

local function Callback(  )
	_modifyName:removeTransitAction()
end

local function sureFunc(  )

	if name_text == "" or name_text == nil then
		ViewCtrol.showTip({content = "请先输入用户名称！"})
		return
	else
		if not cc.LuaHelp:IsGameName(name_text) or string.len(name_text) > LEN_NAME then
			ViewCtrol.showTip({content = "昵称不能超过"..(LEN_NAME/3).."个汉字或"..LEN_NAME.."个字母、数字！"})
			return
		end
	end
	
	local function response( data )
		dump(data)
		if data.code == 0 then
			ViewCtrol.showMsg("修改完成！")
			_modifyName:removeTransitAction()
			-- if tonumber(mineMsg.username_flag) ~= 0 then
			-- 	diamond = diamond - 300
			-- end
			
			MineCtrol.editInfo( {name = name_text} )
			-- Single:playerModel():setPDiaNum( diamond )

			Single:playerModel():setPName(name_text)
			
			local mineEdit = require("mine.MineEdit"):create()
			mineEdit:setUserName(name_text)
		end
	end
	local tabData = {}
	tabData["username"] = name_text
	tabData["id"] = Single:playerModel():getId()
	XMLHttp.requestHttp("user/update", tabData, response, PHP_POST)
end

function ModifyName:buildLayer(  )
	-- topBar
    UIUtil.addTopBar({backFunc = Callback, title = "更改昵称", parent = self})
	
	mineMsg =  MineCtrol.getMineInfo(  )

	-- 昵称

	local userName = UIUtil.addEditBox( ResLib.CLUB_EDIT_BG, cc.size(display.width-100, 80), cc.p(display.width/2, display.top-200), '请输入昵称', self )
	userName:setMaxLength(LEN_NAME)
	userName:setFontColor(display.COLOR_WHITE)
	--[[local function nameFunc( eventType, sender )
		if eventType == "began" then
			print("began")
		elseif eventType == "changed" then
			local str = sender:getText()
			local len = string.len(str)
			-- print("cha str :" .. str)
			-- print("cha len :" .. len)
		elseif eventType == "ended" then
			
		elseif eventType == "return" then
			local str = StringUtils.trim(sender:getText())
			sender:setText(str)
			if str ~= "" then
				btn:setEnabled(true)
				name_text = str
				if not cc.LuaHelp:IsGameName(name_text) or string.len(name_text) > LEN_NAME then
					ViewCtrol.showTip({content = "名称为"..(LEN_NAME/3).."个汉字或"..LEN_NAME.."个字母、数字！"})
				end
			else
				btn:setEnabled(false)
			end
		end
	end--]]
	local function nameFunc( eventType, sender )
		UIUtil.checkEditText( eventType, sender, {modLen = LEN_NAME, content ="昵称不能超过"..(LEN_NAME/3).."个汉字或"..LEN_NAME.."个字母、数字！", funcBack = function(str)
			name_text = str
			if str ~= "" then
				btn:setEnabled(true)
			else
				btn:setEnabled(false)
			end
		end } )
	end
	userName:registerScriptEditBoxHandler(nameFunc)

	-- UIUtil.addLabelArial("消耗：", 30, cc.p(50, display.top-300), cc.p(0, 0.5), self)
	-- UIUtil.addPosSprite("user/icon_zhuanshi.png", cc.p(150, display.top-300), self, cc.p(0.5,0.5))
	-- local price = UIUtil.addLabelArial("", 30, cc.p(200, display.top-300), cc.p(0, 0.5), self)
	-- if tonumber(mineMsg.username_flag) == 0 then
	-- 	price:setString("0")
	-- else
	-- 	price:setString("300")
	-- end

	-- UIUtil.addLabelArial("余额：", 30, cc.p(300, display.top-300), cc.p(0, 0.5), self)
	-- UIUtil.addPosSprite("user/icon_zhuanshi.png", cc.p(400, display.top-300), self, cc.p(0.5,0.5))

	-- diamond = mineMsg.diamonds
	-- diamondLabel = UIUtil.addLabelArial(diamond, 30, cc.p(450, display.top-300), cc.p(0, 0.5), self)

	-- UIUtil.addLabelArial("首次免费修改，之后每次收费修改！", 30, cc.p(50, display.top-350), cc.p(0, 0.5), self)

	local label = cc.Label:createWithSystemFont("确定", "Marker Felt", 30):setColor(ResLib.COLOR_BLUE)
	btn = UIUtil.controlBtn("common/com_button_img.png", "common/com_button_img.png", "common/com_button_img.png", label, cc.p(display.cx, display.top-300), cc.size(display.width-100,80), sureFunc, self)
	btn:setEnabled(false)

end

function ModifyName:createLayer(  )
	_modifyName = self
	_modifyName:setSwallowTouches()
	_modifyName:addTransitAction()

	UIUtil.setBgScale(ResLib.MAIN_BG, display.center, self)

	name_text = ""

	self:buildLayer()
end

return ModifyName