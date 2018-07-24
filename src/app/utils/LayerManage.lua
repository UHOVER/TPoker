local LayerManage = {}

-- 添加所有继承自ViewBase的layer
local LayerTable = {}

local dtime = 0.1
local size = cc.Director:getInstance():getWinSize()
local startPos = cc.p(size.width, 0)
local pos1 = cc.p(-size.width/2, 0)
local pos2 = cc.p(size.width/2, 0)

function LayerManage.addLayerOfTable( layer )
	table.insert(LayerTable, layer)
	-- dump(LayerTable)
end

function LayerManage.removeLayerOfTable(  )
	table.remove(LayerTable, #LayerTable)
	-- (LayerTable)
end

function LayerManage.clearLayerTable(  )
	LayerTable = {}
end

function LayerManage.addTransitAction(  )
 	local curLayer = nil
	local bgLayer = nil
	curLayer = LayerTable[#LayerTable]
	if #LayerTable > 1 then
		bgLayer = LayerTable[#LayerTable-1]
	end

	local seq = cc.Sequence:create(cc.CallFunc:create(function (  )
		curLayer:setPosition(startPos)
	end), cc.FadeIn:create(dtime), cc.MoveBy:create(dtime, pos1) )

	local spa = cc.Spawn:create(cc.CallFunc:create(function (  )
		bgLayer:runAction(cc.MoveBy:create(dtime, pos1))
	end), seq)

	curLayer:runAction(spa)

end

function LayerManage.removeTransitAction(  )
	local curLayer = nil
	local bgLayer = nil
	curLayer = LayerTable[#LayerTable]
	if #LayerTable > 1 then
		bgLayer = LayerTable[#LayerTable-1]
	end

 	local seq = cc.Sequence:create( cc.FadeOut:create(dtime), cc.MoveBy:create(dtime, pos2), cc.CallFunc:create(function (  )
 			curLayer:removeFromParent()
 			LayerManage.removeLayerOfTable()
 	end) )

	local spa = cc.Spawn:create(cc.CallFunc:create(function (  )
		bgLayer:runAction(cc.MoveBy:create(dtime, pos2))
	end), seq)

	curLayer:runAction(spa)
end

return LayerManage