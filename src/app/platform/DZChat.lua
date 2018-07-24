local DZChat = {}
local DZChatNet = require ('platform.DZChatNet')

local _platform = cc.Application:getInstance():getTargetPlatform()

DZChat.TYPE_CLUB = 1
DZChat.TYPE_GROUP = 2
DZChat.TYPE_FRIEND = 3
DZChat.TYPE_GAME_STANDARD = 4
DZChat.TYPE_GAME_SNG = 5
DZChat.TYPE_GAME_MTT = 6

local isShowChat = false

local _lua = nil
local _className = ""
local NO_SHOW_TAG = -1
local _showTag = NO_SHOW_TAG	--展示界面类型1~5
local _showRYid = nil			--展示界面的讨论组id

if (cc.PLATFORM_OS_IPHONE == _platform) or (cc.PLATFORM_OS_IPAD == _platform) or (cc.PLATFORM_OS_MAC == _platform)  then
	_lua = require "cocos.cocos2d.luaoc"
	_className = "DZChat"
elseif _platform == cc.PLATFORM_OS_ANDROID then
	_lua = require "cocos.cocos2d.luaj"
	_className = "org/cocos2dx/lua/DZChat"
else
	assert(nil, 'DZChat is not platform')
end


local function jsonToTab(json)
	return jsonStr.decode(json, 1)
end

local function tabToJson(tab)
	return jsonStr.encode(tab)
end

local function setCallNative(cname, fname, args, isNull, linkStr, javaArgs)
	local function delayCall()
		local ok = nil
		local ret = nil

		if not linkStr then
			linkStr = ''
		end

		--android
		if not javaArgs then
			javaArgs = '(Ljava/lang/String;)V'
		end

		if _platform == cc.PLATFORM_OS_ANDROID then
			local jsonStr = linkStr..tabToJson(args)
			local tabStr = {jsonStr}
			ok,ret  = _lua.callStaticMethod(cname, fname, tabStr, javaArgs)
		else
			local tab = {}
			tab['JSON'] = linkStr..tabToJson(args)
			-- print_f(tab)
			if isNull then
				ok,ret  = _lua.callStaticMethod(cname, fname)
			else
				ok,ret  = _lua.callStaticMethod(cname, fname, tab)
			end
		end

		if not ok then
		    -- assert(nil, 'setCallNative '..fname)
		end
	end

	if _platform == cc.PLATFORM_OS_ANDROID then
		DZSchedule.schedulerOnce(0.05, delayCall)
	else
		delayCall()
	end
end

local function errorMsgFunc(data)
	if DZChat.isShowChatView() then
		DZChat.clickPromptMsg(_showRYid, data['msg'])
	end
end



--init rong yun
function DZChat.rongyuInit(token)
	local args = {}
	args['TOKEN'] = token
	setCallNative(_className, 'rongyuInit', args)
end



--show layer
function DZChat.showChatLayer(ryid, title, chatType, usersMsg, typeMsg, msg, pokerInfo)
	local args = {}
	args['token'] = XMLHttp.getGameToken()
	args['myid'] = Single:playerModel():getId()
	args['myRYId'] = Single:playerModel():getRYId()

	args['ryid'] = tostring(ryid)
	args['title'] = title
	args['chatType'] = tostring(chatType)

	args['typeMsg'] = typeMsg
	args['usersMsg'] = usersMsg

	msg['chatType'] = tostring(chatType)
	args['msg'] = msg

	args['pokerInfo'] = pokerInfo

	-- print_f(args)
 	setCallNative(_className, 'showChatLayer', args)

 	_showTag = chatType
 	_showRYid = ryid

 	isShowChat = true

 	--DZAction.delateTime(nil, time, back)
 	--DZChat.clickShowTimeDlg("你的比赛60秒后开始", "60秒", "23221")
end

