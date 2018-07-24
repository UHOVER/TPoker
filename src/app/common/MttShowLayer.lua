local ViewBase = require("ui.ViewBase")
local MttShowLayer = class("MttShowLayer", ViewBase)
local MttShowCtorl = require("common.MttShowCtorl")
local CardCtrol = require("cards.CardCtrol")

local _mttShowLayer = nil

local MTT_TARGET = nil

local curNode = nil

local dissolveBtn = nil

local imageView = nil

local CUR_TARGET = nil

local redPoint_bg = nil

local tableViewHeight = 0

local _statusTab = {}
local _playerTab = {}
local _tableTab  = {}
local _awardTab  = {}

-- 服务器当前时间
local currentTime = 0
-- 开赛时间
local startTime = 0

-- 牌局状态
local cardStatus = 0

-- 报名状态
local entryStatus = 0

-- 是否授权
local isAccess = 0
-- 截止报名
local offEntry = 0
-- 是否被淘汰
local weedOut = 0

-- 报名人数
local entryNum = 0

local entryNumLabel = nil

local entryBtn = nil
local entryLabel = nil
local entryDes = nil

local downTime = 0

local downTimeLabel = nil

local buttonIcon = {}

local schedule = nil
local myupdate = nil

local _retData = {}

local curTableView = nil
local curData = {}

local function showGroup()
	local mod = nil
	local chatType = tonumber(_retData.chatType)
	if chatType == DZChat.TYPE_CLUB then
		mod = StatusCode.CHAT_CLUB
	elseif chatType == DZChat.TYPE_GROUP then
		mod = StatusCode.CHAT_CIRCLE
	end
	DZChat.checkChat(_retData.groupID, mod)
end

local function Callback(  )

	MttShowLayer.clearSchedule()
	_mttShowLayer:initData()

	-- local myEvent = cc.EventCustom:new("C_Event_Update_MTT_List")
	-- local customEventDispatch = cc.Director:getInstance():getEventDispatcher()
 --    customEventDispatch:dispatchEvent(myEvent)

	if _mttShowLayer then
		_mttShowLayer:removeFromParent()
	end
	if MTT_TARGET == "hallMtt" or _retData["mttType"] == "hallMtt" then
		local CardScene = require("cards.CardScene")
		CardScene:startScene()
		return
	end
	if MTT_TARGET then
		print("这里是牌局列表")
		local CardScene = require("cards.CardScene")
		CardScene:startScene()
	else
		local chatType = tonumber(_retData.chatType)
		if chatType == 1 or chatType == 2 then
			showGroup()
		else
			DZChat.clickUnreadRecord("mtt_pre".._retData["pokerId"], chatType)
			MainCtrol.enterGame(_retData['pokerId'], MainCtrol.MOD_GID, function()end, nil, true, true )
		end
	end

end

-- 解散
local function dissolveFunc(  )
	local chatType = tonumber(_retData.chatType)
	ViewCtrol.popHint({bgSize = cc.size(display.width-100, 300), content = "确定要解散此MTT比赛?", sureFunBack = function()
		local function funcBack(  )
			_mttShowLayer:removeFromParent()
			if MTT_TARGET then
				CardCtrol.updateCardList( _retData["pokerId"] )
			else
				if chatType == 1 or chatType == 2 then
					showGroup()
				end
			end
			if chatType == DZChat.TYPE_GAME_MTT then
				local ryid = "mtt_pre".._retData["pokerId"]
				DZChat.clickClearRecord(ryid, chatType)
				DZChat.getChatList()
			end
		end
		local game_mod = MttShowCtorl.getGameMod()
		DZChat.exitDisbandGame(_retData['pokerId'], funcBack, game_mod)
	end})
end

-- 报名
local function entryFunc( sender )
	local tag = sender:getTag()
	if tag == 100 then
		ViewCtrol.popHint({bgSize = cc.size(display.width-100, 300), content = "确定花费"..MttShowCtorl.getMttEntryFee().."的记分牌参加比赛?", sureFunBack = function()
			MttShowCtorl.httpEntry( _retData, function(data)
				dump(data)
				cardStatus = tonumber(data.status)
				-- MttShowLayer.updateMttTime( _retData )
				if entryBtn == nil then
					return
				end
				if entryLabel == nil then
					return
				end
				if MttShowCtorl.isHost() then
					-- MttShowLayer.updateMttEntry(1)
					if cardStatus == 0 then
						-- entryBtn:loadTextures(buttonIcon.cancel[1], buttonIcon.cancel[2], buttonIcon.cancel[3])
						-- entryBtn:setTag(101)
						-- local value = 10*60
						-- local d_value = tonumber(startTime - currentTime)
						-- if d_value <= value then
						-- 	entryBtn:setEnabled(false)
						-- end
						MttShowLayer.updateMttTime( _retData )
					elseif cardStatus == 1 then
						local game_mod = MttShowCtorl.getGameMod()
						if game_mod == "43" then
							-- 是否开启授权
							if MttShowCtorl.isAccess() then
								-- 是否是管理员
								if MttShowCtorl.isManager() then
									entryStatus = 1
									entryBtn:loadTextures(buttonIcon.match[1], buttonIcon.match[2], buttonIcon.match[2])
									entryBtn:setTag(102)
									MttShowCtorl.BackMatch( _retData.pokerId )
								else
									MttShowLayer.updateMttTime( _retData )
								end
							else
								entryStatus = 1
								entryBtn:loadTextures(buttonIcon.match[1], buttonIcon.match[2], buttonIcon.match[2])
								entryBtn:setTag(102)
								MttShowCtorl.BackMatch( _retData.pokerId )
							end
						else
							entryStatus = 1
							entryBtn:loadTextures(buttonIcon.match[1], buttonIcon.match[2], buttonIcon.match[2])
							entryBtn:setTag(102)
							MttShowCtorl.BackMatch( _retData.pokerId )
						end
					end
				else
					if cardStatus == 0 then
						--[[if isAccess == 0 then
							MttShowLayer.updateMttEntry(1)
							entryStatus = 1
							entryBtn:loadTextures(buttonIcon.cancel[1], buttonIcon.cancel[2], buttonIcon.cancel[3])
							entryBtn:setTag(101)
							local value = 10*60
							local d_value = tonumber(startTime - currentTime)
							if d_value <= value then
								entryBtn:setEnabled(false)
							end
						elseif isAccess == 1 then
							entryStatus = 2
							entryBtn:setVisible(false)
							ViewCtrol.showMsg("申请报名成功,等待房主审核")
							entryLabel:setString("等待房主同意您的报名申请...")
						end--]]
						MttShowLayer.updateMttTime( _retData )
					elseif cardStatus == 1 then
						if isAccess == 0 then
							MttShowLayer.updateMttEntry(1)
							entryStatus = 1
							entryBtn:loadTextures(buttonIcon.match[1], buttonIcon.match[2], buttonIcon.match[2])
							entryBtn:setTag(102)
							
							MttShowCtorl.BackMatch( _retData.pokerId )
						elseif isAccess == 1 then
							-- entryStatus = 2
							-- entryBtn:setVisible(false)
							-- ViewCtrol.showMsg("申请报名成功,等待房主审核")
							-- entryLabel:setString("等待房主同意您的报名申请...")
							MttShowLayer.updateMttTime( _retData )
						end
					end
				end
				-- MttShowLayer.updatePlayer( _retData )
			end )
		end})
	elseif tag == 101 then
		ViewCtrol.popHint({bgSize = cc.size(display.width-100, 300), content = "退出牌局后,将不退还记录费,只会返还参赛费,是否退出该牌局?", sureFunBack = function() 
			MttShowCtorl.httpCancelEntry( _retData.pokerId, function()
				-- MttShowLayer.updateMttEntry(0)
				-- entryStatus = 0
				-- entryBtn:loadTextures(buttonIcon.entry[1], buttonIcon.entry[2], buttonIcon.entry[2])
				-- entryBtn:setTag(100)
				MttShowLayer.updateMttTime( _retData )
			end )
		end})
	elseif tag == 102 then
		MttShowCtorl.BackMatch( _retData.pokerId )
	end
end

