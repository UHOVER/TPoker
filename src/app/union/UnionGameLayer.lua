--
-- Author: Taylor
-- Date: 2017-08-01 14:35:12
-- 联盟牌局
local ViewBase = require("ui.ViewBase")
local UnionGameLayer = class("UnionGameLayer", ViewBase)
local UnionCtrol = require("union.UnionCtrol")
local CardCtrol = require("cards.CardCtrol")
local _size = cc.size(display.width, display.height-130-90)
local s_csize = cc.size(359, 209)
local _gameNumTf = nil
local _table = nil
local _data = nil
local curLayer = nil

function UnionGameLayer:ctor()
	curLayer = self
	self:setContentSize(_size)
	self:enableNodeEvents()
	self:initGameData()
	self:initUI()
end

function UnionGameLayer:onEnter()
end

function UnionGameLayer:onExit()
end

local function resetData()
	local isCreate = UnionCtrol.isHasAuth(UnionCtrol.Auth_CREATE)
	local isUnion = UnionCtrol.getVisitFrom()
	if isCreate and isUnion then 
		_data = {[1] = {flag = "new"}}
	else 
		_data = {}
	end
end
function UnionGameLayer:initGameData()
	resetData()
end


local function intoGame(gameData)
	dump(gameData)
	local game_mod = tostring(gameData.table_type)
	local choose_clubNum = #gameData.choose_clubs
	-- 联盟标准局
	if game_mod == GAME_UNION_STABDARD then 
		if choose_clubNum >= 2 then
			CardCtrol.addSNGApply( gameData )
		else
			local clubId = nil
			if gameData.choose_clubs[1] then
				clubId = gameData.choose_clubs[1]["club_id"]
			end
			CardCtrol.enterNOR( gameData['gid'], clubId )
		end
	-- 联盟sng
	elseif game_mod == GAME_UNION_SNG then 
		if choose_clubNum >= 2 then
			CardCtrol.addSNGApply( gameData )
		elseif choose_clubNum == 1 then
			CardCtrol.popData( gameData, gameData.choose_clubs[1]["club_id"] )
		else
			ViewCtrol.showTip({content = "您没有可以绑定的俱乐部, 不能参加牌局！"})
		end
	-- 联盟MTT
	elseif game_mod == GAME_UNION_MTT then 
		if choose_clubNum >= 2 then
			CardCtrol.addSNGApply( gameData )
		else
			local tab = {}
			if gameData.choose_clubs and gameData.choose_clubs[1] then
				tab = {pokerId = gameData.gid, groupID = gameData.choose_clubs[1]["club_id"]}
			else
				tab = {pokerId = gameData.gid}
			end
			local MttShowCtorl = require("common.MttShowCtorl")
			MttShowCtorl.dataStatStatus( function (  )
				MttShowCtorl.MttSignUp(tab)
			end, tab )
		end
	end
end

local function clickBeganHandler(sender, evt)
	local bg = evt:getCurrentTarget().bg
	bg:setHighlighted(true)
end

local function clickCancelHandler(touch, evt)
	local bg = evt:getCurrentTarget().bg
	bg:setHighlighted(false)
end

local function clickanyHandler(touch, evt)
	local bg = evt:getCurrentTarget().bg
	bg:setHighlighted(false)
end

local function clickRacesHandler(touch, evt)
		local bg = evt:getCurrentTarget().bg
		bg:setHighlighted(false)
		local isMoved = _table:isTouchMoved()
		if not isMoved then 
			
			local tag = evt:getCurrentTarget():getTag() -1
			print("点击:"..tostring(tag))
			local data = _data[tag + 1]
			dump(data)
			if  tag == 0 and data.flag == "new" then 
				--创建牌局
				local scene = cc.Director:getInstance():getRunningScene()
				local union_id = UnionCtrol.getUnionDetail()["union_id"]
				local setCard = require("common.SetCards")
				local layer = setCard:create()
				scene:addChild(layer,StringUtils.getMaxZOrder(scene))
				layer:createLayer( union_id, "union")
				layer:onNodeEvent("exitTransitionStart", function()
						--刷新牌局列表
						curLayer:showContent()
					end)
			else 
				--进入牌局游戏
				intoGame(data)
			end
		end