-- 成员返回到聊天
function DZChat.showChatChangeData(ctab)
	local ctype = tonumber(ctab['chatType'])
	if ctype == DZChat.TYPE_GAME_STANDARD or ctype == DZChat.TYPE_GAME_SNG then
		MainCtrol.enterGame(ctab['typeMsg']['pokerId'], MainCtrol.MOD_GID, function()end)	
		return
	end
	DZChat.showChatLayer(ctab['ryid'], ctab['title'], ctab['chatType'], ctab['usersMsg'], ctab['typeMsg'], ctab['msg'], ctab['pokerInfo'])
end


--lua call native
function DZChat.clickCloseNotice(id, chatType)
	local args = {}
	args['id'] = id
	args['chatType'] = tostring(chatType)
	setCallNative(_className, 'clickCloseNotice', args)
end

function DZChat.clickClearRecord(ryid, chatType)
	local args = {}
	args['ryid'] = ryid
	args['chatType'] = tostring(chatType)
	setCallNative(_className, 'clickClearRecord', args)
end

function DZChat.clickUnreadRecord(ryid, chatType)
	local args = {}
	args['ryid'] = ryid
	args['chatType'] = tostring(chatType)
	setCallNative(_className, 'clickUnreadRecord', args)
end

function DZChat.clickBuildGame(ryid, chatType, content, chatData)
	local args = {}
	args['ryid'] = ryid
	args['chatType'] = tostring(chatType)
	args['content'] = content
	args['msg'] = chatData['msg']

	local link = '^yidaWuXIAn$#@*益达normal'
	if tonumber(content['gameType']) == 1 then
		link = '^yidaWuXIAn$#@*益达normal'
	elseif tonumber(content['gameType']) == 2 then
		link = '^yidaWuXIAn$#@*益达sng'
	elseif tonumber(content['gameType']) == 3 then
		link = '^yidaWuXIAn$#@*益达mtt'
	end
	setCallNative(_className, 'clickBuildGame', args, false, link)	
end

--sng
function DZChat.clickRemoveChatLayer(ryid)
	local args = {}
	args['ryid'] = ryid	
	setCallNative(_className, 'clickRemoveChatLayer', args)
end

function DZChat.clickPromptMsg(ryid, msg)
	local args = {}
	args['ryid'] = ryid
	args['msg'] = msg
	setCallNative(_className, 'clickPromptMsg', args)
end

--弹出对话框
function DZChat.clickShowDlg(msg, ryid)
	if not ryid then
		ryid = _showRYid
	end
	local args = {}
	args['msg'] = msg
	args['ryid'] = ryid
	setCallNative(_className, 'showDlg', args)
end

--native call lua
local function delayBack(backFunc, tab)
	DZSchedule.schedulerOnce(0.05, function()
		backFunc()
	end)
end

----全游戏通知比赛开始相关mtt
---弹出各自系统对话框的接口
function DZChat.clickShowTimeDlg(msgName, msgTime, pid)
	local args = {}
	args['msgName'] = tostring(msgName)
	args['msgTime'] = tostring(msgTime)
	args['pid'] = tostring(pid)
	setCallNative(_className, 'showTimeDlg', args)
end

----点击进入后的接口回调
--function g_playVoiceTime(str)
function g_playInGame(str)
	print("iinnnasdasd="..str)
	print("关闭所有聊天界面")

	DZChat.removeAllChatLayer()

	local function backFunc()
		local tab = jsonToTab(str)
		print("进入游戏的id = "..tostring(tab['pid']))
		local CardCtrol = require("cards.CardCtrol")
		local gid = tab['pid']
		CardCtrol.enterMtt( gid )
	end
	delayBack(backFunc)
end

--移除所有聊天界面
function DZChat.removeAllChatLayer()
	local args = {}
	--setCallNative(_className, 'removeAllChatLayer', nil)
	setCallNative(_className, 'removeAllChatLayer', args)
end

-----------end


function g_backReturn(str)
 	_showRYid = nil
 	isShowChat = false

 	delayBack(function()
	 	DZChat.getChatList()
	end, nil)
end


-- 点击成员头像
function g_backHead(str)
	local function backFunc()
		local tab = jsonToTab(str)
		local currScene = cc.Director:getInstance():getRunningScene()
		local personInfo = require("friend.PersonInfo")
		local layer = personInfo:create()
		currScene:addChild(layer, StringUtils.getMaxZOrder(currScene))
		layer:createLayer(tab, true)
	end
	delayBack(backFunc)
