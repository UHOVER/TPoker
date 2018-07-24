local GReview = {}
local _csize = cc.size(600,160)
local _data = {}
local _poolPokers = {}
local _pageNode = nil
local _leftOriginBtn = nil
local _leftBtn = nil
local _rightOriginBtn = nil
local _rightBtn = nil
local _tablev = nil
local _layer = nil
local _gameId = nil
local _ttfMax = nil
local _isCanCollect = true
local _poollabel = nil
local _insureLabel = nil
local _maxNum = 0
local _nowNum = 0
local _switch_on = false --控制按钮节奏，请求网络数据时按钮不能点击
local _rect = cc.rect(0,0,0,0)
local _clolo1 = cc.c3b(255,255,255)
local _clolo2 = cc.c3b(122,170,193)
local pageNum, pageTotalNum = 0, 0
local leftOriginImgs = {"game/left_origin_normal.png", "game/left_origin_press.png", "game/left_origin_disable.png"}
local leftNextImgs = {"game/left_next_normal.png","game/left_next_press.png","game/left_next_disable.png"}
local rightNextImgs = {"game/right_next_normal.png","game/right_next_press.png","game/right_next_disable.png"}
local rightOriginImgs = {"game/right_origin_normal.png", "game/right_origin_press.png", "game/right_origin_disable.png"}
local LEFT_TAG, LEFT_ORIGIN_TAG = 100, 150
local RIGHT_TAG, RIGHT_ORIGIN_TAG = 200, 250
local function handleCollect()
	if not _gameId then return end
	if not _isCanCollect then return end

	_isCanCollect = false
	DZAction.delateTime(_layer, 5, function()
		_isCanCollect = true
		end)

	local function response(data)
		if data['isNew'] then
			_nowNum = tonumber(_nowNum) + 1
			_ttfMax:setString(_nowNum..'/'.._maxNum)
		end

		local tnode = cc.Node:create()
		_layer:addChild(tnode)

		local pos = cc.p(475,440)
		local rightbg = UIUtil.addPosSprite('game/game_review_rightbg.png', pos, tnode)
		local rightok = UIUtil.addPosSprite('game/game_review_right.png', pos, tnode)
		local collect = UIUtil.addLabelArial('已收藏', 28, cc.p(pos.x,pos.y-80), cc.p(0.5,0.5), tnode, cc.c3b(255,255,255))
		rightok:setOpacity(0)
		rightbg:setOpacity(0)
		collect:setOpacity(0)

		DZAction.fadeInOut(rightok, 0.8, DZAction.FADE_IN, nil)
		DZAction.fadeInOut(rightbg, 0.8, DZAction.FADE_IN, nil)
		DZAction.fadeInOut(collect, 0.8, DZAction.FADE_IN, nil)

		DZAction.delateTime(rightbg, 3, function()
			DZAction.fadeInOut(rightok, 0.8, DZAction.FADE_OUT, nil)
			DZAction.fadeInOut(collect, 0.8, DZAction.FADE_OUT, nil)
			DZAction.fadeInOut(rightbg, 0.8, DZAction.FADE_OUT, function()
				tnode:removeFromParent()
			end)
		end)
	end

	SocketCtrol.collectionPoker(_gameId, response)
end
local function handleData(players)
	_data = {}
	if not players then return end

	local pid = Single:playerModel():getId()
	local PokerType = require 'game.PokerType'

	local function getCardType(cards, pools, isFolded)
		if isFolded then return '弃牌' end
		-- dump(cards, "手牌：")
		-- dump(pools, "底池的牌：")
		local array = StringUtils.linkArrayNew(cards, pools)	
		local newArr = {}
		for i=1,#array do
			if array[i] ~= StatusCode.POKER_BACK then
				table.insert(newArr, array[ i ])
			end
		end
		-- if #newArr < 2 then return '未知' end
		if #newArr < 2 then return '' end
		-- local text,pokers = PokerType.get_poker_type(newArr)
		local text,pokers = PokerType.get_poker_type_full(newArr)
		return text, pokers
	end

	for i=1,#players do
		local user = players[ i ]

		local isme = false
		local cards = user['cards']
		local poolCards = _poolPokers
		local typetext, maxCards = getCardType(cards, poolCards, user['isFolded'])
		--我
		if pid == user['id'] then
			isme = true
		end

		local tab = {}
		tab['isMe'] = isme
		tab['cards'] = cards
		tab['poolCards'] = poolCards
		tab['cardType'] = typetext
		tab['maxCards'] = maxCards
		tab['name'] = user['userName']
		tab['changeBet'] = user['score']
		tab['headUrl'] = user['headUrl']
		tab['isFolded'] = user['isFolded']

		--不是保险
		if Single:gameModel():isInsuranceGame() then
			tab['insure'] = user['insure']
			tab['payment'] = user['payment']
		end

		table.insert(_data, tab)
	end
