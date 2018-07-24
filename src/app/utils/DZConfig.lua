local DZConfig = {}

--个人组建标准牌局、个人组建sng牌局、大厅标准牌局、大厅sng牌局、大厅headsup标准牌局
-- _secure 为保险牌局
GAME_TYPE_STANDARD 		= 'general'
GAME_TYPE_STANDARD_SECURE = 'general_secure'
GAME_TYPE_SNG 			= 'sng'
GAME_TYPE_HALL_STANDARD = 'hall_general_standard'
GAME_TYPE_HALL_SNG 		= 'hall_sng'
GAME_TYPE_HALL_HEADSUP 	= 'hall_general_headsup'

--俱乐部组建标准牌局、俱乐部组建sng牌局、圈子组建标准牌局、圈子组建sng牌局、联盟组建sng、联盟组建标准
GAME_CLUB_STABDARD 		= '21'
GAME_CLUB_STABDARD_SECURE 	= '21_secure'
GAME_CLUB_SNG 			= '22'
GAME_CIRCLE_STABDARD 	= '31'
GAME_CIRCLE_STABDARD_SECURE = '31_secure'
GAME_CIRCLE_SNG 		= '32'
GAME_UNION_STABDARD 	= '41'
GAME_UNION_STABDARD_SECURE 	= '41_secure'
GAME_UNION_SNG 			= '42'

--mtt：俱乐部、圈子、联盟、组建牌局
GAME_CLUB_MTT 			= '23'
GAME_CIRCLE_MTT 		= '33'
GAME_UNION_MTT			= '43'
GAME_TYPE_MTT 			= 'mtt_general'
GAME_HALL_MTT			= '53'			--大厅mtt
GAME_LOCAL_MTT			= '63'			--本地化mtt


local _isLogin = true
function DZConfig.setInLogin(login)
	_isLogin = login
end
function DZConfig.isInLogin()
	return _isLogin
end


function DZConfig.getShareImgName()
	return 'SHARE_IMG.png'
end

function DZConfig.getHeadImgName(userId)
	assert(userId, ' getHeadImgName ')
	return 'head_'..userId..'_img.png'
end


function DZConfig.getHeadUrl(hurl)
	if hurl == '' or string.len(hurl) == 0 then
		return ''
	end
	return DZConfig.getImgHeadUrl()..hurl
end

function DZConfig.getImgHeadUrl()
	return IMG_PREFIX_URL
end


--bbs 转换筹码
function DZConfig.getBBSToScores(bbs)
	return bbs * 20
end



--img name
function DZConfig.cardName(idx)
	if type(idx) ~= 'number' then
		assert(nil, 'idx type is not number')
	end

	if idx == StatusCode.POKER_BACK then
		return ResLib.COM_CARD
	end

	if idx < 1 or idx > 52 then
		assert(nil, 'idx 超出了范围  '..idx)
	end

	return 'dzcard/card_'..idx..'.png'
end


function DZConfig.getStatusImg(status)
	local img = nil
	if status == StatusCode.GAME_GIVEUP then
		img = 'game/game_giveup_tag.png'
	elseif status == StatusCode.GAME_LOOK then
		img = 'game/game_looks.png'
	elseif status == StatusCode.GAME_FOLLOW then
		img = 'game/game_follows.png'
	elseif status == StatusCode.GAME_ADD then
		img = 'game/game_adds.png'
	elseif status == StatusCode.GAME_ALLIN then
		img = 'game/game_allins.png'
	elseif status == StatusCode.GAME_THINK then
		-- img = 'game/game_looks.png'
	elseif status == StatusCode.GAME_DELAY then
		img = 'game/game_delay_time.png'
	elseif status == StatusCode.GAME_GAME_ING then
		img = nil
	elseif status == StatusCode.GAME_WAIT_ING then
		img = nil
	elseif status == StatusCode.GAME_STRADDLE1 then 
		img = 'game/game_straddle.png'
	elseif status == StatusCode.GAME_NO_STATUS then
		img = nil
	end

	return img
