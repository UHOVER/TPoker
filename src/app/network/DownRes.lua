local DownRes = {}
local _url = 'http://192.168.1.103:8000/src.zip'
local _vurl = 'https://raw.github.com/samuele3hu/AssetsManagerTest/master/version'
local _asset = nil

local function onError(errorCode)
	print('onError  '..errorCode)
    if errorCode == cc.ASSETSMANAGER_NO_NEW_VERSION then
    elseif errorCode == cc.ASSETSMANAGER_NETWORK then
    end
end

local function onProgress(percent)
	print(percent)
end

local function onSuccess()
	ViewCtrol.showMsg('退出重新进入游戏', 5)
end


local function getAssets()
	if nil == _asset then
	    _asset = cc.AssetsManager:new(_url, _vurl, device.writablePath)
	    _asset:retain()
	    _asset:setDelegate(onError, cc.ASSETSMANAGER_PROTOCOL_ERROR )
	    _asset:setDelegate(onProgress, cc.ASSETSMANAGER_PROTOCOL_PROGRESS)
	    _asset:setDelegate(onSuccess, cc.ASSETSMANAGER_PROTOCOL_SUCCESS )
	    _asset:setConnectionTimeout(3)
	end

	return _asset
end

function DownRes.startDown()
	getAssets():deleteVersion()
	getAssets():checkUpdate()
end


return DownRes