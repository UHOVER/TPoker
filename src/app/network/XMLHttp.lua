local XMLHttp = {}
-- local _url = "http://101.201.48.107:9901/"
-- local _url = "http://101.201.48.107:9987/"--小明
-- local _url = "http://101.201.48.107:9989/" -- 服务器
local _url = "http://192.168.199.171:8799/"
-- local _url = "http://114.215.68.59:80/"
-- local _jsUrl = "http://101.201.48.107:8999/"----"http://192.168.199.108:8080/"--
local _jsUrl = "http://101.201.48.107:8999/"
-- local _url = "http://192.168.199.171:80/"
local _shareUrl = "http://share.allbetspace.com:9989/"
if DZ_MASTER_VERSION then
    _url = "http://api.allbetspace.com/"
    --_jsUrl = "http://139.129.213.1:8999/"----"http://192.168.199.108:8080/"--
    --_jsUrl = "http://192.168.199.108:8080/"--小游戏本地
    -- _jsUrl = "http://101.201.48.107:8999/"--小游戏测试
    _jsUrl = "http://api.allbetspace.com:8999/"--小游戏正式
    -- _url = "http://101.201.48.107:9901/"
    _shareUrl = "http://share.allbetspace.com:9989/"--分享地址
end

local LOGIN_TOKEN_KEY = 'LOGIN_TOKEN_KEY'
local register_token = ''
local forget_token = ''
local _loginToken = nil

local function setToken(data, httpUrl)
    if httpUrl == PHP_LOGIN or httpUrl == PHP_FORGET_SURE_PWD or httpUrl == PHP_REGISTER_PWD then
        if data['token'] == nil then
            print('setToken  '..httpUrl)
            return
        end
        Storage.setStringForKey(LOGIN_TOKEN_KEY, data['token'])
        _loginToken = data['token']

    elseif httpUrl == PHP_REGISTER then
        register_token = data['token']
    elseif httpUrl == PHP_FORGET_PWD then
        forget_token = data['token']
    end
end

local function getToken(httpUrl)
    local token = Storage.getStringForKey(LOGIN_TOKEN_KEY)
    if httpUrl == PHP_REGISTER_SURE or httpUrl == PHP_REGISTER_PWD then
        token = register_token
    elseif httpUrl == PHP_FORGET_SURE_PWD then
        token = forget_token
    end

    if not token then
        token = nil
    end

    return token
end



local function commonRequest(httpUrl, seddata, funcBack, rPattern, noShowWait, purl)
    local txhr = nil

    local function responseHttp()
        if not noShowWait then
            ViewCtrol.hidePHPWaitServer()
        end


        local tabData = nil
        if txhr.readyState == 4 and (txhr.status >= 200 and txhr.status < 207) then
            local jsonData  = txhr.response
            tabData = jsonStr.decode(jsonData, 1)
        else
            print("xhr.readyState is:", txhr.readyState, "xhr.status is: ", txhr.status)
            ViewCtrol.showMsg('连接出错')

            DZChat.netLinkError()
            return
        end
        
        txhr:unregisterScriptHandler()
        txhr:release()
        txhr = nil

        print(serialize(tabData))

        if tabData['code'] == StatusCode.PHP_SUCCESS then
            setToken(tabData['data'], httpUrl)
            funcBack(tabData)
        elseif tabData['code'] == StatusCode.PHP_UPDATE then
            if not DZChat.isShowChatView() then
                ViewCtrol.showTip({ content = tabData['msg'], listener = function (  )
                    print("版本更新，退回到登录界面")
                    local currScene = cc.Director:getInstance():getRunningScene()
                    if currScene:getChildByName("LoginLayer") then
                        print("已退回到登录界面")
                        return
                    end
                    local LoginCtrol = require("login.LoginCtrol")
                    LoginCtrol.changeUser()
                    DZChat.breakRYConnect()
                    NoticeCtrol.removeNoticeNode()
                    AUTO_LOGIN = false
                    local loginScene = require("login.LoginScene")
                    loginScene.startScene()
                end})
            end
        elseif tabData['code'] == StatusCode.PHP_REFRESH_TOKEN then
            ViewCtrol.showMsg(tabData['msg'])
            local function xmlResponse( data )
                if data.code == 0 then
                    setToken(data['data'], PHP_LOGIN)
                end
            end
            XMLHttp.requestHttp("auth/refresh", '', xmlResponse, PHP_GET)
            return
        else
            if not DZChat.isShowChatView() then
                ViewCtrol.showTip({ content = tabData['msg']})
            end
            -- setToken(tabData['data'], httpUrl)
            funcBack(tabData)
        end
    end

    if not noShowWait then
        ViewCtrol.showPHPWaitServer()
    end

    txhr = cc.XMLHttpRequest:new()
    txhr:retain()
    txhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON

    txhr:setRequestHeader("Content-type", "application/json; charset=utf-8")
    if httpUrl ~= PHP_LOGIN and httpUrl ~= PHP_FORGET_PWD and httpUrl ~= PHP_REGISTER and httpUrl.match(httpUrl,PHP_SHARE) == nil then
        txhr:setRequestHeader("authorization", string.format("Bearer %s", getToken(httpUrl)))
    end
    -- print(string.format("Bearer %s", getToken(httpUrl)))
    
    txhr.timeout = 20
    txhr:registerScriptHandler(responseHttp)

    if rPattern == "POST" then
        print(serialize(seddata))
        print('type: '..'POST')
        txhr:open(rPattern, purl)
        txhr:send(json.encode(seddata))
    elseif rPattern == "GET" then
        print('type: '..'GET')
        txhr:open(rPattern, purl.."?"..seddata)
        txhr:send()
    end