function MttShowLayer:buildLayer()
	local mtt_name = MttShowCtorl.getMttName()
	local menuStr = nil
	local menuBack = nil

	local topBar = UIUtil.addTopBar({backFunc = Callback, title = mtt_name, parent = self})

	-- 解散按钮
	local chatType = tonumber(_retData.chatType)
	if chatType == DZChat.TYPE_GROUP then
		local label = cc.Label:createWithSystemFont("解散", "Marker Felt", 30):setColor(cc.c3b(152, 152, 152))
		dissolveBtn = UIUtil.controlBtn(ResLib.COM_OPACITY0, ResLib.COM_OPACITY0, ResLib.COM_OPACITY0, label, cc.p(topBar:getContentSize().width-20, topBar:getContentSize().height/2-20), cc.size(label:getContentSize().width+40,80), dissolveFunc, topBar):setAnchorPoint(cc.p(1,0.5))
	end
	

	imageView = UIUtil.addImageView({image = ResLib.MTT_BG, touch=false, scale=true, size=cc.size(display.width, display.height-130), parent=self})
	local width = imageView:getContentSize().width
	local height = imageView:getContentSize().height

	-- 底部按钮图标
	local icon1 = {entry={"common/card_mtt_entry_btn.png", "common/card_mtt_entry_btn_height.png"},
				re_entry={"common/card_mtt_reentry_btn.png", "common/card_mtt_reentry_btn_height.png"},
				cancel={"common/card_mtt_cancel_btn.png","common/card_mtt_cancel_btn_height.png", "common/card_mtt_canel_btn_dis.png"},
				match={"common/card_mtt_match_btn.png", "common/card_mtt_match_btn_height.png"}}

	local icon2 = {entry={"common/card_mtt_entry_btn.png", "common/card_mtt_entry_btn_height.png"},
				re_entry={"common/card_mtt_delayEntry_btn.png", "common/card_mtt_delayEntry_btn_height.png"},
				cancel={"common/card_mtt_cancel_btn.png","common/card_mtt_cancel_btn_height.png", "common/card_mtt_canel_btn_dis.png"},
				match={"common/card_mtt_enter_btn.png", "common/card_mtt_enter_btn_height.png"}}
	if MTT_TARGET == "hallMtt" or _retData["mttType"] == "hallMtt" then
		buttonIcon = icon2
	else
		buttonIcon = icon1
	end

	local btn_icon = {
				{normal = "common/card_mtt_status_btn.png", height = "common/card_mtt_status_btn_height.png"},
				{normal = "common/card_mtt_player_btn.png", height = "common/card_mtt_player_btn_height.png"},	
				{normal = "common/card_mtt_table_btn.png", height = "common/card_mtt_table_btn_height.png"},
				{normal = "common/card_mtt_award_btn.png", height = "common/card_mtt_award_btn_height.png"}
			}

	local btn_text = {"状态", "玩家", "牌桌", "奖励"}
	local game_mod = MttShowCtorl.getGameMod()
	if game_mod == "mtt_general" or game_mod == "23" then
		if MttShowCtorl.isManager() then
			btn_text = {"状态", "玩家", "牌桌", "奖励", "管理"}
		end
	elseif game_mod == "43" then
		-- 是盟主
		if MttShowCtorl.isHost() then
			btn_text = {"状态", "玩家", "牌桌", "奖励", "管理"}
		else
			-- 非盟主 是管理员
			if MttShowCtorl.isManager() then
				if MttShowCtorl.isAccess() then
					btn_text = {"状态", "玩家", "牌桌", "奖励", "管理"}
				end
			end
		end
	end
	if game_mod == "mtt_general" or game_mod == "23" or game_mod == "33" or game_mod == "43" then
		tableViewHeight = 0
	else
		tableViewHeight = 100
	end

	local cardItem_btn = {}
	local function cardItemFunc( sender )
		local tag = sender:getTag()
		sender:setTouchEnabled(false)
		sender:setBright(false)
		sender:setTitleColor(display.COLOR_WHITE)
		for k,v in pairs(cardItem_btn) do
			if tag ~= v:getTag() then
				v:setTouchEnabled(true)
				v:setBright(true)
				v:setTitleColor(ResLib.COLOR_GREY2)
			end
		end
		self:initData()
		local countTab = Notice.getMessagePushCount( 6 )
		if CUR_TARGET == MttShowCtorl.MTT_PLAYER then
			if next(countTab) ~= nil then
				if tonumber(countTab.count) > 0 then
					Notice.deleteMessage( 6 )
				end
			end
		end
		if tag == MttShowCtorl.MTT_STATUS then
			CUR_TARGET = MttShowCtorl.MTT_STATUS
			MttShowCtorl.dataStatStatus(function (  )
				redPoint_bg:setVisible(true)
				if game_mod == "mtt_general" or game_mod == "23" or game_mod == "33" or game_mod == "43" then
					self:buildStatusUI(imageView)
				else
					self:buildStatusUI1(imageView)
				end
			end, _retData)
		elseif tag == MttShowCtorl.MTT_PLAYER then
			CUR_TARGET = MttShowCtorl.MTT_PLAYER
			if next(countTab) ~= nil then
				if tonumber(countTab.count) > 0 then
					Notice.deleteMessage( 6 )
				end
			end
			MttShowCtorl.dataStatPlayer(function (  )
				redPoint_bg:setVisible(false)
				self:buildPlayerUI(imageView)
			end, _retData)
		elseif tag == MttShowCtorl.MTT_TABLE then
			CUR_TARGET = MttShowCtorl.MTT_TABLE
			MttShowCtorl.dataStatTable(function (  )
				redPoint_bg:setVisible(true)
				self:buildTableUI(imageView)
			end, _retData)
		elseif tag == MttShowCtorl.MTT_AWARD then
			CUR_TARGET = MttShowCtorl.MTT_AWARD
			MttShowCtorl.dataStatAward(function (  )
				redPoint_bg:setVisible(true)
				self:buildAwardUI(imageView)
			end, _retData)
		elseif tag == MttShowCtorl.MTT_MANAGE then
			CUR_TARGET = MttShowCtorl.MTT_MANAGE
			if game_mod == "43" then
				MttShowCtorl.dataStatManage(function (  )
					redPoint_bg:setVisible(true)
					self:buildManageUI(imageView)
				end, _retData)
			else
				redPoint_bg:setVisible(true)
				self:buildManageUI(imageView)
			end
		end
	end
	local btn_len = #btn_text
	for i=1,btn_len do
		cardItem_btn[i] = UIUtil.addImageBtn({norImg = "common/card_mtt_normal_btn.png", selImg = "common/card_mtt_height_btn.png", disImg = "common/card_mtt_height_btn.png", text = btn_text[i], ah = cc.p(0, 1), pos = cc.p((i-1)*(width/btn_len), height), scale9 = true, size = cc.size(width/btn_len-1,80), touch = true, listener = cardItemFunc, parent = imageView})
		cardItem_btn[i]:setTitleColor(ResLib.COLOR_GREY2)
		cardItem_btn[i]:setTitleFontSize(32)
		cardItem_btn[i]:setTag(i)
		if i == 2 then
			redPoint_bg = UIUtil.addImageView({image = ResLib.COM_OPACITY0, touch=false, scale=true, size=cardItem_btn[i]:getContentSize(), ah = cc.p(0, 1), pos = cc.p((i-1)*(width/btn_len), height), parent= imageView})
		end
	end
	cardItem_btn[1]:setTouchEnabled(false)
	cardItem_btn[1]:setBright(false)
	cardItem_btn[1]:setTitleColor(display.COLOR_WHITE)

	if game_mod == "mtt_general" or game_mod == "23" or game_mod == "33" or game_mod == "43" then
		self:buildStatusUI(imageView)
	else
		self:buildStatusUI1(imageView)
	end
	
	CUR_TARGET = MttShowCtorl.MTT_STATUS

	MttShowLayer.buildRedPoint(  )
end

function MttShowLayer.buildRedPoint(  )
    -- 玩家报名
    NoticeCtrol.setNoticeNode( POS_ID.POS_40001, redPoint_bg )

    Notice.registRedPoint( 6 )
end

function MttShowLayer:buildStatusUI1( layer )
	if curNode then
		curNode:removeFromParent()
		curNode = nil
	end
	curNode = cc.Node:create()
	local function onNodeEvent(event)
		if event == "enter" then
		elseif event == "exit" then
			MttShowLayer.clearSchedule()
		end
	end
	curNode:registerScriptHandler(onNodeEvent)
	
	local posH = display.height-220
	curNode:setContentSize(cc.size(display.width, posH))
	curNode:setPosition(cc.p(0,0))
	layer:addChild(curNode)

	-- 状态数据
	_statusTab = MttShowCtorl.getStatusData()

	local infoBg = {}
	local infoH = {400, 300, 220}
	local infoW = display.width-50
	local infoSize_H = 0

	for i=1,#infoH do
		infoSize_H = infoH[i] + infoSize_H+25
		infoBg[i] = UIUtil.addImageView({image="common/com_grey_block.png", touch=false, scale=true, size=cc.size(infoW, infoH[i]), ah = cc.p(0.5,0), pos=cc.p(display.width/2, posH - infoSize_H), parent=curNode})
	end

	-- 牌局标题
	local tableBg = UIUtil.addImageView({image="common/card_mtt_table_icon.png", touch=false, ah = cc.p(0.5,1), pos=cc.p(infoW/2, infoH[1]-20), parent=infoBg[1]})

	local label1 = UIUtil.addLabelArial('定时开赛', 20, cc.p(60, tableBg:getContentSize().height/2), cc.p(0, 0.5), tableBg):setColor(ResLib.COLOR_BLUE1)

	local label2_str = nil
	local label3_str = nil
	local label4_str = nil
	local union_open = 0
	if _statusTab.game_mod == "23" then
		label3_str = "俱乐部赛"
	elseif _statusTab.game_mod == "33" then
		label3_str = "圈子赛"
	elseif _statusTab.game_mod == "43" then
		if _statusTab.invite_code ~= "0" then
			label2_str = "邀请码"
			label3_str = _statusTab.invite_code
			label4_str = "点击分享"
			union_open = 1
		else
			label3_str = "联盟赛"
		end
	else
		label2_str = "邀请码"
		label3_str = _statusTab.invite_code
		label4_str = "点击分享"
	end

	-- 邀请码
	if label2_str then
		local label2 = UIUtil.addLabelArial(label2_str, 22, cc.p(tableBg:getContentSize().width/2, tableBg:getContentSize().height/2+20), cc.p(0.5, 0), tableBg):setColor(ResLib.COLOR_BLUE1)
	end

	local join_code = label3_str
	local label3 = UIUtil.addLabelArial(join_code, 30, cc.p(tableBg:getContentSize().width/2, tableBg:getContentSize().height/2), cc.p(0.5, 0.5), tableBg)

	if label4_str then
		local label4 = UIUtil.addLabelArial('点击分享', 22, cc.p(tableBg:getContentSize().width/2, tableBg:getContentSize().height/2-20), cc.p(0.5, 1), tableBg):setColor(ResLib.COLOR_BLUE1)
	end

	-- "%Y年%m月%d日 %H:%M:%S"
	local date = os.date("%m月%d日\n%H:%M", _statusTab.start_time)
	-- local label5 = UIUtil.addLabelArial(date, 20, cc.p(tableBg:getContentSize().width-20, tableBg:getContentSize().height/2), cc.p(1, 0.5), tableBg):setColor(ResLib.COLOR_BLUE1)
	local label = cc.Label:createWithSystemFont(date, "Arial", 20, cc.size(100, 60), cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
	label:setTextColor(ResLib.COLOR_BLUE1)
	label:setPosition(cc.p(tableBg:getContentSize().width-95, tableBg:getContentSize().height/2))
	tableBg:addChild(label)

	if _statusTab.game_mod == "mtt_general" or _statusTab.game_mod == "53" or _statusTab.game_mod == "63" or union_open == 1 then
		local function shareFunc(  )
			DZWindow.shareDialog(DZWindow.SHARE_CODE, {pokerId = _retData.pokerId, inviteCode = _statusTab.invite_code})
		end
		local shareBtn = UIUtil.addImageBtn({norImg = ResLib.COM_OPACITY0, selImg = ResLib.COM_OPACITY0, disImg = ResLib.COM_OPACITY0, ah = cc.p(0.5, 0.5), pos = cc.p(label3:getPosition()), scale9 = true, size = cc.size(200, 100), touch = true, listener = shareFunc, parent = tableBg})
	end

	-- 房主
	local hostLabel = UIUtil.addLabelArial("", 30, cc.p(infoW/2-5, infoH[1]/2+10), cc.p(1, 0.5), infoBg[1]):setColor(ResLib.COLOR_BLUE2)
	local hostName = UIUtil.addLabelArial("", 30, cc.p(infoW/2+5, infoH[1]/2+10), cc.p(0, 0.5), infoBg[1])
	if _statusTab.game_mod == "43" then
		hostLabel:setString("")
		hostName:setAnchorPoint(cc.p(0.5, 0.5))
		hostName:setPositionX(infoW/2)
		hostName:setString("来自".._statusTab.host_name.."联盟")
	elseif _statusTab.game_mod == "53" then
		hostLabel:setString("")
		hostName:setAnchorPoint(cc.p(0.5, 0.5))
		hostName:setPositionX(infoW/2)
		hostName:setString("来自赛场")
	elseif _statusTab.game_mod == "63" then
		hostLabel:setString("")
		hostName:setAnchorPoint(cc.p(0.5, 0.5))
		hostName:setPositionX(infoW/2)
		hostName:setString("来自本地化".._statusTab.host_name)
	else
		hostLabel:setString("房主:")
		hostName:setString(_statusTab.host_name)
	end

	-- 报名费、初始记分牌
	local spBg = UIUtil.addImageView({image="common/card_mtt_opacity_icon.png", touch=false, ah = cc.p(0.5,1), pos=cc.p(infoW/2, infoH[1]/2-30), parent=infoBg[1]})

	local entryStr = UIUtil.addLabelArial('报名费:', 26, cc.p(10, spBg:getContentSize().height/2), cc.p(0, 0.5), spBg):setColor(ResLib.COLOR_BLUE2)
	local entryFee = _statusTab.entry_fee.."+"..tostring(_statusTab.entry_fee/10)
	local entry_fee = UIUtil.addLabelArial(entryFee, 26, cc.p(entryStr:getPositionX()+entryStr:getContentSize().width+10, spBg:getContentSize().height/2), cc.p(0, 0.5), spBg)

	local scoreStr = UIUtil.addLabelArial('起始记分牌:', 26, cc.p(spBg:getContentSize().width/2, spBg:getContentSize().height/2), cc.p(0, 0.5), spBg):setColor(ResLib.COLOR_BLUE2)
	local scoreNum = _statusTab.inital_score
	local score_num = UIUtil.addLabelArial(scoreNum, 26, cc.p(scoreStr:getPositionX()+scoreStr:getContentSize().width+10, spBg:getContentSize().height/2), cc.p(0, 0.5), spBg)



	-- 已报名人数
	local entryStr = UIUtil.addLabelArial('已报名:', 30, cc.p(infoW/2-5, 90), cc.p(1, 0.5), infoBg[1]):setColor(ResLib.COLOR_BLUE2)
	entryNum = _statusTab.players_num
	entryNumLabel = UIUtil.addLabelArial(entryNum, 30, cc.p(infoW/2+5, 90), cc.p(0, 0.5), infoBg[1])

	-- 总奖池人数
	local awardLabel = UIUtil.addLabelArial('总奖池:', 30, cc.p(infoW/2-5, 40), cc.p(1, 0.5), infoBg[1]):setColor(ResLib.COLOR_BLUE2)
	local awardNum = _statusTab.awards_count
	local award_num = UIUtil.addLabelArial(awardNum, 30, cc.p(infoW/2+5, 40), cc.p(0, 0.5), infoBg[1])

	-- 赛事状态
	cardStatus = tonumber(_statusTab.status)

	
	-----------------
	if cardStatus == 0 then
		local text = {"升盲时间", "单桌人数", "重购", "增购", "终止报名", "中场休息"}
		local halftime = nil
		if _statusTab.halftime == "0" then
			halftime = "比赛中途不休息"
		else
			local half_time = tonumber(_statusTab.halftime)/60
			halftime = "比赛每"..half_time.."分钟休息5分钟"
		end
		local reBuyStr = ""
		if tonumber(_statusTab.rebuy_num) == (-1) then
			reBuyStr = "(购买1倍记分牌无限制)"
		else
			reBuyStr = "(购买1倍记分牌".._statusTab.rebuy_num.."次)"
		end

		-- 升盲时间换算
		local ActivityCtorl = require("common.ActivityCtorl")
		local increase_time = ActivityCtorl.transTime(_statusTab.increase_time)

		local value = {increase_time, "9人", "1-"..(tostring(_statusTab.entry_stop-1)).."盲注级别", "第"..tostring(_statusTab.entry_stop).."盲注级别", "第"..tostring(_statusTab.entry_stop).."盲注级别", halftime}
		local desText = {"", "", reBuyStr, "(购买1.5倍记分牌".._statusTab.addon.."次)", "", ""}
		local textLabel = {}
		local textValue = {}
		for i=1,#text do
			textLabel[i] = UIUtil.addLabelArial(text[i]..":", 26, cc.p(100, infoH[2]-(i-1)*40-60), cc.p(0, 0.5), infoBg[2]):setColor(ResLib.COLOR_BLUE2)
			textValue[i] = UIUtil.addLabelArial(value[i], 26, cc.p(textLabel[i]:getPositionX()+textLabel[i]:getContentSize().width+10, infoH[2]-(i-1)*40-60), cc.p(0, 0.5), infoBg[2])
			if desText[i] ~= "" then
				UIUtil.addLabelArial(desText[i], 24, cc.p(textValue[i]:getPositionX()+textValue[i]:getContentSize().width+10, infoH[2]-(i-1)*40-60), cc.p(0, 0.5), infoBg[2]):setColor(ResLib.COLOR_BLUE2)
			end
		end
	else
		local text = {"当前盲注", "下一等级", "升盲时间"}
		local ActivityCtorl = require("common.ActivityCtorl")
		local increase_time = ActivityCtorl.transTime(_statusTab.increase_time)
		local bindTag = nil
		if _statusTab.game_mod == "53" then
			bindTag = "hall"
		else
			bindTag = "mtt"
		end
		local curBind, nextBind = {}, {}
		local cur_level = tonumber(_statusTab.current_blind) or 1
		if cur_level == 0 then
			cur_level = 1
		end
		curBind, nextBind = MttShowCtorl.getCurBind( bindTag, cur_level )

		local value = { "盲注"..curBind.bind.."/"..tostring(curBind.bind*2).."  前注"..curBind.ori_bind, "盲注"..nextBind.bind.."/"..tostring(nextBind.bind*2).."  前注"..nextBind.ori_bind, increase_time}
		local textLabel = {}
		local textValue = {}
		for i=1,#text do
			textLabel[i] = UIUtil.addLabelArial(text[i]..":", 26, cc.p(120, infoH[2]-(i-1)*40-120), cc.p(0, 0.5), infoBg[2]):setColor(ResLib.COLOR_BLUE2)
			textValue[i] = UIUtil.addLabelArial(value[i], 26, cc.p(textLabel[i]:getPositionX()+textLabel[i]:getContentSize().width+10, infoH[2]-(i-1)*40-120), cc.p(0, 0.5), infoBg[2])
		end
	end
	
	-- 盲注结构
	local function bindsStru(  )
		local params = {blind = _statusTab.entry_stop, rebuy = _statusTab.rebuy_num, addbuy = _statusTab.addon}
		local bindTag = nil
		if _statusTab.game_mod == "53" then
			bindTag = "hall"
		else
			bindTag = "status"
		end
		local bindsLayer = require("common.bindsLayer").new(bindTag, params)
		self:addChild(bindsLayer, 10)
	end
	UIUtil.addImageBtn({norImg = "common/com_icon_ask.png", selImg = "common/com_icon_ask.png", disImg = "common/com_icon_ask.png", ah =cc.p(1, 0.5), pos = cc.p(infoW-50, infoH[2]-60), touch = true, listener = bindsStru, parent = infoBg[2]})

	-----------------
	local timeLabel = UIUtil.addLabelArial('比赛开始后，中途不可退出', 22, cc.p(infoW/2, infoH[3]-50), cc.p(0.5, 0.5), infoBg[3]):setColor(ResLib.COLOR_BLUE2)

	-- 当前时间
	currentTime = _statusTab.current_time
	-- 开赛时间
	startTime = _statusTab.start_time
	
	entryStatus = tonumber(_statusTab.is_entry)
	isAccess = tonumber(_statusTab.is_access)
	offEntry = tonumber(_statusTab.stop_entry)
	self:addTime_Entry(curNode)

end
--]]

