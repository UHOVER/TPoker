local MainCtrol = {}
local DZSort = require 'utils.DZSort'
local GameScene = require 'game.GameScene'

--组建牌局里
local _buildBigBlind    = DZConfig.buildBlind()[1]
local _buildSngFee      = DZConfig.buildSng()[1]
local _buildSngNum      = 2

local _buildMttFee = DZConfig.getMttFee()[1]
local _buildMttScore = DZConfig.getStartScores()[1]

-- 组建标准牌局大盲
function MainCtrol.setBuildBigBlind(bigBlind)
    _buildBigBlind = bigBlind
end
function MainCtrol.getBuildBigBlind()
    return _buildBigBlind
end

-- 组建sng报名费
function MainCtrol.setBuildSngFee(sngFee)
    _buildSngFee = sngFee
end
function MainCtrol.getBuildSngFee()
    return _buildSngFee
end

-- 组建sng房间人数
function MainCtrol.setBuildSngNum(sngNum)
    _buildSngNum = sngNum
end
function MainCtrol.getBuildSngNum()
    return _buildSngNum
end

-- 组建牌局MTT报名费
function MainCtrol.setBuildMttFee( mttFee )
    _buildMttFee = mttFee
end
function MainCtrol.getBuildMttFee(  )
    return _buildMttFee
end

-- 组建牌局MTT起始记分牌
function MainCtrol.setBuildMttScore( mttScore )
    _buildMttScore = mttScore
end
function MainCtrol.getBuildMttScore(  )
    return _buildMttScore
end

local function changeNum(num)
    local function noZero(noz)
        local zero = noz % 10
        if zero ~= 0 then return noz end
        noZero(noz / 10)
    end

    if num < 10000 then
        return num
    end

    local int = math.floor(num / 10000)
    local sur = num % 10000
    if sur ~= 0 then
        while sur % 10 == 0 do
            sur = sur / 10
        end
    
        int = int..'.'..sur
    end
    return int..'万'
end

--盲注:大小忙、带入记分牌、记录费
local function getBlindNum(bigBlind, ctag)
    local smallBlind = bigBlind / 2
    local first = changeNum(smallBlind)..'/'..changeNum(bigBlind)
    local secnod = changeNum(bigBlind * 100)

    --组建牌局：大忙超过20 记录费改变
    local mul = DZConfig.mainRecordFeeMul(bigBlind, ctag)

    local third = bigBlind * 100 * mul
    third = math.floor(third)
    third = changeNum(third)

    return first, secnod, third
end

--报名费:奖金、报名费、奖池
local function getSignUpCost(scost, pnum)
    local spend = scost / 10
    local rewards = DZConfig.getRewardMoney(pnum, scost)
    local first = ''
    local secnod = changeNum(scost)..'+'..changeNum(spend)
    local third = changeNum(scost * pnum)

    for i=1,#rewards do
        if i ~= 1 then
            first = first..'/'
        end
        local trew = changeNum(rewards[i])
        first = first..trew
    end

    return first, secnod, third
end


--大厅：hall、build
function MainCtrol.getHallText(cdata, rdata)
    local ttag = cdata['tag']
    local first = ''
    local secnod = ''
    local v1 = ''
    local v2 = ''
    local third = ''

    --大小盲：hall 快速游戏             build 标准牌局、单挑牌局
    --报名费：hall sng、heads-up       build sng
    if ttag == StatusCode.HALL_START or ttag == StatusCode.HALL_HUPS then
        first,secnod,third = getBlindNum(cdata['numOne'], ttag)
    elseif ttag == StatusCode.HALL_SNG then
        first,secnod,third = getSignUpCost(cdata['numOne'], cdata['playerNum'])
    elseif ttag == StatusCode.BUILD_STANDARD  then
        local bigBlind = MainCtrol.getBuildBigBlind()
        first,secnod,third = getBlindNum(bigBlind, ttag)
    elseif ttag == StatusCode.BUILD_SNG then
        local sngFee = MainCtrol.getBuildSngFee()
        local playerNum = MainCtrol.getBuildSngNum()
        first,secnod,third = getSignUpCost(sngFee, playerNum)
    end

--[[
    first = rdata['textOne']..first
    secnod = rdata['textTwo']..secnod
]]
-----add by kang
    v1 = first
    v2 = secnod

    first = rdata['textOne']
    secnod = rdata['textTwo']
-----add end
    return first, secnod, v1, v2
end


