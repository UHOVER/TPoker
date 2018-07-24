local SceneBase = require("ui.SceneBase")
local MineScene = class("MineScene", SceneBase)

function MineScene:initScene(  )
	local curScene = cc.Director:getInstance():getRunningScene()

	local mineLayer = require("mine.MineLayer")
	local layer = mineLayer:create()
	layer:setName("mine")
	if curScene:getChildByName("mine") then
		curScene:removeChildByName("mine")
	end
	self:addChild(layer)
	layer:createLayer(  )
end

function MineScene:startScene(  )
	data = {}
	local MineCtrol = require("mine.MineCtrol")
	MineCtrol.dataStatMine(function (  )
		local scene = MineScene:create()
		cc.Director:getInstance():replaceScene(scene)
		scene:initScene()

	-- 	NewMsgMgr.registerDisplayScene(scene)
	end)
end

return MineScene