end


function XMLHttp.requestHttp(httpUrl, seddata, funcBack, rPattern, noShowWait)
    local turl = _url..httpUrl
   commonRequest(httpUrl, seddata, funcBack, rPattern, noShowWait, turl) 
end


function XMLHttp.requestJSHttp(httpUrl, seddata, funcBack, rPattern, noShowWait)
    local turl = _jsUrl..httpUrl
   commonRequest(httpUrl, seddata, funcBack, rPattern, noShowWait, turl) 
end


function XMLHttp.requestAllUrl(allUrl, seddata, funcBack, rPattern, noShowWait)
    commonRequest(PHP_GET_LOGS, seddata, funcBack, rPattern, noShowWait, allUrl)
end


function XMLHttp.getGameToken()
    return getToken(nil)
end

function XMLHttp.getLoginToken()
    return _loginToken
end

function XMLHttp.getHttpUrl()
    return _url    
end

function XMLHttp.getShareUrl()
    return _shareUrl
end

function XMLHttp.setTestHttpUrl(testUrl)
    _url = testUrl
end
function XMLHttp.setTestJSUrl(jsUrl)
    _jsUrl = jsUrl
end


function XMLHttp.registerSocket()
    local function broPHPFunc(opcode, data)
        if opcode == BRO_PHP_3000 then
            if not data['message'] then
                local logs = 'XMLHttp.registerSocket'
                local explain = 'php推送广播出错'
                print('stack 出错广播了 '..logs)
                Single:appLogs(logs, explain)
                return
            end

            DZChat.broHandle(data['message'])

            Notice.broMessage(data["message"])

            local CheckNet = require 'network.CheckNet'
            CheckNet.broHandle(data['message'])

            local HandleBro = require 'utils.HandleBro'
            HandleBro.broMsg(data['message'])
        end
    end

    Network.bindBroadcast(broPHPFunc)
end


return XMLHttp

-- local test = '{"firstname":"Jesper","surname":"Aaberg","phone":["555-0100","555-0120"]}'
-- print('send data is '..json.encode(data))

-- XMLHttpRequest
-- 函数：
-- abort()：终止
-- getAllResponseHeaders()：所有请求头信息
-- getResponseHeader('Transfer-Encoding')：具体某个信息
-- setRequestHeader('fsfsf', 'kkk')：设置请求头

-- 属性：
-- withCredentials：false 或 true、
-- readyState
-- status：成功200
-- statusText：状态码字符串
-- responseText：返回数据只是字符串
-- response：返回数据对应 responseType 设置的类型，如 json