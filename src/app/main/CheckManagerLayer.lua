--
-- Author: Your Name
-- Date: 2016-10-28 18:01:25
--帮助对话框
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
    --管理员界面，要回复适配 
    if(g_self.m_stype == 0) then
	   rebackScreen()
    end

    g_self:removeFromParent()
    g_self = nil
end


--类
--tdata传入点击选择的管理员参数
--stype是哪个入口进来的 0-管理员界面 1-战绩界面
local CheckManagerLayer = class("CheckManagerLayer", function ()
    return cc.Node:create()
end)

function CheckManagerLayer:ctor(tdata, stype)
	self.m_root = nil
	self.m_listView = nil--管理员列表
    self.m_data = tdata--
    self.m_yqCode = nil--邀请码
    self.m_stype = stype--是哪个入口进来的 0-管理员界面 1-战绩界面
    print("入口类型:",stype)
    self:init()
end

function CheckManagerLayer:init()
	g_self = nil
	g_self = self
    local cs = cc.CSLoader:createNodeWithVisibleSize("scene/CheckManagerLayer.csb")
    cs:setContentSize(cc.size(cs:getContentSize().width, 92))
    self:addChild(cs)
    self.m_root = cs:getChildByName("Panel_root")

    --返回按钮
    local btn = ccui.Helper:seekWidgetByName(self.m_root, "Button_back")
    btn:touchEnded(handleReturn)

    --listView
    self.m_listView = ccui.Helper:seekWidgetByName(self.m_root, "ListView_1")
    self.m_listView:setBounceEnabled(true)
    self.m_listView:setScrollBarEnabled(false)

    --战绩界面不显示牌桌
    if(self.m_stype == 1) then
        ccui.Helper:seekWidgetByName(self.m_root, "Text_11_0"):setVisible(false)
        ccui.Helper:seekWidgetByName(self.m_root, "Text_11"):setPositionX(155)
        ccui.Helper:seekWidgetByName(self.m_root, "Text_11_2"):setPositionX(610)
    end

    --刷新管理员列表
    self:updateLayer()

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
end

function CheckManagerLayer:updateLayer()

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
        
		local jfpPosx = ccui.Helper:seekWidgetByName(self.m_root, "Text_11_2"):getPositionX()
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
			return
		end

		for i = 1, #tData do	
			local cell = cc.CSLoader:createNodeWithVisibleSize("scene/CheckManagerLayerCell.csb")
			local tRoot = cell:getChildByName("Panel_root")
			tRoot:setTouchEnabled(true)
            local tNameL = ccui.Helper:seekWidgetByName(tRoot, "Text_name")
			ccui.Helper:seekWidgetByName(tRoot, "Text_name"):setString(tData[i].user_name)
            tNameL:setAnchorPoint(cc.p(0,0.5))
            --ccui.Helper:seekWidgetByName(tRoot, "Text_tgrno"):setString(self.m_yqCode) 
            ccui.Helper:seekWidgetByName(tRoot, "Text_tgrno"):setVisible(false)
            --战绩界面记分牌显示带入量，不显示牌桌
            if(self.m_stype == 1) then

                ccui.Helper:seekWidgetByName(tRoot, "Text_pz"):setVisible(false)
                local jfpPanel = ccui.Helper:seekWidgetByName(tRoot, "Text_jfp")
                jfpPanel:setString(tData[i].spense)
                jfpPanel:setPositionX(jfpPosx)
                tNameL:setPositionX(84)
            --其他界面记分牌显示游戏内记分牌， 显示牌桌
            else
                tNameL:setPositionX(20)
                ccui.Helper:seekWidgetByName(tRoot, "Text_pz"):setString("牌桌"..tData[i].table)
                ccui.Helper:seekWidgetByName(tRoot, "Text_pz"):setPositionX(373.52)
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

            local tNamePosx = tNameL:getPositionX() + tNameL:getContentSize().width * ( 1 - tNameL:getAnchorPoint().x)
            --R,A 1-两个都存在
            if(tCase == 1) then

                local imageViewA = ccui.ImageView:create()
                --imageViewA:setScale9Enabled(true)
                imageViewA:loadTexture("result/r_s9.png")
                --imageViewA:setContentSize(cc.size(200, 85))
                imageViewA:setPosition(cc.p(tNamePosx + imageViewA:getContentSize().width/2 + 10, tNameL:getPositionY()))
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
                imageViewA:setPosition(cc.p(tNamePosx + imageViewA:getContentSize().width/2 + 10, tNameL:getPositionY()))
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
                imageViewR:setPosition(cc.p(tNamePosx + imageViewR:getContentSize().width/2 + 10, tNameL:getPositionY()))
                imageViewR:setColor(cc.c3b(252,215,54))
                UIUtil.addLabelArial("R", 30, cc.p(tW/2, imageViewR:getContentSize().height/2), cc.p(0.5, 0.5), imageViewR, cc.c3b(25,25,25))
                UIUtil.addLabelArial(tData[i]['r_num'], 15, cc.p(tW/2 + 10, imageViewR:getContentSize().height/2 - 10), cc.p(0.0, 0.5), imageViewR, cc.c3b(25,25,25))
                tRoot:addChild(imageViewR)
            end

            -------------
			tRoot:removeFromParent()
			self.m_listView:pushBackCustomItem(tRoot)
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
    tab.manager_id = tostring(self.m_data.id)
    tab.mtt_id = tostring(self.m_data.m_pjID)
    MainCtrol.filterNet("getMttMatchManagerInfo", tab, response, PHP_POST)
end

function CheckManagerLayer:create(tdata, stype)
    return CheckManagerLayer.new(tdata, stype)
end

return CheckManagerLayer