--编辑：hall、build
function MainCtrol.getEditText(cdata, rdata)
    local ttag = cdata['tag']
    local one = cdata['numOne']
    local first = ''
    local secnod = ''
    local third = ''

    --大小盲：hall 快速游戏             build 标准牌局、单挑牌局
    --报名费：hall sng、heads-up       build sng
    if ttag == StatusCode.HALL_START or ttag == StatusCode.BUILD_STANDARD or ttag == StatusCode.HALL_HUPS then
        local bigBlind = one
        first,secnod,third = getBlindNum(bigBlind, ttag)
    elseif ttag == StatusCode.BUILD_SNG or ttag == StatusCode.HALL_SNG then
        local _,tfirst,tsecnod = getSignUpCost(one, cdata['playerNum'])
        first = tfirst
        secnod = tsecnod
    end

    first = first
    secnod = secnod
    third = rdata['textThree']..third
    return first,secnod,third
end


--build:第一个 slider 设置盲注或报名费
function MainCtrol.getSliderArray(tag)
    local tab = nil
    if tag == StatusCode.BUILD_STANDARD then
        tab = DZConfig.buildBlind()
    elseif tag == StatusCode.BUILD_SNG then
        tab = DZConfig.buildSng()
    elseif tag == StatusCode.HALL_START then
        tab = DZConfig.hallBlind()
    elseif tag == StatusCode.HALL_SNG then
        tab = DZConfig.hallSng()
    elseif tag == StatusCode.HALL_HUPS then
        tab = DZConfig.hallHups()
    end

    assert(tab, "getSliderArray "..tag)

    return tab
end



function MainCtrol.getStatusText(tag)
    local tab = {}
    local bs = '标准牌局是最多9人可以参加的扑克游戏，有预定牌局\n时间及盲注级别，玩家可以随时加入、随时离开。'
    local bsng = '单桌锦标赛是参赛人数达到预定人数以后即开始比赛\n的一种锦标赛。'
    local hstart = '快速游戏是快速进入游戏，没有预定的结束时间，玩家\n可以随时加入、随时离开。'
    local hsng = '坐满即玩是参赛人数达到预定人数以后即开始比赛的\n一种锦标赛。'
    local hhups = '单挑是玩家人数达到2人后即可开始游戏，没有预定的\n结束时间，玩家可以随时加入、随时离开。'

    tab[ StatusCode.BUILD_STANDARD ] = bs
    tab[ StatusCode.BUILD_SNG ] = bsng
    tab[ StatusCode.HALL_START ] = hstart
    tab[ StatusCode.HALL_SNG ] = hsng
    tab[ StatusCode.HALL_HUPS ] = hhups

    local text = tab[ tag ]
    if text == nil then return 'error' end
    return text
end



function MainCtrol.startGameFilterType(cdata, funcBack)
    print_f(data)
    local tag = cdata['tag']
    local function getAccess(isAccess)
        --0不授权
        local is_access = 0
        if isAccess and isAccess ~= 0 then
            is_access = 1
        end
        return is_access
    end

    if tag == StatusCode.BUILD_STANDARD then
        local bigBlind = MainCtrol.getBuildBigBlind()
        local accessNum = getAccess(cdata['isSAuthorize'])
        MainCtrol.buildGeneralPoker(cdata['gameName'], cdata['gameTime'], bigBlind, accessNum, cdata["anteNum"], cdata["gameMod"], cdata["playerNum"], cdata["openStraddle"], cdata["openIP"], cdata["openGPS"], funcBack)
    elseif tag == StatusCode.BUILD_SNG then
        local accessNum = getAccess(cdata['isSAuthorize'])
        local sngFee = MainCtrol.getBuildSngFee()
        local playerNum = MainCtrol.getBuildSngNum()
        MainCtrol.buildSngPoker(cdata['gameName'], sngFee, cdata['beginScores'], cdata['upTime'], playerNum, accessNum, cdata["openIP"], cdata["openGPS"], funcBack)
    elseif tag == StatusCode.BUILD_MTT then
        MainCtrol.buildMttPoker(cdata, funcBack)
    elseif tag == StatusCode.HALL_START then
        local bigBlind = cdata['numOne']
        MainCtrol.hallQuickGame(bigBlind, cdata['game_mode'], funcBack)
    elseif tag == StatusCode.HALL_SNG then
        MainCtrol.hallSNGGame(cdata['numOne'], cdata['playerNum'], funcBack)
    elseif tag == StatusCode.HALL_HUPS then
        MainCtrol.hallHeadUpGame(cdata['numOne'], cdata['game_mode'], funcBack)
    end
