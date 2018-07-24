local MessageWin = class("MessageWin")

function MessageWin.show(msg, delay)
	if not delay then delay = 1 end

	local currScene = cc.Director:getInstance():getRunningScene()

	local tsize = cc.size(370,80)
	local bg = UIUtil.scale9Sprite(cc.rect(60,50,60,50), 'common/com_prompt.png', tsize, cc.p(display.cx, 0), currScene)
	bg:setLocalZOrder(StringUtils.getMaxZOrder(currScene))
	
   	local msgWin = UIUtil.addLabelBold(msg, 30, cc.p(tsize.width/2, tsize.height/2), cc.p(0.5,0.5), nil, cc.c3b(255,255,255))
   	bg:addChild(msgWin)

   	local len = msgWin:getContentSize().width
   	if len > 380 then
   		msgWin:setSystemFontSize(24)
   	end
   	msgWin:setWidth(380)
   	msgWin:setAlignment(cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)

   	local move = cc.MoveTo:create(0.5, cc.p(display.cx, display.height * 0.7))
   	local delay = cc.DelayTime:create(delay)
   	local scale = cc.ScaleTo:create(0.5,0)
	local callfunc = cc.CallFunc:create(function()
		bg:removeFromParent()
		end)
   	local seq = cc.Sequence:create(move, delay, scale, callfunc)

  	bg:runAction(seq)
end

