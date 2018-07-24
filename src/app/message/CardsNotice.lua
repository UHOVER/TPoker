local ViewBase = require("ui.ViewBase")
local CardsNotice = class("CardsNotice", ViewBase)

local MessageCtorl = require("message.MessageCtorl")

local _cardsNotice = nil
local imageView = nil
local curData = {}
local curTableView = nil

local _callTag = nil
--进入游戏中、聊天界面
local _isUpdateCardsMsg = false

local function netBack(data)
	_cardsNotice:removeFromParent()

	--_callTag为nil是游戏界面调用
	ViewCtrol.fromApplyList(_callTag)

	local tlist = data
	if not tlist or #tlist == 0 then
		local GameScene = require 'game.GameScene'
		GameScene.removeNewMsgSignUp()
	end

	NewMsgMgr.checkNewMsg(NewMsgMgr.INTO_BACKGROUND)
end

local function Callback()

	Notice.deleteMessage( 6 )

	local noticeTab = Notice.getMessagePushCount( 5 )
	if next(noticeTab) ~= nil then
		Notice.deleteCardMsg( noticeTab.count )
	end
	
	local MessageLayer = require("message.MessageLayer")
	if _isUpdateCardsMsg then
		_cardsNotice:removeFromParent()
	    MessageLayer.updateCardsMsg(true)
	else
		MessageCtorl.dataStatCardNotice(netBack)
		if MessageCtorl.isMessageLayer() then
			MessageLayer.updateCardsMsg(true)
		end
	end
end

function CardsNotice:buildLayer(  )
	UIUtil.addTopBar({backFunc = Callback, title = "牌局请求", parent = self})
	imageView = UIUtil.addImageView({touch=true, scale=true, size=cc.size(display.width, display.height-130), pos=cc.p(0,0), parent=self})

	NewMsgMgr.msgLayerRemoveMsg()
	
	curData = MessageCtorl.getCardData(true)
	dump(curData)
	
	curTableView = self:createTableView()
	curTableView:reloadData()

	local noticeTab = Notice.getMessagePushCount( 5 )
	if next(noticeTab) ~= nil then
		Notice.deleteCardMsg( noticeTab.count )
	end
	Notice.deleteMessage( 6 )

end

function CardsNotice:createTableView(  )

	local function tableCellTouched( tableViewSender, tableCell )
	end
	local function cellSizeForTable( tableViewSender, cellIndex )
		local data = curData[cellIndex+1]
		if data.first == 1 then
			return 0, 200
		else
			return 0, 130
		end
	end
	local function numberOfCellsInTableView( tableViewSender )
		return #curData
	end
	local function tableCellAtIndex( tableViewSender, cellIndex )
		local cellItem = tableViewSender:dequeueCell()
		if cellItem == nil then
			cellItem = cc.TableViewCell:new()

			self:buildCellTmpl(cellItem)
		end
		self:updateCellTmpl(cellItem, cellIndex)

		return cellItem
	end
	
	local tableView = cc.TableView:create(cc.size(display.width, display.height - 130))
	tableView:setPosition(cc.p(0, 0))
	tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
	imageView:addChild(tableView)
	tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
	tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
	tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
	tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
	tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
	tableView:setBounceable(true)
	tableView:setDelegate()
	tableView:reloadData()

	return tableView
end

