--
-- Author: Your Name
-- Date: 2016-10-25 10:33:17
--
--
-- Author: Your Name
-- Date: 2016-08-18 16:27:21
--
--require("lfs")

--类
local AssetsManagerNode = class("AssetsManagerNode", function ()
    return cc.Node:create()
end)

function AssetsManagerNode:ctor()
	self.m_assetsManager = nil
	--self.m_downLoadZipURL = "https://raw.github.com/samuele3hu/AssetsManagerTest/master/package.zip"
	--self.m_downLoadZipURL = "http://192.168.199.234:8000/download123.zip"
	self.m_downLoadZipURL = ""--下载地址
	--self.m_versionURL = "https://raw.github.com/samuele3hu/AssetsManagerTest/master/version"
	self.m_versionURL = ""--版本地址
	self.m_pathToSave = cc.FileUtils:getInstance():getWritablePath()
	self.m_dirName = "download/"
	self.m_is_must_update = ""--是否必需更新
	self.m_senderUI = nil--上级UI
	self.m_littleVersionKey = "kc_litV"--小版本号key值
	self.m_littleVersion = ""--小版本号value值
	self.m_vpVersionKey = "kc_vpV"--大版本号key值
	self.m_vpVersion = ""--大版本号value值
	self.m_zipSize = 0--zip包大小
	self.m_BIG_VERION_VALUE = UPDATE_VERSION--当前版本是V0 格式 V0,V1,V2...
    self:init()
end

function AssetsManagerNode:init()
	print("ttttt==vvvvv=="..UPDATE_VERSION)

	self.m_assetsManager = cc.AssetsManager:new(self.m_downLoadZipURL,
											self.m_versionURL,
                                           	self.m_pathToSave)
	

	local function onError(errorCode)
		print("~~~~~~~~~~~~~err="..errorCode)
	    if errorCode == cc.ASSETSMANAGER_NO_NEW_VERSION then
	        print("~~~~~~~~~~~~~no new version")
	    elseif errorCode == cc.ASSETSMANAGER_NETWORK then
	        print("~~~~~~~~~~~~~network error")
	    end
	end

	local function onProgress( percent )
	    local progress = string.format("downloading %d%%",percent)
	    print("~~~~~~~~~~~~~"..progress)
	    self.m_senderUI:setDownLoadPa(percent)
	   
		if(percent == 100) then
			self.m_senderUI:runInstallAction()
		end
	end

	--更新成功
	local function onSuccess()
	    print("~~~~~~~~~~~~~downloading onSuccess")

	    --local rp = self.m_pathToSave.."download/res/user/login_btn_forget.png"
	    --local sp = cc.Sprite:create(rp)
	    --self:addChild(sp, 9999)   
	    --dump(package.loaded)
	    --dump(package.preload)
		--package.loaded = {}
		--package.preload = {}
--[[
		for k,v in pairs(package.loaded) do
			--print("value===="..k)
			package.loaded[k] = nil
		end

		for k,v in pairs(package.preload) do
			--print("pvalue===="..k)
			package.preload[k] = nil
		end
]]	
		Network.destory()
		for k,v in pairs(package.loaded) do
			print("value===="..k)
			if(k ~= 'math' 
				and k ~= 'string' 
				and k ~= 'table' 
				and k ~= '_G'
				and k ~= 'libs.jsonStr') then
				package.loaded[k] = nil
			end
			--require(k)
		end

		require "main"

		--for i, tPanel in ipairs(showPanelArr) do
        --	tPanel:setVisible(false)
    	--end

    	--更新版本号
    	Storage.setStringForKey(self.m_littleVersionKey, self.m_littleVersion)
    	Storage.setStringForKey(self.m_vpVersionKey, self.m_vpVersion)
	
    	self.m_senderUI:playOverInstall()
	end

	self.m_assetsManager:retain()	
	self.m_assetsManager:setDelegate(onError, cc.ASSETSMANAGER_PROTOCOL_ERROR )
	self.m_assetsManager:setDelegate(onProgress, cc.ASSETSMANAGER_PROTOCOL_PROGRESS)
	self.m_assetsManager:setDelegate(onSuccess, cc.ASSETSMANAGER_PROTOCOL_SUCCESS )
	self.m_assetsManager:setConnectionTimeout(3)


	local function onEvent(event)
        if event == "enter" then
        elseif event == "enterTransitionFinish" then	
        elseif event == "exit" then
        	if(self.m_assetsManager ~= nil) then
				self.m_assetsManager:release()
			end

			self.m_assetsManager = nil
        end
    end
    
    self:registerScriptHandler(onEvent)