function MttShowLayer:buildStatusUI( layer )
	if curNode then
		curNode:removeFromParent()
		curNode = nil
	end
	curNode = cc.Node:create()
	local function onNodeEvent(event)
		if event == "enter" then
		elseif event == "exit" then
			MttShowLayer.clearSchedule()
		end
	end
	curNode:registerScriptHandler(onNodeEvent)

	local posH = display.height-220
	curNode:setContentSize(cc.size(display.width, posH))
	curNode:setPosition(cc.p(0,0))
	layer:addChild(curNode)

	_statusTab = MttShowCtorl.getStatusData()
	
	-- 780
	local sizeH = {330, 380, 570}
	if _statusTab.mtt_description == "" then
		sizeH = {335, 0, 580}
	end
	local scrollH = sizeH[1]+sizeH[2]+sizeH[3]
	local scrollView = UIUtil.addScrollView( {showSize=cc.size(display.width, posH-190), innerSize=cc.size(display.width, scrollH), dir=cc.SCROLLVIEW_DIRECTION_VERTICAL, colorType=ccui.LayoutBackGroundColorType.none, color=cc.c3b(0, 0, 10), bounce=true, pos=cc.p(0,200), parent=curNode} )
	scrollView:setScrollBarEnabled(false)

	local infoBg = {}
	local infoBgH = 0
	for i=1,#sizeH do
		infoBgH = sizeH[i] + infoBgH
		-- TABLEVIEW_CELL_BG
		-- COM_OPACITY0
		local img = ResLib.COM_OPACITY0
		if i == 2 then
			img = "common/card_mtt_des_bg.png"
		end
		infoBg[i] = UIUtil.addImageView({image = img, touch=false, scale=true, size=cc.size(display.width, sizeH[i]), ah=cc.p(0,0), pos=cc.p(0, scrollH-infoBgH), parent=scrollView})
		if sizeH[i] == 0 then
			infoBg[i]:setVisible(false)
		end
	end
	
	local item1 = {"common/card_mtt_strMtt.png", "common/card_mtt_strTime.png", "common/card_mtt_strEntry.png"}
	local itemDes = {}

	if _statusTab.game_mod == "43" then
		itemDes[1] = "来自".._statusTab.host_name.."联盟"
	elseif _statusTab.game_mod == "53" then
		itemDes[1] = "来自赛场"
	elseif _statusTab.game_mod == "63" then
		itemDes[1] = "来自本地化".._statusTab.host_name
	else
		itemDes[1] = _statusTab.host_name
	end
	itemDes[2] = os.date("%m月%d日%H:%M", _statusTab.start_time)
	itemDes[3] = MttShowCtorl.transNum(_statusTab.entry_fee).."+"..MttShowCtorl.transNum(_statusTab.entry_fee/10)
	
	local itemStr1 = {}
	for i=1,#item1 do
		itemStr1[i] = UIUtil.addPosSprite(item1[i], cc.p(25, sizeH[1]/2+(2-i)*60), infoBg[1], cc.p(0, 0.5))
		UIUtil.addLabelArial(itemDes[i], 30, cc.p(180, itemStr1[i]:getPositionY()), cc.p(0, 0.5), infoBg[1])
	end

	-------------------------------------
	-- 赛事状态
	cardStatus = tonumber(_statusTab.status)
	-- 当前时间
	currentTime = _statusTab.current_time
	-- 开赛时间
	startTime = _statusTab.start_time
	entryStatus = tonumber(_statusTab.is_entry)
	isAccess = tonumber(_statusTab.is_access)
	offEntry = tonumber(_statusTab.stop_entry)
	-------------------------------------

	-- 倒计时
	local timeBg = UIUtil.addPosSprite("common/card_mtt_time_bg.png", cc.p(display.width-70, sizeH[1]/2), infoBg[1], cc.p(1, 0.5))
	local timeTile = UIUtil.addLabelArial("", 36, cc.p(timeBg:getContentSize().width/2, timeBg:getContentSize().height/2+10), cc.p(0.5, 0), timeBg)

	local timeValue = tonumber(startTime - currentTime)
	print("-----------------------------------------")
	print(string.format("curTime:%d, startTime:%d, D_value:%d", currentTime, startTime, timeValue))
	print("-----------------------------------------")
	local down_time = nil
	if timeValue <= 0 and cardStatus == 1 then
		timeTile:setString("比赛进行中")
		down_time = os.date("!%H: %M:%S", math.abs(timeValue))
	elseif timeValue <= 10*60 and timeValue > 0 then
		timeTile:setString("倒计时")
		down_time = os.date("!%H: %M:%S", math.abs(timeValue))
	else
		timeTile:setString(os.date("%Y/%m/%d", startTime))
		down_time = os.date("%H:%M:%S", startTime)
	end
	local down_TimeLabel = UIUtil.addLabelArial(down_time, 46, cc.p(timeBg:getContentSize().width/2, timeBg:getContentSize().height/2-15), cc.p(0.5, 1), timeBg)

	-----------------------------
	if infoBg[2]:isVisible() then
		-- sizeH[2]-110
		local desTitle = UIUtil.addLabelArial("赛事简介", 36, cc.p(display.width/2, sizeH[2]-40), cc.p(0.5, 0.5), infoBg[2])
		-- local desStr = StringUtils.getShortStr( _statusTab.mtt_description, 400)
		local desStr = _statusTab.mtt_description
		local MttDes = cc.Label:createWithSystemFont(desStr, "Arial", 28, cc.size(display.width-50, 0), cc.TEXT_ALIGNMENT_LEFT, cc.VERTICAL_TEXT_ALIGNMENT_TOP)
			:addTo(infoBg[2])
		MttDes:setLineBreakWithoutSpace(true)
		MttDes:setClipMarginEnabled(true)
		MttDes:setAnchorPoint(cc.p(0.5, 1))
		MttDes:setPosition(cc.p(display.width/2, sizeH[2]-75))

		local desNum = string.len(_statusTab.mtt_description)
		local lineNum = math.ceil(desNum/(26*3))
		-- print("行数 ：" .. lineNum)

		local desHeight = MttDes:getContentSize().height
		-- print("当前label高度："..desHeight)

		-- local add_sizeH = lineNum*33.75-MttDes:getContentSize().height
		local add_sizeH = desHeight - (sizeH[2]-110)
		-- print("增加高度 ：" .. add_sizeH)

		local scrollFlag = 1
		local lookBtn = nil
		local function lookAllFun(  )
			print("查看全部")
			if add_sizeH <= 0 then
				return
			end
			local desStr = ""
			if scrollFlag == 1 then
				scrollFlag = 0
				sizeH = {sizeH[1], sizeH[2]+add_sizeH, sizeH[3]}

				desStr = _statusTab.mtt_description
			elseif scrollFlag == 0 then
				scrollFlag = 1
				sizeH = {sizeH[1], sizeH[2]-add_sizeH, sizeH[3]}
				desStr = StringUtils.getShortStr( _statusTab.mtt_description, 400)
			end
			local conH = sizeH[1]+sizeH[2]+sizeH[3]
			scrollView:setInnerContainerSize(cc.size(display.width, conH))
			local scro_size = scrollView:getInnerContainerSize()
			dump(scro_size)
			-- print(">>>>conH: "..conH)
			local infoBgH = 0
			for i=1,3 do
				infoBgH = sizeH[i] + infoBgH
				infoBg[i]:setContentSize(cc.size(display.width, sizeH[i]))
				infoBg[i]:setPositionY(conH-infoBgH)
			end
			MttDes:setDimensions(display.width-50, sizeH[2]-110)
			MttDes:setString(desStr)
			desTitle:setPositionY(sizeH[2]-40)
			MttDes:setPositionY(sizeH[2]-75)
			lookBtn:setPositionY(25)
			scrollView:scrollToTop(0.1, false)
		end
		lookBtn = UIUtil.addImageBtn({norImg = "common/card_mtt_look_btn.png", selImg = "common/card_mtt_look_btn.png", disImg = "common/card_mtt_look_btn.png", ah =cc.p(1, 0.5), pos = cc.p(display.width-25, 25), touch = true, listener = lookAllFun, parent = infoBg[2]})

		if desHeight > sizeH[2]-110 then
			MttDes:setDimensions(display.width-50, sizeH[2]-110)
			desStr = StringUtils.getShortStr( _statusTab.mtt_description, 400)
			MttDes:setString(desStr)
		else
			lookBtn:setVisible(false)

			sizeH = {sizeH[1], desHeight+110, sizeH[3]}
			local conH = sizeH[1]+sizeH[2]+sizeH[3]
			scrollView:setInnerContainerSize(cc.size(display.width, conH))
			local infoBgH = 0
			for i=1,3 do
				infoBgH = sizeH[i] + infoBgH
				infoBg[i]:setContentSize(cc.size(display.width, sizeH[i]))
				infoBg[i]:setPositionY(conH-infoBgH)
			end
			desTitle:setPositionY(sizeH[2]-40)
			MttDes:setPositionY(sizeH[2]-75)
			scrollView:scrollToTop(0.1, false)
		end
	end
	
	-- local item2 = {"已报名", "总奖池", "起始记分牌", "升盲时间", "当前盲注", "重购", "Add-on", "终止报名", "中场休息", "猎头奖池", "猎头奖金"}
	local item2 = {"已报名", "总奖池", "起始记分牌", "升盲时间", "当前盲注", "重购", "Add-on", "终止报名", "中场休息"}

	-- 报名人数
	entryNum = _statusTab.players_num
	-- 总奖池
	local awardNum = _statusTab.awards_count
	-- 起始记分牌
	local str = tonumber(_statusTab.inital_score)/tonumber(_statusTab.big_blind)
	local scoreNum = _statusTab.inital_score.."("..tostring(str).."倍大盲)"
	-- 升盲时间换算
	local ActivityCtorl = require("common.ActivityCtorl")
	local increase_time = ActivityCtorl.transTime(_statusTab.increase_time)
	-- 当前盲注
	local blindLevel = tonumber(_statusTab.big_blind)/2
	local blind_type = "general"
	if tonumber(_statusTab.blind_type) == 0 then
		blind_type = "quick"
	elseif tonumber(_statusTab.blind_type) == 1 then
		blind_type = "general"
	end
	local curBind = {}
	local cur_level = tonumber(_statusTab.current_blind) or 1
	if cur_level == 0 then
		cur_level = 1
	end
	curBind = MttShowCtorl.getMttBlind(blind_type, blindLevel, cur_level)
	local bindStr = tostring(curBind.blindSmall).."/"..tostring(curBind.blindBig).."("..tostring(curBind.ante)..")"
	-- 重购
	local reBuyStr = ""
	local level_str = _statusTab.entry_stop-1
	if tonumber(_statusTab.rebuy_num) == (-1) then
		reBuyStr = "(购买1倍记分牌无限制)"
	else
		reBuyStr = "(购买1倍记分牌".._statusTab.rebuy_num.."次)"
	end
	if level_str == 0 then
		level_str = "1"
	elseif level_str > 0 then
		level_str = "1-"..tostring(level_str)
	end
	local reBuy = level_str.."盲注级别"..reBuyStr
	-- Add-on
	local add_on = nil
	if tonumber(_statusTab.add_mult) == 0 then
		add_on = "未开启"
	else
		add_on = tostring(_statusTab.add_mult).."倍带入"
	end
	-- 终止报名
	local stop_level = "第"..tostring(_statusTab.entry_stop).."盲注级别"
	-- 中场休息
	local halftime = nil
	local half_time = tonumber(_statusTab.halftime)/60
	halftime = "每隔10个盲注级别休息"..tostring(half_time).."分钟"
	-- if _statusTab.halftime == "0" then
	-- 	halftime = "比赛中途不休息"
	-- else
	-- 	local half_time = tonumber(_statusTab.halftime)/60
	-- 	halftime = "比赛每"..half_time.."分钟休息5分钟"
	-- end
	-- 猎头奖池
	local Headhunter = 2000
	-- 猎头奖金
	local HeadNum = 400

	-- local item2_value = {entryNum, awardNum, scoreNum, increase_time, bindStr, reBuy, add_on, stop_level, halftime, Headhunter, HeadNum}
	local item2_value = {entryNum, awardNum, scoreNum, increase_time, bindStr, reBuy, add_on, stop_level, halftime}

	local itemStr2 = {}
	for i=1,#item2 do
		itemStr2[i] = UIUtil.addLabelArial(item2[i], 30, cc.p(25, sizeH[3]-(i-1)*50-50), cc.p(0, 0.5), infoBg[3])
		UIUtil.addLabelArial(item2_value[i], 30, cc.p(200, itemStr2[i]:getPositionY()), cc.p(0, 0.5), infoBg[3])
	end

	-- 盲注结构
	local function bindsStru(  )
		--[[local params = {blind = _statusTab.entry_stop, rebuy = _statusTab.rebuy_num, addbuy = _statusTab.addon}
		local bindTag = nil
		if _statusTab.game_mod == "53" then
			bindTag = "hall"
		else
			bindTag = "status"
		end
		local bindsLayer = require("common.bindsLayer").new(bindTag, params)
		self:addChild(bindsLayer, 10)--]]
		local blindLevel = tonumber(_statusTab.big_blind)/2
		local blind_type = "general"
		if tonumber(_statusTab.blind_type) == 0 then
			blind_type = "quick"
		elseif tonumber(_statusTab.blind_type) == 1 then
			blind_type = "general"
		end
		
		local mttBlinds = require("common.mttBlinds").new(blindLevel, blind_type, 1)
		self:addChild(mttBlinds, 10)
	end
	UIUtil.addImageBtn({norImg = "common/com_icon_ask.png", selImg = "common/com_icon_ask.png", disImg = "common/com_icon_ask.png", ah =cc.p(1, 0.5), pos = cc.p(display.width-25, itemStr2[5]:getPositionY()), touch = true, listener = bindsStru, parent = infoBg[3]})

	local timeLabel = UIUtil.addLabelArial('比赛开始后，中途不可退出', 25, cc.p(display.width/2, 175), cc.p(0.5, 0.5), curNode):setColor(ResLib.COLOR_GREY)

	self:addTime_Entry(curNode)

	if cardStatus ~= 3 then
		-- 倒计时
		if timeValue <= 60*10 then
			self:countDown(timeTile, down_TimeLabel)
		end
	end
