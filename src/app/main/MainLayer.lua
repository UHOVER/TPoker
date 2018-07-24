local MainLayer = class("MainLayer", require 'ui.ViewBase')
local EditTable = require 'main.EditTable'
local HallTable = require 'main.HallTable'
local MainGuide = require 'main.MainGuide'

local _cs = nil
local _tabNode = nil
local _spPanel = nil
local _cityLayer = nil--城市本地化搜索层
local _cityData = nil--城市本地化地址数据
local _isInMove = false--layer移动状态
local _mttBlindData = nil--mtt盲注数据
local _isOutMainLayer = 1--是否退出该界面1-退出了， 0-没退出

local function handleQuestion(sender)
    if MainModel:isEditStatus() then return end
    MainGuide.startGuide(_cs)

    -- print(Single:paltform():getChannelName())
    -- local function response(data)
    -- end
    -- local tab = {}
    -- tab['mtt_id'] = 816
    -- tab['count'] = 6
    -- MainCtrol.filterNet('mttTest', tab, response, PHP_POST)
end

--显示搜索城市层
local function showCityLayer(sender)

    if(_isInMove == true) then
        return
    end

    _cityLayer:initData(_cityData)
    _isInMove = true

    local tS = sender
    _cityLayer:stopAllActions()
    _cityLayer:runAction( cc.Sequence:create( 
        cc.EaseOut:create(cc.MoveTo:create(0.3, cc.p(0, _cityLayer:getPositionY() )), 2.5),
        cc.CallFunc:create( 
            function(sender)
                _isInMove = false
            end)
        ) )


    --local testly = require('main.ZhanDui'):create({})
    --cc.Director:getInstance():getRunningScene():addChild(testly, 9999999)
    --local testly = require('main.UnionCheckClubMangerLayer'):create({})
    --cc.Director:getInstance():getRunningScene():addChild(testly, 9999999)
end

local function handleBuild(sender)
    _cs:getChildByName('btnBuild'):setEnabled(false)
    _cs:getChildByName('btnHall'):setEnabled(true)

    if MainModel:isEditStatus() then
        -- MainLayer:switchEditBuild(1)
    else
        MainLayer:switchBuild(3, _spPanel) -- convert 1 to 3
    end
end

local function handleHall(sender)
    _cs:getChildByName('btnHall'):setEnabled(false)
    _cs:getChildByName('btnBuild'):setEnabled(true)

    if MainModel:isEditStatus() then
        -- MainLayer:switchEditHall(1)
    else
        MainLayer:switchHall(3, _spPanel)-- convert 1 to 3
    end
end


