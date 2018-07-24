-- YDWX_DZ_WUJIANCHAO_ FEATURE _20160708 _001
local ViewBase = require("ui.ViewBase")
local BaseData = class("BaseData", ViewBase)

function BaseData:createLayer(data)

    local colorBR = cc.c3b(42,89,192)--标准 色
    
    if data['tag'] == ResultCtrol.SNG_TAG then
        colorBR = cc.c3b(128,54,13)--sng
    elseif data['tag'] == ResultCtrol.MTT_TAG then
        colorBR = cc.c3b(170,122,239)--mtt
    end


    local layer = cc.LayerColor:create(cc.c4b(0,0,0,255))
	self:addChild(layer)

	local cs = cc.CSLoader:createNodeWithVisibleSize(ResLib.RBASE_LAYER_CSB)
    self:addChild(cs)
    cs:getChildByName('btnReturn'):touchEnded(function()
    	self:removeFromParent()
    	end)
    cs:setPositionY(-G_SURPLUS_H)

    local bg1 = cs:getChildByName('imgbg1')
    local bg2 = cs:getChildByName('imgbg2')
    local bg3 = cs:getChildByName('imgbg3')

    --bg1
    bg1:getChildByName('ttfAllFeeText'):setString(data['feeText'])
    bg1:getChildByName('ttfAllFeeVal'):setString(data['feeVal'])
    local tsp = bg1:getChildByName('ttfAllFeeVal')
    tsp:setColor(colorBR)
    bg1:getChildByName('ttfStatus'):setString(data['feeStatus'])


    --bg2
    local arr1 = data['array1']
    for i=1,5 do
    	local img = bg2:getChildByName('imgCard'..i)
    	img:setOpacity(0)
    end
    for i=1,#arr1 do
    	local img = bg2:getChildByName('imgCard'..i)
    	img:setOpacity(255)
    	img:setTexture(DZConfig.cardName( tonumber(arr1[ i ]) ))
    end
    bg2:setPositionY(860)


    --bg3
    local titles = {'翻牌前加注率', '摊牌率', '激进度', '持续下注', '再加注率', '偷盲率'}
    local text1 = '翻牌前主动加注的频率，体现翻牌前加注的牌的范围。'
    local text2 = '是指玩家看到翻牌圈并玩到摊牌的百分比。'
    local text3 = '是指玩家在翻牌后的主动下注/加注的激进行为的数值。'
    local text4 = '是指玩家在前一轮主动下注或加注后在当前这一轮再次主动下注的。'
    local text5 = '即在他人下注，有人加注之后的再加注的频率。'
    local text6 = '当玩家处于截位(CO)/庄位/小盲位加注偷盲的频率。'
    local texts = {text1, text2, text3, text4, text5, text6}

    local statusbg = bg3:getChildByName('imgStatusBg')
    local ttfTitle = statusbg:getChildByName('ttfStatusTitle')
    local ttfCon = statusbg:getChildByName('ttfStatusCon')
    local imgSelect = bg3:getChildByName('btnSelected')

    local posArr = {cc.p(0,358), cc.p(0,209), cc.p(0,55), cc.p(750,358), cc.p(750,209), cc.p(750,55)}

    ttfTitle:setString(titles[ 1 ])
    ttfCon:setString(texts[ 1 ])
    imgSelect:setPosition(posArr[ 1 ])

    local function handleStatus(sender)
    	local btnTag = sender:getTag()
    	ttfTitle:setString(titles[ btnTag ])
    	ttfCon:setString(texts[ btnTag ])
        imgSelect:setPosition(posArr[ btnTag ])

        if btnTag < 4 then
            imgSelect:setRotation(0)
        else
            imgSelect:setRotation(180)
        end
    end

    local arr2 = data['array2']
    for i=1,#arr2 do
    	local btn = bg3:getChildByName('btn'..i)
    	btn:setTag(i)
    	btn:touchEnded(handleStatus)

    	btn:getChildByName('ttfVal'..i):setString(arr2[i]..'%')
        tsp = btn:getChildByName('ttfVal'..i)
        tsp:setColor(colorBR)
    end
end

function BaseData:startBaseLayer(parent, data)
	UIUtil.shieldLayer(self, nil)
	parent:addChild(self)
	self:createLayer(data)
end


return BaseData
-- YDWX_DZ_WUJIANCHAO_ FEATURE _20160708 _001