end

function MttShowLayer:countDown( timeTile, titleLabel )
	local d_value = tonumber(startTime - currentTime)
	local cardTime = 0
	local backMatch = 0

	local norImg = buttonIcon.match[1]
	local selImg = buttonIcon.match[2]

	local function update( dt )
		cardTime = cardTime + 1
		d_value = d_value - 1

		-- 比赛倒计时
		if d_value > 0 then
			downTime = os.date("!%H: %M:%S", d_value)
			print(downTime)
			if titleLabel then
				titleLabel:setString(downTime)
			end
		-- 比赛数据初始化
		elseif d_value == 0 then
			backMatch = 1
			downTime = os.date("!%H: %M:%S", 0)
			if titleLabel then
				titleLabel:setString(downTime)
			end
			-- 未收到游戏开始的推送时等待5s后刷新界面
			DZAction.delateTime(_mttShowLayer, 5, function()
				if MttShowCtorl.isMttShow() then
					MttShowLayer.updateMttTime( _retData )
				end
			end)
			MttShowLayer.clearSchedule()
		-- 比赛进行中
		else
			-- 已开赛
			if cardStatus == 1 then
				cardTime = math.abs(d_value)
				-- print("-------------: "..cardTime)
				downTime = os.date("!%H: %M:%S", cardTime)
				-- print("-------------: "..downTime)
				if timeTile then
					timeTile:setString("比赛进行中")
				end
				if titleLabel then
					titleLabel:setString(downTime)
				end
				if entryStatus == 1 then
					entryBtn:loadTextureNormal(norImg)
					entryBtn:loadTexturePressed(selImg)
					entryBtn:loadTextureDisabled(selImg)
					entryBtn:setTag(102)
					entryBtn:setEnabled(true)
				end
			-- 未开赛
			elseif cardStatus == 0 then
				downTime = os.date("!%H: %M:%S", 0)
				if titleLabel then
					titleLabel:setString(downTime)
				end
				MttShowLayer.clearSchedule()
			end
		end
	end
	scheduleNode = DZSchedule.runSchedule(update, 1, curNode)
