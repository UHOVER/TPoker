--
-- Author: Your Name
-- Date: 2016-10-28 18:01:25
--倒计时逻辑节点
--

--类
local AllGameTimeLogicNode = class("AllGameTimeLogicNode", function ()
    return cc.Node:create()
end)

--处理计时数字
local function mNumber(num)
	local ret = num

	if(ret < 10) then
		ret = "0"..tostring(ret) 
	end
	
	return ret
end

--创建处理时间的逻辑节点
--labelMin-显示分钟的文本控件
--labelSec-显示秒的文本控件
--min-分钟值
--sec-秒值
function AllGameTimeLogicNode:ctor(labelMin, labelSec, min, sec)
	self.m_labelMin = labelMin
	self.m_labelSec = labelSec
	self.m_min = min
	self.m_sec = sec
	self.m_schedulerEntryDelay = nil--延迟开始定时
    self:init()
end


function AllGameTimeLogicNode:init()
	--新生成的cell，有可能从队列里拿出一个带logicNode的cell，所以重置下
	if(self.m_labelMin.logicNode ~= nil) then
		self.m_labelMin.logicNode:setTxtMin(nil)
		self.m_labelMin.logicNode:setTxtSec(nil)
	end


	local scheduler = cc.Director:getInstance():getScheduler()

	self.m_schedulerEntryDelay = scheduler:scheduleScriptFunc(function(dt)
		
		--print("ok time~~~")
		self.m_sec = self.m_sec - 1

		if(self.m_sec < 0) then
			
			self.m_min = self.m_min - 1

			--倒计时结束
			if(self.m_min < 0) then
				--关闭定时器
				if(self.m_schedulerEntryDelay ~= nil) then
					scheduler:unscheduleScriptEntry(self.m_schedulerEntryDelay)
					self.m_schedulerEntryDelay = nil
				end

				self.m_min = 0
				self.m_sec = 0
			else
				self.m_sec = 59
			end
		end

		if(self.m_labelMin ~= nil) then
			self.m_labelMin:setString(mNumber(self.m_min))
			self.m_labelSec:setString(mNumber(self.m_sec))
		end
						
    end, 1, false)

	local function onEvent(event)
		--退出时销毁全局计时器
        if event == "exit" then
        	if(self.m_schedulerEntryDelay ~= nil) then
				scheduler:unscheduleScriptEntry(self.m_schedulerEntryDelay)
				self.m_schedulerEntryDelay = nil
			end 	
        end
    end
    
    self:registerScriptHandler(onEvent)
	
end

function AllGameTimeLogicNode:getMin()
	--print("rMin=="..self.m_min)
	return self.m_min
end

function AllGameTimeLogicNode:getSec()
	--print("rSec=="..self.m_sec)
	return self.m_sec
end

function AllGameTimeLogicNode:setTxtMin(labelMin)
	if(labelMin ~= nil) then
		if(labelMin.logicNode ~= nil) then
			labelMin.logicNode:setTxtMin(nil)
			labelMin.logicNode:setTxtSec(nil)
		end
	end

	self.m_labelMin = labelMin
end

function AllGameTimeLogicNode:setTxtSec(labelSec)
	self.m_labelSec = labelSec
end

function AllGameTimeLogicNode:create(labelH, labelMin, min, sec)
    return AllGameTimeLogicNode.new(labelH, labelMin, min, sec)
end

return AllGameTimeLogicNode
