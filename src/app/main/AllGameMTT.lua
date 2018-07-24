--
-- Author: Your Name
-- Date: 2016-10-28 18:01:25
--MTT列表
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
    StringUtils.setDZAdapter()
    -- body
end

local g_self = nil
--类
local AllGameMTT = class("AllGameMTT", function ()
    return cc.Node:create()
end)

function AllGameMTT:ctor(data)
	self.m_flag = data.flag--25-大厅mtt标志；14-组件牌局 本地化 mtt标志
	self.m_root = nil
	self.m_data = data--列表数据
	self.m_cellSize = nil
	self.m_IN_WHICH_MATCH_LIST = 1--哪个比赛列表 1欢乐赛  2我的比赛
	self.m_CELL_RES = "scene/AllGameCellMTT.csb"
	self.m_tableView = nil
	self.m_btnL = nil--欢乐赛按钮引用
	self.m_btnR = nil--我的比赛按钮引用
	self.m_timeLogicNodeArr = {}--倒计时逻辑节点
	self.m_txtWithLGNodeArr = {}--存储挂载了logicNode的cell的 txtLabelMin
	self.m_bmDlg = nil--成功报名对话框
	self.m_btnRes = {[25] = "bg/all_mttBtnHLS", [14] = "bg/all_mttBtnBD"}
	self.m_t1Res = {[25] = "赛事logo", [14] = "赛事来源"}
	self.m_t2Res = {[25] = "赛事信息", [14] = "赛事名称"}
	self.m_name = {[25] = "matchInfo", [14] = "matchInfo"}
	self.m_listener = nil--自定义事件
	self.m_listDlg = nil--选择俱乐部列表 
	
    self:init()
end

------------------------btn-------------------------------
local function handleReturn(sender)
	require("main.AllGame"):rebackScreen()
	g_self:removeFromParent()
	g_self = nil

	local myEvent = cc.EventCustom:new("C_Event_Update_MTT_CARD_NUM")
    local customEventDispatch = cc.Director:getInstance():getEventDispatcher()
    customEventDispatch:dispatchEvent(myEvent)
end

local function showList(sender)
	
	if(sender:getTag() == g_self.m_IN_WHICH_MATCH_LIST) then
		return
	end

	g_self.m_data = nil
	
	--g_self.m_btnL:loadTexture("bg/all_mttBtnHLSUn.png")
	g_self.m_btnL:loadTexture(g_self.m_btnRes[g_self.m_flag]..'Un.png')
	g_self.m_btnR:loadTexture("bg/all_mttBtnWDBSUn.png")
	g_self.m_IN_WHICH_MATCH_LIST = sender:getTag()

	--重置cell LabelMin的logic指向
	for i = 1, #g_self.m_txtWithLGNodeArr do
		g_self.m_txtWithLGNodeArr[i].logicNode = nil
	end
	g_self.m_txtWithLGNodeArr = {}

	--清理计时器逻辑节点
	for k, v in pairs(g_self.m_timeLogicNodeArr) do
        v:removeFromParent()
    end
	g_self.m_timeLogicNodeArr = {}
	

	--欢乐赛
	if(g_self.m_IN_WHICH_MATCH_LIST == 1) then
		--g_self:initData(1)
		--g_self.m_tableView:reloadData()
		--sender:loadTexture("bg/all_mttBtnHLS.png")
		sender:loadTexture(g_self.m_btnRes[g_self.m_flag]..'.png')
	--我的比赛
	elseif(g_self.m_IN_WHICH_MATCH_LIST == 2) then
		--g_self:initData(2)
		--g_self.m_tableView:reloadData()
		sender:loadTexture("bg/all_mttBtnWDBS.png")
	end


    --发送消息
    local function response(data)
        --dump(data)
        if(g_self ~= nil)then
        	g_self.m_data = data--列表数据
        	
        	if(g_self.initData ~= nil) then
        		g_self:initData(g_self.m_IN_WHICH_MATCH_LIST)
        		g_self.m_tableView:reloadData()
        	end
    	end
    end

    local tab = {}
    print("hhhhhh===="..g_self.m_flag)
    --25--大厅mtt标志
    if(g_self.m_flag == 25) then
        tab['mttType'] = g_self.m_IN_WHICH_MATCH_LIST
    	tab['page'] = 1
    	tab['every_page'] = 30
    	MainCtrol.filterNet("game_hall/getMttList", tab, response, PHP_POST)
    --14--本地化
    elseif(g_self.m_flag == 14) then
        tab['mod'] = g_self.m_IN_WHICH_MATCH_LIST
        local MainLayer = require 'main.MainLayer'
        tab['city_code'] = MainLayer:getCityCode()
        MainCtrol.filterNet("LocalMttList", tab, response, PHP_POST)
    end
end

--进入游戏按钮
local function gameIn( sender )
	print("进入游戏")
	dump(sender.data)
	local GameWait = require("game.GameWait")
	GameWait.intoWaitScene(sender.data.matchID)
end

--报名或者延迟报名按钮
local function gameBM( sender )
	print("报名")
--[[
	dump(sender.data)
	--如果是14，为本地化mtt，走本地化UI逻辑
	if(g_self.m_flag == 14) then
		--如果是联盟，判断是否是该联盟成员，是的话弹聊天框，不是就弹详情框
		if(sender.data.from == 'union') then
			--请求是否是联盟成员
		    local function response(data)
		        print("是否是联盟成员返回数据")
		        dump(data)
		        --是联盟的成员
		        if(data.is_union_members == 1) then
		        	DZChat.checkChat(data.club_id, StatusCode.CHAT_CLUB)
				--不是联盟的成员
				else
					local tab = {}
					tab["pokerId"] = sender.data.matchID

					local MttShowCtorl = require("common.MttShowCtorl")
					MttShowCtorl.dataStatStatus(function()
							MttShowCtorl.MttSignUp(tab, "hallMtt")
						end, tab)
		        end
		    end

		    local tab = {}
		    tab['union_id'] = sender.data.from_id
		    MainCtrol.filterNet("isUnionMember", tab, response, PHP_POST)
		--如果是系统创建的，直接查看详情框
		elseif(sender.data.from == "system") then
			local tab = {}
			tab["pokerId"] = sender.data.matchID
			local MttShowCtorl = require("common.MttShowCtorl")
			MttShowCtorl.dataStatStatus(function()
					MttShowCtorl.MttSignUp(tab, "hallMtt")
					end, tab)
		end

	--如果是25，为大厅mtt，走大厅UI逻辑
	elseif(g_self.m_flag == 25) then
		--请求报名消息
	    local function response(data)
	        --print("报名返回数据。。。。")
	        --dump(data)
	        g_self:showBMDlg(sender.data)
	    end

	    local tab = {}
	    tab['mtt_id'] = sender.data.matchID
	    MainCtrol.filterNet("mttApply", tab, response, PHP_POST)
	end
	]]
--[[
	--请求报名消息
    local function response(data)
        --print("报名返回数据。。。。")
        --dump(data)
        g_self:showBMDlg(sender.data)
    end

    local tab = {}
    tab['mtt_id'] = sender.data.matchID
    MainCtrol.filterNet("mttApply", tab, response, PHP_POST)
]]