-- @@@@ params
-- listener 回调函数
-- title 	提示标题
-- content 	提示内容
function MessageWin.showTip( params )
	local currScene = cc.Director:getInstance():getRunningScene()
	
	local layer = cc.LayerColor:create(cc.c4b(10, 10, 10, 150))
	layer:setPosition(cc.p(0,0))
	currScene:addChild(layer, StringUtils.getMaxZOrder(currScene))
	local listener = cc.EventListenerTouchOneByOne:create()
	listener:registerScriptHandler(function ( touch, event )
		listener:setSwallowTouches(true)
		return true
	end, cc.Handler.EVENT_TOUCH_BEGAN)
	local dispatcher = cc.Director:getInstance():getEventDispatcher()
	dispatcher:addEventListenerWithSceneGraphPriority(listener, layer)

	local bgSize = cc.size(display.width-100, 400)
	local bgSp1 = UIUtil.addImageView({image = "common/common_notify_bg.png", touch=false, scale=true, size=bgSize, pos=cc.p(display.cx, display.cy), ah =cc.p(0.5, 0.5), parent=layer})
	local sp_w = bgSp1:getContentSize().width
	local sp_h = bgSp1:getContentSize().height
	-- local bgSp2 = UIUtil.addImageView({image = "common/common_notify_bg1.png", touch=false, scale=true, size=bgSize, pos=cc.p(sp_w/2, sp_h/2), ah =cc.p(0.5, 0.5), parent=bgSp1})
	local bgSp3 = UIUtil.addImageView({image = "common/common_notify_bg2.png", touch=false, scale=true, size=bgSize, pos=cc.p(sp_w/2, sp_h/2), ah =cc.p(0.5, 0.5), parent=bgSp1})
	bgSp3:setLocalZOrder(10)
	local font_color = {cc.c3b(208, 193, 104), cc.c3b(202, 203, 205), cc.c3b(184, 117, 88)}

	local contSize = cc.size(bgSize.width-50, bgSize.height-85-130)
	local bgSp = UIUtil.addImageView({image = "common/common_sngpop_little_bg.png", touch=false, scale=true, size=contSize, pos=cc.p(sp_w/2, sp_h-85), ah =cc.p(0.5, 1), parent=bgSp3})

	-- title
	local titleSp =  UIUtil.addLabelArial(params.title or "温馨提示", 35, cc.p(contSize.width/2, contSize.height+15), cc.p(0.5, 0), bgSp)
	UIUtil.addPosSprite("common/comtanhao.png", cc.p(titleSp:getPositionX()-titleSp:getContentSize().width/2-5, contSize.height+19.5), bgSp, cc.p(1,0))

	-- content
	local str = params.content or "提示内容"
	local fsize = params.fontSize or 30
	local strSize = cc.size(contSize.width-50, contSize.height-20)
	local content = cc.Label:createWithSystemFont(str, "Arial", fsize, strSize, cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
	content:setColor(display.COLOR_WHITE)
	content:setPosition(cc.p(contSize.width/2, contSize.height/2))
	content:setAnchorPoint(cc.p(0.5,0.5))
	bgSp:addChild(content)

	-- 确认
	local function sureFunc(  )
		if params.listener then
			layer:removeFromParent()
			params.listener()
		else
			layer:removeFromParent()
		end
	end
	local confirmBtn =  UIUtil.addImageBtn({norImg = "common/sng_confirm_normal.png", selImg = "common/sng_confirm_highlight.png", ah = cc.p(0.5, 0), pos = cc.p(sp_w/2, 25), touch = true, listener = sureFunc, parent = bgSp3})

	bgSp1:setScale(0.5)
	local seq = cc.Sequence:create(cc.ScaleTo:create(0.2, 1.1), cc.ScaleTo:create(0.2, 1))
	bgSp1:runAction(seq)

	return layer
end

-- @@@@ params
-- title 	提示标题
-- content 	提示内容
-- leftListener 	左响应函数
-- rightListener 	右响应函数
-- button {} 
function MessageWin.showTips( params )
	local currScene = cc.Director:getInstance():getRunningScene()
	--背景图片
	local layer = cc.Layer:create()
	layer:setPosition(cc.p(0,0))
	currScene:addChild(layer, StringUtils.getMaxZOrder(currScene))

	local listener = cc.EventListenerTouchOneByOne:create()
	listener:registerScriptHandler(function ( touch, event )
		listener:setSwallowTouches(true)
		return true
	end, cc.Handler.EVENT_TOUCH_BEGAN)
	local dispatcher = cc.Director:getInstance():getEventDispatcher()
	dispatcher:addEventListenerWithSceneGraphPriority(listener, layer)

	local bgSize = cc.size(display.width-100, 400)
	local bgSp1 = UIUtil.addImageView({image = "common/common_notify_bg.png", touch=false, scale=true, size=bgSize, pos=cc.p(display.cx, display.cy), ah =cc.p(0.5, 0.5), parent=layer})
	local sp_w = bgSp1:getContentSize().width
	local sp_h = bgSp1:getContentSize().height
	-- local bgSp2 = UIUtil.addImageView({image = "common/common_notify_bg1.png", touch=false, scale=true, size=bgSize, pos=cc.p(sp_w/2, sp_h/2), ah =cc.p(0.5, 0.5), parent=bgSp1})
	local bgSp3 = UIUtil.addImageView({image = "common/common_notify_bg2.png", touch=false, scale=true, size=bgSize, pos=cc.p(sp_w/2, sp_h/2), ah =cc.p(0.5, 0.5), parent=bgSp1})
	bgSp3:setLocalZOrder(10)
	local font_color = {cc.c3b(208, 193, 104), cc.c3b(202, 203, 205), cc.c3b(184, 117, 88)}

	local contSize = cc.size(bgSize.width-50, bgSize.height-85-130)
	local bgSp = UIUtil.addImageView({image = "common/common_sngpop_little_bg.png", touch=false, scale=true, size=contSize, pos=cc.p(sp_w/2, sp_h-85), ah =cc.p(0.5, 1), parent=bgSp3})

	-- title
	local titleSp =  UIUtil.addLabelArial(params.title or "温馨提示", 35, cc.p(contSize.width/2, contSize.height+15), cc.p(0.5, 0), bgSp)
	UIUtil.addPosSprite("common/comtanhao.png", cc.p(titleSp:getPositionX()-titleSp:getContentSize().width/2-5, contSize.height+19.5), bgSp, cc.p(1,0))

	-- content
	local str = params.content or "提示内容"
	local strSize = cc.size(contSize.width-50, contSize.height-20)
	local content = cc.Label:createWithSystemFont(str, "Arial", 30, strSize, cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
	content:setColor(display.COLOR_WHITE)
	content:setPosition(cc.p(contSize.width/2, contSize.height/2))
	content:setAnchorPoint(cc.p(0.5,0.5))
	bgSp:addChild(content)

	-- 关闭
	local function closeLayer(  )
		if params.leftListener then
			params.leftListener()
		else
			layer:removeFromParent()
		end
	end
	-- size(241, 85)
	local cancelBtn = UIUtil.addImageBtn({norImg = "common/sng_cancel_normal.png", selImg = "common/sng_cancel_highlight.png", ah = cc.p(0, 0), pos = cc.p(50, 25), touch = true, listener = closeLayer, parent = bgSp3})

	-- 确认
	local function sureFunc(  )
		if params.rightListener then
			params.rightListener()
		else
			layer:removeFromParent()
		end
	end
	local confirmBtn =  UIUtil.addImageBtn({norImg = "common/sng_confirm_normal.png", selImg = "common/sng_confirm_highlight.png", ah = cc.p(1, 0), pos = cc.p(sp_w-50, 25), touch = true, listener = sureFunc, parent = bgSp3})

	bgSp1:setScale(0.5)
	local seq = cc.Sequence:create(cc.ScaleTo:create(0.2, 1.1), cc.ScaleTo:create(0.2, 1))
	bgSp1:runAction(seq)

	return layer
end

-- @@ params content 提示内容
-- @@ params delay 展示时间
function MessageWin.showTick( params )
	if not params.delay then params.delay = 1 end

	local currScene = cc.Director:getInstance():getRunningScene()

	local layer = cc.LayerColor:create(cc.c4b(10, 10, 10, 150))
	layer:setPosition(cc.p(0,0))
	currScene:addChild(layer, StringUtils.getMaxZOrder(currScene))

	local bg = UIUtil.addImageView({image = "bg/bg_show_tick.png", touch = false, scale = true, size = cc.size(420, 300), ah = cc.p(0.5,0.5), pos = cc.p(display.cx, display.cy), parent = layer})
	local tick = UIUtil.addImageView({image = "common/com_tip_tick.png", touch = false, ah = cc.p(0.5,0), pos = cc.p(210, 150), parent = bg})

	UIUtil.addLabelArial(params.content or "提示内容", 35, cc.p(210, 50), cc.p(0.5, 0.5), bg):setColor(display.COLOR_WHITE)

   	local seq = cc.Sequence:create(cc.DelayTime:create(params.delay), cc.ScaleTo:create(0.2, 0.7), cc.CallFunc:create(function (  )
   		layer:removeFromParent()
   	end))

  	bg:runAction(seq)

end

--[[
	popHint
	#bgSize
	#content
	#sureFunBack
--]]
function MessageWin.popHint( params )
	local currScene = cc.Director:getInstance():getRunningScene()
	local layer = cc.LayerColor:create(cc.c4b(10, 10, 10, 50))
	layer:setPosition(cc.p(0,0))
	currScene:addChild(layer, StringUtils.getMaxZOrder(currScene))

	local listener = cc.EventListenerTouchOneByOne:create()
	listener:registerScriptHandler(function ( touch, event )
		listener:setSwallowTouches(true)
		return true
	end, cc.Handler.EVENT_TOUCH_BEGAN)
	local dispatcher = cc.Director:getInstance():getEventDispatcher()
	dispatcher:addEventListenerWithSceneGraphPriority(listener, layer)

	local bgSize = params.bgSize
	local bgSp1 = UIUtil.addImageView({image = "common/common_notify_bg.png", touch=false, scale=true, size=bgSize, pos=cc.p(display.cx, display.cy), ah =cc.p(0.5, 0.5), parent=layer})
	local sp_w = bgSp1:getContentSize().width
	local sp_h = bgSp1:getContentSize().height
	-- local bgSp2 = UIUtil.addImageView({image = "common/common_notify_bg1.png", touch=false, scale=true, size=bgSize, pos=cc.p(sp_w/2, sp_h/2), ah =cc.p(0.5, 0.5), parent=bgSp1})
	local bgSp3 = UIUtil.addImageView({image = "common/common_notify_bg2.png", touch=false, scale=true, size=bgSize, pos=cc.p(sp_w/2, sp_h/2), ah =cc.p(0.5, 0.5), parent=bgSp1})
	bgSp3:setLocalZOrder(10)
	local font_color = {cc.c3b(208, 193, 104), cc.c3b(202, 203, 205), cc.c3b(184, 117, 88)}

	local contSize = cc.size(bgSize.width-50, bgSize.height-85-75)
	local bgSp = UIUtil.addImageView({image = "common/common_sngpop_little_bg.png", touch=false, scale=true, size=contSize, pos=cc.p(sp_w/2, sp_h-25), ah =cc.p(0.5, 1), parent=bgSp3})

	-- content
	local str = params.content
	local strSize = cc.size(contSize.width-50, contSize.height-20)
	local content = cc.Label:createWithSystemFont(str, "Arial", 30, strSize, cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
	content:setColor(display.COLOR_WHITE)
	content:setPosition(cc.p(contSize.width/2, contSize.height/2))
	content:setAnchorPoint(cc.p(0.5,0.5))
	bgSp:addChild(content)

	-- 关闭
	-- local funBack = nil
	local function closeLayer(  )
		layer:removeFromParent()
	end
	-- size(241, 85)
	local cancelBtn = UIUtil.addImageBtn({norImg = "common/sng_cancel_normal.png", selImg = "common/sng_cancel_highlight.png", ah = cc.p(0, 0), pos = cc.p(50, 25), touch = true, listener = closeLayer, parent = bgSp3})

	-- 确认
	local function sureFunc(  )
		layer:removeFromParent()
		if params.sureFunBack then
			params.sureFunBack()
		end
	end
	local confirmBtn =  UIUtil.addImageBtn({norImg = "common/sng_confirm_normal.png", selImg = "common/sng_confirm_highlight.png", ah = cc.p(1, 0), pos = cc.p(sp_w-50, 25), touch = true, listener = sureFunc, parent = bgSp3})

	if params.popType == 1 then
		cancelBtn:setVisible(false)
		confirmBtn:setAnchorPoint(cc.p(0.5,0))
		confirmBtn:setPosition(cc.p(sp_w/2, 25))
	elseif params.popType == 3 then
		cancelBtn:setVisible(false)
		confirmBtn:setVisible(false)
		local btn = {}
		local function callBack( sender )
			local tag = sender:getTag()
			if params.sureFunBack[tag] then
				params.sureFunBack[tag]()
			end
			layer:removeFromParent()
		end
		for i=1,#params.text do
			btn[i] = UIUtil.addImageBtn({norImg = "common/surebuy/enter_unselect_btn.png", selImg = "common/surebuy/enter_btn.png", text=params.text[i], ah = cc.p(0, 0), pos = cc.p(25+(i-1)*((sp_w-100)/#params.text+25), 25), scale9=true, size=cc.size((sp_w-100)/#params.text, 80), touch = true, listener = callBack, parent = bgSp3})
			btn[i]:setTag(i)
			btn[i]:setTitleColor(display.COLOR_BLACK)
		end
	end

	bgSp1:setScale(0.5)
	local seq = cc.Sequence:create(cc.ScaleTo:create(0.2, 1.1), cc.ScaleTo:create(0.2, 1))
	bgSp1:runAction(seq)

	return layer
end

return MessageWin