end

function DZConfig.getSexImg(sex)
	local img = 'user/user_icon_sex_male.png'

	if sex == 2 then
		img = 'user/user_icon_sex_female.png'
	end

	return img
end



--表情动画
function DZConfig.emojiImg(idx)
	local img = string.format('icon/emoji_%d.png', idx)
	return img
end

--1~12
function DZConfig.getEmojiPreFix(idx)
	local prefix = 'emoji'..idx..'_'
	return prefix
end

--1~12
function DZConfig.getEmojiFrameNum(idx)
	local arrs = {
		10, 10, 10, 10, 10, 10,
		10, 12, 10, 12, 11, 11
	}
	local frame = arrs[ idx ]
	return frame
end

--表情名
function DZConfig.getEmojiName(idx)
	local arrs = {
		'emoji1', 'emoji2', 'emoji3', 'emoji4', 'emoji5', 'emoji6',
		'emoji7', 'emoji8', 'emoji9', 'emoji10', 'emoji11', 'emoji12'
	}
	local name = 'dzemoji/'..arrs[ idx ]
	return name
end


--动画前缀
function DZConfig.getAniPreFix(aniTag)
	local aniImg = {}
	aniImg[ ResLib.EFFECT_HAND ] = 'hand_'
	aniImg[ ResLib.EFFECT_BEER ] = 'beer_'
	aniImg[ ResLib.EFFECT_BOMB ] = 'bomb_'
	aniImg[ ResLib.EFFECT_CAKE ] = 'cake_'
	aniImg[ ResLib.EFFECT_CHICKEN ] = 'chicken_'

	-- aniImg[ ResLib.EFFECT_DIAMOND ] = 'diamond_'
	aniImg[ ResLib.EFFECT_FISH ] = 'fish_'
	-- aniImg[ ResLib.EFFECT_FLOWER ] = 'flower_'
	aniImg[ ResLib.EFFECT_MOUTH ] = 'mouth_'
	aniImg[ ResLib.EFFECT_REDPACKET ] = 'redPacket_'
	aniImg[ ResLib.EFFECT_PANDA ] = 'panda_'

	local prefix = aniImg[ aniTag ]

	if not prefix then
		assert(nil, 'getAniOneImg '..aniTag)
	end

	return prefix
end

--动画第一张图片
function DZConfig.getAniOneImg(aniTag)
	local aniImg = {}
	aniImg[ ResLib.EFFECT_HAND ] = ResLib.HAND_ONE
	aniImg[ ResLib.EFFECT_BEER ] = ResLib.BEER_ONE
	aniImg[ ResLib.EFFECT_BOMB ] = ResLib.BOMB_ONE
	aniImg[ ResLib.EFFECT_CAKE ] = ResLib.CAKE_ONE
	aniImg[ ResLib.EFFECT_CHICKEN ] = ResLib.CHICKEN_ONE

	-- aniImg[ ResLib.EFFECT_DIAMOND ] = ResLib.DIAMOND_ONE
	aniImg[ ResLib.EFFECT_FISH ] = ResLib.FISH_ONE
	-- aniImg[ ResLib.EFFECT_FLOWER ] = ResLib.FLOWER_ONE
	aniImg[ ResLib.EFFECT_MOUTH ] = ResLib.MOUTH_ONE
	aniImg[ ResLib.EFFECT_REDPACKET ] = ResLib.REDPACKET_ONE
	aniImg[ ResLib.EFFECT_PANDA ] = ResLib.PANDA_ONE

	local oneImg = aniImg[ aniTag ]

	if not oneImg then
		assert(nil, 'getAniOneImg '..aniTag)
	end

	return oneImg
end

