--
-- Author: Your Name
-- Date: 2016-10-28 18:01:25
--战绩统计里的查看
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
    -- body
    StringUtils.setDZAdapter()
end

------------------------btn-------------------------------
--返回按钮
local function handleReturn(sender)    
    g_self:removeFromParent()
    g_self = nil
    rebackScreen()
end

--查看按钮
local function checkID(sender)
    
    print("23334444=="..sender.data.id)

    local tData = {}
    tData.id = sender.data.id
    tData.m_pjID = g_self.m_pjID

    local runScene = cc.Director:getInstance():getRunningScene()
    local testly = require("main.CheckManagerLayer"):create(tData, 1)
    runScene:addChild(testly, StringUtils.getMaxZOrder(runScene))

    local function response(data)   
        dump(data)
    end
--[[
    local tab = {}
    tab['manager_id'] = sender.data["id"]
    MainCtrol.filterNet("removeHostManager", tab, response, PHP_POST)
]]
end


--类
local CheckAllManagerLayer = class("CheckAllManagerLayer", function ()
    return cc.Node:create()
end)

function CheckAllManagerLayer:ctor(pjID)
    self.m_root = nil
    self.m_pjID = pjID--赛事牌局id
    self.m_listView = nil--管理员列表
    self.m_listView2 = nil--
    self.m_dataTable = {}--存储临时管理员数据
    self:init()
end

function CheckAllManagerLayer:init()
    g_self = nil
    g_self = self

    local bgColor = cc.LayerColor:create(cc.c3b(0,0,0))
    bgColor:setContentSize(cc.size(display.width, display.height))
    self:addChild(bgColor)
    
    local cs = cc.CSLoader:createNodeWithVisibleSize("scene/CheckAllManagerLayer.csb")
    local cssize = cs:getContentSize()
    self:addChild(cs)
    -- dump(cs:getContentSize(), "cs宽高")
    -- dump(cs:getPosition(), "cs坐标")
    self.m_root = cs:getChildByName("Panel_root")
    self.m_root:setBackGroundImageOpacity(0)

    --返回按钮
    local btn = ccui.Helper:seekWidgetByName(self.m_root, "Button_back")
    btn:touchEnded(handleReturn)

    self.m_listView2 = ccui.Helper:seekWidgetByName(self.m_root, "ListView_2")
    self.m_listView2:setBounceEnabled(true)
    self.m_listView2:setScrollBarEnabled(false)

    --刷新管理员列表
    self:updateList()


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

    -- local realx = StringUtils.setKCAdapter()
    -- if realx then
    --     self:setPosition(cc.p(realx, 0))
    -- end
    --  dump(cs:getContentSize(), ">>cs宽高")
    -- dump(cs:getPosition(), ">>cs坐标")
end

function CheckAllManagerLayer:updateList()
    --初始化管理员列表
    local function response(data)
        print("23334444")
        dump(data)

        --房主显示层 并且开启可以授权true
        self.m_listView = self.m_listView2

        self.m_listView:removeAllItems()

        --"headimg"     = ""
        --"id"          = ""
        --"invite_code" = ""
        --"is_host"     = ""
        --"username"    = ""

        if(data.managers[1].id == "") then
            return
        end

        local tData = data.managers

        table.sort(tData, function ( a, b )
            return a.is_host > b.is_host
        end)

        self.m_dataTable = tData

        for i = 1, #tData do    
            local cell = cc.CSLoader:createNodeWithVisibleSize("scene/AddManagerCreateLayerCell.csb")
            local tRoot = cell:getChildByName("Panel_root")
            tRoot:setContentSize(cc.size(tRoot:getContentSize().width, 138))
            tRoot:setTouchEnabled(true)
            ccui.Helper:seekWidgetByName(tRoot, "Text_name"):setString(tData[i].username)
            --ccui.Helper:seekWidgetByName(tRoot, "Text_ID"):setString("ID  "..tData[i].id)
            ccui.Helper:seekWidgetByName(tRoot, "Text_ID"):setString("ID  "..tData[i].u_no)
            local inviteCode = tData[i].invite_code
            if (not inviteCode or tonumber(inviteCode) <= 0 or inviteCode == "") then 
                ccui.Helper:seekWidgetByName(tRoot, "Text_yqm"):setVisible(false)
                ccui.Helper:seekWidgetByName(tRoot, "Text_m"):setVisible(false)
            else 
                ccui.Helper:seekWidgetByName(tRoot, "Text_yqm"):setString(tData[i].invite_code)
            end
            --添加头像
            local hx, hy = ccui.Helper:seekWidgetByName(tRoot, "Image_head"):getPosition()
            ccui.Helper:seekWidgetByName(tRoot, "Image_head"):setVisible(false)
            local thead = UIUtil.addShaderHead(cc.p(hx, hy), tData[i].headimg, tRoot, function(thead)end)
            thead:setScale(0.5)

            tRoot:removeFromParent()
            self.m_listView:pushBackCustomItem(tRoot)

            --查看按钮
            local dbtn = ccui.Helper:seekWidgetByName(tRoot, "Button_check")
            -- dbtn:loadTextures("common/m_fy.png", "common/m_fy.png", "common/m_fy.png")
            -- dbtn:setScale9Enabled(false)
            -- dbtn:setContentSize(cc.size(60,60))
            -- dbtn:setPosition(cc.p(719.22, 67.59))
            dbtn:touchEnded(checkID)
            dbtn.data = tData[i]

            --如果是房主
            if(data.is_host == 1) then
                ccui.Helper:seekWidgetByName(tRoot, "Button_check"):setVisible(true)
            --不是房主
            else
                --判断id是不是跟自己一样，只能分享自己的
                if(tonumber(tData[i].id) == tonumber(data.id)) then
                    ccui.Helper:seekWidgetByName(tRoot, "Button_check"):setVisible(true)
                else
                    ccui.Helper:seekWidgetByName(tRoot, "Button_check"):setVisible(false)
                end
            end
            --如果是我自己
            print("tData[i].id", tData[i].id, Single:playerModel():getId() )
            if tonumber(tData[i].id) == tonumber(Single:playerModel():getId()) then 
                tRoot:setBackGroundImage("common/s_btd_3.png")
                print("heihei --------")
            else 
                tRoot:setBackGroundImageOpacity(0)
                tRoot:setBackGroundColorOpacity(0)
            end
            local line = cc.LayerColor:create(cc.c3b(12,31,52))
            line:setContentSize(cc.size(display.width, 2))
            line:setPosition(0, 0)
            tRoot:addChild(line)

            --分享按钮不显示
            dbtn = ccui.Helper:seekWidgetByName(tRoot, "Button_fx")
            dbtn:setVisible(false)
        end     
--[[
        local Button_close = ccui.Helper:seekWidgetByName(root, "Button_close")
        Button_close:touchEnded(function(event)
                g_self.m_listDlg:removeFromParent()
                g_self.m_listDlg = nil
                end)
]]
    end

    local tab = {}
    tab.mtt_id = self.m_pjID
    MainCtrol.filterNet("getMttMatchManagersList", tab, response, PHP_POST)
end

function CheckAllManagerLayer:create(pjID)
    return CheckAllManagerLayer.new(pjID)
end

return CheckAllManagerLayer