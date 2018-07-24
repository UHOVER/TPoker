local DZChatNet = {}

local function errorMsgShowDlg(data)
	print('errorMsgShow  '..data['msg'])
	DZChat.clickShowDlg(data['msg'])
end

--处理俱乐部或圈子牌局字段
local function handleClubPokerMsg(msgs)
	-- print_f(msgs)
	if not msgs or #msgs == 0 then
		return {}
	end

	local rets = {}
	for i=1,#msgs do
		local msg = msgs[ i ]
		local ret = {}
		local changeType = DZConfig.changePokerType(msg['pokerType'])

		ret['groupId'] = msg['groupId']
		ret['pokerId'] = msg['pokerId']
		ret['ryid'] = msg['ryid']
		ret['pokerName'] = msg['pokerName']
		ret['isUnion'] = tostring(msg['isUnion'])
		ret['pokerType'] = changeType

		--注意广播broClubAndCirclePokerStatusChange也要改
		ret['pokerStatus'] = tostring(msg['pokerStatus'])
		ret['joinStatus'] = tostring(msg['joinStatus'])

		local pokerContent = {}
		local pc = msg['pokerContent']

		--共有
		if pc['playersCount'] then
			pokerContent['playerCount'] = tostring(pc['playersCount'])
		end
		if pc['joinGamePlayerCount'] then
			pokerContent['joinGamePlayerCount'] = tostring(pc['joinGamePlayerCount'])
		end

		if changeType == StatusCode.POKER_GENERAL then
			--标准
			local smallBet = pc['bigBet'] / 2
			pokerContent['blindBet'] = smallBet..'/'..pc['bigBet']
			-- pokerContent['gameDuration'] = tostring(pc['gameDuration'])
			pokerContent['gameDuration'] = DZConfig.secondsToMin(pc['gameDuration'])
			pokerContent['secure'] = pc['secure'] or 0
		elseif changeType == StatusCode.POKER_SNG then
			--sng
			-- local needFee = pc['applyFee'] / 10
			pokerContent['applyFee'] = tostring(pc['applyFee'])
			pokerContent['originBet'] = tostring(pc['originBet'])
			pokerContent['growBlindTime'] = DZConfig.getGrowBlindTime(pc['growBlindTime'])
			pokerContent['openGPS'] = tostring(pc['open_gps'] or 0)

			local rewards = DZConfig.getSngRewards(pc['playersCount'], pc['applyFee'])
			pokerContent['champion'] = rewards[1]
			pokerContent['runner-up'] = rewards[2]
			pokerContent['secondRunner-up'] = rewards[3]
			pokerContent['runner_up'] = rewards[2]
			pokerContent['secondRunner_up'] = rewards[3]
		elseif changeType == StatusCode.POKER_MTT then
			--mtt
			pokerContent['applyFee'] = tostring(pc['applyFee'])
			pokerContent['isEntry'] = msg['is_entry']
			pokerContent['originBet'] = tostring(pc['originBet'])
			pokerContent['growBlindTime'] = DZConfig.getGrowBlindTime(pc['growBlindTime'])
		end

		ret['pokerContent'] = pokerContent

		table.insert(rets, ret)
	end

	return rets
end

--sng报名
function DZChatNet.netSNGSignUp(tabStr)
	local retStr = tabStr

	local function responseSNG(data)
		local gid = retStr['pokerId']

		--进入游戏、等待房主同意
		if data['is_enter'] == 1 then
			DZChat.clickRemoveChatLayer(retStr['ryid'])

			local GameScene = require 'game.GameScene'
            GameScene.startScene(gid)
        else
        	DZChat.clickPromptMsg(retStr['ryid'], '申请成功等待房主同意')	
        end
	end

	local tab = {}
	tab['gid'] = retStr['pokerId']
	tab['mod'] = StatusCode.GLSTATUS_COMMON
	
	--只有俱乐部用到：圈子、大厅的sng没有用到
	local clubId = retStr['clubId']
	local function response(data)
		--返回3证明牌局结束
		if data['status'] == 3 then
			DZChat.clickShowDlg("该牌局已经结束！", retStr['ryid'])
			DZChat.clubAndCircleEndPoker(retStr['pokerId'])
		else
			--error：已经报名
			MainCtrol.sngSignUp(tab['gid'], clubId, retStr, responseSNG, errorMsgShowDlg)
		end	
	end

	MainCtrol.filterNet("getGlStatus", tab, response, PHP_POST) 