dump(sender.data)
	
    --请求报名消息
    local function response(data)
        --print("报名返回数据。。。。")
        --dump(data)
        if(g_self == nil) then
        	return
        end
        
        g_self:showBMDlg(sender.data)
    end

    local function GPSBack(jd, wd)
    	--如果是14，为本地化mtt，判断是否需要group_id
		if(g_self.m_flag == 14) then
			--如果是联盟，判断是否是该联盟成员，
			--是成员的话选择对应的俱乐部，传group_id，
			--不是成员就group_id = 0
			if(sender.data.from == 'union') then
				--请求是否是联盟成员
			    local function responseM(data)
			        print("是否是联盟成员返回数据")
			        dump(data)
			        --是联盟的成员
			        if(data.is_union_members == 1) then
			        	
			        	print("kkkjjjlllbbb---")
			        	dump(sender.data.choose_club)
	                    --判断该用户有没有多个俱乐部
			        	--如果数量大于1证明有多个俱乐部
			        	--多个俱乐部弹框，让玩家选择要进入的俱乐部，做活跃统计用
			        	if(#sender.data.choose_club > 1) then
			        		local function callBackFun(data)
			        			print("fcccc="..data.club_id)
			        			local tab = {}
	    						tab['mtt_id'] = sender.data.matchID
	    						tab['group_id'] = data.club_id
								tab['longitude'] = jd
								tab['latitude'] = wd
	    						MainCtrol.filterNet("mttApply", tab, response, PHP_POST)
			        		end

			        		g_self:showSelceClubList(sender.data.choose_club, callBackFun)
			        	else
			        		--DZChat.checkChat(data.club_id, StatusCode.CHAT_CLUB)
			        		print("cccc="..sender.data.choose_club[1].club_id)
			        		local tab = {}
	    					tab['mtt_id'] = sender.data.matchID
	    					tab['group_id'] = sender.data.choose_club[1].club_id
	    					tab['longitude'] = jd
							tab['latitude'] = wd
	    					MainCtrol.filterNet("mttApply", tab, response, PHP_POST)
			        	end
					--不是联盟的成员
					else
						local tab = {}
	    				tab['mtt_id'] = sender.data.matchID
	    				tab['group_id'] = 0
	    				tab['longitude'] = jd
						tab['latitude'] = wd
	    				MainCtrol.filterNet("mttApply", tab, response, PHP_POST)
			        end
			    end

			    local tab = {}
			    tab['union_id'] = sender.data.from_id
			    MainCtrol.filterNet("isUnionMember", tab, responseM, PHP_POST)
			--如果是系统创建的，直接报名，不传group_id
			elseif(sender.data.from == "system") then
				local tab = {}
	    		tab['mtt_id'] = sender.data.matchID
	    		tab['longitude'] = jd
				tab['latitude'] = wd
	    		MainCtrol.filterNet("mttApply", tab, response, PHP_POST)
			end
		--其他情况直接报名
		else
			local tab = {}
	    	tab['mtt_id'] = sender.data.matchID
	    	tab['longitude'] = jd
			tab['latitude'] = wd
	    	MainCtrol.filterNet("mttApply", tab, response, PHP_POST)
		end
    end
    local isGPSPoker = false
	if tonumber(sender.data.open_gps) == 1 then
		isGPSPoker = true
	else
		isGPSPoker = false
	end
	Single:paltform():getLatitudeAndLongitude(GPSBack, isGPSPoker)
	
end

local function showHelp( sender )
	print("显示帮助")
	local dlg = require("main/HelpDlg"):create(2)
	g_self.m_root:addChild(dlg)
end 

------------------------------------------------------------end

--处理时间数字
local function mNumber(num)
	local ret = tonumber(num)

	if(ret < 10) then
		ret = "0"..tostring(ret) 
	end
	
	return ret
end

--注册刷新事件
local function CustomCallBackUpdateMttList(event)  
    printf("Test Custom Eventmmmmm")
    --刷新比赛界面
	g_self.m_IN_WHICH_MATCH_LIST = -1
	showList(g_self.m_btnL)
end  

-------------------------tableView--------------------------------------------

local function updateCellContent(idx, layer)

    if(g_self.m_data[idx] == nil) then
        return
    end

    local cdata = g_self.m_data[idx]
	layer.data = g_self.m_data[idx]
    --print("hhh~~~~~")
    --dump(cdata)

	local tCell = layer:getChildByName("Panel_root")
         
    --flagImg
    local img = ccui.Helper:seekWidgetByName(tCell, "Image_typeFlag")
    img:getChildByName("Image_gb"):stopAllActions()
	img:getChildByName("Image_gb"):runAction(cc.RepeatForever:create(cc.RotateBy:create(1, 360)))

    if(g_self.m_flag == 25) then--大厅mtt
    	if(g_self.m_data[idx].path ~= nil and g_self.m_data[idx].path ~= "") then--如果地址不为空，头像不为空，那么不要重新创建，直接取path里图片赋值		
			img:loadTexture(cdata.path)
			img:getChildByName("Image_gb"):setVisible(false)
			--print("---1")
    	elseif(g_self.m_data[idx].path == nil) then--如果都为空，重新创建头像
    		local url = cdata.logo_img
    		--print("---2")
			--贴图回调
			local function funcBack( path )

				local function onEvent(event)
					if event == "exit" then
						return
					end
				end
				img:registerScriptHandler(onEvent)


				img:loadTexture(path)
				img:getChildByName("Image_gb"):setVisible(false)

				if(g_self.m_data == nil) then
					return
				end

				g_self.m_data[idx].path = path
				--print("---2.3")
			end
			
			if url ~= "" then
				--print("---2.1")
				--ClubModel.downloadPhoto(funcBack, url, true)

				--优化的
				ClubModel.replayDownloadPhoto(funcBack, url, true, img, true)
				--以前的
				-- ClubModel.downloadPhoto(funcBack, url, true, "download")
			else
				--print("---2.2")
				g_self.m_data[idx].path = ""
				img:getChildByName("Image_gb"):stopAllActions()
				img:getChildByName("Image_gb"):runAction(cc.RepeatForever:create(cc.RotateBy:create(1, 360)))
				--img:loadTexture("bg/all_mttType"..cdata["matchType"]..".png")
			end
		elseif(g_self.m_data[idx].path == "") then--为空字符串处理
			--print("---3")
			img:getChildByName("Image_gb"):stopAllActions()
			img:getChildByName("Image_gb"):runAction(cc.RepeatForever:create(cc.RotateBy:create(1, 360)))
			--img:loadTexture("bg/all_mttType"..cdata["matchType"]..".png")
    	end
    elseif(g_self.m_flag == 14) then--本地mtt
    	img:getChildByName("Image_gb"):setVisible(false)
    	if(g_self.m_data[idx].path ~= nil and g_self.m_data[idx].path ~= "") then--如果地址不为空，头像不为空，那么不要重新创建，直接取path里图片赋值		
    		local rect = img.stencil:getContentSize()
			img.clubIcon:setTexture(cdata.path)
			--img.clubIcon:setTextureRect(cc.size(200, 184))
    	elseif(g_self.m_data[idx].path == nil) then--如果都为空，重新创建头像
    		local url = cdata.avatar
    		
			--贴图回调
			local function funcBack( path )

				local function onEvent(event)
					if event == "exit" then
						return
					end
				end
				img.clubIcon:registerScriptHandler(onEvent)

				local rect = img.stencil:getContentSize()
				img.clubIcon:setTexture(path)
				img.clubIcon:setTextureRect(rect)
				g_self.m_data[idx].path = path
			end
			
			if url ~= "" then
				--ClubModel.downloadPhoto(funcBack, url, true)
				--优化后的
				ClubModel.replayDownloadPhoto(funcBack, url, true, img, true)
				--之前的
				-- ClubModel.downloadPhoto(funcBack, url, true, "download")
			else
				if cdata.from == "union" then
					--img.clubIcon:setTexture(ResLib.CLUB_HEAD_GENERAL)
					img.clubIcon:setTexture(ResLib.UNION_HEAD)
				else
					img.clubIcon:setTexture(ResLib.CLUB_HEAD_ORIGIN)
				end
				g_self.m_data[idx].path = ""
			end
		elseif(g_self.m_data[idx].path == "") then--为空字符串处理

			if cdata.from == "union" then
				--img.clubIcon:setTexture(ResLib.CLUB_HEAD_GENERAL)
				img.clubIcon:setTexture(ResLib.UNION_HEAD)
			else
				img.clubIcon:setTexture(ResLib.CLUB_HEAD_ORIGIN)
			end
    	end
    end
    
    --txt比赛类型文字，赛事名称
    local txt = ccui.Helper:seekWidgetByName(tCell, "Text_sname")
	txt:setString(cdata[g_self.m_name[g_self.m_flag]])
    
    --报名费
    txt = ccui.Helper:seekWidgetByName(tCell, "Text_fee")
    local daiRuFee = tonumber(cdata["matchFee"])
    local shouQuFee = daiRuFee/10
	txt:setString(tostring(daiRuFee).."+"..tostring(shouQuFee))

	--报名人数
	txt = ccui.Helper:seekWidgetByName(tCell, "Text_getinNum")
	txt:setString(cdata["matchPeopleNum"])

	--初始化报名或者进入按钮---------------------------------------
	txt = ccui.Helper:seekWidgetByName(tCell, "Text_btn")
	txt:setVisible(false)
	local btn = ccui.Helper:seekWidgetByName(tCell, "Button_BM")
	btn:setVisible(false)
	btn.data = cdata
	--欢乐赛1-报名 2-延迟报名 3-终止报名 4-已经报名 等待开始 5-进入 6-重新报名
	if(g_self.m_IN_WHICH_MATCH_LIST == 1) then
		--终止报名
		if(tonumber(cdata["matchBtnStatus"]) == 3) then
			txt:setVisible(true)
			txt:setString("终止报名")
		--已经报名 等待开始
		elseif(tonumber(cdata["matchBtnStatus"]) == 4) then
			txt:setVisible(true)
			txt:setString("等待开始")
		elseif(tonumber(cdata["matchBtnStatus"]) == 5) then
			btn:setVisible(true)
	  		btn:loadTextureNormal("bg/all_mttBtnJR.png")
		   	btn:loadTexturePressed("bg/all_mttBtnJRUn.png")
	       	btn:loadTextureDisabled("bg/all_mttBtnJRUn.png")
	       	btn:touchEnded(gameIn)
		elseif(tonumber(cdata["matchBtnStatus"]) == 2) then
			btn:setVisible(true)
		   	btn:loadTextureNormal("bg/all_mttBtnBM"..cdata["matchBtnStatus"]..".png")
		   	btn:loadTexturePressed("bg/all_mttBtnBMUn"..cdata["matchBtnStatus"]..".png")
	       	btn:loadTextureDisabled("bg/all_mttBtnBMUn"..cdata["matchBtnStatus"]..".png")
	       	btn:touchEnded(gameBM)
       	elseif(tonumber(cdata["matchBtnStatus"]) == 1) then
			btn:setVisible(true)
		   	btn:loadTextureNormal("bg/all_mttBtnBM"..cdata["matchBtnStatus"]..".png")
		   	btn:loadTexturePressed("bg/all_mttBtnBMUn"..cdata["matchBtnStatus"]..".png")
	       	btn:loadTextureDisabled("bg/all_mttBtnBMUn"..cdata["matchBtnStatus"]..".png")
	       	btn:touchEnded(gameBM)
	    elseif(tonumber(cdata["matchBtnStatus"]) == 6) then
			btn:setVisible(true)
		   	btn:loadTextureNormal("bg/all_cxbm.png")
		   	btn:loadTexturePressed("bg/all_cxbmUn.png")
	       	btn:loadTextureDisabled("bg/all_cxbmUn.png")
	       	btn:touchEnded(gameBM)
       	end
	--我的比赛1-进入 2-进行中
    elseif(g_self.m_IN_WHICH_MATCH_LIST == 2) then
    	--进行中
    	if(tonumber(cdata["matchBtnStatus"]) == 2) then
			txt:setVisible(true)
			txt:setString("等待开始")
    	else
    		btn:setVisible(true)
	  		btn:loadTextureNormal("bg/all_mttBtnJR.png")
		   	btn:loadTexturePressed("bg/all_mttBtnJRUn.png")
	       	btn:loadTextureDisabled("bg/all_mttBtnJRUn.png")
	       	btn:touchEnded(gameIn)
       	end
    end

    --R A 显示
    local imgR = ccui.Helper:seekWidgetByName(tCell, "Image_A")
    local imgA = ccui.Helper:seekWidgetByName(tCell, "Image_R")
    imgR:setVisible(false)
    imgA:setVisible(false)

    if(tonumber(cdata["isR"]) == 1) then
    	imgR:setVisible(true)
    end

    if(tonumber(cdata["isA"]) == 1) then
    	imgA:setVisible(true)
    end

    --时间显示
    for i = 1, 4 do
    	ccui.Helper:seekWidgetByName(tCell, "Panel_time"..i):setVisible(false)
    end

    --如果时间状态在可预知状态内
    if(tonumber(cdata["matchDayStatus"]) >= 1 and tonumber(cdata["matchDayStatus"]) <= 4) then

	    local pTime = ccui.Helper:seekWidgetByName(tCell, "Panel_time"..cdata["matchDayStatus"])
	    pTime:setVisible(true)

	    --倒计时
	    if(tonumber(cdata["matchDayStatus"]) == 3) then
	    	--没有记录过倒计时，创建新的倒计时
	    	if(cdata["isInUpDate"] ~= true) then
	    		--print("is No InUpDate idx==="..idx)
		    	g_self.m_data[idx].isInUpDate = true
		    	local tMin = tonumber(cdata["matchTimeMin"])
		    	local tSec = tonumber(cdata["matchTimeSec"])

		    	ccui.Helper:seekWidgetByName(tCell, "Text_timeMin"):setString(mNumber(tMin))
		    	ccui.Helper:seekWidgetByName(tCell, "Text_timeSec"):setString(mNumber(tSec))
		    	local logicNode = require('main.AllGameTimeLogicNode'):create(ccui.Helper:seekWidgetByName(tCell, "Text_timeMin"), ccui.Helper:seekWidgetByName(tCell, "Text_timeSec"), tMin, tSec)
		    	g_self:addChild(logicNode)
		    	g_self.m_timeLogicNodeArr[idx] = logicNode

		    	--记录当前txt绑定的节点logicNode，为以后解除用
		    	ccui.Helper:seekWidgetByName(tCell, "Text_timeMin").logicNode = logicNode
		    	--将txt绑定的logicNode全部塞入容器中，删除的时候清空用，防止了空指针指控的问题
		    	table.insert(g_self.m_txtWithLGNodeArr, ccui.Helper:seekWidgetByName(tCell, "Text_timeMin"))
		  
		    --已经有倒计时了,重新指向读秒的txt
		    else
		    	--print("isInUpDate idx==="..idx)
		    	local tMin = tonumber(g_self.m_timeLogicNodeArr[idx]:getMin())
		    	local tSec = tonumber(g_self.m_timeLogicNodeArr[idx]:getSec())
		    	ccui.Helper:seekWidgetByName(tCell, "Text_timeMin"):setString(mNumber(tMin))
		    	ccui.Helper:seekWidgetByName(tCell, "Text_timeSec"):setString(mNumber(tSec))

		    	--重新指向新的计时器
				g_self.m_timeLogicNodeArr[idx]:setTxtMin(ccui.Helper:seekWidgetByName(tCell, "Text_timeMin"))
				g_self.m_timeLogicNodeArr[idx]:setTxtSec(ccui.Helper:seekWidgetByName(tCell, "Text_timeSec"))
				ccui.Helper:seekWidgetByName(tCell, "Text_timeMin").logicNode = g_self.m_timeLogicNodeArr[idx]
				--将txt绑定的logicNode全部塞入容器中，删除的时候清空用，防止了空指针指控的问题
				table.insert(g_self.m_txtWithLGNodeArr, ccui.Helper:seekWidgetByName(tCell, "Text_timeMin"))
	    	end

	    elseif( tonumber(cdata["matchDayStatus"]) == 1 or tonumber(cdata["matchDayStatus"]) == 2) then
	    	local tHour = mNumber(tonumber(cdata["matchTimeHours"]))
	    	local tMin = mNumber(tonumber(cdata["matchTimeMin"]))
			pTime:getChildByName("Text_BStime"):setString(tHour..":"..tMin)

			--明天显示年月日
			if(tonumber(cdata["matchDayStatus"]) == 1) then
				local sLabelStr = cdata["matchTimeYear"]..'/'..cdata["matchTimeMonth"]..'/'..cdata["matchTimeDay"]
				pTime:getChildByName("Text_2"):setString(sLabelStr)
			end

	    end
	end
    
end

local function tableCellTouched(table, cell)
	require("main.AllGame"):rebackScreen()
	--只有大厅mtt的时候才可以查看详细
	if(g_self.m_flag == 25) then
--[[
		--发送消息
	    local function response(data)
	    	data.idx = cell:getChildByTag(123).data["matchID"]
	        require("main/AllGameMTTCellContent"):create(data)
	    end

	    local tab = {}
	    tab['mtt_id'] = cell:getChildByTag(123).data["matchID"]

	    MainCtrol.filterNet("MttOverview", tab, response, PHP_POST)
]]
		local tab = {}
		tab["pokerId"] = cell:getChildByTag(123).data.matchID
		local MttShowCtorl = require("common.MttShowCtorl")
		MttShowCtorl.dataStatStatus(function()
				MttShowCtorl.MttSignUp(tab, "hallMtt")
				end, tab)
	--如果是14，为本地化mtt，走本地化UI逻辑
	elseif(g_self.m_flag == 14) then
		--如果是联盟，判断是否是该联盟成员，是的话弹聊天框，不是就弹详情框
		if(cell:getChildByTag(123).data.from == 'union') then
			--请求是否是联盟成员
		    local function response(data)
		        print("是否是联盟成员返回数据")
		        dump(data)
		        --是联盟的成员,根据选择的俱乐部情况，得到融云id，然后进入聊天界面
		        if(data.is_union_members == 1) then
		        	
		        	print("kkkjjjlllbbb---")
		        	dump(cell:getChildByTag(123).data.choose_club)
                    --判断该用户有没有多个俱乐部
		        	--如果数量大于1证明有多个俱乐部
		        	--多个俱乐部弹框，让玩家选择要进入的俱乐部，做活跃统计用
		        	if(#cell:getChildByTag(123).data.choose_club > 1) then
		        		--DZChat.checkChat(data.club_id, StatusCode.CHAT_CLUB)
		        		local function callBackFun(data)
		        			print("rrrry="..data.club_id)
		        			DZChat.checkChat(data.club_id, StatusCode.CHAT_CLUB)
		        		end

		        		g_self:showSelceClubList(cell:getChildByTag(123).data.choose_club, callBackFun)
		        	--只有一个俱乐部的情况直接进入，不选择俱乐部的列表框
		        	else
		        		print("rrrry="..cell:getChildByTag(123).data.choose_club[1].club_id)
		        		DZChat.checkChat(cell:getChildByTag(123).data.choose_club[1].club_id, StatusCode.CHAT_CLUB)
		        	end
				--不是联盟的成员
				else
					local tab = {}
					tab["pokerId"] = cell:getChildByTag(123).data.matchID

					local MttShowCtorl = require("common.MttShowCtorl")
					MttShowCtorl.dataStatStatus(function()
							MttShowCtorl.MttSignUp(tab, "hallMtt")
						end, tab)
		        end
		    end

		    local tab = {}
		    tab['union_id'] = cell:getChildByTag(123).data.from_id
		    MainCtrol.filterNet("isUnionMember", tab, response, PHP_POST)
		--如果是系统创建的，直接查看详情框
		elseif(cell:getChildByTag(123).data.from == "system") then
			local tab = {}
			tab["pokerId"] = cell:getChildByTag(123).data.matchID
			local MttShowCtorl = require("common.MttShowCtorl")
			MttShowCtorl.dataStatStatus(function()
					MttShowCtorl.MttSignUp(tab, "hallMtt")
					end, tab)
		end
	end
end

local function numberOfCellsInTableView(table)
	if(g_self == nil) then
		return 0
	end

    if(g_self.m_data == nil) then 
        return 0
    end
    
    return #g_self.m_data
end

local function cellSizeForTable(table,idx)
    return g_self.m_cellSize.width, g_self.m_cellSize.height + 10
end

local function tableCellAtIndex(table, idx)
    idx = idx + 1--默认从0开始，lua里没0所以+1
    local cell = table:dequeueCell() 
    
    --如果table 队列里取出的cell为空，重新创建一个
    if nil == cell then
        cell = cc.TableViewCell:new()
        local layer = cc.CSLoader:createNodeWithVisibleSize(g_self.m_CELL_RES)
        layer:setContentSize(g_self.m_cellSize)
        layer:setTag(123)
        cell:addChild(layer)

        --如果是本地mtt，头像从网络获取，先初始化裁切模板
        if(g_self.m_flag == 14) then
        	local tCell = layer:getChildByName("Panel_root")
        	local img = ccui.Helper:seekWidgetByName(tCell, "Image_typeFlag")
        	img:getChildByName("Image_gb"):runAction(cc.RepeatForever:create(cc.RotateBy:create(1, 360)))
        	--local stencil, clubIcon = UIUtil.createCircle(ResLib.CLUB_HEAD_GENERAL, cc.p(20, 0), img, ResLib.CLUB_HEAD_STENCIL_200)
        	local stencil, clubIcon = UIUtil.createCircle(ResLib.UNION_HEAD, cc.p(20, 0), img, ResLib.CLUB_HEAD_STENCIL_200)
			img.stencil = stencil
			img.clubIcon = clubIcon
			stencil:setAnchorPoint(cc.p(0,0))
			clubIcon:setAnchorPoint(cc.p(0,0))			
			img:loadTexture("common/com_opacity0.png")
		elseif(g_self.m_flag == 25) then
			local tCell = layer:getChildByName("Panel_root")

    		local batchParNode = {}
			local tpar = cc.ParticleSystemQuad:create("bg/xiaodiandonghua.plist")
			tpar:unscheduleUpdate()
		    batchParNode = cc.ParticleBatchNode:createWithTexture(tpar:getTexture())
			batchParNode:setPosition(cc.p(0, 0))
			tCell:addChild(batchParNode)

			local px, py = tCell:getChildByName("Particle_1"):getPosition()
			local emitter = cc.ParticleSystemQuad:create("bg/xiaodiandonghua.plist")
			--ccui.Helper:seekWidgetByName(root, "Panel_panelGame"):addChild(emitter)
    		batchParNode:addChild(emitter)
    		emitter:setPosition(cc.p(px, py))
    		emitter:setAutoRemoveOnFinish(true)
    		emitter:setPositionType(kCCPositionTypeRelative)
    		
        end
    end

    --根据idx，重新更新cell内容
    updateCellContent(idx, cell:getChildByTag(123))

    return cell
end

--------------------------------------------------------------------------------------end

function AllGameMTT:init()

	self:initData(1)
	--print("hhh2222~~~~~")
	--dump(self.m_data)
	--print("flag===="..self.m_flag)
	if(self.m_flag == nil) then
		return
	end

	g_self = nil
	g_self = self

	--初始化层
    local runScene = cc.Director:getInstance():getRunningScene()
    runScene:addChild(self, StringUtils.getMaxZOrder(runScene))

    local cs = cc.CSLoader:createNodeWithVisibleSize("scene/AllGameMTT.csb")
    self:addChild(cs)
    self.m_root = cs:getChildByName("Panel_root")
    
    --返回按钮
    local btn = ccui.Helper:seekWidgetByName(self.m_root, "Button_back")
    btn:touchEnded(handleReturn)

    --问号帮助按钮
    btn = ccui.Helper:seekWidgetByName(self.m_root, "Button_wenHao")
    btn:touchEnded(showHelp)

    --初始化title1, title2
    ccui.Helper:seekWidgetByName(self.m_root, "Text_title1"):setString(self.m_t1Res[self.m_flag])
    ccui.Helper:seekWidgetByName(self.m_root, "Text_title2"):setString(self.m_t2Res[self.m_flag])

    --点击欢乐赛 或者本地赛事
	self.m_btnL = ccui.Helper:seekWidgetByName(self.m_root, "Image_tLBtn")
    self.m_btnL:touchEnded(showList)
    self.m_btnL:setTag(1)
    self.m_btnL:loadTexture(g_self.m_btnRes[self.m_flag]..'.png')
    
    --点击我的比赛
    self.m_btnR = ccui.Helper:seekWidgetByName(self.m_root, "Image_tRBtn")
    self.m_btnR:touchEnded(showList)
    self.m_btnR:setTag(2)


    --创建列表
    local modelP = ccui.Helper:seekWidgetByName(self.m_root, "Panel_t")
    local tLayer = cc.CSLoader:createNodeWithVisibleSize(self.m_CELL_RES)
    local tCell = tLayer:getChildByName("Panel_root")
    self.m_cellSize = tCell:getContentSize()
    --print('cccccsssssss=='.._gcsize.width..",".._gcsize.height)
    --print('mmmssss=='..modelP:getContentSize().width..","..modelP:getContentSize().height)
    local tableView = cc.TableView:create(modelP:getContentSize())
    tableView:initWithViewSize(modelP:getContentSize())
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setPosition(cc.p(0, 0))
    tableView:setDelegate()
    modelP:addChild(tableView)
    --注册列表相关事件
    tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)   
    tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
    tableView:setBounceable(true)
    tableView:reloadData()
    self.m_tableView = tableView

    --注册刷新事件
    local listenerCustom = cc.EventListenerCustom:create("C_Event_Update_MTT_List", CustomCallBackUpdateMttList)  
    local customEventDispatch = cc.Director:getInstance():getEventDispatcher()
    customEventDispatch:addEventListenerWithFixedPriority(listenerCustom, 1)
    self.m_listener = listenerCustom

    --退出后移除注册的事件
    local function onNodeEvent(event)
        if event == "exit" then
            if(self.m_listener ~= nil) then
                local customEventDispatch = cc.Director:getInstance():getEventDispatcher()
                customEventDispatch:removeEventListener(self.m_listener)

                --移除红点
			    --移除红点
			    if self.m_flag == 14 then
			    	Notice.deleteBuildCard(1)
			    elseif self.m_flag == 25 then
			    	Notice.deleteMessage( 9, 1 )
			    end
                print("llll---removeM")
            end
        end
    end
    
    self:registerScriptHandler(onNodeEvent)

    --发送事件
    --[[
    local myEvent = cc.EventCustom:new("C_Event_Update_MTT_List")
	local customEventDispatch = cc.Director:getInstance():getEventDispatcher()
    customEventDispatch:dispatchEvent(myEvent) 
    ]]

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

    --移除红点
    if self.m_flag == 14 then
    	Notice.deleteBuildCard(1)
    elseif self.m_flag == 25 then
    	Notice.deleteMessage( 9, 1 )
    end




--[[

	--测试 http请求网络图片 的代码
	local function HttpRequestCompleted(statusCode,tagNum,image)
	    print("图片数据请求结果 statusCode:"..statusCode.."  tag:"..tagNum)

	    --200表示获取网络图片成功，否则失败
	    if statusCode==200 then

	        local texture=cc.Texture2D:new()
	        texture:initWithImage(image)
	        local sp_goodsItem=cc.Sprite:createWithTexture(texture)  --直接创建请求的网络图片精灵，不用再保存到本地，很方便的
	        self:addChild(sp_goodsItem, 99999999)
	    end

	end
	
	--最后一个参数是tag值，缺省是-1，这个参数与回调函数HttpRequestCompleted的第2个参数对应
	cc.HandleData:getInstance():requestGoodsImageFromWeb("http://images.allbetspace.com/big_0.522907001486539754370554.jpg",HttpRequestCompleted,123)

]]


end

function AllGameMTT:initData(tType)
--[[
self.m_data = {
[1] = {
["matchID"]=212,
["isA"]=1,
["current_time"]=1482387440,
["matchPeopleNum"]=0,
["matchInfo"]="this is a mtt test",
["isR"]=1,
["game_mod"]="63",
["start_time"]=1482308697,
["matchBtnStatus"]=0,
["matchType"]=2,
["team_name"]="system",
["from"]="system",
["avatar"]="",
["matchFee"]=200,
},

[2] = {
["matchID"]=212,
["isA"]=1,
["current_time"]=1482387440,
["matchPeopleNum"]=0,
["matchInfo"]="this is a mtt test",
["isR"]=1,
["game_mod"]="63",
["start_time"]=1482308697,
["matchBtnStatus"]=0,
["matchType"]=2,
["team_name"]="system",
["from"]="system",
["avatar"]="",
["matchFee"]=200,
},

[3] = {
["matchID"]=212,
["isA"]=1,
["current_time"]=1482387440,
["matchPeopleNum"]=0,
["matchInfo"]="this is a mtt test",
["isR"]=1,
["game_mod"]="63",
["start_time"]=1482308697,
["matchBtnStatus"]=0,
["matchType"]=2,
["team_name"]="system",
["from"]="system",
["avatar"]="",
["matchFee"]=200,
},

[4] = {
["matchID"]=212,
["isA"]=1,
["current_time"]=1482387440,
["matchPeopleNum"]=0,
["matchInfo"]="this is a mtt test",
["isR"]=1,
["game_mod"]="63",
["start_time"]=1482308697,
["matchBtnStatus"]=0,
["matchType"]=2,
["team_name"]="system",
["from"]="system",
["avatar"]="",
["matchFee"]=200,
},

[5] = {
["matchID"]=212,
["isA"]=1,
["current_time"]=1482387440,
["matchPeopleNum"]=0,
["matchInfo"]="this is a mtt test",
["isR"]=1,
["game_mod"]="63",
["start_time"]=1482308697,
["matchBtnStatus"]=0,
["matchType"]=2,
["team_name"]="system",
["from"]="system",
["avatar"]="",
["matchFee"]=200,
},

[6] = {
["matchID"]=212,
["isA"]=1,
["current_time"]=1482387440,
["matchPeopleNum"]=0,
["matchInfo"]="this is a mtt test",
["isR"]=1,
["game_mod"]="63",
["start_time"]=1482308697,
["matchBtnStatus"]=0,
["matchType"]=2,
["team_name"]="system",
["from"]="system",
["avatar"]="",
["matchFee"]=200,
},

[7] = {
["matchID"]=212,
["isA"]=1,
["current_time"]=1482387440,
["matchPeopleNum"]=0,
["matchInfo"]="this is a mtt test",
["isR"]=1,
["game_mod"]="63",
["start_time"]=1482308697,
["matchBtnStatus"]=0,
["matchType"]=2,
["team_name"]="system",
["from"]="system",
["avatar"]="",
["matchFee"]=200,
},

[8] = {
["matchID"]=212,
["isA"]=1,
["current_time"]=1482387440,
["matchPeopleNum"]=0,
["matchInfo"]="this is a mtt test",
["isR"]=1,
["game_mod"]="63",
["start_time"]=1482308697,
["matchBtnStatus"]=0,
["matchType"]=2,
["team_name"]="system",
["from"]="system",
["avatar"]="",
["matchFee"]=200,
},

[9] = {
["matchID"]=212,
["isA"]=1,
["current_time"]=1482387440,
["matchPeopleNum"]=0,
["matchInfo"]="this is a mtt test",
["isR"]=1,
["game_mod"]="63",
["start_time"]=1482308697,
["matchBtnStatus"]=0,
["matchType"]=2,
["team_name"]="system",
["from"]="system",
["avatar"]="",
["matchFee"]=200,
},

[10] = {
["matchID"]=212,
["isA"]=1,
["current_time"]=1482387440,
["matchPeopleNum"]=0,
["matchInfo"]="this is a mtt test",
["isR"]=1,
["game_mod"]="63",
["start_time"]=1482308697,
["matchBtnStatus"]=0,
["matchType"]=2,
["team_name"]="system",
["from"]="system",
["avatar"]="",
["matchFee"]=200,
},

[11] = {
["matchID"]=212,
["isA"]=1,
["current_time"]=1482387440,
["matchPeopleNum"]=0,
["matchInfo"]="this is a mtt test",
["isR"]=1,
["game_mod"]="63",
["start_time"]=1482308697,
["matchBtnStatus"]=0,
["matchType"]=2,
["team_name"]="system",
["from"]="system",
["avatar"]="0.427208001474677992764983.jpg",
["matchFee"]=200,
},

[12] = {
["matchID"]=212,
["isA"]=1,
["current_time"]=1482387440,
["matchPeopleNum"]=0,
["matchInfo"]="this is a mtt test",
["isR"]=1,
["game_mod"]="63",
["start_time"]=1482308697,
["matchBtnStatus"]=0,
["matchType"]=2,
["team_name"]="system",
["from"]="system",
["avatar"]="0.427208001474677992764983.jpg",
["matchFee"]=200,
}
}
]]
	if(self.m_data == nil) then
		self.m_data = {}
		return
	end


	--print("hhhh111111")
	--dump(self.m_data)
	--self.m_data = nil
	for i = 1, #self.m_data do
		--print("dddddd213123")
		--dump(self.m_data[i])
		--比赛时间协议处理
		--根据current_time和start_time，判断显示哪种时间类型
		--"matchDayStatus" 1明天 2今天 3倒计时 4正在进行 5显示月日
		local cTime = tonumber(self.m_data[i].current_time)
		local sTime = tonumber(self.m_data[i].start_time)
		--print("iiiiii===="..i)
		--print("init---- c="..cTime.." s="..sTime)
		--d = {year=2005, month=11, day=6, hour=22,min=18,sec=30,isdst=false}
	
		local tTime = os.date("*t", cTime);
		local cday = tTime['yday']
		local chour = tTime['hour']
		local cmin = tTime['min']
		local csec = tTime['sec']
		--print("initcccccc----cd="..cday.." ch="..chour.." cm="..cmin.." csec="..csec)

		tTime = os.date("*t", sTime);
		local syear = tTime['year']
		local smonth = tTime['month']
		local sday = tTime['yday']
		local sssday = tTime['day']
		local shour = tTime['hour']
		local smin = tTime['min']
		local ssec = tTime['sec']

		print("asdaszxcsadasd")
		dump(tTime)

		--print("initssssss---- sd="..sday.." sh="..shour.." sm="..smin.." ssec="..ssec)
		--print(" ")

		--如果当前时间 大于 开赛时间，证明比赛已经开始了，显示正在进行
		--显示正在进行
		if(cTime > sTime) then
			self.m_data[i].matchDayStatus = 4
		--比赛还没开始
		else
			--根据日数判断是今天还是明天
			--如果是明天的比赛，判断距离明天的日期
			
			print("iii=="..i)
			print("sss=="..sTime)
			print("ccc=="..cTime)
			print("ddd=="..(sTime - cTime)/86400)
			if(sday - cday >= 1 or sday - cday < 0) then
			--if((sTime - cTime)/86400 >= 1) then
				--判断是否需要倒计时
				--小时数相差1，需要计算分钟数来判断是否需要倒计时
				if(shour + 24  - chour <= 1) then
					--如果分钟小于60证明开始读秒
					if(smin + 60 - cmin < 60) then
						self.m_data[i].matchDayStatus = 3
					--大于60，还是属于明天的
					else
						self.m_data[i].matchDayStatus = 1
					end
				
				--小时数相差大于等于2，证明是明天的比赛
				else
					self.m_data[i].matchDayStatus = 1
				end 

			--今天的比赛
			else
				--小时数相差1，需要计算分钟数来判断是否需要倒计时
				if(shour - chour == 1) then
					--如果分钟小于60证明开始读秒
					if(smin + 60 - cmin < 60) then
						self.m_data[i].matchDayStatus = 3
					--大于60，还是属于今天的
					else
						self.m_data[i].matchDayStatus = 2
					end
				--如果等于0，证明不足一小时，进入倒计时
				elseif(shour - chour == 0) then
					self.m_data[i].matchDayStatus = 3
				--小时数相差大于等于2，证明是今天的比赛
				else
					self.m_data[i].matchDayStatus = 2
				end 
			end
		end

		--如果是倒计时，现实当前时间
		if(self.m_data[i].matchDayStatus == 3) then
			self.m_data[i].matchTimeHours = tostring(shour)
			--self.m_data[i].matchTimeMin = tostring(smin + 60 - cmin)
			--self.m_data[i].matchTimeSec = tostring(sTime - cTime)
			self.m_data[i].matchTimeMin = tostring(math.floor((sTime - cTime)/60))
			self.m_data[i].matchTimeSec = tostring((sTime - cTime) - math.floor((sTime - cTime)/60)*60)

		--如果是明天或者今天，现实开始时间
		elseif(self.m_data[i].matchDayStatus == 1 or self.m_data[i].matchDayStatus == 2) then
			self.m_data[i].matchTimeHours = tostring(shour)
			self.m_data[i].matchTimeMin = tostring(smin)
			self.m_data[i].matchTimeSec = tostring(ssec)
			self.m_data[i].matchTimeYear = tostring(syear)
			self.m_data[i].matchTimeMonth = tostring(mNumber(smonth))
			self.m_data[i].matchTimeDay = tostring(mNumber(sssday))
		end

		self.m_data[i].matchDayStatus = tostring(self.m_data[i].matchDayStatus)


		--欢乐赛
		if(tType == 1) then
--[[
			--处理按钮状态协议转换
			----服务端协议id如下3种（客户端id 号加 1）
			--0.游戏开始前  1. 游戏开始且可报名 2. 截止报名
			---------------------
			--在欢乐赛里就分别对应
			--报名，延迟报名，终止报
			---------------------
			--------进行协议转换--------------
			--欢乐赛1-报名 2-延迟报名 3-终止报名 4-已经报名
			print("tttttttt8798797979="..self.m_data[i].matchBtnStatus)
			self.m_data[i].matchBtnStatus = self.m_data[i].matchBtnStatus + 1

			--1.已经报名
			if(self.m_data[i].is_apply == 1) then
				self.m_data[i].matchBtnStatus = 4
			end
]]
            --matchBtnStatus 1-报名 2-延迟报名 3-终止报名 4-已经报名 等待开始 5-进入
            
			-- cardStatus 0 报名中, 1进行中, 2截止报名
			-- entryStatus 0 可以报名， 1 已报名可取消（10分钟内不能取消比赛)， 2待审核，3可重新报名，4被彻底淘汰
			local cardStatus = tonumber(self.m_data[i].status)
			local entryStatus = tonumber(self.m_data[i].is_entry)
			local offEntry = tonumber(self.m_data[i].stop_entry)
			print("cardStatus="..cardStatus)
			print("entryStatus="..entryStatus)
			print("offEntry="..offEntry)

			if cardStatus == 0 then
				-- 报名
				if entryStatus == 0 then
					self.m_data[i].matchBtnStatus = 1
				-- 取消报名（不能取消按照距离开赛时间判断）
				elseif entryStatus == 1 then
					self.m_data[i].matchBtnStatus = 4
				elseif entryStatus == 2 then
					--entryLabel:setString("等待房主同意您的报名申请...")
					self.m_data[i].matchBtnStatus = 4
				end
			elseif cardStatus == 1 then
				-- 截止报名
				if offEntry == 1 then
					if entryStatus == 0 or entryStatus == 2 or entryStatus == 3 then
						--entryLabel:setString("截止报名")
						self.m_data[i].matchBtnStatus = 3
					elseif entryStatus == 1 then
						--entryDes:setString("您已在比赛中")
						self.m_data[i].matchBtnStatus = 5
					elseif entryStatus == 4  then
						--entryDes:setString("已截止报名")
						self.m_data[i].matchBtnStatus = 3
					end
				else
					-- 未报名
					if entryStatus == 0 then
						self.m_data[i].matchBtnStatus = 2
					-- 回到比赛
					elseif entryStatus == 1 then
						--entryDes:setString("您已在比赛中")
						self.m_data[i].matchBtnStatus = 5		
					-- 待审核
					elseif entryStatus == 2 then
						--entryLabel:setString("等待房主同意您的报名申请...")
						self.m_data[i].matchBtnStatus = 4
					-- 重新报名
					elseif entryStatus == 3 then
						self.m_data[i].matchBtnStatus = 6
					-- 已被淘汰
					elseif entryStatus == 4 then
						--entryLabel:setString("您已经被淘汰")
						self.m_data[i].matchBtnStatus = 3
					end
				end
			elseif cardStatus == 3 then
				--entryLabel:setString("比赛已结束")
				self.m_data[i].matchBtnStatus = 3
			end


	--[[
			self.m_data = {
				[1] = {
					["matchID"] = "1",
					["matchType"] = "1",
					["matchInfo"] = "100元话费赛",
					["matchFee"] = "6",
					["matchPeopleNum"] = "26",
					["matchBtnStatus"] = "1",
					["matchDayStatus"] = "3",
					["matchTimeHours"] = "21",----
					["matchTimeMin"] = "2",-----
					["matchTimeSec"] = "50",----
					["isR"] = "1",
					["isA"] = "1",
		        },

		        [2] = {
					["matchID"] = "2",
					["matchType"] = "2",
					["matchInfo"] = "500元话费赛",
					["matchFee"] = "16",
					["matchPeopleNum"] = "6",
					["matchBtnStatus"] = "2",
					["matchDayStatus"] = "3",
					["matchTimeHours"] = "22",-----
					["matchTimeMin"] = "1",----
					["matchTimeSec"] = "2",-----
					["isR"] = "0",
					["isA"] = "1",
		        },

		        [3] = {
					["matchID"] = "3",
					["matchType"] = "3",
					["matchInfo"] = "1000元话费赛",
					["matchFee"] = "62",
					["matchPeopleNum"] = "236",
					["matchBtnStatus"] = "3",
					["matchDayStatus"] = "3",
					["matchTimeHours"] = "23",-----
					["matchTimeMin"] = "0",-----
					["matchTimeSec"] = "10",----
					["isR"] = "1",
					["isA"] = "0",
		        }
		    }

	]]
		--我的比赛
		else
            ---cd按钮状态协议转换
			----服务端协议id如下3种（客户端id 号加 1）
			--0.游戏开始前  1. 游戏开始且可报名 2. 截止报名
			---------------------
			--在我的比赛里对应
			--0，显示等待开始
			--1和2 显示进入
			--------进行协议转换--------------
			--我的比赛1-进入 2-进行中
			if(self.m_data[i].matchBtnStatus == 1 or self.m_data[i].matchBtnStatus == 2) then
				self.m_data[i].matchBtnStatus = 1
			elseif(self.m_data[i].matchBtnStatus == 0) then
				self.m_data[i].matchBtnStatus = 2
			end

			--[[

			self.m_data = {

				[1] = {
					["matchID"] = "1",
					["matchType"] = "1",
					["matchInfo"] = "100元话费赛",
					["matchFee"] = "6",
					["matchPeopleNum"] = "6",
					["matchBtnStatus"] = "1",
					["matchDayStatus"] = "3",
					["matchTimeHours"] = "8",---
					["matchTimeMin"] = "12",---
					["matchTimeSec"] = "50",---
					["isR"] = "0",
					["isA"] = "0",
				},

				[2] = {
					["matchID"] = "2",
					["matchType"] = "2",
					["matchInfo"] = "300元话费赛",
					["matchFee"] = "100",
					["matchPeopleNum"] = "990",
					["matchBtnStatus"] = "2",
					["matchDayStatus"] = "2",
					["matchTimeHours"] = "9",----
					["matchTimeMin"] = "0",----
					["matchTimeSec"] = "50",----
					["isR"] = "1",
					["isA"] = "0",
				},

				[3] = {
					["matchID"] = "3",
					["matchType"] = "3",
					["matchInfo"] = "1000元话费赛",
					["matchFee"] = "1000",
					["matchPeopleNum"] = "590",
					["matchBtnStatus"] = "2",
					["matchDayStatus"] = "1",
					["matchTimeHours"] = "6",----
					["matchTimeMin"] = "20",----
					["matchTimeSec"] = "50",----
					["isR"] = "1",
					["isA"] = "0",
				}
			}
			]]
		end
	end