end



--------功能函数
function AssetsManagerNode:doUpdate(sender)
	print("~~~~~~~~~~~~~~send update")
    --self.m_assetsManager:deleteVersion()
    --self.m_assetsManager:checkUpdate()
	self.m_senderUI = sender

    --请求版本信息
	local function response(data)
        dump(data.data)

        if(self.m_senderUI ~= nil) then
	        self.m_is_must_update = tostring(data.data.is_must_update)
			self.m_downLoadZipURL = tostring(XMLHttp.getHttpUrl()..data.data.download_url)
			self.m_versionURL = tostring(XMLHttp.getHttpUrl()..data.data.version_url)
			self.m_littleVersion = tostring(data.data.new_version)
			self.m_vpVersion = tostring(data.data.vp_version)
			self.m_zipSize = tonumber(data.data.zip_size)
			self.m_senderUI:setInstallSizeTxt(data.data.zip_size)

	        --为1走更新逻辑
	        if(tostring(data.data.is_need_update) == '1') then
	        	--为1必须更新逻辑
	        	if(self.m_is_must_update == '1') then
	        		print("必须更新")
	        		self.m_senderUI:showFirstDlg(1)
	        		self.m_senderUI:closeRemoveSelf()
	        	--为0不用必须更新
	        	elseif(self.m_is_must_update == '0') then
	        		print("不用须更新")
	        		self.m_senderUI:showFirstDlg(0)
	        		self.m_senderUI:closeRemoveSelf()
	        	else
	        		print("无效的必需更新的参数--kc")
	        	end
	        --为0走不更新逻辑
	        elseif(tostring(data.data.is_need_update) == '0') then
	        	print("直接登入")
	        	self.m_senderUI:loginGame()
	        else
	        	print("无效的更新的参数--kc")
	        end
    	end
    end

    local tab = {}
    local tVersion = nil

    print("self.m_BIG_VERION_VALUE = "..self.m_BIG_VERION_VALUE)
    print("Storage.getStringForKey(self.m_vpVersionKey) = "..Storage.getStringForKey(self.m_vpVersionKey))
    
    --第一次装机=大版本号 + _000000000000
    if(Storage.getStringForKey(self.m_littleVersionKey) == "") then
    	tVersion = self.m_BIG_VERION_VALUE.."_000000000000"
    	print("00000---")
    --已经装机的玩家 大版本号与本地存储的不一致=大版本号 + _000000000000
    elseif (self.m_BIG_VERION_VALUE ~= Storage.getStringForKey(self.m_vpVersionKey)) then
    	print("11111---")
    	self:removeDownLoadDir()
    	tVersion = self.m_BIG_VERION_VALUE.."_000000000000"
		Storage.setStringForKey(self.m_littleVersionKey, tVersion)
		Storage.setStringForKey(self.m_vpVersionKey, self.m_BIG_VERION_VALUE)
    else
    	tVersion = Storage.getStringForKey(self.m_littleVersionKey)
    end

    print("curr version="..tVersion)
    tab['version'] = tVersion
    --MainCtrol.filterNet("getUpdateInfo", tab, response, PHP_POST)
	XMLHttp.requestHttp("getUpdateInfo", tab, response, PHP_POST)
