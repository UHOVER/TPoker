NoticeCtrol = require("common.NoticeCtrol")


local Notice = {}

-- 推送消息表
local SMALL_RED_POINT = {}

local RED_POINT = {}

local NUMBER_TEXT = {}

local num_friend = nil
local num_club = nil
local num_union = nil
local number = nil
local msg_number = nil
local num_player = nil
local num_award = nil
local num_bcard = nil
local num_hcard = nil
local num_team = nil

local RED_TYPE = {
	FRIEND_TYPE = 1, 	-- 添加好友请求消息
	CLUB_TYPE 	= 2,	-- 申请加入俱乐部消息、 联盟邀请俱乐部消息
	UNION_TYPE 	= 3, 	-- 申请加入联盟消息
	MSG_TYPE 	= 4,	-- 系统消息
	CARD_TYPE 	= 5,	-- 标准、sng牌局请求消息
	PLAYER_TYPE = 6,	-- MTT牌局请求消息
	AWARD_TYPE	= 7,	-- 我的奖励
	BCARD_TYPE 	= 8, 	-- 组局
	HCARD_TYPE 	= 9, 	-- 赛场
	TEAM_TYPE 	= 10	-- 战队
}

local cards_count = 0

local MESSAGE_PUSH = {}
MESSAGE_PUSH.FRIEND_PUSH 	= {}
MESSAGE_PUSH.CLUB_PUSH 		= {}
MESSAGE_PUSH.UNION_PUSH 	= {}
MESSAGE_PUSH.MSG_PUSH 		= {}
MESSAGE_PUSH.CARD_PUSH 		= {}
MESSAGE_PUSH.PLAYER_PUSH 	= {}
MESSAGE_PUSH.AWARD_PUSH		= {}
MESSAGE_PUSH.BCARD_PUSH		= {}
MESSAGE_PUSH.HCARD_PUSH		= {}
MESSAGE_PUSH.TEAM_PUSH		= {}

local isBro = true


function Notice.broMessage( data )

	local TmpMsg = data or {}

	-- 消息红点推送

	-- 好友、俱乐部消息推送
	if TmpMsg.code == 3060 then
		Notice.requestRedData( true )
	-- 系统消息
	elseif tonumber(TmpMsg.code) == 6001 then
		Notice.requestRedData( true )
		local MessageCtorl = require("message.MessageCtorl")
		if MessageCtorl.isMessageLayer() then
			MessageCtorl.updateMessageList()
		end
	-- 牌局结束移除牌局、组建牌局聊天移除 推送
	elseif TmpMsg.code == 3061 then
		print("移除牌局")
		local CardCtrol = require("cards.CardCtrol")
		if CardCtrol.isCardScene() then
			print("成功移除牌局")
			CardCtrol.updateCardList( TmpMsg.gid )
		end

		local MessageCtorl = require("message.MessageCtorl")
		MessageCtorl.deleteMsg( TmpMsg.ryId )
	-- 牌局请求消息推送
	elseif TmpMsg.code == 3068 then
		local MessageCtorl = require("message.MessageCtorl")
		local MttShowCtorl = require("common.MttShowCtorl")
		
		local msgOk = Storage.getStringForKey("msgSound") or 1
		if tonumber(msgOk) == 0 then
			Single:paltform():shakePhone()
		else
			DZPlaySound.playGameSound("sound/card_entry.mp3", false)
		end

		if isBro then
			isBro = false
		else
			return
		end
		DZAction.delateTime(nil, 1, function (  )
			isBro = true
			if MttShowCtorl.isMttShow() then
				MttShowCtorl.connectMttStat(TmpMsg)
			elseif MessageCtorl.isMessageLayer() then
				MessageCtorl.updateMessageListCard()
			end
		end)
		
		Notice.requestRedData( true )
	-- 牌局请求消息移除推送（标准局）
	elseif TmpMsg.code == 3069 then
		local MessageCtorl = require("message.MessageCtorl")
		MessageCtorl.updateCardsList( TmpMsg.gid, TmpMsg.uids )
	-- mtt审核结果广播
	elseif TmpMsg.code == 3080 then
		DZPlaySound.playGameSound("sound/card_result.mp3", false)

		local MttShowCtorl = require("common.MttShowCtorl")
		MttShowCtorl.connectMttStat(TmpMsg)
		if TmpMsg['current_scores'] then
			Single:playerModel():setPBetNum(TmpMsg['current_scores'])
		end
		
		local GameScene = require 'game.GameScene'
		if TmpMsg['access_res'] == 0 then
			GameScene.mttCheckResult(false)
		elseif TmpMsg['access_res'] == 1 then
			GameScene.mttCheckResult(true)
		end
		
	-- mtt未开启授权通知房主
	elseif TmpMsg.code == 3081 then
		local MttShowCtorl = require("common.MttShowCtorl")
		if isBro then
			isBro = false
		else
			return
		end
		DZAction.delateTime(nil, 3, function (  )
			isBro = true
			MttShowCtorl.connectMttStat(TmpMsg)
		end)
	-- mtt 取消报名通知房主
	elseif TmpMsg.code == 3082 then
		local MttShowCtorl = require("common.MttShowCtorl")
		if isBro then
			isBro = false
		else
			return
		end
		DZAction.delateTime(nil, 3, function (  )
			isBro = true
			MttShowCtorl.connectMttStat(TmpMsg)
		end)
	-- 组局 新牌局红点提示
	elseif TmpMsg.code == 8001 then
		--[[local city_code = NoticeCtrol.getLocalCity()
		if not city_code then
			return
		end
    	-- print(">>>>>>>>>>>>1 city_code :"..city_code)
    	if tostring(city_code) == tostring(TmpMsg.msg) then
    		Notice.requestBuildCard( true, nil, 0 )
    	end
		local myEvent = cc.EventCustom:new("C_Event_Update_MTT_CARD_NUM")
		local customEventDispatch = cc.Director:getInstance():getEventDispatcher()
	    customEventDispatch:dispatchEvent(myEvent)--]]
	-- 赛场 新牌局红点提示
	elseif TmpMsg.code == 9001 then
		--[[Notice.requestRedData( true, 0 )

	    local myEvent = cc.EventCustom:new("C_Event_Update_MTT_CARD_NUM")
		local customEventDispatch = cc.Director:getInstance():getEventDispatcher()
	    customEventDispatch:dispatchEvent(myEvent)--]]
	end