function CardsNotice:buildCellTmpl( cellItem )
	local girdNodes = {}
	girdNodes = cellItem

	local cellBg = UIUtil.addImageView({image=ResLib.TABLEVIEW_CELL_BG, touch=false, scale=true, size=cc.size(display.width, 130), pos=cc.p(0,0), ah=cc.p(0,0), parent=cellItem})
	local width = cellBg:getContentSize().width
	local height = cellBg:getContentSize().height

	local textBg = UIUtil.addImageView({image = ResLib.TABLEVIEW_TEXT_LINE, touch=false, scale=true, size=cc.size(display.width, 70),pos=cc.p(display.width/2, height), ah=cc.p(0.5,0), parent=cellItem})
	girdNodes.textBg = textBg

	local cardName = UIUtil.addLabelArial('', 26, cc.p(20, textBg:getContentSize().height/2), cc.p(0, 0.5), textBg):setColor(cc.c3b(170, 170, 170))
	girdNodes.cardName = cardName

	local cardMod = UIUtil.addLabelArial('', 26, cc.p(cardName:getPositionX()+cardName:getContentSize().width+10, textBg:getContentSize().height/2), cc.p(0, 0.5), textBg):setColor(cc.c3b(170, 170, 170))
	girdNodes.cardMod = cardMod

	local cardFrom = UIUtil.addLabelArial('', 22, cc.p(width-25, textBg:getContentSize().height/2), cc.p(1, 0.5), textBg):setColor(ResLib.COLOR_GREY)
	girdNodes.cardFrom = cardFrom

	local userName = UIUtil.addLabelArial('', 26, cc.p(cardFrom:getPositionX()+cardFrom:getContentSize().width+10, textBg:getContentSize().height/2), cc.p(1, 0.5), textBg):setColor(cc.c3b(170, 170, 170))
	girdNodes.userName = userName

	local stencil, Icon = UIUtil.createCircle(ResLib.USER_HEAD, cc.p(75,height/2), cellBg, ResLib.CLUB_HEAD_STENCIL_200)
	girdNodes.stencil = stencil
	girdNodes.Icon = Icon

	local msgTitle = UIUtil.addLabelArial('消息标题', 36, cc.p(150, height*3/4), cc.p(0, 0.5), cellBg)
	girdNodes.msgTitle = msgTitle

	local msgContent = UIUtil.addLabelArial('申请带入', 26, cc.p(150, height/4), cc.p(0, 0.5), cellBg):setColor(cc.c3b(170, 170, 170))
	girdNodes.msgContent = msgContent

	local spIcon = UIUtil.addPosSprite("user/icon_spades.png", cc.p(msgContent:getPositionX()+msgContent:getContentSize().width+50, height/4), cellBg, cc.p(0.5,0.5))

	local msgContentNum = UIUtil.addLabelArial('200', 26, cc.p(spIcon:getPositionX()+spIcon:getContentSize().width+3, height/4), cc.p(0, 0.5), cellBg)
	girdNodes.msgContentNum = msgContentNum

	local msgResult = UIUtil.addLabelArial('已拒绝', 26, cc.p(width-110, height/2), cc.p(0.5, 0.5), cellBg)
	girdNodes.msgResult = msgResult

	local function noFuncback( sender )
		local tag = sender:getTag()
		self:agree_refuseCard( tag, false )
	end
	local refuseBtn = UIUtil.addImageBtn({norImg = "common/card_mtt_player_refuse_btn.png", selImg = "common/card_mtt_player_refuse_btn.png", disImg = "common/card_mtt_player_refuse_btn.png", pos = cc.p(width-110, height/2), ah = cc.p(1, 0.5), touch = true, listener = noFuncback, parent = cellBg})
	girdNodes.refuseBtn = refuseBtn

	local function okFuncback( sender )
		local tag = sender:getTag()
		self:agree_refuseCard( tag, true )
	end
	local agreeBtn = UIUtil.addImageBtn({norImg = "common/card_mtt_player_agree_btn.png", selImg = "common/card_mtt_player_agree_btn.png", disImg = "common/card_mtt_player_agree_btn.png", pos = cc.p(width-20, height/2), ah = cc.p(1, 0.5), touch = true, listener = okFuncback, parent = cellBg})
	girdNodes.agreeBtn = agreeBtn

end

