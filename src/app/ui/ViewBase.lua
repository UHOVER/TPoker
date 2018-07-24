
local ViewBase = class("ViewBase", cc.Layer)

function ViewBase:ctor(app, name)
    print('ViewBase')
end

-- 设置layer是否屏蔽下层触摸
function ViewBase:setSwallowTouches( )
	 -- 触摸屏蔽
	local listener = cc.EventListenerTouchOneByOne:create()
	listener:registerScriptHandler(function ( touch, event )
		listener:setSwallowTouches(true)
		-- print('触摸屏蔽')
		return true
	end, cc.Handler.EVENT_TOUCH_BEGAN)
	local dispatcher = cc.Director:getInstance():getEventDispatcher()
	dispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

-- 添加layer到Table管理
function ViewBase:addLayerOfTable(  )
	-- 清空layer管理表
	LayerManage.clearLayerTable()
	local curLayer = self
    LayerManage.addLayerOfTable(curLayer)
end

-- 添加layer时 过渡动画效果
function ViewBase:addTransitAction(  )
	-- local curLayer = self
 --    LayerManage.addLayerOfTable(curLayer)
	-- LayerManage.addTransitAction()
end

-- 移除layer时 过渡动画效果
function ViewBase:removeTransitAction(  )
	local curLayer = self
	curLayer:removeFromParent()
	-- LayerManage.removeTransitAction()
end

return ViewBase