end

-- 标准局本地MTT红点提示
function Notice.requestBuildCard( requestType, funBack, from )
	if funBack then
		funBack()
	end
	--[[
    local city_code = NoticeCtrol.getLocalCity()
    if not city_code then
    	return
    end
    -- print(">>>>>>>>>>>>2 city_code :"..city_code)
	local function response( data )
		if data.code == 0 then
			if data.data["count"] >= 0 then
				MESSAGE_PUSH.BCARD_PUSH = data.data
			end
			if requestType then
				Notice.registRedPoint( 8 )
			end
			--
			if funBack then
				funBack()
			end
		end
	end
	local tabData = {}
	tabData["city_code"] = city_code
	if from then
		tabData["from"] = from
	end
	XMLHttp.requestHttp("localMsgRedList", tabData, response, PHP_POST, true)--]]
end

-- 请求红点数据
function Notice.requestRedData( requestType, from )
	
	do return end
	-- 不执行以下代码

	local function response( data )
		-- dump(data)
		local tmpTab = {}
		tmpTab = data.data or {}
		if #tmpTab ~= 0 then
			for k,v in pairs(tmpTab) do
				if v.type == RED_TYPE.FRIEND_TYPE then
					MESSAGE_PUSH.FRIEND_PUSH = v
				elseif v.type == RED_TYPE.CLUB_TYPE then
					MESSAGE_PUSH.CLUB_PUSH = v
				elseif v.type == RED_TYPE.UNION_TYPE then
					MESSAGE_PUSH.UNION_PUSH = v
				elseif v.type == RED_TYPE.MSG_TYPE then
					MESSAGE_PUSH.MSG_PUSH = v
				elseif v.type == RED_TYPE.CARD_TYPE then
					if v.count >= 0 then
						MESSAGE_PUSH.CARD_PUSH = v
					end
				elseif v.type == RED_TYPE.PLAYER_TYPE then
					if v.count >= 0 then
						MESSAGE_PUSH.PLAYER_PUSH = v
					end
				elseif v.type == RED_TYPE.AWARD_TYPE then
					if v.count >= 0 then
						MESSAGE_PUSH.AWARD_PUSH = v
					end
				elseif v.type == RED_TYPE.HCARD_TYPE then
					if v.count >= 0 then
						MESSAGE_PUSH.HCARD_PUSH = v
					end
				elseif v.type == RED_TYPE.TEAM_TYPE then
					if v.count >= 0 then
						MESSAGE_PUSH.TEAM_PUSH = v
					end
				end
			end
			print("--------->>>>>>>>>>>>>>------------MESSAGE_PUSH-----")
			dump(MESSAGE_PUSH)
			if requestType then
				Notice.registRedPoint( 1 )
				Notice.registRedPoint( 2 )
				Notice.registRedPoint( 3 )
				Notice.registRedPoint( 4 )
				Notice.registRedPoint( 5 )
				Notice.registRedPoint( 6 )
				Notice.registRedPoint( 7 )
				-- Notice.registRedPoint( 9 )
				Notice.registRedPoint( 10 )
			end
		end
	end
	local tabData = {}
	tabData["from"] = 0
	if from then
		tabData["from"] = from
	end
	XMLHttp.requestHttp("messageRedList", tabData, response, PHP_POST, true)
