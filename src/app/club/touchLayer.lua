local TouchLayer = {}

local scheduler = nil
local my_update = nil

local m_startPoint = nil
local m_endPoint = nil

local m_startTime = nil

local isTouch = false
local isMoved = false

local pressTimes = 0
local touchCounts = 0


local function updateSingleDelay(  )
	
end

local function updateDoubleDelay(  )
	
end

local function updateLongprogress(  )
	
end

local function updateFunc(  )
	if isTouch then
		touchCounts = touchCounts + 1
		if touchCounts >= 2 then
			print("双击")
		end
	end
end

function TouchLayer:touchBack( touchNode )
	
	local function onTouchBegan(touch, event)
		m_startPoint = touch:getLocation()
		isTouch = true

		my_update = cc.Director:getInstance():getScheduler():scheduleScriptFunc(updateFunc, 1, false)

		return true
	end

	local function onTouchMoved(touch, event)
		isMoved = true
		local point = touch:getLocation()
	end

	local function onTouchEnded(touch, event)
		isTouch = false
		m_endPoint = touch:getLocation()

		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(my_update)


		-- 连击判断
		if isMoved then
			isMoved = false
			return false
		end

		if touchCounts == 2 then
			touchCounts = 0
		elseif touchCounts == 1 then
			
		end
	end

	local listener = cc.EventListenerTouchOneByOne:create()
	listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
	listener:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED)
	listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
	local dispatcher = cc.Director:getInstance():getEventDispatcher()
	dispatcher:addEventListenerWithSceneGraphPriority(listener, touchNode)
end

return TouchLayer