end





--net
--
MainCtrol.MOD_GID = 'gid'
MainCtrol.MOD_CODE = 'code'
local _enterKey = nil
local _enterMod = nil

--进入组建牌局聊天:sng或标准、mtt
local function enterBuildChat(rgid, title, tag, usersMsg, typeMsg, msg, gid, is_apply)
    DZChat.showChatLayer(rgid, title, tag, usersMsg, typeMsg, msg)
    print('fewfwefwe  fewfwf '..gid)
    _enterKey = gid
    _enterMod = MainCtrol.MOD_GID
    if is_apply == 1 then
        DZChat.displayApplySignUp()
    end
end
local function setKeyAndMod(key, mod)
    _enterKey = key
    _enterMod = mod
end

local function getBuidMsg(usersMsg, gid)
    local mtitle = Single:playerModel():getPName()
    local murl = Single:playerModel():getPHeadUrl()
    local mId = Single:playerModel():getId()
    local mRYid = Single:playerModel():getRYId()

    local msg = DZChat.getMsgJson(mtitle, murl, mId, mRYid, gid)
    local tab = DZChat.getPlayerJson(mId, murl, mtitle, mRYid)
    
    table.insert(usersMsg, tab)

    return msg
end
function MainCtrol.buildGeneralPoker(name, time, bigBlind, isAccess, anteNum, gameMod, playerNum, openStraddle, openIP, openGPS, funcBack)
	local function response(data)
        funcBack()

        data['game_name'] = tostring(name)
        data['big_blind'] = bigBlind
        data['life_time'] = time * 60 * 60
        data['limit_players'] = playerNum
        data["secure"] = gameMod
        local typeMsg = MainCtrol.getStandardChatMsg(data, true)

        local usersMsg = {}
        local msg = getBuidMsg(usersMsg, data['gid'])
        msg["secure"] = gameMod
        -- DZChat.showChatLayer(data['Rgid'], '普通局', DZChat.TYPE_GAME_STANDARD, usersMsg, typeMsg, msg)
        local ttag = DZChat.TYPE_GAME_STANDARD
        enterBuildChat(data['Rgid'], '普通局', ttag, usersMsg, typeMsg, msg, data['gid'], data['is_apply'])
	end

    --牌局名称、牌局时间 单位秒、大盲
	local tab = {}
	tab['name'] = name
    tab['is_access'] = isAccess
	tab['big_blind'] = bigBlind
	tab['life_time'] = time * 3600
    tab['limit_players'] = playerNum
    tab['game_mod'] = 'general'
    tab['create_way'] = 'person'
    tab["secure"] = gameMod
    tab["ante"] = anteNum
    tab["open_straddle"] = openStraddle
    tab["open_ip"] = openIP
    tab["open_gps"] = openGPS
    MainCtrol.filterNet(PHP_CREATE_GAME, tab, response, PHP_POST)
end


function MainCtrol.buildSngPoker(name, entryFee, initalScore, increaseTime, limitPlayers, isAcccess, openIP, openGPS, funcBack)
    local function response(data)
        funcBack()

        data['limit_players'] = limitPlayers
        data['inital_score'] = DZConfig.getBBSToScores(initalScore)
        data['entry_fee'] = entryFee
        data['increase_time'] = increaseTime
        data['game_name'] = name
        data['signup_num'] = 1
        data['open_gps'] = openGPS
        local typeMsg = MainCtrol.getSngChatMsg(data, true)

        local usersMsg = {}
        local msg = getBuidMsg(usersMsg, data['gid'])

        print('====进阶为服务费及违法')
        -- DZChat.showChatLayer(data['Rgid'], 'SNG局', DZChat.TYPE_GAME_SNG, usersMsg, typeMsg, msg)
        local ttag = DZChat.TYPE_GAME_SNG
        enterBuildChat(data['Rgid'], 'SNG局', ttag, usersMsg, typeMsg, msg, data['gid'], data['is_apply'])
    end
    
    --牌局名称、带入积分、起始记分牌、升盲时间单位秒、奖池、记录费(报名费？)
    --是否授权、参赛人数
    local tab = {}
    tab['name'] = name
    tab['entry_fee'] = entryFee
    tab['inital_score'] = initalScore
    tab['increase_time'] = increaseTime * 60
    tab['limit_players'] = limitPlayers
    tab['is_access'] = isAcccess

    tab['game_mod'] = 'sng'
    tab['create_way'] = 'person'
    tab['open_ip'] = openIP
    tab['open_gps'] = openGPS
    MainCtrol.filterNet(PHP_CREATE_GAME, tab, response, PHP_POST)