end

function Notice.registRedPoint( push_type )

	do return end
	-- 不执行以下代码

	print("registRedPoint ： 判断数据类型 " .. push_type )
	local noticeNode = {}
	noticeNode = NoticeCtrol.getNoticeNode()
	-- dump(noticeNode)
	if next(noticeNode) == nil then
		return
	end
	
	num_friend = 0
	num_club = 0
	num_union = 0
	number = 0
	msg_number = 0
	num_player = 0
	num_award = 0
	num_bcard = 0
	num_hcard = 0
	num_team = 0
	
	num_player = tonumber(MESSAGE_PUSH.PLAYER_PUSH.count or 0)
	msg_number = NoticeCtrol.getUnLookNum() + tonumber(MESSAGE_PUSH.MSG_PUSH.count or 0) + tonumber(MESSAGE_PUSH.CARD_PUSH.count or 0) + tonumber(MESSAGE_PUSH.PLAYER_PUSH.count or 0)
	print(string.format("unlookNum-->>%d, msgNum-->>%d, cardNum-->>%d", NoticeCtrol.getUnLookNum(), MESSAGE_PUSH.MSG_PUSH.count or 0, MESSAGE_PUSH.CARD_PUSH.count or 0))
	num_friend = tonumber(MESSAGE_PUSH.FRIEND_PUSH.count or 0)
	num_club = tonumber(MESSAGE_PUSH.CLUB_PUSH.count or 0)
	num_union = tonumber(MESSAGE_PUSH.UNION_PUSH.count or 0)
	num_award = tonumber(MESSAGE_PUSH.AWARD_PUSH.count or 0)
	num_bcard = tonumber(MESSAGE_PUSH.BCARD_PUSH.count or 0)
	num_hcard = tonumber(MESSAGE_PUSH.HCARD_PUSH.count or 0)
	num_team = tonumber(MESSAGE_PUSH.TEAM_PUSH.count or 0)

	number = num_friend + num_union + num_award + num_team
	print(string.format("num_bcard-->>%d, num_hcard-->>%d", num_bcard, num_hcard))
	print(string.format("number-->>%d, num_club-->>%d, num_union-->>%d, num_friend->>%d, msg_number->>%d, num_player->>%d", number, num_club, num_union, num_friend, msg_number, num_player))

	if push_type == RED_TYPE.FRIEND_TYPE then
		local idx = 1
		for k,v in pairs(noticeNode) do
			local pos_str = tonumber("1000" .. idx)
			idx = idx + 1
			if noticeNode[pos_str] then
				print("------------- >>>>>>> ------------" .. pos_str)
				Notice.addRedPoint( noticeNode[pos_str], pos_str )
			end
		end

	elseif push_type == RED_TYPE.CLUB_TYPE then
		local idx = 1
		for k,v in pairs(noticeNode) do
			local pos_str = tonumber("2000" .. idx)
			idx = idx + 1
			if noticeNode[pos_str] then
				print("------------- >>>>>>> ------------" .. pos_str)
				Notice.addRedPoint( noticeNode[pos_str], pos_str )
			end
		end
	elseif push_type == RED_TYPE.UNION_TYPE then
		local idx = 1
		for k,v in pairs(noticeNode) do
			local pos_str = tonumber("3000" .. idx)
			idx = idx + 1
			if noticeNode[pos_str] then
				print("------------- >>>>>>> ------------" .. pos_str)
				Notice.addRedPoint( noticeNode[pos_str], pos_str )
			end
		end
	elseif push_type == RED_TYPE.MSG_TYPE or push_type == RED_TYPE.CARD_TYPE then
		local pos_str = 60001
		if noticeNode[pos_str] then
			print("------------- >>>>>>> ------------" .. pos_str)
			Notice.addRedPoint( noticeNode[pos_str], pos_str )
		end
	elseif push_type == RED_TYPE.PLAYER_TYPE then
		local pos_str = {60001, 40001}
		for i,v in ipairs(pos_str) do
			if noticeNode[v] then
				print("------------- >>>>>>> ------------" .. v)
				Notice.addRedPoint( noticeNode[v], v )
			end
		end
	elseif push_type == RED_TYPE.AWARD_TYPE then
		local idx = 1
		for k,v in pairs(noticeNode) do
			local pos_str = tonumber("5000" .. idx)
			idx = idx + 1
			if noticeNode[pos_str] then
				print("------------- >>>>>>> ------------" .. pos_str)
				Notice.addRedPoint( noticeNode[pos_str], pos_str )
			end
		end
	elseif push_type == RED_TYPE.BCARD_TYPE then
		local pos_str = 80001
		if noticeNode[pos_str] then
			print("------------- >>>>>>> ------------" .. pos_str)
			Notice.addRedPoint( noticeNode[pos_str], pos_str )
		end
	elseif push_type == RED_TYPE.HCARD_TYPE then
		local pos_str = 90001
		if noticeNode[pos_str] then
			print("------------- >>>>>>> ------------" .. pos_str)
			Notice.addRedPoint( noticeNode[pos_str], pos_str )
		end
	elseif push_type == RED_TYPE.TEAM_TYPE then
		local pos_str = {100001, 100002}
		for i,v in ipairs(pos_str) do
			if noticeNode[v] then
				print("------------- >>>>>>> ------------" .. v)
				Notice.addRedPoint( noticeNode[v], v )
			end
		end
	end
