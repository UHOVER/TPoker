local SceneBase = require('ui.SceneBase')
local ClubScene = class('ClubScene', SceneBase)
local ClubCtrol = require("club.ClubCtrol")
local _data = nil

function ClubScene:initScene(  )
	print('开始俱乐部')
	local curScene = cc.Director:getInstance():getRunningScene()
	if _data == "no" then
		local ClubLayer = require('club.ClubLayer')
		local layer = ClubLayer:create()
		self:addChild(layer)
		layer:createLayer()
	else
		local clubList = require('club.ClubList')
		local layer = clubList:create()
		layer:setName("clubList")
		if curScene:getChildByName("clubList") then
			curScene:removeChildByName("clubList")
		end
		self:addChild(layer)
		layer:createLayer()
	end
end

function ClubScene:startScene(  )
	_data = nil

	ClubCtrol.isHaveClub( function ( data )
		_data = data
		-- dump(_data)
		local scene = ClubScene:create()
		cc.Director:getInstance():replaceScene(scene)
		scene:initScene()

		NewMsgMgr.registerDisplayScene(scene)
	end )

end

return ClubScene