end

local function updateBtnStatus(isleft, islleft, isright, isrright)
	  _leftBtn:setEnabled(isleft)
	   _leftOriginBtn:setEnabled(islleft)
	   _rightBtn:setEnabled(isright)
	   _rightOriginBtn:setEnabled(isrright)
end
local function updatePageUIStatu()
	local isMin = (pageNum <= 0)
	local isMax = (pageNum >=pageTotalNum)
	local isBetween = (not isMin and not isMax)
	local isNothing = ((pageTotalNum + 1) == 0)
	local tmpPage = (pageTotalNum - pageNum + 1).."/"..(pageTotalNum+1)
	if isNothing then 
	   tmpPage = tostring(0)..'/'..tostring(0)
	   updateBtnStatus(false, false, false,false) 
	elseif isBetween then 
	   updateBtnStatus(true, true, true, true)
	elseif isMax then --开启向前翻页，go to new
	   updateBtnStatus(false, false, true, true)
	elseif isMin then --开启向后翻页  go to old
	   updateBtnStatus(true, true, false, false)
	end
	_pageNode:setString(tmpPage)
end

local function addCellLayer(idx, parent)
	local cdata = _data[idx]
	if not cdata then  return end
	local cy = _csize.height / 2 - 8
	local ty = _csize.height - 10
	local topy = _csize.height - 8
	local virualy = 88
	--自己
	local color = cc.c3b(255,255,255)
	if cdata['isMe'] then
		color = cc.c3b(142,199,223)
	end

	--top
	local tbetpos = cc.p(_csize.width - 49, 23)
    local tname = UIUtil.addLabelBold(cdata['name'], 20, cc.p(99,23), cc.p(0.5, 0.5), parent, color)
    local tbet = UIUtil.addLabelBold(cdata['changeBet'], 30, tbetpos, cc.p(0.5, 0.5), parent, _clolo1)
	UIUtil.addPosSprite("game/game_userhead_bg.png",cc.p(99,93),parent)
	local stencil,sp = UIUtil.addUserHead(cc.p(99, 93), cdata['headUrl'], parent,true)
	stencil:setScale(0.9)
	sp:setScale(0.9)
	-- print("stencil:getContentSize", sp:getContentSize().width,sp:getContentSize().height)
	if cdata['changeBet'] < 0 then
		tbet:setColor(cc.c3b(28,133,61))
	end

	local poolCards = _poolPokers
	local cards = cdata['cards']
	local maxCards = cdata['maxCards']
	--弃牌
	-- if cdata['isFolded'] and not cdata['isMe'] then
	-- 	poolCards = {}
	-- 	cards = {}
	-- end

	local tx = _csize.width - 18 - 48*5
	local displaySelectStatus = function(cardIndex,pt)
									if maxCards and table.indexof(maxCards, cardIndex) then
										-- UIUtil.addPosSprite("game/game_poker_selected.png", pt, parent, cc.p(0, 0.5))
									else 
										UIUtil.addPosSprite("game/game_poker_mark.png", pt, parent, cc.p(0, 0.5))
									end
								end
	for i=1,#poolCards do
		local imgp = UIUtil.addPosSprite(DZConfig.cardName(poolCards[i]), cc.p(tx,virualy), parent, cc.p(0,0.5))
		imgp:setScale(0.4)
		displaySelectStatus(poolCards[i],cc.p(tx,virualy))
		tx = tx + 48
	end

	local txx = 206
	for i=1,#cards do
		local imgp = UIUtil.addPosSprite(DZConfig.cardName(cards[i]), cc.p(txx,virualy), parent, cc.p(0,0.5))
		imgp:setScale(0.4)
		displaySelectStatus(cards[i],cc.p(txx, virualy))
		txx = txx + 48
	end

	--down
	local downy = 23
    local tcard = UIUtil.addLabelBold(cdata['cardType'], 28, cc.p(254,downy), cc.p(0.5,0.5), parent, color)
    if cdata['insure'] then
	    UIUtil.addLabelBold('投保:'..cdata['insure'], 20, cc.p(296,topy), cc.p(0,1), parent, color)
	end
	if cdata['payment'] then
	    UIUtil.addLabelBold('赔付:'..cdata['payment'], 20, cc.p(450,topy), cc.p(0,1), parent, color)
	end

    --弃牌
 --    local ttfy = _csize.height / 2 + 8
 --    if #cards == 0 then
 --    	tcard:setPositionY(ttfy)
	-- end
	-- if #poolCards == 0 then
 --    	tbet:setPositionY(ttfy)
	-- end

	--line
    local line = UIUtil.scale9Sprite(_rect, 'game/game_fight3.png', cc.size(600,2), cc.p(_csize.width,0), parent)
    line:setAnchorPoint(1,0)

 	if cdata['isMe'] then 
 		UIUtil.addPosSprite('game/game_isme_tag.png', cc.p(22, virualy), parent)
 	end