end

function MttShowLayer:buildPlayerUI( layer )
	if curNode then
		curNode:removeFromParent()
		curNode = nil
	end
	curNode = cc.Node:create()
	local function onNodeEvent(event)
		if event == "enter" then
		elseif event == "exit" then
			MttShowLayer.clearSchedule()
		end
	end
	curNode:registerScriptHandler(onNodeEvent)

	local posH = display.height-220
	curNode:setContentSize(cc.size(display.width, posH))
	curNode:setPosition(cc.p(0,0))
	layer:addChild(curNode)

	_playerTab = MttShowCtorl.getPlayerData()
	local isHost = MttShowCtorl.isHost()

	-- 已报名人数
	local entryStr = UIUtil.addLabelArial('已报名:', 30, cc.p(25, posH-34), cc.p(0, 0.5), curNode)

	entryNum = _playerTab.players_num
	entryNumLabel = UIUtil.addLabelArial(entryNum, 30, cc.p(entryStr:getPositionX()+entryStr:getContentSize().width+10, posH-34), cc.p(0, 0.5), curNode)

	--[[if isHost then
		UIUtil.addLabelArial('授权参赛', 28, cc.p(display.width-200, posH-40), cc.p(1, 0.5), curNode):setColor(ResLib.COLOR_BLUE2)
		local function togMenuFunc( tag, sender )
			if sender:getSelectedIndex() == 0 then
				print("on")
				MttShowCtorl.setMttAccess( _retData['pokerId'], 1 )
			else
				print("off")
				MttShowCtorl.setMttAccess( _retData['pokerId'], 0 )
			end
		end
		local switch = UIUtil.addTogMenu({pos = cc.p(display.width-100, posH-40), listener = togMenuFunc, parent = curNode})
		if tonumber(_playerTab.is_access) == 0 then
			-- 关闭
			switch:setSelectedIndex(1)
		else
			-- 开启
			switch:setSelectedIndex(0)
		end
	end--]]

	local searchBg = UIUtil.addImageView({image = "club/team_edit_name_bg.png", touch=false, scale=true, size=cc.size(display.width-40, 60), pos=cc.p(display.width/2, posH-94), ah =cc.p(0.5, 1), parent=curNode})

	local searchStr = nil
	local searchEdit = UIUtil.addEditBox( nil, cc.size(display.width-40-120, 60), cc.p(20, 0), "搜索报名玩家", searchBg )
	searchEdit:setFontColor(display.COLOR_WHITE)
	searchEdit:setMaxLength(24)
	searchEdit:setReturnType(cc.KEYBOARD_RETURNTYPE_SEARCH)
	searchEdit:setAnchorPoint(cc.p(0, 0))
	local function callback( eventType, sender )
		if eventType == "began" then
		elseif eventType == "return" then
			local str = StringUtils.trim(sender:getText())
			local lenStr = ""
            if string.len(str) > 18 then
                lenStr = StringUtils.checkStrLength( str, 18 )
            else
                lenStr = str
            end
			sender:setText(lenStr)
			searchStr = lenStr
			if searchStr == "" then
				curData = {}
				curData = MttShowCtorl.buildPlayerData()
				curTableView:reloadData()
			end
		end
	end
	searchEdit:registerScriptEditBoxHandler( callback )

	-- 搜索按钮
	local function ssFunc(  )
		if not searchStr then
			return
		end
		if searchStr ~= "" then
			if not cc.LuaHelp:IsGameName(searchStr) or string.len(searchStr) > 24 then
				ViewCtrol.showTip({content = "请输入正确的玩家昵称"})
			else
				local tmpTag, data = nil, {}
				tmpTag, data = MttShowCtorl.findPlayerByName(searchStr)
				-- print("-------------- " .. tmpTag)
				dump(data)
				if tmpTag then
					curData = {}
					curData[1] = data
					curTableView:reloadData()
				else
					ViewCtrol.showTip({content = "请输入正确的玩家昵称"})
				end
			end
		end
	end
	UIUtil.addImageBtn({norImg = "common/s_ss_icon.png", selImg = "common/s_ss_icon.png", disImg = "common/s_ss_icon.png", ah = cc.p(1, 0.5), pos = cc.p(display.width-40, searchBg:getContentSize().height/2), touch = true, listener = ssFunc, parent = searchBg})

	local spBg = UIUtil.addImageView({image = "common/com_mtt_bind_bg.png", touch=false, scale=true, size=cc.size(display.width, 90), pos=cc.p(display.width/2, posH-160), ah =cc.p(0.5, 1), parent=curNode})
	-- local title = {"玩家", "牌桌", "通过人", "记分牌"}
	local title = {"玩家", "牌桌", "积分"}
	-- for i=1,#title do
	-- 	UIUtil.addLabelArial(title[i], 32, cc.p(spBg:getContentSize().width*(2*i-1)/6, spBg:getContentSize().height/2), cc.p(0, 0.5), spBg)
	-- end
	local playTitle = UIUtil.addLabelArial(title[1], 32, cc.p(144, spBg:getContentSize().height/2), cc.p(0, 0.5), spBg)
	local tableTitle = UIUtil.addLabelArial(title[2], 32, cc.p(playTitle:getPositionX()+playTitle:getContentSize().width+230, spBg:getContentSize().height/2), cc.p(0, 0.5), spBg)
	local scoreTitle = UIUtil.addLabelArial(title[3], 32, cc.p(tableTitle:getPositionX()+tableTitle:getContentSize().width+116, spBg:getContentSize().height/2), cc.p(0, 0.5), spBg)


	self:addTableView( {tag = MttShowCtorl.MTT_PLAYER, size = cc.size(display.width, posH-400-tableViewHeight), pos = cc.p(0, 145+tableViewHeight), parent = curNode} )

	---------------------
	-- 当前时间
	currentTime = _playerTab.current_time
	startTime = _playerTab.start_time
	entryStatus = tonumber(_playerTab.is_entry)
	cardStatus = tonumber(_playerTab.status)
	isAccess = tonumber(_playerTab.is_access)
	offEntry = tonumber(_playerTab.stop_entry)
	self:addTime_Entry(curNode)

end

function MttShowLayer:buildTableUI( layer )
	if curNode then
		curNode:removeFromParent()
		curNode = nil
	end
	curNode = cc.Node:create()
	local function onNodeEvent(event)
		if event == "enter" then
		elseif event == "exit" then
			MttShowLayer.clearSchedule()
		end
	end
	curNode:registerScriptHandler(onNodeEvent)

	local posH = display.height-220
	curNode:setContentSize(cc.size(display.width, posH))
	curNode:setPosition(cc.p(0,0))
	layer:addChild(curNode)

	_tableTab = MttShowCtorl.getTableData()

	-- 已报名人数
	local entryStr = UIUtil.addLabelArial('已报名:', 30, cc.p(25, posH-40), cc.p(0, 0.5), curNode)
	entryNum = _tableTab.entry_num
	entryNumLabel = UIUtil.addLabelArial(entryNum, 30, cc.p(entryStr:getPositionX()+entryStr:getContentSize().width+10, posH-40), cc.p(0, 0.5), curNode)

	-- 单桌人数
	local aloneLabel = UIUtil.addLabelArial('单桌人数:', 30, cc.p(display.width-100, posH-40), cc.p(1, 0.5), curNode)
	local aloneNum = UIUtil.addLabelArial('9', 30, cc.p(aloneLabel:getPositionX()+10, posH-40), cc.p(0, 0.5), curNode)

	local spBg = UIUtil.addImageView({image = "common/com_mtt_bind_bg.png", touch=false, scale=true, size=cc.size(display.width, 90), pos=cc.p(display.width/2, posH-100), ah =cc.p(0.5, 1), parent=curNode})
	local title = {"牌桌", "玩家人数"}
	UIUtil.addLabelArial(title[1], 32, cc.p(spBg:getContentSize().width/6, spBg:getContentSize().height/2), cc.p(0.5, 0.5), spBg)
	UIUtil.addLabelArial(title[2], 32, cc.p(spBg:getContentSize().width*4/6, spBg:getContentSize().height/2), cc.p(0.5, 0.5), spBg)


	self:addTableView( {tag = MttShowCtorl.MTT_TABLE, size = cc.size(display.width, posH-340-tableViewHeight), pos = cc.p(0, 145+tableViewHeight), parent = curNode} )

	--------------------
	-- 当前时间
	currentTime = _tableTab.current_time
	startTime = _tableTab.start_time
	entryStatus = tonumber(_tableTab.is_entry)
	cardStatus = tonumber(_tableTab.status)
	isAccess = tonumber(_tableTab.is_access)
	offEntry = tonumber(_tableTab.stop_entry)
	
	self:addTime_Entry(curNode)
end

function MttShowLayer:buildAwardUI( layer )
	if curNode then
		curNode:removeFromParent()
		curNode = nil
	end
	curNode = cc.Node:create()
	local function onNodeEvent(event)
		if event == "enter" then
		elseif event == "exit" then
			MttShowLayer.clearSchedule()
		end
	end
	curNode:registerScriptHandler(onNodeEvent)

	local posH = display.height-220
	curNode:setContentSize(cc.size(display.width, posH))
	curNode:setPosition(cc.p(0,0))
	layer:addChild(curNode)

	_awardTab = MttShowCtorl.getAwardData()

	local spB1 = UIUtil.addImageView({image = "common/com_mtt_bind_bg.png", touch=false, scale=true, size=cc.size(display.width, 90), pos=cc.p(display.width/2, posH-15), ah =cc.p(0.5, 1), parent=curNode})
	local awardType = ""
	if tonumber(_awardTab.mtt_type) == 1 then
		awardType = "固定奖励"
	elseif tonumber(_awardTab.mtt_type) == 2 then
		awardType = "浮动奖励"
	else
		awardType = "固定+浮动奖励"
	end
	UIUtil.addLabelArial(awardType, 28, cc.p(spB1:getContentSize().width/2, spB1:getContentSize().height/2), cc.p(0.5, 0.5), spB1)

	-- 总奖池
	local awardLabel = UIUtil.addLabelArial('总奖池:', 28, cc.p(25, posH-140), cc.p(0, 0.5), curNode)
	local awardNum = UIUtil.addLabelArial(_awardTab.awards_count, 28, cc.p(awardLabel:getPositionX()+awardLabel:getContentSize().width+10, posH-140), cc.p(0, 0.5), curNode)

	-- 参赛人数
	local matchLabel = UIUtil.addLabelArial('参赛人数:', 28, cc.p(display.width/2+50, posH-140), cc.p(0, 0.5), curNode)
	local match = (_awardTab.playing_num or 0).."/".._awardTab.players_num
	local matchNum = UIUtil.addLabelArial(match, 28, cc.p(matchLabel:getPositionX()+matchLabel:getContentSize().width+10, posH-140), cc.p(0, 0.5), curNode)

	-- 奖励圈
	local circleLabel = UIUtil.addLabelArial('奖励圈:', 28, cc.p(28, posH-180), cc.p(0, 0.5), curNode)
	local circleNum = UIUtil.addLabelArial(_awardTab.awards_num, 28, cc.p(circleLabel:getPositionX()+circleLabel:getContentSize().width+10, posH-180), cc.p(0, 0.5), curNode)


	local spBg2 = UIUtil.addImageView({image = "common/com_mtt_bind_bg.png", touch=false, scale=true, size=cc.size(display.width, 90), pos=cc.p(display.width/2, posH-220), ah =cc.p(0.5, 1), parent=curNode})
	local title = {"名次", "奖励"}
	UIUtil.addLabelArial(title[1], 32, cc.p(100, spBg2:getContentSize().height/2), cc.p(0, 0.5), spBg2)
	UIUtil.addLabelArial(title[2], 32, cc.p(spBg2:getContentSize().width-100, spBg2:getContentSize().height/2), cc.p(1, 0.5), spBg2)


	self:addTableView( {tag = MttShowCtorl.MTT_AWARD, size = cc.size(display.width, posH-460-tableViewHeight), pos = cc.p(0, 145+tableViewHeight), parent = curNode} )
	
	--------------------
	-- 当前时间
	currentTime = _awardTab.current_time
	startTime = _awardTab.start_time
	cardStatus = tonumber(_awardTab.status)
	entryStatus = tonumber(_awardTab.is_entry)
	isAccess = tonumber(_awardTab.is_access)
	offEntry = tonumber(_awardTab.stop_entry)

	self:addTime_Entry(curNode)