end

function g_backLayerMsg(str)
	local function backFunc()
		local tab = jsonToTab(str)
		local ctype = tonumber(tab['chatType'])
		local MessageLayer = require 'message.MessageLayer'

		if ctype == DZChat.TYPE_GROUP then
			
			MessageLayer.lookCircleMsg(tab)
		elseif ctype == DZChat.TYPE_CLUB then

			MessageLayer.lookClubMsg(tab)
		elseif ctype == DZChat.TYPE_FRIEND then
			MessageLayer.lookFriendMsg( tab )
		end
	end
	delayBack(backFunc)
end

function g_backBuildClubOrGroupGame(str)
	local function backFunc()
		local tab = jsonToTab(str)
		local setCard = require("common.SetCards")
		local layer = setCard:create()
	    local runScene = cc.Director:getInstance():getRunningScene()
		runScene:addChild(layer, StringUtils.getMaxZOrder(runScene))

		if DZChat.TYPE_CLUB == tonumber(tab['chatType']) then
			layer:createLayer(tab['typeMsg']['groupId'], "club")
		elseif DZChat.TYPE_GROUP == tonumber(tab['chatType']) then
			layer:createLayer(tab['typeMsg']['groupId'], "circle")
		end
	end

	delayBack(backFunc)
end

function g_backStartClubOrGroupGame(str)
	local function backFunc()
		local retStr = jsonToTab(str)
		DZChatNet.netStartStandard(retStr)
	end

	delayBack(backFunc)
end

--standard
function g_backStartGame(str)
	local function backFunc()
		local tab = jsonToTab(str)
	    DZChat.startGame(tab['typeMsg']['pokerId'])
	end
	delayBack(backFunc)
end

--sng、standard、mtt
function g_backExitGame(str)
	local function backFunc()
		local tab = jsonToTab(str)
		if tonumber(tab['chatType']) == DZChat.TYPE_GAME_STANDARD then
		    DZChat.exitDisbandGame(tab['typeMsg']['pokerId'], function()end)
		elseif tonumber(tab['chatType']) == DZChat.TYPE_GAME_SNG then
		    DZChat.exitDisbandGame(tab['typeMsg']['pokerId'], function()end)
		elseif tonumber(tab['chatType']) == DZChat.TYPE_GAME_MTT then
			print("mtt退出")
			DZChat.exitDisbandGame(tab['typeMsg']['pokerId'], function()end, "mtt_general")
		end
	end
	delayBack(backFunc)
end

--解散游戏
function g_backCancelGame(str)
	local function backFunc()
		local tab = jsonToTab(str)
		if tonumber(tab['chatType']) == DZChat.TYPE_GAME_STANDARD then
		    DZChat.exitDisbandGame(tab['typeMsg']['pokerId'], function()end)
		elseif tonumber(tab['chatType']) == DZChat.TYPE_GAME_SNG then
		    DZChat.exitDisbandGame(tab['typeMsg']['pokerId'], function()end)
		elseif tonumber(tab['chatType']) == DZChat.TYPE_GAME_MTT then
			print("mtt解散")
			DZChat.exitDisbandGame(tab['typeMsg']['pokerId'], function()end, "mtt_general")
		end
	end
	delayBack(backFunc)
end


--sng报名
function g_backSNGSignUp(str)
	local function backFunc()
		local retStr = jsonToTab(str)
		DZChatNet.netSNGSignUp(retStr)
	end
	delayBack(backFunc)
end

--查看申请列表：sng或标准
function g_backLookApplayList(str)
	local function backFunc()
		ViewCtrol.showApplyList(_showTag)
	end
	delayBack(backFunc)
end

--进入sng牌局
function g_backIntoSngGame(str)
	local function backFunc()
		local tab = jsonToTab(str)
		local gid = tab['pokerId']
		local GameScene = require 'game.GameScene'
	    GameScene.startScene(gid) 
	end
	delayBack(backFunc)
end