end

function MainCtrol.buildMttPoker( _data, funcBack )
    local function response( data )
        dump(data)
        funcBack()

        -- data["inital_score"] = DZConfig.getBBSToScores(_data["inital_score"])
        data["inital_score"] = _data["inital_score"]*_data["small_blind"]*2
        data["entry_fee"] = _data["entry_fee"]
        data["increase_time"] = _data["increase_time"]/60
        data["game_name"] = _data["mtt_name"]
        data["signup_num"] = 1
        data["start_time"] = _data["play_time"]
        local typeMsg = MainCtrol.getMttChatMsg(data, true)

        local usersMsg = {}
        local msg = getBuidMsg(usersMsg, data['mtt_id'])

        local ttag = DZChat.TYPE_GAME_MTT
        enterBuildChat(data['Rmtt_id'], 'MTT局', ttag, usersMsg, typeMsg, msg, data['mtt_id'], data['is_apply'])

        -- --for test 自动为MTT添加机器人
        --[[
        if DZ_DEBUG then 
            local taba = {}
            taba['mtt_id'] = data['mtt_id']
            taba['count'] = 20
            MainCtrol.filterNet('mttTest', taba, function(data)end, PHP_POST)
        end
        -- 联盟MTT自动报名
        -- local TestCase = require('utils.TestCaseMessage')
        -- TestCase.sendMttAutoSingUp(data['mtt_id'])
        ]]
    end
    local tab = {}
    _data["tag"] = nil
    tab = _data

    --升盲时间
    -- tab['increase_time'] = 20
    dump(tab)
    MainCtrol.filterNet("createMtt", tab, response, PHP_POST)
end

function MainCtrol.hallQuickGame(big_blind, gameMode, funcBack)
    local function response(data)
        GameScene.startScene(data['gid'], StatusCode.INTO_MAIN, true)
        funcBack()
    end
    local tab = {}
    tab['big_blind'] = big_blind
    tab['secure'] = gameMode
    MainCtrol.filterNet(PHP_QUICK_GAME, tab, response, PHP_POST)
end

function MainCtrol.hallSNGGame(entry_fee, limit_players, funcBack)
    local function response(data)
        -- GameScene.startScene(data['gid'], StatusCode.INTO_MAIN)
        GameScene.startScene(data['gid'])
        funcBack()
    end
    local tab = {}
    tab['entry_fee'] = entry_fee
    tab['limit_players'] = limit_players
    MainCtrol.filterNet(PHP_HALL_SNG, tab, response, PHP_POST)
end

function MainCtrol.hallHeadUpGame(big_blind, gameMode, funcBack)
    local function response(data)
        GameScene.startScene(data['gid'], StatusCode.INTO_MAIN)
        funcBack()
    end
    local tab = {}
    tab['big_blind'] = big_blind
    tab['secure'] = gameMode
    MainCtrol.filterNet(PHP_HALL_HEAD_UP, tab, response, PHP_POST)
end


function MainCtrol.lookAllGame(game_mod, funcBack)
   local function response(data)
        funcBack(data)
    end

    local tab = {}

    --大厅sng接口换掉了，特殊处理
    if(StatusCode.HALL_SNG == game_mod) then        
        MainCtrol.filterNet("game_hall/getSngList", tab, response, PHP_POST)
    else
        
        if StatusCode.HALL_START == game_mod then
            game_mod = 1
            tab['sort_key'] = 'big_blind'
        --elseif StatusCode.HALL_SNG == game_mod then
        --    game_mod = 2
        --    tab['sort_key'] = 'entry_fee'
        elseif StatusCode.HALL_HUPS == game_mod then
            game_mod = 3
            tab['sort_key'] = 'big_blind'
        else
            assert(nil, 'lookAllGame  '..game_mod)
        end
   
        tab['game_mod'] = game_mod
        tab['sort_type'] = 'asc'
        tab['page'] = 1
        tab['every_page'] = 15
        
        MainCtrol.filterNet(PHP_GAME_LIST, tab, response, PHP_POST)
    end
    -- response(tab)
end