end

function MttShowLayer:buildManageUI( layer )
	if curNode then
		curNode:removeFromParent()
		curNode = nil
	end
	curNode = cc.Node:create()
	local function onNodeEvent(event)
		if event == "enter" then
		elseif event == "exit" then
			MttShowLayer.clearSchedule()
		end
	end
	curNode:registerScriptHandler(onNodeEvent)

	local posH = display.height-220
	curNode:setContentSize(cc.size(display.width, posH))
	curNode:setPosition(cc.p(0,0))
	layer:addChild(curNode)

	local _statusTab = MttShowCtorl.getStatusData()
	local stype = ""
	local fid = _statusTab.fid
	-- dump(_statusTab)
	if _statusTab.game_mod == "mtt_general" then
		stype = "person"
	elseif _statusTab.game_mod == "23" then
		stype = "club"
	end

	print("stype: "..stype)
	if _statusTab.game_mod == "43" then
		self:addTableView( {tag = MttShowCtorl.MTT_MANAGE, size = cc.size(display.width, posH), pos = cc.p(0, 0), parent = curNode} )
	else
		local testly = require("main.SearchCreateManagerLayer"):create(_retData['pokerId'], stype, fid)
		curNode:addChild(testly)
	end
end

function MttShowLayer:addTime_Entry( node )

	-- 房主解散
	local is_host = MttShowCtorl.isHost()
	local chatType = tonumber(_retData.chatType)
	if chatType == DZChat.TYPE_GROUP then
		if is_host then
			local value = 10*60
			local d_value = tonumber(startTime - currentTime)
			if d_value <= value then
				dissolveBtn:setEnabled(false)
			end
		else
			dissolveBtn:setVisible(false)
		end
	end
	
	local game_mod = MttShowCtorl.getGameMod()
	if game_mod == "53" or game_mod == "63" then
		local timeBg = UIUtil.addImageView({image="common/card_mtt_date_icon.png", touch=false, ah = cc.p(0.5,0), pos=cc.p(display.width/2, 165), parent=node})
		timeBg:setLocalZOrder(StringUtils.getMaxZOrder(timeBg))
		local timeValue = tonumber(startTime - currentTime)

		print("-----------------------------------------")
		print(string.format("curTime:%d, startTime:%d, D_value:%d", currentTime, startTime, timeValue))
		print("-----------------------------------------")
		if timeValue <= 0 and cardStatus == 1 then
			downTime = "比赛进行中: ".. os.date("!%H: %M:%S", math.abs(timeValue))
		elseif timeValue <= 10*60 and timeValue > 0 then
			downTime = "距离比赛开始还剩: ".. os.date("!%H: %M:%S", math.abs(timeValue))
		else
			downTime = os.date("%Y年%m月%d日 %H:%M:%S", startTime)
		end
		downTimeLabel = UIUtil.addLabelArial(downTime, 40, cc.p(timeBg:getContentSize().width/2, timeBg:getContentSize().height/2), cc.p(0.5, 0.5), timeBg)
	end
	--------------------
	--[[--]]

	local timeValue = tonumber(startTime - currentTime)

	local norImg = buttonIcon.entry[1]
	local selImg = buttonIcon.entry[2]
	local disImg = nil
	local blindStr = MttShowCtorl.getBlindLevel()
	-- 报名按钮
	entryBtn = UIUtil.addImageBtn({norImg = norImg, selImg = selImg, disImg = disImg, ah = cc.p(0.5, 0.5), pos = cc.p(display.width/2, 60), touch = true, listener = entryFunc, parent = node})

	-- 报名状态
	entryLabel = UIUtil.addLabelArial('', 50, cc.p(display.width/2, 70), cc.p(0.5, 0.5), node)
	-- 报名状态描述
	entryDes = UIUtil.addLabelArial('', 25, cc.p(display.width/2, 130), cc.p(0.5, 0.5), node)

	local entryTag = 100

	-- cardStatus 0 报名中, 1进行中, 2截止报名
	-- entryStatus 0 可以报名， 1 已报名可取消（10分钟内不能取消比赛)， 2待审核，3可重新报名，4被彻底淘汰
	if cardStatus == 0 then
		entryLabel:setString("")
		entryDes:setString("")
		-- 报名
		if entryStatus == 0 then
			entryBtn:loadTextures(buttonIcon.entry[1], buttonIcon.entry[2], buttonIcon.entry[2])
			entryBtn:setTag(100)
		-- 取消报名（不能取消按照距离开赛时间判断）
		elseif entryStatus == 1 then
			entryBtn:loadTextures(buttonIcon.cancel[1], buttonIcon.cancel[2], buttonIcon.cancel[3])
			entryBtn:setTag(101)
			-- 不能取消报名
			local value = 10*60
			if timeValue <= value then
				entryBtn:setEnabled(false)
			end
		elseif entryStatus == 2 then
			entryBtn:setVisible(false)
			entryLabel:setString("等待房主同意您的报名申请...")
			entryDes:setString("")
		end
	elseif cardStatus == 1 then
		entryLabel:setString("")
		entryDes:setString("")
		-- 截止报名
		if offEntry == 1 then
			if entryStatus == 0 or entryStatus == 2 or entryStatus == 3 then
				entryBtn:setVisible(false)
				entryLabel:setString("截止报名")
				entryDes:setString("盲注等级已达到"..blindStr.."级")
			elseif entryStatus == 1 then
				entryBtn:setVisible(true)
				entryBtn:loadTextures(buttonIcon.match[1], buttonIcon.match[2], buttonIcon.match[2])
				entryBtn:setTag(102)
				entryLabel:setString("")
				entryDes:setString("您已在比赛中")
			elseif entryStatus == 4  then
				entryBtn:setVisible(false)
				entryLabel:setString("您已经被淘汰")
				entryDes:setString("已截止报名")
			end
		else
			-- 未报名
			if entryStatus == 0 then
				entryBtn:loadTextures(buttonIcon.entry[1], buttonIcon.entry[2], buttonIcon.entry[2])
				entryBtn:setTag(100)
			-- 回到比赛
			elseif entryStatus == 1 then
				entryDes:setString("您已在比赛中")
				entryBtn:loadTextures(buttonIcon.match[1], buttonIcon.match[2], buttonIcon.match[2])
				entryBtn:setTag(102)
			-- 待审核
			elseif entryStatus == 2 then
				entryBtn:setVisible(false)
				entryLabel:setString("等待房主同意您的报名申请...")
				entryDes:setString("")
			-- 重新报名
			elseif entryStatus == 3 then
				entryBtn:loadTextures(buttonIcon.re_entry[1], buttonIcon.re_entry[2], buttonIcon.re_entry[2])
				entryBtn:setTag(100)
			-- 已被淘汰
			elseif entryStatus == 4 then
				entryBtn:setVisible(false)
				entryLabel:setString("您已经被淘汰")
				entryDes:setString("")
			end
		end
	elseif cardStatus == 3 then
		entryBtn:setVisible(false)
		entryLabel:setString("比赛已结束")
		entryDes:setString("")
	end

	if game_mod ~= "mtt_general" then
		if cardStatus ~= 3 then
			-- 倒计时
			if timeValue <= 60*10 then
				self:countdown()
			end
		end
	end
	
end

-- 倒计时
function MttShowLayer:countdown(  )
	local d_value = tonumber(startTime - currentTime)
	local cardTime = 0
	local backMatch = 0

	local norImg = buttonIcon.match[1]
	local selImg = buttonIcon.match[2]

	local function update( dt )
		cardTime = cardTime + 1
		d_value = d_value - 1

		-- 比赛倒计时
		if d_value > 0 then
			downTime = os.date("!%H: %M:%S", d_value)
			print(downTime)
			if downTimeLabel then
				downTimeLabel:setString("距离比赛开始还剩: "..downTime)
			end
		-- 比赛数据初始化
		elseif d_value == 0 then
			backMatch = 1
			if downTimeLabel then
				downTimeLabel:setString("比赛即将开始")
			end
			MttShowLayer.clearSchedule()
			-- 未收到游戏开始的推送时等待5s后刷新界面
			DZAction.delateTime(_mttShowLayer, 5, function()
				if MttShowCtorl.isMttShow() then
					MttShowLayer.updateMttTime( _retData )
				end
			end)
			
		-- 比赛进行中
		else
			-- 已开赛
			if cardStatus == 1 then
				cardTime = math.abs(d_value)
				-- print("-------------: "..cardTime)
				downTime = os.date("!%H: %M:%S", cardTime)
				-- print("-------------: "..downTime)
				if downTimeLabel then
					downTimeLabel:setString("比赛进行中: "..downTime)
				end
				if entryStatus == 1 then
					entryBtn:loadTextureNormal(norImg)
					entryBtn:loadTexturePressed(selImg)
					entryBtn:loadTextureDisabled(selImg)
					entryBtn:setTag(102)
					entryBtn:setEnabled(true)
				end
			-- 未开赛
			elseif cardStatus == 0 then
				if downTimeLabel then
					downTimeLabel:setString("比赛即将开始")
				end
				MttShowLayer.clearSchedule()
			end
		end
	end
	scheduleNode = DZSchedule.runSchedule(update, 1, curNode)
end