-- 点击MTT报名
function g_backMTTSignUp(str)
	local function backFunc()
		local tab = jsonToTab(str)
		dump(tab)
		local MttShowCtorl = require("common.MttShowCtorl")
		MttShowCtorl.dataStatStatus( function (  )
			DZChat.clickRemoveChatLayer(tab.ryid)
			MttShowCtorl.MttSignUp(tab)
		end, tab )
	end
	delayBack(backFunc)
end

--消息广播
function g_backBroChatMsg(str)
	local function backFunc()
		local tab = jsonToTab(str)
		local GameScene = require 'game.GameScene'
		if tab['msgRYId'] == _showRYid or GameScene.isDisGameScene() then
			return
		end

		dump(tab)
		if next(tab) ~= nil then
			local msgOk = Storage.getStringForKey("msgSound") or 1
			if tonumber(msgOk) == 0 then
				Single:paltform():shakePhone()
			else
				local key = nil
				local myId = Single:playerModel():getId()
				if tonumber(tab.chatType) == DZChat.TYPE_CLUB then
					key = myId .. tab.msgRYId
				elseif tonumber(tab.chatType) == DZChat.TYPE_GROUP then
					key = myId .. tab.msgRYId
				elseif tonumber(tab.chatType) == DZChat.TYPE_FRIEND then
					local siadId = tonumber(tab.siadId)
					if tonumber(myId) == tab.siadId then
						key = myId .. tab.msgRYId
					else
						key = myId .. tab.saidRYId
					end
				end
				-- print("-------------------"..key)
				local isOk = Storage.getStringForKey(key)
				-- print("-------------------消息广播" .. isOk .. "<<<<<<")
				if isOk == "" or isOk == nil then
					isOk = 1
				end

				if tonumber(isOk) == 0 then
					print("消息震动")
					Single:paltform():shakePhone()
				else
					DZPlaySound.playGameSound("sound/shake_match.mp3", false)
				end
			end
		end

		DZChat.getChatList()
		DZChat.getUnlookNum()
	end
	delayBack(backFunc)
end

--历史消息
function g_backSetChatList(str)
	local function backFunc()
		local tab = jsonToTab(str)
		DZChat.getUnlookNum()
		
		local MessageCtorl = require("message.MessageCtorl")
		local MessageLayer = require("message.MessageLayer")
		MessageCtorl.setChatList( tab.messageList )
		MessageLayer.buildData(  )
	end
	delayBack(backFunc)
end

--所有未读消息数
function g_backSetUnlookNum(str)
	local function backFunc()
		local tab = jsonToTab(str)
		NoticeCtrol.setUnLoookNum( tab )
	end
	delayBack(backFunc)
end

function g_backInitFailed(  )
	print("融云token 连接失败！")
	-- ViewCtrol.showMsg('融云token 连接失败！')
end

function g_backConnectFailed(  )
	print("融云token 初始化失败！")
	-- ViewCtrol.showMsg('融云token 初始化失败！')
end

function DZChat.breakRYConnect(  )
	local args = {}
	args['test'] = 'test'
	setCallNative(_className, 'breakRYConnect', args, nil, nil,'(Ljava/lang/String;)Ljava/lang/String;')
end

--得到未读消息数
function DZChat.getUnlookNum()
	local args = {}
	args['test'] = 'test'
	setCallNative(_className, 'getUnlookNum', args, nil, nil,'(Ljava/lang/String;)Ljava/lang/String;')
end

--得到历史消息
function DZChat.getChatList()
	local args = {}
	local msgList = {}
	args['test'] = 'test'
	setCallNative(_className, 'getChatList', args, nil, nil,'(Ljava/lang/String;)Ljava/lang/String;')
	return {} 
end