--动画多少贞
function DZConfig.getAniFrameNum(aniTag)
	local aniImg = {}
	aniImg[ ResLib.EFFECT_HAND ] = 18
	aniImg[ ResLib.EFFECT_BEER ] = 13
	aniImg[ ResLib.EFFECT_BOMB ] = 20
	aniImg[ ResLib.EFFECT_CAKE ] = 7
	aniImg[ ResLib.EFFECT_CHICKEN ] = 12

	-- aniImg[ ResLib.EFFECT_DIAMOND ] = 12
	aniImg[ ResLib.EFFECT_FISH ] = 14
	-- aniImg[ ResLib.EFFECT_FLOWER ] = 19
	aniImg[ ResLib.EFFECT_MOUTH ] = 12
	aniImg[ ResLib.EFFECT_REDPACKET ] = 15
	aniImg[ ResLib.EFFECT_PANDA ] = 22

	local frame = aniImg[ aniTag ]

	if not frame then
		assert(nil, 'getAniOneImg '..aniTag)
	end

	return frame
end

--动画数组
function DZConfig.getAniArray()
	local ANI_ARR = {
		ResLib.EFFECT_HAND, ResLib.EFFECT_BEER, ResLib.EFFECT_CAKE, ResLib.EFFECT_FISH, ResLib.EFFECT_CHICKEN,
		ResLib.EFFECT_MOUTH, ResLib.EFFECT_BOMB, ResLib.EFFECT_REDPACKET, ResLib.EFFECT_PANDA
	}
	return ANI_ARR
end

--动画显示图片数组和动画数组对应
function DZConfig.getAniOneImgArray()
	local aniOneImgs = {
		ResLib.HAND_ONE, ResLib.BEER_ONE, ResLib.CAKE_ONE, ResLib.FISH_ONE, ResLib.CHICKEN_ONE, 
		ResLib.MOUTH_ONE, ResLib.BOMB_ONE, ResLib.REDPACKET_ONE, ResLib.PANDA_ONE
	}
	return aniOneImgs
end

--灰色
function DZConfig.getAniGreyImgArray()
	local aniOneImgs = {
		ResLib.HAND_GREY, ResLib.BEER_GREY, ResLib.CAKE_GREY, ResLib.FISH_GREY, ResLib.CHICKEN_GREY, 
		ResLib.MOUTH_GREY, ResLib.BOMB_GREY, ResLib.REDPACKET_GREY, ResLib.PANDA_GREY
	}
	return aniOneImgs
end


--config
function DZConfig.getTypeName(ctype)
	local arrs = {'皇家同花顺', '同花顺', '四条', '葫芦', '同花', '顺子', '三条', '两对', '一对', '高牌'}
	
	if not arrs[ ctype ] then 
		-- return '未知'
		return ''
	end
	return arrs[ctype]
end


--组建牌局大盲
function DZConfig.buildBlind()
	-- 1-2 2-4 5-10 10-20 20-40 25-50 50-100 100-200 500-1000 1000-2000 2000-4000 5k-10k 10k-20k
	local tab = {2, 4, 10, 20, 40, 50, 100, 200, 1000, 2000, 4000, 10000, 20000}
	return tab
end

--组建牌局sng报名费
function DZConfig.buildSng()
	local tab = {200, 300, 400, 500, 1000, 2000}
	return tab
end

--SNG盲注级别
function DZConfig.sngBlindLevel()
	local tab = {10, 15, 25, 40, 60, 80, 100, 150, 200, 300, 400, 500, 600, 
	800,1000,1500,2000,3000,4000,6000,8000,10000,15000,20000,25000,30000,"",""}
	return tab
end
--组建heads-up牌局大盲
-- function DZConfig.buildHups()
-- 	-- local tab = {2, 4, 10, 20, 50, 100, 200}
-- 	return DZConfig.buildBlind()
-- end
function DZConfig.getPeopleNum()
	local tab = {2, 3, 4, 5, 6, 7, 8, 9}
	return tab
end

--大厅牌局大盲
function DZConfig.hallBlind()
	local tab = {10, 20, 50, 100, 200, 400, 1000, 2000, 5000, 10000, 20000}
	return tab
