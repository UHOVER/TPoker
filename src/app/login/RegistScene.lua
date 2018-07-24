local SceneBase = require("ui.SceneBase")
local RegistScene = class("RegistScene", SceneBase)

local TARGET = nil

function RegistScene:initScene(  )
	local RegistLayer = require("login.RegistLayer")
	local layer = RegistLayer:create()
	self:addChild(layer)
	layer:createLayer( TARGET )
end

function RegistScene:startScene( target )
	local scene = RegistScene:create()
	cc.Director:getInstance():replaceScene(scene)

	TARGET = target
	scene:initScene()
end

return RegistScene