--转换数据
function DZChat.enterBefGame(data, gid)
	local usersMsg = {}
	local umsg = data['players']
	for i=1,#umsg do
		local msg = DZChat.getPlayerJson(umsg[i]['id'], umsg[i]['avatar'], umsg[i]['name'], umsg[i]['rongyun_id'])
		table.insert(usersMsg, msg)
	end

	local ptype = '普通局'
    local typeMsg = {}
    local tchatType = DZChat.TYPE_GAME_STANDARD

    --房主
    local ism = false
	if data['is_owner'] == 1 then
		ism = true
	end
	   	 
    if data['game_mod'] == 'general' then
    	ptype = '普通局'
    	tchatType = DZChat.TYPE_GAME_STANDARD

        typeMsg = MainCtrol.getStandardChatMsg(data, ism)
    elseif data['game_mod'] == 'sng' then
    	ptype = 'SNG局'
    	tchatType = DZChat.TYPE_GAME_SNG

    	data['increase_time'] = tonumber(data['increase_time']) / 60
    	typeMsg = MainCtrol.getSngChatMsg(data, ism)
    elseif data['game_mod'] == 'mtt_general' then
    	ptype = 'MTT局'
    	tchatType = DZChat.TYPE_GAME_MTT
    	data["mtt_id"] = data["gid"]
    	data["invite_code"] = data["join_code"]
    	data['increase_time'] = tonumber(data['increase_time']) / 60
    	typeMsg = MainCtrol.getMttChatMsg(data, ism)
    end

    --组建牌局:标准、sng
    if data['is_apply'] == 1 then
		DZChat.displayApplySignUp(data['Rgid'])
	end

	local msg = DZChat.getMsgJson(data['create_user_name'], data['create_user_avatar'], data['gid'], data['Rgid'], gid)
	if data['game_mod'] == 'general' then
		msg['secure'] = data['secure']
	end

    DZChat.showChatLayer(data['Rgid'], ptype, tchatType, usersMsg, typeMsg, msg)
end



--net
--退出/解散
function DZChat.exitDisbandGame(gid, funcBack, game_mod)
   	local function response(data)
       funcBack()
    end

    local tab = {}
    tab['gid'] = gid
    if game_mod then
    	tab["mod"] = game_mod
    else
    	-- 非MTT
    	tab["mod"] = 0
    end
    MainCtrol.filterNet(PHP_EXIT_GAME, tab, response, PHP_POST, errorMsgFunc) 
end

function DZChat.startGame(gid, funcBack)
	local function response(data)
		if funcBack then
			funcBack(data)
		end
    end

    local tab = {}
    tab['gid'] = gid
    MainCtrol.filterNet(PHP_START_GAME, tab, response, PHP_POST, errorMsgFunc)
end

function DZChat.checkChat(id, mod)
	DZChatNet.netEnterChat(id, mod)
end


-- 跳转到俱乐部聊天
function g_backJumpChat( str )
	local function backFunc()
		local tab = jsonToTab(str)
		dump(tab)
		DZChatNet.netEnterChat(tab["club_id"], StatusCode.CHAT_CLUB)
	end
	delayBack(backFunc)
end

--


--bro

--解散游戏开始前圈子、退出游戏开始前圈子
local function broExitDisbandGame(data)
	-- if _showRYid == nil or _showRYid ~= data['Rgid'] then return end

	--解散、退出(只有退出者页面消失)
	if data['cat'] == 0 then
		local args = {}
		args['ryid'] = data['Rgid']
		setCallNative(_className, 'broDisbandGroup', args)

		local GameScene = require 'game.GameScene'
		GameScene.disbandGame(data['gid'])
		local CardCtrol = require("cards.CardCtrol")
		if CardCtrol.isCardScene() then
			print("移除牌局")
			CardCtrol.updateCardList(data['gid'])
		end
	elseif data['cat'] == 1 then
		local args = {}
		args['ryid'] = data['Rgid']
		args['playerid'] = data['uid']
		setCallNative(_className, 'broLeaveBefGame', args)

		local CardCtrol = require("cards.CardCtrol")
		if CardCtrol.isCardScene() then
			print("移除牌局")
			CardCtrol.updateCardList(data['gid'])
		end
		--退出者
		if data['uid'] == Single:playerModel():getId() then
		end
	end
end

