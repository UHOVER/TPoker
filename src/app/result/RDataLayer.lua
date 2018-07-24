local ViewBase = require("ui.ViewBase")
local RDataLayer = class("RDataLayer", ViewBase)
local _data1 = {}
local _data2 = {}

local color2 = cc.c3b(139,139,140)
local _scrollH = 0
function RDataLayer:addStatistics(data)
	local function baseData()
		local BaseData = require 'result.BaseData'
		local bd = BaseData:create()

		bd:startBaseLayer(cc.Director:getInstance():getRunningScene(), data)
	end

	local white = cc.c3b(205,205,205)

	local tnode = cc.Node:create()
	local leftX = 53

	--标准
	local upLine = 'result/result_curve5.png'
	local progress2 = 'result/result_progress4.png'
	local progress1 = 'result/result_progress6.png'
	local colorBR = cc.c3b(51,103,205)
	local resB = "result/mark_general.png"

	if data['tag'] == ResultCtrol.SNG_TAG then
		upLine = 'result/result_curve4.png'
		progress2 = 'result/result_progress2.png'
		progress1 = 'result/result_progress1.png'

		colorBR = cc.c3b(220,95,3)
		resB = "result/mark_sng.png"
	elseif data['tag'] == ResultCtrol.MTT_TAG then
		upLine = 'result/result_curve8.png'
		progress2 = 'result/result_progress8.png'
		progress1 = 'result/result_progress7.png'
		colorBR = cc.c3b(168,119,247)
		resB = "result/mark_mtt.png"
	end

	local cx = display.cx

	local ty1 = 1200
	-- local tsp = UIUtil.addPosSprite('result/result_line2.png', cc.p(cx-60,ty1), tnode, cc.p(1,0.5))
	-- tsp:setColor(colorBR)
	-- tsp = UIUtil.addPosSprite('result/result_line2.png', cc.p(cx+60,ty1), tnode, cc.p(0,0.5))
	-- tsp:setColor(colorBR)
	local titleLine = UIUtil.addPosSprite(resB, cc.p(cx,ty1), tnode, cc.p(0.5,0.5))
	-- titleLine:setColor(colorBR)

	local ty2 = 1135
	UIUtil.addLabelArial('生涯合计', 32, cc.p(53,ty2), cc.p(0,0.5), tnode, white)

	local ty3 = 1070
	local bg3 = UIUtil.addPosSprite('result/result_bg5.png', cc.p(cx,ty3), tnode, cc.p(0.5,0.5))
	bg3:setOpacity(0)
	local ttf3 = UIUtil.addLabelArial(data['pokerNum'], 37, cc.p(-28,30.5), cc.p(0,0.5), bg3, colorBR)
	local ttf3w = ttf3:getContentSize().width
	UIUtil.addLabelArial(data['title1'], 30, cc.p(ttf3w -25,30.5), cc.p(0,0.5), bg3, white)
	local tab = {}
    tab['font'] = 'Arial'
    tab['size'] = 30
	local item = UIUtil.addMenuFont(tab, ' 基本数据 ', cc.p(588,32), baseData, bg3)
	item:setAnchorPoint(1,0.5)
	item:setColor(colorBR)

	local arrow = UIUtil.addPosSprite('result/result_base_arrow.png', cc.p(610,32), bg3, cc.p(1,0.5))
	arrow:setColor(colorBR)

	--线
	UIUtil.addPosSprite('result/r_llline.png', cc.p(20,ty3 - 30), tnode, cc.p(0.0,0.0))

	--入池率
	local ty4 = 980
	UIUtil.addLabelArial(data['title2'], 24, cc.p(52,ty4), cc.p(0,0.5), tnode, white)
	local ty5 = 934
	local ttf5 = UIUtil.addLabelArial(data['probability1']..'%', 50, cc.p(52,ty5), cc.p(0,0.5), tnode, colorBR)
	local ttfw5 = ttf5:getContentSize().width
	UIUtil.addLabelArial(data['text1'], 22, cc.p(ttfw5 + 90,ty5+35), cc.p(0,0.5), tnode, cc.c3b(44,44,44))
	UIUtil.addLabelArial(data['text2'], 22, cc.p(ttfw5 + 90,ty5), cc.p(0,0.5), tnode, cc.c3b(44,44,44))

	--进度条
	local node6 = cc.Node:create()
	node6:setPositionY(-45)
	tnode:addChild(node6)

	--动态line
	local rect1 = cc.rect(5,0,5,0)
	local line = UIUtil.scale9Sprite(rect1, upLine, cc.size(data['lineWidth'],27), cc.p(60,935), node6)
	line:setAnchorPoint(0,0.5)


	--进度条
	local rect2 = cc.rect(37,0,37,0)
	local minLen = 20
	local scale9Bg = UIUtil.scale9Sprite(rect2, progress1, cc.size(626,37), cc.p(60,901), node6)
	scale9Bg:setAnchorPoint(0,0.5)
	local scale9 = UIUtil.scale9Sprite(rect2, progress2, cc.size(626,37), cc.p(60,901), node6)
	scale9:setAnchorPoint(0,0.5)
	UIUtil.scale9Slider(scale9, cc.size(626,37), data['probability1'], minLen)

	--标准局胜率
	if data['tag'] == ResultCtrol.STARNDARD_TAG then
		local upImg = 'result/result_progress3.png'
		local scale9Up = UIUtil.scale9Sprite(rect2, upImg, cc.size(626,37), cc.p(60,901), node6)
		scale9Up:setAnchorPoint(0,0.5)
		UIUtil.scale9Slider(scale9Up, cc.size(626,37), data['probability3'], minLen)
	end

	--poker
	local pokerTag = UIUtil.addPosSprite('result/result_poker.png', cc.p(685,870), node6, cc.p(0.5,0))
	pokerTag:setColor(colorBR)

	--胜率、投资回报率
	local imgLine = 'result/result_curve6.png'
	if data['tag'] == ResultCtrol.STARNDARD_TAG then
		imgLine = 'result/result_curve6.png'

		--前三个
		if data['probability2'] ~= 0 then
			UIUtil.addPosSprite('result/result_curve1.png', cc.p(70,885), node6, cc.p(0,1))
		end
		UIUtil.addLabelArial(data['title3'], 28, cc.p(leftX,830), cc.p(0,0.5), node6, cc.c3b(158,158,158))
		UIUtil.addLabelArial(data['probability2']..'%', 42, cc.p(110,790), cc.p(0.5,0.5), node6, colorBR)
	elseif data['tag'] == ResultCtrol.SNG_TAG then
		imgLine = 'result/result_curve7.png'
		UIUtil.addLabelArial(data['title3'], 28, cc.p(leftX,750), cc.p(0,0.5), tnode, cc.c3b(158,158,158))
		UIUtil.addLabelArial(data['probability2']..'%', 34, cc.p(198,750), cc.p(0,0.5), tnode, colorBR)
	elseif data['tag'] == ResultCtrol.MTT_TAG then
		imgLine = 'result/result_curve9.png'
		UIUtil.addLabelArial(data['title3'], 28, cc.p(leftX,750), cc.p(0,0.5), tnode, cc.c3b(158,158,158))
		UIUtil.addLabelArial(data['probability2']..'%', 34, cc.p(198,750), cc.p(0,0.5), tnode, colorBR)
	end

	--后三
	UIUtil.addPosSprite(imgLine, cc.p(680,880), node6, cc.p(0,1))
	UIUtil.addLabelArial(data['title4'], 25, cc.p(695,824), cc.p(0.5,0.5), node6, cc.c3b(158,158,158))
	UIUtil.addLabelArial(data['allNum'], 45, cc.p(695,785), cc.p(0.5,0.5), node6, colorBR)

	return tnode
