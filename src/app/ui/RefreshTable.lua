local RefreshTable = class("RefreshTable", cc.LayerColor)
local UP_REFRESH = 'UP_REFRESH'
local DOWN_REFRESH = 'DOWN_REFRESH'
local REFRESH_H = 100

function RefreshTable:getTableView()
	return self._tablev
end

function RefreshTable:setRefreshH(refresh)
	REFRESH_H = refresh
end


function RefreshTable:upFinished(refData)
	self:recoveryTable(UP_REFRESH)
end
function RefreshTable:downFinished(refData)
	if refData and #refData > 0 then
		self._nowPage = self._nowPage + 1
	end
	self:recoveryTable(DOWN_REFRESH)
end


function RefreshTable:recoveryTable(tag)
	local posy = self._tablev:minContainerOffset().y

	local containerH1 = self._tablev:getContainer():getContentSize().height
	
	self._tablev:reloadData()

	if tag == DOWN_REFRESH then
		local containerH2 = self._tablev:getContainer():getContentSize().height
		posy = containerH1 - containerH2
	end

	self._tablev:setContentOffset(cc.p(0, posy), true)	
	self._tablev:setBounceable(true)

	if self._ani then
		self._ani:removeFromParent()
		self._ani = nil
	end
end


function RefreshTable:showWaitAni(tag)
	local container = self._tablev:getContainer()

	local posy = self._tablev:minContainerOffset().y - REFRESH_H
	local aniy = container:getContentSize().height + REFRESH_H / 2
	if tag == DOWN_REFRESH then
		posy = REFRESH_H
		aniy =  -posy / 2
	end

	self._isStart = false
	self._tablev:setContentOffset(cc.p(0, posy), true)
	self._tablev:setBounceable(false)

	local tposx = container:getContentSize().width / 2
	self._ani = UIUtil.plistAni(ResLib.EFFECT_REFRESH, cc.p(tposx,aniy), container, 0.3, 'pull_refresh', 6, true)
end



function RefreshTable:initEvent()
	local tablev = self._tablev
	
	local function onTouchBegin(touch, event)
		self._tablev:setBounceable(true)
		if self._ani then return false end

	    self._isStart = false
	    return true
	end
	local function onTouchMoved(touch, event)
	end
	local function onTouchEnded(touch, event)
	    self._isStart = true
	end


	local function scheduleUP()
		if not self._isStart then return end
		if tablev:minContainerOffset().y >= 0 then return end
		local stopy = tablev:minContainerOffset().y - REFRESH_H

		if tablev:getContentOffset().y < stopy then
			self:showWaitAni(UP_REFRESH)
			self._upBack(1)
		end
	end
	local function scheduleDown()
		if not self._isStart then return end
		if tablev:minContainerOffset().y >= 0 then return end

		if tablev:getContentOffset().y > REFRESH_H then
			self:showWaitAni(DOWN_REFRESH)
			self._downBack(self._nowPage + 1)
		end
	end


	local eventl = cc.Layer:create()
    self:addChild(eventl, 4)

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(onTouchBegin,cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED)
    local eventDispatcher = eventl:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, eventl)

    -- DZSchedule.runSchedule(scheduleUP, 1/30, eventl) 
  	DZSchedule.runSchedule(scheduleDown, 1/30, eventl)
end


function RefreshTable:init(nowpage, upBack, downBack)
	self._upBack = upBack
	self._downBack = downBack
	self._nowPage = nowpage

	self:initEvent()	
end

function RefreshTable:ctor(size, pos, dir, parent)
	self._tablev = nil
	self._upBack = nil
	self._downBack = nil
	self._ani = nil

	self._nowPage = 1
	self._refreshPage = 20
	self._isStart = false
	REFRESH_H = 100


	self._tablev = UIUtil.addTableView(size, pos, dir, self)

	parent:addChild(self)	
end

return RefreshTable