function MainCtrol.enterGame(key, mod, funcBack, isBefData, isMtt, mttShow)
    if isBefData then
        if _enterKey == nil or _enterMod == nil then
            assert(nil, 'enterGame MainCtrol')
        end
        mod = _enterMod
        key = _enterKey
    end

    if string.len(key) == 0 then
        ViewCtrol.showMsg('请输入验证码')
        return
    end

    local isMtt = isMtt

    local function response(data)
        funcBack()

        if not data then
            Single:appLogsJson('服务器端返回数据有错：MainCtrol.enterGame response ', data)
            return
        end

        --游戏开始前界面
        if data.game_mod == "63" or data.game_mod == "53" or data.game_mod == "43" then
            local tab = {}
            tab["pokerId"] = data["gid"]
            tab["mttType"] = "hallmtt"
            tab["ryid"] = data["Rgid"]
            if not mttShow then
                local MttShowCtorl = require("common.MttShowCtorl")
                MttShowCtorl.dataStatStatus( function (  )
                    DZChat.clickRemoveChatLayer(tab.ryid)
                    MttShowCtorl.MttSignUp(tab)
                end, tab )
            end
        else
            if data['is_join'] == 0 then
                setKeyAndMod(data['gid'], MainCtrol.MOD_GID)
                DZChat.enterBefGame(data, data['gid'])
                return
            end

            -- 游戏开始
            local game_mod = DZConfig.changePokerType(tostring(data.game_mod))
            if game_mod == StatusCode.POKER_MTT then
                local tab = {}
                tab["pokerId"] = data["gid"]
                tab["chatType"] = DZChat.TYPE_GAME_MTT
                tab["ryid"] = data["Rgid"]
                if not mttShow then
                    local MttShowCtorl = require("common.MttShowCtorl")
                    MttShowCtorl.dataStatStatus( function (  )
                        DZChat.clickRemoveChatLayer(tab.ryid)
                        MttShowCtorl.MttSignUp(tab)
                    end, tab )
                end
            else
                GameScene.startScene(data['gid'])
            end
        end
    end

    local tab = {}
    tab['key'] = key
    tab['mod'] = mod
    if mod == MainCtrol.MOD_GID then
        if isMtt then
            tab["game_type"] = "mtt_general"
        else
            tab["game_type"] = "common"
        end
    end
    MainCtrol.filterNet(PHP_ENTER_GAME, tab, response, PHP_POST) 
end


--sng报名
function MainCtrol.sngSignUp(gid, clubId, applyTab, funcBack, errBack)
    local function response(data)
        funcBack(data)
    end

    local tab = {}
    tab['gid'] = gid
    tab['club_id'] = clubId
    tab['longitude'] = applyTab.longitude
    tab['latitude'] = applyTab.latitude
    
    MainCtrol.filterNet(PHP_SNG_APPLY, tab, response, PHP_POST, errBack)  
end

--查看申请列表
function MainCtrol.lookApplayList(gid, funcBack)
    local function response(data)
        funcBack(data)
    end

    local tab = {}
    tab['gid'] = gid
    MainCtrol.filterNet(PHP_SNG_APPLY_LIST, tab, response, PHP_POST) 
end

--处理sng报名
function MainCtrol.handleSNGSignUp(gid, uid, agree, funcBack)
    local function response(data)
        funcBack()
        if agree == 1 then
        end
    end

    local tab = {}
    tab['gid'] = gid
    tab['uid'] = uid
    tab['agree'] = agree
    MainCtrol.filterNet(PHP_SNG_APPLY_CHECK, tab, response, PHP_POST) 
end

--sng离开游戏
function MainCtrol.leaveSngGame(gid, funcBack)
    local function response(data)
    end

    local tab = {}
    tab['gid'] = gid
    MainCtrol.filterNet(PHP_SNG_LEAVE_GAME, tab, response, PHP_POST) 
end

--核查记分牌
function MainCtrol.checkUserScores(funcBack)
    local function response(data)
        data = data['data']
        if data['all_diamond'] then
            Single:playerModel():setPDiaNum(data['all_diamond'])
        end
        if data['scores'] then
            Single:playerModel():setPBetNum(data['scores'])
        end
        if funcBack then
            funcBack()
        end
    end
     
    local tab = {}
    XMLHttp.requestHttp(PHP_ALL_DIAMOND, tab, response, PHP_POST, true) 
end


