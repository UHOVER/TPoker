--
-- Author: Your Name
-- Date: 2016-10-28 18:01:25
--联盟查看管理员
--

local g_self = nil

---适配回复
local function rebackScreen( )
    -- local framesize = cc.Director:getInstance():getOpenGLView():getFrameSize()
    -- local scaleX, scaleY = framesize.width / 750, framesize.height / 1334
    -- local width, height = framesize.width, framesize.height

    -- width = framesize.width / scaleX-----
    -- height = framesize.height / scaleX----

    -- local tframesize = cc.Director:getInstance():getOpenGLView():getFrameSize()
    -- local ratio = tframesize.height/tframesize.width
    -- print("exit----rrrr=="..ratio)
    -- if ratio >= 1.5 then
    --     cc.Director:getInstance():getOpenGLView():setDesignResolutionSize(width, height, cc.ResolutionPolicy.NO_BORDER)
    -- else
        
    -- end
    StringUtils.setDZAdapter()
    -- body
end

------------------------btn-------------------------------
--返回按钮
local function handleReturn(sender)
    g_self:removeFromParent()
    g_self = nil
    rebackScreen()
end

--tap按钮
local function showWLayer(sender)
    if(sender.s == g_self.m_isSelect) then
        return
    end

    g_self.m_isSelect = sender.s

    if(g_self.m_isSelect == 1) then
        g_self:showLayer1()
    elseif(g_self.m_isSelect == 2) then
        g_self:showLayer2()
    end

end

--显示联盟俱乐部管理员查看界面
local function showUCKLayer(sender)
    
end

--类
local UnionCheckLayer = class("UnionCheckLayer", function ()
    return cc.Node:create()
end)

--tData传入选择该管理员的参数信息
function UnionCheckLayer:ctor(tData)
    self.m_root = nil
    self.m_listView1 = nil--审核通过的列表
    self.m_listView2 = nil--俱乐部列表

    self.m_data = tData--存储列表
    self.m_isSelect = 1--1授权通过界面 2-审核俱乐部
    self.m_iBtn1 = nil--授权通过按钮
    self.m_iBtn2 = nil--审核俱乐部

    self:init()
end

function UnionCheckLayer:init()
    g_self = nil
    g_self = self
    local cs = cc.CSLoader:createNodeWithVisibleSize("scene/UnionCheckLayer.csb")
    self:addChild(cs)
    self.m_root = cs:getChildByName("Panel_root")

    ccui.Helper:seekWidgetByName(self.m_root, "Panel_root1"):setVisible(false)
    ccui.Helper:seekWidgetByName(self.m_root, "Panel_root2"):setVisible(false)

    --列表审核的人
    self.m_listView1 = ccui.Helper:seekWidgetByName(self.m_root, "ListView_1")
    self.m_listView1:setBounceEnabled(true)
    self.m_listView1:setScrollBarEnabled(false)

    --列表俱乐部
    self.m_listView2 = ccui.Helper:seekWidgetByName(self.m_root, "ListView_2")
    self.m_listView2:setBounceEnabled(true)
    self.m_listView2:setScrollBarEnabled(false)

    --返回按钮
    local btn = ccui.Helper:seekWidgetByName(self.m_root, "Button_back")
    btn:touchEnded(handleReturn)
    
    self.m_iBtn1 = ccui.Helper:seekWidgetByName(self.m_root, "Image_shtg")
    self.m_iBtn2 = ccui.Helper:seekWidgetByName(self.m_root, "Image_sqjlb")

    self.m_iBtn1.s = 1
    self.m_iBtn2.s = 2
    self.m_iBtn1:touchEnded(showWLayer)
    self.m_iBtn2:touchEnded(showWLayer)

    self:showLayer1()


    --listView
   -- self.m_listView = ccui.Helper:seekWidgetByName(self.m_root, "ListView_1")
   -- self.m_listView:setBounceEnabled(true)
   -- self.m_listView:setScrollBarEnabled(false)

    --刷新管理员列表
    --self:updateLayer()

    --适配处理
    -- local tframesize = cc.Director:getInstance():getOpenGLView():getFrameSize()
    -- local ratio = tframesize.height/tframesize.width
    -- print("rrrrrr="..ratio)
    -- if ratio >= 1.5 then
    --     print("iiiiiihhhhhh")
    --     local framesize = cc.Director:getInstance():getOpenGLView():getFrameSize()
    --     local scaleX, scaleY = framesize.width / 750, framesize.height / 1334
    --     local width = framesize.width / scaleY
    --     local height = framesize.height / scaleY
    --     cc.Director:getInstance():getOpenGLView():setDesignResolutionSize(width, height, cc.ResolutionPolicy.NO_BORDER)
    --     local realx = (framesize.width / scaleY - 750)*0.5
    --     self:setPosition(cc.p(realx, 0))
    -- else
        
    -- end
    local realx = StringUtils.setKCAdapter()
    if realx then
        self:setPosition(cc.p(realx, 0))
    end
