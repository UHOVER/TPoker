local GPlayerMsg = {}
local _cs = nil
local _data = {}
local _userId = nil
local _seatNum = 0
local _isEnter = false
local _csize = cc.size(0,0)
local _aniArr = {}
local _disAniImgs = {}
local _isSendAni = false
local function handleClose()
    DZAction.hideWindow(_cs, function()
		_cs:removeFromParent()
	end, nil, 0.1)
end

local function handleAddFriend()
	local function response( data )
		if tonumber(data.code) == 0 then
			ViewCtrol.showTick({content = "好友申请已发送!"})
			handleClose()
		end
	end
	local tname = Single:playerModel():getPName()
	local tab = {}
	tab["to_id"] = _data['playerId']
	tab["contents"] = '玩家'..tname..'游戏中加您好友'
	XMLHttp.requestHttp(PHP_FRIEND_TEST, tab, response, PHP_POST)
end

local function handleLastVoice()
	DZChat.playLastVoice(tostring(_data['playerId']), _data['rongyunId'])
end

local function calculateScale(targetImgPath, targetSize)
	local sp = cc.Sprite:create(targetImgPath)
	local srcSize = sp:getContentSize()
	local sw,sh = srcSize.width, srcSize.height
	local tw, th = targetSize.width, targetSize.height
	local ws, hs = tw/sw, th/sh
	return math.max(ws, hs)
end

local function addTableLayer(idx, layer)
	UIUtil.addPosSprite('game/game_anibet.png', cc.p(60,30), layer, cc.p(0,0.5))	
	UIUtil.addLabelArial('20', 26, cc.p(58,30), cc.p(1,0.5), layer, cc.c3b(203,203,203))

	local aniName = _disAniImgs[ idx ]
	local pos = cc.p(_csize.width/2-3,_csize.height/2+16)
	local ani = UIUtil.addPosSprite(aniName, pos, layer, cc.p(0.5,0.5))	
	ani:setScale(0.92)
end

local function tableCellTouched(table, cell)
	if not GSelfData.isHavedSeat() then return end
	if _isSendAni then return end
	_isSendAni = true

	local idx = cell:getIdx() + 1
    handleClose()
    -- _cs:removeFromParent()

    SocketCtrol.sendAnimation(_seatNum, _aniArr[ idx ], function()end)
end