end

--大厅牌局sng报名费
function DZConfig.hallSng()
	local tab = {200, 300, 500, 1000, 5000, 10000, 30000, 50000, 100000, 200000, 500000}
	return tab
end

--大厅牌局heads-up报名费
function DZConfig.hallHups()
	-- local tab = {200, 300, 500, 1000, 2000, 5000, 10000, 30000, 50000, 100000, 200000, 500000}
	-- return tab
	local tab = {2, 4, 10, 20, 50, 100, 200, 400, 1000, 2000, 5000, 10000, 20000}
	return tab
	-- return DZConfig.hallBlind()
end

--游戏时间
function DZConfig.gameTimes()
	local tab = {0.5, 1, 1.5, 2, 2.5, 4, 6, 8, 10, 12}
	return tab
end

function DZConfig.getAnte(  )
	-- 0 2 5 10 20 25 50 75 100 150 300 500
	local tab = {0, 1, 2, 5, 10, 20, 25, 50, 75, 100, 150, 300, 500}
	return tab
end

--升盲时间
function DZConfig.getUpTime()
	local tab = {3, 5, 7, 10}
	return tab
end

function DZConfig.getSngUpTimes()
	local tab = {3, 5, 7, 10, 15}
	return tab
end

--升盲时间
function DZConfig.getUpTimes()
	-- local tab = {3, 5, 7, 10, 15}
	local tab = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 15, 20, 25, 30, 40, 50, 60, 90, 120}
	return tab
end

--升盲时间
function DZConfig.stopLevel()
	-- local tab = {6, 8, 10, 12, 15}
	local tab = {}
	for i=1,15 do
		tab[i] = i
	end
	return tab
end

--SNG起始记分牌
function DZConfig.getStartSngScores()
	local tab = { 30, 50, 75, 100, 150, 200, 400}
	return tab
end

--MTT起始记分牌
function DZConfig.getStartScores()
	-- local tab = { 50, 75, 100, 150, 200, 400}
	local tab = {10, 20, 30, 50, 75, 100, 150, 200, 300, 400, 500}
	return tab
end

function DZConfig.getMttFee()
	-- local tab = {200, 300, 400, 500, 1000, 2000}
	local tab = {50, 100, 200, 300, 400, 500, 800, 1000, 2000, 3000, 4000, 5000, 10000, 20000, 30000, 40000, 50000, 100000}
	return tab
end

-- MTT重构次数
function DZConfig.getRebuyNum(  )
	-- local tab = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, "无限制"}
	local tab = {}
	for i=1,11 do
		tab[i] = i-1
	end
	return tab
end

-- MTT起始盲注级别
function DZConfig.getBlindLevel(  )
	local tab = {20, 40, 50, 100, 200, 600, 1000}
	return tab
end


--得到记录费
--组建牌局：大忙超过20 记录费改变
local _bigBlind = 20
function DZConfig.gameRecordFeeMul(bigBlind, gtype)
	local mul = 0.1
	return mul
end

function DZConfig.mainRecordFeeMul(bigBlind, ctag)
    local mul = 0.1
    return mul
end


