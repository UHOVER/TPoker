local LongTouch = {}

-- 长按
-- 触发时间，按多长时间触发
local mTriggerTime = 2

-- 可抖动区域，如果在长按触发前移动超过这个距离则不会触发
local removableDis = 10

-- 取消事件
LongTouch.isCancel = false

-- node 给谁添加这个事件 		parent node父节点添加触摸方法 		longPressHandler 触发回调方法 	triggerTime 可自定义的触发时长
function LongTouch.addTouches( node, parent, longPressHandler, triggerTime )

	print("添加长按方法")
	-- 可自定义的触发时长
	local triggerTime = triggerTime or mTriggerTime

	-- 记录长按时间
	local countTime = nil

	-- 用scheduler计时，记录scheduler的id
	local sid = nil

	-- 开始点击的位置
	local beganPoint = nil

	-- 有没有回调过
	local haveCall = false

	-- 有没有移动（超出可移动范围）
	local isMoved = false

	-- 有没有已添加过监听

	-- 计时方法
	local function countTimeFunc( delay )
		countTime = countTime or 0
		countTime = countTime + delay

		if countTime > triggerTime then
			-- 回调
			if longPressHandler then
				longPressHandler()
			end

			-- 停止计时
			local scheduler = cc.Director:getInstance():getScheduler()
			scheduler:unscheduleScriptEntry(sid)
			sid = nil
			countTime = nil
			haveCall = true
			return
		end
	end

	local function onTouchBegan(touch, event)
		print("onTouchBegan >>>>> 1")
		LongTouch.isCancel = false
		local target = event:getCurrentTarget()
		local pos = target:convertToNodeSpace(touch:getLocation())
		-- local pos = node:getParent():convertTouchToNodeSpace(touch)
		local rect = node:getBoundingBox()
		-- dump(pos)
		-- dump(rect)
		if cc.rectContainsPoint(rect, pos) then
			-- print("onTouchBegan >>>>> 2")
			beganPoint = touch:getLocation()
			-- dump(beganPoint)
			-- 开始计时
			if longPressHandler then
				local scheduler = cc.Director:getInstance():getScheduler()
				sid = scheduler:scheduleScriptFunc(function( delay )
					countTimeFunc(delay)
				end,0.1,false)
			end
			return true
		else
			-- print("onTouchBegan >>>>> 3")
			return false
		end
	end

	local function onTouchMoved(touch, event)
		-- print("onTouchMoved >>>>> 1")
		if haveCall == false and sid then
			-- print("onTouchMoved >>>>> 2")
			local location = touch:getLocation()
			local width = location.x - beganPoint.x
			local height = location.y - beganPoint.y

			-- 超出抖动范围停止计时
			if math.abs(width) > removableDis or math.abs(height) > removableDis then
				-- print("onTouchMoved >>>>> 3")
				local scheduler = cc.Director:getInstance():getScheduler()
				scheduler:unscheduleScriptEntry(sid)
				sid 		= nil
				countTime 	= nil
				isMoved 	= true
				LongTouch.isCancel = true
			end
		end
	end

	local function onTouchEnded(touch, event)
		-- print("onTouchEnded >>>>> 1")
		if sid then
			-- print("onTouchEnded >>>>> 2")
			local scheduler = cc.Director:getInstance():getScheduler()
			scheduler:unscheduleScriptEntry(sid)
			sid = nil
		end

		beganPoint 	= nil
		haveCall 	= false
		isMoved 	= false
	end

	local function onTouchCancelled(touch, event)
	end

	local listener = cc.EventListenerTouchOneByOne:create()
	listener:setSwallowTouches(true)
	listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
	listener:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED)
	listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
	local dispatcher = cc.Director:getInstance():getEventDispatcher()
	dispatcher:addEventListenerWithSceneGraphPriority(listener, parent)
	return node
end

return LongTouch