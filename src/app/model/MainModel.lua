local MainModel = {}

--本地存储
local SHARE_CODE    = 'SHARE_CODE'

local STANDARD_NAME = 'STANDARD_NAME'
local SNG_NAME      = 'SNG_NAME'

local B_BLIND_1     = 'B_BLIND_1'
local B_SING_UP_2   = 'B_SING_UP_2'
local H_BLIND_1     = 'H_BLIND_1'
local H_SING_UP_2   = 'H_SING_UP_2'
local H_SING_UP_3   = 'H_SING_UP_3'

--标准牌局时间、单挑牌局时间
local B_STANDARD_TIME = 'B_STANDARD_TIME'
local B_HEADS_UP_TIME = 'B_HEADS_UP_TIME'

--升盲时间、起始记分牌
local B_UP_TIME       = 'B_UP_TIME'
local B_BEGIN_SCORES  = 'B_BEGIN_SCORES'

function MainModel:getGameTime(key)
    local stime = Storage.getDoubleForKey(key)
    if stime == 0 then
        stime = DZConfig.gameTimes()[1]
    end
    return stime
end

function MainModel:storageUpTime()
    local stime = Storage.getDoubleForKey(B_UP_TIME)
    if stime == 0 then
        stime = DZConfig.getUpTimes()[1]
    end
    return stime
end

function MainModel:storageBeginScores()
    local stime = Storage.getDoubleForKey(B_BEGIN_SCORES)
    if stime == 0 then
        stime = DZConfig.getStartScores()[1]
    end
    return stime
end

function MainModel:getBuildNumOnes()
    local rets = {}
    --建立牌局：标准牌局大盲、sng报名费
    local b_blind1 = Storage.getDoubleForKey(B_BLIND_1)
    local b_singup2 = Storage.getDoubleForKey(B_SING_UP_2)

    if b_blind1 == 0 then 
        b_blind1 = DZConfig.buildBlind()[1]
    end
    if b_singup2 == 0 then 
        b_singup2 = DZConfig.buildSng()[1]
    end
    table.insert(rets, b_blind1)
    table.insert(rets, b_singup2)

    return rets
end

function MainModel:getHallNumOnes()
    local rets = {}
    --大厅牌局：标准牌局大盲、sng报名费、heads-up报名费
    local h_blind1 = Storage.getDoubleForKey(H_BLIND_1)
    local h_singup2 = Storage.getDoubleForKey(H_SING_UP_2)
    local h_singup3 = Storage.getDoubleForKey(H_SING_UP_3)

    if h_blind1 == 0 then 
        h_blind1 = DZConfig.hallBlind()[1]
    end
    if h_singup2 == 0 then 
        h_singup2 = DZConfig.hallSng()[1]
    end
    if h_singup3 == 0 then 
        h_singup3 = DZConfig.hallHups()[1]
    end
    table.insert(rets, h_blind1)
    table.insert(rets, h_singup2)
    table.insert(rets, h_singup3)

    return rets
end

function MainModel:getBuildName()
    local rets = {}
    local pId = Single:playerModel():getId()
    local standard = Storage.getStringForKey(STANDARD_NAME..pId)
    local sng = Storage.getStringForKey(SNG_NAME..pId)

    local uname = Single:playerModel():getPName()
    if standard == '' then
        standard = uname..'的牌局'
    end
    if sng == '' then
        -- sng = uname..'单桌锦标赛(SNG)'
        sng = uname..'的牌局'
    end

    table.insert(rets, standard)
    table.insert(rets, sng)
    return rets
end


