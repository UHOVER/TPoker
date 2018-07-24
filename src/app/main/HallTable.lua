local HallTable = {}
local _line = nil
local _data = {}
local _resData = {}
local _csize = cc.size(650,475)

local BUILD_TAG = 1 -- 组件牌局
local HALL_TAG = 2 -- 大厅
local PUBLIC_RACE_TAG = 3 -- 2017/07/18  main ui fix

local _tag = PUBLIC_RACE_TAG
local _shareCode = ''
local _pageIdx = 0
local _edit = nil
local _spPanel = nil
local _cs = nil
local _cellArr = {}
local _startBtns = {}
local _editNode = nil
local MAX_B = 4--组建牌局元素数量
local MAX_H = 5--大厅元素数量
local MAX_F = 3---- 2017/07/18  main ui fix
local _superPage = nil

--btn
local function startBtn(event)
    local target = event
    local idata = target._itemData
    dump(idata)
    local function response(data)
    end

    MainCtrol.startGameFilterType(idata, response)
end

-- 进入MTT编辑界面
local function editMttLayer( event )
    if(_superPage.m_isCanClick == true) then
        local currScene = cc.Director:getInstance():getRunningScene()
        local SetCards = require("common.SetCards")
        local layer = SetCards:create()
        currScene:addChild(layer, StringUtils.getMaxZOrder(currScene))
        layer:createLayer(3, "person")
    end
end

--进入小游戏按钮
local function inLittleGame(event)
    --print("jkhsadkfjhsd==".._superPage.m_isCanClick)

    if(_superPage.m_isCanClick == true) then
        event:setTouchEnabled(false)
        local GamblingLayer = require('gambling.GamblingLayer')
        GamblingLayer.showGambling()
        GamblingLayer:setWhichLayerInTag(1)
    end
end

local function editBtn(tag, sender)
    if(_superPage.m_isCanClick == true) then
        local MainLayer = require 'main.MainLayer'

        if _tag == HALL_TAG then
            MainLayer:switchEditHall(_pageIdx)
        elseif _tag == BUILD_TAG or _tag == PUBLIC_RACE_TAG then
            MainLayer:switchEditBuild(1)
        end
    end
end

local function okBtn(tag, sender)
    MainCtrol.enterGame(_shareCode, MainCtrol.MOD_CODE, function()
        _edit:setText('')
    end)
end


local function getNewIdx(idx)
    return idx % #_data + 1
end


local function scrollBack(parent, idx)
    idx = getNewIdx(idx)
    _pageIdx = idx
end

---------------------------------------------new-------------------
local function allGameBtn(sender)
    if(_superPage.m_isCanClick == true) then
        MainCtrol.lookAllGame(2, function(cdata)
            local AllGame = require 'main.AllGame'
            AllGame.lookGame(2, cdata)
        end)
    end
end

local function allGameBtn4MTT(sender)
    print("进入MTT大厅")
    if(_superPage.m_isCanClick == true) then
        --发送消息
        local function response(data)
            --dump(data)
            if(data == nil) then
                data = {}
            end

            data.flag = sender.flag
            require('main.AllGameMTT'):create(data)
        end

        local tab = {}
        --25--大厅mtt标志
        if(sender.flag == 25) then
            tab['mttType'] = 1
            tab['page'] = 1
            tab['every_page'] = 30
            MainCtrol.filterNet("game_hall/getMttList", tab, response, PHP_POST)
        --14--本地化
        elseif(sender.flag == 14) then
            tab['mod'] = 1
            local MainLayer = require 'main.MainLayer'
            tab['city_code'] = MainLayer:getCityCode()
            print("code=="..MainLayer:getCityCode())
            MainCtrol.filterNet("LocalMttList", tab, response, PHP_POST)
        end
    end
end

---------------------------------------------public race ---
local function buildRGameRoom(sender, eventType)
    if eventType == ccui.TouchEventType.began then 
        sender:setColor(cc.c3b(171, 171, 171))
    elseif eventType == ccui.TouchEventType.canceled then
        sender:setColor(cc.c3b(255,255,255))
    elseif eventType == ccui.TouchEventType.ended  then 
        sender:setColor(cc.c3b(255,255,255))
        print("创建牌局")
        editBtn(_tag, sender)
    end
