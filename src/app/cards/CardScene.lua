local SceneBase = require("ui.SceneBase")
local CardScene = class("CardScene", SceneBase)
local CardCtrol = require("cards.CardCtrol")

local callBack = nil

function CardScene:initScene(  )
	local cardList = require('cards.CardList')
	local layer = cardList:create()
	self:addChild(layer)
	layer:createLayer()
	if callBack then
		callBack()
	end
end

function CardScene:startScene( funcBack )
	callBack = nil
	if funcBack then
		callBack = funcBack
	end
	CardCtrol.dataStatClubInfo( function (  )
		local scene = CardScene:create()
		cc.Director:getInstance():replaceScene(scene)
		scene:initScene(  )

		-- NewMsgMgr.registerDisplayScene(scene)
	end )
end

return CardScene