function MainCtrol.filterNet(pnum, tab, back, pattern, errBack, noshowWaite)
    local logs = {}
    logs[ PHP_GET_CHAT_MSG ] = true
    logs[ 'getGlStatus' ] = true

	local function response(data)
		if data['code'] ~= StatusCode.PHP_SUCCESS then

            -- ViewCtrol.showMsg(data['msg'])
			if errBack ~= nil then
				errBack(data)
			end

			return
		end

        --客户端logs
        if not data['data'] then
            if logs[pnum] then
                local tjson1 = '客户端数据  '..json.encode(tab)
                local tjson2 = '服务器端数据  '..json.encode(data)
                local logs = tjson1.."  "..tjson2
                Single:appLogs(logs, 'MainCtrol.filterNet : '..pnum)
            end
        end

		data = data['data']

		back(data)
	end

    print_f(tab)
	XMLHttp.requestHttp(pnum, tab, response, pattern, noshowWaite)
end


--得到mtt聊天显示信息
--是否是房主、人数限制、起始记分牌、报名费、升盲时间
function MainCtrol.getMttChatMsg(data, isManager)
    local ret = {}

    ret['isManager'] = tostring(isManager)

    ret['shareCode'] = tostring(data['invite_code'])
    ret['pokerId'] = tostring(data['mtt_id'])

    ret['name'] = tostring(data['game_name'])
    ret['signUpNum'] = tostring(data['signup_num'] or data['current_players'])

    ret['originBet'] = tostring(data['inital_score'])
    ret['gameFee'] = tostring(data['entry_fee'])
    ret['growBlindTime'] = tostring(data['increase_time'])..'分'
    ret['isEntry'] = data['is_entry'] or 0
    ret['isDissolve'] = 0
    -- isDissolve 0 报名后退出要扣记录费， 1 10分钟内不能退出  2 没有报名随时退出
    local value = 10*60
    local d_value = tonumber(data["start_time"]-data["current_time"])
    if tonumber(ret['isEntry']) == 0 then
        ret['isDissolve'] = 2
    else
        if d_value <= value then
            ret['isDissolve'] = 1
        else
            ret['isDissolve'] = 0
        end
    end
    
    return ret
end


--得到sng聊天显示信息
--是否是房主、人数限制、起始记分牌、报名费、升盲时间
function MainCtrol.getSngChatMsg(data, isManager)
    local ret = {}

    ret['isManager'] = tostring(isManager)

    ret['shareCode'] = tostring(data['join_code'])
    ret['pokerId'] = tostring(data['gid'])

    ret['name'] = tostring(data['game_name'])
    ret['playerCount'] = tostring(data['limit_players'])
    ret['signUpNum'] = tostring(data['signup_num'] or data['current_players'])

    ret['originBet'] = tostring(data['inital_score'])
    ret['gameFee'] = tostring(data['entry_fee'])
    ret['growBlindTime'] = tostring(data['increase_time'])..'分'
    ret['openGPS'] = tostring(data['open_gps'])
    --奖励
    MainCtrol.setSngReward(ret, data['limit_players'], data['entry_fee']) 

    return ret
end


--得到标准牌局聊天显示信息
--data 创建时候的、服务器返回的
function MainCtrol.getStandardChatMsg(data, isManager)
    local ret = {}

    ret['isManager'] = tostring(isManager)
    local bigBlind = tonumber(data['big_blind'])

    ret['blind'] = (bigBlind / 2)..'/'..bigBlind

    ret['shareCode'] = tostring(data['join_code'])
    ret['name'] = tostring(data['game_name'])
    ret['time'] = (tonumber(data['life_time']) / 60)..'分'
    ret['pokerId'] = tostring(data['gid'])
    ret['playerCount'] = tostring(data["limit_players"])
    ret["secure"] = data['secure'] or 0

    return ret
end


function MainCtrol.setSngReward(data, limit_players, entry_fee)
    data['champion'] = ''
    data['runner-up'] = ''
    data['secondRunner-up'] = ''
    data['runner_up'] = ''
    data['secondRunner_up'] = ''
    local arr = {'champion', 'runner-up', 'secondRunner-up', '', ''}
    local arr1 = {'champion', 'runner_up', 'secondRunner_up', '', ''}
    local rewards = DZConfig.getRewardMoney(tonumber(limit_players), tonumber(entry_fee))

    for i=1,#rewards do
        data[ arr[i] ] = tostring(rewards[ i ])
        data[ arr1[i] ] = tostring(rewards[ i ])
    end
end

return MainCtrol