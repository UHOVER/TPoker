--
-- Author: Your Name
-- Date: 2016-08-19 11:13:13
--
local ScrollTxtLabelLogic = {}
local schedulerEntry = nil
local myScrollTxtArr = {}
local keyIdx = 1--关键索引
local imgT = nil

--初始化
--scrollArr 滚动的层容器
function ScrollTxtLabelLogic:initScrollTxtLogic(scrollTxtArr, img)
	myScrollTxtArr = {}
	myScrollTxtArr = scrollTxtArr
	imgT = nil
	imgT = img

	schedulerEntry = nil
	--循环滚动逻辑
	local scheduler = cc.Director:getInstance():getScheduler()
	schedulerEntry = scheduler:scheduleScriptFunc(function(dt)
		local num = 1
		local idx = keyIdx
		local isUp = 1--是否向上运动 0下 1上 
		--判断关键层运动方向
		if(myScrollTxtArr[keyIdx]:getPositionY() <= imgT:getPositionY()) then
			isUp = 1
		elseif (myScrollTxtArr[keyIdx]:getPositionY() > imgT:getPositionY()) then
			isUp = 0
		end

		--向上运动逻辑
		if(isUp == 1) then
			local downt = {}--存储向下关联点
			--向上寻找符合条件的层
			while(num <= 9) do
				idx = idx + 1

				if(idx > 10) then
					idx = idx%10
				end

				--print('test=='..idx)
				--处理满足条件的位置
				if(myScrollTxtArr[idx]:getPositionY() < 526 and myScrollTxtArr[idx]:getPositionY() > myScrollTxtArr[keyIdx]:getPositionY()) then
					local nextTidx = nil
					if(idx - 1 < 1) then
						nextTidx = 10
					else
						nextTidx = idx - 1
					end

					myScrollTxtArr[idx]:setPositionY(myScrollTxtArr[nextTidx]:getPositionY() + myScrollTxtArr[nextTidx]:getSize().height)
				else
					table.insert(downt, idx)
				end

				num = num + 1
			end

			--处理特殊节点位置
			local nextDix = nil
			for i = #downt, 1, -1 do
				if((downt[i] + 1) > 10) then
					nextDix = 1
				else
					nextDix = downt[i] + 1
				end
        		myScrollTxtArr[downt[i]]:setPositionY(myScrollTxtArr[nextDix]:getPositionY() - myScrollTxtArr[downt[i]]:getSize().height)
    		end
		--向下运动逻辑
		elseif(isUp == 0) then
			local upt = {}--存储向上关联点
			--向上寻找符合条件的层
			while(num <= 9) do
				idx = idx - 1

				if(idx < 1) then
					idx = 10 - idx
				end

				--print('test=='..idx)
				--处理满足条件的位置
				if(myScrollTxtArr[idx]:getPositionY() > -216 and myScrollTxtArr[idx]:getPositionY() < myScrollTxtArr[keyIdx]:getPositionY()) then		
					local nextTidx = nil
					if(idx + 1 > 10) then
						nextTidx = 1
					else
						nextTidx = idx + 1
					end
					myScrollTxtArr[idx]:setPositionY(myScrollTxtArr[nextTidx]:getPositionY() - myScrollTxtArr[idx]:getSize().height)
				else
					table.insert(upt, idx)
				end

				num = num + 1
			end

			--处理特殊节点位置
			local nextDix = nil
			for i = #upt, 1, -1 do
				if((upt[i] - 1) < 1) then
					nextDix = 10
				else
					nextDix = upt[i] - 1
				end
				myScrollTxtArr[upt[i]]:setPositionY(myScrollTxtArr[nextDix]:getPositionY() + myScrollTxtArr[nextDix]:getSize().height)
    		end
		end
    end, 0, false)
end

--重置颜色
function ScrollTxtLabelLogic:resetScrollTxtColor()
	local zz = nil
	local yy = nil
	for i = 1, 10 do
		myScrollTxtArr[i]:stopAllActions()
		zz = ccui.Helper:seekWidgetByName(myScrollTxtArr[i], "Text_23")
		yy = ccui.Helper:seekWidgetByName(myScrollTxtArr[i], "Text_24")
		zz:setColor(ccc3(255,255,255))
	    yy:setColor(ccc3(255,255,255))
	    zz:setFontSize(30)
	    yy:setFontSize(30)
	end
end

--设置对应的位置
function ScrollTxtLabelLogic:setScrollTxtPosWithIdx(idx)
--[[
	local zz = nil
	local yy = nil
	for i = 1, 10 do
		myScrollTxtArr[i]:stopAllActions()
		zz = ccui.Helper:seekWidgetByName(myScrollTxtArr[i], "Text_23")
		yy = ccui.Helper:seekWidgetByName(myScrollTxtArr[i], "Text_24")
		zz:setColor(ccc3(255,255,255))
	    yy:setColor(ccc3(255,255,255))
	    zz:setFontSize(30)
	    yy:setFontSize(30)
	end
]]
	self:resetScrollTxtColor()

	keyIdx = idx
	myScrollTxtArr[idx]:runAction(cc.Sequence:create(
		cc.MoveTo:create(1, cc.p(myScrollTxtArr[idx]:getPositionX(), imgT:getPositionY())),
        cc.CallFunc:create(
            function(sender)
                local zLabel = ccui.Helper:seekWidgetByName(sender, "Text_23")
                local yLabel = ccui.Helper:seekWidgetByName(sender, "Text_24")
                zLabel:setColor(ccc3(0,255,0))
                yLabel:setColor(ccc3(0,255,0))
                zLabel:setFontSize(40)
                yLabel:setFontSize(40)
            end)
        ))
	--myScrollTxtArr[idx]:runAction(cc.MoveTo:create(1, cc.p(myScrollTxtArr[idx]:getPositionX(), imgT:getPositionY())))
end

--移除计时器
function ScrollTxtLabelLogic:removeScheduler()
	if(schedulerEntry ~= nil) then
		local scheduler = cc.Director:getInstance():getScheduler()
		scheduler:unscheduleScriptEntry(schedulerEntry)
		schedulerEntry = nil
	end
end

return ScrollTxtLabelLogic