local ViewBase = require("ui.ViewBase")
local DataStat = class("DataStat", ViewBase)

cc.exports.ResultCtrol 	= require ('result.ResultCtrol')
cc.exports.DZSort		= require 'utils.DZSort'

local _dataStat = nil

local dataUser = {}

local function Callback(  )
	_dataStat:removeTransitAction()

end

function DataStat:buildLayer(  )
	
	-- addTopBar
	UIUtil.addTopBar({backFunc = Callback, title = "他的战绩", parent = self})

	local imageView = UIUtil.addImageView({touch=false, scale=true, size=cc.size(display.width, display.height-130), parent=self})

	local node = cc.Node:create()
	self:addChild(node)
	node:setContentSize(cc.size(display.width, display.height-130))
	local RDataLayer = require 'result.RDataLayer'
	local rd = RDataLayer:create()
	rd:startData(node, dataUser)


	--[[local height = display.height-130

	local color1 = cc.c3b(40,177,223)
	local color2 = cc.c3b(139,139,140)
	local color3 = cc.c3b(14,88,157)

	-- 生涯合计
	UIUtil.addLabelArial('生涯合计', 30, cc.p(50, height-80), cc.p(0, 0.5), imageView):setColor(color2)
	UIUtil.addLabelArial(dataUser.poker_num, 80, cc.p(50, height-200), cc.p(0, 0), imageView):setColor(color1)
	UIUtil.addLabelArial('个牌局', 30, cc.p(100, height-180), cc.p(0, 0), imageView):setColor(color2)

	-- 入池率
	UIUtil.addLabelArial('入池率', 30, cc.p(50, height-280), cc.p(0, 0.5), imageView):setColor(color2)

	local into_num = dataUser.into_rate*100
	UIUtil.addLabelArial(into_num .. '%', 80, cc.p(50, height-400), cc.p(0, 0), imageView):setColor(color1)

	local str = "入池率是扑克牌中一项重要的基础数据，通过玩家入局的频率，反映其打牌的松紧度。"
	local dataDes = cc.Label:createWithSystemFont(str, "Arial", 20, cc.size(450, 45), cc.TEXT_ALIGNMENT_LEFT, cc.VERTICAL_TEXT_ALIGNMENT_TOP)
	dataDes:setColor(color1)
	dataDes:setPosition(cc.p(220, height-380))
	dataDes:setAnchorPoint(cc.p(0, 0))
	imageView:addChild(dataDes)

	-- 胜率
	local win_num = dataUser.win_rate*100

	local img3 = 'result/result_progress3.png'
	local imgs = {img3, 'result/result_progress2.png', 'result/result_thumb.png'}
	local slider = UIUtil.addSlider(imgs, cc.p(50,height-470), imageView, nil, 1, 103)
	slider:setValue(50)
	slider:setAnchorPoint(0,0)
	slider:setEnabled(false)
	UIUtil.addPosSprite('result/result_poker.png', cc.p(685,height-470), imageView, cc.p(0.5,0))


	-- 胜率
	UIUtil.addPosSprite('result/result_curve1.png', cc.p(100,height-470), imageView, cc.p(0,1))
	UIUtil.addLabelArial('其中胜率', 30, cc.p(50, height-530), cc.p(0, 0.5), imageView):setColor(color2)
	
	
	UIUtil.addLabelArial(win_num .. '%', 50, cc.p(50, height-580), cc.p(0, 0.5), imageView):setColor(color3)

	UIUtil.addPosSprite('result/result_curve3.png', cc.p(640, height-470), imageView, cc.p(0,1))
	UIUtil.addLabelArial('总手数', 30, cc.p(display.width-50, height-530), cc.p(1, 0.5), imageView):setColor(color2)
	UIUtil.addLabelArial(dataUser.all_num, 50, cc.p(display.width-50, height-580), cc.p(1, 0.5), imageView):setColor(color3)
--]]
end

function DataStat:createLayer( data )
	_dataStat = self
	_dataStat:setSwallowTouches()
	_dataStat:addTransitAction()

	UIUtil.setBgScale(ResLib.MAIN_BG, display.center, self)

	dataUser = {}
	dataUser = data
	dump(dataUser)

	self:buildLayer()

end

return DataStat