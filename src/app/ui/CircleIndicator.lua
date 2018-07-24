--
-- Author: Taylor
-- Date: 2016-12-26 14:11:13
--
-- 可以用来当做预加载使用的loading等提示
--
local  CircleIndicator = class("CircleIndicator", function()
	local layer = cc.Layer:create()
	layer:setTouchEnabled(true)
	layer:enableNodeEvents()
	layer:ignoreAnchorPointForPosition(false)
	layer:setAnchorPoint(cc.p(0.5,0.5))
	return layer
end)
local scheduler = cc.Director:getInstance():getScheduler()

--
--- 返回圆形路径
--- r_ 半径， angle_ 角度， centerPt_ type:CCPoint中心店
--- return 以centerPt为中心的点 type:CCPointArray
local function createCirclePath( r_, angle_, centerPt_ )
	local r = r_
	local angle = angle_
	local centerPt = centerPt_
	print("r:"..r, "angle:"..angle, "centerPt:"..centerPt.x.. " "..centerPt.y)
	local allAngle = 360
	-- math.radian2angle(radian)
	local number = allAngle/angle
	local tabelPt = {}
	for i=1,number+1 do
		local nty = math.sin(angle*i*math.pi/180)*r + centerPt.y
		local ntx = math.cos(angle*i*math.pi/180)*r + centerPt.x
		local cpp = cc.p(ntx, nty)
		table.insert(tabelPt, i, cpp)
	end
	return tabelPt
end

function CircleIndicator:ctor(param)
    local param = param or {}
    local color = param.color or cc.c4b(0, 0, 0, 255 * 0.8)
    local size  = param.size or cc.size(display.width, display.height)
    local dotColor = param.dotColor or cc.c3b(255, 255, 255)
    local r 	= param.r or 50
    local isTextVisible = param.isTextVisible or false
    local textColor  = param.textColor 
    local textSize   = param.textSize
   	local ptNumber = param.ptNumber or  14
   	local angle = 360/ptNumber
 	
 	self:setContentSize(size)

	local loadingR = r
	local centerPt = cc.p(0, 0) 
	self.ptTable = createCirclePath(loadingR, angle, centerPt)

	local dotNode = cc.Node:create()
	dotNode:setPosition(size)
	self:addChild(dotNode)
	dotNode:setPosition(cc.p(size.width/2, (size.height-r)/2))
	self.dots = {}

	for i=1,#self.ptTable do
		local dx = self.ptTable[i].x
		local dy = self.ptTable[i].y
		local dr = math.max(8 * loadingR/50, 0)
	
		local circle = cc.DrawNode:create()
		circle:drawSolidCircle(cc.p(0, 0), dr, math.pi, 360, 1, 1, dotColor)
		circle:setPosition(cc.p(dx, dy))
		circle:ignoreAnchorPointForPosition(false)
		circle:setAnchorPoint(cc.p(0, 0))
		circle:setScale(1 - 0.8/(#self.ptTable) * i)
		circle.state = "scale_out"
		circle:setContentSize(cc.size(dr *2, dr*2 ))
		dotNode:addChild(circle)
		
		table.insert(self.dots, circle)
	end


 	if not isTextVisible then 
		local text = CCLabelTTF:create("加载中", "", textSize)
		text:setFontFillColor(textColor)
		text:setPosition(cc.p(dotNode:getPositionX(), dotNode:getPositionY()-r-textSize/2))
		self:addChild(text)
	end
end

function  CircleIndicator:onEnter( )
	print("onEnter")
	-- body
	local dots = self.dots
	local index = #self.ptTable

	local enterframeScheduler = nil

	local maxScale, minScale = 1, 0.2
	local scaleTime = 0.4 --sec
	local scaleFrame = scaleTime * 60
	local scaleAchor = (maxScale - minScale)/scaleFrame   --半径为6 最小1.5
	local update = function ( dt )
		for k,v in pairs(dots) do
			-- print(k,v)
			local circleState = v.state
			if "scale_out" == circleState then --缩小
				self:scaleOut(v, scaleAchor)
			elseif "scale_in" == circleState then --放大
				self:scaleIn(v,scaleAchor)
			end
		end
	end
	enterframeScheduler = scheduler:scheduleScriptFunc(update, 1/40, false)
	self.enterframeScheduler = enterframeScheduler
end

function  CircleIndicator:onExit( )
	scheduler:unscheduleScriptEntry(self.enterframeScheduler)
	self.ptTable = nil
end

function CircleIndicator:scaleOut( v_, scaleAchor_ )
	local circle = v_
	local curScale = circle:getScale()

	local tmpScale = curScale - scaleAchor_
	if tmpScale < 0.2 then 
		scaleAchor_ = 0.2 - curScale
		circle.state = "scale_in"
	end 

	-- circle:setScale(circle:getScale() - scaleAchor_)
	circle:setScale( curScale - scaleAchor_ )

end

function CircleIndicator:scaleIn( v_, scaleAchor_ )
	local circle = v_
	local curScale = circle:getScale()

	local tmpScale = curScale + scaleAchor_
	-- print("temR:"..tmpScale .. "curR:"..curScale)
	if tmpScale > 1 then 
		scaleAchor_ = 1 - curScale
		circle.state = "scale_out"
	end 

	circle:setScale( curScale + scaleAchor_)

end

return CircleIndicator
