local BottomCtrol = class( 'BottomCtrol' )

-- 游戏UI
function BottomCtrol.buildGame(  )
	local MainScene = require('main.MainScene')
	MainScene.startScene()
end

-- 消息UI
function BottomCtrol.buildMessage(  )
	-- local function falseBack()
		local MessageCtorl = require("message.MessageCtorl")
		MessageCtorl.setChatType(0)

		local Message = require('message.MessageScene')
		Message.startScene()
	-- end
	
	-- UIUtil.falseShield(falseBack, nil)
end

-- 牌局列表
function BottomCtrol.buildCards(  )
	local cards = require("cards.CardScene")
	cards.startScene()
end

-- 俱乐部UI
function BottomCtrol.buildClub(  )
	local ClubScene = require('club.ClubScene')
	ClubScene.startScene()
end

-- 我UI
function BottomCtrol.buildMine(  )
	local MineScene = require('mine.MineScene')
	MineScene.startScene()
end

function BottomCtrol.buildResult(  )
	local Result = require("result.ResultScene")
    Result.startScene()
end

return BottomCtrol