end

local function addCellLayer(idx, parent)
    --idx = getNewIdx(idx)
    local tmpIdx = idx
    local tIdx = idx

    if _tag == HALL_TAG then
        if idx > MAX_H then
            return
        end
    end

    if _tag == BUILD_TAG then
        if idx == MAX_B then--敬请期待
            idx = 1
            tmpIdx = MAX_B
        elseif(idx > MAX_B) then
            return
        end
    end

    local tnode = cc.Layer:create()
    tnode:setTag(16)
    tnode:setName('GUID_DIS_LAYER')
    tnode.isShowEditBtn = true
    tnode.isShowInBtn = true
    tnode.idx = tIdx
    parent:addChild(tnode)
    table.insert(_cellArr, tnode)

    local cdata = {}
    local rdata = {}
   
    if idx > 3 and idx <= MAX_H and _tag == HALL_TAG then
        cdata = _data[ 1 ]
        rdata = _resData[ 1 ]
    --组件牌局mtt，本地mtt做特殊处理
    elseif (tmpIdx == 3 or tmpIdx == 4) and _tag == BUILD_TAG then
        cdata = _data[ 2 ]
        rdata = _resData[ 2 ] 
    else
        cdata = _data[ idx ]
        rdata = _resData[ tmpIdx ]
    end

    local cy = _csize.height / 2 
    local cx = _csize.width / 2

    -- bg背景图片
    --print("_tag==".._tag.." ,tmpIdx=="..tmpIdx)
    local bgImgStr = "main/main_cardBG"
    print(">>>>>>>>bgImgStr:", bgImgStr.._tag..tmpIdx..".png")
    local tbg = UIUtil.addPosSprite(bgImgStr.._tag..tmpIdx..".png", cc.p(cx,_csize.height-105), tnode, cc.p(0.5,0.5))
    tnode.tbg = tbg--背景图片，播发动画用
    tnode:setCascadeColorEnabled(true)
    local color = cc.c3b(255, 252, 205)
    local fsize = 26
    local ftype = 'Arial-BoldMT'
    
    local one, two, v1, v2 = MainCtrol.getHallText(cdata, rdata)
   
    --快速游戏
    local button = ccui.Button:create()
    button._itemData = cdata
    --button:touchEnded(startBtn)
    button:touchEnded(editBtn)
    button:setTouchEnabled(true)
    button:loadTextures(rdata['imgBtn'], rdata['imgBtn'], "")
    button:setPosition(cc.p(cx - 5, 85 - 15 + 300))
    parent:addChild(button)
    button:setName('GUID_DIS_BTN')
    button:setTag(18)

    table.insert(_startBtns, button)

    MainHelp.mainAdaptationHallBtn({button})

    --编辑
    local editItem = UIUtil.addMenuBtn(rdata['imgEdit'], rdata['imgEdit'], editBtn, cc.p(552 - 80, cy + 330), parent)
    editItem:setTag(cdata['tag'])
    editItem:getParent():setName("e")
    editItem:getParent():setVisible(false)
    tnode.isShowEditBtn = false

    --MTT
    if (_tag == BUILD_TAG and tmpIdx == 3) then
        --one = ''
        --two = ''
        local cscmfee = MainCtrol.getBuildMttScore()--初始筹码X20
        local bmfee = MainCtrol.getBuildMttFee()--报名费
        
        one = "初始筹码"
        two = "报名费"
        v1 = tostring(cscmfee*20)
        v2 = bmfee.."+"..bmfee/10

        -- button:loadTextures("main/main_inBtn.png", "main/main_inBtn.png", "main/main_inBtn.png")
        button:touchEnded(editMttLayer)
        editItem:getParent():setVisible(true)
        tnode.isShowEditBtn = false
        tnode.isShowInBtn = true

        -- if(DZ_CLOSE_MTT == true) then
        --     button:setVisible(false)
        --     button:setTouchEnabled(false)
        --     tnode.isShowInBtn = false
        -- end
    --小游戏
    elseif (_tag == HALL_TAG and tmpIdx == 4) then
        --tbg:setTexture("main/main_line9.png")
        one = ''
        two = ''
        v1 = ''
        v2 = ''
        button:loadTextures("main/main_inBtn.png", "main/main_inBtn.png", "main/main_inBtn.png")
        button:touchEnded(inLittleGame)
        editItem:getParent():setVisible(false)
        tnode.isShowEditBtn = false
        tnode.isShowInBtn = true
    --sng
    elseif (_tag == HALL_TAG and tmpIdx == 2) then
        one = ''
        two = ''
        v1 = ''
        v2 = ''
        button:loadTextures("main/main_inBtn.png", "main/main_inBtn.png", "main/main_inBtn.png")
        button:touchEnded(allGameBtn)
        editItem:getParent():setVisible(false)
        tnode.isShowEditBtn = false
        tnode.isShowInBtn = true
    --MTT大厅
    elseif (_tag == HALL_TAG and tmpIdx == 5) then
        one = ''
        two = ''
        v1 = ''
        v2 = ''
        button.flag = 25--大厅mtt标志
        button:loadTextures("main/main_inBtn.png", "main/main_inBtn.png", "main/main_inBtn.png")
        button:touchEnded(allGameBtn4MTT)
        editItem:getParent():setVisible(false)
        tnode.isShowEditBtn = false
        tnode.isShowInBtn = true

        local actionLDNode = cc.CSLoader:createNode("action/showStarPoint.csb")
        actionLDNode:setPosition(cc.p(490, 590))
        actionLDNode:setTag(666)
        actionLDNode:setVisible(false)
        tnode:addChild(actionLDNode)

        -- if(DZ_CLOSE_MTT == true) then
        --     button:setVisible(false)
        --     button:setTouchEnabled(false)
        --     tnode.isShowInBtn = false
        -- end
    --MTT本地化
    elseif (_tag == BUILD_TAG and tmpIdx == 4) then
        one = ''
        two = ''
        v1 = ''
        v2 = ''
        button.flag = 14--组件牌局 本地化 mtt标志
        button:loadTextures("main/main_inBtn.png", "main/main_inBtn.png", "main/main_inBtn.png")
        button:touchEnded(allGameBtn4MTT)
        editItem:getParent():setVisible(false)
        tnode.isShowEditBtn = false
        tnode.isShowInBtn = true

        local actionLDNode = cc.CSLoader:createNode("action/showStarPoint.csb")
        actionLDNode:setPosition(cc.p(490, 590))
        actionLDNode:setTag(666)
        actionLDNode:setVisible(false)
        tnode:addChild(actionLDNode)

        -- if(DZ_CLOSE_MTT == true) then
        --     button:setVisible(false)
        --     button:setTouchEnabled(false)
        --     tnode.isShowInBtn = false
        -- end
    --国外版本 -免费参赛
    elseif (_tag == PUBLIC_RACE_TAG and tmpIdx == 1) then 
        button.flag = 25
        button:touchEnded(allGameBtn4MTT)
    --国外版本 -实物奖励
    elseif (_tag == PUBLIC_RACE_TAG and tmpIdx == 2) then 
        button.flag = 25
        button:touchEnded(allGameBtn4MTT)
    --国外版本 -出票专场
    elseif (_tag == PUBLIC_RACE_TAG and tmpIdx == 3) then 
        button.flag = 25
        button:touchEnded(allGameBtn4MTT)
    end

    button:loadTextures("main/m_cartBtn.png", "main/m_cartBtn.png", "main/m_cartBtn.png")
    button:setSwallowTouches(false)

