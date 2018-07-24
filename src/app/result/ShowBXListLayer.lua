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
    -- body
    StringUtils.setDZAdapter()
end

local g_self = nil
--类
local ShowBXListLayer = class("ShowBXListLayer", function ()
    return cc.Node:create()
end)

--传入保险的数据data 格式如下
--[[
local bxData = {
        ["name"] = data1['myName'],--组建该局的玩家的名字
        ["from"] = data1['pokerFrom'],--来自哪个牌局
        --各个玩家保险池情况
        ["dataList"] = {
            [1] = {
                ["url"] = "",--头像url图片地址
                ["name"] = "",--玩家昵称
                ["poolNum"] = "",--玩家投保数量   
                ["playerID"] = "",--玩家id
                ["pid"] = ""--牌局id
            },

            [2] = {
                ["url"] = "",--头像url图片地址
                ["name"] = "",--玩家昵称
                ["poolNum"] = "",--玩家投保数量   
                ["playerID"] = "",--玩家id
                ["pid"] = ""--牌局id 
            },

            [3] = {
                ["url"] = "",--头像url图片地址
                ["name"] = "",--玩家昵称
                ["poolNum"] = "",--玩家投保数量   
                ["playerID"] = "",--玩家id
                ["pid"] = ""--牌局id   
            }
        }
    }
]]

function ShowBXListLayer:ctor(data)
	self.m_root = nil
	self.m_titleData = data--列表数据
    self.m_data = data.dataList
    self.m_CELL_RES = "scene/ShowBXListCell.csb"
    
    -- self.createWay = data['createWay']
    -- if (ResultCtrol.isUnionCreate(self.createWay)) then 
    --     self.clubname = data.clubname
    --     self.clubid = data.clubid
    -- end
    self:init()
end

------------------------btn-------------------------------
local function handleReturn(sender)
	require("main.AllGame"):rebackScreen()
	g_self:removeFromParent()
	g_self = nil
end

--查看详细按钮
local function touchDetailbtn(sender)
    print("sadasd333333")
    dump(sender.data)

    --发送消息
    local function response(data)
        print("ttttrrrrrr")
        dump(data)
        require("result.ShowBXDetailLayer"):create(data["players_insurance"], sender.data["name"].."保险明细")
    end

    local tab = {}
    tab['p_id'] = sender.data["pid"]
    tab['u_id'] = sender.data["playerID"]
    MainCtrol.filterNet("pRInsuranceDetail", tab, response, PHP_POST)
end

------------------------------------------------------------end


function ShowBXListLayer:init()

	g_self = nil
	g_self = self

    --初始化层
    local runScene = cc.Director:getInstance():getRunningScene()
    runScene:addChild(self, StringUtils.getMaxZOrder(runScene))

    local cs = cc.CSLoader:createNodeWithVisibleSize("scene/ShowBXListLayer.csb")
    self:addChild(cs)
    self.m_root = cs:getChildByName("Panel_root")
    
    --一些文字
    local txt = ccui.Helper:seekWidgetByName(self.m_root, "Text_name")
    txt:setString(self.m_titleData["name"])
    local posx = txt:getPositionX()
    posx = posx + 10 + txt:getContentSize().width
    txt = ccui.Helper:seekWidgetByName(self.m_root, "Text_from")
    txt:setString("("..self.m_titleData["from"]..")")
    txt:setPositionX(posx)

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

        ccui.Helper:seekWidgetByName(sRoot, "Text_name"):setString(self.m_data[i]["name"])
        
        local bxtxt = ccui.Helper:seekWidgetByName(sRoot, "Text_pool")
        local tnumber = tonumber(self.m_data[i]['poolNum'])
        local tcolor = cc.c3b(255,255,255)
        
        if(tnumber > 0) then
            tcolor = cc.c3b(255,0,0)
        elseif(tnumber < 0) then
            tcolor = cc.c3b(0,255,0)
        end

        if(tnumber > 0) then
            bxtxt:setString("+"..self.m_data[i]["poolNum"])
        else
            bxtxt:setString(self.m_data[i]["poolNum"])
        end
        
        bxtxt:setColor(tcolor)

        local img = ccui.Helper:seekWidgetByName(sRoot, "Image_typeFlag")
        local thead = UIUtil.addShaderHead(cc.p(0, 0), self.m_data[i]['url'], img, function(thead)end)
        thead:setScale(0.4)
        thead:setAnchorPoint(cc.p(0, 0))

        --处理查看明细按钮
        local bxtxt = ccui.Helper:seekWidgetByName(sRoot, "Button_xx")
        bxtxt.data = self.m_data[i]
        bxtxt:touchEnded(touchDetailbtn)
        
    end

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


--数据格式影响：GResult.lua和
function ShowBXListLayer:create(data)
    return ShowBXListLayer.new(data)
end

return ShowBXListLayer