--游戏开始前圈子开始游戏(讨论组消失)
local function broStartGame(data)
	local isStart = false
	if _showRYid == data['Rgid'] then 
		isStart = true
	end

	local args = {}
	args['ryid'] = data['Rgid']
	setCallNative(_className, 'broStartGame', args)

	if isStart then
		DZAction.delateTime(nil, 0.2, function()
			local GameScene = require 'game.GameScene'
		    GameScene.startScene(data['gid'])
		end)
	end
end

--加入游戏开始前圈子
local function broIntoBefGame(data)
	local args = {}
	args['playerid'] = data['uid']
	args['playerRYId '] = data['rongyun_id']
	args['name'] = data['name']
	args['headUrl'] = data['avatar']
	args['ryid'] = data['Rgid']
	setCallNative(_className, 'broIntoBefGame', args)
end

--申请报名
local function broApplaySignUp(data, isDisplay)
	local isdis = tostring(true)
	if isDisplay == nil then
		isdis = tostring(true)
	else
		isdis = tostring(isDisplay)
	end
	local args = {}
	args['isDisplay'] = isdis
	-- args['ryid'] = data['Rgid']
	-- args['pokerId'] = data['gid']
	setCallNative(_className, 'broApplaySignUp', args)	

    local GameScene = require 'game.GameScene'
    GameScene.disNewMsgSignUp()
end

--sng玩家申请结果
local function broApplayResult(data)
	-- dump(data)
	-- 聊天界面弹窗sng报名结果
	local isAgree = tostring(true)
	if data['agree'] == 0 then
		isAgree = tostring(false)
	end
	local args = {}
	args['roomName'] = data['gname']
	args['isAgree'] = isAgree
	args['ryid'] = data['Rgid']
	args['pokerId'] = data['gid']
	setCallNative(_className, 'broApplayResult', args)

	-- 非聊天界面弹窗sng报名结果
	-- 拒绝、同意
	if data['agree'] == 0 then
		MainHelp.sngApplayFail(data['gid'], data['gname'])
	else
		MainHelp.sngApplaySuccess(data['gid'], data['gname'])
	end
end

--sng报名人数更新(报名成功或离开游戏)
local function broSngSignUpNum(data)
	local args = {}
	args['signUpNum'] = tostring(data['signup_num'])
	args['ryid'] = data['Rgid']
	setCallNative(_className, 'broSngSignUpNum', args)
end

--俱乐部或圈子增加新牌局
local function broClubAndCircleNewPoker(data)
	local args = DZChatNet.getClubAndCircleNewPokerData(data['pokerInfo'])
	setCallNative(_className, 'broClubAndCircleNewPoker', args)
end

--俱乐部或圈子牌局状态发生改变
local function broClubAndCirclePokerStatusChange(data)
	local args = {}
	-- handleClubPokerMsg 已进入和新增牌局广播
	args['pokerId'] = data['pokerId']
	args['pokerStatus'] = tostring(data['pokerStatus'])
	args['joinStatus'] = tostring(data['joinStatus'])
	setCallNative(_className, 'broClubAndCirclePokerStatusChange', args)
end

--俱乐部或圈子牌局结束
function DZChat.clubAndCircleEndPoker(pokerId)
	local args = {}
	args['pokerId'] = pokerId
	setCallNative(_className, 'broClubAndCircleEndPoker', args)
end
local function broClubAndCircleEndPoker(data)
	DZChat.clubAndCircleEndPoker(data['pokerId'])
end

function DZChat.broHandle(data)
	local pnum = data['code']

	local handles = {}
	handles[3000] = broExitDisbandGame
	handles[3050] = broStartGame
	handles[3051] = broIntoBefGame
	-- handles[3052] = broApplaySignUp
	handles[3053] = broApplayResult
	handles[3054] = broSngSignUpNum

	handles[3065] = broClubAndCircleNewPoker
	handles[3067] = broClubAndCirclePokerStatusChange
	handles[3066] = broClubAndCircleEndPoker

	handles[3068] = broApplaySignUp

	if handles[ pnum ] then
		print('广播了了了  .. 聊天')
		print_f(data)
		handles[ pnum ](data)
	end
end




