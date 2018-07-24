local UserModel = class('UserModel')

function UserModel:setUserId(userid)
	self._userId = userid
end
function UserModel:getUserId()
	return self._userId
end

function UserModel:setUserRYId(ryid)
	self._ryId = ryid
end
function UserModel:getUserRYId()
	return self._ryId
end
--设置战队的图标url
function UserModel:setTeamBool(url)
	if url == nil then 
		url = false
	end
	self._isTeam = url
end

function UserModel:isTeam()
	return self._isTeam
end

function UserModel:setHeadUrl(url)
	self._headUrl = url
end
function UserModel:getHeadUrl()
	return self._headUrl
end

function UserModel:setUserName(name)
	self._userName = name
end
function UserModel:getUserName()
	return self._userName
end

function UserModel:setSurplusNum(surplus)
	if surplus < 0 then surplus = 0 end
	self._surplusNum = surplus
end
function UserModel:getSurplusNum()
	return self._surplusNum
end


function UserModel:setScores(scores)
	self._scores = scores
end
function UserModel:getScores()
	return self._scores
end

function UserModel:setIntoBet(ibet)
	self._intoBet = ibet
end
function UserModel:getIntoBet()
	return self._intoBet
end

function UserModel:isSeat()
	return false
end


function UserModel:isGaming()
	return false
end

function UserModel:getStatus()
	return StatusCode.GAME_NO_STATUS
end


function UserModel:isSelf()
	if Single:playerModel():getId() == self._userId then
		return true
	end
	return false
end


function UserModel:init()
	--id、头像地址、用户名、剩余砝码
	self._userId = nil
	self._headUrl = nil
	self._userName = nil
	self._surplusNum = nil
	self._isTeam = nil
	--积分(只有实时战况用到)
	self._scores = 0

	--带入(只有实时战况用到)
	self._intoBet = 0

	--融云id
	self._ryId = nil
end


return UserModel