function CardsNotice:updateCellTmpl( cellItem, cellIndex )
	local girdNodes = cellItem
	local data = curData[cellIndex+1]

	if data.first == 1 then
		girdNodes.textBg:setVisible(true)
		local card_mod, card_from = CardsNotice:thinkCardsMod( data.game_mod )
		girdNodes.cardName:setString(data.table_name)
		girdNodes.cardMod:setString(card_mod)
		girdNodes.cardMod:setPositionX(girdNodes.cardName:getPositionX()+girdNodes.cardName:getContentSize().width+10)
		girdNodes.cardFrom:setString(card_from)
		girdNodes.userName:setString(data.host_name)
		girdNodes.userName:setPositionX(girdNodes.cardFrom:getPositionX()-girdNodes.cardFrom:getContentSize().width-10)
		if data.game_mod == GAME_TYPE_MTT or data.game_mod == GAME_CLUB_MTT or data.game_mod == GAME_CIRCLE_MTT or data.game_mod == GAME_UNION_MTT then
			girdNodes.cardName:setColor(ResLib.COLOR_PURPLE)
		elseif data.game_mod == GAME_CLUB_STABDARD or data.game_mod == GAME_CIRCLE_STABDARD or data.game_mod == GAME_UNION_STABDARD or data.game_mod == GAME_TYPE_STANDARD or data.game_mod == GAME_CLUB_STABDARD_SECURE or data.game_mod == GAME_CIRCLE_STABDARD_SECURE or data.game_mod == GAME_UNION_STABDARD_SECURE or data.game_mod == GAME_TYPE_STANDARD_SECURE then
			girdNodes.cardName:setColor(ResLib.COLOR_BLUE)
		elseif data.game_mod == GAME_CLUB_SNG or data.game_mod == GAME_CIRCLE_SNG or data.game_mod == GAME_UNION_SNG or data.game_mod == GAME_TYPE_SNG then
			girdNodes.cardName:setColor(ResLib.COLOR_ORANGE1)
		end
	else
		girdNodes.textBg:setVisible(false)
	end

	girdNodes.msgTitle:setString(data.apply_name)
	if data.game_mod == GAME_TYPE_MTT or data.game_mod == GAME_CLUB_MTT or data.game_mod == GAME_CIRCLE_MTT or data.game_mod == GAME_UNION_MTT then
		if data.apply_type == 0 then
			girdNodes.msgContent:setString("申请报名")
		elseif data.apply_type == 1 or data.apply_type == 3 then
			local r_num = ""
			if data.r_num > 0 then
				r_num = data.r_num
			end
			girdNodes.msgContent:setString("申请重购"..r_num)
		elseif data.apply_type == 2 then
			girdNodes.msgContent:setString("申请增购")
		end
	else
		girdNodes.msgContent:setString("申请带入")
	end
	
	girdNodes.msgContentNum:setString(data.cost)

	if data.isAgree == 0 then
		girdNodes.agreeBtn:setVisible(false)
		girdNodes.refuseBtn:setVisible(false)
		girdNodes.msgResult:setString("已拒绝")
		girdNodes.msgResult:setColor(ResLib.COLOR_GREY)
	elseif data.isAgree == 1 then
		girdNodes.agreeBtn:setVisible(false)
		girdNodes.refuseBtn:setVisible(false)
		girdNodes.msgResult:setString("已同意")
		girdNodes.msgResult:setColor(ResLib.COLOR_BLUE)
	elseif data.isAgree == 2 then
		girdNodes.agreeBtn:setVisible(true)
		girdNodes.refuseBtn:setVisible(true)
		girdNodes.msgResult:setString("")
		girdNodes.agreeBtn:setTag(cellIndex+1)
		girdNodes.refuseBtn:setTag(cellIndex+1)
	end

	local url = data.apply_avatar or ""
	local function funcBack( path )
		local rect = girdNodes.stencil:getContentSize()
		girdNodes.Icon:setTexture(path)
		girdNodes.Icon:setTextureRect(rect)
	end
	if url ~= "" then
		ClubModel.downloadPhoto(funcBack, url, true)
	end

end

function CardsNotice:thinkCardsMod( mod )
	-- local card_mod = nil
	-- local card_from = nil

	local gameMod = { GAME_CLUB_STABDARD, GAME_CLUB_SNG, GAME_CLUB_MTT, GAME_CLUB_STABDARD_SECURE, GAME_TYPE_STANDARD, GAME_TYPE_SNG, GAME_TYPE_MTT, GAME_TYPE_STANDARD_SECURE, GAME_CIRCLE_STABDARD, GAME_CIRCLE_SNG, GAME_CIRCLE_MTT, GAME_CIRCLE_STABDARD_SECURE, GAME_UNION_STABDARD, GAME_UNION_SNG, GAME_UNION_MTT, GAME_UNION_STABDARD_SECURE }
	local modDes = { "标准牌局", "SNG局", "MTT牌局", "保险牌局", "标准牌局", "SNG局", "MTT牌局", "保险牌局", "标准牌局", "SNG局", "MTT牌局", "保险牌局", "标准牌局", "SNG局", "MTT牌局", "保险牌局" }
	local modFrom = { "俱乐部", "俱乐部", "俱乐部", "俱乐部", "组局", "组局", "组局", "组局", "圈子", "圈子", "圈子", "圈子", "联盟", "联盟", "联盟", "联盟" }
	for i,v in ipairs(gameMod) do
		if tostring(mod) == v then
			return modDes[i], modFrom[i]
		end
	end