end


--标准牌局、俱乐部、圈子 进入游戏
function DZChatNet.netStartStandard(tabStr)
	local retStr = tabStr
	local tab = {}
	
	tab['gid'] = retStr['pokerId']
	tab['club_id'] = retStr['club_id']
	tab['mod'] = StatusCode.GLSTATUS_COMMON

	local club_id = nil
	if retStr['club_id'] then
		club_id = retStr['club_id']
	end

	local function response(data)
		--返回3证明牌局结束
		if data.status == 3 then
		    DZChat.clickShowDlg("该牌局已经结束！", retStr['ryid'])
		    DZChat.clubAndCircleEndPoker(retStr['pokerId'])
		else
			DZChat.clickRemoveChatLayer(retStr['ryid'])
			local GameScene = require 'game.GameScene'
			-- 联盟标准局绑定一个俱乐部id
			GData.setUclubId(club_id)
		    GameScene.startScene(tab['gid'])
		end	
	end

	MainCtrol.filterNet("getGlStatus", tab, response, PHP_POST)
end


--进入好友、圈子、俱乐部聊天
local _chatId = nil
local _chatMod = nil
function DZChatNet.netEnterChat(id, mod, isBefData)
	if isBefData then
		if _chatMod == nil or _chatId == nil then
			assert(nil, 'netEnterChat DZChatNet')
		end
		id = _chatId
		mod = _chatMod
	end

	local function response(data)
		_chatId = id
		_chatMod = mod

		local chatType = DZChat.TYPE_CLUB
		local tName = 'groupId'

		local pokerInfo = handleClubPokerMsg(data['pokerInfo'])

		local titleName = data['name']

		if not titleName then
			titleName = ''
		end

		local msg = DZChat.getMsgJson(data['name'], data['avatar'], id, data['ryid'])
		--创始俱乐部
		if data['isHost'] == 1 then
			msg['isHost'] = 'true'
		end

		--俱乐部、圈子、好友
		if mod == StatusCode.CHAT_CLUB then
			chatType = DZChat.TYPE_CLUB
		elseif mod == StatusCode.CHAT_CIRCLE then
			chatType = DZChat.TYPE_GROUP
			-- 是否允许圈子成员开局
			if data["begin_root"] == 1 then
				msg["isOpening"] = 'true'
			else
				msg["isOpening"] = 'false'
			end
			if data["create_true"] == 1 then
				msg["isCreate"] = 'true'
			else
				msg["isCreate"] = 'false'
			end
			titleName = '圈子'
		elseif mod == StatusCode.CHAT_FRIEND then
			chatType = DZChat.TYPE_FRIEND
			tName = 'friendId'

			local rets = {}
			local tab = DZChat.getPlayerJson(id, data['avatar'], data['name'], data['ryid'])
			table.insert(rets, tab)

			data['usersMsg'] = rets
		end

		local usersMsg = data['usersMsg']
		local typeMsg = {}
		typeMsg['gamingNum'] = tostring(data['gamingNum'])
		typeMsg[ tName ] = id

		DZChat.showChatLayer(data['ryid'], titleName, chatType, usersMsg, typeMsg, msg, pokerInfo)

		--授权申请:俱乐部、圈子、好友
		if data['isHaveApply'] == 1 then
			DZChat.displayApplySignUp(data['ryid'])
		end
    end

    local tab = {}
    tab['mod'] = mod
    tab['id'] = id
    MainCtrol.filterNet(PHP_GET_CHAT_MSG, tab, response, PHP_POST)
end


function DZChatNet.getClubAndCircleNewPokerData(msg)
	local msgTabs = handleClubPokerMsg({msg})
	if #msgTabs == 1 then
		return msgTabs[ 1 ]
	end
end


return DZChatNet