end

function UnionCheckLayer:showLayer1()
    self.m_iBtn1:loadTexture("common/m_sqtgS.png")
    self.m_iBtn2:loadTexture("common/m_shjlb.png")
    ccui.Helper:seekWidgetByName(self.m_root, "Panel_root1"):setVisible(true)
    ccui.Helper:seekWidgetByName(self.m_root, "Panel_root2"):setVisible(false)
    self:updateLayer()
end

function UnionCheckLayer:showLayer2()
    self.m_iBtn1:loadTexture("common/m_sqtg.png")
    self.m_iBtn2:loadTexture("common/m_shjlbS.png")
    ccui.Helper:seekWidgetByName(self.m_root, "Panel_root1"):setVisible(false)
    ccui.Helper:seekWidgetByName(self.m_root, "Panel_root2"):setVisible(true)
    self:updateClubMList()
end

function UnionCheckLayer:updateLayer()

    --初始化layer
    ccui.Helper:seekWidgetByName(self.m_root, "Text_rS"):setString("")
    ccui.Helper:seekWidgetByName(self.m_root, "Text_rC"):setString("")
    ccui.Helper:seekWidgetByName(self.m_root, "Image_Aflag"):setVisible(false)
    


    --初始化管理员列表
    local function response(data)
        print("---23334444---")
        dump(data)

        --"access_num": 1,
        --"access_times_r": 1,
        --"access_times_a": 0,
        --"access_invite_code": 0,
        if( data == nil ) then
            return
        end

        self.m_yqCode = data.access_invite_code
        ccui.Helper:seekWidgetByName(self.m_root, "Text_rS"):setString(data.access_num)

        local sTxt = tostring(data.access_times_r)
        if(tonumber(data.access_times_a) > 0) then
            sTxt = sTxt.."+"..tostring(data.access_times_a)
            ccui.Helper:seekWidgetByName(self.m_root, "Image_Aflag"):setVisible(true)
        end

        local tLabel = ccui.Helper:seekWidgetByName(self.m_root, "Text_rC")
        tLabel:setString(sTxt)
        ccui.Helper:seekWidgetByName(self.m_root, "Image_Aflag"):setPositionX(tLabel:getPositionX() + tLabel:getContentSize().width + 5)
        
        local tData = data.players
