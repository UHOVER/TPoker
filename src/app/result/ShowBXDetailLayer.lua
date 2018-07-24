--
-- Author: Your Name
-- Date: 2016-10-28 18:01:25
--查看保险池列表层
--

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
    --newdz
    StringUtils.setDZAdapter()
end

local g_self = nil
--类
local ShowBXDetailLayer = class("ShowBXDetailLayer", function ()
    return cc.Node:create()
end)

--传入保险的数据data 格式如下
--[[
local bxData = {
  
            ["insurance_detail"] = {
                [1] = {
                    ["hand_num"] = 1,--手牌
                    ["insurance_bet"] = 266,--投保额
                    ["insurance_change"] = -266--赔付额
                },

                [2] = {
                    ["hand_num"] = 3,
                    ["insurance_bet"] = 66,
                    ["insurance_change"] = 330
                }
            }
          
        }
]]

--name 是谁都保险明细
function ShowBXDetailLayer:ctor(data, name)
	self.m_root = nil
	self.m_titleName = name
    self.m_data = data
    self.m_CELL_RES = "scene/ShowBXDetailCell.csb"
    self:init()
end

------------------------btn-------------------------------
local function handleReturn(sender)
	--require("main.AllGame"):rebackScreen()
	g_self:removeFromParent()
	g_self = nil
end


------------------------------------------------------------end


function ShowBXDetailLayer:init()

	g_self = nil
	g_self = self

    --初始化层
    local runScene = cc.Director:getInstance():getRunningScene()
    runScene:addChild(self, StringUtils.getMaxZOrder(runScene))

    local cs = cc.CSLoader:createNodeWithVisibleSize("scene/ShowBXDetailLayer.csb")
    self:addChild(cs)
    self.m_root = cs:getChildByName("Panel_root")
    
    --一些文字
    local txt = ccui.Helper:seekWidgetByName(self.m_root, "Text_nameTitle")
    txt:setString(self.m_titleName)

    --返回按钮
    local btn = ccui.Helper:seekWidgetByName(self.m_root, "Button_back")
    btn:touchEnded(handleReturn)

    --滚动层
    local slayer = ccui.Helper:seekWidgetByName(self.m_root, "ScrollView_list")
    local tcell = cc.CSLoader:createNodeWithVisibleSize(self.m_CELL_RES)
    local tcellRoot = tcell:getChildByName("Panel_root")
    slayer:setInnerContainerSize(cc.size(slayer:getInnerContainerSize().width, tcellRoot:getContentSize().height*(#self.m_data)))
    slayer:setScrollBarEnabled(false)
    local theight = slayer:getInnerContainerSize().height

--[[
    print("maxContainerOffsety="..view:maxContainerOffset().y)
    print("minContainerOffsety="..view:minContainerOffset().y)
    print("getContentOffsety="..view:getContentOffset().y)
    print("ContentSizeH="..view:getContentSize().height)
    print("viewSizeH="..view:getViewSize().height)
    print("ContainerSizeH="..view:getContainer():getContentSize().height)
]]

    --初始化列表
    for i = 1, #self.m_data do
        local cell = cc.CSLoader:createNodeWithVisibleSize(self.m_CELL_RES)
        slayer:addChild(cell)
        local sRoot = cell:getChildByName("Panel_root")
        cell:setPositionY(theight - (sRoot:getContentSize().height - 2)*i)

        ccui.Helper:seekWidgetByName(sRoot, "Text_sp"):setString(self.m_data[i]["hand_num"])
        ccui.Helper:seekWidgetByName(sRoot, "Text_tbe"):setString(self.m_data[i]["insurance_bet"])
        
        local bxtxt = ccui.Helper:seekWidgetByName(sRoot, "Text_pfe")
        local tnumber = tonumber(self.m_data[i]['insurance_change'])
        local tcolor = cc.c3b(255,255,255)
        
        if(tnumber > 0) then
            tcolor = cc.c3b(255,0,0)
        elseif(tnumber < 0) then
            tcolor = cc.c3b(0,255,0)
        end

        if(tnumber > 0) then
            bxtxt:setString("+"..self.m_data[i]["insurance_change"])
        else
            bxtxt:setString(self.m_data[i]["insurance_change"])
        end
        
        bxtxt:setColor(tcolor)
        
    end

    --适配处理
    --oldkc
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
    --newdz
    local realx = StringUtils.setKCAdapter()
    if realx then
        self:setPosition(cc.p(realx, 0))
    end
end


--数据格式影响：GResult.lua和
function ShowBXDetailLayer:create(data, name)
    return ShowBXDetailLayer.new(data, name)
end

return ShowBXDetailLayer