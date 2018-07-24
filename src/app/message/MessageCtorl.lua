local MessageCtorl = {}

local chat_id = nil

local isChatType = 0

local isMsgLayer = false

local cardsNotice = false

MessageCtorl.CHAT_USER 		= 1
MessageCtorl.CHAT_CLUB 		= 2
MessageCtorl.CHAT_CIRCLE 	= 3

-- 聊天列表
local ChatList = {}

-- 系统公告
local sysData = {}

-- 牌局请求消息
local cardsData = {}

function MessageCtorl.setChatType( chatType )
	isChatType = chatType
end

function MessageCtorl.getChatType(  )
	local chatType = isChatType
	isChatType = 0
	return chatType
end

function MessageCtorl.dataStatHTTP_RYID( funback )
	local function response( data )
		dump(data)
		if data.code == 0 then
			if #data.data.gids == 0 then
				-- funback()
				MessageCtorl.dataStatSysNotice( nil, funback )
			else
				for k,v in pairs(data.data.gids) do
					MessageCtorl.deleteMsg( v )
					if k == #data.data.gids then
						-- funback()
						MessageCtorl.dataStatSysNotice( nil, funback )
					end
				end
			end
		end
	end
	XMLHttp.requestHttp("preTableRemoveList", {}, response, PHP_POST)
end

function MessageCtorl.deleteMsg( ryid )
	DZChat.clickClearRecord(ryid, DZChat.TYPE_GAME_STANDARD)
	DZChat.getChatList()
	MessageCtorl.removeHTTP_RYID( ryid )
end

function MessageCtorl.removeHTTP_RYID( ryid )
	local function response( data )
		dump(data)
	end
	local tabData = {}
	tabData["ryId"] = ryid
	XMLHttp.requestHttp("preTableRemoveDel", tabData, response, PHP_POST, true)
end

function MessageCtorl.setChatData( id )
	chat_id = nil
	chat_id = id
end

function MessageCtorl.getChatData(  )
	return chat_id
end

