local SceneBase = require('ui.SceneBase')
local MessageScene = class('MessageScene', SceneBase)
local MessageCtorl = require("message.MessageCtorl")

function MessageScene:initScene(  )
	local messageLayer = require('message.MessageLayer')
	local layer = messageLayer:create()
	layer:setName("message")
	self:addChild(layer)
	layer:createLayer()
end

function MessageScene:startScene(  )
	 MessageCtorl.dataStatHTTP_RYID(function (  )
	 	local scene = MessageScene:create()
		cc.Director:getInstance():replaceScene(scene)
		scene:initScene()

		NewMsgMgr.registerDisplayScene(scene)
	 end)
end

return MessageScene