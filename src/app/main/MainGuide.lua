local MainGuide = {}
local _dotposx = {}
local _step = 1
local _layer = nil
local _node = nil
local _dot = nil
local MAX_STEP = 3

local _btnBuild = nil
local _btnHall = nil
local _shield = nil

local function removeSceneGuid()
	local runScene = cc.Director:getInstance():getRunningScene()
    if runScene:getChildByName('SCENE_GUILD_ANME') then
    	runScene:getChildByName('SCENE_GUILD_ANME'):removeFromParent()
    end
end

local function textureSprite(texture, parent)
    local target = cc.RenderTexture:create(display.width, display.height, cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888)
    local sprite = target:getSprite()
    sprite:setContentSize(display.width, display.height)
    sprite:setAnchorPoint(0,0)
    sprite:setPosition(0,0)
    parent:addChild(target, 10)

    target:begin()
    texture:visit()
    target:endToLua()

    return target
end

local function createLayer(step)
    removeSceneGuid()

	local runScene = cc.Director:getInstance():getRunningScene()

	_node:removeAllChildren()
	_step = step

	if _dot then 
		_dot:setPositionX(_dotposx[_step])
	end

	if step == 1 then
		local posy = _btnBuild:getPositionY() - 110
		textureSprite(_btnBuild, _node)
		textureSprite(_btnHall, _node)
	    UIUtil.addPosSprite('main/main_guide_text1.png', cc.p(display.cx,posy), _node, cc.p(0.5,1))
	elseif step == 2 then
		local tnode = cc.Node:create()
		runScene:addChild(tnode)
		tnode:setName('SCENE_GUILD_ANME')

		local HallTable = require 'main.HallTable'
		local panel = HallTable.getDisplayNode()
		local sprite = textureSprite(panel, tnode)

		local px,py = panel:getPosition()
		local mpos = panel:convertToWorldSpace(cc.p(px,py))
	    UIUtil.addPosSprite('main/main_guide_text2.png', cc.p(display.cx,mpos.y+115), _node, cc.p(0.5,1))
		-- local pen = UIUtil.addPosSprite('main/main_pen.png', cc.p(display.cx,mpos.y+200), tnode, cc.p(0.5,0.5))
		-- pen:setLocalZOrder(11)
	elseif step == 3 then
		local HallTable = require 'main.HallTable'
		local editNode = HallTable.getEditNode()
		local posy = editNode:getPositionY()
		textureSprite(editNode, _node)
		UIUtil.addPosSprite('main/main_guide_text3.png', cc.p(display.cx,posy+260), _node, cc.p(0.5,0))
	-- elseif step == 4 then
		-- local tnode = cc.Node:create()
		-- runScene:addChild(tnode)
		-- tnode:setName('SCENE_GUILD_ANME')

		-- local HallTable = require 'main.HallTable'
		-- local btnNode = HallTable.getStartBtnNode()
		-- local px,py = btnNode:getPosition()
		-- local mpos = btnNode:convertToWorldSpace(cc.p(px,py))

		-- local sprite = textureSprite(btnNode, tnode)
		-- UIUtil.addPosSprite('main/main_guide_text4.png', cc.p(display.cx,mpos.y+10), tnode, cc.p(0.5,0))
	end
end


local function closeLayer()
	removeSceneGuid()
	_layer:removeFromParent()
	_shield:removeFromParent()
end

local function nextStep()
	_step = _step + 1

	if MAX_STEP < _step then 
		closeLayer()
	else
		createLayer(_step)
	end
end


function MainGuide.startGuide(parent)
	_dot = nil

	local layer = cc.Layer:create()
    parent:addChild(layer)	
    _layer = layer

    local rect = cc.rect(0,0,0,0)
    local mask = UIUtil.scale9Sprite(rect, 'main/main_blue_mask.png', display.size, cc.p(0,0), layer)
    mask:setAnchorPoint(0,0)

    _node = cc.Node:create()
    layer:addChild(_node)
    createLayer(1)

    --bar
    UIUtil.addPosSprite('main/main_guide_bar.png', cc.p(0,0), _layer, cc.p(0,0))
    
    local img = ResLib.COM_OPACITY0
    local label = cc.Label:createWithSystemFont('下一步', "Marker Felt", 28)
    local item1 = UIUtil.controlBtn(img, img, img, label, cc.p(display.width,0), cc.size(128,104), nextStep, _layer)
    item1:setAnchorPoint(1,0)

    _dotposx = {}
    local sx = 325
    for i=1,MAX_STEP do
    	UIUtil.addPosSprite('main/main_guide_dot0.png', cc.p(sx,46), _layer, cc.p(0.5,0.5))

    	table.insert(_dotposx, sx)
    	sx = sx + 30
    end
    _dot = UIUtil.addPosSprite('main/main_guide_dot1.png', cc.p(_dotposx[1],46), _layer, cc.p(0.5,0.5))

    local runScene = cc.Director:getInstance():getRunningScene()
    local shield = cc.Layer:create()
    _shield = shield
    runScene:addChild(shield, StringUtils.getMaxZOrder(runScene))
    UIUtil.shieldLayer(shield, nextStep)

    local tab = {}
    tab['font'] = 'Arial'
    tab['size'] = 35
    local item2 = UIUtil.addMenuFont(tab, '关闭', cc.p(35,30), closeLayer, shield)
    -- item2:setLocalZOrder(StringUtils.getMaxZOrder(runScene))
    item2:setAnchorPoint(0,0)
end



function MainGuide.setTwoBtn(btnBuild, btnHall)
	_btnBuild = btnBuild
	_btnHall = btnHall
end

return MainGuide