local function createLayer(tuser)
	--head
	local uname = tuser:getUserName()
	_cs:getChildByName('ttfName'):setString(uname)
	local nw = _cs:getChildByName('ttfName'):getContentSize().width
	local npx = _cs:getChildByName('ttfName'):getPositionX()
	_cs:getChildByName('imgBoyTag'):setPositionX(nw/2 + npx + 8)

	local hurl = tuser:getHeadUrl()
	local heady = _cs:getChildByName('ttfName'):getPositionY()
	local stencil, sprite = UIUtil.addUserHead(cc.p(272, 1016), hurl, _cs, true)
	sprite:setScale(1)
	stencil:setScale(1)
	local sexImg = DZConfig.getSexImg(_data['sex'])
	-- _cs:getChildByName('imgBoyTag'):setTexture('user/user_icon_sex_female.png')
	_cs:getChildByName('imgBoyTag'):setTexture(sexImg)

	--队伍
	local teamData = _data['team']
	if teamData then 
		local teamName = _cs:getChildByName('teamName')
		local teamIcon = _cs:getChildByName('teamIcon')
		teamName:setString(teamData['teamName'].."战队")
		local width,posx = teamName:getContentSize().width, teamName:getPositionX()
		_cs:getChildByName('teamMark'):setPositionX(width + posx + 8)
		_cs:getChildByName('teamDes'):setString("来自"..teamData['teamFrom'].."俱乐部")
		local function success(path)
			
		  	local teamPos = cc.p(teamIcon:getPositionX(), teamIcon:getPositionY())
		  	local scale = calculateScale(path, cc.size(74, 74))
		  	local stencil, sprite = UIUtil.createCircle(path, teamPos, _cs, ResLib.CLUB_HEAD_STENCIL_200, scale)
		end

		CppPlat.downResFile(teamData['teamIconUrl'], success, success, ResLib.USER_HEAD, "playerMsgIdentifier")
	else 
		_cs:getChildByName('teamName'):setVisible(false)
		_cs:getChildByName('teamDes'):setVisible(false)
		_cs:getChildByName('teamMark'):setVisible(false)
		_cs:getChildByName('teamIcon'):setVisible(false)
	end

	--标准 
	local standard = _data['statistics']['normal']
	local intoRate = standard['intoRate'] * 100
	local winRate = standard['winRate'] * 100
	_cs:getChildByName('ttfPokerNum'):setString(standard['pokerNum'])
	_cs:getChildByName('ttfAllNum'):setString(standard['allNum'])
	_cs:getChildByName('ttfIntoVal'):setString(intoRate..'%')
	_cs:getChildByName('ttfWinVal'):setString(winRate..'%')

	--sng
	local sng = _data['statistics']['match']
	_cs:getChildByName('ttfGameNum'):setString(sng['pokerNum'])
	_cs:getChildByName('ttfRewardNum'):setString(sng['rewardAll'])
	_cs:getChildByName('ttfFirst'):setString(sng['firstNum'])
	_cs:getChildByName('ttfSecond'):setString(sng['secondNum'])
	_cs:getChildByName('ttfThird'):setString(sng['thirdNum'])

	local mtt = _data['statistics']['mtt']
	if mtt then 
		local getBackRate = string.format("%.1f%s",mtt['getBackRate']*100,'%')
		_cs:getChildByName("inGameNum"):setString(mtt['pokerNum'])--参赛数
		_cs:getChildByName("totalAward"):setString(mtt['rewardAll'])--总奖金
		_cs:getChildByName("tableNo"):setString(mtt['offNum'])--决赛卓场次
		_cs:getChildByName("returnOfInvest"):setString(getBackRate)--回报率
	end

	--表情
    _aniArr = DZConfig.getAniArray()

    if GSelfData.isHavedSeat() then
	    _disAniImgs = DZConfig.getAniOneImgArray()
    else
    	_disAniImgs = DZConfig.getAniGreyImgArray()
    end

	local tsize = cc.size(506, 185)
	_csize = cc.size(98,tsize.height)
	local tablev = UIUtil.addTableView(tsize, cc.p(18,12), cc.SCROLLVIEW_DIRECTION_HORIZONTAL, _cs)
    tablev:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    DZUi.addTableView(tablev, _csize, #_aniArr, addTableLayer, nil)
    tablev:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
end


local function handleData()
end

function GPlayerMsg.showMsg(tuser)
    local playerId = tuser:getUserId()
    local meId = Single:playerModel():getId()
    if playerId == meId then return end

    _isSendAni = false

	if _isEnter then return end
	_isEnter = true
	DZSchedule.schedulerOnce(2, function()
		_isEnter = false
	end)


	local function netBack(data)
		local runScene = cc.Director:getInstance():getRunningScene()
		local sceneChild = runScene:getChildByName('PLAYER_MSG')
		if sceneChild then
			return
		end
		-- local team = {}
		-- data['team'] = team
		-- team['teamName'] = "xxxxxx"
		-- team['teamFrom'] = "天空"
		-- team['teamIconUrl'] = "icon/emoji_9.png"

		_data = data
		_isEnter = false

		local cs = cc.CSLoader:createNode(ResLib.GPLAYER_MSG_CSB)
		cs:setName('PLAYER_MSG')
	    runScene:addChild(cs, StringUtils.getMaxZOrder(runScene))	
	    cs:setPosition(display.cx, display.cy)
	    _cs = cs

	    cs:setAnchorPoint(cc.p(0.5,0.5))
	    DZAction.showWindow(cs, nil)

	    cs:getChildByName('btnClose'):touchEnded(handleClose)
	    cs:getChildByName('btnLastVoice'):touchEnded(handleLastVoice)
	    cs:getChildByName('btnAddFriend'):touchEnded(handleAddFriend)

	    if data['isFriend'] then
	    	cs:getChildByName('btnAddFriend'):setEnabled(false)
		end

		local gryid = Single:gameModel():getGamePRYId()
		local isHave = Single:paltform():isLastVoice(gryid, _data['rongyunId'])
		if tostring(isHave) == 'false'  then
			cs:getChildByName('btnLastVoice'):setEnabled(false)
		end

		UIUtil.shieldLayer(cs)


		createLayer(tuser)
	end
    
    _userId = tuser:getUserId()
    _seatNum = tuser:getSeatNum()
    local userRYid = tuser:getUserRYId()
	SocketCtrol.getPlayerMsg(_userId, userRYid, netBack)
end


return GPlayerMsg