--[[
    button:setVisible(false)
    button:setTouchEnabled(false)
    tnode.isShowInBtn = false
]]
    --两行文字
    if(_tag == BUILD_TAG) then
        print("kasdksdhfkj==="..one)
        --标准牌局
        if(tIdx == 1) then
            --阴影
            UIUtil.addLabelArial(one, fsize, cc.p(cx + 50+ 2 - 16 - 15,185 + 50 - 2), cc.p(1,0.5), tnode, cc.c3b(0, 0, 0), ftype)
            UIUtil.addLabelArial(v1, fsize, cc.p(cx + 50 + 16 + 2 - 15,185 + 50 - 2), cc.p(0,0.5), tnode, cc.c3b(0, 0, 0), ftype)
            UIUtil.addLabelArial(two, fsize, cc.p(cx + 50 - 16 + 2 - 15,145 + 50 - 2), cc.p(1,0.5), tnode, cc.c3b(0, 0, 0), ftype)
            UIUtil.addLabelArial(v2, fsize, cc.p(cx + 50 + 16 + 2 - 15,145 + 50 - 2), cc.p(0,0.5), tnode, cc.c3b(0, 0, 0), ftype)

            UIUtil.addLabelArial(one, fsize, cc.p(cx + 50 - 16 - 15,185 + 50), cc.p(1,0.5), tnode, color, ftype)
            UIUtil.addLabelArial(v1, fsize, cc.p(cx + 50 + 16 - 15,185 + 50), cc.p(0,0.5), tnode, color, ftype)
            UIUtil.addLabelArial(two, fsize, cc.p(cx + 50 - 16 - 15,145 + 50), cc.p(1,0.5), tnode, color, ftype)
            UIUtil.addLabelArial(v2, fsize, cc.p(cx + 50 + 16 - 15,145 + 50), cc.p(0,0.5), tnode, color, ftype)
        else
            --阴影
            UIUtil.addLabelArial(one, fsize, cc.p(cx - 16 + 2,185 + 50- 2), cc.p(1,0.5), tnode, cc.c3b(0, 0, 0), ftype)
            UIUtil.addLabelArial(v1, fsize, cc.p(cx + 16+ 2,185 + 50- 2), cc.p(0,0.5), tnode, cc.c3b(0, 0, 0), ftype)
            UIUtil.addLabelArial(two, fsize, cc.p(cx - 16+ 2,145 + 50- 2), cc.p(1,0.5), tnode, cc.c3b(0, 0, 0), ftype)
            UIUtil.addLabelArial(v2, fsize, cc.p(cx + 16+ 2,145 + 50- 2), cc.p(0,0.5), tnode, cc.c3b(0, 0, 0), ftype)

            UIUtil.addLabelArial(one, fsize, cc.p(cx - 16,185 + 50), cc.p(1,0.5), tnode, color, ftype)
            UIUtil.addLabelArial(v1, fsize, cc.p(cx + 16,185 + 50), cc.p(0,0.5), tnode, color, ftype)
            UIUtil.addLabelArial(two, fsize, cc.p(cx - 16,145 + 50), cc.p(1,0.5), tnode, color, ftype)
            UIUtil.addLabelArial(v2, fsize, cc.p(cx + 16,145 + 50), cc.p(0,0.5), tnode, color, ftype)
        end
    elseif(_tag == HALL_TAG) then
        --自由单桌
        if(tIdx == 1) then
            --阴影
            UIUtil.addLabelArial(one, fsize, cc.p(cx + 5 - 16 + 2,335 + 50 - 2), cc.p(1,0.5), tnode, cc.c3b(0, 0, 0), ftype)
            UIUtil.addLabelArial(v1, fsize, cc.p(cx + 5 + 16+ 2,335 + 50- 2), cc.p(0,0.5), tnode, cc.c3b(0, 0, 0), ftype)
            UIUtil.addLabelArial(two, fsize, cc.p(cx + 5 - 16 + 2,295 + 50- 2), cc.p(1,0.5), tnode, cc.c3b(0, 0, 0), ftype)
            UIUtil.addLabelArial(v2, fsize, cc.p(cx + 5 + 16+ 2,295 + 50- 2), cc.p(0,0.5), tnode, cc.c3b(0, 0, 0), ftype)

            UIUtil.addLabelArial(one, fsize, cc.p(cx + 5 - 16,335 + 50), cc.p(1,0.5), tnode, color, ftype)
            UIUtil.addLabelArial(v1, fsize, cc.p(cx + 5 + 16,335 + 50), cc.p(0,0.5), tnode, color, ftype)
            UIUtil.addLabelArial(two, fsize, cc.p(cx + 5 - 16,295 + 50), cc.p(1,0.5), tnode, color, ftype)
            UIUtil.addLabelArial(v2, fsize, cc.p(cx + 5 + 16,295 + 50), cc.p(0,0.5), tnode, color, ftype)
        else
             --阴影
            UIUtil.addLabelArial(one, fsize, cc.p(cx - 16+ 2,335 + 50 - 2), cc.p(1,0.5), tnode, cc.c3b(0, 0, 0), ftype)
            UIUtil.addLabelArial(v1, fsize, cc.p(cx + 16+ 2,335 + 50- 2), cc.p(0,0.5), tnode, cc.c3b(0, 0, 0), ftype)
            UIUtil.addLabelArial(two, fsize, cc.p(cx - 16+ 2,295 + 50- 2), cc.p(1,0.5), tnode, cc.c3b(0, 0, 0), ftype)
            UIUtil.addLabelArial(v2, fsize, cc.p(cx + 16+ 2,295 + 50- 2), cc.p(0,0.5), tnode, cc.c3b(0, 0, 0), ftype)
            
            UIUtil.addLabelArial(one, fsize, cc.p(cx - 16,335 + 50), cc.p(1,0.5), tnode, color, ftype)
            UIUtil.addLabelArial(v1, fsize, cc.p(cx + 16,335 + 50), cc.p(0,0.5), tnode, color, ftype)
            UIUtil.addLabelArial(two, fsize, cc.p(cx - 16,295 + 50), cc.p(1,0.5), tnode, color, ftype)
            UIUtil.addLabelArial(v2, fsize, cc.p(cx + 16,295 + 50), cc.p(0,0.5), tnode, color, ftype)
        end
    end