function MainModel:updateData()
    local bdatas = self._builds
    local hdatas = self._halls

    --组建牌局
    for i=1,#bdatas do
        local tdata = bdatas[ i ]
        local tname = tdata['gameName']
        local numOne = tdata['numOne']
        if not tname then
            tname = ''
        end
        
        local key1 = ''
        local key2 = ''
        if tdata['tag'] == StatusCode.BUILD_STANDARD then
            key1 = STANDARD_NAME
            key2 = B_BLIND_1

            Storage.setDoubleForKey(B_STANDARD_TIME, tdata['gameTime'], true)
        elseif tdata['tag'] == StatusCode.BUILD_SNG then
            key1 = SNG_NAME
            key2 = B_SING_UP_2

            Storage.setDoubleForKey(B_UP_TIME, tdata['upTime'], true)
            Storage.setDoubleForKey(B_BEGIN_SCORES, tdata['beginScores'], true)
        end

        Storage.setStringForKey(key1, tname, true)
        Storage.setDoubleForKey(key2, numOne, true)
    end

    --大厅
    for i=1,#hdatas do
        local tdata = hdatas[ i ]
        local numOne = tdata['numOne']
        
        local key2 = ''
        if tdata['tag'] == StatusCode.HALL_START then
            key2 = H_BLIND_1
        elseif tdata['tag'] == StatusCode.HALL_SNG then
            key2 = H_SING_UP_2
        elseif tdata['tag'] == StatusCode.HALL_HUPS then
            key2 = H_SING_UP_3
        end

        Storage.setDoubleForKey(key2, numOne, true)
    end

    cc.UserDefault:getInstance():flush()
end


--build
function MainModel:setArray(btnTexts, btnLocks, isBuild)
    table.insert(btnTexts, {'标准', '多牌', '保险'})
    if isBuild then
        table.insert(btnTexts, {2, 6, 9, 45})
        table.insert(btnTexts, {})
    else
        table.insert(btnTexts, {6, 9, 45})
        table.insert(btnTexts, {'标准', '多牌', '保险'})
    end


    table.insert(btnLocks, {false, true, true})
    if isBuild then
        table.insert(btnLocks, {false, false, false, true})
        table.insert(btnLocks, {})
    else
        table.insert(btnLocks, {false, false, true})
        table.insert(btnLocks, {false, true, true})
    end
end


function MainModel:setShareCode(code)
    Storage.setStringForKey(SHARE_CODE, code)
end
function MainModel:getShareCode()
    return Storage.getStringForKey(SHARE_CODE)
end

function MainModel:isEditStatus()
	return self._isSEdit
end
function MainModel:setEditStatus(edit)
	self._isSEdit = edit
end


--get
function MainModel:getHallData()
	return self._halls
end
function MainModel:getBuildData()
	return self._builds
end
function MainModel:getEditHallData(btnTexts, btnLocks)
    self:setArray(btnTexts, btnLocks, false)
	return self._halls
end
function MainModel:getEditBuildData(btnTexts, btnLocks)
    self:setArray(btnTexts, btnLocks, true)
	return self._builds
end

function MainModel:getHallResData(isBuild)
    local data = {}

    local imgTitles     = {'main_line4.png', 'main_line2.png', 'main_line6.png', ''}
    local textOnes      = {'盲注', '奖金', '盲注', ''}
    local textTwos      = {'起始记分牌', '报名费', '起始记分牌', ''}
    local imgBtns       = {'main_btn9.png', 'main_btn10.png', 'main_btn9.png', 'main_btn10.png'}

    if isBuild then
        imgTitles     = {'main_line4.png', 'main_line5.png', 'main_line8.png'}
        textOnes      = {'盲注', '奖金', '初始筹码', ''}
        textTwos      = {'起始记分牌', '报名费', '报名费', ''}
        imgBtns       = {'main_btn6.png', 'main_btn6.png', 'main_btn6.png', 'main_inBtn.png'}
    end

    for i=1,#imgTitles do
        local tab = {}
        tab['imgTitle']     = 'main/'..imgTitles[ i ]
        tab['textOne']      = textOnes[ i ]
        tab['textTwo']      = textTwos[ i ]
        tab['imgBtn']       = 'main/'..imgBtns[ i ]
        tab['imgEdit']      = 'main/main_pen.png'

        table.insert(data, tab)
    end

    return data
end

