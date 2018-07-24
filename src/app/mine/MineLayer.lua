local ViewBase = require("ui.ViewBase")
local MineLayer = class("MineLayer", ViewBase)

local MineCtrol = require('mine.MineCtrol')
local ClubCtrol = require('club.ClubCtrol')
local UnionCtrol = require("union.UnionCtrol")

local _mine = nil
local viewSize = nil
local mineMsg = {}

local scrollView = nil
local btnBg = {}

local diamondNum = nil
local scoreNum = nil

local redPoint_bg = {}

local function updateMineInfo(  )
    _mine:init()
    _mine:buildLayer()
end

function MineLayer:buildLayer(  )

    local mineNode = self:getChildByName("mine")
    if mineNode then
       mineNode:removeAllChildren()
    end

    mineMsg = MineCtrol.getMineInfo()
    dump(mineMsg)

    local mineUI = {
                {text="shop", sizeH=186, tag=1, stype=1}, 
                {text="mine", sizeH=168, tag=2, stype=1}, 
                {text="登录账号/ID", sizeH=110, tag=3, stype=2}, 
                {text="设置", sizeH=110, tag=4, stype=2},
            }
    local photoShow_H = 374
    
    local viewH = 0
    for i=1,#mineUI do
        viewH = mineUI[i].sizeH + viewH
    end
    viewSize = {width = display.width, height = viewH+photoShow_H}
    if viewSize.height < display.height-230 then
        viewSize.height = display.height-230
    end

    scrollView = UIUtil.addScrollView( {showSize=cc.size(display.width, display.height-100), innerSize=cc.size(viewSize.width, viewSize.height), dir=cc.SCROLLVIEW_DIRECTION_VERTICAL, colorType=ccui.LayoutBackGroundColorType.none, color=cc.c3b(0, 0, 10), bounce=true, pos=cc.p(0,100), parent=mineNode} )

    local layer = UIUtil.addImageView({image = ResLib.IMG_BG, touch=false, scale=true, size=cc.size(viewSize.width, viewSize.height), pos=cc.p(0,0), parent=scrollView})

    -- 相册
    local params = {bgArray=mineMsg.players_imgs, pos=cc.p(0,viewSize.height-photoShow_H), parent=layer, view=scrollView, rangeH=200, viewH=display.height}
    ClubModel.buildPageView( params )

    local function btnCallBack( sender )
        local tag = sender:getTag()
        if tag == 2 then
            print("mine")
            if VISITOR_LOGIN then
                UIUtil.checkIsVisitor()
                return
            end
            local mineEdit = require("mine.MineEdit")
            local layer = mineEdit:create()
            self:addChild(layer, 10)
            layer:createLayer()
        elseif tag == 4 then
            print("设置")
            local setting = require("mine.SettingLayer")
            local layer = setting:create()
            self:addChild(layer,10)
            layer:createLayer()
        end
    end
    -- 基础UI
    local posY = viewSize.height-photoShow_H
    local infoBg = {}
    local sizeH = {}
    local infoBgH = 0
    local infoW = 20
    for i=1,#mineUI do
        local infoH = mineUI[i].sizeH
        sizeH[i] = infoH
        infoBgH = infoH + infoBgH

        infoBg[i] = UIUtil.addImageView({image = ResLib.IMG_CELL_GREY_BG, touch=true, scale=true, size=cc.size(display.width, infoH), pos=cc.p(0, posY-infoBgH), parent=layer})
        infoBg[i]:setSwallowTouches(true)

        local btn = UIUtil.addImageBtn({norImg = ResLib.COM_OPACITY0, selImg = ResLib.COM_OPACITY0, disImg = ResLib.COM_OPACITY0, ah = cc.p(0,0.5), pos = cc.p(0, infoH/2), touch = true, swalTouch = false, scale9 = true, size = cc.size(display.width, infoH), listener = btnCallBack, parent = infoBg[i]})
        btn:setTag(mineUI[i].tag)

        if mineUI[i].tag == 1 or mineUI[i].tag == 3 then
            btn:setTouchEnabled(false)
        end
        if mineUI[i].tag == 3 or mineUI[i].tag == 4 then
            UIUtil.addLabelArial(mineUI[i].text, 34, cc.p(160, infoH/2), cc.p(0, 0.5), infoBg[i]):setColor(cc.c3b(160, 160, 160))
        end
        if mineUI[i].sizeH == 0 then
            infoBg[i]:setVisible(false)
        end
    end

    -- shop
    local shopText = {"授信额", "本金", "输赢"}
    local accountVal = mineMsg.players_account or {}
    local shopValue = {accountVal.line_credit or 0, accountVal.principal or 0, accountVal.win or 0}
    for i=1,3 do
        UIUtil.addLabelArial(shopText[i], 28, cc.p(display.width*((2*i-1)/6), sizeH[1]-49), cc.p(0.5, 1), infoBg[1]):setColor(ResLib.COLOR_YELLOW1)
        UIUtil.addLabelArial(shopValue[i], 40, cc.p(display.width*((2*i-1)/6), 55), cc.p(0.5, 0), infoBg[1])
        if i<3 then
            local drawNode = cc.DrawNode:create()
            infoBg[1]:addChild(drawNode)
            local posX = display.width*(i/3)
            local posY = sizeH[1]/2+58/2
            drawNode:drawSegment(cc.p(posX, posY), cc.p(posX, posY-58/2), 1, cc.c4f(39/255, 39/255, 39/255, 1))
        end
    end

    -- mine
    local stencil, mineIcon = UIUtil.createCircle(ResLib.USER_HEAD, cc.p(80, sizeH[2]/2), infoBg[2], ResLib.CLUB_HEAD_STENCIL_200, 0.6)
    -- 下载头像
    if mineMsg.headimg ~= ""  then
        local url = mineMsg.headimg
        local function funcBack( path )
            local function onEvent(event)
                if event == "exit" then
                    return
                end
            end
            mineIcon:registerScriptHandler(onEvent)
            mineIcon:setTexture(path)
        end
        ClubModel.downloadPhoto(funcBack, url, true)
    end
    local userName = StringUtils.getShortStr(mineMsg.username, LEN_NAME)
    local labelName = UIUtil.addLabelArial(userName, 36, cc.p(160, sizeH[2]/2+20), cc.p(0, 0.5), infoBg[2]):setColor(cc.c3b(160, 160, 160))
    -- 性别
    local sex_sp = UIUtil.addPosSprite("user/user_icon_sex_female.png", cc.p(labelName:getPositionX()+ labelName:getContentSize().width+10, labelName:getPositionY()), infoBg[2], cc.p(0, 0.5))
    local sexImg = DZConfig.getSexImg(tonumber(mineMsg.sex))
    sex_sp:setTexture(sexImg)

    -- 国家
    local country = DZConfig.getCountryById(mineMsg.countryid or 2)
    local countrySp = cc.Sprite:createWithSpriteFrameName("0"..country.id..".png")
    countrySp:setAnchorPoint(cc.p(0, 0.5))
    countrySp:setPosition(cc.p(sex_sp:getPositionX()+ sex_sp:getContentSize().width+5, sex_sp:getPositionY()))
    countrySp:setScale(0.45)
    infoBg[2]:addChild(countrySp)

    local signDes = nil
    if mineMsg.personsign == "" then
        signDes = "您还没有签名哦！"
        -- signDes = "HHHHHHHHHHKKKKKKKKKKKMMMMMMMMMMDDDDDDDDDDGGGGGGGGGGWWWWWWWWUQ"
    else
        signDes = StringUtils.getShortStr(mineMsg.personsign, LEN_DES)
    end
    local labelDes = cc.Label:createWithSystemFont(signDes, "Arial", 24, cc.size(display.width-136*2, 65), cc.TEXT_ALIGNMENT_LEFT, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
        :addTo(infoBg[2])
    labelDes:setLineBreakWithoutSpace(true)
    labelDes:setClipMarginEnabled(true)
    labelDes:setDimensions(display.width-136*2,75)
    labelDes:setColor(cc.c3b(160, 160, 160))
    labelDes:setPosition(cc.p(160, labelName:getPositionY()-10 ))
    labelDes:setAnchorPoint(cc.p(0,1))
    UIUtil.addPosSprite(ResLib.BTN_BACK_RIGHT, cc.p(display.width-20, sizeH[2]/2), infoBg[2], cc.p(1, 0.5))

    -- account
    UIUtil.addPosSprite("user/mine_icon_account.png", cc.p(80, sizeH[3]/2), infoBg[3], cc.p(0.5, 0.5))
    local userID = Single:playerModel():getPNumber()
    UIUtil.addLabelArial(userID, 32, cc.p(display.width-20, sizeH[3]/2), cc.p(1, 0.5), infoBg[3]):setColor(cc.c3b(85, 85, 85))

    -- setting
    UIUtil.addPosSprite("user/mine_icon_set.png", cc.p(80, sizeH[4]/2), infoBg[4], cc.p(0.5, 0.5))
    UIUtil.addPosSprite(ResLib.BTN_BACK_RIGHT, cc.p(display.width-20, sizeH[4]/2), infoBg[4], cc.p(1, 0.5))

end

function MineLayer.updateShop(  )
    mineMsg = MineCtrol.getMineInfo()
    
    diamondNum:setString(mineMsg.diamonds)
    scoreNum:setString(mineMsg.scores)
end

function MineLayer:buildRedPoint(  )

    -- 我的奖励
    NoticeCtrol.setNoticeNode( POS_ID.POS_50002, redPoint_bg[1] )

    -- 好友
    NoticeCtrol.setNoticeNode( POS_ID.POS_10002, redPoint_bg[3] )

    -- 战队
    NoticeCtrol.setNoticeNode( POS_ID.POS_100002, redPoint_bg[4] )

    -- 联盟
    NoticeCtrol.setNoticeNode( POS_ID.POS_30002, redPoint_bg[5] )

    Notice.registRedPoint( 1 )
    Notice.registRedPoint( 3 )
    Notice.registRedPoint( 7 )
    Notice.registRedPoint( 10 )
end

-- 各模块回调函数
function MineLayer:callFunc( sender )
    local tag = sender:getTag()
    print(tag)
    -- {101, 102, 103, 104, 105, 106, 107, 108}
    print(tag)
    if tag == 101 then
        local mineAward = require("mine.MineAward")
        local layer = mineAward:create()
        self:addChild(layer, 1)
        layer:createLayer() 
    elseif tag == 102 then
        print('好友')
        MineCtrol.dataStatFriendList(function (  )
            local MyFriend = require('friend.FriendList')
            local layer = MyFriend:create()
            self:addChild(layer, 1)
            layer:createLayer()
        end)
    elseif tag == 103 then
        self:IntoResult()
    elseif tag == 104 then
        print("战队")
        MineCtrol.judgeTeam( function ( tab )
            if tab == 0 then
                MineCtrol.editInfo({exist_team = 0})
                local MineTeam = require("mine.MineTeam")
                local layer = MineTeam:create()
                self:addChild(layer, 1)
                layer:createLayer( 0 )
            else
                MineCtrol.editInfo({exist_team = tab[1].team_id})
                MineCtrol.dataStatTeam( tab[1].team_id, function ( data )
                    local MineTeam = require("mine.MineTeam")
                    local layer = MineTeam:create()
                    self:addChild(layer, 1)
                    layer:createLayer( 2, data )
                end )
            end
        end )
    elseif tag == 105 then
        print("联盟")
        self:IntoUnion()
    elseif tag == 106 then
        print("收藏")
    elseif tag == 107 then
        print("小游戏")
        sender:setTouchEnabled(false)
        NoticeCtrol.removeNoticeNode()
        local GamblingLayer = require('gambling.GamblingLayer')
        GamblingLayer.showGambling()
    elseif tag == 108 then
        print("设置")
        local setting = require("mine.SettingLayer")
        local layer = setting:create()
        self:addChild(layer,2)
        layer:createLayer()
    end
end

function MineLayer:IntoResult(  )
    
    local Result = require("result.ResultScene")
    Result.startScene()

end

--[[
    10.6.0 later
]]

function MineLayer:IntoUnion()
    local entryUnionHanlder = function()

        local isLookup = UnionCtrol.isMatchAccess(UnionCtrol.access_mine_lookup)
        local isAllowCreate = UnionCtrol.isMatchAccess(UnionCtrol.access_mine_create)
        local isNothing = UnionCtrol.isMatchAccess(UnionCtrol.access_mine_nothing)
         print("isLook",isLookup,"isAllowCreate", isAllowCreate, "isNothing", isNothing)
        if isNothing or isAllowCreate then 
             --没有联盟id 查看是否允许创建
            ClubCtrol.setClubInfo(UnionCtrol.getUnionInfo())
            local _new = require("club.ClubNew")
            local layer = _new:create()
            self:addChild(layer)
            layer:createLayer("union")

        elseif isLookup then 
            local DashBoardLayer = require("union.DashBoardLayer")
            DashBoardLayer.show(self, { from = UnionCtrol.mine_union})
        end
    end
   
    UnionCtrol.requestDetailUnion(entryUnionHanlder)
end

function MineLayer:createLayer(  )
    _mine = self

    local listenerCustom = cc.EventListenerCustom:create("C_Event_update_MineInfo", updateMineInfo)  
    local customEventDispatch = cc.Director:getInstance():getEventDispatcher()
    customEventDispatch:addEventListenerWithFixedPriority(listenerCustom, 1)
    self.listener = listenerCustom

    --退出后移除注册的事件
    local function onNodeEvent(event)
        if event == "enter" then
        elseif event == "exit" then
            if(self.listener ~= nil) then
                local customEventDispatch = cc.Director:getInstance():getEventDispatcher()
                customEventDispatch:removeEventListener(self.listener)
            end
            NoticeCtrol.removeNoticeById(60001)
            NoticeCtrol.removeNoticeById(50001)
            NoticeCtrol.removeNoticeById(50002)
            NoticeCtrol.removeNoticeById(10001)
            NoticeCtrol.removeNoticeById(10002)
            NoticeCtrol.removeNoticeById(20001)
            NoticeCtrol.removeNoticeById(30001)
            NoticeCtrol.removeNoticeById(30002)
            NoticeCtrol.removeNoticeById(100001)
            NoticeCtrol.removeNoticeById(100002)
        end
    end
    self:registerScriptHandler(onNodeEvent)

    self:addLayerOfTable()
    UIUtil.setBgScale(ResLib.MAIN_BG, display.center, self)
    Bottom:getInstance():addBottom(3, self)--添加下栏5个导航按钮

    self:init()
    
    local node = cc.Node:create()
    node:setPosition(cc.p(0,0))
    node:setName("mine")
    self:addChild(node)

    UIUtil.addTopBar({title = "我", parent = self})

    self:buildLayer()
end

function MineLayer:init(  )
    viewSize = nil
    mineMsg = {}

    scrollView = nil
    btnBg = {}

    diamondNum = nil
    scoreNum = nil
    redPoint_bg = {}
end

return MineLayer