end

--开始更新
function AssetsManagerNode:goUpdate()
	--大版本不一致删除多余目录
	if(self.m_BIG_VERION_VALUE ~= self.m_vpVersion) then
		self:removeDownLoadDir()
		print("请到官网下最新版本～～～～")
	end

	print('curr load url='..self.m_downLoadZipURL)
	print('curr version url='..self.m_versionURL)
    self.m_assetsManager:setPackageUrl(self.m_downLoadZipURL)
    self.m_assetsManager:setVersionFileUrl(self.m_versionURL)
    self.m_assetsManager:checkUpdate()
end

--删除多余目录
function AssetsManagerNode:removeDownLoadDir()
	
	--修改so
--[[
	local path = self.m_pathToSave..self.m_dirName
    print("os.rmdir:"..path)
	print("before dddddddir="..tostring(CCFileUtils:sharedFileUtils():isFileExist(path)))
	cc.FileUtils:getInstance():removeDirectory(path)
	print("after dddddddir="..tostring(CCFileUtils:sharedFileUtils():isFileExist(path)))
]]

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
	

--[[

	local path = self.m_pathToSave..'download/'
	local path2 = self.m_pathToSave..'test/'

	print("-------------------------------------------------")
    print("os.rmdir:"..path)
    local cmdStr = "rm -rf "..path2
    print("cmdStr:"..cmdStr)
	--os.execute(cmdStr)
	print("before dddddddir111 isFileExist="..tostring(cc.FileUtils:getInstance():isFileExist(path)))	
	print("mmmmmmmm111~~~~"..tostring(cc.FileUtils:getInstance():removeDirectory(path)))
	print("after dddddddir111 isFileExist="..tostring(cc.FileUtils:getInstance():isFileExist(path)))
	

	print("before creatdir222 isFileExist="..tostring(cc.FileUtils:getInstance():isFileExist(path2)))
	print("create Dir2222~~~~"..tostring(cc.FileUtils:getInstance():createDirectory(path2)))
	print("after creatdir222 isFileExist="..tostring(cc.FileUtils:getInstance():isFileExist(path2)))


	print("before dddddddir222 isFileExist="..tostring(cc.FileUtils:getInstance():isFileExist(path2)))	
	print("mmmmmmmm2222~~~~"..tostring(cc.FileUtils:getInstance():removeDirectory(path2)))
	print("after dddddddir222 isFileExist="..tostring(cc.FileUtils:getInstance():isFileExist(path2)))
	

	print("before OS dddddddir222 isFileExist="..tostring(cc.FileUtils:getInstance():isFileExist(path2)))	
	os.execute(cmdStr)
	print("after OS dddddddir222 isFileExist="..tostring(cc.FileUtils:getInstance():isFileExist(path2)))	
	]]



	--[[
    if CCFileUtils:sharedFileUtils():isFileExist(path) then
        --local function _rmdir(path)
        local _rmdir = function(path) 
            local iter, dir_obj = lfs.dir(path)
            while true do
                local dir = iter(dir_obj)
                if dir == nil then break end
                if dir ~= "." and dir ~= ".." then
                    local curDir = path..dir
                    local mode = lfs.attributes(curDir, "mode") 
                    if mode == "directory" then
                        _rmdir(curDir.."/")
                    elseif mode == "file" then
                        os.remove(curDir)
                    end
                end
            end
            local succ, des = os.remove(path)
            if des then print(des) end
            return succ
        end
        _rmdir(path)
    end
    ]]
end

--重新加载所有
function AssetsManagerNode:reloadAll()
	--display.removeUnusedSpriteFrames()
	cc.Director:getInstance():getTextureCache():removeAllTextures()
	require("app.AppBase"):create():run()
end


--------
function AssetsManagerNode:create()
    return AssetsManagerNode.new()
end

return AssetsManagerNode



