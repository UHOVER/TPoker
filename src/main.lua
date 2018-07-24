local path = cc.FileUtils:getInstance():getWritablePath()
cc.FileUtils:getInstance():addSearchPath(path)
cc.FileUtils:getInstance():addSearchPath(path.."download/src/")
cc.FileUtils:getInstance():addSearchPath(path.."download/src/app/")
cc.FileUtils:getInstance():addSearchPath(path.."download/res/")

cc.FileUtils:getInstance():setPopupNotify(false)
cc.FileUtils:getInstance():addSearchPath("src/")
cc.FileUtils:getInstance():addSearchPath("src/app/")
cc.FileUtils:getInstance():addSearchPath("res/")

require "config"
require "cocos.init"


local function main()
	collectgarbage("collect")
    collectgarbage("setpause", 100)
    collectgarbage("setstepmul", 5000)

	math.randomseed(os.time())
    require("app.AppBase"):create():run()
end


local cclog = function(...)
    print(string.format(...))
end

function sendMsgToServer( msg )
	print('sendMsgToServer')
end

function __G__TRACKBACK__(msg)
    cclog("----------------------------------------")
    cclog("LUA ERROR: " .. tostring(msg) .. "\n")
    cclog(debug.traceback())
    cclog("----------------------------------------")

    local errmsg = tostring(msg).. "\n"..debug.traceback()
    require("app.AppBase"):create():client_logs(errmsg)

	-- pcall(
	-- 	sendMsgToServer(msg)
	-- )
    return msg
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    print(msg)
end