--[[
        tData = {

            [1] = {
                ["uid"] = "941",
                ["get_back"] = "1000",
                ["user_name"] = "3ddfsdff",
                ["r_num"] = 0,
                ["a_num"] = 0,
                ["table"] = 3,
            },

            [2] = {
                ["uid"] = "143",
                ["get_back"] = "32000",
                ["user_name"] = "ffff",
                ["r_num"] = 100,
                ["a_num"] = 0,
                ["table"] = 1,

            },

            [3] = {
                ["uid"] = "43",
                ["get_back"] = "0",
                ["user_name"] = "dfgdf9990",
                ["r_num"] = 0,
                ["a_num"] = 1,
                ["table"] = 0,
            },

            [4] = {
                ["uid"] = "43",
                ["get_back"] = "3340",
                ["user_name"] = "user99",
                ["r_num"] = 11,
                ["a_num"] = 110,
                ["table"] = 2,
            },

        }
]]

        if(tData[1] == "") then
            --print("sdjfkhsdkjfh")
            return
        end

        for i = 1, #tData do    
            local cell = cc.CSLoader:createNodeWithVisibleSize("scene/CheckManagerLayerCell.csb")
            local tRoot = cell:getChildByName("Panel_root")
            tRoot:setTouchEnabled(true)
            local tNameL = ccui.Helper:seekWidgetByName(tRoot, "Text_name")
            ccui.Helper:seekWidgetByName(tRoot, "Text_name"):setString(tData[i].user_name)
            ccui.Helper:seekWidgetByName(tRoot, "Text_tgrno"):setString(self.m_yqCode)
            

            --战绩界面记分牌显示带入量，不显示牌桌
            if(self.m_stype == 1) then
                ccui.Helper:seekWidgetByName(tRoot, "Text_pz"):setVisible(false)
                ccui.Helper:seekWidgetByName(tRoot, "Text_jfp"):setString(tData[i].spense)
            --其他界面记分牌显示游戏内记分牌， 显示牌桌
            else
                ccui.Helper:seekWidgetByName(tRoot, "Text_pz"):setString("牌桌"..tData[i].table)
                ccui.Helper:seekWidgetByName(tRoot, "Text_jfp"):setString(tData[i].get_back)
            end

            if(tonumber(tData[i].table) == 0) then
                ccui.Helper:seekWidgetByName(tRoot, "Text_pz"):setVisible(false)
            end

            --先判断有几种情况0-都不存在，1-两个都存在，2-存在增购，3-存在重购
            --["add_on"]
            --["rebuy_num"]
            local tCase = 0
            if(tonumber(tData[i]['a_num']) > 0 and tonumber(tData[i]['r_num']) > 0) then
                tCase = 1
            elseif(tonumber(tData[i]['a_num']) > 0 and tonumber(tData[i]['r_num']) == 0) then
                tCase = 2
            elseif(tonumber(tData[i]['a_num']) == 0 and tonumber(tData[i]['r_num']) > 0) then
                tCase = 3
            end

            --R,A 1-两个都存在
            if(tCase == 1) then

                local imageViewA = ccui.ImageView:create()
                --imageViewA:setScale9Enabled(true)
                imageViewA:loadTexture("result/r_s9.png")
                --imageViewA:setContentSize(cc.size(200, 85))
                imageViewA:setPosition(cc.p(tNameL:getPositionX() + tNameL:getContentSize().width + imageViewA:getContentSize().width/2 + 10, tNameL:getPositionY()))
                imageViewA:setColor(cc.c3b(26,255,150))
                UIUtil.addLabelArial("A", 30, cc.p(imageViewA:getContentSize().width/2, imageViewA:getContentSize().height/2), cc.p(0.5, 0.5), imageViewA, cc.c3b(25,25,25))
                tRoot:addChild(imageViewA)


                local imageViewR = ccui.ImageView:create()
                local tLen = string.len(tostring(tData[i]['r_num']))
                imageViewR:setScale9Enabled(true)
                imageViewR:loadTexture("result/r_s9.png")
                imageViewR:setContentSize(cc.size(imageViewA:getContentSize().width + tLen*8, imageViewA:getContentSize().height))
                imageViewR:setPosition(cc.p(imageViewA:getPositionX() + imageViewA:getContentSize().width/2 + imageViewR:getContentSize().width/2 + 10, tNameL:getPositionY()))
                imageViewR:setColor(cc.c3b(252,215,54))
                UIUtil.addLabelArial("R", 30, cc.p(imageViewA:getContentSize().width/2, imageViewR:getContentSize().height/2), cc.p(0.5, 0.5), imageViewR, cc.c3b(25,25,25))
                UIUtil.addLabelArial(tData[i]['r_num'], 15, cc.p(imageViewA:getContentSize().width/2 + 10, imageViewR:getContentSize().height/2 - 10), cc.p(0.0, 0.5), imageViewR, cc.c3b(25,25,25))
                tRoot:addChild(imageViewR)
            --2-存在增购A
            elseif(tCase == 2) then
                local imageViewA = ccui.ImageView:create()
                --imageViewA:setScale9Enabled(true)
                imageViewA:loadTexture("result/r_s9.png")
                --imageViewA:setContentSize(cc.size(200, 85))
                imageViewA:setPosition(cc.p(tNameL:getPositionX() + tNameL:getContentSize().width + imageViewA:getContentSize().width/2 + 10, tNameL:getPositionY()))
                imageViewA:setColor(cc.c3b(26,255,150))
                UIUtil.addLabelArial("A", 30, cc.p(imageViewA:getContentSize().width/2, imageViewA:getContentSize().height/2), cc.p(0.5, 0.5), imageViewA, cc.c3b(25,25,25))
                tRoot:addChild(imageViewA)
            --3-存在重购R
            elseif(tCase == 3) then
                local imageViewR = ccui.ImageView:create()
                local tLen = string.len(tostring(tData[i]['r_num']))
                imageViewR:setScale9Enabled(true)
                imageViewR:loadTexture("result/r_s9.png")
                local tW = imageViewR:getContentSize().width
                imageViewR:setContentSize(cc.size(imageViewR:getContentSize().width + tLen*8, imageViewR:getContentSize().height))
                imageViewR:setPosition(cc.p(tNameL:getPositionX() + tNameL:getContentSize().width + imageViewR:getContentSize().width/2 + 10, tNameL:getPositionY()))
                imageViewR:setColor(cc.c3b(252,215,54))
                UIUtil.addLabelArial("R", 30, cc.p(tW/2, imageViewR:getContentSize().height/2), cc.p(0.5, 0.5), imageViewR, cc.c3b(25,25,25))
                UIUtil.addLabelArial(tData[i]['r_num'], 15, cc.p(tW/2 + 10, imageViewR:getContentSize().height/2 - 10), cc.p(0.0, 0.5), imageViewR, cc.c3b(25,25,25))
                tRoot:addChild(imageViewR)
            end

            -------------
            tRoot:removeFromParent()
            self.m_listView1:pushBackCustomItem(tRoot)
        end     
    end

    local tab = {}
    tab.manager_id = tostring(self.m_data.id)
    tab.mtt_id = tostring(self.m_data.m_pjID)
    MainCtrol.filterNet("getMttMatchManagerInfo", tab, response, PHP_POST)
