local CppPlat = {}

local function download(curl, downBack, errBack, defaultResName, taskId)
	local imgName = curl
	local tpath = device.writablePath..imgName

	local function response(path, result)
		if result == 'task_error' and errBack then
			errBack(defaultResName)
		elseif result == 'file_success' and downBack then
			downBack(path)
		end
	end

	local isHave = cc.FileUtils:getInstance():isFileExist(tpath)
	if isHave then
		return downBack(tpath)
	else
		local newCurl = DZConfig.getHeadUrl(curl)
		local handle = cc.HandleData:createHandleData()
		handle:registerHandlerBack(response)
		dump(newCurl, "heihei")
		handle:fileTask(newCurl, tpath, taskId)
	end
end

function CppPlat.downResFile(curl, downBack, errBack, defaultResName,taskId)
	if not curl or string.len(curl) == 0 or curl == defaultResName then
		return errBack(defaultResName)
	end

	download(curl, downBack, errBack, defaultResName, taskId)

	return defaultResName
end


function CppPlat.downHead(curl, downBack, errBack)
	if not curl or string.len(curl) == 0 or curl == 'default_avatars.jpg' then
		return ResLib.USER_HEAD
	end

	local imgName = curl
	local tpath = device.writablePath..imgName

	local function response(path, result)
		if result == 'task_error' and errBack then
			errBack(ResLib.USER_HEAD)
		elseif result == 'file_success' and downBack then
			downBack(path)
		end
	end

	local isHave = cc.FileUtils:getInstance():isFileExist(tpath)
	if isHave then
		return tpath
	else
		local newCurl = DZConfig.getHeadUrl(curl)
		local handle = cc.HandleData:createHandleData()
		handle:registerHandlerBack(response)
		handle:fileTask(newCurl, tpath, 'identifier')
	end

	return ResLib.USER_HEAD
end

return CppPlat