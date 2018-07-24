local ViewBase = require('ui.ViewBase')
local ClubFund = class('ClubFund', ViewBase)
local _clubFund = nil

local tab = {}
	tab['font'] = 'Arial'
	tab['size'] = 30

local clubData = {}
local fundCount = 2000


local function callBack(  )
	_clubFund:removeFromParent()
end

-- 发放基金
local function sendCallback(  )
	local memberList = require('club.MemberList')
	local layer = memberList:create()
	_clubFund:addChild(layer)
	layer:createLayer( clubData, 'fund' )
end

-- 充值 （去往商城）
local function payCallback(  )
	local shop = require('shop.ShopLayer')
	local layer = shop:create()
	_clubFund:addChild(layer)
	layer:createLayer()
end

function ClubFund:buildLayer(  )
	
	UIUtil.addLabelArial('基金', 30, cc.p(display.cx,display.top-100), cc.p(0.5,0.5), self)

	UIUtil.addMenuFont(tab, 'BACK', cc.p(display.left+100, display.top-100), callBack, self)

	UIUtil.addMenuFont(tab, '发放', cc.p(display.right-100, display.top-100), sendCallback, self)

	UIUtil.addLabelArial('基金数目:'.. fundCount, 30, cc.p(display.cx-200,display.top-300), cc.p(0.5,0.5), self)
	UIUtil.addMenuFont(tab, '充值', cc.p(display.cx+200, display.top-300), payCallback, self)

end

function ClubFund:createLayer( clubTab )
	clubData = clubTab
	_clubFund = self
	_clubFund:setSwallowTouches()

	UIUtil.setBgScale(ResLib.MAIN_BG, display.center, self)
	self:buildLayer()
end

return ClubFund