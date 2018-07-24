--
-- Author: Your Name
-- Date: 2016-10-28 18:01:25
--
--

--类
local DownLoadUI = class("DownLoadUI", function ()
    return cc.Node:create()
end)

function DownLoadUI:ctor()
	self.m_root = nil
	--self.m_isInWifi = true--是否是wifi情况
	self.m_isMustUpdate = 2--是否必更1-是 0-不是 2-其他
	self.m_assetsManagerNode = nil--热更新逻辑节点
	self.m_isCanPlayActStat = 0--播放动画状态 0-不播放 1-播放到随机目标 2－播放到100%
	self.m_currInsP = 0--当前安装百分比
	self.m_randInsP = 85--随机目标百分比，85 － 95 之间
	self.m_addStepInsP = 20--每次增加到百分比
	self.m_loginUI = nil--登入UI
	self.m_schedulerEntry = nil
	self.m_isCanRemoveSelf = true--即使倒计时结束后是否可以移除自己
    self:init()
end


function DownLoadUI:init()
	
	self.m_assetsManagerNode = require('download.AssetsManagerNode'):create()
	self:addChild(self.m_assetsManagerNode)

	self:setPosition(cc.p(0, 0))
	self:setAnchorPoint(cc.p(0, 0))

	local cs = cc.CSLoader:createNodeWithVisibleSize("scene/DownloadUI.csb")
    self:addChild(cs)
	self.m_root = cs:getChildByName("Panel_root")

	ccui.Helper:seekWidgetByName(self.m_root, "Image_firstDlg"):setVisible(false)
	ccui.Helper:seekWidgetByName(self.m_root, "Image_wifiDlg"):setVisible(false)
	ccui.Helper:seekWidgetByName(self.m_root, "Image_downLoadDlg"):setVisible(false)
	ccui.Helper:seekWidgetByName(self.m_root, "Panel_showBtn1"):setVisible(false)
	ccui.Helper:seekWidgetByName(self.m_root, "Panel_showBtn2"):setVisible(false)

	local btn = ccui.Helper:seekWidgetByName(self.m_root, "Button_yes")
	btn:touchEnded(
		function(event)
			print("开始更新1")
			--在Wi-Fi环境中
			if(Single:paltform():getWiFiFlag() == "wifi") then
				self.m_assetsManagerNode:goUpdate(self)
				self:showDownLoadDlg()
			--不在Wi-Fi环境中
			else		
				self:showWifiDlg()
				--self:showDownLoadDlg()
			end
		end)

	--不必须更新------------------------------------
	btn = ccui.Helper:seekWidgetByName(self.m_root, "Button_ok")
	btn:touchEnded(
		function(event)
			print("开始更新2")
			--在Wi-Fi环境中
			if(Single:paltform():getWiFiFlag() == "wifi") then
				self.m_assetsManagerNode:goUpdate(self)
				self:showDownLoadDlg()
			--不在Wi-Fi环境中
			else		
				self:showWifiDlg()
				--self:showDownLoadDlg()
			end
		end)

	btn = ccui.Helper:seekWidgetByName(self.m_root, "Button_exit")
	btn:touchEnded(
		function(event)
			print("不必需更新退出,登入游戏")
			self:loginGame()
		end)

	--wifi提示按钮---------------------------------
	btn = ccui.Helper:seekWidgetByName(self.m_root, "Button_load_ok")
	btn:touchEnded(
		function(event)
			print("开始更新～")
			self.m_assetsManagerNode:goUpdate(self)
			self:showDownLoadDlg()
			--self:showDownLoadDlg()
		end)

	btn = ccui.Helper:seekWidgetByName(self.m_root, "Button_load_exit")
	btn:touchEnded(
		function(event)
			print("关闭")
			--必须更新
			if(self.m_isMustUpdate == 1) then 
				print("退出更新")
				self:removeFromParent()
			--不必须更新
			elseif (self.m_isMustUpdate == 0) then
				print("退出，登入游戏")
				self:loginGame()
			else
				self:removeFromParent()
			end
		end)


	--安装逻辑相关
	local function update()
		if self.m_isCanPlayActStat == 1 then
			self.m_addStepInsP = self.m_addStepInsP - 1
			
			if(self.m_addStepInsP <= 0) then
				self.m_addStepInsP = 1
			end			
			
			self.m_currInsP = self.m_currInsP + self.m_addStepInsP
		
			if(self.m_currInsP >= self.m_randInsP) then
				self.m_currInsP = self.m_randInsP
			end

			ccui.Helper:seekWidgetByName(self.m_root, "LoadingBar_install"):setPercent(self.m_currInsP)
			ccui.Helper:seekWidgetByName(self.m_root, "Text_installPa"):setString(tostring(self.m_currInsP)..'%')
		
		elseif self.m_isCanPlayActStat == 2 then
			self.m_currInsP = self.m_currInsP + self.m_addStepInsP

			if(self.m_currInsP >= 100) then
				self.m_currInsP = 100
			end

			ccui.Helper:seekWidgetByName(self.m_root, "LoadingBar_install"):setPercent(self.m_currInsP)
			ccui.Helper:seekWidgetByName(self.m_root, "Text_installPa"):setString(tostring(self.m_currInsP)..'%')
			
			if(self.m_currInsP == 100) then
				self.m_assetsManagerNode:reloadAll()
			end
		end
    end

    self:scheduleUpdateWithPriorityLua(update, 0)

    local function onNodeEvent(tag)
        if tag == "exit" then
            self:unscheduleUpdate()
			local scheduler = cc.Director:getInstance():getScheduler()
			--销毁计时器

            if(self.m_schedulerEntry ~= nil) then
				scheduler:unscheduleScriptEntry(self.m_schedulerEntry)
				self.m_schedulerEntry = nil
            end
            
        end
    end

    self:registerScriptHandler(onNodeEvent)

    --定时销毁自己
    local scheduler = cc.Director:getInstance():getScheduler()
	if(self.m_schedulerEntry ~= nil) then 
		scheduler:unscheduleScriptEntry(self.m_schedulerEntry)
	end

	self.m_schedulerEntry = nil
	self.m_schedulerEntry = scheduler:scheduleScriptFunc(function(dt)

		local scheduler = cc.Director:getInstance():getScheduler()
		if(self.m_schedulerEntry ~= nil) then
			scheduler:unscheduleScriptEntry(self.m_schedulerEntry)
			self.m_schedulerEntry = nil
        end

        print("kc in remove function~~~")

        if(self.m_isCanRemoveSelf == true) then
        	self:removeFromParent()
        end
	    
    end, 6, false)
	

    --检查更新
	self.m_assetsManagerNode:doUpdate(self)
