--
-- Author: Your Name
-- Date: 2016-10-28 18:01:25
--帮助对话框
--

local g_self = nil

--处理万以上数字
local function mWanNumber(num)
    local ret = tonumber(num)
    
    if(ret >= 10000) then
        ret = math.floor(ret/10000)
        ret = tostring(ret).."万"
    end

    return ret
end

--类
local HelpDlg = class("HelpDlg", function ()
    return cc.Node:create()
end)

function HelpDlg:ctor(flag, obj)
	self.m_flag = flag--1,2,3,4,
	self.m_root = nil
	self.m_MAX_NUM = 8
	self.m_pathToSave = cc.FileUtils:getInstance():getWritablePath()
	self.m_dirName = "download/"
	self.m_obj = obj
    self:init()
end

function HelpDlg:init()
	g_self = nil
	g_self = self
    local cs = cc.CSLoader:createNodeWithVisibleSize("scene/HelpDlg.csb")
    self:addChild(cs)
    self.m_root = cs:getChildByName("Panel_root")

    for i = 1, self.m_MAX_NUM do
    	ccui.Helper:seekWidgetByName(self.m_root, "Panel_"..i):setVisible(false)
    	print("asdi==="..i)
    end
    
    if(self.m_flag == 1 or self.m_flag == 2 or self.m_flag == 3 or self.m_flag == 4) then
    	self.m_root:touchEnded(
		function(event)
			g_self:removeFromParent()
		end)
    elseif(self.m_flag == 5) then
		local btn = ccui.Helper:seekWidgetByName(self.m_root, "Button_close")
		btn:touchEnded(
		function(event)
			g_self:removeFromParent()
		end)
		-- local text = ccui.Helper:seekWidgetByName(self.m_root, "Text_11")
	--大版本
	elseif(self.m_flag == 6) then
		local btn = ccui.Helper:seekWidgetByName(self.m_root, "Button_6")
		btn:touchEnded(
		function(event)
			--[[
			local winSize = cc.Director:getInstance():getVisibleSize()
		    self._webView = ccexp.WebView:create()
		    self._webView:setPosition(winSize.width / 2, winSize.height / 2-65)
		    self._webView:setContentSize(winSize.width,  winSize.height)
		    self._webView:loadURL("http://api.allbetspace.com/wei")
		    self._webView:setScalesPageToFit(true)
		    self._webView:setOnShouldStartLoading(function(sender, url)
		        print("onWebViewShouldStartLoading, url is ", url)
		        return true
		    end)
		    self._webView:setOnDidFinishLoading(function(sender, url)
		        print("onWebViewDidFinishLoading, url is ", url)
		    end)
		    self._webView:setOnDidFailLoading(function(sender, url)
		        print("onWebViewDidFinishLoading, url is ", url)
		    end)

		    self:addChild(self._webView)
		    ]]
		    local args = {}
		    args.url = "http://api.allbetspace.com/wei"
		    Single:paltform():luaCallNativeFunc(args, 0)

		    --清除小版本更新的缓存文件
		    local path = self.m_pathToSave..self.m_dirName
		    print("os.rmdir:"..path)
			print("before dddddddir="..tostring(CCFileUtils:sharedFileUtils():isFileExist(path)))

			local tPlatform = cc.Application:getInstance():getTargetPlatform()
			
			if (cc.PLATFORM_OS_IPHONE == tPlatform) or (cc.PLATFORM_OS_IPAD == tPlatform) or (cc.PLATFORM_OS_MAC == tPlatform) then
				cc.FileUtils:getInstance():removeDirectory(path)
			elseif tPlatform == cc.PLATFORM_OS_ANDROID then
				local cmdStr = "rm -rf "..path
				os.execute(cmdStr)
			end

			print("after dddddddir="..tostring(CCFileUtils:sharedFileUtils():isFileExist(path)))
		end)
	--小版本
	elseif(self.m_flag == 7) then
		local btn = ccui.Helper:seekWidgetByName(self.m_root, "Button_7")
		btn:touchEnded(
		function(event)
			local LoginCtrol = require("login.LoginCtrol")
			LoginCtrol.changeUser()
			DZChat.breakRYConnect()
			NoticeCtrol.removeNoticeNode()
			AUTO_LOGIN = false
			local loginScene = require("login.LoginScene")
			loginScene.startScene()
		end)
	--sng报名
    elseif(self.m_flag == 8) then
    	local btn = ccui.Helper:seekWidgetByName(self.m_root, "Button_qx")
		btn:touchEnded(
		function(event)
			g_self:removeFromParent()
		end)

		btn = ccui.Helper:seekWidgetByName(self.m_root, "Button_bm")
		btn:touchEnded(
		function(event)
			print("BBBM")

			local function response(data)
            	-- GameScene.startScene(data['gid'], StatusCode.INTO_MAIN)
            	local GameScene = require 'game.GameScene'
            	GameScene.startScene(data['gid'])
        	end
        
	        local tab = {}
	        tab['type'] = g_self.m_obj["type"]
	        tab['entry_fee'] = g_self.m_obj["entry_fee"]
	        tab['limit_players'] = 6
	        MainCtrol.filterNet("sng/quick_join", tab, response, PHP_POST)

		end)
		--g_self.m_obj 
		--ccui.Helper:seekWidgetByName(self.m_root, "Button_qx")
		local typename = {
			[1] = "新手场",
			[2] = "普通场",
			[3] = "职业场",
			[4] = "精英场",
			[5] = "卓越场",
			[6] = "大师场",
			[7] = "宗师场"
		}

		local txt = ccui.Helper:seekWidgetByName(self.m_root, "Text_bsname")
		txt:setString(typename[self.m_obj['type']])
		
		txt = ccui.Helper:seekWidgetByName(self.m_root, "Text_fee")
		local tStr = mWanNumber(tostring(self.m_obj['entry_fee']))

		if(tonumber(self.m_obj['entry_cost']) > 0) then
			tStr = tStr.."+"..mWanNumber(tostring(self.m_obj['entry_cost']))
		end
		txt:setString(tStr)

		txt = ccui.Helper:seekWidgetByName(self.m_root, "Text_v1")
		txt:setString(mWanNumber(self.m_obj['first_prize']))

		txt = ccui.Helper:seekWidgetByName(self.m_root, "Text_v2")
		txt:setString(mWanNumber(self.m_obj['second_prize']))

--[[
		tobj['type'] 
        tobj['entry_fee']
        tobj['limit_players'] 
    ]]    
        
    end

	ccui.Helper:seekWidgetByName(self.m_root, "Panel_"..self.m_flag):setVisible(true)
end


function HelpDlg:create(flag, obj)
    return HelpDlg.new(flag, obj)
end

return HelpDlg