--牌局类型
--general 或 sng
function DZConfig.changePokerType(pokerType)
	local tab = {}
	tab[ GAME_TYPE_STANDARD ] 		= StatusCode.POKER_GENERAL
	tab[ GAME_TYPE_HALL_STANDARD ] 	= StatusCode.POKER_GENERAL
	tab[ GAME_TYPE_HALL_HEADSUP ] 	= StatusCode.POKER_GENERAL
	tab[ GAME_CLUB_STABDARD ] 		= StatusCode.POKER_GENERAL
	tab[ GAME_CIRCLE_STABDARD ] 	= StatusCode.POKER_GENERAL
	tab[ GAME_UNION_STABDARD ] 		= StatusCode.POKER_GENERAL

	tab[ GAME_TYPE_SNG ] 			= StatusCode.POKER_SNG
	tab[ GAME_TYPE_HALL_SNG ] 		= StatusCode.POKER_SNG
	tab[ GAME_CLUB_SNG ] 			= StatusCode.POKER_SNG
	tab[ GAME_CIRCLE_SNG ] 			= StatusCode.POKER_SNG
	tab[ GAME_UNION_SNG ] 			= StatusCode.POKER_SNG

	tab[ GAME_TYPE_MTT ] 			= StatusCode.POKER_MTT
	tab[ GAME_CLUB_MTT ] 			= StatusCode.POKER_MTT
	tab[ GAME_CIRCLE_MTT ] 			= StatusCode.POKER_MTT
	tab[ GAME_UNION_MTT ] 			= StatusCode.POKER_MTT
	tab[ GAME_HALL_MTT ] 			= StatusCode.POKER_MTT
	tab[ GAME_LOCAL_MTT ] 			= StatusCode.POKER_MTT

	local changeType = tab[ pokerType ]
	if not changeType then
		assert(nil, 'changePokerType  '..pokerType)
	end

	return changeType
end 
--是否是大厅mtt
function DZConfig.isHallMTT(pokerType)
	if GAME_HALL_MTT == pokerType then
		return true
	end
	return false
end
--是否是大厅游戏
function DZConfig.isHallGame(pokerType)
	local halls = {} 
	halls[ GAME_TYPE_HALL_STANDARD ] 	= true
	halls[ GAME_TYPE_HALL_SNG ] 		= true
	halls[ GAME_TYPE_HALL_HEADSUP ] 	= true
	halls[ GAME_HALL_MTT ] 				= true

	if halls[ pokerType ] then
		return true
	end
	return false
end
--是否是标准牌局
function DZConfig.isStandardPoker(pokerType)
	local standards = {}
	standards[ GAME_TYPE_STANDARD ]		= true
	standards[ GAME_TYPE_HALL_STANDARD ]= true
	standards[ GAME_TYPE_HALL_HEADSUP ]	= true
	standards[ GAME_CLUB_STABDARD ]		= true
	standards[ GAME_CIRCLE_STABDARD ]	= true
	standards[ GAME_UNION_STABDARD ]	= true
	
	if standards[ pokerType ] then
		return true
	end
	return false
end


--比赛奖励：人数、钱
function DZConfig.getRewardMoney(pnum, money)
	local ret = {}
	local allM = money * pnum
	if pnum == 6 then
		local first = math.floor(allM * 2 / 3)
		local second = math.floor(allM / 3)
		table.insert(ret, first)
		table.insert(ret, second)
	elseif pnum == 9 then
		local first = math.floor(allM * 0.5)
		local second = math.floor(allM * 0.3)
		local third = math.floor(allM * 0.2)
		table.insert(ret, first)
		table.insert(ret, second)
		table.insert(ret, third)
	elseif pnum == 2 then
		local first = math.floor(allM)
		table.insert(ret, first)
	else
		assert(nil, 'getRewardMoney  '..pnum)
	end

	return ret
end


--platform 转换
--sng涨盲时间
function DZConfig.getGrowBlindTime(growBlindTime)
	local gbt = growBlindTime / 60
	return gbt..'分'
end

--sng奖励
function DZConfig.getSngRewards(pnum, money)
	local rewards = {'', '', ''}
	local rewardNums = DZConfig.getRewardMoney(pnum, money)

	for i=1,#rewardNums do
		rewards[i] = tostring(rewardNums[ i ])
	end

	return rewards
end

--服务器秒转换成分
function DZConfig.secondsToMin(seconds)
	if not seconds then return '0分' end
	local min,_ = math.modf(tonumber(seconds) / 60)
	return min..'分'
end


--游戏中配置计算

