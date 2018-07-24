local MainHelp = {}
local MAX_H = 80

local SCALE = G_SURPLUS_H / G_SURPLUS_MAX_H
local surplusH = G_SURPLUS_H

function MainHelp.mainAdaptation(arrs)
	local topy = arrs[1]:getPositionY()
	local toph = arrs[1]:getContentSize().height

	arrs[2]:setPositionY(topy - toph)
	arrs[3]:setPositionY(topy - toph)
	arrs[4]:setPositionY(arrs[4]:getPositionY() - 0.72 * surplusH)	
end


function MainHelp.mainAdaptationHall(arrs)
	-- if G_SURPLUS_H < MAX_H then return end
	-- 余额、line、edit
	arrs[1]:setPositionY(arrs[1]:getPositionY() - 0.95 * surplusH)
	arrs[2]:setPositionY(arrs[2]:getPositionY() - 0.41 * surplusH)	
	arrs[3]:setPositionY(arrs[3]:getPositionY() - 0.14 * surplusH)	
end
function MainHelp.mainAdaptationHallBtn(arrs)
	--现在开局按钮
	arrs[1]:setPositionY(arrs[1]:getPositionY() + 0.11 * surplusH)
end

function MainHelp.mainAdaptSenior(arrs, tTag)
	local node1 = arrs[ 1 ]
	local node2 = arrs[ 2 ]
	local highBtnNode = arrs[ 3 ]

	local scale1 = 0.05
	local scale2 = 0.05
	local scale3 = 0.65
	if tTag == StatusCode.BUILD_SNG then
		scale1 = -0.05
		scale2 = 0.12
		scale3 = 0.57
	end

	node1:setPositionY(node1:getPositionY() + scale1 * surplusH)	
	node2:setPositionY(node2:getPositionY() - scale2 * surplusH)	
	highBtnNode:setPositionY(highBtnNode:getPositionY() - scale3 * surplusH)
end

function MainHelp.mainAdaptSlider(arrs)
	local ttf1 = arrs[ 1 ]
	local ttf2 = arrs[ 2 ]
	local ttf3 = arrs[ 3 ]
	local tslider = arrs[ 4 ]

	ttf1:setPositionY(ttf1:getPositionY() - 0.1 * surplusH)	
	ttf2:setPositionY(ttf2:getPositionY() - 0.1 * surplusH)	
	-- tslider:setPositionY(tslider:getPositionY() - 0.05 * surplusH)	
	ttf3:setPositionY(ttf3:getPositionY() - 0.08 * surplusH)	
end

function MainHelp.mainAdaptationEdit(arrs)
	if G_SURPLUS_H < MAX_H then return end

	--tabelview、高亮点、三个小点
	arrs[1]:setPositionY(arrs[1]:getPositionY() - 0.15 * surplusH)
	arrs[2]:setPositionY(arrs[2]:getPositionY() - 0.05 * surplusH)
	local dots = arrs[3]
	for i=1,#dots do
		dots[i]:setPositionY(dots[i]:getPositionY() - 0.05 * surplusH)
	end
end

function MainHelp.mainCommonAdapt(arrs)
	local startBtn = arrs[ 1 ]
	local lastLine = arrs[ 2 ]
	local highNode = arrs[ 3 ]
	
	local triangle = arrs[ 4 ]
	local sliderNode = arrs[ 5 ]
	local titleNode = arrs[ 6 ]
	startBtn:setPositionY(startBtn:getPositionY() - 0.12 * surplusH)
	triangle:setPositionY(triangle:getPositionY() - 0.85 * surplusH)
	lastLine:setPositionY(lastLine:getPositionY() - 0.23 * surplusH)

	highNode:setPositionY(highNode:getPositionY() - 0.45 * surplusH)
	sliderNode:setPositionY(sliderNode:getPositionY() - 0.6 * surplusH)
	titleNode:setPositionY(titleNode:getPositionY() - 0.75 * surplusH)
end

function MainHelp.mainEditBuild(arrs)
	local buildNode = arrs[ 1 ]
	buildNode:setPositionY(buildNode:getPositionY() - 0.7 * surplusH)	
end
function MainHelp.mainEditBuildSNG(arrs)
	local buildNode = arrs[ 1 ]
	local line1 = arrs[ 2 ]
	local line2 = arrs[ 3 ]
	local tedit = arrs[ 4 ]
	local input = arrs[ 5 ]
	buildNode:setPositionY(buildNode:getPositionY() - 0.5 * surplusH)	
	line2:setPositionY(line2:getPositionY() - 0.07 * surplusH)	
	line1:setPositionY(line1:getPositionY() - 0.15 * surplusH)	
	tedit:setPositionY(tedit:getPositionY() - 0.2 * surplusH)	
	input:setPositionY(input:getPositionY() - 0.2 * surplusH)	
end
function MainHelp.mainEditBuildStandard(arrs)
	local buildNode = arrs[ 1 ]
	buildNode:setPositionY(buildNode:getPositionY() - 0.7 * surplusH)	
end

function MainHelp.mainEditHall(arrs)
	--mainCommonAdapt 里的 lastLine下降一样
	local lookAll = arrs[1]
	local hallNode = arrs[2]
	lookAll:setPositionY(lookAll:getPositionY() - 0.23 * surplusH)	
	hallNode:setPositionY(hallNode:getPositionY() - 0.7 * surplusH)	
end



--sng申请通过了提示
function MainHelp.sngApplaySuccess(gid, pokerName)
	local GameScene = require 'game.GameScene'
	if GameScene.isDisGameScene() then return end
	if DZChat.isShowChatView() then return end

	local function sureBtn()
		GameScene.startScene(gid)
	end

	DZWindow.prompt('提示', '您申请的'..pokerName..'牌局申请已经通过了', '入局', sureBtn, '取消', function()end)
end

function MainHelp.sngApplayFail(gid, pokerName)
	local GameScene = require 'game.GameScene'
	if GameScene.isDisGameScene() then return end
	if DZChat.isShowChatView() then return end

	local params = {}
	params['title'] = '提示'
	params['content'] = '您申请的'..pokerName..'牌局被拒绝了'
	MessageWin.showTip(params)	
end



function MainHelp.getCellBgH()
	return 1050 - G_SURPLUS_H * 0.85
end

function MainHelp.getTopEditHeight()
	--225图片高度
	-- if G_SURPLUS_H < 0 then return 225 end

	-- local reth = 225 - G_SURPLUS_H
	-- if reth < 225 - MAX_H then
	-- 	reth = 225 - MAX_H
	-- end

	return 120
end


return MainHelp