end

function CardsNotice:agree_refuseCard( idx, isAgree )
	
	local offset = curTableView:getContentOffset()

	local tmpData = curData[idx]
	local apply_id = tmpData.apply_id
	local game_id = tmpData.gid
	local game_mod = tmpData.game_mod
	local apply_type = nil
	if tmpData.apply_type then
		apply_type = tmpData.apply_type
	end

	local function response( data )
		if data.code == 0 then
			for k,v in pairs(curData) do
				if tonumber(apply_id) == tonumber(v.apply_id) then
					if isAgree then
						curData[k]["isAgree"] = 1
					else
						curData[k]["isAgree"] = 0
					end
					break
				end
			end
			dump(curData)
			curTableView:reloadData()
			dump(offset)
			if idx > 9 then
				curTableView:setContentOffset(offset)
			end
			MessageCtorl.removeCardData(apply_id, isAgree)
		end
	end
	local tabData = {}
	local httpUrl = nil
	-- sng
	if game_mod == GAME_TYPE_SNG or game_mod == GAME_CLUB_SNG or game_mod == GAME_CIRCLE_SNG or game_mod == GAME_UNION_SNG then
		tabData["gid"] = game_id
		tabData["uid"] = apply_id
		httpUrl = "sngApplyCheck"
		if isAgree then
			tabData["agree"] = 1
		else
			tabData["agree"] = 0
		end
	-- 标准牌局
	elseif game_mod == GAME_TYPE_STANDARD or game_mod == GAME_CLUB_STABDARD or game_mod == GAME_CIRCLE_STABDARD or game_mod == GAME_UNION_STABDARD then
		tabData["gid"] = game_id
		tabData["user_id"] = apply_id
		httpUrl = "generalCheck"
		if isAgree then
			tabData["agree"] = true
		else
			tabData["agree"] = false
		end
	elseif game_mod == GAME_TYPE_MTT or game_mod == GAME_CLUB_MTT or game_mod == GAME_CIRCLE_MTT or game_mod == GAME_UNION_MTT then
		tabData["mtt_id"] = game_id
		tabData["uid"] = apply_id
		tabData["apply_type"] = apply_type
		if isAgree then
			tabData["access"] = 1
		else
			tabData["access"] = 0
		end
		httpUrl = "mttPlayersEntryAccess"
	end
	XMLHttp.requestHttp(httpUrl, tabData, response, PHP_POST)
end

function CardsNotice.updateCardsList(  )
	curData = MessageCtorl.getCardData()
	curTableView:reloadData()
end

function CardsNotice:ctor(  )
	_isUpdateCardsMsg = true
	_callTag = nil

	_cardsNotice = self
	_cardsNotice:setSwallowTouches()
	imageView = nil

	curData = {}
	curTableView = nil


	local drs = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize()
	local function onNodeEvent(event)
		if event == "enter" then
			MessageCtorl.setIsCardsNotice( true )
		elseif event == "exit" then
			MessageCtorl.setIsCardsNotice( false )

			--根据是不是康超适配界面，退出的时候进行设置适配
			StringUtils.recoveryAdapter(drs.width, drs.height)
		end
    end
	self:registerScriptHandler(onNodeEvent)

	self:buildLayer()


	--还原屏蔽适配
	StringUtils.setDZAdapter()
end

--俱乐部、圈子、好友、组局、游戏中
function CardsNotice:setCallTag(callTag)
	_isUpdateCardsMsg = false
	_callTag = callTag
end

return CardsNotice