--倒计时百分比
function DZConfig.getRunPercentAndTime(runTime, mode)
	local thinkTime = 0
	if mode == nil or mode == 1 then --默认喊注思考时间
	 	thinkTime = Single:gameModel():getThinkTime()
	elseif mode == 2 then  -- 保险思考时间
		thinkTime = Single:gameModel():getInsuranceTime()
	elseif mode == 3 then  -- 搓牌思考时间
		thinkTime = Single:gameModel():getCuoTime()
	end

	if not runTime then
		return 100,thinkTime
	end

	--延迟思考时间
	if runTime >= thinkTime then
		return 100,runTime
	end

	--小于思考时间
	local percent = runTime / thinkTime * 100
	return percent,runTime
end


--Mtt大厅盲注级别
--
function DZConfig.getMTTHallBigBlind()
	local blinds = {
		50, 100, 150, 200, 300, 400, 600, 800, 1000,
		1200, 1600, 2000, 3000, 4000, 5000, 6000, 8000,
		10000, 12000, 14000, 16000, 20000, 24000, 30000,
		40000, 50000, 60000, 80000, 100000, 120000, 160000,
		200000, 300000, 400000, 500000, 600000, 700000, 800000, 
		1000000, 1200000
	}
	return blinds
end

function DZConfig.getMTTHallSmallBlind()
	local blinds = {}
	local bigs = DZConfig.getMTTHallBigBlind()

	for i=1,#bigs do
		local val = bigs[ i ] / 2
		table.insert(blinds, val)
	end

	return blinds
end

function DZConfig.getMTTHallANTE()
	local antes = {
		0, 0, 0, 25, 25, 50, 75,
		100, 100, 200, 200, 300, 
		500, 500, 500, 500, 1000, 1000, 1000,
		2000, 2000, 2000, 3000, 3000, 4000,
		5000, 5000, 10000, 10000, 10000,
		20000, 20000, 30000, 50000, 50000, 50000,
		100000, 100000, 100000, 100000
	}
	return antes
end

function DZConfig.getMTTHallBlinds()
	local ret = {}	
	local bigs = DZConfig.getMTTHallBigBlind()
	local smalls = DZConfig.getMTTHallSmallBlind()
	local antes = DZConfig.getMTTHallANTE()
	for i=1,#bigs do
		local temp = {}
		temp['blindSmall'] = smalls[i]
		temp['ante'] = antes[i]
		temp['blindBig'] = bigs[i]
		temp['blindLevel'] = i
		table.insert(ret, temp)
	end
	return ret
end


--Mtt组建牌局盲注级别
--
-- function DZConfig.getMTTBuildBigBlind()
-- 	local blinds = {
-- 		20, 30, 50, 100, 150, 200, 250, 300, 400, 600, 800, 1000,
-- 		1200, 1600, 2000, 2500, 3000, 4000, 5000, 6000, 7000, 8000,
-- 		10000, 12000, 16000, 20000, 25000, 30000, 40000, 50000, 60000, 80000, 
-- 		100000, 120000, 150000, 180000, 210000, 240000, 280000, 320000, 360000, 
-- 		400000, 450000, 500000, 550000, 600000, 650000, 700000, 800000, 900000,
-- 		1000000, 1200000, 1400000, 1600000, 1800000, 2000000
-- 	}
-- 	return blinds
-- end

-- function DZConfig.getMTTBuildSmallBlind()
-- 	local blinds = {}
-- 	local bigs = DZConfig.getMTTBuildBigBlind()

-- 	for i=1,#bigs do
-- 		local val = bigs[ i ] / 2
-- 		table.insert(blinds, val)
-- 	end

-- 	return blinds
-- end

-- function DZConfig.getMTTBuildANTE()
-- 	local antes = {
-- 		0, 0, 0, 0, 10, 10, 25, 25, 50, 50, 75,
-- 		100, 125, 150, 200, 250, 300, 400,
-- 		500, 600, 700, 800, 1000, 1200, 1600,
-- 		2000, 2500, 3000, 4000, 5000, 6000, 7000, 8000,
-- 		10000, 12000, 15000, 18000, 21000,
-- 		24000, 28000, 32000, 36000, 40000, 45000, 50000, 55000, 60000, 70000, 80000, 90000,
-- 		100000, 120000, 140000, 160000, 180000, 200000
-- 	}
-- 	return antes
-- end