end

function AllGameMTT:showBMDlg(data)

	if(self.m_bmDlg == nil) then
		self.m_bmDlg = cc.CSLoader:createNodeWithVisibleSize("scene/AllDlg.csb")
    	self.m_root:addChild(self.m_bmDlg)
	end


	local root = self.m_bmDlg:getChildByName("Panel_root")

	local str = data.matchFee
	if(tonumber(data.matchFee) == 0) then
		str = "免费"
	end

	--报名费
	ccui.Helper:seekWidgetByName(root, "Text_fee"):setString(str)
	--比赛信息
	ccui.Helper:seekWidgetByName(root, "Text_name"):setString(data.matchInfo)

	--比赛时间
	local showTime = nil
	if(data.matchDayStatus == "1") then
		showTime = ccui.Helper:seekWidgetByName(root, "Panel_time_1")
		showTime:setVisible(true)
		ccui.Helper:seekWidgetByName(showTime, "Text_timeH"):setString(mNumber(data.matchTimeHours))
		ccui.Helper:seekWidgetByName(showTime, "Text_timeM"):setString(mNumber(data.matchTimeMin))

		--显示年月日
		local sLabelStr = data["matchTimeYear"]..'/'..data["matchTimeMonth"]..'/'..data["matchTimeDay"]
		showTime:getChildByName("Text_48"):setString(sLabelStr)
		
	elseif(data.matchDayStatus == "2") then
		showTime = ccui.Helper:seekWidgetByName(root, "Panel_time_2")
		showTime:setVisible(true)
		ccui.Helper:seekWidgetByName(showTime, "Text_timeH"):setString(mNumber(data.matchTimeHours))
		ccui.Helper:seekWidgetByName(showTime, "Text_timeM"):setString(mNumber(data.matchTimeMin))
	end

	--确定按钮
	local btn = ccui.Helper:seekWidgetByName(root, "Button_ok")
	btn:touchEnded(
		function(event)
			print("确定按钮")
			--移除对话框界面
			self.m_bmDlg:removeFromParent()
			self.m_bmDlg = nil

			--刷新比赛界面
			g_self.m_IN_WHICH_MATCH_LIST = -1
			showList(self.m_btnL)
		end)