end

function Notice.addRedPoint( node, pos_id )

	local pos = nil
	local red_count = nil
	
	local width = node:getContentSize().width
	local height = node:getContentSize().height

	if pos_id == POS_ID.POS_10001 or pos_id == POS_ID.POS_30001 or pos_id == POS_ID.POS_50001 or pos_id == POS_ID.POS_100001 then
		pos = cc.p(width-25, height-10)
		-- red_count = number
		red_count = 0
		if number > 0 then
			SMALL_RED_POINT[pos_id] = UIUtil.addPosSprite(ResLib.COM_POINT_RED, pos, node, cc.p(0.5, 0.5))
			SMALL_RED_POINT[pos_id]:setScale(0.5)
		else
			if SMALL_RED_POINT[pos_id] then
				node:removeAllChildren()
				SMALL_RED_POINT[pos_id] = nil
			end
		end
	elseif pos_id == POS_ID.POS_20001 then
		pos = cc.p(width-10, height-20)
		red_count = num_club
	elseif pos_id == POS_ID.POS_60001 then
		pos = cc.p(width-10, height-20)
		red_count = msg_number
	elseif pos_id == POS_ID.POS_40001 then
		pos = cc.p(width-30, height-25)
		red_count = num_player
	elseif pos_id == POS_ID.POS_10002 or pos_id == POS_ID.POS_10003 then
		pos = cc.p(width-150, height/2)
		red_count = num_friend
	elseif pos_id == POS_ID.POS_20002 then
		pos = cc.p(width-150, height/2)
		red_count = num_club
	elseif pos_id == POS_ID.POS_30002 then
		pos = cc.p(width-150, height/2)
		red_count = num_union
	elseif pos_id == POS_ID.POS_50002 then
		pos = cc.p(width-150, height/2)
		red_count = num_award
	elseif pos_id == POS_ID.POS_100002 then
		pos = cc.p(73, height/2+23)
		-- red_count = num_team
		red_count = 0
		if num_team > 0 then
			SMALL_RED_POINT[pos_id] = UIUtil.addPosSprite(ResLib.COM_POINT_RED, pos, node, cc.p(0.5, 0.5))
			SMALL_RED_POINT[pos_id]:setScale(0.5)
			-- SMALL_RED_POINT[pos_id]:setLocalZOrder(100)
		else
			if SMALL_RED_POINT[pos_id] then
				node:removeAllChildren()
				SMALL_RED_POINT[pos_id] = nil
			end
		end
	elseif pos_id == POS_ID.POS_20003 or pos_id == POS_ID.POS_20004 then
		pos = cc.p(width-5, height-5)
		red_count = 0
		if num_club > 0 then
			SMALL_RED_POINT[pos_id] = UIUtil.addPosSprite(ResLib.COM_POINT_RED, pos, node, cc.p(0.5, 0.5))
			SMALL_RED_POINT[pos_id]:setScale(0.5)
		else
			if SMALL_RED_POINT[pos_id] then
				-- SMALL_RED_POINT[pos_id]:removeFromParent()
				node:removeAllChildren()
				SMALL_RED_POINT[pos_id] = nil
			end
		end
	elseif pos_id == POS_ID.POS_30003 or pos_id == POS_ID.POS_30004 then
		pos = cc.p(width-10, height-10)
		red_count = 0
		if num_union > 0 then
			SMALL_RED_POINT[pos_id] = UIUtil.addPosSprite(ResLib.COM_POINT_RED, pos, node, cc.p(0.5, 0.5))
			SMALL_RED_POINT[pos_id]:setScale(0.5)
		else
			if SMALL_RED_POINT[pos_id] then
				-- SMALL_RED_POINT[pos_id]:removeFromParent()
				node:removeAllChildren()
				SMALL_RED_POINT[pos_id] = nil
			end
		end
	elseif pos_id == POS_ID.POS_80001 then
		pos = cc.p(width-130, height-30)
		red_count = 0
		if num_bcard > 0 then
			SMALL_RED_POINT[pos_id] = UIUtil.addPosSprite(ResLib.COM_POINT_RED, pos, node, cc.p(0.5, 0.5))
			SMALL_RED_POINT[pos_id]:setScale(0.5)
		else
			if SMALL_RED_POINT[pos_id] then
				-- SMALL_RED_POINT[pos_id]:removeFromParent()
				node:removeAllChildren()
				SMALL_RED_POINT[pos_id] = nil
			end
		end
	elseif pos_id == POS_ID.POS_90001 then
		pos = cc.p(width-130, height-30)
		red_count = 0
		if num_hcard > 0 then
			SMALL_RED_POINT[pos_id] = UIUtil.addPosSprite(ResLib.COM_POINT_RED, pos, node, cc.p(0.5, 0.5))
			SMALL_RED_POINT[pos_id]:setScale(0.5)
		else
			if SMALL_RED_POINT[pos_id] then
				-- SMALL_RED_POINT[pos_id]:removeFromParent()
				node:removeAllChildren()
				SMALL_RED_POINT[pos_id] = nil
			end
		end
	end

	-- dump(RED_POINT)

	if RED_POINT[pos_id] then
		-- print("已存在红点: " .. pos_id.. "---------->>>> " ..red_count)
		if red_count ~= 0 then
			RED_POINT[pos_id] = nil
			NUMBER_TEXT[pos_id] = nil
		else
			-- print("--------------->>>>>>>> 移除红点" .. pos_id)
			node:removeAllChildren()
			RED_POINT[pos_id] = nil
			NUMBER_TEXT[pos_id] = nil
		end
	end

	-- print("加载红点")
	if red_count < 0 then
		red_count = 0
	end
	if red_count ~= 0 then
		-- print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"..pos_id)
		RED_POINT[pos_id] = UIUtil.addPosSprite(ResLib.COM_POINT_RED, pos, node, cc.p(0.5, 0.5))
		local count_str = nil
		if red_count > 99  then
			RED_POINT[pos_id]:setTexture(ResLib.COM_POINT_RED1)
			count_str = "99+"
		else
			RED_POINT[pos_id]:setTexture(ResLib.COM_POINT_RED)
			count_str = red_count
		end
		NUMBER_TEXT[pos_id] = UIUtil.addLabelArial(count_str, 25, cc.p(RED_POINT[pos_id]:getContentSize().width/2, RED_POINT[pos_id]:getContentSize().height/2), cc.p(0.5, 0.5), RED_POINT[pos_id])
	end
	