end


local function editBoxChange(eventType, sender)
    print("asdadasd==="..eventType)
    if eventType == 'began' then
        sender:setPlaceHolder('') 
        print("bbbbb~~~~~~")
        --处理误触摸
        _superPage.m_tableCell[ 1 ]:getChildByTag(18):setVisible(false)
    elseif eventType == "changed" then      
    elseif eventType == "ended" then        
    elseif eventType == "return" then
        print("rrrrr~~~~~~")
        --处理误触摸
        _superPage:stopAllActions()
        _superPage:runAction(cc.Sequence:create(
                            cc.DelayTime:create(0.1),
                            --回复触摸
                            cc.CallFunc:create(
                                function(sender)
                                    _superPage.m_tableCell[ 1 ]:getChildByTag(18):setVisible(true)
                                end)
                            ))
    end

    _shareCode = sender:getText()
end

local function setIdx(pidx)
    _pageIdx = pidx
    print('当前展示  '..pidx)
    if pidx == 4 then
        if Notice.getMessagePushCount(8)["count"] and Notice.getMessagePushCount(8)["count"] > 0 then
            Notice.deleteBuildCard(0)
        end
    end
end

local function getMyNeed()
    return _tag
end

local function createLayer(parent, spPanel)
    _shareCode = ''
    local layer = cc.Layer:create()
    parent:addChild(layer)

    local tlayer = cc.LayerColor:create(cc.c4b(255,255,255,0), display.width, 535)
    tlayer:setPositionY(400)
    parent:addChild(tlayer)
    
    local page = require('main.SuperPageTable'):create(spPanel, addCellLayer, setIdx, getMyNeed)
    layer:addChild(page)
    
    --大厅展示第五个
    if(_tag == 2) then
        page:resetPos(5)
        _pageIdx = 5
    else
        page:resetPos(1)
        _pageIdx = 1
        --page:resetPos(_pageIdx)
    end
    
    _superPage = page

    _line = UIUtil.addPosSprite('main/main_scroll1.png', cc.p(display.width/2,-110), tlayer, cc.p(0.5,0.5))
    _line:setScale(610/_line:getContentSize().width)
    local imgs = {"common/com_btn_blue.png","common/com_btn_blue_height.png","common/com_btn_blue.png"}
    local buildBtn = UIUtil.addUIButton(imgs, cc.p(display.cx, -196), tlayer, buildRGameRoom)
    buildBtn:setScale9Enabled(true)
    buildBtn:setContentSize(cc.size(610, 82))
    buildBtn:setTitleText("创建牌局")
    buildBtn:setTitleFontSize(42)
    buildBtn:setTitleFontName("Helvetica-Bold")
    -- buildBtn:setBrightStyle(ccui.BrightStyle.highlight)
    --edit
    local editNode = cc.Node:create()
    tlayer:addChild(editNode)
    editNode:setPosition(cc.p(0, -10))
    _editNode = editNode

    -- UIUtil.addPosSprite('main/main_input.png', cc.p(display.width/2-2,390), editNode, cc.p(0.5,0.5))
    UIUtil.scale9Sprite(cc.rect(20,10,20,10), "common/com_btn_blue_border_small.png", cc.size(610, 95), cc.p(display.cx, 0), editNode)
    local tedit = UIUtil.addEditBox(nil, cc.size(492,83), cc.p(display.cx-610/2+18,0), '请输入验证码进入牌局', editNode)
    tedit:setAnchorPoint(0,0.5)
    tedit:setFontSize(38)
    tedit:setPlaceholderFontSize(38)
    tedit:setPlaceholderFontColor(cc.c3b(100, 126, 165))
    tedit:setFontColor(cc.c3b(255, 255, 255))

    _edit = tedit

    tedit:registerScriptEditBoxHandler(editBoxChange)

    UIUtil.addMenuBtn('main/main_btn0.png', 'main/main_btn0.png', okBtn, cc.p(636, 0), editNode)
    tedit:setInputMode(cc.EDITBOX_INPUT_MODE_PHONENUMBER)


    local ttfSurplus = UIUtil.addLabelArial('', 32, cc.p(display.cx,1135), cc.p(0.5,0.5), layer, cc.c3b(115, 150, 196), 'Arial-BoldMT')
    local function updateScore()
        local text = Single:playerModel():getPBetNum()

        ttfSurplus:setString('记分牌余额:'..text)
    end
    updateScore()
    DZSchedule.runSchedule(updateScore, 1, ttfSurplus)


    -- local befy1 = page:getPositionY()
    -- local befy2 = editNode:getPositionY()

    --余额、tableview、line、edit
    local arrs = {ttfSurplus, _line, editNode}
    MainHelp.mainAdaptationHall(arrs)

    page:setPositionY(-200)
