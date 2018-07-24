local GMttBuy = {}
local _data = {}
local _cs = nil
local _color1 = cc.c3b(143,199,222)
local _color2 = cc.c3b(255,255,255)

local function handleAgain()
	_cs._removeWindow()
	SocketCtrol.mttBuyScore(1, function()
		-- GData.subAgainTimes()
	end)
end

local function handleAdd()
	_cs._removeWindow()
	SocketCtrol.mttBuyScore(2, function()
		-- GData.subAddTimes()
	end)
end

local function handleGiveUp()
	_cs._removeWindow()
	SocketCtrol.mttBuyScore(0, function()end)
end

local function handleClose()
end



local function commonUI(img1, timesText, ccps)
	local bgs = _cs:getContentSize()
	local cx = bgs.width / 2

	local ty1 = ccps[1]
	local ty2 = ccps[2]
	local ty3 = ccps[3]
	local ty4 = ccps[4]
	local ty5 = ccps[5]

	local text = '在下一局开始时, 将为您补充所购记分牌'
	UIUtil.addLabelBold(text, 32, cc.p(cx,ty1), cc.p(0.5,0.5), _cs, _color1)

	local surplus = '账户余额：'.._data['surplusBet']
	UIUtil.addLabelBold(surplus, 32, cc.p(48,ty2), cc.p(0,0.5), _cs, _color1)
	local service = '服务费：'.._data['serviceFee']
	UIUtil.addLabelBold(service, 32, cc.p(425,ty2), cc.p(0,0.5), _cs, _color1)

	UIUtil.addLabelBold(timesText, 39, cc.p(cx-70,ty3), cc.p(0,0.5), _cs, _color2)
	UIUtil.addLabelArial(_data['initScore'], 82, cc.p(cx,ty4), cc.p(0.5,0.5), _cs, _color2)
	UIUtil.addLabelBold('费用：'.._data['entryFee'], 30, cc.p(cx,ty5), cc.p(0.5,0.5), _cs, _color2)

	UIUtil.addPosSprite(img1, cc.p(249,ty3), _cs, cc.p(1,0.5))
end



local function commonData()
	_data = {}
	local surplusBet = Single:playerModel():getPBetNum()
	_data['surplusBet'] = surplusBet
end


--重购
function GMttBuy.showAgainBuy()
	commonData()
	_data['initScore'] = GData.getMttInitScore()
	_data['entryFee'] = GData.getMttEntryFee()
	_data['serviceFee'] = GData.getMttEntryFee() / 10

	_cs = GWindow.getWindowOne(handleClose)
	_cs:getChildByName('btnSure'):touchEnded(handleAgain)
	_cs:getChildByName('btnGiveUp'):touchEnded(function()end)
	_cs:getChildByName('ttfTitleWindow'):setString('重购')
	_cs:getChildByName('btnSure'):setTitleText('确定重购')


	local ccps = {435, 385, 320, 240, 160}
	local times = GData.getAgainTimes()
	commonUI('mtt/mtt_R.png', '重购  ('..times..'次)', ccps)
end


--增购
function GMttBuy.showAddBuy()
	commonData()
	local mul = GData.getMttBuyMul()
	_data['initScore'] = GData.getMttInitScore() * mul
	_data['entryFee'] = GData.getMttEntryFee() 
	_data['serviceFee'] = GData.getMttEntryFee() / 10

	_cs = GWindow.getWindowOne(handleClose)
	_cs:getChildByName('btnSure'):touchEnded(handleAdd)
	_cs:getChildByName('btnGiveUp'):touchEnded(function()end)
	_cs:getChildByName('ttfTitleWindow'):setString('增购')
	_cs:getChildByName('btnSure'):setTitleText('确定增购')

	
	local ccps = {435, 385, 320, 240, 160}
	local times = GData.getAddTimes()
	commonUI('mtt/mtt_A.png', '增购  ('..times..'次)', ccps)
end


--复活重购
function GMttBuy.reviveAgainBuy()
	commonData()
	_data['initScore'] = GData.getMttInitScore()
	_data['entryFee'] = GData.getMttEntryFee()
	_data['serviceFee'] = GData.getMttEntryFee() / 10
	local start = 25
	local btnText = '放弃('..start..'s)'

	_cs = GWindow.getWindowOne(handleClose)
	local btnSure = _cs:getChildByName('btnSure')
	local btnGiveUp = _cs:getChildByName('btnGiveUp')
	btnSure:touchEnded(handleAgain)
	btnGiveUp:touchEnded(handleGiveUp)
	_cs:getChildByName('ttfTitleWindow'):setString('您已被淘汰, 是否重购复活')

	--倒计时
	local tnode = cc.Node:create()
	_cs:addChild(tnode)
	local function scheduleOne()
		if start < 0 then return end

		btnText = '放弃('..start..'s)'
		_cs:getChildByName('btnGiveUp'):setTitleText(btnText)
		start = start - 1

		--放弃
		if start == 0 then
			handleGiveUp()
		end
	end
	
	DZSchedule.runSchedule(scheduleOne, 1, tnode)
	scheduleOne()

	btnSure:setPositionX(475)
	btnGiveUp:setPositionX(175)

	local ccps = {2435, 420, 345, 250, 160}
	local times = GData.getAgainTimes()
	commonUI('mtt/mtt_R.png', '重购  ('..times..'次)', ccps)
end



return GMttBuy