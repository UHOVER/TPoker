local HandleBro = {}

local function buySuccess(tdata)
	local PayLayer = require 'shop.PayLayer'	
	PayLayer.buySuccess(tdata)
end


--消失蓝条新消息提示
local function disappearNewMsg(tdata)
	local GameScene = require 'game.GameScene'	
	GameScene.removeNewMsgSignUp()
end

--显示通知mtt开始对话框需要的消息类型有
--返回码 -code
--牌局id -pid
--比赛名称 -mname
--比赛开始时间 -stime
-- 60s 时候推送开始
local function showBeginDlg(tdata)
	local MttShowCtorl = require("common.MttShowCtorl")
	local isShow = MttShowCtorl.isMttShow()
	if isShow then
		-- local MttShowLayer = require("common.MttShowLayer")
		-- MttShowLayer.updateMttTime()
		return
	else
		local GameScene = require("game.GameScene")
		if GameScene.isDisGameScene() then
			local str = tdata['mtt_name'].."比赛将在"..tdata['to_timing'].."秒后开始"
			ViewCtrol.showMsg(str, 2.5)
		else
			MttShowCtorl.getMttStatus( tdata["mtt_id"], function(data)
				if tonumber(data.status) == 1 or tonumber(data.status) == 0 then
					local tab = {}
					tab["msgName"] = tdata['mtt_name'].."比赛将在"..tdata['to_timing'].."秒后开始"
					tab["msgTime"] = tdata['to_timing']
					tab["pid"] = tdata["mtt_id"]
					DZChat.clickShowTimeDlg(tab['msgName'], tab["msgTime"], tab["pid"])
				else
					print("赛事已结束")
					return
				end
			end)
		end
	end
end

-- mtt人数不足 推送解散
local function broDissolveMtt( tdata )
	local MttShowCtorl = require("common.MttShowCtorl")
	local isShow = MttShowCtorl.isMttShow()
	if isShow then
		MttShowCtorl.broDissolve( tdata['mtt_id'] )
	else
		local CardCtrol = require("cards.CardCtrol")
		if CardCtrol.isCardScene() then
			print("成功移除牌局")
			CardCtrol.updateCardList( tdata['mtt_id'] )
		end
	end
	local MessageCtorl = require("message.MessageCtorl")
	MessageCtorl.deleteMsg( tdata["ryId"] )
end

-- 比赛正式开始、进入MTT
local function broEnterMttGame( tdata )
	dump(tdata)
	local MttShowCtorl = require("common.MttShowCtorl")
	MttShowCtorl.broEnterGame( tdata['mtt_id'] )
end

-- 10分钟推送
local function broReStatus( tdata )
	local MttShowCtorl = require("common.MttShowCtorl")
	MttShowCtorl.connectMttStat(tdata)
end


function HandleBro.broMsg(data)
	print("iiii")
	dump(data)

	local pnum = data['code']
	
	local handles = {}
	handles[5000] = buySuccess
	handles[3071] = disappearNewMsg
	handles[3070] = showBeginDlg
	handles[3072] = broDissolveMtt
	handles[3073] = broEnterMttGame
	handles[3074] = broReStatus
	if handles[ pnum ] then
		print('HandleBro  推送消息')
		-- print_f(data)
		handles[ pnum ](data)
	end
end

return HandleBro