--
-- Author: Taylor
-- Date: 2017-01-19 18:38:46
-- 文件操作
-- require("lfs")
FileType = {}
FileType.IMAGE = 1
FileType.MUSIC = 2
FileType.FILE = 3
FileType.ALL = 4
local function readFile(path)
	local _file = io.open(path, "rb")
	if _file then
		local content = _file:read("*all")
		io.close(_file)
		return content
	end
	return nil
end

local function extension(path)
	 local extname = cc.FileUtils:getInstance():getFileExtension(path)
	 -- print("extname:"..extname)
	 if extname == ".png" or extname == ".jpg" or extname == ".jpeg" or 
	 	extname == ".pvr" then 
	 	return FileType.IMAGE

	 elseif extname == ".mp3" or extname == ".wav" or extname == ".mp4" then
	 	return FileType.MUSIC

	 elseif extname == ".plist" or extname == "" or extname == ".txt" or 
	 	 	extname == ".csv" or extname == ".json" or extname == ".xml" then 
	 	return FileType.FILE

	 else
	 	return FileType.ALL
 	 end
end

function checkDirOK( basepath, filepath)
	local filepath = filepath or ""
	local basepath = basepath or ""

	local function __mkdir(filepath, basepath)
		local oldpath = lfs.currentdir()

		if lfs.chdir(basepath..filepath) then
	        lfs.chdir(oldpath)
	        return true
	    end

	    local path = string.split(filepath, "/")
	    local newbasepath = basepath .. path[1] .."/"

		if lfs.chdir(newbasepath) then
			lfs.chdir(oldpath)
		else
			if not lfs.mkdir(newbasepath) then
				return false
			end
		end

		local newfilepath = ""
		if path[2] then
			table.remove(path,1)
			newfilepath = table.concat(path,"/") .. "/"
		end
		return __mkdir(newfilepath, newbasepath)
	end

	return __mkdir(filepath, basepath)
end

function os.exists(path)
    return cc.FileUtils:getInstance():isFileExist(path)
end

function os.mkdir(path)
    if not os.exists(path) then
        return lfs.mkdir(path)
    end
    return true
end


function os.rmdir(path, filetype, normdir)
    -- print("os.rmdir:", path)
    if os.exists(path) then
        local function _rmdir(path)
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
						if filetype == extension(curDir) or filetype == FileType.ALL then 
							print(curDir)
							local succ, des = os.remove(curDir)
							print("succ:"..tostring(succ))
							if des then print(des) end
						end
                    end
                end
            end
            if not isrmdir then 
            	local succ, des = os.remove(path)
            	if des then print(des) end
            else 
            	succ = true
            end
            return succ
        end
        _rmdir(path)
    end
    return true
end