-- Outs 与 Odds 一一对应， 最后一个是代表20张及以上
function DZConfig.getOddsList()
	local oddsList = {
						 -- Outs = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20},
						 -- Odds = {30,16,10,8, 6, 5, 4,3.5,3,2.5,2.2, 2, 1.8,1.6,1.4,1.2,1.0,0.8,0.6,0.5}
					 	 30,16, 10,8, 6, 5, 4,3.5,3,2.5,2.2, 2, 1.8,1.6,1.4,1.2,1.0,0.8,0.6,0.5
					 }
	return oddsList
end


-- 获取赔率
function DZConfig.getOddsValue(outsNum)
	if (outsNum <= 0) then 
		outsNum = 1
	end
	-- print("outsNum:"..outsNum)
	local oddsArr = DZConfig.getOddsList()
	if outsNum > #oddsArr then 
		outsNum = #oddsArr
	end

	local oddVal = oddsArr[outsNum]
	return oddVal
end

-- mtt盲注级别表json读取
function DZConfig.readMttJosn(  )
	-- print("读取mtt盲注表")
	-- local filePath =  cc.FileUtils:getInstance():fullPathForFilename("common/blind.json")
	-- local f = io.open(filePath, "r")
	-- local jsonStr = f:read("*all")
	-- f:close()
	-- mttBlindTab = json.decode(jsonStr)
end

-- mtt盲注级别表（盲注级别，大盲，小盲，前注）
function DZConfig.getMttBlindTab(  )
	print("获取mtt盲注表")
	local blindTab = require("common.blindData")
	return blindTab
end

--得到对应盲注
--blindTag快慢、blindStart起始盲注
function DZConfig.getBlindNote(blindTag, blindStart)
	local tab = DZConfig.getMttBlindTab()
	local tag = 'general'
	if blindTag == StatusCode.BLIND_FASE then
		tag = 'quick'
	end

	local startTag = 'blind_'..blindStart
	local retTab = tab[ tag ][ startTag ]
	
	if not retTab then return {} end

	return retTab
end


--提示信息,获取不到gps位置
function DZConfig.getTextGPS()
	local text = '无法获取到您的GPS位置信息，请您\n确认GPS功能是否正常。'
	return text
end

function DZConfig.getCountryTab(  )
	local country = {
		{id = 1, name = "美国"},
		{id = 2, name = "中国"},
		{id = 3, name = "香港"},
		{id = 4, name = "澳门"},
		{id = 5, name = "台湾"},
		{id = 6, name = "韩国"},
		{id = 7, name = "日本"},
		{id = 8, name = "新加坡"},
		{id = 9, name = "马来西亚"},
		{id = 10, name = "泰国"},

		{id = 11, name = "缅甸"},
		{id = 12, name = "老挝"},
		{id = 13, name = "越南"},
		{id = 14, name = "菲律宾"},
		{id = 15, name = "柬埔寨"},
		{id = 16, name = "英国"},
		{id = 17, name = "澳大利亚"},
		{id = 18, name = "加拿大"},
		{id = 19, name = "法国"},
		{id = 20, name = "德国"},

		{id = 21, name = "意大利"},
		{id = 22, name = "俄罗斯"},
		{id = 23, name = "墨西哥"},
		{id = 24, name = "巴西"},
		{id = 25, name = "冰岛"},
		{id = 26, name = "丹麦"},
		{id = 27, name = "瑞士"},
	}
	return country
end

function DZConfig.getCountryById( id )
	local tab = DZConfig.getCountryTab()
	for i,v in ipairs(tab) do
		if v.id == tonumber(id) then
			return v
		end
	end
	return {id = 1, name = "未知"}
end


return DZConfig