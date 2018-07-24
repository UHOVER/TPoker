local ViewBase = require("ui.ViewBase")
local EditCircleName = class("EditCircleName", ViewBase)
local MineCtrol = require("mine.MineCtrol")

local _editCircleName = nil

local circleTab = {}

local circle_name = nil

local function Callback(  )
	_editCircleName:removeTransitAction()
end

local function saveNameFunc(  )
	if circle_name == nil or circle_name == "" then
		ViewCtrol.showTip({content = "请先输入圈子名称！"})
		return
	else
		if not cc.LuaHelp:IsGameName(circle_name) or string.len(circle_name) > LEN_NAME then
			ViewCtrol.showTip({content = "昵称不能超过"..(LEN_NAME/3).."个汉字或"..LEN_NAME.."个字母、数字！"})
			return
		end
	end

	local function response( data )
		dump(data)
		if data.code == 0 then
			MineCtrol.editCircleInfo({name = circle_name})
			_editCircleName:removeTransitAction()
			
			local CircleInfo = require("mine.CircleInfo")
			CircleInfo.updateCircleInfo(circle_name)
		end
	end
	local tabData = {}
	tabData["circle_id"] = circleTab.id
	tabData["circle_nickname"] = circle_name
	XMLHttp.requestHttp("modifyCircleName", tabData, response, PHP_POST)

end

function EditCircleName:buildLayer(  )
	-- addTopBar
	UIUtil.addTopBar({backFunc = Callback, title = "圈子名称", menuFont = "保存", menuFunc = saveNameFunc, parent = self })

	UIUtil.addLabelArial("为圈子起一个名字", 30, cc.p(50, display.height - 170), cc.p(0, 0.5), self)

	local text = UIUtil.addEditBox( ResLib.COM_EDIT_WHITE, cc.size(display.width-100, 80), cc.p(display.cx, display.height -250), '输入圈子名称', self )
	-- text:setFontColor(display.COLOR_WHITE)
	text:setMaxLength(LEN_NAME)
	--[[local function textFunc( eventType, sender )
		if eventType == "began" then
			print("began")
		elseif eventType == "changed" then
			local str = sender:getText()
			local len = string.len(str)
			
		elseif eventType == "ended" then
			
		elseif eventType == "return" then
			local str = StringUtils.trim(sender:getText())
			sender:setText(str)
			circle_name = str
			if str ~= "" then
				if not cc.LuaHelp:IsGameName(circle_name) or string.len(circle_name) > LEN_NAME then
					ViewCtrol.showTip({content = "名称为"..(LEN_NAME/3).."个汉字或"..LEN_NAME.."个字母、数字！"})
				end
			end
		end
	end--]]
	local function textFunc( eventType, sender )
		UIUtil.checkEditText( eventType, sender, {modLen = LEN_NAME, content ="昵称不能超过"..(LEN_NAME/3).."个汉字或"..LEN_NAME.."个字母、数字！", funcBack = function(str)
			circle_name = str
		end })
	end
	text:registerScriptEditBoxHandler(textFunc)

end

function EditCircleName:createLayer( data )
	_editCircleName = self
	_editCircleName:setSwallowTouches()
	_editCircleName:addTransitAction()
	UIUtil.setBgScale(ResLib.MAIN_BG, display.center, self)

	circleTab = data

	self:buildLayer()

end

return EditCircleName