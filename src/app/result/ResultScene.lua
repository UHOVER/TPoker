local SceneBase = require("ui.SceneBase")
local ResultScene = class("ResultScene", SceneBase)
cc.exports.ResultCtrol 	= require ('result.ResultCtrol')
cc.exports.DZSort		= require 'utils.DZSort'
local director = cc.Director:getInstance()
local view = director:getOpenGLView()
local visibleSize = view:getVisibleSize()
local framesize = view:getFrameSize()
local originPos = cc.p((visibleSize.width-visibleSize.width), (1334-display.height))
local _node = nil
local _cs = nil
local _data1 = nil
local _btnStatistics1 = nil
local _btnStatistics2 = nil
local _btnReturn = nil

--数据统计按钮
local function handleData()
	local function godataLayer(data)
		_data1 = data

		local titleBg = _cs:getChildByName('baseTitle')
    	local titlePosy =  titleBg:getPositionY() - titleBg:getAnchorPoint().y * titleBg:getContentSize().height
    	_node:setContentSize(cc.size(display.width, titlePosy -5))
		local RDataLayer = require 'result.RDataLayer'
		local rdl = RDataLayer:create()
		rdl:startData(_node, data)
		
    	-- _node:setPositionY(titlePosy - rdl:getContentSize().height)
    	_node:setLocalZOrder(68)
	end

	_node:removeAllChildren()
	_cs:getChildByName('imgBg2'):removeAllChildren()
	_btnStatistics2:setEnabled(true)
	_btnStatistics1:setEnabled(false)
	_btnStatistics2:setTitleColor(cc.c3b(236,201,140))
	_btnStatistics1:setTitleColor(cc.c3b(0,0,0))
	_cs:getChildByName('rline_15'):setVisible(false)
	if _data1 == nil then
	else
		godataLayer(_data1)
	end

	_cs:getChildByName('imgBg2'):removeAllChildren()
end

--战绩统计按钮
local function handleResult()
	local function response(data)
		_node:removeAllChildren()
		_cs:getChildByName('imgBg2'):removeAllChildren()
		_btnStatistics1:setEnabled(true)
		_btnStatistics2:setEnabled(false)
		_btnStatistics1:setTitleColor(cc.c3b(236,201,140))
		_btnStatistics2:setTitleColor(cc.c3b(0,0,0))
		_cs:getChildByName('rline_15'):setVisible(false)

		local titleBg = _cs:getChildByName('baseTitle')
    	local titlePosy =  titleBg:getPositionY() - titleBg:getAnchorPoint().y * titleBg:getContentSize().height

		local RRecordLayer = require 'result.RRecordLayer'
		local rrl = RRecordLayer:create()
		rrl:startRecord(_cs:getChildByName('imgBg2'), data, titlePosy)
	end
	ResultCtrol.recordStatistics(response)
end


local function Callback(  )
	-- local mine = require("mine.MineScene")
	-- mine.startScene()
end

function ResultScene:initScene()
	local layer = cc.Layer:create()
	self:addChild(layer)
	layer:setPosition(cc.p(0, 0))

    local cs = cc.CSLoader:createNodeWithVisibleSize(ResLib.RESULT_SCENE_CSB)
    layer:addChild(cs)

	Bottom:getInstance():addBottom(1, layer)

    _cs = cs
    _cs:getChildByName('rline_15'):setVisible(false)
    _node = cc.Node:create()
    cs:addChild(_node)

    --btn
    local topbar = cs:getChildByName('Image_1')
    local topposy = topbar:getPositionY() - topbar:getAnchorPoint().y * topbar:getContentSize().height
    
    local titleBg = cs:getChildByName('baseTitle')
    titleBg:setPositionY(topposy)
    local btn1 = titleBg:getChildByName('btnStatistics1')
    local btn2 = titleBg:getChildByName('btnStatistics2')
    btn1:touchEnded(handleData)
    btn2:touchEnded(handleResult)
    _btnStatistics1 = btn1
    _btnStatistics2 = btn2

	local btn = topbar:getChildByName('btnReturn')
	btn:touchEnded(Callback)
	_btnReturn = btn

	  dump(originPos, "圆点")
    dump(display.size, "设计分辨率")
    dump(framesize, "内容size")
    dump(_cs:getContentSize(),"内容大小")
    dump(_cs:getPositionY(), '内容坐标')
    dump(topbar:getPositionY(), 'topbar坐标')
    
    handleData()

  
    -- if originPos.y < 0 then  
	    -- _cs:setPositionY(0-originPos.y)
	-- end
end


function ResultScene:startScene()
	_data1 = nil

	ResultCtrol.dataStatistics(function(data)
		_data1 = data
		local scene = ResultScene:create()
		cc.Director:getInstance():replaceScene(scene)
		scene:initScene()

		NewMsgMgr.registerDisplayScene(scene)
	end)
end

--隐藏上标题
function ResultScene:hideT()
	_cs:getChildByName('baseTitle'):setPositionX(10000)
	-- _btnStatistics1:setVisible(false)
	-- _btnStatistics2:setVisible(false)
	-- _btnReturn:setVisible(false)
	_cs:getChildByName('Image_1'):setVisible(false)
	_cs:getChildByName('Panel_1'):setVisible(false)
	-- _cs:setPositionY(0 )
end

--显示上标题
function ResultScene:showT()
	_cs:getChildByName('baseTitle'):setPositionX(display.cx)
	-- _btnStatistics1:setVisible(true)
	-- _btnStatistics2:setVisible(true)
	-- _btnReturn:setVisible(true)
	_cs:getChildByName('Image_1'):setVisible(true)
	_cs:getChildByName('Panel_1'):setVisible(true)
	-- _cs:setPositionY(0- originPos.y)
end

return ResultScene
