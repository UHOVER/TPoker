local Storage = {}
Storage.ACCOUNT_KEY 	= 'ACCOUNT_KEY'
Storage.PWD_KEY 		= 'PWD_KEY'
Storage.INTERNAT_KEY 	= 'INTERNAT_KEY'
Storage.POKER_NAME_K 	= 'POKER_NAME_KEY'
Storage.POKER_TIME_K 	= 'POKER_TIME_KEY'

Storage.DESK_COLOR		= 'GAME_DESK_COLOR'

function Storage.setStringForKey(key, value, noFlush)
	cc.UserDefault:getInstance():setStringForKey(key, value)
	if noFlush then return end
	cc.UserDefault:getInstance():flush()
end

function Storage.getStringForKey(key)
	return cc.UserDefault:getInstance():getStringForKey(key)
end

function Storage.deleteValueForKey( key )
	cc.UserDefault:getInstance():deleteValueForKey(key)
end

function Storage.setDoubleForKey(key, value, noFlush)
	cc.UserDefault:getInstance():setDoubleForKey(key, value)
	if noFlush then return end
	cc.UserDefault:getInstance():flush()
end

function Storage.getDoubleForKey(key)
	return cc.UserDefault:getInstance():getDoubleForKey(key)
end


local function isBoolean(isbool)
	if type(isbool) ~= 'boolean' then
		assert(nil, 'setIsCloseVoice  '..type(isbool))
	end
end


--game
function Storage.getIsCloseVoice()
    return cc.UserDefault:getInstance():getBoolForKey('G_CLOSE_VOICE')
end
function Storage.setIsCloseVoice(isClose)
	isBoolean(isClose)
	cc.UserDefault:getInstance():setBoolForKey('G_CLOSE_VOICE', isClose)
    cc.UserDefault:getInstance():flush()
end

function Storage.setIsCloseGameSound(isClose)
	isBoolean(isClose)
	cc.UserDefault:getInstance():setBoolForKey('G_CLOSE_GAME_SOUND', isClose)
    cc.UserDefault:getInstance():flush()
end
function Storage.isCloseGameSound()
	return cc.UserDefault:getInstance():getBoolForKey('G_CLOSE_GAME_SOUND')
end

function Storage.getIsNoPrompt()
    return cc.UserDefault:getInstance():getBoolForKey('G_PROMPT')
end
function Storage.setIsNoPrompt(isNoPrompt)
	isBoolean(isNoPrompt)
	cc.UserDefault:getInstance():setBoolForKey('G_PROMPT', isNoPrompt)
    cc.UserDefault:getInstance():flush()
end



--用户信息
function Storage.setStorageUserName(uname)
	cc.UserDefault:getInstance():setStringForKey('DZ_USER_NAME', uname)
	cc.UserDefault:getInstance():flush()
end
function Storage.getStorageUserName()
	return cc.UserDefault:getInstance():getStringForKey('DZ_USER_NAME')
end

function Storage.setStorageUserHeadUrl(hImgUrl)
	cc.UserDefault:getInstance():setStringForKey('DZ_USER_HEAD_URL', hImgUrl)
	cc.UserDefault:getInstance():flush()
end

function Storage.setStorageUserId(unum)
	cc.UserDefault:getInstance():setStringForKey('DZ_USER_NUMBER', unum)
	cc.UserDefault:getInstance():flush()
end
function Storage.getStorageUserId()
	return cc.UserDefault:getInstance():getStringForKey('DZ_USER_NUMBER')
end

function Storage.setStorageImgHeadUrl(headUrl)
	cc.UserDefault:getInstance():setStringForKey('DZ_IMGURL_HEAD', headUrl)
	cc.UserDefault:getInstance():flush()
end


--游戏中
function Storage.setDeskColor(color)
	cc.UserDefault:getInstance():setStringForKey(Storage.DESK_COLOR, color)
	cc.UserDefault:getInstance():flush()
end
function Storage.getDeskColor()
	return cc.UserDefault:getInstance():getStringForKey(Storage.DESK_COLOR)
end


--java、oc、lua
--G_CLOSE_VOICE
--DZ_USER_NAME、DZ_USER_HEAD_IMG_NAME、DZ_USER_NUMBER

return Storage