function MainModel:getEditResData(isBuild)
    local data = {}

    local seniorTexts   = {'游戏模式:', '参赛人数:', '游戏模式:'} --''没有高级设置这项
    local textOnes      = {'盲注:', '报名费:', '盲注:'}
    local textTwos      = {'带入计分牌:', '奖池:', '带入计分牌:'}
    local textThrees    = {'记录费:', '', '记录费:'}
    local titles        = {'快速游戏', '坐满即玩(SNG)', '单挑'}
    local btnImgs       = {'main/main_btn11.png', 'main/main_btn12.png', 'main/main_btn11.png'}

    if isBuild then
        seniorTexts   = {'游戏模式:', '参赛人数:'} 
        textOnes        = {'盲注:', '报名费:', '盲注:'}
        textTwos        = {'带入计分牌:', '奖池:', '带入计分牌:'}
        textThrees    = {'记录费:', '', '记录费:'}
        titles          = {'标准牌局', '单桌锦标赛(SNG)'}
        btnImgs       = {'main/main_btn8.png', 'main/main_btn8.png'}
    end

    for i=1,#titles do
        local tab = {}
        tab['title']        = titles[ i ]
        tab['textOne']      = textOnes[ i ]
        tab['textTwo']      = textTwos[ i ]
        tab['textThree']    = textThrees[ i ]
        tab['seniorText']   = seniorTexts[ i ]
        tab['btnImg']       = btnImgs[ i ]

        table.insert(data, tab)
    end

    return data
end

--外过的数据
function MainModel:getPublicRaceData()
    local resData, data = {}, {}
    --资源
    local imgTitles     = {'main_line4.png', 'main_line5.png', 'main_line8.png'}
    local textOnes      = {'盲注', '奖金', '初始筹码', ''}
    local textTwos      = {'起始记分牌', '报名费', '报名费', ''}
    local imgBtns       = {'main_btn6.png', 'main_btn6.png', 'main_btn6.png', 'main_inBtn.png'}
    for i = 1, #imgTitles do 
        local tab = {}
        tab['imgTitle']     = 'main/'..imgTitles[ i ]
        tab['textOne']      = textOnes[ i ]
        tab['textTwo']      = textTwos[ i ]
        tab['imgBtn']       = 'main/'..imgBtns[ i ]
        tab['imgEdit']      = 'main/main_pen.png'

        table.insert(resData, tab)
    end

    --数据
    local numOnes   = self:getHallNumOnes()
    local tags      = {StatusCode.HALL_START, StatusCode.HALL_SNG, StatusCode.HALL_HUPS}
    local pnums     = {9, 6, 2}
    local lookBtns  = {'查看全部游戏', '查看全部比赛', '查看全部游戏'}
     for i=1,#tags do
        local tab = {}
        tab['tag']          = tags[ i ]
        tab['numOne']       = numOnes[ i ]

        --是否显示高级、游戏模式、游戏人数
        tab['isDisHigh']    = false
        tab['gameModel']    = '标准'
        tab['playerNum']    = pnums[ i ]

        tab['lookBtn']      = lookBtns[ i ]

        table.insert(data, tab)
    end

    return resData, data
end

--init edit
function MainModel:extraBuild(datas)
	--是否有显示授权、授权状态
    local gameNames = self:getBuildName()

    for i=1,#datas do
        local tdata = datas[ i ]
        tdata['gameName'] = gameNames[ i ]
        --是否有授权功能(是否显示授权报名按钮)
        tdata['isHAuthorize'] = true

        --游戏时长、升盲时间  起始记分牌、升盲时间  起始记分牌
        if tdata['tag'] == StatusCode.BUILD_STANDARD then
            tdata['isSAuthorize'] = false
            tdata['gameTime'] = self:getGameTime(B_STANDARD_TIME)
            tdata['authorizeText'] = '控制玩家带入:'
            tdata["anteNum"] = 0
            tdata["gameMod"] = 0
        elseif tdata['tag'] == StatusCode.BUILD_SNG then
            tdata['isSAuthorize'] = false
            tdata['upTime'] = self:storageUpTime()
            tdata['beginScores'] = self:storageBeginScores()
            tdata['authorizeText'] = '控制玩家报名:'
        end
    end
end

function MainModel:extraHall(datas)

end


function MainModel:editData(isBuild)
    local data = {}

    --hall ：大盲、报名费、报名费
    --build：大盲、报名费、大盲
    local numOnes   = self:getHallNumOnes()
    local tags      = {StatusCode.HALL_START, StatusCode.HALL_SNG, StatusCode.HALL_HUPS}
    local pnums     = {9, 6, 2}
    local lookBtns  = {'查看全部游戏', '查看全部比赛', '查看全部游戏'}
    if isBuild then
        numOnes     = self:getBuildNumOnes()
        pnums     = {9, 2}
        tags        = {StatusCode.BUILD_STANDARD, StatusCode.BUILD_SNG}
        lookBtns  = {'', ''}
    end

    for i=1,#tags do
        local tab = {}
        tab['tag']          = tags[ i ]
        tab['numOne']       = numOnes[ i ]

        --是否显示高级、游戏模式、游戏人数
        tab['isDisHigh']    = false
        tab['gameModel']    = '标准'
        tab['playerNum']    = pnums[ i ]

        tab['lookBtn']      = lookBtns[ i ]

        table.insert(data, tab)
    end

    if isBuild then
    	self:extraBuild(data)
    else
    	self:extraHall(data)
    end

    return data