end

local function createRacesCell(cell,table)
	local layer =display.newLayer(cc.c4b(0,0,0,0),s_csize.width,s_csize.height):addTo(cell)
	local imgBoderbg = UIUtil.addImageBtn({touch = false, scale9 = true, size = s_csize, norImg = "club/game_create_s9.png", selImg = "club/game_create_p_s9.png", disImg = "club/game_create_s9.png", pos=cc.p(0,0), parent = layer}):align(cc.p(0,0),0,0)
	local cross_sp =  UIUtil.addImageView({image = "club/game_btn_create.png", pos = cc.p(s_csize.width/2, s_csize.height-42), ah = cc.p(.5,1),parent = imgBoderbg})
	UIUtil.addLabelArial("创建牌局", 28, cc.p(s_csize.width/2, 50), cc.p(.5,.5), imgBoderbg, ResLib.COLOR_WHITE)
	imgBoderbg:setTag(0)
	layer.bg = imgBoderbg
	return layer
end

local function detailRacesCell(data, cell, table)
	local layer = display.newLayer(cc.c4b(0,0,0,0), s_csize.width,s_csize.height):addTo(cell)
	local rcellpanel =  cc.CSLoader:createNodeWithVisibleSize("scene/PokerRacesCell.csb")
	rcellpanel:setAnchorPoint(cc.p(0,0))
	layer:addChild(rcellpanel)
	layer.bg = rcellpanel:getChildByName("bordersp")

	local getStateStr = function(state,mod)
		if state == 0 then 
			if mod == UnionCtrol.game.stand then 
				return "准备中"
			else 
				return "报名中"
			 end
		end
		if state == 1 then return "进行中" end
	end
	local timeToDate = function(time, mod)
		if mod == UnionCtrol.game.stand then 
			return '还剩'..CardCtrol.transTime(time)
		else 
			return math.ceil(time).."分"
		end
	end
	if data.insure and data.insure > 0 then 
		rcellpanel:getChildByName("insure"):setVisible(true)
	else
		rcellpanel:getChildByName("insure"):setVisible(false)
	end
	
	local tf_gametype = rcellpanel:getChildByName("tfgametype")
	local tf_gamestate = rcellpanel:getChildByName("tfgamestate")
	local tf_gamefrom = rcellpanel:getChildByName("tfgamefrom")
	
	
	local sp_bg = rcellpanel:getChildByName("sp_bg")
	local sp_alter0 = rcellpanel:getChildByName("Sprite_2")
	local tf_alter0 = rcellpanel:getChildByName("tf_peopleNum")
	local sp_alter1 = rcellpanel:getChildByName("sp_alter1")
	local tf_alter1 = rcellpanel:getChildByName("tf_alter1")
	local sp_alter2 = rcellpanel:getChildByName("sp_alter2")
	local tf_alter2 = rcellpanel:getChildByName("tf_alter2")
	local sp_alter3 = rcellpanel:getChildByName('Sprite_3')
	local tf_time = rcellpanel:getChildByName("tf_time")

	local game_mod= tonumber(data.table_type)
	 tf_gamefrom:setString(data.table_name)
	 tf_gamestate:setString(getStateStr(data.status, game_mod))
	 tf_gametype:setString(UnionCtrol.game[data.table_type])
	if game_mod == UnionCtrol.game.stand then 
		local text = math.ceil(data.big_blind/2).."/"..data.big_blind
		if tonumber(data.ante) > 0 then 
			text = text.."("..data.ante..")"
		end
		sp_alter0:setTexture("club/card_list_icon_user1.png")
		tf_alter0:setString(data.current_players.."/"..data.limit_players)
		sp_alter1:setTexture("club/card_list_icon_spades.png")
		tf_alter1:setString(text)
		sp_alter2:removeFromParent()
		tf_alter2:removeFromParent()
		sp_bg:setTexture("club/game_mark_stand.png")
		tf_time:setString(timeToDate(data.left_time, game_mod))
	elseif game_mod == UnionCtrol.game.sng then 
		sp_alter0:setTexture("club/card_list_icon_user1.png")
		tf_alter0:setString(data.current_players.."/"..data.limit_players)
		sp_alter1:setTexture("club/card_list_icon_fee.png")
		tf_alter1:setString( data.entry_fee.."+"..tonumber(data.entry_fee)*0.1 )
		sp_alter2:setTexture( "club/card_list_icon_reward.png")
		tf_alter2:setString(data.prize)
		sp_bg:setTexture("club/game_mark_sng.png")
		tf_time:setString(timeToDate(tonumber(data.increase_time)/60 or 0))
	elseif game_mod == UnionCtrol.game.mtt then 
		sp_alter0:setTexture("club/card_list_icon_initalScore.png")
		tf_alter0:setString(data.inital_score)
		sp_alter1:setTexture("club/card_list_icon_fee.png")
		tf_alter1:setString(data.entry_fee.."+"..tonumber(data.entry_fee)*0.1)
		sp_alter2:removeFromParent()
		tf_alter2:removeFromParent()
		sp_bg:setTexture("club/game_mark_mtt.png")
		sp_alter3:setTexture("club/card_list_icon_increaseTime.png")
		tf_time:setString(timeToDate(tonumber(data.increase_time)/60 or 0))
	end
	return layer
