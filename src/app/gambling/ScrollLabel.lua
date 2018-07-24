--
-- Author: Your Name
-- Date: 2016-08-18 16:27:21
--
--ScrollLabel类
local ScrollLabel = class("ScrollLabel", function ()
    return cc.Node:create()
end)

function ScrollLabel:ctor(mylabel)
	self.m_label = mylabel--tolua.cast(mylabel, "TextAtlas") --显示的label
	self.m_currValue = 0--当前值
	self.m_targetValue = 0--目标值
	self.m_offsetValue = nil--每次迭代差值
	self.m_scrollTime = 0.1--滚动需要持续时间
	self.m_totalStep = 30--每秒60帧
	self.m_schedulerEntry = nil--定时器
	self.m_schedulerEntryUpdateUI = nil--延迟开始定时
	self.m_isHaveBBH = false--是否带有百分号
	self.m_BFHstr = '/'--百分号符号
	self.m_schedulerEntryDelay = nil--延迟开始定时
	self.m_currStr = '0'--延迟开始定时
    self:init()
end

function ScrollLabel:init()
	self.m_currValue = tonumber(self.m_label:getString())
	--self:removeScheduler()
	--循环滚动数字逻辑
	local scheduler = cc.Director:getInstance():getScheduler()
	
	self.m_schedulerEntryDelay = scheduler:scheduleScriptFunc(function(dt)
		
		self.m_schedulerEntryUpdateUI = scheduler:scheduleScriptFunc(function(dt)
			if(self.m_label ~= nil) then
				self.m_label:setString(self.m_currStr)
			end
		end, 0, false)
		
		self.m_schedulerEntry = scheduler:scheduleScriptFunc(function(dt)
						
			if(self.m_targetValue == self.m_currValue) then
				return
			end

			self.m_currValue = self.m_currValue + self.m_offsetValue

			if(self.m_offsetValue > 0) then
				if(self.m_currValue >= self.m_targetValue) then
					self.m_currValue = self.m_targetValue
					--self:removeScheduler()
				end
			elseif(self.m_offsetValue < 0) then
				if(self.m_currValue <= self.m_targetValue) then
					self.m_currValue = self.m_targetValue
					--self:removeScheduler()
				end
			end

			--带百分号做百分号显示处理
			if(self.m_isHaveBBH) then

	--[[
				local fnailStr = ''--最终串
				--先查位数
				local len = string.len(tostring(self.m_currValue))
				--大于3位做处理
				if(len > 3) then
					--计算需要循环几次处理千分位
					local fnum = math.floor(len/3)
					--如果为0，位数减1
					if(len - fnum*3 == 0) then
						fnum = fnum - 1
					end

					local numStr = tostring(self.m_currValue)
					numStr = string.reverse(numStr)
					
					local spos = nil--开始截取位置
					local epos = nil--结束截取位置

					for n = 1, fnum do					
						spos = (n-1)*3 + 1
						epos = n*3
						fnailStr = fnailStr..string.sub(numStr, spos ,epos)..self.m_BFHstr

						if(n == fnum) then
							fnailStr = fnailStr..string.sub(numStr, epos + 1 ,len)
						end		
					end

					fnailStr = string.reverse(fnailStr)
				else
					fnailStr = tostring(self.m_currValue)
				end

				self.m_label:setString(fnailStr)
	]]


				local num = self.m_currValue
			    local str1 =""
			    local str = tostring(num)
			    local strLen = string.len(str)
			    local deperator = self.m_BFHstr
			    if deperator == nil then
			        deperator = ","
			    end
			    deperator = tostring(deperator)
			        
			    for i=1,strLen do
			        str1 = string.char(string.byte(str,strLen+1 - i)) .. str1
			        if math.mod(i,3) == 0 then
			            --下一个数 还有
			            if strLen - i ~= 0 then
			                str1 = deperator..str1
			            end
			        end
			    end
			     
				--self.m_label:setString(str1)
				self.m_currStr = str1
		
				--self.m_label:setString(tostring(self.m_currValue)..'/')
			
			--不带百分号直接赋值
			else
				--self.m_label:setString(tostring(self.m_currValue))
				self.m_currStr = tostring(self.m_currValue)
			end

	    end, 0, false)
		
		if(self.m_schedulerEntryDelay ~= nil) then
			scheduler:unscheduleScriptEntry(self.m_schedulerEntryDelay)
			self.m_schedulerEntryDelay = nil
		end
    end, 0.1, false)


	
end

--设置最新值
function ScrollLabel:setValue(value)
	self.m_targetValue = tonumber(value)

	--如果目标值跟的当前值相等，直接返回
	if(self.m_targetValue == self.m_currValue) then
		return
	end
	--print("self.m_targetValue="..self.m_targetValue)
	--print("self.m_currValue="..self.m_currValue)
	local offsetValue = self.m_targetValue - self.m_currValue

	if( math.abs(offsetValue) > self.m_scrollTime * self.m_totalStep ) then
		self.m_offsetValue = math.floor(offsetValue/(self.m_scrollTime * self.m_totalStep))
	else
		if(offsetValue > 0) then
			self.m_offsetValue = 1
		else
			self.m_offsetValue = -1
		end
	end
end

--获得最新值
function ScrollLabel:getValue()
	return self.m_targetValue
end

--移除定时器
function ScrollLabel:removeScheduler()
	local scheduler = cc.Director:getInstance():getScheduler()

	if(self.m_schedulerEntry ~= nil) then
		scheduler:unscheduleScriptEntry(self.m_schedulerEntry)
		self.m_schedulerEntry = nil
	end
	
	if(self.m_schedulerEntryUpdateUI ~= nil) then
		scheduler:unscheduleScriptEntry(self.m_schedulerEntryUpdateUI)
		self.m_schedulerEntryUpdateUI = nil
	end

	if(self.m_schedulerEntryDelay ~= nil) then
		scheduler:unscheduleScriptEntry(self.m_schedulerEntryDelay)
		self.m_schedulerEntryDelay = nil
	end
end

--设置是否带有百分号
function ScrollLabel:setISBFH(isBFH)
	self.m_isHaveBBH = isBFH
end

function ScrollLabel:create(mylabel)
    return ScrollLabel.new(mylabel)
end


return ScrollLabel