end

-- 从服务器移除红点消息
function Notice.deleteMessage( del_type, from )
	do return end
	-- 不执行以下代码

	Notice.clearMessageByType( del_type )
	local function response( data )
		-- dump(data)
		-- if data.code == 0 then
		-- 	Notice.clearMessageByType( del_type )
		-- end
	end
	local tabData = {}
	tabData["type"] = del_type
	tabData["from"] = 0
	if from then
		tabData["from"] = from
	end
	XMLHttp.requestHttp("messageRedDel", tabData, response, PHP_POST, true)
end

function Notice.deleteCardMsg( num )
	do return end
	-- 不执行以下代码

	Notice.clearMessageByType( 5, num )
	local function response( data )
		-- dump(data)
		-- if data.code == 0 then
		-- 	Notice.clearMessageByType( 5, num )
		-- end
	end
	local tabData = {}
	tabData["type"] = 5
	tabData["num"] = -num
	XMLHttp.requestHttp("messageRedDelSome", tabData, response, PHP_POST, true)
end

-- 从服务器移除本地MTT红点消息
function Notice.deleteBuildCard( from )
	do return end
	-- 不执行以下代码
	
	local city_code = NoticeCtrol.getLocalCity()
	if not city_code then
		return
	end
	Notice.clearMessageByType( 8 )
	local function response( data )
		-- if data.code == 0 then
		-- 	Notice.clearMessageByType( 8 )
		-- end
	end
	local tabData = {}
	tabData["city_code"] = city_code
	if from then
		tabData["from"] = from
	end
	XMLHttp.requestHttp("localMsgRedDel", tabData, response, PHP_POST, true)
