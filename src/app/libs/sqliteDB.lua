local sqliteDB = {}

local fullPath = nil
local DB = nil

local width = 78
local function line(pref, suff)
    pref = pref or ''
    suff = suff or ''
    local len = width - 2 - string.len(pref) - string.len(suff)
    print(pref .. string.rep('-', len) .. suff)
end
local sqlite3 = require("sqlite3")


--打开数据库文件
local targetPlatform = cc.Application:getInstance():getTargetPlatform()
if cc.PLATFORM_OS_ANDROID == targetPlatform then
	fullPath = cc.FileUtils:getInstance():getWritablePath().."tpoker.ydwx"
else
	fullPath = cc.FileUtils:getInstance():fullPathForFilename("tpoker.ydwx")
end
-- fullPath = cc.FileUtils:getInstance():getWritablePath()..'tpoker.ydwx'

DB = sqlite3.open(fullPath)

-- dump(DB)
-- line(nil, 'db:exec')
-- DB:exec('CREATE TABLE message(id integer primary key autoincrement, avater, title, content)')

-- local db = sqlite3.open_memory()
-- print('==========  '..sqlite3.version())

-- 查询数据
function sqliteDB.getDB( table_name )
	local tab = {}
	local i = 1
	for row in DB:nrows("SELECT * FROM " .. table_name) do
		tab[i] = row
		i = i + 1
	end

	return tab
end

-- 插入数据
function sqliteDB.insertDB( tab )
	dump(tab)
	local result = DB:exec(" INSERT INTO message (org_id,mod,card_type,title,avatar,content,last_date) VALUES ('"..tab.org_id.."', '"..tab.mod.."', '"..tab.card_type.."', '"..tab.title.."', '"..tab.avatar.."', '"..tab.content.."', '"..tab.last_date.."') ")
	
	print("$$$$$$$$$$$$$$$$$"..result)
	if result ~= 0 then
		print("插入失败")
	else
		print("插入成功")
	end

end


function sqliteDB.updateDB( id, key, value )
	local result = DB:exec("UPDATE message SET "..key.." = '"..value.."' WHERE org_id = " .. id)
	if result ~= 0 then
		print("更新失败")
	end
end

-- 删除
function sqliteDB.deleteDB( value )
	DB:exec("DELETE FROM message WHERE org_id = '"..value.."' ")
end

function sqliteDB.closeDB(  )
	DB:close()
end

return sqliteDB