end

function UnionCheckLayer:updateClubMList()
    local function response(data)
        for i = 1, #data do     
            local cell = cc.CSLoader:createNodeWithVisibleSize("scene/CheckClubLayerCell.csb")
            local tRoot = cell:getChildByName("Panel_root")
            tRoot:setTouchEnabled(true)
            ccui.Helper:seekWidgetByName(tRoot, "Text_name"):setString(data[i].username)

            local btn = ccui.Helper:seekWidgetByName(tRoot, "Button_check")
            btn.data = data[i]
            btn:touchEnded(showUCKLayer)

            --添加头像
            local hx, hy = ccui.Helper:seekWidgetByName(tRoot, "Image_head"):getPosition()
            ccui.Helper:seekWidgetByName(tRoot, "Image_head"):setVisible(false)
            local thead = UIUtil.addShaderHead(cc.p(hx, hy), data[i].headimg, tRoot, function(thead)end)
            thead:setScale(0.5)

            tRoot:removeFromParent()
            self.m_listView2:pushBackCustomItem(tRoot)      
        end
    end

    local tab = {}
    tab.manager_id = tostring(self.m_data.id)
    tab.mtt_id = tostring(self.m_data.m_pjID)
    MainCtrol.filterNet("getMttMatchManagerInfo", tab, response, PHP_POST)    
end

function UnionCheckLayer:create(tData)
    return UnionCheckLayer.new(tData)
end

return UnionCheckLayer