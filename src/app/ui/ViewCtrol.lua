local ViewCtrol = {}
local WaitServer = require('ui.WaitServer')

--wait PHP
function ViewCtrol.showPHPWaitServer()
    WaitServer.showPHPWait()
end

function ViewCtrol.hidePHPWaitServer()
    WaitServer.hidePHPWait()
end

function ViewCtrol.removePHPWaitServer()
    WaitServer.removePHPWaitServer()
end


--wait socket
function ViewCtrol.showWaitServer()
    WaitServer.showWait()
end

function ViewCtrol.hideWaitServer()
    WaitServer.hideWait()
end

function ViewCtrol.removeWaitServer()
    WaitServer.removeWaitServer()
end

function ViewCtrol.setWaitServerAni(parent, pos)
	return WaitServer.loadingImg(parent, pos)
end



function ViewCtrol.showMsg(msg, delay)
	local MessageWin = require ('ui.MessageWin')
	MessageWin.show(msg, delay)
end

function ViewCtrol.showTip( params )
	local MessageWin = require("ui.MessageWin")
	local layer = MessageWin.showTip( params )
	return layer
end

function ViewCtrol.showTips( params )
	local MessageWin = require("ui.MessageWin")
	local layer = MessageWin.showTips( params )
	return layer
end

function ViewCtrol.showTick( params )
	local MessageWin = require("ui.MessageWin")
	MessageWin.showTick(params)
end

function ViewCtrol.popHint( params )
	local MessageWin = require("ui.MessageWin")
	local layer = MessageWin.popHint( params )
	return layer
end


--展示授权界面
function ViewCtrol.showApplyList(tag)
    local runScene = cc.Director:getInstance():getRunningScene()
	local MessageCtorl = require("message.MessageCtorl")
    MessageCtorl.dataStatCardNotice(function(cdata)
        local CardsNotice = require("message.CardsNotice").new()
        runScene:addChild(CardsNotice, StringUtils.getMaxZOrder(runScene))
        CardsNotice:setCallTag(tag)
    end)	
end

--从授权界面返回
function ViewCtrol.fromApplyList(tag)
	if tag == DZChat.TYPE_CLUB or tag == DZChat.TYPE_GROUP or tag == DZChat.TYPE_FRIEND then
		local DZChatNet = require ('platform.DZChatNet')
		DZChatNet.netEnterChat(nil, nil, true)
	elseif tag == DZChat.TYPE_GAME_STANDARD or tag == DZChat.TYPE_GAME_SNG then
		MainCtrol.enterGame(nil, nil, function()end, true)
	elseif tag == DZChat.TYPE_GAME_MTT then
		MainCtrol.enterGame(nil, nil, function()end, true, true )
	elseif tag == nil then
	end
end


return ViewCtrol