end



local function generateCell(idx, cell, table)
	-- print("idx:"..idx-1)
	idx = idx - 1
	for i = 1, 2 do 
		local data = _data[idx*2+i]
		if not data then return end
		local cellpanel = nil
		local cx, cy = 10*i + s_csize.width*(i - 1), 0
		if data.flag == "new" then 
		 	cellpanel =	createRacesCell(cell, table)
		else 
			cellpanel = detailRacesCell(data, cell, table)
		end
		cellpanel:setPosition(cx, cy)
		cellpanel:setTag(idx*2+i)

		cellpanel.beginBack = clickBeganHandler
		cellpanel.notMoveBack = clickRacesHandler
		cellpanel.touchCancel = clickCancelHandler
		cellpanel.anyEndBack = clickanyHandler

		TouchBack.registerImg(cellpanel)
	end
end


function UnionGameLayer:initUI()


	local numberOfCellsInTableView = function(table)
		return math.ceil(#_data/2)
	end
	local basey = _size.height - 44
	local cellSize = cc.size(display.width, 219)

	local sectionPanel = UIUtil.addSection({text = "牌局列表", size = cc.size(display.width, 42), tcolor = ResLib.COLOR_GREY1, pos = cc.p(0, basey), parent = self})

	_gameNumTf = UIUtil.addLabelArial(#_data - 1,26,cc.p(display.width - 20, 22),cc.p(1, .5), sectionPanel, ResLib.COLOR_GREY1)

	_table = UIUtil.addTableView(cc.size(display.width, basey), cc.p(0,0), cc.SCROLLVIEW_DIRECTION_VERTICAL, self)
	DZUi.addTableView(_table, cellSize, math.ceil(#_data/2), generateCell)
	_table:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
	_table:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
	_table:reloadData()

end
	
function UnionGameLayer:hideContent()
end

function UnionGameLayer:showContent()
	local function refreshUI(data)
		resetData()
		table.insertto(_data, data)
		_table:reloadData()
		_gameNumTf:setString(math.max(#_data - 1, 0))
	end
	UnionCtrol.requestUnionRaces(refreshUI)
end

return UnionGameLayer
