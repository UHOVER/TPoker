local ViewBase = require 'ui.ViewBase'
local BuildPoker = class("BuildPoker", ViewBase)
local _cs = nil
local _mimg = nil
local _isBest = false
local _time = 0
local _name = ''
local _maxBlind = 0


local function handleStart(tag, sender)
	if string.len(_name) == 0 then
		ViewCtrol.showMsg('先输入牌局id')
		return
	end
	Storage.setStringForKey(Storage.POKER_NAME_K, _name)
	Storage.setDoubleForKey(Storage.POKER_TIME_K, _time)

	MainCtrol.buildGeneralPoker(_name, _time, _maxBlind, function()end)
end

local function handleSelect()
	_isBest = not _isBest
	_cs:getChildByName('imgSelect1'):setVisible(not _isBest)
	_cs:getChildByName('imgSelect2'):setVisible(_isBest)
end

local function handleSwitch1()
	_mimg:getChildByName('btnSwitch1'):setVisible(false)
	_mimg:getChildByName('btnSwitch2'):setVisible(true)
end
local function handleSwitch2()
	_mimg:getChildByName('btnSwitch1'):setVisible(true)
	_mimg:getChildByName('btnSwitch2'):setVisible(false)
end

local function sliderOne(sender)
	local idx = math.floor(sender:getValue())
	local arr = {1, 2, 5, 10, 25, 50, 100}
	local min = arr[ idx ]
	local max = min * 2
	local score = max * 100
	_mimg:getChildByName('ttfBlind'):setString(min..'/'..max)
	_mimg:getChildByName('ttfScoreCard'):setString(score)

	_mimg:getChildByName('ttfBetText'):setColor(cc.c3b(255,255,255))
	_mimg:getChildByName('ttfAllBet'):setColor(cc.c3b(255,255,255))
	_mimg:getChildByName('ttfScoreText'):setColor(cc.c3b(255,255,255))
	_mimg:getChildByName('ttfNeedBet'):setColor(cc.c3b(255,255,255))
	if min > 10 then
		_mimg:getChildByName('ttfBetText'):setColor(cc.c3b(255,0,255))
		_mimg:getChildByName('ttfAllBet'):setColor(cc.c3b(255,0,255))
		_mimg:getChildByName('ttfScoreText'):setColor(cc.c3b(255,0,255))
		_mimg:getChildByName('ttfNeedBet'):setColor(cc.c3b(255,0,255))
	end

	_maxBlind = max
end



function BuildPoker:createLayer()
    DZAction.easeInMove(self, cc.p(0,0), 0.3, DZAction.MOVE_TO, nil)
	UIUtil.setBgScale(ResLib.GAME_BG, display.center, self)	
	local cs = cc.CSLoader:createNodeWithVisibleSize(ResLib.BUILD_LAYER_CSB)
	self:addChild(cs)
	_cs = cs
	_mimg = _cs:getChildByName('imgMiddle')

	local function btnCancel(tag, sender)
	    DZAction.easeInMove(self, cc.p(0,-display.height), 0.3, DZAction.MOVE_TO, function()
	    	self:removeFromParent()
    	end)
	end

	--edit
	local tedit =  nil
	local function editBack(ctype, sender)
		if ctype == 'began' then
		    tedit:setPlaceHolder('')
		end
		_name = sender:getText()
	end
	tedit = UIUtil.addPlatEdit('牌局名', cc.p(display.cx,display.top*0.88), cc.size(300,63), self, editBack)
	if string.len(_name) ~= 0 then
		tedit:setText(_name)
	end


    --btn
	_cs:getChildByName('btnCancel'):touchEnded(btnCancel)
	_cs:getChildByName('btnSelect'):touchEnded(handleSelect)
	_cs:getChildByName('btnStartGame'):touchEnded(handleStart)
	_mimg:getChildByName('btnSwitch1'):touchEnded(handleSwitch1)
	_mimg:getChildByName('btnSwitch2'):touchEnded(handleSwitch2)


	--设置
	_cs:getChildByName('imgSelect1'):setVisible(not _isBest)
	_cs:getChildByName('imgSelect2'):setVisible(_isBest)
	_mimg:getChildByName('btnSwitch2'):setVisible(false)


    local imgs1 = {"common/com_progress1.png", "common/com_progressbg1.png", 'icon/icon_redThumb.png'}
    local tslider1 = UIUtil.addSlider(imgs1, cc.p(display.cx,184.5), _mimg, sliderOne, 1.1, 7.9)
    tslider1:setScale(0.6)
    tslider1:setAnchorPoint(0.5,0.5)

    local layer, ttime = DZUi.addUISlider(_cs, DZUi.SLIDER_SIX, cc.p(display.cx,440), function(val)
    	_time = val
	end, _time)
	_time = ttime
end


function BuildPoker.startBuild()
	_time = Storage.getDoubleForKey(Storage.POKER_TIME_K)
	_name = Storage.getStringForKey(Storage.POKER_NAME_K)
	_isBest = false
	_maxBlind = 2

    local runScene = cc.Director:getInstance():getRunningScene()
	local build = BuildPoker:create()
	UIUtil.shieldLayer(build, nil)

	build:setPositionY(-display.height)
	build:createLayer()

    runScene:addChild(build, StringUtils.getMaxZOrder(runScene))
end


function BuildPoker:ctor()
end

return BuildPoker