end

--isMust是否是必需更新 数字类型 1-必需更新 0-不必必需更新
function DownLoadUI:showFirstDlg(isMust)
	self.m_isMustUpdate = isMust
	ccui.Helper:seekWidgetByName(self.m_root, "Image_firstDlg"):setVisible(true)
	ccui.Helper:seekWidgetByName(self.m_root, "Image_wifiDlg"):setVisible(false)
	ccui.Helper:seekWidgetByName(self.m_root, "Image_downLoadDlg"):setVisible(false)

	ccui.Helper:seekWidgetByName(self.m_root, "Panel_showBtn1"):setVisible(false)
	ccui.Helper:seekWidgetByName(self.m_root, "Panel_showBtn2"):setVisible(false)
	if(isMust == 1) then
		ccui.Helper:seekWidgetByName(self.m_root, "Panel_showBtn1"):setVisible(true)
	else
		ccui.Helper:seekWidgetByName(self.m_root, "Panel_showBtn2"):setVisible(true)
	end
end

--显示非wifi下，提示对话框
function DownLoadUI:showWifiDlg()
	ccui.Helper:seekWidgetByName(self.m_root, "Image_firstDlg"):setVisible(false)
	ccui.Helper:seekWidgetByName(self.m_root, "Image_wifiDlg"):setVisible(true)
	ccui.Helper:seekWidgetByName(self.m_root, "Image_downLoadDlg"):setVisible(false)
end

--显示正在下载对话框
function DownLoadUI:showDownLoadDlg()
	ccui.Helper:seekWidgetByName(self.m_root, "Image_firstDlg"):setVisible(false)
	ccui.Helper:seekWidgetByName(self.m_root, "Image_wifiDlg"):setVisible(false)
	ccui.Helper:seekWidgetByName(self.m_root, "Image_downLoadDlg"):setVisible(true)
end

--运行安装游戏逻辑
function DownLoadUI:runInstallAction()
    self.m_isCanPlayActStat = 1 
    self.m_randInsP = math.random(85, 95)
end

--播放剩余安装动画
function DownLoadUI:playOverInstall()
	self.m_isCanPlayActStat = 2
end

--设置更新包大小
function DownLoadUI:setInstallSizeTxt(size)
	ccui.Helper:seekWidgetByName(self.m_root, "Text_size"):setString(tostring(size).."KB")
end

--设置下载进度百分比
function DownLoadUI:setDownLoadPa(percent)
	ccui.Helper:seekWidgetByName(self.m_root, "LoadingBar_downLoad"):setPercent(percent)
	ccui.Helper:seekWidgetByName(self.m_root, "Text_loadPa"):setString(tostring(percent).."%")
end

--关闭移除自己开关
function DownLoadUI:closeRemoveSelf()
	self.m_isCanRemoveSelf = false
end

------------设置父节点
function DownLoadUI:setParentNode(parent)
	self.m_loginUI = parent
end

-------登入
function DownLoadUI:loginGame()
	self.m_loginUI:loginGame()
	self:removeFromParent()
end

function DownLoadUI:create()
    return DownLoadUI.new()
end

return DownLoadUI