-- 添加消息列表
function MessageCtorl.setChatList( data )
	ChatList = {}
	local myId = Single:playerModel():getId()
	for k,v in pairs(data) do
		local tmpTab = {}
		tmpTab = v
		tmpTab["isTouch"] = 0

		local key = nil
		local chatType = tonumber(v.chatType)
		if chatType == DZChat.TYPE_CLUB or  chatType == DZChat.TYPE_GROUP  then
			key = myId .. v.msgRYId
			-- print(">>>>>>>>>>>>>>>>>> " .. key)
			local isOk = Storage.getStringForKey(key)
			-- print("<<<<<<<<<<<<<<<<<<" .. isOk .. "isOk")
			if isOk == "" or isOk == nil then
				-- print("isOk是一个空值")
				tmpTab["isSound"] = 1
			else
				tmpTab["isSound"] = tonumber(isOk)
			end
		elseif chatType == DZChat.TYPE_FRIEND then
			local siadId = tonumber(v["siadId"])
			if tonumber(myId) == siadId then
				key = myId .. v.msgRYId
			else
				key = myId .. v.saidRYId
			end
			-- print(">>>>>>>>>>>>>>>>>> " .. key)
			local isOk = Storage.getStringForKey(key)
			-- print("<<<<<<<<<<<<<<<<<<" .. isOk .. "isOk")
			if isOk == "" or isOk == nil then
				tmpTab["isSound"] = 1
			else
				tmpTab["isSound"] = tonumber(isOk)
			end
		else
			tmpTab["isSound"] = 2
		end
		ChatList[#ChatList+1] = tmpTab
	end
end

-- 获得聊天列表
function MessageCtorl.getChatList(  )
	return ChatList
end

function MessageCtorl.setIsMsgLayer( isLayer )
	isMsgLayer = isLayer
end

function MessageCtorl.isMessageLayer(  )
	return isMsgLayer
end

function MessageCtorl.updateMessageList(  )
	local MessageLayer = require("message.MessageLayer")
	DZAction.delateTime(nil, 0.2, function()
		MessageCtorl.dataStatSysNotice( function (  )
			MessageLayer.updateSystemMsg( true )
		end, nil )
	end)
end

function MessageCtorl.dataStatSysNotice( funback1, funback2 )
	local content = ""
	local function response( data )
		dump(data)
		if data.code == 0 then
			MessageCtorl.setSysData( data.data )
			if funback1 then
				funback1()
			end
			if funback2 then
				MessageCtorl.dataStatCardNotice( funback2 )
			end
		end
	end
	local tabData = {}
	XMLHttp.requestHttp("getSimpleAnnounce", tabData, response, PHP_POST)
end

function MessageCtorl.setSysData( data )
	sysData = {}
	sysData = data
end

function MessageCtorl.getSysData(  )
	return sysData
end

function MessageCtorl.setIsCardsNotice( isCards )
	cardsNotice = isCards
end

function MessageCtorl.getIsCardsNotice(  )
	return cardsNotice
end

function MessageCtorl.dataStatCardNotice( funback , noLoading)
	local function response( data )
		-- dump(data)
		if data.code == 0 then
			MessageCtorl.buildCardsData( data.data )
			funback(data.data)
		end
	end
	XMLHttp.requestHttp("getTableHandleMessage", {}, response, PHP_POST, noLoading)
end

function MessageCtorl.buildCardsData( data )
	local cardData = {}
	local tmpTab = {}
	tmpTab = data
	if not tmpTab then
		MessageCtorl.setCardData( cardData )
		return cardData
	end
	local baseTab = {}
	local applyTab = {}

	local function buildData(  )
		for i=1, #tmpTab do
			for k,v in pairs(applyTab[i]) do
				local tmpData = {}
				tmpData = v
				-- tmpData["cost"] = baseTab[i].cost
				tmpData["gid"] = baseTab[i].gid
				tmpData["game_mod"] = baseTab[i].game_mod
				tmpData["host_name"] = baseTab[i].host_name
				tmpData["table_name"] = baseTab[i].table_name
				tmpData["isAgree"] = 2
				if k == 1 then
					tmpData["first"] = 1
				else
					tmpData["first"] = 0
				end
				table.insert(cardData, tmpData)
			end
		end
	end

	for k,v in pairs(tmpTab) do
		-- dump(v)
		local baseData = {}
		-- baseData["cost"] = v.cost
		baseData["game_mod"] = v.game_mod
		baseData["gid"] = v.gid
		baseData["host_name"] = v.host_name
		baseData["table_name"] = v.table_name
		applyTab[k] = v.apply_data

		dump(baseData)
		baseTab[k] = baseData
		if k == #tmpTab then
			-- dump(baseTab)
			-- dump(applyTab)
			buildData()
		end
	end
	
	MessageCtorl.setCardData( cardData )
end

function MessageCtorl.setCardData( data )
	cardsData = {}
	cardsData = data
end

function MessageCtorl.getCardData( is_rm )
	if is_rm then
		for k,v in pairs(cardsData) do
			if v.isAgree < 2 then
				cardsData[k] = nil
			end
		end
	end
	return cardsData
end

function MessageCtorl.removeCardData(apply_id, isAgree)
	local tmpTab = MessageCtorl.getCardData()
	for k,v in pairs(tmpTab) do
		if tonumber(apply_id) == tonumber(v.apply_id) then
			if isAgree then
				tmpTab[k]["isAgree"] = 1
			else
				tmpTab[k]["isAgree"] = 0
			end
			break
		end
	end
	MessageCtorl.setCardData( tmpTab )
end

function MessageCtorl.updateCardsList( gid, uids )
	local tmpTab = MessageCtorl.getCardData()
	local CardsNotice = require("message.CardsNotice")
	local isMsgLayer = MessageCtorl.isMessageLayer()
	local isCardsNotice = MessageCtorl.getIsCardsNotice()
	for key,val in pairs(uids) do
		for k,v in pairs(tmpTab) do
			if tonumber(gid) == tonumber(v.gid) and tonumber(val) == tonumber(v.apply_id) then
				-- Notice.clearMessageByType( 5 )
				table.remove(tmpTab, k)
				MessageCtorl.setCardData( tmpTab )
				if isCardsNotice then
					CardsNotice.updateCardsList()
				elseif isMsgLayer then
					local MessageLayer = require("message.MessageLayer")
					MessageLayer.updateCardsMsg( true )
				end
			end
			if key == #uids then
				Notice.deleteCardMsg( #uids )
			end
		end
	end
end

function MessageCtorl.buildCardsNotice(  )
	local cardTab = {}
	
	local tmpTab = MessageCtorl.getCardData(true)
	if next(tmpTab) == nil then
		return cardTab
	end

	-- local cardCount = #tmpTab or 0
	local cardMsg = tmpTab[1].apply_name or ""
	local cardTime = tmpTab[1].apply_time or 0
	-- cardTab["count"] = cardCount
	cardTab["msg"] = cardMsg
	cardTab["time"] = cardTime
	return cardTab
end

function MessageCtorl.updateMessageListCard(  )
	local MessageLayer = require("message.MessageLayer")
	local CardsNotice = require("message.CardsNotice")
	local isMsgLayer = MessageCtorl.isMessageLayer()
	local isCardsNotice = MessageCtorl.getIsCardsNotice()
	
	DZAction.delateTime(nil, 0.2, function()
		MessageCtorl.dataStatCardNotice( function (  )
			-- MessageLayer.updateCardsMsg( true )
			if isCardsNotice then
				CardsNotice.updateCardsList()
			else
				local MessageLayer = require("message.MessageLayer")
				MessageLayer.updateCardsMsg( true )
			end
		end)
	end)
end

return MessageCtorl