end

local function requestRoundData(tmpPageNum)
	if tmpPageNum == pageNum and (pageNum < 0 or pageNum > pageTotalNum) then 
		print("奇怪的数据：tmpPageNum:"..tmpPageNum.." pageNum:"..pageNum.." pageTotalNum:"..pageTotalNum)
		return 
	end

	if _switch_on then 
		print("数据正在加载中")
		return 
	end

	local function response(data)
		_gameId = data['gameId']
		_poolPokers = data['poolCards']
		_nowNum = data['favNumber']
		pageNum = data['curPage']
		pageTotalNum = data['totalPage'] - 1
		handleData(data['players'])

    	local isInsure = Single:gameModel():isInsuranceGame()
    	if (_poollabel and data['allPool'] and isInsure) then 
    		_poollabel:setString('底池：'..data['allPool'])
    	end
    	if (_insureLabel and data['insurancePool'] and isInsure) then
    		_insureLabel:setString(data['insurancePool'])
    	end
    	--返回行数
		local function numberOfCellsInTableView(table)
			return #_data
		end
		_tablev:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
		_tablev:reloadData()
		updatePageUIStatu()
		_switch_on = false
	end
	_switch_on = true
	SocketCtrol.lookHistoryDataByPage(tmpPageNum, response)
end
-- 事件监听
local function pageChangeHandler(sender, evtType)
	if _switch_on then 
		print("正在加载数据中.....")
		return
	end

	if evtType == ccui.TouchEventType.ended then  
		-- sender:setTouchEnabled(true)
		local tag = sender:getTag()
		local tmpPageNum = pageNum
		if (tag == LEFT_TAG) then 
			tmpPageNum = math.min(pageNum + 1, pageTotalNum)
		elseif (tag == LEFT_ORIGIN_TAG) then 
			tmpPageNum = pageTotalNum
		elseif (tag == RIGHT_TAG) then 
			tmpPageNum = math.max(pageNum - 1, 0)
		elseif (tag == RIGHT_ORIGIN_TAG) then 
			tmpPageNum = 0
		end
		print("ya  ho :"..sender:getTag() .. "curPage:"..tmpPageNum)
		updatePageUIStatu()
		requestRoundData(tmpPageNum)
		pageNum = tmpPageNum
	elseif evtType == ccui.TouchEventType.began then 
		-- sender:setTouchEnabled(false)
	end
end

