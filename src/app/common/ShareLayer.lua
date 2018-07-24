local ViewBase = require("ui.ViewBase")
local ShareLayer = class("ShareLayer", ViewBase)

function ShareLayer:ctor(  )
	self:init()
	self:touchFun()
end

function ShareLayer:init(  )
	
	local color = cc.c3b(165, 157, 157)
	local shareBg = UIUtil.addImageView({image="common/com_bg_share.png", touch=true, scale=true, size=cc.size(750, 300), pos=cc.p(display.cx, 0), ah=cc.p(0.5, 0), parent=self})
	UIUtil.addLabelArial('分享到 ', 35, cc.p(display.cx, 270), cc.p(0.5, 0.5), shareBg):setColor(color)

	local btnPng = {"common/com_icon_chat.png", "common/com_icon_circle.png", "common/com_icon_weibo.png"}
	local btnTitle = {"微信好友", "微信朋友圈", "新浪微博"}
	local btn = {}
	local function shareCallback( sender )
		local tag = sender:getTag()
		print(tag)
	end
	for i=1,3 do
		btn[i] = UIUtil.addImageBtn({norImg = btnPng[i], selImg = btnPng[i], ah = cc.p(0.5,0.5), pos = cc.p(125+(i-1)*250, 190), touch = true, listener = shareCallback, parent = shareBg})
		btn[i]:setTag(i)
		UIUtil.addLabelArial(btnTitle[i], 30, cc.p(125+(i-1)*250, 110), cc.p(0.5, 0.5), shareBg):setColor(color)
	end

	-- line
	UIUtil.addPosSprite("common/com_grey_line.png", cc.p(display.cx, 90), layer, cc.p(0.5, 0.5))

	-- 取消
	local function cancleFunc(  )
		self:removeFromParent()
	end
	UIUtil.addImageBtn({norImg = "common/com_bg_button.png", selImg = "common/com_bg_button.png", text = "取消", ah = cc.p(0.5,0.5), pos = cc.p(display.cx, 40), touch = true, swalTouch = false, scale9 = true, size = cc.size(750, 80), listener = cancleFunc, parent = shareBg}):setTitleColor(color)
end

function ShareLayer:touchFun(  )
	local listener = cc.EventListenerTouchOneByOne:create()
	listener:registerScriptHandler(function ( touch, event )
		listener:setSwallowTouches(true)
		-- print('触摸屏蔽')
		return true
	end, cc.Handler.EVENT_TOUCH_BEGAN)
	listener:registerScriptHandler(function ( touch, event )
		self:removeFromParent()
	end, cc.Handler.EVENT_TOUCH_ENDED)
	local dispatcher = cc.Director:getInstance():getEventDispatcher()
	dispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

return ShareLayer