end


function MainModel:getAllGames(data, tag)
    --print("000000----00000")
    --print("cccc=="..data['count'])
    --dump(data)
    local rets = {}

    --大厅sng数据特殊处理
    if(tag == 2) then

        local cellTables = data

        for i=1,#cellTables do
            local tdata = cellTables[ i ]
            local ret = {}
            ret['entry_cost'] = tdata['entry_cost']
            ret['entry_fee'] = tdata['entry_fee']
            ret['first_prize'] = tdata['first_prize']
            ret['increase_time'] = tdata['increase_time']
            ret['inital_score'] = tdata['inital_score']
            ret["players_count"] = tdata['players_count']
            ret["second_prize"] = tdata['second_prize']
            ret["type"] = tdata['type']

            table.insert(rets, ret)
        end 
    else
        --local rets = {}
        local imgTag = 'main/main_reward1.png'
        local title1 = '快速游戏'
        local title2 = ''--'参赛人数:'
        local title3 = ''--'报名费:'
        local sortText1 = ''--'参赛人数'
        local sortText2 = '参赛金:(由小到大)'
        local sortText3 = '参赛金:(由大到小)'

        if tag == StatusCode.HALL_START then
            sortText1 = '空座'
            sortText2 = '盲注级别:(由小到大)'
            sortText3 = '盲注级别:(由大到小)'
            title1 = '快速游戏'
            title3 = ''--'盲注:'
            title2 = ''--'玩家人数:'

            imgTag = 'main/main_reward1.png'
        elseif tag == StatusCode.HALL_SNG then
            title1 = '坐满即玩'
            imgTag = 'main/main_reward2.png'
        elseif tag == StatusCode.HALL_HUPS then
            title1 = '单挑'
            imgTag = 'main/main_reward3.png'
            title3 = ''--'盲注:'
            sortText1 = '空座'
            sortText2 = '盲注级别:(由小到大)'
            sortText3 = '盲注级别:(由大到小)'
        end

        local tab = DZConfig.hallBlind()
        -- for i=1,10 do
        local cellTables = data["tables"]

        for i=1,#cellTables do
            local tdata = cellTables[ i ]
            local ret = {}
         
            ret['title1'] = tdata['name']
            ret['gid']    = tdata['gid']
            ret['nowPersonNum'] = tdata['current_players']
            ret['allPersonNum'] = tdata['limit_players']
            if tonumber(tdata['entry_fee']) ~= 0 then
                ret['useNum'] = tdata['entry_fee']
            elseif tonumber(tdata['big_blind']) ~= 0 then
                ret['useNum'] = tdata['big_blind']
            end

            if(tdata['inital_score'] ~= nil) then
                ret["inital_score"]=tdata['inital_score']
                ret["increase_time"]=tdata['increase_time']
            end

            -- ret['gid']    = 'gid'
            -- ret['title1'] = title1..StringUtils.threeBit(i)
            -- ret['nowPersonNum'] = 2
            -- ret['allPersonNum'] = 9 
            -- --盲注或报名费
            -- ret['useNum'] = tab[i]

            ret['imgTag'] = imgTag
            ret['title2'] = title2
            ret['title3'] = title3

            ret["entry_fee"] = tdata['entry_fee']
            ret["big_blind"] = tdata['big_blind']
            ret['secure'] = tdata['secure']

            table.insert(rets, ret)
        end


        --local data = {}--------好坑啊---------
        data['title'] = '场'..title1
        data['sortText1'] = sortText1
        data['sortText2'] = sortText2
        data['sortText3'] = sortText3
    end
    
    return rets, data
end


function MainModel:initArray()
    self._halls = self:editData(false)
    self._builds = self:editData(true)
end


function MainModel:init()
	--是否是编辑状态
	self._isSEdit = false

	--
	self._halls = {}
	self._builds = {}

	self:initArray()
end


return MainModel