local function createLayer(data)
    local runScene = cc.Director:getInstance():getRunningScene()
    if runScene:getChildByName('SHOW_REVIEW') then
    	return
    end

    local glayer = cc.LayerColor:create(cc.c4b(0,0,0,0))
    glayer:setName('SHOW_REVIEW')
    runScene:addChild(glayer, StringUtils.getMaxZOrder(runScene))
    UIUtil.shieldLayer(glayer, nil)

    _layer = glayer

    glayer:setPositionX(display.width)
	DZAction.easeInMove(glayer, cc.p(0,0), 0.3, DZAction.MOVE_TO, function()
		glayer:initWithColor(cc.c4b(0,0,0,100))
	end)

    local function removeLayer()
		glayer:initWithColor(cc.c4b(0,0,0,0))
    	DZAction.easeInMove(glayer, cc.p(display.width,0), 0.4, DZAction.MOVE_TO, function()
	    	glayer:removeFromParent()
		end)
    end

    --bg
  	local bgsize = cc.size(608,display.height)
    local rebg = UIUtil.scale9Sprite(_rect, 'game/game_fight0.png', bgsize, cc.p(display.width+8,0), glayer)
    rebg:setAnchorPoint(1,0)
    rebg.noEndedBack = removeLayer
  	TouchBack.registerImg(rebg)

  	local bgw = 600
  	local titleSize = cc.size(bgw,64)
  	local titlecy = titleSize.height / 2

    --top1
    local topy = display.top-55
    local size1 = cc.size(bgw,92)
    local topbgpos = cc.p(display.width,display.height-40)
    local topbg = UIUtil.scale9Sprite(_rect, 'game/game_fight1.png', size1, topbgpos, glayer)
    topbg:setAnchorPoint(1,1)
    UIUtil.addLabelBold('上局回顾', 36, cc.p(410,size1.height/2), cc.p(0,0.5), topbg, _clolo1)
    local img = 'game/game_return.png'
    local titem = UIUtil.addMenuBtn(img, img, removeLayer, cc.p(40,size1.height/2), topbg)
    titem:setScale(-1.2)

    --top2
    local topy2 = display.top-132
    local bg2pos = cc.p(display.width+8,topy2)
    local isPool, isInsurepool = false, false
    local bg2 = UIUtil.scale9Sprite(_rect, 'game/game_fight0.png', cc.size(608,70), bg2pos, glayer)
    bg2:setAnchorPoint(1,1)

    local isInsure = Single:gameModel():isInsuranceGame()
    if data['allPool'] and isInsure then
    	isPool = true
    	_poollabel = UIUtil.addLabelArial('底池：'..data['allPool'], 28, cc.p(132, titlecy), cc.p(0, 0.5), bg2, cc.c3b(255,255,255))
    end
    if data['insurancePool'] and isInsure then
    	isInsurepool = true
		UIUtil.addPosSprite('game/insure_pool_tag.png',cc.p(bgw-170, titlecy),bg2, cc.p(0.5,0.5))
		_insureLabel = UIUtil.addLabelArial(data['insurancePool'], 28, cc.p(bgw-84,titlecy), cc.p(0,0.5), bg2, cc.c3b(255,255,255))
	end
	local line = UIUtil.scale9Sprite(_rect, 'game/game_fight3.png', cc.size(600,2), cc.p(display.width,display.top-200), glayer)
    line:setAnchorPoint(1,0)
    
	--is show top2 and offsety
	local offsety = 0
	if not isPool and not isInsurepool then 
		bg2:setVisible(false)
		line:setVisible(false)
		offsety = 70
	end

    --牌铺先去掉
    local ty = 110
    _ttfMax = UIUtil.addLabelArial(_nowNum..'/'.._maxNum, 30, cc.p(300,ty), cc.p(0,0.5), glayer, cc.c3b(255,255,255))
    -- UIUtil.addLabelArial('牌铺', 30, cc.p(220,ty), cc.p(0,0.5), glayer, cc.c3b(255,255,255))
    local tab = {}
	tab['font'] = 'Arial'
	tab['size'] = 34
    local mfont = UIUtil.addMenuFont(tab, '收藏', cc.p(display.width-85,ty), handleCollect, glayer)
    mfont:setColor(cc.c3b(243,145,5))
    mfont:setVisible(false)
    mfont:setVisible(false)
    _ttfMax:setVisible(false)

    local tsize = cc.size(_csize.width,978-G_SURPLUS_H + 155-136 + offsety)
    local tablev = UIUtil.addTableView(tsize, cc.p(150,136), cc.SCROLLVIEW_DIRECTION_VERTICAL, glayer)
    tablev:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    DZUi.addTableView(tablev, _csize, #_data, addCellLayer)
    _tablev = tablev
    --翻页标记
   	local colorbg = cc.LayerColor:create(cc.c3b(33, 52, 79))
   	colorbg:ignoreAnchorPointForPosition(false)
   	colorbg:setAnchorPoint(cc.p(1, 0))
   	colorbg:setContentSize(cc.size(_csize.width, 136))
   	colorbg:setPosition(cc.p(display.width,0))
   	_layer:addChild(colorbg)

   	local basex = 152
   	UIUtil.addLabelArial("全局回顾", 26, cc.p(basex + 21, 109), cc.p(0, .5), _layer,cc.c3b(255,255,255))
   	_pageNode = UIUtil.addLabelArial(pageNum.."/"..pageTotalNum, 26, cc.p(basex + _csize.width/2, 44), cc.p(.5, .5), _layer,cc.c3b(255,255,255))
   	_leftOriginBtn = UIUtil.addUIButton(leftOriginImgs,cc.p(basex + 44, 44),_layer,pageChangeHandler)
   	_leftBtn = UIUtil.addUIButton(leftNextImgs,cc.p(basex + 142, 44),_layer,pageChangeHandler)
   	_rightOriginBtn = UIUtil.addUIButton(rightOriginImgs,cc.p(display.width - 20, 44),_layer,pageChangeHandler)
   	_rightBtn = UIUtil.addUIButton(rightNextImgs,cc.p(display.width - 98, 44),_layer,pageChangeHandler)
   	_leftOriginBtn:setAnchorPoint(cc.p(.5,.5))
   	_leftBtn:setAnchorPoint(cc.p(.5,.5))
   	_rightOriginBtn:setAnchorPoint(1,.5)
   	_rightBtn:setAnchorPoint(1,.5)
   	_leftOriginBtn:setTag(LEFT_ORIGIN_TAG)
   	_leftBtn:setTag(LEFT_TAG)
   	_rightOriginBtn:setTag(RIGHT_ORIGIN_TAG)
   	_rightBtn:setTag(RIGHT_TAG)
   	updatePageUIStatu()	
end

local _isEnter = true
function GReview.showReview()
	if not _isEnter then return end
	_isEnter = false
	DZSchedule.schedulerOnce(2, function()
		_isEnter = true
		end)

	_isCanCollect = true
	_maxNum = Single:playerModel():getMaxCollection()

	local function response(data)
		-- --test
		-- 	local function createPlayer(userdata, card1, card2)
		-- 		 local index = math.random(0,100)
		-- 		 userdata["id"] = 490+index
  --    			 userdata["userName"] = "幺幺"..tostring(math.random(0,100))
  --     			 userdata["headUrl"] = nil
  --    		 	 userdata["isFolded"] = false
  --     			 userdata["score"] =10
  --     			 userdata["insure"] = 110
  --     			 userdata["payment"] = 130
  --    			 userdata["cards"] =  {card1, card2}
  --    			 userdata['changeBet'] = 10
		-- 	end

		-- 	local _poolCards = {23,43,50,44,19}
		-- 	data = {result = 1,protocolNum = 1017, favNumber = 1, gameId = "24", poolCards = _poolCards}
 	-- 		local player1, player2, player3,player4,player5,player6,player7,player9,player8 = {}, {},{},{},{},{},{},{},{}
 	-- 		createPlayer(player1, 11, 12)
 	-- 		createPlayer(player2, 1,9)
 	-- 		createPlayer(player3, 46,51)
 	-- 		createPlayer(player4, 49,48)
 	-- 		createPlayer(player5, 5,6)
 	-- 		createPlayer(player6, 14,17)
 	-- 		createPlayer(player7, 24,28)
 	-- 		createPlayer(player8, 31,33)
 	-- 		createPlayer(player9, 36,37)
 	-- 		player4['cards'] = {}
 	-- 		player3['id'] = Single:playerModel():getId()
 	-- 		data.players = {player1, player2, player3,player4, player5,player6,player7,player8,player9}
 	-- 		data['curPageNum'] = 0
 	-- 		data['totalPageNum'] = 4
 			
		-- --test end
		-- dump(data, "回顾")
		_gameId = data['gameId']
		_poolPokers = data['poolCards']
		_nowNum = data['favNumber']
		if data['curPage'] then 
			pageNum = data['curPage']
		else 
			pageNum = 0
		end

		if data['totalPage'] then 
			pageTotalNum = data['totalPage'] - 1
		else
			pageTotalNum = 0
		end
		handleData(data['players'])	

		createLayer(data)
		_isEnter = true
	end
	
	SocketCtrol.lookHistoryDataByPage(0,response)
end




return GReview