function MainLayer:createLayer(isEnterHall)
    _isOutMainLayer = 0
    MainModel:setEditStatus(false)

    UIUtil.setBgScale(ResLib.GAME_BG, display.center, self)
    local cs = cc.CSLoader:createNodeWithVisibleSize(ResLib.MAIN_CSB)
    self:addChild(cs)
    _cs = cs

    -- 添加Bottom
    Bottom:getInstance():addBottom(1, _cs)

    _tabNode = cc.Node:create()
    _cs:addChild(_tabNode)


    --btn
    local imgTop = cs:getChildByName('imgTop')
    local btnBuild = cs:getChildByName('btnBuild')
    local btnHall = cs:getChildByName('btnHall')
    local btnBuildOpacity = cs:getChildByName('btnBuildOpacity')
    local btnHallOpacity = cs:getChildByName('btnHallOpacity')
    btnBuildOpacity:setVisible(false)
    btnHallOpacity:setVisible(false)
    btnBuild:setVisible(false)
    btnHall:setVisible(false)
    imgTop:getChildByName('Text_cityName'):setVisible(false)
    imgTop:getChildByName('Button_showCityLayer'):setVisible(false)
    -- imgTop:setPositionY(display.height-imgTop:getContentSize().height)
    imgTop:setPositionY(display.height-130)
    --滑动模版
    _spPanel = nil
    _spPanel = cs:getChildByName('Panel_SpuerPageTable')
    _spPanel:setPositionY(_spPanel:getPositionY() + 100)
    _spPanel:setVisible(true)

    imgTop:getChildByName('btnQuestion'):touchEnded(handleQuestion)
    -- btnBuild:touchEnded(function()end)
    -- btnHall:touchEnded(function()end)

    local befy = btnBuild:getPositionY()
    local arrs = {imgTop, btnBuild, btnHall, _spPanel}
    MainHelp.mainAdaptation(arrs)

    --隐形btn
    local aftY1 = btnBuild:getPositionY()
    local aftY2 = btnHall:getPositionY()
    btnHallOpacity:setPositionY(aftY1)
    btnBuildOpacity:setPositionY(aftY2)

    -- 打开定位服务
    require("platform.Platform"):getInstance():callGPSCity()
    
    --[[
    --引导
    MainGuide.setTwoBtn(btnBuild, btnHall)


    --创建移动搜索City层 
    _isInMove = false

    --获取gps城市数据
    if(_cityData == nil) then
        require("platform.Platform"):getInstance():callGPSCity() 
    end
   
    if(_cityData == nil) then
        _cityData = "北京"--{["name"]="北京市", ["code"]="110000", ["t1Idx"] = 0, ["t2Idx"] = 1, ["tposY1"] = -1240, ["tposY2"] = -340}--城市本地化地址数据ss市省份，0代表没省份
    end

    self:setCityValue(_cityData)
    
    _cityLayer = require("main.CityLayer"):create()
    _cityLayer:setPositionX(-1000)
    _cityLayer:initData(_cityData)
    self:addChild(_cityLayer)

    --搜索btn
    imgTop:getChildByName('Button_showCityLayer'):touchEnded(showCityLayer)
    local cityLabel = imgTop:getChildByName('Text_cityName')
    cityLabel:touchEnded(showCityLayer)
    imgTop:getChildByName('Button_showCityLayer'):setPositionX(cityLabel:getPositionX() + cityLabel:getContentSize().width + 20)
    --]]

    --初始化大厅mtt盲注数据
    if(_mttBlindData == nil) then
        --发送消息
        local function response(data)
            _mttBlindData = data
        end

        local tab = {}
        -- MainCtrol.filterNet("game_hall/MttBlind", tab, response, PHP_POST)
    end

    --置空一些对象
    local function onEvent(event)
        if event == "exit" then
            print("hhhhhhhh~~~~~~~~~~~")
            --_cs = nil
            -- NoticeCtrol.removeNoticeById( POS_ID.POS_80001 )
            -- NoticeCtrol.removeNoticeById( POS_ID.POS_90001 )
            _isOutMainLayer = 1
        end
    end
    
    self:registerScriptHandler(onEvent)

    -- btnBuildOpacity:touchEnded(function()
    --     handleBuild(btnBuild)
    -- end)
    -- btnHallOpacity:touchEnded(function()
    --     handleHall(btnHall)
    -- end)
    
    -- immediate enter foreign ui
    _spPanel:setVisible(true)
    _tabNode:removeAllChildren()
    HallTable.createPublicRaceMtt(_tabNode, 3, _spPanel)
    -- if isEnterHall then
    --     handleHall(btnHall)
    -- else
    --     handleBuild(btnBuild)
    -- end

    -- btnBuild:setPositionY(display.height-130)
    -- btnHall:setPositionY(display.height-130)
    -- btnBuildOpacity:setPositionY(display.height-130)
    -- btnHallOpacity:setPositionY(display.height-130)
    --btnBuildOpacity:setLocalZOrder(10)
    --btnHallOpacity:setLocalZOrder(10)

    -- imgTop:setPositionY(display.height-130)

    -- local bRed_bg = UIUtil.addImageView({image = ResLib.COM_OPACITY0, touch=false, scale=true, size=_cs:getChildByName('btnBuild'):getContentSize(), pos=cc.p(_cs:getChildByName('btnBuild'):getPosition()), ah=cc.p(1, 1), parent= _cs})
    -- local hRed_bg = UIUtil.addImageView({image = ResLib.COM_OPACITY0, touch=false, scale=true, size=_cs:getChildByName('btnHall'):getContentSize(), pos=cc.p(_cs:getChildByName('btnHall'):getPosition()), ah=cc.p(0, 1), parent= _cs})
    --- 红点提示
    -- NoticeCtrol.setNoticeNode( POS_ID.POS_80001, bRed_bg )
    -- NoticeCtrol.setNoticeNode( POS_ID.POS_90001, hRed_bg )
    -- Notice.registRedPoint( 8 )
    -- Notice.registRedPoint( 9 )
