local ViewBase = require("ui.ViewBase")
local report = class("report", ViewBase)

function report:ctor(  )
	self:setSwallowTouches()
	self:addTransitAction()
	UIUtil.setBgScale(ResLib.MAIN_BG, display.center, self)
	
	self.content = nil

	self:buildUI()
end

function report:buildUI(  )
	local function Callback(  )
		self:removeTransitAction()
	end
	local function submitCallback(  )
		print("提交")
		local function response( data )
			dump(data)
			if data.code == 0 then
				ViewCtrol.showTick({content = "提交成功"})
				self:removeFromParent()
			end
		end
		local tabData = {}
		tabData["ccontent"] = self.content
		XMLHttp.requestHttp("Complain", tabData, response, PHP_POST)
	end
	-- topBar
    UIUtil.addTopBar({backFunc = Callback, title = "违法举报", menuFont = "提交", menuFunc = submitCallback, parent = self})
    UIUtil.addImageView({touch=false, scale=true, size=cc.size(display.width, display.height-130), pos = cc.p(0, 0), ah = cc.p(0,0), parent=self})

    -- 验证
	local string = '请描述问题！'
	UIUtil.addLabelArial(string, 30, cc.p(50, display.top-200), cc.p(0, 0.5), self)
	
	-- 验证信息
	local textBg = UIUtil.addImageView({touch=false, scale=true, size=cc.size(display.width-100, 160), image=ResLib.COM_EDIT_WHITE, pos=cc.p(50, display.height-250), ah=cc.p(0,1), parent=self})

	local text = UIUtil.createTextField("", 30, cc.size(display.width-100, 150), cc.p(0, 0), textBg)
	text:addEventListener(function ( sender, eventType )
		if eventType == ccui.TextFiledEventType.attach_with_ime then

        elseif eventType == ccui.TextFiledEventType.detach_with_ime then
			print("detach")
			self.content = sender:getString()
        elseif eventType == ccui.TextFiledEventType.insert_text then
			print("insert")
        elseif eventType == ccui.TextFiledEventType.delete_backward then
			print("delete")
        end
	end)

end

return report