end

--显示选择俱乐部列表界面
--data-数据
--callBackFun-回调函数
function AllGameMTT:showSelceClubList(data, callBackFun)
	if(self.m_listDlg ~= nil) then
		self.m_listDlg:removeFromParent()
		self.m_listDlg = nil
	end

	local listDlg = cc.CSLoader:createNodeWithVisibleSize("scene/AllMttSelectClubList.csb")
	self.m_root:addChild(listDlg)
	self.m_listDlg = listDlg
	local root = self.m_listDlg:getChildByName("Panel_root")
	local listView = ccui.Helper:seekWidgetByName(root, "ListView_1")

	for i = 1, #data do	
		local cell = cc.CSLoader:createNodeWithVisibleSize("scene/AllMttSelectClubListCell.csb")
		local tRoot = cell:getChildByName("Panel_root")
		tRoot:setTouchEnabled(true)
		ccui.Helper:seekWidgetByName(tRoot, "Text_name"):setString(data[i].club_name)
		tRoot.data = data[i]
		tRoot:removeFromParent()
		print(i.."="..data[i].club_name)
		--listView:addChild(cell)
		listView:pushBackCustomItem(tRoot)
		
	end

	local function listViewEvent(sender, eventType)
		--print("eventType"..eventType)
		if eventType == 1 then
			local index = sender:getCurSelectedIndex()
			local cell = sender:getItem(index)
		    print("select child index = "..cell.data.Rclub_id)
		    callBackFun(cell.data)
		    self.m_listDlg:setVisible(false)
		end
	end

	listView:setBounceEnabled(true)
	listView:addEventListener(listViewEvent)

	local Button_close = ccui.Helper:seekWidgetByName(root, "Button_close")
	Button_close:touchEnded(function(event)
			g_self.m_listDlg:removeFromParent()
			g_self.m_listDlg = nil
		end)
end

function AllGameMTT:create(data)
    return AllGameMTT.new(data)
end

return AllGameMTT