end

--返回mtt盲注数据
function MainLayer:getBlindData()
    return _mttBlindData
end

--修改地址信息
function MainLayer:setCityValue(cdata)

    _cityData = cdata
    print("dasdas9999777=="..cdata)

    if(cdata == "") then
        local spm = Single:playerModel()
        _cityData = spm:getPCity()

        print("asdajksh999====".._cityData)
    end
    
    if(_cityData == "北京市") then
        _cityData = "北京"
    elseif(_cityData == "上海市") then
        _cityData = "上海"
    elseif(_cityData == "天津市") then
        _cityData = "天津"
    elseif(_cityData == "重庆市") then
        _cityData = "重庆"
    end
    
    if(_isOutMainLayer == 0) then
        if(_cs ~= nil) then
            local imgTop = _cs:getChildByName('imgTop')
            imgTop:getChildByName('Text_cityName'):setString(_cityData)

            --修改标志位置
            imgTop:getChildByName('Button_showCityLayer'):touchEnded(showCityLayer)
            local cityLabel = imgTop:getChildByName('Text_cityName')
            imgTop:getChildByName('Button_showCityLayer'):setPositionX(cityLabel:getPositionX() + cityLabel:getContentSize().width + 20)
        end
    end

    -- 组建牌局红点提示(先移除本地记录再重新获取)
    
    -- local cityCode = NoticeCtrol.getLocalCity()
    -- local cityLayer = require("main.CityLayer")
    -- NoticeCtrol.setLocalCity(cityLayer.getSiteOfCode(_cityData))

    -- if tostring(cityCode) ~= tostring(cityLayer.getSiteOfCode(_cityData)) then
    --     Notice.clearMessageByType(8)
    --     Notice.requestBuildCard(true, nil, 0)
    -- end 

    --大红点
    -- local myEvent = cc.EventCustom:new("C_Event_Update_MTT_CARD_NUM")
    -- local customEventDispatch = cc.Director:getInstance():getEventDispatcher()
    -- customEventDispatch:dispatchEvent(myEvent)
end

function MainLayer:switchBuild(idx, spPanel)
    _spPanel:setVisible(true)
    _tabNode:removeAllChildren()
    -- HallTable.createBuild(_tabNode, idx, spPanel)
    HallTable.createPublicRaceMtt(_tabNode, idx, spPanel)
end
function MainLayer:switchHall(idx, spPanel)
    _spPanel:setVisible(true)
    _tabNode:removeAllChildren()
    -- HallTable.createHall(_tabNode, idx, spPanel)
    HallTable.createPublicRaceMtt(_tabNode, idx, spPanel)
end

function MainLayer:switchEditBuild(idx)
    -- _spPanel:setVisible(false)
    -- _tabNode:removeAllChildren()
    -- UIUtil.addImageView({image = ResLib.TABLEVIEW_CELL_BG_NOLINE, touch=true, scale=true, size=cc.size(display.width, 200), pos=cc.p(0,0), ah=cc.p(0,0), parent=_tabNode})
    -- EditTable.createEditBuild(_tabNode, idx)
    local currScene = cc.Director:getInstance():getRunningScene()
    local SetCards = require("common.SetCards")
    local layer = SetCards:create()
    currScene:addChild(layer, StringUtils.getMaxZOrder(currScene))
    layer:createLayer(idx, "person")
end

function MainLayer:switchEditHall(idx)
    self.fuck()
    _spPanel:setVisible(false)
    _tabNode:removeAllChildren()
    UIUtil.addImageView({image = ResLib.TABLEVIEW_CELL_BG_NOLINE, touch=true, scale=true, size=cc.size(display.width, 200), pos=cc.p(0,0), ah=cc.p(0,0), parent=_tabNode})
    EditTable.createEditHall(_tabNode, idx)
end

--获取城市编码code
function MainLayer:getCityCode()
    return _cityLayer.getSiteOfCode(_cityData)
end

function MainLayer:getSpPanel()
    return _spPanel
end

function MainLayer:ctor()
end
return MainLayer