end


function RDataLayer:createLayer()
	-- local sH = 1200 - G_SURPLUS_H 
	-- local sH = 1334 - 130 - 89
	local sh = _scrollH
	local scrollSize = cc.size(display.width,sh)
	local addH = 620
	local layerH = 1130 + addH
	local layer = cc.LayerColor:create(cc.c4b(0,225,5,0), scrollSize.width, layerH)
	local scrollView = cc.ScrollView:create()
	scrollView:setViewSize(scrollSize)
	scrollView:setContainer(layer)
	scrollView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
	self:addChild(scrollView)

	local tH = scrollSize.height - layerH
	if tH < 0 then
		scrollView:setContentOffset(cc.p(0,tH))
	end

	--标准
	local node1 = self:addStatistics(_data1[1])
	node1:setPositionY(-105 + addH)
	layer:addChild(node1)

	--sng
	local node2 = self:addStatistics(_data1[2])
	node2:setPositionY(-630 + addH)
	layer:addChild(node2)
	--sng
	local node3 = cc.Node:create()
	layer:addChild(node3)
	node3:setPositionY(addH)
	local ty3 = 50
	UIUtil.addLabelArial('总奖金', 30, cc.p(50,ty3), cc.p(0,0.5), node3, color2)
	UIUtil.addLabelArial(_data2['AllBonus'], 35, cc.p(145,ty3), cc.p(0,0.5), node3, cc.c3b(128,54,13))
	UIUtil.addPosSprite('result/result_gold.png', cc.p(360,ty3), node3, cc.p(1,0.5))
	UIUtil.addPosSprite('result/result_silver.png', cc.p(510,ty3), node3, cc.p(1,0.5))
	UIUtil.addPosSprite('result/result_copper.png', cc.p(680,ty3), node3, cc.p(1,0.5))
	UIUtil.addLabelBold(_data2['first'], 30, cc.p(370,ty3), cc.p(0,0.5), node3, cc.c3b(158,158,158))
	UIUtil.addLabelBold(_data2['second'], 30, cc.p(520,ty3), cc.p(0,0.5), node3, cc.c3b(158,158,158))
	UIUtil.addLabelBold(_data2['third'], 30, cc.p(690,ty3), cc.p(0,0.5), node3, cc.c3b(158,158,158))

	--mtt
	local node4 = self:addStatistics(_data1[3])
	node4:setPositionY(-1230 + addH)
	layer:addChild(node4)
	--mtt
	local node5 = cc.Node:create()
	layer:addChild(node5)
	node5:setPositionY(0)
	local ty4 = 60
	UIUtil.addLabelArial('总奖金', 32, cc.p(50,ty4), cc.p(0,0.5), node5, color2)
	UIUtil.addLabelArial(_data2['mttRewardAll'], 35, cc.p(150,ty4), cc.p(0,0.5), node5, cc.c3b(170,122,239))
	UIUtil.addLabelArial('决赛桌', 32, cc.p(640,ty4), cc.p(1,0.5), node5, color2)
	UIUtil.addLabelArial(_data2['mttFinalNum']..'场', 32, cc.p(650,ty4), cc.p(0,0.5), node5, cc.c3b(170,122,239))
	self:setContentSize(scrollSize)
end


function RDataLayer:startData(parent, data)
	print_f(data)
	dump(parent:getContentSize(), "ZUOBIAO")
	_scrollH = parent:getContentSize().height
	print("_scrollH:".._scrollH)
	_data1,_data2 = ResultCtrol.getDataResult(data)

	parent:addChild(self)
	self:createLayer()

end



return RDataLayer