end

-- 从本地移除红点数据
function Notice.clearMessageByType( push_type, num )
	if push_type == RED_TYPE.FRIEND_TYPE then
		MESSAGE_PUSH.FRIEND_PUSH = {}
	elseif push_type == RED_TYPE.CLUB_TYPE then
		MESSAGE_PUSH.CLUB_PUSH = {}
	elseif push_type == RED_TYPE.UNION_TYPE then
		MESSAGE_PUSH.UNION_PUSH = {}
	elseif push_type == RED_TYPE.MSG_TYPE then
		MESSAGE_PUSH.MSG_PUSH = {}
	elseif push_type == RED_TYPE.CARD_TYPE then
		if num then
			if next(MESSAGE_PUSH.CARD_PUSH) ~= nil then
				MESSAGE_PUSH.CARD_PUSH.count = MESSAGE_PUSH.CARD_PUSH.count - num
				if MESSAGE_PUSH.CARD_PUSH.count <= 0 then
					MESSAGE_PUSH.CARD_PUSH = {}
				end
			end
		end
	elseif push_type == RED_TYPE.PLAYER_TYPE then
		MESSAGE_PUSH.PLAYER_PUSH = {}
	elseif push_type == RED_TYPE.AWARD_TYPE then
		MESSAGE_PUSH.AWARD_PUSH = {}
	elseif push_type == RED_TYPE.TEAM_TYPE then
		MESSAGE_PUSH.TEAM_PUSH = {}
	elseif push_type == RED_TYPE.BCARD_TYPE then
		MESSAGE_PUSH.BCARD_PUSH = {}
	elseif push_type == RED_TYPE.HCARD_TYPE then
		MESSAGE_PUSH.HCARD_PUSH = {}
	end
	dump(MESSAGE_PUSH)
	Notice.registRedPoint( push_type )
end

-- 获取红点数量
function Notice.getMessagePushCount( push_type )
	if push_type == RED_TYPE.FRIEND_TYPE then
		return MESSAGE_PUSH.FRIEND_PUSH
	elseif push_type == RED_TYPE.CLUB_TYPE then
		return MESSAGE_PUSH.CLUB_PUSH
	elseif push_type == RED_TYPE.UNION_TYPE then
		return MESSAGE_PUSH.UNION_PUSH
	elseif push_type == RED_TYPE.MSG_TYPE then
		return MESSAGE_PUSH.MSG_PUSH
	elseif push_type == RED_TYPE.CARD_TYPE then
		return MESSAGE_PUSH.CARD_PUSH
	elseif push_type == RED_TYPE.PLAYER_TYPE then
		return MESSAGE_PUSH.PLAYER_PUSH
	elseif push_type == RED_TYPE.BCARD_TYPE then
		return MESSAGE_PUSH.BCARD_PUSH
	elseif push_type == RED_TYPE.HCARD_TYPE then
		return MESSAGE_PUSH.HCARD_PUSH
	end
end

return Notice