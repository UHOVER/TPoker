local ClubCtrol = require("club.ClubCtrol")
local AreaCode = {}

AreaCode.AREA_TAB 	= {}
AreaCode.ListView 	= nil 		-- listview 地区列表
AreaCode.ADDRESS_ID = nil 		-- 地区编码
AreaCode.Layer 		= nil 		-- 当前layer
AreaCode.FuncBack 	= nil 		-- 选择完地区回调函数
AreaCode.State 		= nil
AreaCode.size 		= nil

function AreaCode.buildArea( funcBack, parent, state )
	AreaCode.AREA_TAB = ClubCtrol.getAreaTable()
	-- dump(AreaCode.AREA_TAB)
	local hot = {} 			-- 热门
	local province = {} 	-- 省份
	for k,v in pairs(AreaCode.AREA_TAB) do
		if string.len(AreaCode.AREA_TAB[k].number) > 3 then
			table.insert(hot, AreaCode.AREA_TAB[k])
		else
			table.insert(province, AreaCode.AREA_TAB[k])
		end
	end
	-- dump(hot)
	-- dump(province)
	AreaCode.FuncBack = funcBack
	AreaCode.State  = state
	

--[[
**************************************************************************
* NAME OF THE BUG : YDWX_DZ_ZHANGMENG_BUG _20160711_001
* DESCRIPTION OF THE BUG : 【UE Integrity】Return error
* MODIFIED BY : 王礼宁
* DATE :2016-7-14
*************************************************************************/
]]

	AreaCode.Layer = cc.Layer:create()
	parent:addChild(AreaCode.Layer)
	if AreaCode.State then
		AreaCode.size = cc.size(display.width, display.height-130)
		UIUtil.setBgScale(ResLib.MAIN_BG, display.center, AreaCode.Layer)
		local function backCallback(  )
			AreaCode.Layer:removeFromParent()
		end
		-- addTopBar
		UIUtil.addTopBar({leftMenu = "取消", leftMenuFunc = backCallback, title = "选择城市", parent = AreaCode.Layer})
	else
		AreaCode.size = cc.size(display.width, display.height-225)
	end
	AreaCode.createListView( hot, province )

end


--[[
**************************************************************************
* NAME OF THE BUG : YDWX_DZ_ZHANGMENG_BUG _20160711_001
* DESCRIPTION OF THE BUG : 【UE Integrity】Return error
* MODIFIED BY : 王礼宁
* DATE :2016-7-14
*************************************************************************/
]]



function AreaCode.createListView( hotData, provinceData )

	AreaCode.ListView = ccui.ListView:create()
	AreaCode.ListView:setBounceEnabled(true)
	AreaCode.ListView:setDirection(1)
	AreaCode.ListView:setTouchEnabled(true)
	AreaCode.ListView:setContentSize(AreaCode.size)
	AreaCode.ListView:setBackGroundImage(ResLib.TABLEVIEW_BG)
  	AreaCode.ListView:setBackGroundImageScale9Enabled(true)
	AreaCode.ListView:setAnchorPoint(0,0)
	AreaCode.ListView:setPosition(cc.p(0, 0))
	AreaCode.Layer:addChild( AreaCode.ListView )

	for i=28, 1, -1 do
		local panel1 = AreaCode.createProvince(provinceData[i], i)
		AreaCode.ListView:insertCustomItem(panel1, 0)
	end

	local panel2 = AreaCode.createHot_Node( hotData )
	AreaCode.ListView:insertCustomItem(panel2, 0)

	return AreaCode.ListView

end

local function callback( tag, sender )
	print('button  '..tag:getTag())
	AreaCode.ADDRESS_ID = tag:getTag()
	print('-------  '..AreaCode.ADDRESS_ID)
	for k,v in pairs(AreaCode.AREA_TAB) do
		if tonumber(v.number) == AreaCode.ADDRESS_ID then
			AreaCode.FuncBack( AreaCode.ADDRESS_ID, v.site )
		end
	end
	if AreaCode.State then 	--为真就删除
		AreaCode.Layer:removeFromParent()  -- 从当前节点移除
	end
	
end

-- 创建热门城市
function AreaCode.createHot_Node( data )
	local node = ccui.Layout:create()
	node:setContentSize(cc.size(display.width, 500))
	node:setPosition(cc.p(0,0))
	local line = UIUtil.addPosSprite(ResLib.TABLEVIEW_TEXT_LINE, cc.p(display.cx, 480), node, cc.p(0.5, 0.5))
	UIUtil.addLabelArial('热门城市', 20, cc.p(20, line:getContentSize().height/2), cc.p(0, 0.5), line)

	for i=1,5 do
		for j=1,3 do
			local idx = (i-1)*3 + j
			local btn = UIUtil.addImageBtn({norImg = "club/bg_tableview_cell_noline.png", selImg = "club/bg_tableview_cell_noline.png", text = data[idx].site, pos = cc.p( 125+(j-1)*250, 420-(i-1)*100 ), touch = true, scale9 = true, size = cc.size(240, 90), listener = callback, parent = node})
			btn:setTitleFontSize(35)
			btn:setTitleFontName("Arial")
			btn:setTag(data[idx].number)
		end
	end
	return node
end

-- 创建省份
function AreaCode.createProvince( data, idx )
	local node = ccui.Layout:create()
	node:setPosition(cc.p(0,0))
	if idx == 1 then
		node:setContentSize(cc.size(display.width, 150))
		local line = UIUtil.addPosSprite(ResLib.TABLEVIEW_TEXT_LINE, cc.p(display.cx, 110), node, cc.p(0.5, 0.5))
		UIUtil.addLabelArial('省份', 20, cc.p(20, line:getContentSize().height/2), cc.p(0, 0.5), line)
	else
		node:setContentSize(cc.size(display.width, 100))
	end
	local btn = UIUtil.addImageBtn({norImg = ResLib.TABLEVIEW_CELL_BG, selImg = ResLib.TABLEVIEW_CELL_BG, ah = cc.p(0, 0), pos = cc.p(0, 5), touch = true, scale9 = true, size = cc.size(display.width, 90), listener = callback, parent = node})
	btn:setTag(data.number)

	local label = cc.Label:createWithSystemFont(data.site, "Arial", 35, cc.size(300, 40), cc.TEXT_ALIGNMENT_LEFT, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
		label:setTextColor(cc.c3b(255, 255, 255))
		label:setAnchorPoint(cc.p(0,0.5))
		label:setPosition(cc.p(50, 45))
		btn:addChild(label)
	return node
end

return AreaCode