end

function HallTable.createHall(parent, pidx, spPanel, cs)
    _cellArr = {}
    _startBtns = {}
    _cs = cs
    _tag = HALL_TAG
    _pageIdx = pidx
    _resData = MainModel:getHallResData(false)
    _data = MainModel:getHallData()
    createLayer(parent, spPanel)
    if Notice.getMessagePushCount(9)["count"] and Notice.getMessagePushCount(9)["count"] > 0 then
        Notice.deleteMessage( 9, 0 )
    end
end

function HallTable.createBuild(parent, pidx, spPanel, cs)
    _cellArr = {}
    _startBtns = {}
    _cs = cs
    _tag = BUILD_TAG
    _pageIdx = pidx
    _resData = MainModel:getHallResData(true)
    _data = MainModel:getBuildData()
    createLayer(parent, spPanel)
    if Notice.getMessagePushCount(8)["count"] and Notice.getMessagePushCount(8)["count"] > 0 then
        Notice.deleteBuildCard(0)
    end
end

function HallTable.createPublicRaceMtt(parent, idx, spPanel, cs)
    _cellArr, _startBtns = {}, {}
    _cs = cs 
    _tag = PUBLIC_RACE_TAG
    _pageIdx = pidx
    _resData, _data = MainModel:getPublicRaceData()
    createLayer(parent, spPanel)

    --TODO: tanhaiting 这里的提示怎么处理？？？？？
    -- if Notice.getMessagePushCount(8)["count"] and Notice.getMessagePushCount(8)["count"] > 0 then
    --     Notice.deleteBuildCard(0)
    -- end
end
    
--引导
function HallTable.getDisplayNode()
    local disLayer = _superPage.m_tableCell[ 1 ]:getChildByName('GUID_DIS_LAYER')
    return disLayer
end
function HallTable.getEditNode()
    return _editNode
end
function HallTable.getStartBtnNode()
    local disBtn = _superPage.m_tableCell[ 1 ]:getChildByName('GUID_DIS_BTN')
    return disBtn
end

function HallTable:clearCellArr()
    _cellArr = {}
end

function HallTable:getCellNum()
    if(_tag == BUILD_TAG) then
        return MAX_B
    elseif (_tag == HALL_TAG) then 
        return MAX_H
    else 
        return MAX_F
    end
end

return HallTable
