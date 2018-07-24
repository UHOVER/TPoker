local setClub = class("setClub", function (  )
	return cc.LayerColor:create(cc.c4b(10, 10, 10, 200))
end)

function setClub:ctor(  )
	self.setSp = nil
	self.name = nil
	self.value = nil
	
	self:addUI()
end

function setClub:addUI(  )
	self.setSp = UIUtil.addImageView({image = ResLib.TABLEVIEW_BG, touch=false, scale=true, size=cc.size(display.width-200, 300), ah = cc.p(0.5, 0.5), pos=cc.p(display.cx, display.cy), parent=self})

	local clubName = UIUtil.addEditBox( ResLib.CLUB_EDIT_BG, cc.size(450, 60), cc.p((display.width-200)/2, 200), '俱乐部名称', self.setSp ):setFontColor(cc.c3b(255, 255, 255))
	clubName:setMaxLength(30)
	local function nameFunc( eventType, sender )
		self.name = sender:getText()
	end
	clubName:registerScriptEditBoxHandler(nameFunc)

	local value = UIUtil.addEditBox(ResLib.CLUB_EDIT_BG, cc.size(450, 60), cc.p((display.width-200)/2, 130), "输入0或者1", self.setSp):setFontColor(cc.c3b(255, 255, 255))
	local function valueFunc( eventType, sender )
		self.value = sender:getText()
	end
	value:registerScriptEditBoxHandler(valueFunc)

	local function sureBack(  )
		if self.name == nil or self.name == "" then
			ViewCtrol.showMsg( "不能为空值" )
			return
		end
		if self.value == nil or self.value == "" then
			ViewCtrol.showMsg( "不能为空值" )
			return
		end
		local function response( data )
			if data.code then
				ViewCtrol.showMsg( "修改成功！" )
				self:removeFromParent()
			end
		end
		local tabData = {}
		tabData["club_name"] = self.name
		tabData["value"] = tonumber(self.value)
		XMLHttp.requestHttp("change_club_union", tabData, response, PHP_POST)
	end
	local label = cc.Label:createWithSystemFont("确认", "Marker Felt", 30)
	local close = UIUtil.controlBtn(ResLib.COM_BTN_BG_2, ResLib.COM_BTN_BG_2, ResLib.COM_BTN_BG_2, label, cc.p((display.width-200)/2, 50), cc.size(100,60), sureBack, self.setSp)

	self:touchFun()
end

function setClub:touchFun(  )
	local listener = cc.EventListenerTouchOneByOne:create()
	listener:registerScriptHandler(function ( touch, event )
		listener:setSwallowTouches(true)
		local target = event:getCurrentTarget()
    	local pos = target:convertToNodeSpace(touch:getLocation())

    	local rect = self.setSp:getBoundingBox()
    	if cc.rectContainsPoint(rect, pos) then
    		return false
    	end
		return true
	end, cc.Handler.EVENT_TOUCH_BEGAN)
	listener:registerScriptHandler(function ( touch, event )
		self:removeFromParent()
	end, cc.Handler.EVENT_TOUCH_ENDED)
	local dispatcher = cc.Director:getInstance():getEventDispatcher()
	dispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

return setClub