--游戏中
function DZChat.initGamingRYId()
	local args = {}
	args['ryid'] = Single:gameModel():getGamePRYId()
	setCallNative(_className, 'setGamingRYId', args)
end

function DZChat.startRecord()
	local args = {}
	args['ryid'] = Single:gameModel():getGamePRYId()
	setCallNative(_className, 'startRecord', args)
end

function DZChat.cancelRecord()
	local args = {}
	args['ryid'] = Single:gameModel():getGamePRYId()
	setCallNative(_className, 'cancelRecord', args)
end

function DZChat.sendRecord()
	local args = {}
	args['ryid'] = Single:gameModel():getGamePRYId()
	args['playerId'] = Single:playerModel():getId()
	args['playerRYId'] = Single:playerModel():getRYId()
	setCallNative(_className, 'sendRecord', args)
end


function DZChat.playLastVoice(playerId, playerRYId)
	local function backFunc()
		local args = {}
		args['ryid'] = Single:gameModel():getGamePRYId()
		args['playerId'] = tostring(playerId)
		args['playerRYId'] = tostring(playerRYId)
		setCallNative(_className, 'playLastVoice', args)
	end
	delayBack(backFunc)
end


function g_playVoiceTime(str)
	local GameScene = require 'game.GameScene'

	local function backFunc()
		if not GameScene.isDisGameScene() then return end
		
		local tab = jsonToTab(str)
		local GameLayer = require 'game.GameLayer'
		GameLayer:getInstance():playerVoice(tab['playerId'], tonumber(tab['voiceTime']))
	end
	delayBack(backFunc)
end




--显示新消息
--noDelay是否延迟发送
--进入圈子或俱乐部界面、处理完授权申请后返回页面、进入组建的sng牌局
function DZChat.displayApplySignUp(ryid, noDelay)
	local function callFunc()
		local ndata = {}
		-- ndata['Rgid'] = ryid
		broApplaySignUp(ndata, true)
	end

	if not noDelay then
	    DZSchedule.schedulerOnce(1.5, callFunc)
	else
		callFunc()
	end
end



--数据处理
--附加信息
function DZChat.getMsgJson(mtitle, murl, mId, mRYid, pokerId)
	local ret = {}
	ret['msgTitle'] = mtitle
	ret['msgUrl'] = murl
	ret['msgId'] = mId
	ret['msgRYId'] = mRYid
	ret['msgPlayerName'] = Single:playerModel():getPName()

	if not pokerId then
		ret['pokerId'] = 'no'
	else
		ret['pokerId'] = pokerId
	end

	ret['siadId'] = Single:playerModel():getId()
	ret['saidUrl'] = Single:playerModel():getPHeadUrl()
	ret['saidName'] = Single:playerModel():getPName()
	ret['saidRYId'] = Single:playerModel():getRYId()

	--是否是创始俱乐部
	ret['isHost'] = 'false'
	--是否是保险局 0不是
	ret['secure'] = 0

	return ret
end

--用户信息
function DZChat.getPlayerJson(playerid, hurl, pname, pryid)
	local ret = {}
	ret['playerid'] = playerid
	ret['headUrl'] = hurl
	ret['name'] = pname
	ret['playerRYId'] = pryid

	return ret
end



function DZChat.isShowChatView()
	return isShowChat
end

function DZChat.netLinkError()
	if DZChat.isShowChatView() then
		DZChat.clickPromptMsg(_showRYid, '请检查网络')
	end
end


--用到个人信息
--broIntoBefGame、showChatLayer
--字段：playerid、playerRYId、name、headUrl、ryid(好友的融云id或群组融云id)


--显示：
--好友、圈子、俱乐部、标准牌局开始前、sng牌局开始前
--圈子开局之后、俱乐部开局之后


--隐藏：
--所有：返回
--好友：右侧两个小人好友信息
--圈子：右侧两个小人圈子信息、开局
--俱乐部：右侧两个小人俱乐部信息、开局
--游戏开始前：退出、解散、开始

--chat界面提示信息：聊天界面不消失，请求cocos网络
--1.开始游戏
--2.解散或退出游戏
--3.sng报名

return DZChat