function MttShowLayer:addTableView( params )

	curTableView = nil
	curData = {}

	if CUR_TARGET == MttShowCtorl.MTT_PLAYER then
		curData = MttShowCtorl.buildPlayerData()
	elseif CUR_TARGET == MttShowCtorl.MTT_TABLE then
		curData = _tableTab.table_info
	elseif CUR_TARGET == MttShowCtorl.MTT_AWARD then
		curData = _awardTab.awards_level
	elseif CUR_TARGET == MttShowCtorl.MTT_MANAGE then
		local manageTab = MttShowCtorl.getManageData().managers
		for k,v in pairs(manageTab) do
			local tab = {}
			tab = v
			tab["isAccess"] = 0
			if MttShowCtorl.isAccess() then
				tab["isAccess"] = 1
			end
			curData[#curData+1] = tab
		end
	end
	dump(curData)
	curTableView = self:createTableView( params.size, params.pos, params.parent)
end

function MttShowLayer:createTableView( size, pos, parent )
	local function tableCellTouched( tableViewSender, tableCell )
		local idx = tableCell:getIdx()+1
		local data = curData[idx]
		if CUR_TARGET == MttShowCtorl.MTT_PLAYER then
			
		elseif CUR_TARGET == MttShowCtorl.MTT_TABLE then
			-- if cardStatus == 1 and entryStatus == 1 then
			-- 	print("回到比赛状态时不允许观看比赛")
			-- 	ViewCtrol.showTip({content = "您已经在比赛中,不允许旁观"})
			-- 	return
			-- end
			-- local GameWait = require 'game.GameWait'
			-- GameWait.requestMttCodeAndPokerId(_retData['pokerId'], data.table_id)
		elseif CUR_TARGET == MttShowCtorl.MTT_AWARD then
			
		end
	end
	local function cellSizeForTable( tableViewSender, cellIndex )
		return 0, 102
	end

	local function numberOfCellsInTableView( tableViewSender )
		return #curData
	end

	local function tableCellAtIndex( tableViewSender, cellIndex )
		--print('tableCellAtIndex')
		local index = cellIndex + 1
		local cellItem = tableViewSender:dequeueCell()
		if cellItem == nil then
			cellItem = cc.TableViewCell:new()
			-- 创建函数
			if CUR_TARGET == MttShowCtorl.MTT_PLAYER then
				self:buildPlayerCellTmpl(cellItem)
			elseif CUR_TARGET == MttShowCtorl.MTT_TABLE then
				self:buildTableCellTmpl(cellItem)
			elseif CUR_TARGET == MttShowCtorl.MTT_AWARD then
				self:buildAwardCellTmpl(cellItem)
			elseif CUR_TARGET == MttShowCtorl.MTT_MANAGE then
				self:buildManageCellTmpl(cellItem)
			end

		end
		-- 修改函数
		if CUR_TARGET == MttShowCtorl.MTT_PLAYER then
			self:updatePlayerCellTmpl(cellItem, index)
		elseif CUR_TARGET == MttShowCtorl.MTT_TABLE then
			self:updateTableCellTmpl(cellItem, index)
		elseif CUR_TARGET == MttShowCtorl.MTT_AWARD then
			self:updateAwardCellTmpl(cellItem, index)
		elseif CUR_TARGET == MttShowCtorl.MTT_MANAGE then
			self:updateManageCellTmpl(cellItem, index)
		end
		
		return cellItem
	end

	local tableView = cc.TableView:create( size )
	tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
	tableView:setPosition(pos)
	parent:addChild(tableView)
	tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
	tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
	tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
	tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
	tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
	tableView:setDelegate()
	tableView:reloadData()
	return tableView
end

-- 玩家
function MttShowLayer:buildPlayerCellTmpl( cellItem )
	local girdNodes = {}
	girdNodes = cellItem
	local cellBg = UIUtil.addImageView({image = "common/card_mtt_des_bg.png", touch=false, scale=true, size=cc.size(display.width, 100),pos=cc.p(0,0), ah=cc.p(0,0), parent=cellItem})
	local width = cellBg:getContentSize().width
	local height = cellBg:getContentSize().height
	-- 名称
	local label1 = UIUtil.addLabelArial('', 30, cc.p(20, height/2), cc.p(0, 0.5), cellBg)
	girdNodes.label1 = label1

	-- 牌桌
	local label2 = UIUtil.addLabelArial('10/20', 30, cc.p(470, height/2), cc.p(0.5, 0.5), cellBg)
	girdNodes.label2 = label2

	-- 通过人
	-- local label4 = UIUtil.addLabelArial('10', 30, cc.p(440, height/2), cc.p(0, 0.5), cellBg)
	-- girdNodes.label4 = label4

	-- 记分牌
	local label3 = UIUtil.addLabelArial('10', 30, cc.p(650, height/2), cc.p(0.5, 0.5), cellBg)
	girdNodes.label3 = label3

	-- 报名标示（仅限授权）
	local entryIcon = UIUtil.addPosSprite("common/card_mtt_entry_icon.png", cc.p(width/4+30, height/2), cellBg, cc.p(0, 0.5))
	girdNodes.entryIcon = entryIcon
	local entryNum = UIUtil.addLabelArial('1', 22, cc.p(entryIcon:getContentSize().width/2+5, entryIcon:getContentSize().height/2), cc.p(0, 0.5), entryIcon):setColor(display.COLOR_BLACK)
	girdNodes.entryNum = entryNum

	-- 排名图标（仅限已开赛）
	local rankIcon = UIUtil.addPosSprite("bg/all_mttDetailR1.png", cc.p(20, height/2), cellBg, cc.p(0, 0.5))
	girdNodes.rankIcon = rankIcon

	local rankNum = UIUtil.addLabelArial('1', 22, cc.p(rankIcon:getContentSize().width/2, rankIcon:getContentSize().height/2), cc.p(0.5, 0.5), rankIcon):setColor(cc.c3b(155, 150, 196))
	girdNodes.rankNum = rankNum

	-- 重购
	local reBuyIcon = UIUtil.addPosSprite("common/card_mtt_rebuy_num.png", cc.p(width/4+30, height/2), cellBg, cc.p(0, 0.5))
	girdNodes.reBuyIcon = reBuyIcon
	local reBuyNum = UIUtil.addLabelArial('1', 15, cc.p(reBuyIcon:getContentSize().width/2+5, reBuyIcon:getContentSize().height/2+3), cc.p(0, 1), reBuyIcon):setColor(display.COLOR_BLACK)
	girdNodes.reBuyNum = reBuyNum

	-- 增购
	local addOnIcon = UIUtil.addPosSprite("common/card_mtt_bind_addbuy_icon.png", cc.p(width/4+30, height/2), cellBg, cc.p(0, 0.5))
	girdNodes.addOnIcon = addOnIcon


	-- 拒绝
	local function refuseFun( sender )
		local tag = sender:getTag()
		self:okOrNoPlayer( tag, 0 )
	end
	local refuseBtn = UIUtil.addImageBtn({norImg = "common/card_mtt_player_refuse_btn.png", selImg = "common/card_mtt_player_refuse_btn.png", disImg = "common/card_mtt_player_refuse_btn.png", ah = cc.p(0.5, 0.5), pos = cc.p(width*5/6-45, height/2), touch = true, listener = refuseFun, parent = cellBg})
	girdNodes.refuseBtn = refuseBtn

	-- 同意
	local function agreeFun( sender )
		local tag = sender:getTag()
		self:okOrNoPlayer( tag, 1 )
	end
	local agreeBtn = UIUtil.addImageBtn({norImg = "common/card_mtt_player_agree_btn.png", selImg = "common/card_mtt_player_agree_btn.png", disImg = "common/card_mtt_player_agree_btn.png", ah = cc.p(0.5, 0.5), pos = cc.p(width*5/6+45, height/2), touch = true, listener = agreeFun, parent = cellBg})
	girdNodes.agreeBtn = agreeBtn
end

function MttShowLayer:updatePlayerCellTmpl( cellItem, cellIndex )
	local girdNodes = cellItem
	local data = curData[cellIndex]

	local name = StringUtils.getShortStr( data.user_name, 18)
	girdNodes.label1:setString(name)
	local str = ""
	if data.table and data.table ~= "" then
		str = "牌桌"..data.table
	else
		str = ""
	end
	girdNodes.label2:setString(str)

	if data.key == "entry" then
		girdNodes.entryIcon:setVisible(true)
		girdNodes.entryNum:setString("")
		local img = ""
		if data.apply_type == 0 then
			img = "common/card_mtt_entry_icon.png"
		elseif data.apply_type == 1 or data.apply_type == 3 then
			img = "common/card_mtt_rebuy_icon.png"
			local r_num = data.r_num
			if data.r_num == 0 then
				r_num = 1
			end
			girdNodes.entryNum:setString(r_num)
		elseif data.apply_type == 2 then
			img = "common/card_mtt_addon_icon.png"
		end
		girdNodes.entryIcon:setTexture(img)
		girdNodes.entryIcon:setPositionX(girdNodes.label1:getPositionX()+girdNodes.label1:getContentSize().width+10)

		girdNodes.entryNum:setPositionX(girdNodes.entryIcon:getContentSize().width/2+18)

		girdNodes.reBuyIcon:setVisible(false)
		girdNodes.addOnIcon:setVisible(false)
		girdNodes.rankIcon:setVisible(false)
		girdNodes.rankNum:setString("")

		-- girdNodes.label4:setString(data.invite_code or "000")
		if data.isAgree == 0 then
			girdNodes.refuseBtn:setVisible(false)
			girdNodes.agreeBtn:setVisible(false)
			girdNodes.label3:setString("已拒绝")
		elseif data.isAgree == 1 then
			girdNodes.refuseBtn:setVisible(false)
			girdNodes.agreeBtn:setVisible(false)
			girdNodes.label3:setString("已同意")
		elseif data.isAgree == 2 then
			girdNodes.refuseBtn:setVisible(true)
			girdNodes.agreeBtn:setVisible(true)
			girdNodes.refuseBtn:setTag(cellIndex)
			girdNodes.agreeBtn:setTag(cellIndex)
			girdNodes.label3:setString("")
		end
	else
		girdNodes.entryIcon:setVisible(false)

		girdNodes.refuseBtn:setVisible(false)
		girdNodes.agreeBtn:setVisible(false)
		-- girdNodes.label4:setString(data.invite_code or "000")
		girdNodes.label3:setString(data.get_back)

		-- 比赛进行中
		if data.cardStatus == 1 or data.cardStatus == 3 then
			-- 排名
			girdNodes.rankIcon:setVisible(true)
			if data.rank <= 3 then
				girdNodes.rankIcon:setTexture("bg/all_mttDetailR"..data.rank..".png")
				girdNodes.rankNum:setString("")
			else
				girdNodes.rankIcon:setTexture("common/card_mtt_rank_circle.png")
				girdNodes.rankNum:setString(data.rank)
				girdNodes.rankNum:setPosition(cc.p(girdNodes.rankIcon:getContentSize().width/2, girdNodes.rankIcon:getContentSize().height/2))
			end
			girdNodes.label1:setPositionX(girdNodes.rankIcon:getPositionX()+girdNodes.rankIcon:getContentSize().width+10)
			-- 重购
			if tonumber(data.r_num) ~= 0 then
				girdNodes.reBuyIcon:setVisible(true)
				girdNodes.reBuyNum:setString(data.r_num)
				girdNodes.reBuyNum:setPositionX(girdNodes.reBuyIcon:getContentSize().width/2+5)
				girdNodes.reBuyIcon:setPositionX(girdNodes.label1:getPositionX()+girdNodes.label1:getContentSize().width+10)
			else
				girdNodes.reBuyIcon:setVisible(false)
				girdNodes.reBuyNum:setString("")
			end
			-- 增购
			if tonumber(data.addon_num) ~= 0 then
				girdNodes.addOnIcon:setVisible(true)
				if girdNodes.reBuyIcon:isVisible() then
					girdNodes.addOnIcon:setPositionX(girdNodes.reBuyIcon:getPositionX()+girdNodes.reBuyIcon:getContentSize().width+10)
				else
					girdNodes.addOnIcon:setPositionX(girdNodes.label1:getPositionX()+girdNodes.label1:getContentSize().width+10)
				end
			else
				girdNodes.addOnIcon:setVisible(false)
			end
		else
			girdNodes.reBuyIcon:setVisible(false)
			girdNodes.reBuyNum:setString("")
			girdNodes.addOnIcon:setVisible(false)
			girdNodes.rankIcon:setVisible(false)
			girdNodes.rankNum:setString("")
		end
	end
end
-- 拒绝、同意玩家加入
function MttShowLayer:okOrNoPlayer( idx, isAgree )
	local tab = curData[idx]
	local function response( data )
		if data.code == 0 then
			if isAgree == 0 then
				curData[idx]["isAgree"] = 0
				-- table.remove(curData, idx)
			elseif isAgree == 1 then
				curData[idx]["isAgree"] = 1
				-- curData[idx].key = "playing"
				-- curData[idx]["rank"] = (curData[#curData].rank or 0)+1
				curData[idx]["cardStatus"] = cardStatus
			end
			local offset = curTableView:getContentOffset()
			dump(curData)
			curTableView:reloadData()
			if idx > 7 then
				curTableView:setContentOffset(offset)
			end
		end
	end
	local tabData = {}
	tabData["mtt_id"] = _retData['pokerId']
	tabData["uid"] = tab.uid
	tabData["access"] = isAgree
	tabData["apply_type"] = tab.apply_type
	XMLHttp.requestHttp("mttPlayersEntryAccess", tabData, response, PHP_POST)
end
---------------------

-- 牌桌
function MttShowLayer:buildTableCellTmpl( cellItem )
	local girdNodes = {}
	girdNodes = cellItem
	local cellBg = UIUtil.addImageView({image = "common/card_mtt_des_bg.png", touch=false, scale=true, size=cc.size(display.width, 100),pos=cc.p(0,0), ah=cc.p(0,0), parent=cellItem})
	local width = cellBg:getContentSize().width
	local height = cellBg:getContentSize().height

	-- local tableBg = UIUtil.addPosSprite("common/card_mtt_table_bg.png", cc.p(width/6, height/2), cellBg, cc.p(0.5, 0.5))
	local label1 = UIUtil.addLabelArial('1', 30, cc.p(width/6, height/2), cc.p(0.5, 0.5), cellBg)
	girdNodes.label1 = label1

	local label2 = UIUtil.addLabelArial('9', 30, cc.p(width*4/6, height/2), cc.p(0.5, 0.5), cellBg)
	girdNodes.label2 = label2

	local function btnBack( sender )
		local idx = sender:getTag()
		local data = curData[idx]
		if cardStatus == 1 and entryStatus == 1 then
			print("回到比赛状态时不允许观看比赛")
			ViewCtrol.showTip({content = "您已经在比赛中,不允许旁观"})
			return
		end
		local GameWait = require 'game.GameWait'
		GameWait.requestMttCodeAndPokerId(_retData['pokerId'], data.table_id)
	end
	local btn = UIUtil.addImageBtn({norImg = "common/card_mtt_lookBtn.png", selImg = "common/card_mtt_lookBtn_height.png", disImg = "common/card_mtt_lookBtn.png", ah =cc.p(0.5, 0.5), pos = cc.p(width*5/6+40, height/2), touch = true, listener = btnBack, parent = cellBg})
	girdNodes.btn = btn
end

function MttShowLayer:updateTableCellTmpl( cellItem, cellIndex )
	local girdNodes = cellItem
	local data = curData[cellIndex]

	local table_num = tonumber(data.table_num)+1 or 1
	girdNodes.label1:setString("牌桌"..tostring(table_num))
	girdNodes.label2:setString(data.players_num)

	girdNodes.btn:setTag(cellIndex)
end

-- 奖励
function MttShowLayer:buildAwardCellTmpl( cellItem )
	local girdNodes = {}
	girdNodes = cellItem
	local cellBg = UIUtil.addImageView({image = "common/card_mtt_des_bg.png", touch=false, scale=true, size=cc.size(display.width, 100),pos=cc.p(0,0), ah=cc.p(0,0), parent=cellItem})
	local width = cellBg:getContentSize().width
	local height = cellBg:getContentSize().height

	local label1 = UIUtil.addLabelArial('哈哈哈啊哈哈', 30, cc.p(width/6, height/2), cc.p(0.5, 0.5), cellBg)
	girdNodes.label1 = label1

	local label2 = UIUtil.addLabelArial('10', 30, cc.p(width*5/6, height/2), cc.p(0.5, 0.5), cellBg)
	girdNodes.label2 = label2
end

function MttShowLayer:updateAwardCellTmpl( cellItem, cellIndex )
	local girdNodes = cellItem
	local data = curData[cellIndex]

	girdNodes.label1:setString(cellIndex)
	girdNodes.label2:setString(data)
end

-- 牌桌
function MttShowLayer:buildManageCellTmpl( cellItem )
	local girdNodes = {}
	girdNodes = cellItem
	local cellBg = UIUtil.addImageView({image = "common/card_mtt_des_bg.png", touch=false, scale=true, size=cc.size(display.width, 100),pos=cc.p(0,0), ah=cc.p(0,0), parent=cellItem})
	local width = cellBg:getContentSize().width
	local height = cellBg:getContentSize().height

	local stencil, Icon = UIUtil.createCircle(ResLib.CLUB_HEAD_GENERAL, cc.p(60,height/2), cellBg, ResLib.CLUB_HEAD_STENCIL_200, 0.4)
	girdNodes.stencil = stencil
	girdNodes.Icon = Icon

	-- 俱乐部名称、后缀
	local club_name, club_icon = UIUtil.addNameByType({nameType = 6, nameStr = "俱乐部", fontSize = 36, pos = cc.p(120, height/2+20), parent = cellBg})
	girdNodes.club_name = club_name
	girdNodes.club_icon = club_icon

	local clubNum = UIUtil.addLabelArial('名片ID 10000', 26, cc.p(120, height/2-20), cc.p(0, 0.5), cellBg):setColor(ResLib.COLOR_GREY)
	girdNodes.clubNum = clubNum

	local function btnBack( sender )

		local idx = sender:getTag()
		local tab = {pokerId = _retData['pokerId'], club_id = curData[idx].id }

		MttShowCtorl.dataStatManageInfo(function ( data )
			local MttCheckList = require("common.MttCheckList")
			local layer = MttCheckList:create()
			_mttShowLayer:addChild(layer, 10)
			layer:createLayer(data, curData[idx].clubname)
		end, tab)
	end
	local btn = UIUtil.addImageBtn({norImg = "common/s_ckan.png", selImg = "common/s_ckand.png", disImg = "common/s_ckand.png", ah =cc.p(1, 0.5), pos = cc.p(width-20, height/2), touch = true, listener = btnBack, parent = cellBg})
	girdNodes.btn = btn
end

function MttShowLayer:updateManageCellTmpl( cellItem, cellIndex )
	local girdNodes = cellItem
	local data = curData[cellIndex]
	local name = StringUtils.getShortStr( data.clubname , LEN_NAME)
	girdNodes.club_name:setString(name)

	
	UIUtil.updateNameByType( 6, girdNodes.club_name, girdNodes.club_icon )
	girdNodes.Icon:setTexture(ResLib.CLUB_HEAD_GENERAL)

	girdNodes.clubNum:setString("名片ID "..tostring(data.club_num))

	if data.isAccess == 1 then
		girdNodes.btn:setVisible(true)
		girdNodes.btn:setTag(cellIndex)
	else
		girdNodes.btn:setVisible(false)
	end
	

	local url = data.headimg
	local function funcBack( path )
		girdNodes.Icon:setTexture(path)
	end
	ClubModel.downloadPhoto(funcBack, url, true)
end

function MttShowLayer:initData(  )
	_statusTab = {}
	_playerTab = {}
	_tableTab  = {}
	_awardTab  = {}

	downTime = 0
	downTimeLabel = nil

	scheduleNode = nil
	
	startTime = 0
	-- 0 比赛未开始可报名，1比赛进行中可报名，2报名截止，3比赛结束
	cardStatus = 0
	entryStatus = 0
	isAccess = 0
	offEntry = 0
	weedOut = 0
	entryBtn = nil
	entryLabel = nil
	entryDes = nil

	entryNum = 0

	entryNumLabel = nil
end

function MttShowLayer:createLayer( tab, mttTag )
	_mttShowLayer = self
	_mttShowLayer:setSwallowTouches()
	UIUtil.setBgScale(ResLib.MAIN_BG, display.center, self)

	if mttTag then
		MTT_TARGET = mttTag
	else
		MTT_TARGET = CardCtrol.isCardScene()
	end

	curNode = nil
	dissolveBtn = nil
	imageView = nil

	CUR_TARGET = nil

	tableViewHeight = 0

	buttonIcon = {}

	_statusTab = {}
	_playerTab = {}
	_tableTab  = {}
	_awardTab  = {}

	redPoint_bg = nil

	schedule = nil
	myupdate = nil

	_retData = tab

	self:initData()

	self:buildLayer()

end

function MttShowLayer.clearSchedule( dissolve )
	if dissolve then
		if downTimeLabel then
			downTimeLabel:setString("比赛已解散")
		end
	end
	
	
	-- if schedule then
	-- 	print("移除定时器")
	-- 	schedule:unscheduleScriptEntry(myupdate)
	-- 	schedule = nil
	-- 	myupdate = nil
	-- end
	if scheduleNode then
		scheduleNode:removeFromParent()
		scheduleNode = nil
	end
end

function MttShowLayer.updateMttTime( tab )
	dump(tab)
	print("CUR_TARGET------> :" .. CUR_TARGET)
	if CUR_TARGET == nil or next(tab) == nil then
		return
	end
	MttShowLayer.clearSchedule()
	_mttShowLayer:initData()
	if CUR_TARGET == MttShowCtorl.MTT_STATUS then
		MttShowCtorl.dataStatStatus(function (  )
			local game_mod = MttShowCtorl.getGameMod()
			if game_mod == "mtt_general" or game_mod == "23" or game_mod == "33" or game_mod == "43" then
				_mttShowLayer:buildStatusUI(imageView)
			else
				_mttShowLayer:buildStatusUI1(imageView)
			end
		end, tab)
	elseif CUR_TARGET == MttShowCtorl.MTT_PLAYER then
		MttShowCtorl.dataStatPlayer(function (  )
			_mttShowLayer:buildPlayerUI(imageView)
		end, tab)
	elseif CUR_TARGET == MttShowCtorl.MTT_TABLE then
		MttShowCtorl.dataStatTable(function (  )
			_mttShowLayer:buildTableUI(imageView)
		end, tab)
	elseif CUR_TARGET == MttShowCtorl.MTT_AWARD then
		MttShowCtorl.dataStatAward(function (  )
			_mttShowLayer:buildAwardUI(imageView)
		end, tab)
	end
end

function MttShowLayer.updatePlayer( tab )
	if CUR_TARGET == MttShowCtorl.MTT_PLAYER then
		_mttShowLayer:initData()
		MttShowCtorl.dataStatPlayer(function (  )
			_mttShowLayer:buildPlayerUI(imageView)
		end, tab)
	else
		return
	end
end

function MttShowLayer.updateMttEntry(entryTag)
	if entryTag == 1 then
		entryNum = tonumber(entryNum)+1
	elseif entryTag == 0 then
		if tonumber(entryNum) > 0 then
			entryNum = tonumber(entryNum)-1
		end	
	end
	
	if entryNumLabel then
		entryNumLabel:setString(entryNum)
	end
end

return MttShowLayer