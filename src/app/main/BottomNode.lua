local BottomNode = class('BottomNode')
local BottomCtrol = require('main.BottomCtrol')
local _bottomNode = nil
local _bottom = nil
local btnTab = {}
local btnBg = {}
local BtnFlag = 1

local point = nil

local function gameFunc( sender, eventType )
	print('游戏')
	_bottomNode:selectedOfBtn(sender:getTag())
	BottomCtrol.buildGame()
end

local function messageFunc( sender, eventType )
	print('消息')
	_bottomNode:selectedOfBtn(sender:getTag())
	BottomCtrol.buildMessage()
end

local function clubFunc( sender, eventType )
	print('俱乐部')
	_bottomNode:selectedOfBtn(sender:getTag())
	BottomCtrol.buildClub()
end

local function resultFunc( sender, eventType )
	BottomCtrol.buildResult()
end

local function cardsFunc( sender, eventType )
	print('牌局')
	-- _bottomNode:selectedOfBtn(sender:getTag())
	BottomCtrol.buildCards()
end

local function mineFunc( sender, eventType )
	print('我 mine')
	-- _bottomNode:selectedOfBtn(sender:getTag())
	BottomCtrol.buildMine()	
end

function BottomNode:selectedOfBtn( tag )
	--[[for k,btn in pairs(btnTab) do
		if tag == btn:getTag() then
			btn:setBright(false)
			btn:setTouchEnabled(false)
			BtnFlag = tag
		else
			DZAction.delateTime(nil, 1, function()
				btn:setBright(true)
				btn:setTouchEnabled(true)
			end)
		end
	end]]
end

function BottomNode:createBottom( _btnFlag, parent )
	_bottomNode = self
	btnTab = {}
	BtnFlag = _btnFlag
	local bg = UIUtil.addPosSprite("common/main_button_bg.png", cc.p(display.cx,0), parent, cc.p(0.5, 0))
	local currScene = cc.Director:getInstance():getRunningScene()
	bg:setLocalZOrder(StringUtils.getMaxZOrder(currScene))

	local posX = display.width
	local posY = 100/2
	local idx = 70

	local Button = {}
	local dirCom = "common/"
	-- Button["btn_game"] 				= dirCom.."main_btn_game1.png"
	-- Button["btn_pressed_game"] 		= dirCom.."main_btn_game2.png"
	-- Button["btn_msg"] 				= dirCom.."main_btn_msg1.png"
	-- Button["btn_pressed_msg"] 		= dirCom.."main_btn_msg2.png"
	-- Button["btn_club"] 				= dirCom.."main_btn_club1.png"
	-- Button["btn_pressed_club"] 		= dirCom.."main_btn_club2.png"
	
	Button["btn_result"] 			= dirCom.."main_btn_result1.png"
	Button["btn_pressed_result"] 	= dirCom.."main_btn_result2.png"
	Button["btn_cards"] 			= dirCom.."main_btn_cards1.png"
	Button["btn_pressed_cards"] 	= dirCom.."main_btn_cards2.png"
	Button["btn_mine"] 				= dirCom.."main_btn_mine1.png"
	Button["btn_pressed_mine"] 		= dirCom.."main_btn_mine2.png"

	-- -- 游戏
	-- btnTab[1] = UIUtil.addImageBtn({pos=cc.p(posX*1/5-idx, posY), norImg=Button.btn_game, selImg=Button.btn_pressed_game, disImg=Button.btn_pressed_game, parent=bg, listener=gameFunc }):setTag(1)

 --    -- 消息
 --    btnTab[2] = UIUtil.addImageBtn({pos=cc.p(posX*2/5-idx, posY), norImg=Button.btn_msg, selImg=Button.btn_pressed_msg, disImg=Button.btn_pressed_msg, parent=bg, listener=messageFunc }):setTag(2)

    -- 战绩
    btnTab[1] = UIUtil.addImageBtn({pos=cc.p(posX*1/4-20, posY), norImg=Button.btn_result, selImg=Button.btn_pressed_result, disImg=Button.btn_pressed_result, parent=bg, listener=resultFunc }):setTag(1)

    -- 牌局
    btnTab[2] = UIUtil.addImageBtn({pos=cc.p(posX*1/2, 126/2), norImg=Button.btn_cards, selImg=Button.btn_pressed_cards, disImg=Button.btn_pressed_cards, parent=bg, listener=cardsFunc }):setTag(2)

    -- 我
    btnTab[3] = UIUtil.addImageBtn({pos=cc.p(posX*3/4+20, posY), norImg=Button.btn_mine, selImg=Button.btn_pressed_mine, disImg=Button.btn_pressed_mine, parent=bg, listener=mineFunc }):setTag(3)

    btnTab[BtnFlag]:setBright(false)
	btnTab[BtnFlag]:setTouchEnabled(false)

    for i=1,3 do
    	-- btnBg[i] = UIUtil.addImageView({image = ResLib.COM_OPACITY0, touch=false, scale=true, size=cc.size(90, 90), pos=cc.p(btnTab[i]:getPosition()), ah=cc.p(0.5,0.5), parent=bg})
    	if i ~= BtnFlag then
    		btnTab[i]:setBright(true)
			btnTab[i]:setTouchEnabled(true)
    	end
    end

	-- _bottomNode:buildRedPoint()
    return bg
end

function BottomNode:buildRedPoint(  )

	-- 消息
    -- NoticeCtrol.setNoticeNode( POS_ID.POS_60001, btnBg[2] )
    -- 俱乐部
    -- NoticeCtrol.setNoticeNode( POS_ID.POS_20001, btnBg[4] )
    -- 好友
	-- NoticeCtrol.setNoticeNode( POS_ID.POS_10001, btnBg[5] )
	-- 联盟
	-- NoticeCtrol.setNoticeNode( POS_ID.POS_30001, btnBg[5] )
	-- 奖励
	-- NoticeCtrol.setNoticeNode( POS_ID.POS_50001, btnBg[5] )
	-- -- 战队
	-- NoticeCtrol.setNoticeNode( POS_ID.POS_100001, btnBg[5] )

	-- Notice.registRedPoint( 1 )
 --    Notice.registRedPoint( 2 )
 --    Notice.registRedPoint( 3 )
 --    Notice.registRedPoint( 4 )
 --    Notice.registRedPoint( 7 )
 --    Notice.registRedPoint( 10 )
end

function BottomNode:getBtnNode(  )
	return btnTab
end

function BottomNode:addBottom( _btnFlag, parent )
	if _bottom then
		-- parent:addChild(_bottom)
		_bottom:createBottom(_btnFlag, parent)
	end
end

function BottomNode:getInstance(  )
	if not _bottom then
		_bottom = BottomNode:create()
	end
	return _bottom
end

return BottomNode