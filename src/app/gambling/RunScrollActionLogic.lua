local ScrollActionLogic = {}
local myScrollArr = {}
local schedulerEntry = nil
local scrollSpeed = -100

--根据id运行对应view
--tid 对应滚动的层id
--scrollArr 滚动的层容器
function ScrollActionLogic:runScrollAction(scrollArr)
	myScrollArr = {}
	myScrollArr = scrollArr


	local scheduler = cc.Director:getInstance():getScheduler()
	if(schedulerEntry ~= nil) then 
		scheduler:unscheduleScriptEntry(schedulerEntry)
	end
	--self:initScrollImg()
	schedulerEntry = nil
	--循环滚动逻辑
	--local scheduler = cc.Director:getInstance():getScheduler()
	schedulerEntry = scheduler:scheduleScriptFunc(function(dt)
		local p_up = nil
		local p_down = nil
		local cur_upPosY = nil
		local cur_downPosY = nil

	   	for i, tPanel in ipairs(scrollArr) do

	        p_up = ccui.Helper:seekWidgetByName(tPanel, "Panel_up")
			p_down = ccui.Helper:seekWidgetByName(tPanel, "Panel_down")

			cur_upPosY = p_up:getPositionY()
			cur_downPosY = p_down:getPositionY()

			cur_upPosY = cur_upPosY + scrollSpeed
			cur_downPosY = cur_downPosY + scrollSpeed


			if(cur_upPosY <= - p_up:getSize().height) then
				cur_upPosY = p_down:getPositionY() + p_down:getSize().height
			end

			if(cur_downPosY <= - p_down:getSize().height) then
				cur_downPosY = p_up:getPositionY() + p_up:getSize().height
			end

			p_up:setPositionY(cur_upPosY)
			p_down:setPositionY(cur_downPosY)
	    
	    end
    end, 0, false)
end

--初始化所有滚动牌层牌的图片
function ScrollActionLogic:initScrollImg()
	for i, tPanel in ipairs(myScrollArr) do
		local p_up = ccui.Helper:seekWidgetByName(tPanel, "Panel_up")
		local p_down = ccui.Helper:seekWidgetByName(tPanel, "Panel_down")

		local tTag = i%5

		if(tTag == 0) then
			tTag = 1
		end

		p_up:setTag(tTag)

		if((tTag + 1) > 4) then
			tTag = 1
		end

		p_down:setTag(tTag)

		local tImg = nil
		for j = 1, 13 do
			local idx = p_up:getTag()
      		tImg = ccui.Helper:seekWidgetByName(p_up, "Image_26_"..j)
      		tImg:loadTexture(DZConfig.cardName((idx - 1)*13 + j))

      		idx = p_down:getTag()
      		tImg = ccui.Helper:seekWidgetByName(p_down, "Image_26_"..j)
      		tImg:loadTexture(DZConfig.cardName((idx - 1)*13 + j))	
    	end
    end
end

--
function ScrollActionLogic:setActionScrollViewImg()

end


--移除计时器
function ScrollActionLogic:removeScheduler()
	if(schedulerEntry ~= nil) then
		local scheduler = cc.Director:getInstance():getScheduler()
		scheduler:unscheduleScriptEntry(schedulerEntry)
		schedulerEntry = nil
	end
end

return ScrollActionLogic

