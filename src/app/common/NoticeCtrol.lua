local NoticeCtrol = {}

local noticeNode = {}

local totalChatNum = 0

POS_ID = {
	-- 好友
	POS_10001 = 10001,
	POS_10002 = 10002,
	POS_10003 = 10003,

	-- 俱乐部
	POS_20001 = 20001,
	POS_20002 = 20002,
	POS_20003 = 20003,
	POS_20004 = 20004,

	-- 联盟
	POS_30001 = 30001,
	POS_30002 = 30002,
	POS_30003 = 30003,
	POS_30004 = 30004,

	-- 系统消息
	POS_60001 = 60001,

	-- 授权玩家报名
	POS_40001 = 40001,

	-- 我的奖励
	POS_50001 = 50001,
	POS_50002 = 50002,

	-- 组局
	POS_80001 = 80001,
	-- 赛场
	POS_90001 = 90001,

	--战队
	POS_100001 = 100001,
	POS_100002 = 100002
}

-- 当前所在城市
local cityCode = nil

function NoticeCtrol.setNoticeNode( id, node )
	do return end
	-- 不执行以下代码
	
	if noticeNode[id] then
		-- print("node -->> " .. id .."已存在, 置为nil重新赋值")
		noticeNode[id] = nil
	end

	noticeNode[id] = node

	-- local function onEvent(event)
	-- 	if event == "exit" then
	-- 		noticeNode[id] = nil
	-- 	end
	-- end
	-- local tnode = cc.Node:create()
	-- tnode:registerScriptHandler(onEvent)
	-- node:addChild(tnode)
end

function NoticeCtrol.getNoticeNode(  )
	return noticeNode
end

function NoticeCtrol.removeNoticeNode(  )
	noticeNode = {}
end

function NoticeCtrol.removeNoticeById( id )
	if noticeNode[id] then
		noticeNode[id] = nil
		-- dump(noticeNode)
	end
end

-- 融云聊天未读消息
function NoticeCtrol.setUnLoookNum( data )
	-- dump(data)
	totalChatNum = tonumber(data.unlookNum)
	Notice.registRedPoint( 4 )
end

function NoticeCtrol.getUnLookNum(  )
	return totalChatNum
end

function NoticeCtrol.setLocalCity( city )
	cityCode = city
end

function NoticeCtrol.getLocalCity()
	return cityCode
end

return NoticeCtrol